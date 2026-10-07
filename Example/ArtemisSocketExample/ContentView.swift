import ArtemisSocketSDK
import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ChatViewModel()

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                headerView
                connectedView
                statusBar
                messageList
                inputBar
            }
            .onAppear {
                if viewModel.connectionState == "Disconnected" {
                    viewModel.connect()
                }
            }
        }
        .navigationViewStyle(.stack)
        .navigationBarHidden(true)
    }

    private var headerView: some View {
        HStack {
            Text("Artemis SDK Demo")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(.white)

            Spacer()

            Button("Reconnect") {
                viewModel.connect()
            }
            .font(.system(size: 17, weight: .medium))
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.white.opacity(0.16))
            .clipShape(Capsule())
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(Color.blue)
    }

    private var connectedView: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(connectionColor)
                .frame(width: 10, height: 10)
            Text(viewModel.connectionState)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(connectionTextColor)
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(connectionBackgroundColor)
    }

    private var connectionColor: Color {
        switch viewModel.connectionState {
        case "Connected": return Color(red: 0.08, green: 0.52, blue: 0.25)
        case "Reconnecting": return .orange
        case "Error": return .red
        default: return .gray
        }
    }

    private var connectionTextColor: Color {
        viewModel.connectionState == "Connected"
            ? Color(red: 0.08, green: 0.42, blue: 0.20)
            : .primary
    }

    private var connectionBackgroundColor: Color {
        viewModel.connectionState == "Connected"
            ? Color(red: 0.85, green: 0.96, blue: 0.88)
            : Color(.secondarySystemBackground)
    }

    @ViewBuilder
    private var statusBar: some View {
        if let status = viewModel.statusMessage {
            Text(status)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.vertical, 6)
                .background(Color(.tertiarySystemBackground))
        }
    }

    private var messageList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    if viewModel.messages.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "bubble.left.and.bubble.right")
                                .font(.system(size: 40))
                                .foregroundStyle(.secondary)
                            Text("No Messages")
                                .font(.headline)
                            Text("Connect and send a message to start chatting.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 150)
                    }

                    ForEach(viewModel.messages) { message in
                        MessageBubble(message: message)
                            .id(message.id)
                    }

                    if viewModel.isTyping {
                        HStack {
                            ProgressView()
                                .controlSize(.small)
                            Text("Assistant is typing…")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal)
                    }
                }
                .padding()
            }
            .onChange(of: viewModel.messages.count) { _ in
                if let last = viewModel.messages.last {
                    withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                }
            }
        }
    }

    private var inputBar: some View {
        HStack(spacing: 8) {
            TextField("Type a message…", text: $viewModel.inputText)
                .font(.system(size: 18, weight: .regular))
                .padding(.horizontal, 16)
                .frame(height: 44)
                .background(Color(.systemBackground))
                .overlay {
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                }
                .onSubmit { viewModel.sendMessage() }

            Button(action: viewModel.sendMessage) {
                Text("Send")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 70, height: 44)
            }
            .background(Color.blue)
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .disabled(viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .opacity(viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.55 : 1)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
        .overlay(alignment: .top) {
            Rectangle()
                .fill(Color(.systemGray5))
                .frame(height: 1)
        }
    }

    @ToolbarContentBuilder
    private var toolbarItems: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            if viewModel.connectionState == "Connected" {
                Button("Disconnect", role: .destructive) {
                    viewModel.disconnect()
                }
            } else {
                Button(viewModel.isConnecting ? "Connecting…" : "Connect") {
                    viewModel.connect()
                }
                .disabled(viewModel.isConnecting)
            }

            Menu {
                Button("End Session") { viewModel.endSession() }
                Button("Clear History") { viewModel.clearHistory() }
                Button("Update Custom Data") { viewModel.updateCustomData() }
            } label: {
                Image(systemName: "ellipsis.circle")
            }
        }
    }
}

struct MessageBubble: View {
    let message: Message

    var body: some View {
        HStack {
            if message.role == .user { Spacer(minLength: 48) }

            VStack(alignment: message.role == .user ? .trailing : .leading, spacing: 4) {
                Text(message.content.isEmpty ? "…" : message.content)
                    .font(.body)
                    .padding(12)
                    .background(bubbleColor)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                Text(message.timestamp, style: .time)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }

            if message.role != .user { Spacer(minLength: 48) }
        }
    }

    private var bubbleColor: Color {
        switch message.role {
        case .user: return Color.accentColor.opacity(0.15)
        case .assistant: return Color(.secondarySystemBackground)
        case .system: return Color.orange.opacity(0.12)
        case .thought: return Color.purple.opacity(0.12)
        }
    }
}

#Preview {
    ContentView()
}
