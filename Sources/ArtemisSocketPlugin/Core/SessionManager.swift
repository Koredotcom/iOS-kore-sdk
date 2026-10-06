import Foundation

private let sessionReadyTimeoutMs = 10_000.0
private let endSessionCloseFallbackMs = 5_000.0

protocol SessionManagerDelegate: AnyObject {
    func sessionManagerDidConnect(_ manager: SessionManager)
    func sessionManagerDidDisconnect(_ manager: SessionManager, reason: String?)
    func sessionManager(_ manager: SessionManager, didReceive message: TransportServerMessage)
    func sessionManager(_ manager: SessionManager, didChangeState state: ConnectionState)
    func sessionManager(_ manager: SessionManager, didEncounterError error: Error)
    func sessionManagerDidStartReconnecting(_ manager: SessionManager, attempt: Int, maxAttempts: Int)
}

/// WebSocket connection and session handling.
final class SessionManager: NSObject {
    private let config: SDKConfiguration
    private let tokenManager: TokenManager
    private let httpEndpoint: String
    private let wsEndpoint: String
    private let urlSession: URLSession

    private var webSocketTask: URLSessionWebSocketTask?
    private var sessionId: String?
    private var resolvedProjectId: String?
    private var resolvedChannelId: String?
    private var isSessionReady = false
    private var reconnectAttempts = 0
    private var reconnectWorkItem: DispatchWorkItem?
    private var connectContinuation: CheckedContinuation<Void, Error>?
    private var pendingConnectTimeout: DispatchWorkItem?
    private var endSessionCloseTimeout: DispatchWorkItem?
    private var shouldReconnect = true
    private var disposed = false
    private var connectTask: Task<Void, Error>?

    private let queue = DispatchQueue(label: "com.artemis.session-manager")

    weak var delegate: SessionManagerDelegate?

    init(config: SDKConfiguration, tokenManager: TokenManager, urlSession: URLSession = .shared) {
        self.config = config
        self.tokenManager = tokenManager
        self.httpEndpoint = EndpointNormalizer.normalizeHttpEndpoint(config.connection.endpoint)
        self.wsEndpoint = EndpointNormalizer.normalizeWebSocketEndpoint(config.connection.endpoint)
        self.urlSession = urlSession
        super.init()
    }

    func connect() async throws {
        if isConnected() { return }

        if let connectTask {
            return try await connectTask.value
        }

        shouldReconnect = true
        let task = Task<Void, Error> {
            defer { self.connectTask = nil }
            try await self.openConnection()
        }
        connectTask = task
        return try await task.value
    }

    func disconnect() {
        queue.async {
            self.shouldReconnect = false
            self.clearEndSessionCloseTimeout()
            self.rejectPendingConnect(SessionManagerError.clientDisconnected)
            self.reconnectWorkItem?.cancel()
            self.reconnectWorkItem = nil
            self.closeChannel(code: .normalClosure, reason: "Client disconnect")
            self.resetSessionState()
            self.setConnectionState(.disconnected)
        }
    }

    func endSession() {
        queue.async {
            self.shouldReconnect = false
            guard self.isConnected(), self.webSocketTask != nil else {
                self.disconnect()
                return
            }

            do {
                try self.send(.endSession(sessionId: self.sessionId))
                self.armEndSessionCloseFallback()
            } catch {
                ArtemisLogger.error("Failed to send end_session frame; disconnecting", error)
                self.disconnect()
            }
        }
    }

    func send(_ message: TransportClientMessage) throws {
        guard isConnected(), let task = webSocketTask else {
            throw SessionManagerError.notConnected
        }

        let payload = try message.toJSON()
        if config.debug.logWebsocketMessages {
            ArtemisLogger.debug("WebSocket send", metadata: ["payload": payload])
        }

        task.send(.string(payload)) { error in
            if let error {
                ArtemisLogger.error("WebSocket send failed", error)
            }
        }
    }

    func isConnected() -> Bool {
        webSocketTask != nil && isSessionReady
    }

    func getSessionId() -> String? { sessionId }
    func getProjectId() -> String { resolvedProjectId ?? config.connection.projectId }
    func getChannelId() -> String? { resolvedChannelId }
    func getScope() -> SDKSessionScope? { tokenManager.getScope() }
    func getWidgetConfig() -> WidgetConfig? { tokenManager.getWidgetConfig() }
    func getEndpoint() -> String { httpEndpoint }

    func getAuthToken() async throws -> String {
        try await tokenManager.getToken()
    }

    func dispose() {
        disposed = true
        disconnect()
    }

    // MARK: - Connection

    private func openConnection() async throws {
        let authToken = try await tokenManager.getToken()
        let protocols = try await resolveWebSocketProtocols(authToken: authToken)
        let wsURL = URL(string: "\(wsEndpoint)/ws/sdk")!

        setConnectionState(.connecting)
        resetSessionState()

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            queue.async {
                self.connectContinuation = continuation
                self.armPendingConnect()

                ArtemisLogger.info("Connecting WebSocket", metadata: ["url": wsURL.absoluteString])

                var request = URLRequest(url: wsURL)
                request.setValue(
                    WebSocketAuth.protocolHeaderValue(protocols),
                    forHTTPHeaderField: "Sec-WebSocket-Protocol"
                )

                let task = self.urlSession.webSocketTask(with: request)
                self.webSocketTask = task
                task.resume()
                self.receiveNextMessage(from: task)
            }
        }
    }

    private func resolveWebSocketProtocols(authToken: String) async throws -> [String] {
        let url = URL(string: "\(httpEndpoint)/api/v1/sdk/ws-ticket")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(authToken, forHTTPHeaderField: "X-SDK-Token")
        request.httpBody = "{}".data(using: .utf8)

        do {
            let (data, response) = try await urlSession.data(for: request)
            guard let http = response as? HTTPURLResponse else {
                throw SessionManagerError.invalidTicketResponse
            }

            if !(200 ... 299).contains(http.statusCode) {
                if shouldUseLegacyWebSocketAuth(status: http.statusCode) {
                    ArtemisLogger.warning(
                        "WebSocket ticket endpoint unavailable; using deprecated session-token auth"
                    )
                    return WebSocketAuth.buildTokenProtocols(authToken)
                }
                throw SessionManagerError.ticketRequestFailed(status: http.statusCode)
            }

            guard let payload = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                throw SessionManagerError.invalidTicketResponse
            }

            let ticket = (payload["ticket"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            if ticket.isEmpty {
                throw SessionManagerError.missingTicket
            }

            return WebSocketAuth.buildTicketProtocols(ticket)
        } catch let staged as SdkStageError {
            throw staged
        } catch {
            throw SdkStageError(code: .wsTicket, cause: error)
        }
    }

    private func shouldUseLegacyWebSocketAuth(status: Int) -> Bool {
        status == 404 || status == 405 || status == 501
    }

    private func receiveNextMessage(from task: URLSessionWebSocketTask) {
        task.receive { [weak self] result in
            guard let self else { return }

            switch result {
            case .success(let message):
                self.queue.async {
                    self.handleSocketMessage(message)
                    if self.webSocketTask === task {
                        self.receiveNextMessage(from: task)
                    }
                }

            case .failure(let error):
                self.queue.async {
                    ArtemisLogger.error("WebSocket error", error)
                    let staged = SdkStageError(code: .socketConnection, cause: error)
                    self.delegate?.sessionManager(self, didEncounterError: staged)
                    self.rejectPendingConnect(staged)
                    self.setConnectionState(.error)
                    self.handleSocketClosed(closeCode: nil, closeReason: error.localizedDescription)
                }
            }
        }
    }

    private func handleSocketMessage(_ message: URLSessionWebSocketTask.Message) {
        let text: String
        switch message {
        case .string(let value):
            text = value
        case .data(let data):
            text = String(data: data, encoding: .utf8) ?? ""
        @unknown default:
            return
        }

        guard let data = text.data(using: .utf8) else { return }

        do {
            let transportMessage = try TransportServerMessage.fromJSONData(data)
            if config.debug.logWebsocketMessages {
                ArtemisLogger.debug("WebSocket receive", metadata: transportMessage.raw)
            }
            handleTransportMessage(transportMessage)
        } catch {
            ArtemisLogger.error("Failed to parse WebSocket message", error)
        }
    }

    private func handleTransportMessage(_ message: TransportServerMessage) {
        if message.type == "session_start" {
            let tokenScope = tokenManager.getScope()
            sessionId = message.raw["sessionId"] as? String
            resolvedProjectId = message.raw["projectId"] as? String ?? tokenScope?.projectId
            resolvedChannelId = message.raw["channelId"] as? String ?? tokenScope?.channelId

            if !isSessionReady {
                isSessionReady = true
                reconnectAttempts = 0
                resolvePendingConnect()
                setConnectionState(.connected)
                ArtemisLogger.info("Connected", metadata: ["session_id": sessionId ?? ""])
                delegate?.sessionManagerDidConnect(self)
            }

            ArtemisLogger.info("Session started", metadata: ["session_id": sessionId ?? ""])
        }

        delegate?.sessionManager(self, didReceive: message)
    }

    private func handleSocketClosed(closeCode: Int?, closeReason: String?) {
        clearEndSessionCloseTimeout()
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil

        if shouldInvalidateTokenForClose(code: closeCode) {
            tokenManager.invalidateToken()
        }

        resetSessionState()
        rejectPendingConnect(SessionManagerError.socketClosedBeforeSessionStart)
        delegate?.sessionManagerDidDisconnect(self, reason: closeReason)
        setConnectionState(.disconnected)

        ArtemisLogger.info("Disconnected", metadata: [
            "code": closeCode as Any,
            "reason": closeReason as Any,
        ])

        if shouldReconnect && !disposed {
            attemptReconnect()
        }
    }

    private func attemptReconnect() {
        let reconnection = config.websocket.reconnection
        guard reconnection.enabled else { return }
        guard reconnectAttempts < reconnection.maxAttempts else {
            ArtemisLogger.warning("Max reconnect attempts reached")
            return
        }

        let delayMs = getReconnectDelayMs(attempt: reconnectAttempts, config: reconnection)
        reconnectAttempts += 1
        setConnectionState(.reconnecting)
        delegate?.sessionManagerDidStartReconnecting(
            self,
            attempt: reconnectAttempts,
            maxAttempts: reconnection.maxAttempts
        )

        ArtemisLogger.info("Reconnecting", metadata: [
            "delay_ms": delayMs,
            "attempt": reconnectAttempts,
            "max_attempts": reconnection.maxAttempts,
        ])

        reconnectWorkItem?.cancel()
        let workItem = DispatchWorkItem { [weak self] in
            guard let self else { return }
            Task {
                do {
                    try await self.connect()
                } catch {
                    ArtemisLogger.error("Reconnect failed", error)
                    self.delegate?.sessionManager(self, didEncounterError: error)
                }
            }
        }
        reconnectWorkItem = workItem
        queue.asyncAfter(deadline: .now() + .milliseconds(delayMs), execute: workItem)
    }

    private func getReconnectDelayMs(attempt: Int, config: ReconnectionConfig) -> Int {
        if !config.exponentialBackoff {
            return config.baseDelayMs
        }
        let delay = config.baseDelayMs * Int(pow(2.0, Double(attempt)))
        return min(delay, config.maxDelayMs)
    }

    private func armPendingConnect() {
        clearPendingConnectTimeout()
        let workItem = DispatchWorkItem { [weak self] in
            guard let self else { return }
            let timeoutError = SdkStageError(
                code: .sessionStartTimeout,
                cause: SessionManagerError.sessionStartTimeout
            )
            self.rejectPendingConnect(timeoutError)
            self.closeChannel(code: .goingAway, reason: "Session start timeout")
        }
        pendingConnectTimeout = workItem
        queue.asyncAfter(deadline: .now() + .milliseconds(Int(sessionReadyTimeoutMs)), execute: workItem)
    }

    private func resolvePendingConnect() {
        clearPendingConnectTimeout()
        connectContinuation?.resume()
        connectContinuation = nil
    }

    private func rejectPendingConnect(_ error: Error) {
        clearPendingConnectTimeout()
        connectContinuation?.resume(throwing: error)
        connectContinuation = nil
    }

    private func clearPendingConnectTimeout() {
        pendingConnectTimeout?.cancel()
        pendingConnectTimeout = nil
    }

    private func armEndSessionCloseFallback() {
        clearEndSessionCloseTimeout()
        let workItem = DispatchWorkItem { [weak self] in
            self?.closeChannel(code: .normalClosure, reason: "Session ended by client")
        }
        endSessionCloseTimeout = workItem
        queue.asyncAfter(deadline: .now() + .milliseconds(Int(endSessionCloseFallbackMs)), execute: workItem)
    }

    private func clearEndSessionCloseTimeout() {
        endSessionCloseTimeout?.cancel()
        endSessionCloseTimeout = nil
    }

    private func closeChannel(code: URLSessionWebSocketTask.CloseCode, reason: String) {
        guard let task = webSocketTask else { return }
        task.cancel(with: code, reason: reason.data(using: .utf8))
        webSocketTask = nil
        handleSocketClosed(closeCode: nil, closeReason: reason)
    }

    private func resetSessionState() {
        sessionId = nil
        resolvedProjectId = nil
        resolvedChannelId = nil
        isSessionReady = false
    }

    private func shouldInvalidateTokenForClose(code: Int?) -> Bool {
        code == 4001 || code == 4003 || code == 4010
    }

    private func setConnectionState(_ state: ConnectionState) {
        delegate?.sessionManager(self, didChangeState: state)
    }
}

enum SessionManagerError: Error, LocalizedError {
    case notConnected
    case clientDisconnected
    case socketClosedBeforeSessionStart
    case sessionStartTimeout
    case invalidTicketResponse
    case missingTicket
    case ticketRequestFailed(status: Int)

    var errorDescription: String? {
        switch self {
        case .notConnected: return "Not connected"
        case .clientDisconnected: return "Client disconnected before session_start"
        case .socketClosedBeforeSessionStart: return "WebSocket closed before session_start"
        case .sessionStartTimeout: return "Timed out waiting for session_start"
        case .invalidTicketResponse: return "WebSocket ticket response was invalid"
        case .missingTicket: return "WebSocket ticket response was missing ticket"
        case .ticketRequestFailed(let status): return "WebSocket ticket request failed with status \(status)"
        }
    }
}
