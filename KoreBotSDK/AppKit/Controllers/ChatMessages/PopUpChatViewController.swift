import UIKit

/// Popup presentation of the existing chat controller.
///
/// All chat behavior remains inherited from `ChatMessagesViewController`; the supporting
/// presentation controller only changes how the SDK is displayed over the parent application.
public final class PopUpChatViewController: ChatMessagesViewController {}

private final class PopUpChatNavigationController: UINavigationController,
    UIViewControllerTransitioningDelegate {

    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        configurePopupPresentation()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configurePopupPresentation()
    }

    private func configurePopupPresentation() {
        isNavigationBarHidden = true
        modalPresentationStyle = .custom
        transitioningDelegate = self
        view.backgroundColor = .clear
    }

    func presentationController(
        forPresented presented: UIViewController,
        presenting: UIViewController?,
        source: UIViewController
    ) -> UIPresentationController? {
        PopUpChatPresentationController(
            presentedViewController: presented,
            presenting: presenting
        )
    }
}

private final class PopUpChatPresentationController: UIPresentationController {

    private static let backgroundDimAlpha: CGFloat = 0.25
    private static let topCornerRadius: CGFloat = 18

    private let dimmingView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0
        return view
    }()

    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView else {
            return .zero
        }

        let bounds = containerView.bounds
        let popupHeightRatio =
            CGFloat(SDKConfiguration.botConfig.resolvedChatScreenPercentage) / 100
        let popupHeight = bounds.height * popupHeightRatio
        return CGRect(
            x: bounds.minX,
            y: bounds.maxY - popupHeight,
            width: bounds.width,
            height: popupHeight
        )
    }

    override func presentationTransitionWillBegin() {
        guard let containerView = containerView else {
            return
        }

        dimmingView.frame = containerView.bounds
        containerView.insertSubview(dimmingView, at: 0)
        applyPopupShape()

        if let transitionCoordinator = presentedViewController.transitionCoordinator {
            transitionCoordinator.animate(alongsideTransition: { _ in
                self.dimmingView.alpha = Self.backgroundDimAlpha
            })
        } else {
            dimmingView.alpha = Self.backgroundDimAlpha
        }
    }

    override func presentationTransitionDidEnd(_ completed: Bool) {
        if !completed {
            dimmingView.removeFromSuperview()
        }
    }

    override func dismissalTransitionWillBegin() {
        if let transitionCoordinator = presentedViewController.transitionCoordinator {
            transitionCoordinator.animate(alongsideTransition: { _ in
                self.dimmingView.alpha = 0
            })
        } else {
            dimmingView.alpha = 0
        }
    }

    override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
            dimmingView.removeFromSuperview()
        }
    }

    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        dimmingView.frame = containerView?.bounds ?? .zero
        presentedView?.frame = frameOfPresentedViewInContainerView
        applyPopupShape()
    }

    private func applyPopupShape() {
        guard let presentedView = presentedView else {
            return
        }

        presentedView.layer.cornerRadius = Self.topCornerRadius
        presentedView.layer.maskedCorners = [
            .layerMinXMinYCorner,
            .layerMaxXMinYCorner
        ]
        presentedView.layer.masksToBounds = true
    }
}

extension BotConnect {

    /// Platform-specific popup height for Cordova / OutSystems hosts.
    public var iosChatScreenPercentage: Int? {
        get { SDKConfiguration.botConfig.iosChatScreenPercentage }
        set {
            SDKConfiguration.botConfig.iosChatScreenPercentage =
                newValue.map { min(100, max(1, $0)) }
        }
    }

    /// Shared popup height for Cordova / OutSystems hosts.
    public var chatScreenPercentage: Int? {
        get { SDKConfiguration.botConfig.chatScreenPercentage }
        set {
            SDKConfiguration.botConfig.chatScreenPercentage =
                newValue.map { min(100, max(1, $0)) }
        }
    }

    /// Legacy popup height (`chatWindowHeightPercentage`) for Cordova hosts.
    public var popupHeightPercentage: Int {
        get { SDKConfiguration.botConfig.resolvedChatScreenPercentage }
        set {
            SDKConfiguration.botConfig.chatWindowHeightPercentage =
                min(100, max(1, newValue))
        }
    }

    /// Opens the existing chat flow using the popup presentation.
    public func showPopup() {
        customSettings()

        guard let rootViewController = UIApplication.shared.keyWindow?.rootViewController else {
            return
        }

        botViewController = PopUpChatViewController()
        let navigationController = PopUpChatNavigationController(
            rootViewController: botViewController
        )
        let semanticDirection: UISemanticContentAttribute =
            isKoreSDKRTL
            ? .forceRightToLeft
            : .forceLeftToRight
        navigationController.view.semanticContentAttribute = semanticDirection
        botViewController.view.semanticContentAttribute = semanticDirection
        botViewController.title = SDKConfiguration.botConfig.chatBotName
        botViewController.preferredLanguageChangeHandler = { [weak self] language in
            self?.koreSDkLanguage = language
            self?.laguageSettings()
        }
        rootViewController.present(navigationController, animated: false)

        botViewController.closeAndMinimizeEvent = { [weak self] dictionary in
            guard let dictionary = dictionary else {
                return
            }
            self?.closeOrMinimizeEvent?(dictionary)
        }
    }
}
