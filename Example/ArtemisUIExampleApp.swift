import SwiftUI
import ArtemisUISDK

@main
struct ArtemisUIExampleApp: App {
    var body: some Scene { WindowGroup { ContentView() } }
}

struct ContentView: View {
    @State private var showChat = false
    
    // Replace these values with the host application's runtime configuration.
    private let configuration = SDKConfiguration(
        environment: "dev",
        connection: ConnectionConfig(projectId: "your-project-id", endpoint: "https://runtime.example.com", apiKey: "pk_your_public_key"),
        channel: ChannelConfig(channelId: "your-channel-id")
    )
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
//                        headerBuilder: { header in AnyView(ExampleChatHeader(context: header)) },
//                        footerBuilder: { footer in AnyView(ExampleChatFooter(context: footer)) },
//                        templateRegistry: exampleTemplateRegistry,
                        onClose: { showChat = false }
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
