import Foundation

/// Identifies the exact stage/operation where an SDK error occurred.
public enum SDKErrorCode: String, Sendable {
    case tokenInit
    case tokenRefresh
    case wsTicket
    case socketConnection
    case sessionStartTimeout
    case sendFailed
    case historyFetch
    case unknown
}

public enum ConnectionState: String, Sendable {
    case disconnected
    case connecting
    case connected
    case reconnecting
    case error
}

/// SDK-level events emitted by [AgentSDK].
public enum SDKEvent: Sendable {
    case connected(sessionId: String)
    case disconnected(reason: String?)
    case reconnecting(attempt: Int, maxAttempts: Int)
    case error(error: Error, code: SDKErrorCode)
    case idleTimeout(timeout: TimeInterval)
}

/// Chat-specific events emitted by [AgentSDK].
public enum ChatEvent: Sendable {
    case messageReceived(Message)
    case historyLoaded(messages: [Message])
    case messageStart(messageId: String)
    case messageChunk(messageId: String, chunk: String)
    case messageEnd(messageId: String, message: Message)
    case typingIndicator(isTyping: Bool)
    case thought(content: String)
    case error(error: Error)
}

/// Delegate for receiving SDK and chat events.
@MainActor
public protocol AgentSDKDelegate: AnyObject {
    func agentSDK(_ sdk: AgentSDK, didReceive event: SDKEvent)
    func agentSDK(_ sdk: AgentSDK, didReceive chatEvent: ChatEvent)
}

public extension AgentSDKDelegate {
    func agentSDK(_ sdk: AgentSDK, didReceive event: SDKEvent) {}
    func agentSDK(_ sdk: AgentSDK, didReceive chatEvent: ChatEvent) {}
}
