import SwiftUI
import ArtemisUISDK
import ArtemisSocketPlugin

@main
struct ArtemisUIExampleApp: App {
    var body: some Scene { WindowGroup { ContentView() } }
}

struct ContentView: View {
    @State private var showChat = false
    // Replace these values with the host application's runtime configuration.
    private let configuration = SDKConfiguration(
        environment: "dev",
        connection: ConnectionConfig(projectId: "019ebab0-737a-7661-9c02-d8d416320a1c", endpoint: "https://agents-dev.kore.ai", apiKey: "pk_3721dc52d9b95534fa402c680387afee04b9c9b569a9c508"),
        channel: ChannelConfig(channelId: "019eee30-53a9-7961-afb1-e9303a8c989f")
    )
//    private let configuration = SDKConfiguration(
//        environment: "dev",
//        connection: ConnectionConfig(projectId: "019f1722-d26c-7b94-87c6-c7f92696b82e", endpoint: "https://agents-staging.kore.ai", apiKey: "pk_bf8b6594eaad472af132f344a10f1ef5b67aa984188c1446"),
//        channel: ChannelConfig(channelId: "019f1726-7bc7-779a-851e-5c2c69c1c635")
//    )

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Button("Open Agent Chat") { showChat = true }.buttonStyle(.borderedProminent)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("")
            .fullScreenCover(isPresented: $showChat) {
                NavigationView {
                    AgentChatUI.view(
                        configuration: configuration,
                        title: "Agent Chat",
                        fonts: ChatFonts(family: nil, monospaceFamily: "Menlo"),
                        onClose: { showChat = false }
//                        headerBuilder: { header in AnyView(ExampleChatHeader(context: header)) },
//                        footerBuilder: { footer in AnyView(ExampleChatFooter(context: footer)) },
//                        templateRegistry: exampleTemplateRegistry
                    )
                }
            }
        }
    }

    private var exampleTemplateRegistry: RichTemplateRegistry {
        var registry = RichTemplateRegistry()
        registry.register(RichTemplateRenderer(
            type: "order_card",
            matches: { message in
                guard let metadata = message.metadata else { return false }
                let directType = metadata["template"]?.value as? String
                let richContent = metadata["richContent"]?.value as? [String: Any]
                    ?? metadata["rich_content"]?.value as? [String: Any]
                let nestedType = richContent?["template"] as? String
                return directType == "order_card" || nestedType == "order_card"
            },
            build: { message, context in
                AnyView(ExampleOrderCard(message: message, context: context))
            }
        ))
        return registry
    }
}

private struct ExampleOrderCard: View {
    let message: Message
    let context: RichTemplateContext

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Order card", systemImage: "shippingbox.fill")
                .font(.headline)
            Text("This template is rendered by the parent app.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Button("Confirm order") {
                context.submitAction("confirm-order", "confirmed", nil, message.id)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(context.accentColor.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

/// Example parent-app header injected into the SDK.
private struct ExampleChatHeader: View {
    let context: ChatHeaderContext

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "sparkles")
                .foregroundStyle(.white)
                .frame(width: 36, height: 36)
                .background(.white.opacity(0.2))
                .clipShape(Circle())
            VStack(alignment: .leading, spacing: 2) {
                Text(context.title).font(.headline).foregroundStyle(.white)
                Text("Provided by the parent app").font(.caption).foregroundStyle(.white.opacity(0.8))
            }
            Spacer()
            Button(action: context.onClose) {
                Image(systemName: "xmark").foregroundStyle(.white).padding(8)
            }
            .accessibilityLabel("Close chat")
        }
        .padding(.horizontal, 16)
        .frame(height: 64)
        .background(Color.accentColor)
    }
}

/// Example parent-app footer injected into the SDK.
private struct ExampleChatFooter: View {
    let context: ChatFooterContext

    var body: some View {
        HStack(spacing: 8) {
            if let onAttach = context.onAttach {
                Button(action: onAttach) { Image(systemName: "paperclip") }
                    .disabled(!context.enabled)
            }
            TextField(context.placeholder, text: context.text)
                .textFieldStyle(.roundedBorder)
                .disabled(!context.enabled)
                .onSubmit(context.onSend)
            Button(action: context.onSend) {
                Image(systemName: "arrow.up.circle.fill").font(.title2)
            }
            .disabled(!context.canSend)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.background)
    }
}
