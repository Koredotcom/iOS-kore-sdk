//
//  KRESlideMenuViewController.swift
//  KoreApp
//
//  Created by Srinivas Vasadi on 01/12/18.
//  Copyright © 2018 Kore Inc. All rights reserved.
//

import UIKit

// MARK: - KREPercentDrivenInteractiveTransition
public class KREPercentDrivenInteractiveTransition: UIPercentDrivenInteractiveTransition {
    var hasStarted = false
    var shouldFinish = false
}

// MARK: -
public struct KRESlideMenuHelper {
    // MARK: -
    static let menuWidth: CGFloat = 0.75
    static let percentThreshold: CGFloat = 0.3
    
    // MARK: -
    public static func calculateProgress(_ translationInView: CGPoint, viewBounds: CGRect, direction: KRESlideMenuDirection) -> CGFloat {
        let pointOnAxis: CGFloat
        let axisLength: CGFloat
        switch direction {
        case .up, .down:
            pointOnAxis = translationInView.y
            axisLength = viewBounds.height
        case .left, .right:
            pointOnAxis = translationInView.x
            axisLength = viewBounds.width
        }
        let movementOnAxis = pointOnAxis / axisLength
        let positiveMovementOnAxis:Float
        let positiveMovementOnAxisPercent:Float
        switch direction {
        case .right, .down: // positive
            positiveMovementOnAxis = fmaxf(Float(movementOnAxis), 0.0)
            positiveMovementOnAxisPercent = fminf(positiveMovementOnAxis, 1.0)
            return CGFloat(positiveMovementOnAxisPercent)
        case .up, .left: // negative
            positiveMovementOnAxis = fminf(Float(movementOnAxis), 0.0)
            positiveMovementOnAxisPercent = fmaxf(positiveMovementOnAxis, -1.0)
            return CGFloat(-positiveMovementOnAxisPercent)
        }
    }
    
    public static func mapGestureStateToInteractor(_ gestureState: UIGestureRecognizer.State, progress: CGFloat, interactiveTransition: KREPercentDrivenInteractiveTransition?, triggerSegue: () -> ()) {
        guard let interactiveTransition = interactiveTransition else {
            return
        }
        switch gestureState {
        case .began:
            interactiveTransition.hasStarted = true
            triggerSegue()
        case .changed:
            interactiveTransition.shouldFinish = progress > percentThreshold
            interactiveTransition.update(progress)
        case .cancelled:
            interactiveTransition.hasStarted = false
            interactiveTransition.cancel()
        case .ended:
            interactiveTransition.hasStarted = false
            interactiveTransition.shouldFinish ? interactiveTransition.finish() : interactiveTransition.cancel()
        default:
            break
        }
    }
}

// MARK: - KRESlideMenuDirection
public enum KRESlideMenuDirection {
    case up, down, left, right
}

// MARK: - KRESlideMenuViewController
open class KRESlideMenuViewController: UIViewController {
    // MARK: - properties
    public lazy var backdropView: UIView = {
        let backdropView = UIView(frame: self.view.bounds)
        backdropView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        return backdropView
    }()
    public lazy var containerView: UIView = {
        let containerView = UIView(frame: .zero)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .clear
        return containerView
    }()
    
    public lazy var pullBarView: UIView = {
        let pullBarView = UIView(frame: .zero)
        pullBarView.translatesAutoresizingMaskIntoConstraints = false
        return pullBarView
    }()
    
    public lazy var handleView: UIView = {
        let handleView = UIView(frame: .zero)
        handleView.translatesAutoresizingMaskIntoConstraints = false
        return handleView
    }()
    
    var containerViewHeightConstraint: NSLayoutConstraint?
    
    public var handleColor: UIColor = UIColor.lightGreyBlue {
        didSet {
            handleView.backgroundColor = handleColor
        }
    }
    
    public var menuSize = UIScreen.main.bounds.width * 3 / 4
    
    public var leftViewController: UIViewController? {
        didSet {
            menuDirection = .left
        }
    }
    public var rightViewController: UIViewController? {
        didSet {
            menuDirection = .right
        }
    }
    public var upViewController: UIViewController? {
        didSet {
            menuDirection = .up
        }
    }
    public var downViewController: UIViewController? {
        didSet {
            menuDirection = .down
        }
    }

    public var isPresenting = false
    public var menuDirection: KRESlideMenuDirection = .left
    public var interactiveTransition: KREPercentDrivenInteractiveTransition? = nil
    public var showPullBarHandler: Bool?
    
    // MARK: - init
    public init() {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .custom
        transitioningDelegate = self
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // MARK: -
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleProfileTableViewUpdate(_:)), name: NSNotification.Name(rawValue:"ProfileTableViewContentUpdate"), object: nil)
        
        view.backgroundColor = .clear
        view.addSubview(backdropView)
        view.addSubview(containerView)
        
        switch menuDirection {
        case .left:
            containerView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            containerView.widthAnchor.constraint(equalToConstant: menuSize).isActive = true
            if let leftViewController = leftViewController {
                add(asChildViewController: leftViewController)
            }
        case .right:
            containerView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
            containerView.widthAnchor.constraint(equalToConstant: menuSize).isActive = true
            if let rightViewController = rightViewController {
                add(asChildViewController: rightViewController)
            }
        case .up:
            containerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            containerView.heightAnchor.constraint(equalToConstant: menuSize).isActive = true
            if let upViewController = upViewController {
                add(asChildViewController: upViewController)
            }
        case .down:
            menuSize = 435
            if let downViewController = downViewController {
                add(asChildViewController: downViewController)
            }
            containerViewHeightConstraint = containerView.heightAnchor.constraint(equalToConstant: menuSize)
            containerViewHeightConstraint?.isActive = true
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            containerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        default:
            break
        }
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        backdropView.addGestureRecognizer(tapGestureRecognizer)
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        view.addGestureRecognizer(panGestureRecognizer)
    }
    
    @objc func handleProfileTableViewUpdate(_ notification:Notification) {
        if let object = notification.object as? [String:CGSize]{
            var inserts = UIEdgeInsets.zero
            if #available(iOS 11.0, *) {
                inserts = UIApplication.shared.keyWindow?.safeAreaInsets ?? inserts
            }
            if let size = object["contentSize"] as? CGSize {
                let contentHeight = size.height + inserts.bottom
                containerViewHeightConstraint?.constant = contentHeight
            }
        }
    }
    
    @objc func handleTapGesture(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func handlePanGesture(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
        
        let progress = KRESlideMenuHelper.calculateProgress(translation, viewBounds: view.bounds, direction: .left)
        KRESlideMenuHelper.mapGestureStateToInteractor(sender.state, progress: progress, interactiveTransition: interactiveTransition) {
//            self.dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: -
    private func add(asChildViewController viewController: UIViewController) {
        addChild(viewController)
        containerView.addSubview(viewController.view)
        viewController.view.frame = containerView.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        viewController.didMove(toParent: self)
    }
    
    private func remove(asChildViewController viewController: UIViewController) {
        viewController.willMove(toParent: nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParent()
    }
    
    public func dismissInputView() {
        dismiss(animated: true, completion: nil)
    }
}

extension KRESlideMenuViewController: UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning {
    // MARK: -
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    // MARK: -
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.25
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        switch menuDirection {
        case .left:
            animateLeftViewTransition(using: transitionContext)
        case .right:
            animateRightViewTransition(using: transitionContext)
        case .up:
            animateUpViewTransition(using: transitionContext)
        case .down:
            animateDownViewTransition(using: transitionContext)
        default:
            break
        }
    }
    
    // MARK: -
    func animateLeftViewTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
        guard let toVC = toViewController else {
            return
        }
        isPresenting = !isPresenting
        
        if isPresenting == true {
            containerView.addSubview(toVC.view)
            
            containerView.frame.origin.x = 0
            backdropView.alpha = 0
            
            UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut], animations: {
                self.containerView.frame.origin.x += self.menuSize
                self.backdropView.alpha = 1
            }, completion: { (finished) in
                transitionContext.completeTransition(true)
            })
        } else {
            UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut], animations: {
                self.containerView.frame.origin.x -= self.menuSize
                self.backdropView.alpha = 0
            }, completion: { (finished) in
                transitionContext.completeTransition(true)
            })
        }
    }
    
    func animateRightViewTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
        guard let toVC = toViewController else {
            return
        }
        isPresenting = !isPresenting
        
        if isPresenting == true {
            containerView.addSubview(toVC.view)
            
            containerView.frame.origin.x = 0
            backdropView.alpha = 0
            
            UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut], animations: {
                self.containerView.frame.origin.x -= self.menuSize
                self.backdropView.alpha = 1
            }, completion: { (finished) in
                transitionContext.completeTransition(true)
            })
        } else {
            UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut], animations: {
                self.containerView.frame.origin.x += self.menuSize
                self.backdropView.alpha = 0
            }, completion: { (finished) in
                transitionContext.completeTransition(true)
            })
        }
    }
    
    func animateUpViewTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
        guard let toVC = toViewController else {
            return
        }
        isPresenting = !isPresenting
        
        if isPresenting == true {
            containerView.addSubview(toVC.view)
            
            containerView.frame.origin.y = view.bounds.height
            backdropView.alpha = 0
            
            UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut], animations: {
                self.containerView.frame.origin.y -= self.menuSize
                self.backdropView.alpha = 1
            }, completion: { (finished) in
                transitionContext.completeTransition(true)
            })
        } else {
            UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut], animations: {
                self.containerView.frame.origin.y -= self.menuSize
                self.backdropView.alpha = 0
            }, completion: { (finished) in
                transitionContext.completeTransition(true)
            })
        }
    }
    
    func animateDownViewTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
        guard let toVC = toViewController else {
            return
        }
        isPresenting = !isPresenting
        
        if isPresenting == true {
            containerView.addSubview(toVC.view)
            
            containerView.frame.origin.y = 0
            backdropView.alpha = 0
            
            UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut], animations: {
                self.containerView.frame.origin.y -= self.menuSize
                self.backdropView.alpha = 1
            }, completion: { (finished) in
                transitionContext.completeTransition(true)
            })
        } else {
            UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut], animations: {
                self.containerView.frame.origin.y += self.menuSize
                self.backdropView.alpha = 0
            }, completion: { (finished) in
                transitionContext.completeTransition(true)
            })
        }
    }
}
