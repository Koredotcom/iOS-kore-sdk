import SwiftUI

struct ChatHistoryScrollRequest: Equatable {
    let messageCount: Int
    let isTyping: Bool
    let revision: Int
}

/// Keeps message insertion and automatic scrolling out of animated lazy-layout
/// transactions, which can loop when a response replaces the typing row.
struct ChatHistoryScrollView<Content: View>: View {
    let request: ChatHistoryScrollRequest
    @ViewBuilder let content: (CGFloat) -> Content

    private enum Anchor: Hashable { case bottom }

    var body: some View {
        GeometryReader { geometry in
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        content(max(0, geometry.size.width - 30))
                        Color.clear
                            .frame(height: 16)
                            .id(Anchor.bottom)
                    }
                    .padding(.horizontal, 15)
                    .padding(.top, 16)
                }
                .task(id: request) {
                    // Scroll once immediately so frequent chunks cannot keep
                    // cancelling a delayed scroll before it runs. Follow-up
                    // passes account for the measured heights of lazy rows.
                    for pass in 0..<3 {
                        if pass == 0 {
                            await Task.yield()
                        } else {
                            do { try await Task.sleep(nanoseconds: 50_000_000) }
                            catch { return }
                        }
                        guard !Task.isCancelled else { return }
                        var transaction = Transaction(animation: nil)
                        transaction.disablesAnimations = true
                        withTransaction(transaction) {
                            proxy.scrollTo(Anchor.bottom, anchor: .bottom)
                        }
                    }
                }
            }
        }
        .transaction { transaction in
            transaction.animation = nil
            transaction.disablesAnimations = true
        }
    }
}
