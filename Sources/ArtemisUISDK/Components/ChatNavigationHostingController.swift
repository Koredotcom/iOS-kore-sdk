#if canImport(UIKit)
import SwiftUI
import UIKit

/// Owns navigation-bar visibility only while the pushed chat is on screen.
final class ChatNavigationHostingController<Content: View>: UIHostingController<Content> {
    private var previousNavigationBarHidden: Bool?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let navigationController else { return }
        if previousNavigationBarHidden == nil {
            previousNavigationBarHidden = navigationController.isNavigationBarHidden
        }
        navigationController.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard let navigationController, let previousNavigationBarHidden,
              isMovingFromParent || navigationController.topViewController !== self || navigationController.isBeingDismissed else { return }
        navigationController.setNavigationBarHidden(previousNavigationBarHidden, animated: animated)
        transitionCoordinator?.animate(alongsideTransition: nil) { [weak self, weak navigationController] context in
            // A cancelled interactive pop leaves chat visible.
            if context.isCancelled, let self, navigationController?.topViewController === self {
                navigationController?.setNavigationBarHidden(true, animated: false)
            }
        }
    }
}
#endif
