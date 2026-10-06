import Combine
import Foundation

/// Main Artemis iOS SDK entry point.
///
/// The SDK loads configuration from a YAML/JSON file in the app bundle or from
/// a programmatic `SDKConfiguration`. All behavior is controlled by configuration.
///
/// ```swift
/// let sdk = try AgentSDK.initialize(fromBundle: .main)
/// try await sdk.connect()
/// ```
@MainActor
public final class AgentSDK {
    private var config: SDKConfiguration
    private let tokenManager: TokenManager
    private let sessionManager: SessionManager
    private let chatClient: ChatClient

    private let sdkEventSubject = PassthroughSubject<SDKEvent, Never>()
    private let chatEventSubject = PassthroughSubject<ChatEvent, Never>()

    /// Delegate for receiving SDK and chat events on the main actor.
    public weak var delegate: AgentSDKDelegate?

    /// Combine publisher for SDK-level events.
    public var sdkEvents: AnyPublisher<SDKEvent, Never> {
        sdkEventSubject.eraseToAnyPublisher()
    }

    /// Combine publisher for chat events.
    public var chatEvents: AnyPublisher<ChatEvent, Never> {
        chatEventSubject.eraseToAnyPublisher()
    }

    /// Loaded configuration (read-only).
    public var configuration: SDKConfiguration { config }

    private init(config: SDKConfiguration) {
        self.config = config
        self.tokenManager = TokenManager(config: config)
        self.sessionManager = SessionManager(config: config, tokenManager: tokenManager)
        self.chatClient = ChatClient(sessionManager: sessionManager, config: config)

        ArtemisLogger.configure(
            enabled: config.debug.enabled,
            logLevel: config.debug.logLevel,
            printToConsole: config.debug.printLogs
        )

        sessionManager.delegate = self
        chatClient.delegate = self
    }

    // MARK: - Factory Methods

    /// Initialize SDK by loading configuration from the app bundle.
    public static func initialize(
        fromBundle bundle: Bundle = .main,
        resourceName: String = "sdk_configurations",
        resourceExtension: String = "yaml",
        environment: String? = nil,
        runtimeUserContext: SDKUserContext? = nil
    ) throws -> AgentSDK {
        let config = try SDKConfigurationLoader.load(
            fromBundle: bundle,
            resourceName: resourceName,
            resourceExtension: resourceExtension,
            environment: environment,
            runtimeUserContext: runtimeUserContext
        )
        let sdk = AgentSDK(config: config)
        ArtemisLogger.info("AgentSDK initialized successfully", metadata: [
            "environment": config.environment,
            "endpoint": config.connection.endpoint,
            "project_id": config.connection.projectId,
        ])
        return sdk
    }

    /// Initialize SDK from a configuration file URL.
    public static func initialize(
        from url: URL,
        environment: String? = nil,
        environmentOverrideURL: URL? = nil,
        runtimeUserContext: SDKUserContext? = nil
    ) throws -> AgentSDK {
        var config = try SDKConfigurationLoader.load(
            from: url,
            environment: environment,
            environmentOverrideURL: environmentOverrideURL
        )
        if let runtimeUserContext {
            config = config.copyWithUserContext(runtimeUserContext)
        }
        return AgentSDK(config: config)
    }

    /// Initialize SDK from a YAML string.
    public static func initialize(
        yaml: String,
        environment: String? = nil,
        runtimeUserContext: SDKUserContext? = nil
    ) throws -> AgentSDK {
        let config = try SDKConfigurationLoader.load(
            yaml: yaml,
            environment: environment,
            runtimeUserContext: runtimeUserContext
        )
        return AgentSDK(config: config)
    }

    /// Create SDK with explicit configuration (for testing).
    public static func create(with config: SDKConfiguration) -> AgentSDK {
        AgentSDK(config: config)
    }

    // MARK: - Connection

    /// Connect to the Artemis platform. Returns the session ID.
    @discardableResult
    public func connect() async throws -> String {
        do {
            ArtemisLogger.info("Connecting to Artemis...", metadata: [
                "endpoint": config.connection.endpoint,
            ])

            try await sessionManager.connect()

            guard let sessionId = sessionManager.getSessionId(), !sessionId.isEmpty else {
                throw AgentSDKError.missingSessionId
            }

            ArtemisLogger.info("Connected successfully", metadata: ["session_id": sessionId])
            return sessionId
        } catch {
            ArtemisLogger.error("Connection failed", error)
            emitSDK(.error(error: unwrapStageError(error), code: errorCode(for: error)))
            throw error
        }
    }

    /// Disconnect from the platform.
    public func disconnect() {
        ArtemisLogger.info("Disconnecting from platform")
        chatClient.clearPending()
        sessionManager.disconnect()
    }

    /// End the current server session and disconnect.
    public func endSession() {
        chatClient.clearCustomData()
        chatClient.clearPending()
        sessionManager.endSession()
    }

    /// Whether the SDK has an active session.
    public func isConnected() -> Bool {
        sessionManager.isConnected()
    }

    /// Current session ID, if connected.
    public func getSessionId() -> String? {
        sessionManager.getSessionId()
    }

    /// Server-provided widget configuration from init/refresh response.
    public func getWidgetConfig() -> WidgetConfig? {
        sessionManager.getWidgetConfig()
    }

    // MARK: - Messaging

    /// Send a chat message. Returns the local message ID.
    @discardableResult
    public func sendMessage(
        _ text: String,
        metadata: [String: Any]? = nil,
        attachmentIds: [String]? = nil
    ) async throws -> String {
        guard isConnected() else {
            let error = AgentSDKError.notConnected
            emitSDK(.error(error: error, code: .sendFailed))
            throw error
        }

        do {
            return try await chatClient.send(
                text: text,
                metadata: metadata,
                attachmentIds: attachmentIds
            )
        } catch {
            emitSDK(.error(error: error, code: .sendFailed))
            throw error
        }
    }

    /// Submit an interactive action (button click, select change, form submit).
    public func submitAction(
        _ actionId: String,
        value: String? = nil,
        formData: [String: String]? = nil,
        renderId: String? = nil
    ) throws {
        guard isConnected() else {
            let error = AgentSDKError.notConnected
            emitSDK(.error(error: error, code: .sendFailed))
            throw error
        }

        do {
            try chatClient.submitAction(
                actionId: actionId,
                value: value,
                formData: formData,
                renderId: renderId
            )
        } catch {
            emitSDK(.error(error: error, code: .sendFailed))
            throw error
        }
    }

    /// Submit feedback on a persisted assistant message.
    @discardableResult
    public func submitFeedback(
        messageId: String,
        ratingType: String,
        ratingValue: Int,
        feedbackText: String? = nil,
        actionRenderId: String? = nil,
        timeout: TimeInterval = 10
    ) async throws -> String {
        guard isConnected() else {
            let error = AgentSDKError.notConnected
            emitSDK(.error(error: error, code: .sendFailed))
            throw error
        }

        do {
            return try await chatClient.submitFeedback(
                messageId: messageId,
                ratingType: ratingType,
                ratingValue: ratingValue,
                feedbackText: feedbackText,
                actionRenderId: actionRenderId,
                timeout: timeout
            )
        } catch {
            emitSDK(.error(error: error, code: .sendFailed))
            throw error
        }
    }

    /// All messages in the local store.
    public func getMessages() -> [Message] {
        chatClient.getMessages()
    }

    /// Merge session-scoped custom data into all subsequent outgoing messages.
    public func updateCustomData(_ customData: [String: Any]) {
        chatClient.updateCustomData(customData)
    }

    /// Current session-scoped custom data.
    public var customData: [String: AnySendable] {
        chatClient.customDataSnapshot
    }

    /// Clear all session-scoped custom data.
    public func clearCustomData() {
        chatClient.clearCustomData()
    }

    /// Clear local message history.
    public func clearHistory() {
        chatClient.clearMessages()
        ArtemisLogger.debug("Message history cleared")
    }

    /// Dispose and clean up resources.
    public func dispose() {
        disconnect()
        sessionManager.dispose()
        sdkEventSubject.send(completion: .finished)
        chatEventSubject.send(completion: .finished)
        ArtemisLogger.info("AgentSDK disposed")
    }

    // MARK: - Event Helpers

    private func emitSDK(_ event: SDKEvent) {
        sdkEventSubject.send(event)
        delegate?.agentSDK(self, didReceive: event)
    }

    private func emitChat(_ event: ChatEvent) {
        chatEventSubject.send(event)
        delegate?.agentSDK(self, didReceive: event)
    }

    private func unwrapStageError(_ error: Error) -> Error {
        if let staged = error as? SdkStageError {
            return staged.cause
        }
        return error
    }

    private func errorCode(for error: Error) -> SDKErrorCode {
        if let staged = error as? SdkStageError {
            return staged.code
        }
        return .unknown
    }
}

// MARK: - SessionManagerDelegate

extension AgentSDK: SessionManagerDelegate {
    nonisolated func sessionManagerDidConnect(_ manager: SessionManager) {
        Task { @MainActor in
            if let sessionId = manager.getSessionId() {
                self.emitSDK(.connected(sessionId: sessionId))
            }
            self.chatClient.resendPending()
            self.chatClient.hydratePersistedHistory()
        }
    }

    nonisolated func sessionManagerDidDisconnect(_ manager: SessionManager, reason: String?) {
        Task { @MainActor in
            self.emitSDK(.disconnected(reason: reason))
        }
    }

    nonisolated func sessionManager(_ manager: SessionManager, didReceive message: TransportServerMessage) {
        Task { @MainActor in
            self.chatClient.handleServerMessage(message)
        }
    }

    nonisolated func sessionManager(_ manager: SessionManager, didChangeState state: ConnectionState) {
        Task { @MainActor in
            if state == .reconnecting {
                let maxAttempts = self.config.websocket.reconnection.maxAttempts
                self.emitSDK(.reconnecting(attempt: 1, maxAttempts: maxAttempts))
            }
        }
    }

    nonisolated func sessionManager(_ manager: SessionManager, didEncounterError error: Error) {
        Task { @MainActor in
            self.emitSDK(.error(error: self.unwrapStageError(error), code: self.errorCode(for: error)))
        }
    }

    nonisolated func sessionManagerDidStartReconnecting(
        _ manager: SessionManager,
        attempt: Int,
        maxAttempts: Int
    ) {
        Task { @MainActor in
            self.emitSDK(.reconnecting(attempt: attempt, maxAttempts: maxAttempts))
        }
    }
}

// MARK: - ChatClientDelegate

extension AgentSDK: ChatClientDelegate {
    nonisolated func chatClient(_ client: ChatClient, didReceive event: ChatEvent) {
        Task { @MainActor in
            self.emitChat(event)
        }
    }

    nonisolated func chatClient(_ client: ChatClient, didFailHistoryHydration error: Error) {
        Task { @MainActor in
            self.emitSDK(.error(error: error, code: .historyFetch))
        }
    }
}

public enum AgentSDKError: Error, LocalizedError {
    case notInitialized
    case notConnected
    case missingSessionId

    public var errorDescription: String? {
        switch self {
        case .notInitialized: return "SDK not initialized. Call AgentSDK.initialize() first."
        case .notConnected: return "SDK not connected. Call connect() first."
        case .missingSessionId: return "Connected but session ID was not returned"
        }
    }
}

// MARK: - Session-scoped attachments

public extension AgentSDK {
    /// Upload using the same multipart contract as the web SDK. Send the returned ID with sendMessage.
    func uploadAttachment(fileURL: URL, contentType: String = "application/octet-stream") async throws -> String {
        guard isConnected(), let sessionId = getSessionId(), !sessionId.isEmpty else { throw AgentSDKError.notConnected }
        let token = try await sessionManager.getAuthToken()
        guard isConnected(), getSessionId() == sessionId else { throw AgentSDKError.notConnected }
        let endpoint = sessionManager.getEndpoint()
        let projectId = sessionManager.getProjectId()
        return try await AttachmentHTTP.upload(fileURL: fileURL, contentType: contentType, endpoint: endpoint,
                                               projectId: projectId, sessionId: sessionId, token: token)
    }

    /// Resolve a fresh URL on each open; signed download URLs are never persisted or sent in chat frames.
    func resolveAttachmentDownloadURL(attachmentId: String) async throws -> URL {
        guard isConnected(), let sessionId = getSessionId(), !sessionId.isEmpty else { throw AgentSDKError.notConnected }
        let token = try await sessionManager.getAuthToken()
        guard isConnected(), getSessionId() == sessionId else { throw AgentSDKError.notConnected }
        var request = URLRequest(url: try AttachmentHTTP.url(endpoint: sessionManager.getEndpoint(),
            projectId: sessionManager.getProjectId(), sessionId: sessionId, attachmentId: attachmentId))
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.setValue(token, forHTTPHeaderField: "X-SDK-Token")
        let (data, response) = try await URLSession.shared.data(for: request)
        let json = try AttachmentHTTP.response(data, response)
        let value = json["url"] as? String ?? (json["data"] as? [String: Any])?["url"] as? String
        guard let value, let url = URL(string: value), ["http", "https"].contains(url.scheme?.lowercased()), url.host != nil else {
            throw AttachmentError("Attachment response did not include a valid download URL")
        }
        return url
    }
}

public struct AttachmentError: Error, LocalizedError {
    public let message: String
    public init(_ message: String) { self.message = message }
    public var errorDescription: String? { message }
}

/// File-backed multipart encoding avoids loading large attachments into memory.
enum AttachmentHTTP {
    static func url(endpoint: String, projectId: String, sessionId: String, attachmentId: String? = nil) throws -> URL {
        let allowed = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-._~"))
        func encode(_ value: String) -> String { value.addingPercentEncoding(withAllowedCharacters: allowed) ?? "" }
        var path = endpoint.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        path += "/api/projects/\(encode(projectId))/sessions/\(encode(sessionId))/attachments"
        if let attachmentId { path += "/\(encode(attachmentId))/url?disposition=attachment" }
        guard let url = URL(string: path), ["http", "https"].contains(url.scheme?.lowercased()), url.host != nil else {
            throw AttachmentError("Invalid attachment endpoint")
        }
        return url
    }

    static func multipartFile(source: URL, contentType: String, boundary: String) throws -> URL {
        guard source.isFileURL else { throw AttachmentError("Select a local file to upload") }
        let destination = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        guard FileManager.default.createFile(atPath: destination.path, contents: nil) else { throw AttachmentError("Could not prepare attachment") }
        do {
            let input = try FileHandle(forReadingFrom: source)
            defer { try? input.close() }
            let output = try FileHandle(forWritingTo: destination)
            defer { try? output.close() }
            let filename = source.lastPathComponent.replacingOccurrences(of: "\r", with: "_")
                .replacingOccurrences(of: "\n", with: "_").replacingOccurrences(of: "\"", with: "_")
                .replacingOccurrences(of: "\\", with: "_")
            let mime = contentType.contains("\r") || contentType.contains("\n") || contentType.isEmpty ? "application/octet-stream" : contentType
            let header = "--\(boundary)\r\nContent-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\nContent-Type: \(mime)\r\n\r\n"
            try output.write(contentsOf: Data(header.utf8))
            while let chunk = try input.read(upToCount: 64 * 1024), !chunk.isEmpty {
                try Task.checkCancellation()
                try output.write(contentsOf: chunk)
            }
            try output.write(contentsOf: Data("\r\n--\(boundary)--\r\n".utf8))
            return destination
        } catch {
            try? FileManager.default.removeItem(at: destination)
            throw error
        }
    }

    static func response(_ data: Data, _ response: URLResponse) throws -> [String: Any] {
        guard let http = response as? HTTPURLResponse else { throw AttachmentError("Invalid attachment response") }
        guard (200..<300).contains(http.statusCode) else {
            let detail = String(data: data.prefix(512), encoding: .utf8) ?? "Request failed"
            throw AttachmentError("Attachment request failed (\(http.statusCode)): \(detail)")
        }
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else { throw AttachmentError("Invalid attachment response") }
        return json
    }

    static func upload(fileURL: URL, contentType: String, endpoint: String, projectId: String, sessionId: String,
                       token: String, urlSession: URLSession = .shared) async throws -> String {
        let boundary = "Artemis-\(UUID().uuidString)"
        let body = try multipartFile(source: fileURL, contentType: contentType, boundary: boundary)
        defer { try? FileManager.default.removeItem(at: body) }
        try Task.checkCancellation()
        var request = URLRequest(url: try url(endpoint: endpoint, projectId: projectId, sessionId: sessionId))
        request.httpMethod = "POST"
        request.setValue(token, forHTTPHeaderField: "X-SDK-Token")
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        let (data, response) = try await urlSession.upload(for: request, fromFile: body)
        let json = try self.response(data, response)
        guard let id = json["attachmentId"] as? String, !id.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw AttachmentError("Upload response did not include an attachment ID")
        }
        return id
    }
}
