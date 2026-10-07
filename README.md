# Artemis Socket SDK (Native iOS)

Native Swift SDK for the Artemis agent platform. This package is a full port of the Flutter `artemis_socket_plugin` Dart SDK, providing WebSocket chat, token management, session handling, streaming responses, history hydration, and interactive actions.

**Requirements:** iOS 15.0+, Swift 5.9+, Xcode 15+

## Features

- YAML/JSON configuration loading with validation
- SDK token bootstrap (`POST /api/v1/sdk/init`) and refresh
- WebSocket connection with ticket-based auth (legacy token auth fallback)
- Session lifecycle (`session_start`, `end_session`, reconnect with exponential backoff)
- Chat messaging with streaming (`response_start`, `response_chunk`, `response_end`)
- Persisted history hydration via REST API
- Interactive actions and feedback submission
- Combine publishers and delegate-based event delivery
- Swift Package Manager and CocoaPods distribution

## Installation

### Swift Package Manager

Add the package in Xcode:

1. **File → Add Package Dependencies…**
2. Enter the repository URL or choose **Add Local…** and select this directory
3. Add the `ArtemisSocketSDK` library to your target

Or add to `Package.swift`:

```swift
dependencies: [
    .package(path: "../artemis_socket_plugin"),
],
targets: [
    .target(
        name: "YourApp",
        dependencies: [
            .product(name: "ArtemisSocketSDK", package: "artemis_socket_plugin"),
        ]
    ),
]
```

### CocoaPods

Add to your `Podfile`:

```ruby
pod 'ArtemisSocketSDK', :path => '../artemis_socket_plugin'
```

Then run:

```bash
pod install --repo-update
```

> **Note:** CocoaPods trunk publishes Yams up to `5.0.6`. The podspec uses `~> 5.0` to match that. SPM resolves newer Yams releases directly from GitHub.

## Quick Start

### 1. Add configuration

Copy `sdk_configurations.yaml` into your app bundle (same format as the Flutter plugin):

```yaml
artemis_sdk:
  environment: dev
  connection:
    project_id: "your-project-id"
    api_key: "your-api-key"
    endpoint: "https://agents-dev.kore.ai"
  channel:
    channel_id: "your-channel-id"
  debug:
    enabled: true
    print_logs: true
```

### 2. Initialize and connect

```swift
import ArtemisSocketSDK

@MainActor
final class ChatManager: AgentSDKDelegate {
    private var sdk: AgentSDK?

    func start() async {
        do {
            let sdk = try AgentSDK.initialize(fromBundle: .main)
            sdk.delegate = self
            self.sdk = sdk

            let sessionId = try await sdk.connect()
            print("Connected: \(sessionId)")
        } catch {
            print("Connection failed: \(error)")
        }
    }

    func agentSDK(_ sdk: AgentSDK, didReceive event: SDKEvent) {
        switch event {
        case .connected(let sessionId):
            print("Connected: \(sessionId)")
        case .disconnected(let reason):
            print("Disconnected: \(reason ?? "")")
        case .error(let error, let code):
            print("[\(code)] \(error)")
        default:
            break
        }
    }

    func agentSDK(_ sdk: AgentSDK, didReceive chatEvent: ChatEvent) {
        switch chatEvent {
        case .messageReceived(let message):
            print("\(message.role): \(message.content)")
        case .typingIndicator(let isTyping):
            print("Typing: \(isTyping)")
        default:
            break
        }
    }
}
```

### 3. Send messages

```swift
let messageId = try await sdk.sendMessage("Hello, Artemis!")
```

## API Reference

### AgentSDK

| Method | Description |
|--------|-------------|
| `initialize(fromBundle:)` | Load config from app bundle YAML |
| `initialize(from:)` | Load config from file URL |
| `initialize(yaml:)` | Load config from YAML string |
| `create(with:)` | Create SDK with programmatic config |
| `connect()` | Connect and return session ID |
| `disconnect()` | Client-initiated disconnect |
| `endSession()` | Send `end_session` and disconnect |
| `isConnected()` | Whether session is active |
| `getSessionId()` | Current session ID |
| `getWidgetConfig()` | Server-provided widget theme |
| `sendMessage(_:metadata:attachmentIds:)` | Send chat message |
| `submitAction(_:value:formData:renderId:)` | Submit UI action |
| `submitFeedback(...)` | Submit message feedback |
| `getMessages()` | Local message store |
| `updateCustomData(_:)` | Attach data to outgoing messages |
| `clearHistory()` | Clear local messages |
| `dispose()` | Release resources |

### Events

**SDKEvent:** `connected`, `disconnected`, `reconnecting`, `error`, `idleTimeout`

**ChatEvent:** `messageReceived`, `historyLoaded`, `messageStart`, `messageChunk`, `messageEnd`, `typingIndicator`, `thought`, `error`

**SDKErrorCode:** `tokenInit`, `tokenRefresh`, `wsTicket`, `socketConnection`, `sessionStartTimeout`, `sendFailed`, `historyFetch`, `unknown`

### Combine Publishers

```swift
sdk.sdkEvents
    .sink { event in /* handle SDK event */ }
    .store(in: &cancellables)

sdk.chatEvents
    .sink { event in /* handle chat event */ }
    .store(in: &cancellables)
```

## Example App

A SwiftUI example using the local CocoaPods spec is included:

```bash
cd Example
pod install
open ArtemisSocketExample.xcworkspace
```

The example demonstrates:

- SDK initialization from bundled YAML config
- Connect / disconnect / end session
- Sending messages and displaying streaming responses
- Typing indicators and connection state
- Custom data attachment
- Delegate and Combine event handling

## Project Structure

```
artemis_socket_plugin/
├── Package.swift                    # SPM manifest
├── ArtemisSocketSDK.podspec         # CocoaPods spec
├── Sources/ArtemisSocketSDK/
│   ├── AgentSDK.swift               # Public facade
│   ├── Config/                      # Configuration models & loader
│   ├── Core/                        # Token & session managers
│   ├── Chat/                        # Chat client
│   ├── Events/                      # SDK & chat events
│   ├── Models/                      # Message, WidgetConfig
│   ├── Transport/                   # WebSocket protocol types
│   └── Utils/                       # Logging, helpers
├── Tests/ArtemisSocketSDKTests/     # Unit tests
└── Example/ArtemisSocketExample/    # Demo iOS app
```

## Connection Flow

```
1. AgentSDK.connect()
2. TokenManager → POST /api/v1/sdk/init (or /refresh)
3. POST /api/v1/sdk/ws-ticket → WebSocket subprotocols
4. WebSocket connect to {wssEndpoint}/ws/sdk
5. Wait for session_start (10s timeout)
6. Hydrate persisted history + resend pending messages
```

## Testing

```bash
swift test
```

## Parity with Flutter Plugin

This native SDK ports all runtime functionality from the Flutter plugin's Dart layer:

| Flutter (Dart) | iOS (Swift) |
|----------------|-------------|
| `AgentSDK` | `AgentSDK` |
| `SDKConfigurationLoader` | `SDKConfigurationLoader` |
| `TokenManager` | `TokenManager` |
| `SessionManager` | `SessionManager` |
| `ChatClient` | `ChatClient` |
| `Stream<SDKEvent>` | `sdkEvents` publisher + delegate |
| `Stream<ChatEvent>` | `chatEvents` publisher + delegate |

Configuration-only features (voice, storage, analytics) are modeled but not wired into runtime, matching the Flutter plugin behavior.

## License

MIT — see [LICENSE](LICENSE).
