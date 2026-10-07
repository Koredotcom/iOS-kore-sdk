import Foundation

protocol ChatClientDelegate: AnyObject {
    func chatClient(_ client: ChatClient, didReceive event: ChatEvent)
    func chatClient(_ client: ChatClient, didFailHistoryHydration error: Error)
}

/// Chat client backed by the WebSocket session transport.
final class ChatClient {
    private let sessionManager: SessionManager
    private let config: SDKConfiguration

    private var messages: [Message] = []
    private var messageIds = Set<String>()
    private var isTyping = false
    private var streamingBuffers: [String: String] = [:]
    private var customData: [String: Any] = [:]
    private var inFlight: [PendingMessage] = []
    private var pendingFeedback: [String: PendingFeedback] = [:]

    private var historyHydrationTask: Task<Void, Never>?
    private var historyHydrationSessionId: String?
    private var historyHydrationGeneration = 0

    weak var delegate: ChatClientDelegate?

    init(sessionManager: SessionManager, config: SDKConfiguration) {
        self.sessionManager = sessionManager
        self.config = config
    }

    var customDataSnapshot: [String: AnySendable] {
        customData.mapValues { AnySendable($0) }
    }

    func updateCustomData(_ data: [String: Any]) {
        for (key, value) in data {
            customData[key] = value
        }
        ArtemisLogger.debug("Custom data updated", metadata: ["keys": Array(customData.keys)])
    }

    func clearCustomData() {
        customData.removeAll()
    }

    @discardableResult
    func send(
        text: String,
        metadata: [String: Any]? = nil,
        attachmentIds: [String]? = nil
    ) async throws -> String {
        guard sessionManager.isConnected() else {
            throw ChatClientError.notConnected
        }

        let messageId = generateId()
        let userMessage = Message(
            id: messageId,
            role: .user,
            content: text,
            timestamp: Date(),
            metadata: JSONValue.anySendableDictionary(from: metadata),
            attachmentIds: attachmentIds
        )

        let pending = PendingMessage(
            messageId: messageId,
            text: text,
            attachmentIds: attachmentIds,
            metadata: metadata,
            customData: customData.isEmpty ? nil : customData
        )
        try transmit(pending)
        inFlight.append(pending)
        addMessage(userMessage)
        emit(.messageReceived(userMessage))

        return messageId
    }

    func submitAction(
        actionId: String,
        value: String? = nil,
        formData: [String: String]? = nil,
        renderId: String? = nil
    ) throws {
        guard sessionManager.isConnected() else {
            throw ChatClientError.notConnected
        }

        let trimmedId = actionId.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedId.isEmpty else {
            throw ChatClientError.emptyActionId
        }

        try sessionManager.send(.actionSubmit(
            actionId: trimmedId,
            value: value,
            formData: formData,
            renderId: renderId
        ))

        ArtemisLogger.debug("Submitted action", metadata: [
            "actionId": trimmedId,
            "has_form_data": formData != nil,
            "has_render_id": renderId != nil,
        ])
    }

    func submitFeedback(
        messageId: String,
        ratingType: String,
        ratingValue: Int,
        feedbackText: String? = nil,
        actionRenderId: String? = nil,
        timeout: TimeInterval = 10
    ) async throws -> String {
        guard sessionManager.isConnected() else {
            throw ChatClientError.notConnected
        }

        let trimmedMessageId = messageId.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedMessageId.isEmpty else {
            throw ChatClientError.emptyMessageId
        }

        let key = feedbackKey(messageId: trimmedMessageId, actionRenderId: actionRenderId)
        guard pendingFeedback[key] == nil else {
            throw ChatClientError.feedbackAlreadyPending
        }

        return try await withCheckedThrowingContinuation { continuation in
            let timer = DispatchSource.makeTimerSource(queue: .global())
            timer.schedule(deadline: .now() + timeout)
            timer.setEventHandler { [weak self] in
                guard let self else { return }
                if let pending = self.pendingFeedback.removeValue(forKey: key) {
                    pending.timer.cancel()
                    continuation.resume(throwing: ChatClientError.feedbackTimeout(timeout))
                }
            }
            timer.resume()

            pendingFeedback[key] = PendingFeedback(continuation: continuation, timer: timer)

            do {
                try sessionManager.send(.feedbackSubmit(
                    messageId: trimmedMessageId,
                    ratingType: ratingType,
                    ratingValue: ratingValue,
                    feedbackText: feedbackText,
                    actionRenderId: actionRenderId
                ))
            } catch {
                timer.cancel()
                pendingFeedback.removeValue(forKey: key)
                continuation.resume(throwing: error)
            }

            ArtemisLogger.debug("Submitted feedback", metadata: [
                "messageId": trimmedMessageId,
                "ratingType": ratingType,
                "ratingValue": ratingValue,
            ])
        }
    }

    func resendPending() {
        guard !inFlight.isEmpty, sessionManager.isConnected() else { return }

        ArtemisLogger.info("Resending unanswered messages after reconnect", metadata: [
            "count": inFlight.count,
        ])

        for pending in inFlight {
            try? transmit(pending, isResend: true)
        }
    }

    func clearPending() {
        inFlight.removeAll()
    }

    func getMessages() -> [Message] {
        messages
    }

    func hydratePersistedHistory() {
        guard let sessionId = sessionManager.getSessionId(), !sessionId.isEmpty else {
            ArtemisLogger.debug("Persisted history hydration skipped: no active session")
            return
        }

        if historyHydrationTask != nil, historyHydrationSessionId == sessionId {
            ArtemisLogger.debug("Persisted history hydration already in progress", metadata: [
                "session_id": sessionId,
            ])
            return
        }

        ArtemisLogger.info("Hydrating persisted history", metadata: ["session_id": sessionId])

        let generation = historyHydrationGeneration
        historyHydrationSessionId = sessionId

        historyHydrationTask = Task { [weak self] in
            guard let self else { return }

            do {
                let fetched = try await self.fetchPersistedHistory(sessionId: sessionId)
                guard !Task.isCancelled,
                      generation == self.historyHydrationGeneration,
                      sessionId == self.sessionManager.getSessionId() else {
                    ArtemisLogger.debug("Persisted history hydration result discarded", metadata: [
                        "session_id": sessionId,
                    ])
                    return
                }

                ArtemisLogger.info("Persisted history fetched", metadata: [
                    "session_id": sessionId,
                    "fetched": fetched.count,
                ])
                self.mergeHydratedMessages(fetched)
            } catch {
                ArtemisLogger.warning("Persisted history hydration skipped", metadata: [
                    "session_id": sessionId,
                    "error": error.localizedDescription,
                ])
                self.delegate?.chatClient(self, didFailHistoryHydration: error)
            }

            if generation == self.historyHydrationGeneration {
                self.historyHydrationTask = nil
                self.historyHydrationSessionId = nil
            }
        }
    }

    func clearMessages() {
        historyHydrationGeneration += 1
        historyHydrationTask?.cancel()
        historyHydrationTask = nil
        historyHydrationSessionId = nil
        messages.removeAll()
        messageIds.removeAll()
        streamingBuffers.removeAll()
        inFlight.removeAll()
    }

    func handleServerMessage(_ message: TransportServerMessage) {
        switch message.type {
        case "response_start":
            isTyping = true
            if config.chat.enableTypingIndicator {
                emit(.typingIndicator(isTyping: true))
            }
            let startMessageId = message.raw["messageId"] as? String ?? ""
            if !startMessageId.isEmpty {
                streamingBuffers[startMessageId] = ""
                let streamingMessage = Message(
                    id: startMessageId,
                    role: .assistant,
                    content: "",
                    timestamp: Date()
                )
                upsertStreamingMessage(streamingMessage)
                emit(.messageStart(messageId: startMessageId))
            }

        case "response_chunk":
            let chunkMessageId = message.raw["messageId"] as? String ?? ""
            let chunk = readStreamChunk(message)
            guard !chunkMessageId.isEmpty, !chunk.isEmpty else { break }

            let buffer = (streamingBuffers[chunkMessageId] ?? "") + chunk
            streamingBuffers[chunkMessageId] = buffer
            let streamingMessage = Message(
                id: chunkMessageId,
                role: .assistant,
                content: buffer,
                timestamp: Date()
            )
            upsertStreamingMessage(streamingMessage)
            emit(.messageChunk(messageId: chunkMessageId, chunk: chunk))

        case "response_end":
            isTyping = false
            if config.chat.enableTypingIndicator {
                emit(.typingIndicator(isTyping: false))
            }

            let endMessageId = message.raw["messageId"] as? String ?? generateId()
            let envelope = message.raw["contentEnvelope"] as? [String: Any]
            let envelopeText = envelope?["text"] as? String
            let rawRichContent = extractRawRichContent(message.raw)
            let rawActions = extractRawActions(message.raw)

            let content = (message.raw["fullText"] as? String)
                ?? (message.raw["text"] as? String)
                ?? (message.raw["content"] as? String)
                ?? envelopeText
                ?? streamingBuffers.removeValue(forKey: endMessageId)
                ?? ""

            resolveOldestInFlight()

            let hasTextContent = !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            let hasRenderablePayload = hasTextContent || hasRawRichContent(rawRichContent) || hasRawActions(rawActions)

            if !hasRenderablePayload {
                emit(.error(error: ChatClientError.emptyAssistantResponse))
                break
            }

            let metadata = mergeResponseMetadata(
                metadata: message.raw["metadata"] as? [String: Any],
                rawRichContent: rawRichContent,
                rawActions: rawActions
            )

            let assistantMessage = Message(
                id: endMessageId,
                role: .assistant,
                content: content,
                timestamp: Date(),
                metadata: JSONValue.anySendableDictionary(from: metadata)
            )

            streamingBuffers.removeValue(forKey: endMessageId)
            addMessage(assistantMessage)
            emit(.messageEnd(messageId: endMessageId, message: assistantMessage))
            emit(.messageReceived(assistantMessage))

        case "thought":
            guard config.chat.enableThoughts else { break }
            let thoughtContent = (message.raw["thought"] as? String)
                ?? (message.raw["content"] as? String)
                ?? ""
            if !thoughtContent.isEmpty {
                emit(.thought(content: thoughtContent))
            }

        case "error":
            resolveOldestInFlight()
            let errorContent = (message.raw["content"] as? String) ?? "Unknown error"
            emit(.error(error: ChatClientError.serverError(errorContent)))

        case "status_update":
            if config.chat.enableTypingIndicator {
                emit(.typingIndicator(isTyping: true))
            }

        case "status_clear":
            if config.chat.enableTypingIndicator {
                emit(.typingIndicator(isTyping: false))
            }

        case "feedback.ack":
            handleFeedbackAck(message.raw)

        default:
            break
        }
    }

    // MARK: - Private

    private func transmit(_ pending: PendingMessage, isResend: Bool = false) throws {
        try sessionManager.send(.chatMessage(
            text: pending.text,
            messageId: pending.messageId,
            sessionId: sessionManager.getSessionId(),
            attachmentIds: pending.attachmentIds,
            metadata: pending.metadata,
            customData: pending.customData
        ))

        ArtemisLogger.debug(isResend ? "Resent chat message" : "Sent chat message", metadata: [
            "id": pending.messageId,
            "has_custom_data": pending.customData != nil,
        ])
    }

    private func handleFeedbackAck(_ raw: [String: Any]) {
        let messageId = raw["messageId"] as? String ?? ""
        guard !messageId.isEmpty else { return }

        let actionRenderId = raw["actionRenderId"] as? String
        let key = feedbackKey(messageId: messageId, actionRenderId: actionRenderId)
        guard let pending = pendingFeedback.removeValue(forKey: key) else { return }

        pending.timer.cancel()

        let success = raw["success"] as? Bool == true
        let feedbackId = raw["feedbackId"] as? String

        if success, let feedbackId, !feedbackId.isEmpty {
            pending.continuation.resume(returning: feedbackId)
        } else {
            let errorRaw = raw["error"] as? [String: Any]
            let code = errorRaw?["code"] as? String ?? "FEEDBACK_REJECTED"
            let message = errorRaw?["message"] as? String ?? "Feedback rejected"
            pending.continuation.resume(throwing: FeedbackSubmitError(code: code, message: message))
        }
    }

    private func feedbackKey(messageId: String, actionRenderId: String?) -> String {
        "\(messageId)|\(actionRenderId ?? "")"
    }

    private func resolveOldestInFlight() {
        if !inFlight.isEmpty {
            inFlight.removeFirst()
        }
    }

    private func addMessage(_ message: Message) {
        if messageIds.contains(message.id) {
            if let index = messages.firstIndex(where: { $0.id == message.id }) {
                messages[index] = message
            }
            return
        }

        messageIds.insert(message.id)
        messages.append(message)

        let maxMessages = config.chat.maxMessagesLocal
        if messages.count > maxMessages {
            let overflow = messages.count - maxMessages
            for i in 0 ..< overflow {
                messageIds.remove(messages[i].id)
            }
            messages.removeFirst(overflow)
        }
    }

    private func upsertStreamingMessage(_ message: Message) {
        addMessage(message)
        emit(.messageReceived(message))
    }

    private func emit(_ event: ChatEvent) {
        delegate?.chatClient(self, didReceive: event)
    }

    private func fetchPersistedHistory(sessionId: String) async throws -> [Message] {
        let authToken = try await sessionManager.getAuthToken()
        let perPage = config.chat.historyPageSize
        let maxPages = config.chat.maxHistoryPages
        var hydrated: [Message] = []
        var cursor: String?

        for page in 0 ..< maxPages {
            let uri = buildHistoryURI(sessionId: sessionId, cursor: cursor, limit: perPage)
            var request = URLRequest(url: uri)
            request.setValue(authToken, forHTTPHeaderField: "X-SDK-Token")

            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse else {
                throw ChatClientError.historyRequestFailed(status: 0)
            }
            if !(200 ... 299).contains(http.statusCode) {
                throw ChatClientError.historyRequestFailed(status: http.statusCode)
            }

            let body = try JSONSerialization.jsonObject(with: data)
            let parsed = parsePersistedHistoryPage(body)
            hydrated.append(contentsOf: parsed.messages)

            if !parsed.hasMore || parsed.nextCursor == nil {
                break
            }
            cursor = parsed.nextCursor
            _ = page
        }

        return hydrated
    }

    private func buildHistoryURI(sessionId: String, cursor: String?, limit: Int) -> URL {
        let projectId = sessionManager.getProjectId()
        var components = URLComponents(string: sessionManager.getEndpoint())!
        components.path = "/api/projects/\(projectId.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? projectId)/sessions/\(sessionId.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? sessionId)/messages"
        var queryItems = [
            URLQueryItem(name: "direction", value: "asc"),
            URLQueryItem(name: "limit", value: String(limit)),
        ]
        if let cursor, !cursor.isEmpty {
            queryItems.append(URLQueryItem(name: "cursor", value: cursor))
        }
        components.queryItems = queryItems
        return components.url!
    }

    private struct PersistedHistoryPage {
        let messages: [Message]
        let nextCursor: String?
        let hasMore: Bool
    }

    private func parsePersistedHistoryPage(_ body: Any) -> PersistedHistoryPage {
        guard let map = body as? [String: Any], let rawMessages = map["messages"] as? [Any] else {
            return PersistedHistoryPage(messages: [], nextCursor: nil, hasMore: false)
        }

        let messages = rawMessages.compactMap { parsePersistedHistoryMessage($0) }
        return PersistedHistoryPage(
            messages: messages,
            nextCursor: map["nextCursor"] as? String,
            hasMore: map["hasMore"] as? Bool == true
        )
    }

    private func parsePersistedHistoryMessage(_ raw: Any) -> Message? {
        guard let map = raw as? [String: Any],
              let id = map["id"] as? String,
              let role = map["role"] as? String else {
            return nil
        }

        let envelope = map["contentEnvelope"] as? [String: Any]
        let envelopeText = envelope?["text"] as? String
        let rawContent = map["content"] as? String
        let content: String
        if let rawContent, !rawContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            content = rawContent
        } else {
            content = envelopeText ?? ""
        }

        let timestamp: Date
        if let rawTimestamp = map["timestamp"] as? String {
            timestamp = ISO8601DateFormatter().date(from: rawTimestamp) ?? Date()
        } else {
            timestamp = Date()
        }

        return Message(
            id: id,
            role: roleFromString(role),
            content: content,
            timestamp: timestamp,
            metadata: JSONValue.anySendableDictionary(from: mergeRichContentMetadata(
                metadata: map["metadata"] as? [String: Any],
                rawRichContent: extractRawRichContent(map)
            ))
        )
    }

    private func mergeHydratedMessages(_ newMessages: [Message]) {
        guard !newMessages.isEmpty else { return }

        var existingIds = Set(messages.map(\.id))
        var existingFingerprints = Set(messages.map(fingerprint))
        var toAdd: [Message] = []

        for message in newMessages {
            if existingIds.contains(message.id) { continue }
            let fp = fingerprint(message)
            if existingFingerprints.contains(fp) { continue }
            existingIds.insert(message.id)
            existingFingerprints.insert(fp)
            toAdd.append(message)
        }

        guard !toAdd.isEmpty else {
            ArtemisLogger.debug("Persisted history merge: no new messages")
            return
        }

        ArtemisLogger.info("Merging persisted history", metadata: ["new_messages": toAdd.count])
        messages.append(contentsOf: toAdd)
        messages.sort { $0.timestamp < $1.timestamp }

        let maxMessages = config.chat.maxMessagesLocal
        if messages.count > maxMessages {
            messages.removeFirst(messages.count - maxMessages)
        }

        messageIds = Set(messages.map(\.id))
        emit(.historyLoaded(messages: getMessages()))
    }

    private func fingerprint(_ message: Message) -> String {
        "\(message.role)|\(message.content)|\(message.timestamp.timeIntervalSince1970)"
    }

    private func roleFromString(_ role: String) -> MessageRole {
        switch role.lowercased() {
        case "user": return .user
        case "assistant": return .assistant
        case "system": return .system
        case "thought": return .thought
        default: return .assistant
        }
    }

    private func extractRawRichContent(_ raw: [String: Any]) -> [String: Any]? {
        if let direct = raw["richContent"] as? [String: Any] ?? raw["rich_content"] as? [String: Any] {
            return direct
        }
        if let envelope = raw["contentEnvelope"] as? [String: Any] {
            return envelope["richContent"] as? [String: Any] ?? envelope["rich_content"] as? [String: Any]
        }
        return nil
    }

    private func hasRawRichContent(_ raw: [String: Any]?) -> Bool {
        guard let raw else { return false }
        return !raw.isEmpty
    }

    private func extractRawActions(_ raw: [String: Any]) -> [String: Any]? {
        if let direct = raw["actions"] as? [String: Any] {
            return direct
        }
        if let envelope = raw["contentEnvelope"] as? [String: Any] {
            return envelope["actions"] as? [String: Any]
        }
        return nil
    }

    private func hasRawActions(_ raw: [String: Any]?) -> Bool {
        guard let raw, !raw.isEmpty else { return false }
        let elements = raw["elements"] as? [Any]
        return elements?.isEmpty == false
    }

    private func mergeResponseMetadata(
        metadata: [String: Any]?,
        rawRichContent: [String: Any]?,
        rawActions: [String: Any]?
    ) -> [String: Any]? {
        var merged = metadata ?? [:]
        if let rawRichContent, !rawRichContent.isEmpty {
            merged["richContent"] = rawRichContent
        }
        if hasRawActions(rawActions) {
            merged["actions"] = rawActions as Any
        }
        return merged.isEmpty ? nil : merged
    }

    private func mergeRichContentMetadata(
        metadata: [String: Any]?,
        rawRichContent: [String: Any]?
    ) -> [String: Any]? {
        guard let rawRichContent, !rawRichContent.isEmpty else { return metadata }
        var merged = metadata ?? [:]
        merged["richContent"] = rawRichContent
        return merged
    }

    private func readStreamChunk(_ message: TransportServerMessage) -> String {
        if let chunk = message.raw["chunk"] as? String, !chunk.isEmpty { return chunk }
        if let content = message.raw["content"] as? String, !content.isEmpty { return content }
        return ""
    }

    private func generateId() -> String {
        "msg_\(Int(Date().timeIntervalSince1970 * 1_000_000))"
    }
}

private struct PendingMessage {
    let messageId: String
    let text: String
    let attachmentIds: [String]?
    let metadata: [String: Any]?
    let customData: [String: Any]?
}

private struct PendingFeedback {
    let continuation: CheckedContinuation<String, Error>
    let timer: DispatchSourceTimer
}

enum ChatClientError: Error, LocalizedError {
    case notConnected
    case emptyActionId
    case emptyMessageId
    case feedbackAlreadyPending
    case feedbackTimeout(TimeInterval)
    case emptyAssistantResponse
    case serverError(String)
    case historyRequestFailed(status: Int)

    var errorDescription: String? {
        switch self {
        case .notConnected: return "Not connected to the platform"
        case .emptyActionId: return "actionId must not be empty"
        case .emptyMessageId: return "messageId must not be empty"
        case .feedbackAlreadyPending: return "Feedback already pending for this message"
        case .feedbackTimeout(let timeout): return "Feedback ack timed out after \(Int(timeout * 1000))ms"
        case .emptyAssistantResponse: return "Received empty assistant response"
        case .serverError(let message): return message
        case .historyRequestFailed(let status): return "History request failed: \(status)"
        }
    }
}
