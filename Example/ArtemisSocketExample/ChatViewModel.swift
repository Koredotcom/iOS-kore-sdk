import ArtemisSocketSDK
import Combine
import SwiftUI

@MainActor
final class ChatViewModel: ObservableObject, AgentSDKDelegate {
    @Published var messages: [Message] = []
    @Published var inputText = ""
    @Published var connectionState = "Disconnected"
    @Published var sessionId: String?
    @Published var isTyping = false
    @Published var statusMessage: String?
    @Published var isConnecting = false

    private var sdk: AgentSDK?
    private var cancellables = Set<AnyCancellable>()

    func initializeSDK() {
        guard sdk == nil else { return }

        do {
            let agentSDK = try AgentSDK.initialize(fromBundle: .main)
            agentSDK.delegate = self
            sdk = agentSDK
            bindPublishers(agentSDK)
        } catch {
            statusMessage = "Init failed: \(error.localizedDescription)"
        }
    }

    func connect() {
        if sdk == nil {
            initializeSDK()
        }
        guard let sdk else { return }

        isConnecting = true
        statusMessage = "Connecting..."

        Task {
            do {
                let id = try await sdk.connect()
                sessionId = id
                connectionState = "Connected"
                statusMessage = nil
            } catch {
                connectionState = "Error"
                statusMessage = "Connection failed: \(error.localizedDescription)"
            }
            isConnecting = false
        }
    }

    func disconnect() {
        sdk?.disconnect()
        connectionState = "Disconnected"
        sessionId = nil
        statusMessage = "Disconnected"
    }

    func endSession() {
        sdk?.endSession()
        connectionState = "Disconnected"
        sessionId = nil
        messages.removeAll()
        statusMessage = "Session ended"
    }

    func sendMessage() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, let sdk else { return }

        inputText = ""

        Task {
            do {
                _ = try await sdk.sendMessage(text)
            } catch {
                statusMessage = "Send failed: \(error.localizedDescription)"
            }
        }
    }

    func clearHistory() {
        sdk?.clearHistory()
        messages.removeAll()
        statusMessage = "History cleared"
    }

    func updateCustomData() {
        sdk?.updateCustomData([
            "platform": "ios",
            "app_version": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0",
        ])
        statusMessage = "Custom data updated"
    }

    // MARK: - AgentSDKDelegate

    func agentSDK(_ sdk: AgentSDK, didReceive event: SDKEvent) {
        switch event {
        case .connected(let id):
            sessionId = id
            connectionState = "Connected"
            statusMessage = nil

        case .disconnected(let reason):
            connectionState = "Disconnected"
            sessionId = nil
            statusMessage = reason.map { "Disconnected: \($0)" } ?? "Disconnected"

        case .reconnecting(let attempt, let max):
            connectionState = "Reconnecting"
            statusMessage = "Reconnecting (\(attempt)/\(max))..."

        case .error(let error, let code):
            statusMessage = "[\(code.rawValue)] \(error.localizedDescription)"

        case .idleTimeout(let timeout):
            statusMessage = "Idle timeout after \(Int(timeout))s"
        }
    }

    func agentSDK(_ sdk: AgentSDK, didReceive chatEvent: ChatEvent) {
        switch chatEvent {
        case .messageReceived(let message):
            upsertMessage(message)

        case .historyLoaded(let loaded):
            messages = loaded

        case .messageStart:
            isTyping = true

        case .messageChunk(_, let chunk):
            statusMessage = "Streaming… (\(chunk.count) chars)"

        case .messageEnd(_, let message):
            isTyping = false
            upsertMessage(message)

        case .typingIndicator(let typing):
            isTyping = typing

        case .thought(let content):
            statusMessage = "Thought: \(content.prefix(80))"

        case .error(let error):
            isTyping = false
            statusMessage = "Chat error: \(error.localizedDescription)"
        }
    }

    // MARK: - Private

    private func bindPublishers(_ sdk: AgentSDK) {
        sdk.chatEvents
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                guard let self else { return }
                if case .messageReceived(let message) = event {
                    self.upsertMessage(message)
                }
            }
            .store(in: &cancellables)
    }

    private func upsertMessage(_ message: Message) {
        if let index = messages.firstIndex(where: { $0.id == message.id }) {
            messages[index] = message
        } else {
            messages.append(message)
        }
        messages.sort { $0.timestamp < $1.timestamp }
    }
}
