# Artemis Native iOS UI SDK

SwiftUI implementation of the Artemis Flutter UI SDK contract. It uses the local `artemis_socket_plugin` package for the unchanged REST/WebSocket protocol, token lifecycle, streaming, reconnect, history, and events.

## Integration

### Swift Package Manager

Add this package to the host app. `Package.swift` uses the supplied local socket package at `/Users/Kartheek.Pagidimarri/Desktop/Git Codes/artemis_Native_iOS_Code/artemis_socket_plugin`.

Add this package and the sibling socket package to the host app, then present the UI:

```swift
import ArtemisUISDK

let configuration = try SDKConfigurationLoader.createDefault(
    projectId: "project-id", endpoint: "https://runtime.example.com", apiKey: "pk_..."
)
AgentChatUI.present(from: self, configuration: configuration, title: "Support")
```

For SwiftUI:

```swift
NavigationStack { AgentChatUI.view(configuration: configuration) }
```

### Host view and template injection

The parent app can replace the header and footer and register message-specific
rich-content renderers. Builders return `AnyView`, so they can contain any
SwiftUI view hierarchy:

```swift
var templates = RichTemplateRegistry()
templates.register(RichTemplateRenderer(
    type: "order_card",
    matches: { message in
        (message.metadata?["template"]?.value as? String) == "order_card"
    },
    build: { message, context in
        AnyView(VStack(alignment: .leading) {
            Text("Order card")
            Button("Confirm") {
                context.submitAction("confirm-order", "confirmed", nil, message.id)
            }
        })
    }
))

NavigationStack {
    AgentChatUI.view(
        configuration: configuration,
        headerBuilder: { header in
            AnyView(HStack {
                Text(header.title)
                Spacer()
                Button("Close", action: header.onClose)
            }.padding())
        },
        footerBuilder: { footer in
            AnyView(HStack {
                TextField(footer.placeholder, text: footer.text)
                Button("Send", action: footer.onSend).disabled(!footer.enabled)
            }.padding())
        },
        templateRegistry: templates
    )
}
```

`AgentChatUI.present` accepts the same `headerBuilder`, `footerBuilder`, and
`templateRegistry` arguments.

### CocoaPods

Add both pods to the host app's `Podfile`:

```ruby
pod 'artemis_socket_plugin', :path => '/Users/Kartheek.Pagidimarri/Desktop/Git Codes/artemis_Native_iOS_Code/artemis_socket_plugin'
pod 'artemis_ui_sdk', :path => '../artemis_ui_sdk'
```

For published pods, use the normal version declarations instead:

```ruby
pod 'artemis_socket_plugin', '~> 1.0'
pod 'artemis_ui_sdk', '~> 1.0'
```

Then run `pod install` and open the generated `.xcworkspace`.

The bundle configuration form is also supported with `AgentChatUI.view(configuration: nil)` and `sdk_configurations.yaml`. The native UI includes connection status, reconnect, streaming/typing state, Markdown text, carousel cards from `richContent`, auto-scroll, disabled input while offline, and lifecycle cleanup.

### Built-in rich templates

The native SDK now parses and renders the same Flutter/Web rich-content keys from
message metadata: `image`, `html`, `video`, `audio`, `file`, `list`, `kpi`,
`table`, `chart`, `form`, `progress`, `feedback`, `actions`,
`quick_replies`, channel fallback payloads, and carousel cards. Interactive
templates call the socket SDK's `submitAction`/`submitFeedback` paths.

Host apps can still pass a `RichTemplateRegistry` for custom payloads. Register
a renderer with the same type as a built-in, for example `RichTemplateTypes.kpi`,
to suppress the default renderer and provide an app-specific one.

### UI source organization

Each built-in template has its own SwiftUI `View` struct and file under
`Sources/ArtemisUISDK/Templates/`. `RichTemplateViews.swift` selects the templates
for a message, while `Templates/Shared/` contains reusable cards, styles, and
formatting helpers. The default header and message composer live in
`Components/ChatHeaderView.swift` and `Components/ChatFooterView.swift`.
These implementation types are internal; host apps customize the UI through
the existing header/footer builders and `RichTemplateRegistry`.

## Build

The package references the supplied local socket package at `/Users/Kartheek.Pagidimarri/Desktop/Git Codes/artemis_Native_iOS_Code/artemis_socket_plugin`. From this directory run:

```sh
swift test
```

## Example iOS host

Open `Example/ArtemisUIExample.xcworkspace` for the native SwiftUI host after running `pod install` from `Example/`. It demonstrates the same one-button launch flow as the Flutter example, inline configuration, bundle YAML, themed chat UI, custom font injection, streaming, reconnect, Markdown, typing state, and carousel cards.

The example uses CocoaPods exclusively. Its `Podfile` links both `artemis_ui_sdk` and the supplied `artemis_socket_plugin` reference package. Do not also add these SDKs through Swift Package Manager to the same target, because that loads duplicate class implementations.
