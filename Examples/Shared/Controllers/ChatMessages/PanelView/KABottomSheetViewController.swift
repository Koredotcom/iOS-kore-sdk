//
//  KABottomSheetViewController.swift
//  KoraSDK
//
//  Created by Srinivas Vasadi on 13/11/19.
//  Copyright © 2019 Srinivas Vasadi. All rights reserved.
//

import UIKit

public enum SheetSize {
    case fixed(CGFloat)
    case halfScreen
    case fullScreen
}

open class KABottomSheetController: UIViewController {
    // MARK: - Public Properties
    public private(set) var childViewController: UIViewController!
    
    public let containerView = UIView()
    public let pullBarView = UIView()
    public let handleView = UIView()
    public var handleColor: UIColor = UIColor.lightGreyBlue {
        didSet {
            self.handleView.backgroundColor = self.handleColor
        }
    }
    public var handleSize: CGSize = CGSize(width: 64.0, height: 5.0)
    public var handleTopEdgeInset: CGFloat = 9
    public var handleBottomEdgeInset: CGFloat = 9
    public var dismissOnBackgroundTap: Bool = true
    public var dismissOnPan: Bool = true
    
    public var dismissable: Bool = true {
        didSet {
            guard isViewLoaded else { return }
        }
    }
    
    public var extendBackgroundBehindHandle: Bool = false {
        didSet {
            guard isViewLoaded else { return }
            self.pullBarView.backgroundColor = extendBackgroundBehindHandle ? childViewController.view.backgroundColor : UIColor.clear
            self.updateRoundedCorners()
        }
    }
    
    private var firstPanPoint: CGPoint = CGPoint.zero
    public var keyBoardRect:CGRect = .zero
    public var topCornersRadius: CGFloat = 3.0 {
        didSet {
            guard isViewLoaded else { return }
            self.updateRoundedCorners()
        }
    }
    
    public var overlayColor: UIColor = UIColor(white: 0, alpha: 0.7) {
        didSet {
            if self.isViewLoaded && self.view?.window != nil {
                self.view.backgroundColor = .clear// self.overlayColor
            }
        }
    }
    
    public var willDismiss: ((KABottomSheetController) -> Void)?
    public var didDismiss: ((KABottomSheetController) -> Void)?
    
    // MARK: - Private properties
    private var containerSize: SheetSize = .fixed(300)
    private var actualContainerSize: SheetSize = .fixed(300)
    private var orderedSheetSizes: [SheetSize] = [.fixed(300), .fullScreen]
    
    private var panGestureRecognizer: InitialTouchPanGestureRecognizer!
    private weak var childScrollView: UIScrollView?
    
    private var containerHeightConstraint: NSLayoutConstraint!
    private var containerBottomConstraint: NSLayoutConstraint!
    private var keyboardHeight: CGFloat = 0
    
    var bgView = UIView(frame: CGRect(x: 0, y: -UIScreen.main.bounds.size.height, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height*3))
    private var safeAreaInsets: UIEdgeInsets {
        var inserts = UIEdgeInsets.zero
        if #available(iOS 11.0, *) {
            inserts = UIApplication.shared.keyWindow?.safeAreaInsets ?? inserts
        }
        inserts.top = max(inserts.top, 20)
        return inserts
    }
    
    // MARK: - Functions
    @available(*, deprecated, message: "Use the init(controller:, sizes:) initializer")
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    public convenience init(controller: UIViewController, sizes: [SheetSize] = []) {
        self.init(nibName: nil, bundle: nil)
        self.childViewController = controller
        if sizes.count > 0 {
            self.setSizes(sizes, animated: false)
        }
        self.modalPresentationStyle = .overFullScreen
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        if (self.childViewController == nil) {
            fatalError("KABottomSheetController requires a child view controller")
        }
        
        self.view.backgroundColor = UIColor.clear
        self.setUpContainerView()
        
        if(dismissable){
            self.setUpDismissView()
            
            let panGestureRecognizer = InitialTouchPanGestureRecognizer(target: self, action: #selector(panned(_:)))
            self.view.addGestureRecognizer(panGestureRecognizer)
            panGestureRecognizer.delegate = self
            self.panGestureRecognizer = panGestureRecognizer
        }
      
        self.setUpPullBarView()
        self.setUpChildViewController()
        self.updateRoundedCorners()
        self.view.addSubview(bgView)
        self.view.insertSubview(bgView, at: 0)
        bgView.backgroundColor = UIColor.init(red: 0.02, green: 0.02, blue: 0.02, alpha: 0.6)
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.view.backgroundColor = .clear
        self.containerView.transform = CGAffineTransform.identity
        self.actualContainerSize = .fixed(self.containerView.frame.height)
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        UIView.animate(withDuration: 1.0) {
            self.bgView.backgroundColor = UIColor.init(red: 0.02, green: 0.02, blue: 0.02, alpha: 0.6)
        }
    }
    
    public func setSizes(_ sizes: [SheetSize], animated: Bool = true) {
        guard sizes.count > 0 else {
            return
        }
        self.orderedSheetSizes = sizes.sorted(by: { self.height(for: $0) < self.height(for: $1) })
        
        self.resize(to: sizes[0], animated: animated)
    }
    
    public func resize(to size: SheetSize, animated: Bool = true) {
        self.containerHeightConstraint?.constant = self.height(for: size)
        self.containerSize = size
        self.actualContainerSize = size
    }
    
    private func updateLegacyRoundedCorners() {
        if #available(iOS 11.0, *) {
            self.childViewController.view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        } else {
            let path = UIBezierPath(roundedRect: self.childViewController.view.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 10, height: 10))
            let maskLayer = CAShapeLayer()
            maskLayer.path = path.cgPath
            self.childViewController.view.layer.mask = maskLayer
        }
    }
    
    private func setUpOverlay() {
        let overlay = UIView(frame: CGRect.zero)
        overlay.backgroundColor = .clear
        self.view.addSubview(overlay) { (subview) in
            subview.edges.pinToSuperview()
        }
    }
    
    private func setUpContainerView() {
        self.view.addSubview(self.containerView) { (subview) in
            subview.edges(.left, .right).pinToSuperview()
            self.containerBottomConstraint = subview.bottom.pinToSuperview()
            subview.top.pinToSuperview(inset: self.safeAreaInsets.top + 20, relation: .greaterThanOrEqual)
            self.containerHeightConstraint = subview.height.set(self.height(for: self.containerSize))
            self.containerHeightConstraint.priority = UILayoutPriority(900)
        }
        self.containerView.layer.masksToBounds = true
        self.containerView.backgroundColor = UIColor.clear
        self.containerView.transform = CGAffineTransform(translationX: 0, y: UIScreen.main.bounds.height)
        
        self.view.addSubview(UIView(frame: CGRect.zero)) { subview in
            subview.edges(.left, .right, .bottom).pinToSuperview()
            subview.height.set(0).priority = UILayoutPriority(100)
            subview.top.align(with: self.containerView.al.bottom)
            subview.base.backgroundColor = UIColor.white
        }
    }
    
    private func setUpChildViewController() {
        self.childViewController.willMove(toParent: self)
        self.addChild(self.childViewController)
        self.containerView.addSubview(self.childViewController.view) { (subview) in
            subview.edges(.left, .right).pinToSuperview()
            subview.bottom.pinToSuperview()
            subview.top.align(with: self.pullBarView.al.bottom)
        }
        
        self.childViewController.view.layer.masksToBounds = true
        
        self.childViewController.didMove(toParent: self)
    }
    
    private func updateRoundedCorners() {
        if #available(iOS 11.0, *) {
            let controllerWithRoundedCorners = extendBackgroundBehindHandle ? self.containerView : self.childViewController.view
            let controllerWithoutRoundedCorners = extendBackgroundBehindHandle ? self.childViewController.view : self.containerView
            controllerWithRoundedCorners?.layer.maskedCorners = self.topCornersRadius > 0 ? [.layerMaxXMinYCorner, .layerMinXMinYCorner] : []
            controllerWithRoundedCorners?.layer.cornerRadius = self.topCornersRadius
            controllerWithoutRoundedCorners?.layer.maskedCorners = []
            controllerWithoutRoundedCorners?.layer.cornerRadius = 0
        }
    }
    
    private func setUpDismissView() {
        let dismissAreaView = UIView(frame: CGRect.zero)
        self.view.addSubview(dismissAreaView, containerView) { (dismissAreaView, containerView) in
            dismissAreaView.edges(.top, .left, .right).pinToSuperview()
            dismissAreaView.bottom.align(with: containerView.top)
        }
        dismissAreaView.backgroundColor = UIColor.clear
        dismissAreaView.isUserInteractionEnabled = true
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissTapped))
        dismissAreaView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    private func setUpPullBarView() {
        self.containerView.addSubview(self.pullBarView) { (subview) in
            subview.edges(.top, .left, .right).pinToSuperview()
        }
        
        self.pullBarView.addSubview(handleView) { (subview) in
            subview.top.pinToSuperview(inset: handleTopEdgeInset, relation: .equal)
            subview.bottom.pinToSuperview(inset: handleBottomEdgeInset, relation: .equal)
            subview.centerX.alignWithSuperview()
            subview.size.set(handleSize)
        }
        pullBarView.layer.masksToBounds = true
        pullBarView.backgroundColor = extendBackgroundBehindHandle ? childViewController.view.backgroundColor : UIColor.clear
        
        handleView.layer.cornerRadius = handleSize.height / 2.0
        handleView.layer.masksToBounds = true
        handleView.backgroundColor = self.handleColor
        
        pullBarView.isAccessibilityElement = true
        pullBarView.accessibilityLabel = "Pull bar"
        pullBarView.accessibilityHint = "Tap on this bar to dismiss the modal"
        pullBarView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissTapped)))
    }
    
    @objc func dismissTapped() {
        guard dismissOnBackgroundTap else { return }
        self.closeSheet()
    }
    
    public func closeSheet(completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseIn], animations: { [weak self] in
            self?.containerView.transform = CGAffineTransform(translationX: 0, y: self?.containerView.frame.height ?? 0)
            self?.view.backgroundColor = UIColor.clear
        }, completion: { [weak self] complete in
            self?.dismiss(animated: false, completion: completion)
        })
    }
    
    override open func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        self.willDismiss?(self)
        var duration = 0.0
        if flag {
            duration = 0.5
        }
        UIView.animate(withDuration: duration) {
            self.bgView.backgroundColor = UIColor.init(red: 0.02, green: 0.02, blue: 0.02, alpha: 0.0)
        }
        super.dismiss(animated: flag) {
            self.didDismiss?(self)
            completion?()
        }
    }
    
    @objc func panned(_ gesture: UIPanGestureRecognizer) {
        let point = gesture.translation(in: gesture.view?.superview)
        if gesture.state == .began {
            self.firstPanPoint = point
            self.actualContainerSize = .fixed(self.containerView.frame.height)
        }
        
        let minHeight = min(self.height(for: self.actualContainerSize), self.height(for: self.orderedSheetSizes.first))
        let maxHeight = max(self.height(for: self.actualContainerSize), self.height(for: self.orderedSheetSizes.last))
        
        var newHeight = max(0, self.height(for: self.actualContainerSize) + (self.firstPanPoint.y - point.y))
        var offset: CGFloat = 0
        if newHeight < minHeight {
            offset = minHeight - newHeight
            newHeight = minHeight
        }
        if newHeight > maxHeight {
            newHeight = maxHeight
        }
        
        if gesture.state == .cancelled || gesture.state == .failed {
            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut], animations: {
                self.containerView.transform = CGAffineTransform.identity
                self.containerHeightConstraint.constant = self.height(for: self.containerSize)
            }, completion: nil)
        } else if gesture.state == .ended {
            let velocity = (0.2 * gesture.velocity(in: self.view).y)
            var finalHeight = newHeight - offset - velocity
            if velocity > 500 {
                finalHeight = -1
            }
            
            let animationDuration = TimeInterval(abs(velocity*0.0002) + 0.2)
            
            guard finalHeight >= (minHeight / 2) || !dismissOnPan else {
                UIView.animate(withDuration: animationDuration, delay: 0, options: [.curveEaseOut], animations: { [weak self] in
                    self?.containerView.transform = CGAffineTransform(translationX: 0, y: self?.containerView.frame.height ?? 0)
                    self?.view.backgroundColor = UIColor.clear
                }, completion: { [weak self] complete in
                    self?.dismiss(animated: false, completion: nil)
                })
                return
            }
            
            var newSize = self.containerSize
            if point.y < 0 {
                newSize = self.orderedSheetSizes.last ?? self.containerSize
                for size in self.orderedSheetSizes.reversed() {
                    if finalHeight < self.height(for: size) {
                        newSize = size
                    } else {
                        break
                    }
                }
            } else {
                newSize = self.orderedSheetSizes.first ?? self.containerSize
                for size in self.orderedSheetSizes {
                    if finalHeight > self.height(for: size) {
                        newSize = size
                    } else {
                        break
                    }
                }
            }
            self.containerSize = newSize
            
            UIView.animate(withDuration: animationDuration, delay: 0, options: [.curveEaseOut], animations: {
                self.containerView.transform = CGAffineTransform.identity
                self.containerHeightConstraint.constant = self.height(for: newSize)
                self.view.layoutIfNeeded()
            }, completion: { [weak self] complete in
                guard let self = self else { return }
                self.actualContainerSize = .fixed(self.containerView.frame.height)
            })
        } else {
            Constraints(for: self.containerView) { (containerView) in
                self.containerHeightConstraint.constant = newHeight
            }
            
            if offset > 0 && dismissOnPan {
                self.containerView.transform = CGAffineTransform(translationX: 0, y: offset)
            } else {
                self.containerView.transform = CGAffineTransform.identity
            }
            
        }
    }
    
    public func handleScrollView(_ scrollView: UIScrollView) {
        scrollView.panGestureRecognizer.require(toFail: panGestureRecognizer)
        self.childScrollView = scrollView
    }
    
    private func height(for size: SheetSize?) -> CGFloat {
        guard let size = size else { return 0 }
        switch (size) {
            case .fixed(let height):
                return height
            case .fullScreen:
                let insets = self.safeAreaInsets
                return UIScreen.main.bounds.height - insets.top - 20
            case .halfScreen:
                return (UIScreen.main.bounds.height) / 2 + 24
        }
    }
}

extension KABottomSheetController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard let view = touch.view else {
            return true
        }
        return !(view is UIControl)
    }
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let panGestureRecognizer = gestureRecognizer as? InitialTouchPanGestureRecognizer, let childScrollView = self.childScrollView, let point = panGestureRecognizer.initialTouchLocation else { return true }
        
        let pointInChildScrollView = self.view.convert(point, to: childScrollView).y - childScrollView.contentOffset.y
        
        let velocity = panGestureRecognizer.velocity(in: panGestureRecognizer.view?.superview)
        guard pointInChildScrollView > 0, pointInChildScrollView < childScrollView.bounds.height else {
            if keyboardHeight > 0 {
                childScrollView.endEditing(true)
            }
            return true
        }
        
        guard abs(velocity.y) > abs(velocity.x), childScrollView.contentOffset.y == 0 else { return false }
        
        if velocity.y < 0 {
            let containerHeight = height(for: self.containerSize)
            return height(for: self.orderedSheetSizes.last) > containerHeight && containerHeight < height(for: SheetSize.fullScreen)
        } else {
            return true
        }
    }
}

// MARK: - InitialTouchPanGestureRecognizer
class InitialTouchPanGestureRecognizer: UIPanGestureRecognizer {
    var initialTouchLocation: CGPoint?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        initialTouchLocation = touches.first?.location(in: view)
    }
}
