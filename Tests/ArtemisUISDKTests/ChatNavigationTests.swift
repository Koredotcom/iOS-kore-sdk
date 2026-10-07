#if canImport(UIKit)
import XCTest
import SwiftUI
import UIKit
@testable import ArtemisUISDK

final class ChatNavigationTests: XCTestCase {
    @MainActor
    func testPushRequiresNavigationStackAndPreventsDuplicateChat() {
        XCTAssertFalse(AgentChatUI.show(in: UIViewController(), animated: false))

        let source = UIViewController()
        let navigation = UINavigationController(rootViewController: source)
        XCTAssertTrue(AgentChatUI.show(in: source, title: "Support", animated: false))
        XCTAssertEqual(navigation.viewControllers.count, 2)
        XCTAssertTrue(navigation.topViewController is ChatNavigationHostingController<AgentChatView>)
        XCTAssertEqual(navigation.topViewController?.title, "Support")
        XCTAssertEqual(navigation.topViewController?.hidesBottomBarWhenPushed, true)
        XCTAssertNil(source.presentedViewController)
        XCTAssertFalse(AgentChatUI.show(in: source, animated: false))
        XCTAssertEqual(navigation.viewControllers.count, 2)

        navigation.popViewController(animated: false)
        XCTAssertTrue(AgentChatUI.show(in: navigation, hidesBottomBarWhenPushed: false, animated: false))
        XCTAssertEqual(navigation.topViewController?.hidesBottomBarWhenPushed, false)
    }

    @MainActor
    func testNavigationBarRestoresOnPopAndRemainsHiddenDuringModalPresentation() async throws {
        for initiallyHidden in [false, true] {
            let source = UIViewController()
            let navigation = UINavigationController(rootViewController: source)
            navigation.setNavigationBarHidden(initiallyHidden, animated: false)
            let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 390, height: 844))
            window.rootViewController = navigation
            window.makeKeyAndVisible()
            defer { window.isHidden = true; window.rootViewController = nil }
            try await settle()

            // Exercise the production hosting controller without connecting to a backend.
            let chat = ChatNavigationHostingController(rootView: Text("Offline chat"))
            navigation.pushViewController(chat, animated: false)
            try await settle()
            XCTAssertTrue(navigation.isNavigationBarHidden)

            let picker = UIViewController()
            picker.modalPresentationStyle = .fullScreen
            chat.present(picker, animated: false)
            try await settle()
            XCTAssertTrue(navigation.isNavigationBarHidden)
            chat.dismiss(animated: false)
            try await settle()
            XCTAssertTrue(navigation.isNavigationBarHidden)

            // A destination pushed by custom template content gets the original bar state.
            navigation.pushViewController(UIViewController(), animated: false)
            try await settle()
            XCTAssertEqual(navigation.isNavigationBarHidden, initiallyHidden)
            navigation.popViewController(animated: false)
            try await settle()
            XCTAssertTrue(navigation.isNavigationBarHidden)

            navigation.popViewController(animated: false)
            try await settle()
            XCTAssertTrue(navigation.topViewController === source)
            XCTAssertEqual(navigation.isNavigationBarHidden, initiallyHidden)
        }
    }

    @MainActor private func settle() async throws {
        try await Task.sleep(nanoseconds: 150_000_000)
    }
}
#endif
