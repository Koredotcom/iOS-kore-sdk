# Artemis Native iOS UI SDK

SwiftUI implementation of the Artemis Flutter UI SDK contract. It uses the local `ArtemisSocketSDK` package for the unchanged REST/WebSocket protocol, token lifecycle, streaming, reconnect, history, and events.

## Integration

### Swift Package Manager

In an iOS 15+ Xcode app target, choose **File → Add Package Dependencies → Add Local…**, select this repository's root directory, and add the `ArtemisUISDK` product to the app target. The UI package depends on the sibling `ArtemisSocketSDK` package at `../artemis_socket_plugin`. Update the local path in `Package.swift` if the sibling checkout is elsewhere.

### UIKit project

Import only `ArtemisUISDK` in the view controller that opens chat. It exposes `SDKConfiguration`, `ConnectionConfig`, and `ChannelConfig` for the parent app:

```swift
import UIKit
import ArtemisUISDK

final class ViewController: UIViewController {
    private let configuration = SDKConfiguration(
        environment: "dev",
        connection: ConnectionConfig(
            projectId: "your-project-id",
            endpoint: "https://runtime.example.com",
            apiKey: "pk_your_public_key"
        ),
        channel: ChannelConfig(channelId: "your-channel-id")
    )

    @IBAction func tapsOnConnectBtnAction(_ sender: Any) {
        AgentChatUI.show(in: self, configuration: configuration, title: "Support")
    }
}
```

Connect the action to a button and place the view controller in a `UINavigationController`. For a storyboard app, embed the initial view controller in a navigation controller; the [UIKit example](UIKitExample/ArtemisExample/ArtemisExample/ViewController.swift) wraps its root controller in `SceneDelegate.swift` instead. Replace the placeholder configuration with your project's values.

`show(in:)` pushes chat onto that navigation stack, including a tab's navigation controller. It returns `false` if there is no navigation stack or chat is already on top. The close button pops back to the previous screen. The SDK hides the navigation bar while chat is visible and restores it afterward. The tab bar is hidden by default; pass `hidesBottomBarWhenPushed: false` to keep it visible. `animated` defaults to `true`.

To open chat modally from any UIKit view controller, use:

```swift
AgentChatUI.present(from: self, configuration: configuration, title: "Support")
```

The SDK starts the chat connection when the screen appears and stops it when the screen closes. Use either Swift Package Manager or CocoaPods for a given app target.

For a SwiftUI host:

```swift
NavigationStack { AgentChatUI.view(configuration: configuration) }
```

### Host view and template injection

The parent app can replace the header and footer and register message-specific
rich-content renderers. Import `SwiftUI` in the host file. Builders return
`AnyView`, so they can contain any SwiftUI view hierarchy. Add a registry property
to the host view controller or SwiftUI view:

```swift
private var templates: RichTemplateRegistry {
    var registry = RichTemplateRegistry()
    registry.register(RichTemplateRenderer(
        type: "order_card",
        matches: { message in
            (message.metadata?["template"]?.value as? String) == "order_card" ||
            (message.rawRichContent?["template"] as? String) == "order_card"
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
    return registry
}
```

Pass the registry and builders from a SwiftUI host:

```swift
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
                    .disabled(!footer.enabled)
                Button("Send", action: footer.onSend).disabled(!footer.canSend)
            }.padding())
        },
        templateRegistry: templates
    )
}
```

In a UIKit view controller, pass the same registry and builders to `show(in:)`
inside the button action:

```swift
AgentChatUI.show(
    in: self,
    configuration: configuration,
    title: "Support",
    headerBuilder: { header in
        AnyView(HStack {
            Text(header.title)
            Spacer()
            Button("Close", action: header.onClose)
        }.padding())
    },
    footerBuilder: { footer in
        AnyView(HStack {
            if let onAttach = footer.onAttach {
                Button("Attach", action: onAttach).disabled(!footer.enabled)
            }
            TextField(footer.placeholder, text: footer.text)
                .disabled(!footer.enabled)
                .onSubmit(footer.onSend)
            Button("Send", action: footer.onSend).disabled(!footer.canSend)
        }.padding())
    },
    templateRegistry: templates
)
```

The `templates` property is the `RichTemplateRegistry` created above. A matching
`order_card` message renders the parent app's view, and its Confirm button sends
an action through `RichTemplateContext`. `AgentChatUI.present` accepts the same
three customization arguments.

### CocoaPods

Add both pods to the host app's `Podfile`:

```ruby
pod 'ArtemisSocketSDK', :path => '../artemis_socket_plugin'
pod 'ArtemisUISDK', :path => '../artemis_ui_sdk'
```

For published pods, use the normal version declarations instead:

```ruby
pod 'ArtemisSocketSDK', '~> 1.0'
pod 'ArtemisUISDK', '~> 1.0'
```

Then run `pod install` and open the generated `.xcworkspace`.
Adjust each local `:path` relative to the host app's `Podfile`.

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

The package references the supplied local `ArtemisSocketSDK` checkout at `../artemis_socket_plugin`. From this directory run:

```sh
swift test
```

## Example iOS host

Open `Example/ArtemisUIExample.xcworkspace` for the native SwiftUI host after running `pod install` from `Example/`. It demonstrates the same one-button launch flow as the Flutter example, inline configuration, bundle YAML, themed chat UI, custom font injection, streaming, reconnect, Markdown, typing state, and carousel cards.

The example uses CocoaPods exclusively. Its `Podfile` links both `ArtemisUISDK` and `ArtemisSocketSDK`. Do not also add these SDKs through Swift Package Manager to the same target, because that loads duplicate class implementations.

For a UIKit host, open `UIKitExample/ArtemisExample/ArtemisExample.xcodeproj` in Xcode and select the `ArtemisExample` scheme. This project uses the local Swift package. Replace the placeholder project, endpoint, API key, and channel ID in `ViewController.swift`, then run on an iOS 15+ simulator or device. The storyboard's **Connect to Artemis SDK** button calls `tapsOnConnectBtnAction(_:)`, and `SceneDelegate.swift` puts the root view controller in a navigation controller so `show(in:)` can push chat.
