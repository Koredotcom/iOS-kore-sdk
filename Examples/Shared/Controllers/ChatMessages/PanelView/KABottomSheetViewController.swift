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

public class KABottomSheetController: KABasePanelViewController {
    // MARK: - Public Properties
    public var childViewController: UIViewController!
    public lazy var containerView: UIView = {
        let containerView = UIView(frame: .zero)
        containerView.backgroundColor = .clear
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.layer.shadowOffset = CGSize(width: 0.0, height: -3.0)
        containerView.layer.shadowRadius = 3.0
        containerView.layer.shadowOpacity = 0.1
        return containerView
    }()
    public var dismissOnPan: Bool = true
    public var dismissable: Bool = true {
        didSet {
            guard isViewLoaded else { return }
        }
    }
    
    private var firstPanPoint: CGPoint = CGPoint.zero
    public var keyBoardRect:CGRect = .zero
    public var topCornersRadius: CGFloat = 8.0 {
        didSet {
            guard isViewLoaded else { return }
        }
    }
    
    public var overlayColor: UIColor = UIColor(white: 0, alpha: 0.7) {
        didSet {
            if isViewLoaded && view?.window != nil {
                view.backgroundColor = overlayColor
            }
        }
    }

    public var inputViewHeight: CGFloat = 0.0
    public var willSheetSizeChange: ((KABottomSheetController, SheetSize) -> Void)?
    public var willDismiss: ((KABottomSheetController) -> Void)?
    public var didDismiss: ((KABottomSheetController) -> Void)?
    
    // MARK: - Private properties
    private var containerSize: SheetSize = .fixed(300) {
        didSet {
            willSheetSizeChange?(self, containerSize)
        }
    }
    private var actualContainerSize: SheetSize = .fixed(300)
    private var orderedSheetSizes: [SheetSize] = [.fixed(300), .fullScreen]
    
    private var panGestureRecognizer: InitialTouchPanGestureRecognizer!
    private weak var childScrollView: UIScrollView?
    
    private var containerHeightConstraint: NSLayoutConstraint!
    private var containerBottomConstraint: NSLayoutConstraint!
    var colorView = UIView(frame: .zero)
    var state = "Half"
    
    private var safeAreaInsets: UIEdgeInsets {
        var inserts = UIEdgeInsets.zero
        if #available(iOS 11.0, *) {
            inserts = UIApplication.shared.keyWindow?.safeAreaInsets ?? inserts
        }
        inserts.top = max(inserts.top, 20)
        return inserts
    }
    
    // MARK: - Functions
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    public convenience init(controller: UIViewController, sizes: [SheetSize] = []) {
        self.init(nibName: nil, bundle: nil)
        childViewController = controller
        if sizes.count > 0 {
            setSizes(sizes, animated: false)
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(colorView)
        colorView.backgroundColor = UIColor(red: 20, green: 20, blue: 20, alpha: 0.6)
        if childViewController == nil {
            debugPrint("BottomSheetController requires a child view controller")
        }
        
        setUpContainerView()
        
        if(dismissable){
            let panGestureRecognizer = InitialTouchPanGestureRecognizer(target: self, action: #selector(panned(_:)))
            view.addGestureRecognizer(panGestureRecognizer)
            panGestureRecognizer.delegate = self
            self.panGestureRecognizer = panGestureRecognizer
        }
      
        setUpChildViewController()
        colorView.translatesAutoresizingMaskIntoConstraints = false
        colorView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 0).isActive = true
        colorView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: -100).isActive = true
        colorView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0).isActive = true
        colorView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0).isActive = true
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        view.backgroundColor = .clear
        containerView.transform = CGAffineTransform.identity
        actualContainerSize = .fixed(containerView.frame.height)
    
    }
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    public func setSizes(_ sizes: [SheetSize], animated: Bool = true) {
        guard sizes.count > 0 else {
            return
        }
        orderedSheetSizes = sizes.sorted(by: { height(for: $0) < height(for: $1) })
        
        resize(to: sizes[1], animated: animated)
    }
    
    public func resize(to size: SheetSize, animated: Bool = true, showSpringAnimation: Bool = false) {
        var animationDuration = 0.25
        if !animated {
            animationDuration = 0.0
        }
        
        if showSpringAnimation {
            UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.7, options: UIView.AnimationOptions.curveEaseOut, animations: {
                self.containerHeightConstraint?.constant = self.height(for: size)
                self.containerSize = size
                self.actualContainerSize = size
            }, completion: nil)
        }
        else {
            UIView.animate(withDuration: animationDuration, delay: 0.0, options: [.curveEaseOut], animations: {
                self.containerHeightConstraint?.constant = self.height(for: size)
                self.containerSize = size
                self.actualContainerSize = size
            })
        }
    }
    
    public func maximize(_ animated: Bool = true) {
        if let maxHeight = orderedSheetSizes.last {
            if state == "Half" {
                state = "Full"
                (childViewController.view as? KAFullPanelView)?.disableTouchesToAllSubviews = true
                resize(to: maxHeight, animated: animated)
            }
        }
    }
    
    public func minimize(_ animated: Bool = true) {
        if let minHeight = orderedSheetSizes.first {
            if state == "Full" {
                state = "Half"
                (childViewController.view as? KAFullPanelView)?.disableTouchesToAllSubviews = false
                resize(to: minHeight, animated: animated, showSpringAnimation: true)
            }
        }
    }
    
    private func updateLegacyRoundedCorners() {
        if #available(iOS 11.0, *) {
            childViewController.view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        } else {
            let path = UIBezierPath(roundedRect: childViewController.view.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 10, height: 10))
            let maskLayer = CAShapeLayer()
            maskLayer.path = path.cgPath
            childViewController.view.layer.mask = maskLayer
        }
    }
    
    private func setUpOverlay() {
        let overlay = UIView(frame: CGRect.zero)
        overlay.backgroundColor = overlayColor
        view.addSubview(overlay) { (subview) in
            subview.edges.pinToSuperview()
        }
    }
    
    private func setUpContainerView() {
        view.addSubview(containerView)

        containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        containerBottomConstraint = containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -inputViewHeight - 3)
        containerBottomConstraint.isActive = true
        
        containerHeightConstraint = containerView.heightAnchor.constraint(equalToConstant: height(for: containerSize))
        containerHeightConstraint.isActive = true
    }
    
    private func setUpChildViewController() {
        childViewController.willMove(toParent: self)
        addChild(childViewController)
        containerView.addSubview(childViewController.view) { (subview) in
            subview.edges(.left, .right).pinToSuperview()
            subview.bottom.pinToSuperview()
            subview.top.pinToSuperview()
        }
        
        childViewController.view.layer.masksToBounds = true
        
        childViewController.didMove(toParent: self)
    }
    
    @objc func tapAction(_ recognizer: UITapGestureRecognizer) {
        let maxHeight = height(for: orderedSheetSizes.last)
        let containerHeight = height(for: containerSize)
        var newSize = orderedSheetSizes.first
        if containerHeight == maxHeight {
            newSize = orderedSheetSizes.last
        }
        
        let animationDuration = 0.25
        UIView.animate(withDuration: animationDuration, delay: 0.0, options: [.curveEaseOut], animations: {
            self.containerView.transform = CGAffineTransform.identity
            self.containerHeightConstraint.constant = self.height(for: newSize)
            self.view.layoutIfNeeded()
        }, completion: { [weak self] (complete) in
            guard let weakSelf = self else {
                return
            }
            weakSelf.actualContainerSize = .fixed(weakSelf.containerView.frame.height)
        })
    }
    
    public func closeSheet(completion: (() -> Void)? = nil, _ showAnimation:Bool? = false) {
        var animate = false
        animate = showAnimation!
        var duration = 0.0
        if animate {
            duration = 0.3
        }
        
        if animate {
            UIView.animate(withDuration: 0.1) {
                self.colorView.alpha = 0
            }
        }
        UIView.animate(withDuration: duration) {
            self.view.alpha = 0.0
            self.colorView.transform = CGAffineTransform.init(translationX: 0.0, y: UIScreen.main.bounds.size.height)
        }
        dismiss(animated: animate, completion: completion)
    }
    
    @objc func panned(_ gesture: UIPanGestureRecognizer) {
        let point = gesture.translation(in: gesture.view?.superview)
        if gesture.state == .began {
            firstPanPoint = point
            actualContainerSize = .fixed(containerView.frame.height)
        }
        
        let minHeight = min(height(for: actualContainerSize), height(for: orderedSheetSizes.first))
        let maxHeight = max(height(for: actualContainerSize), height(for: orderedSheetSizes.last))
        
        var newHeight = max(0, height(for: actualContainerSize) + (firstPanPoint.y - point.y))
        var offset: CGFloat = 0
        if newHeight < minHeight {
            offset = minHeight - newHeight
            newHeight = minHeight
        }
        if newHeight > maxHeight {
            newHeight = maxHeight
        }
        
        switch gesture.state {
        case .cancelled, .failed:
            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut], animations: {
                self.containerView.transform = CGAffineTransform.identity
                self.containerHeightConstraint.constant = self.height(for: self.containerSize)
            }, completion: nil)
        case .ended:
            let velocity = (0.2 * gesture.velocity(in: view).y)
            var finalHeight = newHeight - offset - velocity
            if velocity > 500 {
                finalHeight = -1
            }
            
            let animationDuration = TimeInterval(abs(velocity*0.0002) + 0.2)
            var newSize = containerSize
            if point.y < 0 {
                newSize = orderedSheetSizes.last ?? containerSize
                for size in orderedSheetSizes.reversed() {
                    if finalHeight < height(for: size) {
                        newSize = size
                    } else {
                        break
                    }
                }
            } else {
                newSize = orderedSheetSizes.first ?? containerSize
                for size in orderedSheetSizes {
                    if finalHeight > height(for: size) {
                        newSize = size
                    } else {
                        break
                    }
                }
            }
            if gesture.velocity(in: view).y > 1000.0 && point.y > 200{
                newSize = orderedSheetSizes.first!
            }
            else if point.y > 200 {
                newSize = orderedSheetSizes.first!
            }
            else {
                newSize = orderedSheetSizes.last!
            }
            containerSize = newSize
            
            UIView.animate(withDuration: animationDuration, delay: 0, options: [.curveEaseOut], animations: {
                self.containerView.transform = CGAffineTransform.identity
                self.containerHeightConstraint.constant = self.height(for: newSize)
                self.view.layoutIfNeeded()
            }, completion: { [weak self] complete in
                guard let self = self else { return }
                self.actualContainerSize = .fixed(self.containerView.frame.height)
            })
        default:
            if newHeight > minHeight {
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
    }
    
    private func height(for size: SheetSize?) -> CGFloat {
        guard let size = size else {
            return 0
        }
        switch (size) {
            case .fixed(let height):
                return height
            case .fullScreen:
                let insets = safeAreaInsets
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
        guard let panGestureRecognizer = gestureRecognizer as? InitialTouchPanGestureRecognizer, let childScrollView = childScrollView, let point = panGestureRecognizer.initialTouchLocation else { return true }
        
        let pointInChildScrollView = view.convert(point, to: childScrollView).y - childScrollView.contentOffset.y
        
        let velocity = panGestureRecognizer.velocity(in: panGestureRecognizer.view?.superview)
        guard pointInChildScrollView > 0, pointInChildScrollView < childScrollView.bounds.height else {
            return true
        }
        
        guard abs(velocity.y) > abs(velocity.x), childScrollView.contentOffset.y == 0 else { return false }
        
        if velocity.y < 0 {
            let containerHeight = height(for: containerSize)
            return height(for: orderedSheetSizes.last) > containerHeight && containerHeight < height(for: SheetSize.fullScreen)
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
