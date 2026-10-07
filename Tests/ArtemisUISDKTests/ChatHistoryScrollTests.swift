#if canImport(UIKit)
import XCTest
import SwiftUI
import UIKit
@testable import ArtemisUISDK
import ArtemisSocketSDK

final class ChatHistoryScrollTests: XCTestCase {
    @MainActor
    func testEmptyMetadataResponsesKeepLongHistoryResponsiveAndAtBottom() async throws {
        let model = HistoryFixture()
        let controller = UIHostingController(rootView: HistoryFixtureView(model: model))
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 390, height: 844))
        window.rootViewController = controller
        window.makeKeyAndVisible()
        defer { window.isHidden = true; window.rootViewController = nil }
        try await settleLayout()

        let scroll = try XCTUnwrap(findScrollView(in: controller.view))
        XCTAssertGreaterThan(scroll.contentSize.height, scroll.bounds.height * 2)

        for turn in 0..<6 {
            // Read earlier history, then send while several state updates arrive together.
            scroll.setContentOffset(CGPoint(x: 0, y: -scroll.adjustedContentInset.top), animated: false)
            try await settleLayout()
            model.messages.append(Message(id: "user-\(turn)", role: .user, content: "Next question", metadata: [:]))
            model.isTyping = true
            model.scrollRevision += 1
            try await settleLayout()
            assertAtBottom(scroll)

            // An empty metadata dictionary is valid for a plain-text response.
            // Exercise the real message/typing views under an inherited animation.
            withAnimation {
                model.messages.append(Message(
                    id: "assistant-\(turn)", role: .assistant,
                    content: String(repeating: "Plain text response without a template.\n\n", count: 8),
                    metadata: [:]
                ))
                model.isTyping = false
            }
            try await settleLayout()
            assertAtBottom(scroll)

            // If lazy layout loops, the main thread cannot reach this interaction.
            scroll.setContentOffset(CGPoint(x: 0, y: -scroll.adjustedContentInset.top), animated: false)
            try await settleLayout()
            XCTAssertEqual(scroll.contentOffset.y, -scroll.adjustedContentInset.top, accuracy: 2)
        }
    }

    @MainActor
    func testRapidChunksScrollBeforeStreamingFinishes() async throws {
        let model = HistoryFixture()
        model.messages.append(Message(id: "stream", role: .assistant, content: ""))
        let controller = UIHostingController(rootView: HistoryFixtureView(model: model))
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 390, height: 844))
        window.rootViewController = controller
        window.makeKeyAndVisible()
        defer { window.isHidden = true; window.rootViewController = nil }
        try await settleLayout()
        let scroll = try XCTUnwrap(findScrollView(in: controller.view))
        scroll.setContentOffset(CGPoint(x: 0, y: -scroll.adjustedContentInset.top), animated: false)
        try await settleLayout()
        let initialOffset = scroll.contentOffset.y
        let messageCount = model.messages.count
        var streamedText = ""
        var halfwayOffset = initialOffset

        // Chunks arrive faster than the 50 ms layout-settling delay. The same
        // message is replaced, with no message-count or typing-state changes.
        for chunk in 0..<60 {
            streamedText += "Streamed paragraph \(chunk).\n\n"
            model.messages[messageCount - 1] = Message(id: "stream", role: .assistant, content: streamedText)
            model.scrollRevision += 1
            try await Task.sleep(nanoseconds: 10_000_000)
            if chunk == 20 {
                halfwayOffset = scroll.contentOffset.y
                XCTAssertGreaterThan(halfwayOffset, initialOffset + 100)
            }
            if chunk == 40 {
                XCTAssertGreaterThan(scroll.contentOffset.y, halfwayOffset + 100)
            }
        }
        XCTAssertEqual(model.messages.count, messageCount)
        try await settleLayout()
        assertAtBottom(scroll)
    }

    @MainActor private func settleLayout() async throws {
        try await Task.sleep(nanoseconds: 200_000_000)
    }

    @MainActor private func assertAtBottom(_ scroll: UIScrollView, file: StaticString = #filePath, line: UInt = #line) {
        let bottom = scroll.contentSize.height + scroll.adjustedContentInset.bottom - scroll.bounds.height
        XCTAssertEqual(scroll.contentOffset.y, max(-scroll.adjustedContentInset.top, bottom), accuracy: 3, file: file, line: line)
    }

    @MainActor private func findScrollView(in view: UIView) -> UIScrollView? {
        if let scroll = view as? UIScrollView { return scroll }
        return view.subviews.lazy.compactMap { self.findScrollView(in: $0) }.first
    }
}

@MainActor private final class HistoryFixture: ObservableObject {
    @Published var messages = (0..<80).map { index in
        Message(id: "history-\(index)", role: index.isMultiple(of: 2) ? .user : .assistant,
                content: String(repeating: "History message \(index).\n\n", count: index % 4 + 1), metadata: [:])
    }
    @Published var isTyping = false
    @Published var scrollRevision = 0
}

private struct HistoryFixtureView: View {
    @ObservedObject var model: HistoryFixture

    var body: some View {
        ChatHistoryScrollView(request: ChatHistoryScrollRequest(
            messageCount: model.messages.count, isTyping: model.isTyping, revision: model.scrollRevision
        )) { width in
            ForEach(model.messages) { message in
                MessageBubble(message: message, rowWidth: width, fonts: nil, theme: nil,
                              templateRegistry: nil, onSubmitAction: { _, _, _, _ in },
                              onSubmitFeedback: { _, _, _, _ in }, attachments: [], resolveAttachment: { _ in nil })
                    .id(message.id)
            }
            if model.isTyping { TypingBubble(theme: nil) }
        }
    }
}
#endif
