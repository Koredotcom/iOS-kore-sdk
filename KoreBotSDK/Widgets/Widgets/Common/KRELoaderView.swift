//
//  KRELoaderView.swift
//  KoreBotSDK
//
//  Created by Srinivas Vasadi on 04/06/19.
//  Copyright © 2019 Srinivas Vasadi. All rights reserved.
//

import UIKit
import QuartzCore

open class KRELoaderView: UIView {
    override open var tintColor: UIColor? {
        didSet {
            activityIndicatorLayer.strokeColor = tintColor?.cgColor
        }
    }
    @objc open var lineWidth: CGFloat = 1.0 {
        didSet {
            activityIndicatorLayer.lineWidth = lineWidth
        }
    }
    open var interactiveView = [UIView]()
    fileprivate var activityIndicatorLayer = CAShapeLayer()
    fileprivate var strokeEndAnimation = CAAnimationGroup()
    fileprivate var strokeStartAnimation = CAAnimationGroup()
    fileprivate var rotationAnimation = CAAnimation()
    fileprivate var animating: Bool = false
    
    // MARK: - init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        activityIndicatorLayer = CAShapeLayer()
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        activityIndicatorLayer = CAShapeLayer()
        setup()
    }
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        
        activityIndicatorLayer = CAShapeLayer()
        setup()
    }
    
    override open func layoutSubviews() {
        let center = CGPoint(x: (bounds.origin.x + bounds.size.width) / 2.0, y: (bounds.origin.y + bounds.size.height) / 2.0)
        let radius = min(bounds.size.width, bounds.size.height) / 2.0 - activityIndicatorLayer.lineWidth / 2.0
        let startAngle = -Double.pi / 2
        let endAngle = startAngle + (.pi * 2)
        let path = UIBezierPath(arcCenter: .zero, radius: radius, startAngle: CGFloat(startAngle), endAngle: CGFloat(endAngle), clockwise: true)
        activityIndicatorLayer.position = center
        activityIndicatorLayer.path = path.cgPath
    }
    
    // MARK: -
    func setup() {
        backgroundColor = UIColor.clear
        activityIndicatorLayer.lineWidth = 4.0
        activityIndicatorLayer.fillColor = nil
        layer.addSublayer(activityIndicatorLayer)
        
        updateAnimations()
    }
    
    @objc public func startAnimation() {
        animating = true
        activityIndicatorLayer.add(strokeStartAnimation, forKey: "strokeStart")
        activityIndicatorLayer.add(strokeEndAnimation, forKey: "strokeEnd")
        activityIndicatorLayer.add(rotationAnimation, forKey: "rotation")
        activityIndicatorLayer.setCurrentAnimationsPersistent()
    }
    
    @objc public func stopAnimation() {
        animating = false
        activityIndicatorLayer.removeAnimation(forKey: "strokeStart")
        activityIndicatorLayer.removeAnimation(forKey: "strokeEnd")
        activityIndicatorLayer.removeAnimation(forKey: "rotation")
    }
    
    @objc public func isAnimating() -> Bool {
        return animating
    }
    
    func updateAnimations() {
        // Stroke start
        let startAnimation = CABasicAnimation(keyPath: "strokeStart")
        startAnimation.beginTime = 0.5
        startAnimation.fromValue = 0
        startAnimation.toValue = 1
        startAnimation.duration = 1
        startAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        let startGroup = CAAnimationGroup()
        startGroup.duration = 1.5
        startGroup.repeatCount = .infinity
        startGroup.animations = [startAnimation]
        strokeStartAnimation = startGroup
        
        // Stroke end
        let endAnimation = CABasicAnimation(keyPath: "strokeEnd")
        endAnimation.fromValue = 0
        endAnimation.toValue = 1
        endAnimation.duration = 1
        endAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        let endGroup = CAAnimationGroup()
        endGroup.duration = 1.5
        endGroup.repeatCount = .infinity
        endGroup.animations = [endAnimation]
        strokeEndAnimation = endGroup
        
        // Rotation animation
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.fromValue = 0
        rotationAnimation.toValue = Double.pi * 2
        rotationAnimation.duration = 1.5
        rotationAnimation.repeatCount = .infinity
        self.rotationAnimation = rotationAnimation
    }
    
    // MARK: - deinit
    deinit {
        stopAnimation()
        activityIndicatorLayer.removeFromSuperlayer()
        tintColor = nil
    }
}

// MARK: -
var KREPersistentAnimationContainerHandle: UInt8 = 1

extension CALayer {
    func KRE_persistentAnimationKeys() -> [String]? {
        return kreAnimationContainer?.persistentAnimationKeys
    }
    
    var krePersistentAnimationKeys: [String]? {
        get {
            return nil
        }
        set(persistentAnimationKeys) {
            var container = kreAnimationContainer
            if container == nil {
                container = KREPersistentAnimationContainer(layer: self)
                kreAnimationContainer = container
            }
            container?.persistentAnimationKeys = persistentAnimationKeys
        }
    }
    
    func setCurrentAnimationsPersistent() {
        krePersistentAnimationKeys = animationKeys()
    }
    
    var kreAnimationContainer: KREPersistentAnimationContainer? {
        get {
            return objc_getAssociatedObject(self, &KREPersistentAnimationContainerHandle) as? KREPersistentAnimationContainer
        }
        
        set {
            objc_setAssociatedObject(self, &KREPersistentAnimationContainerHandle, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    // MARK: - pause and resume
    func KRE_pauseLayer() {
        let pausedTime:CFTimeInterval = convertTime(CACurrentMediaTime(), from: nil)
        speed = 0.0
        timeOffset = pausedTime
    }
    
    func KRE_resumeLayer() {
        let pausedTime:CFTimeInterval = timeOffset
        speed = 1.0
        timeOffset = 0.0
        beginTime = 0.0
        
        let timeSincePause = convertTime(CACurrentMediaTime(), from: nil) - pausedTime
        beginTime = timeSincePause
    }
}

// MARK: - KREPersistentAnimationContainer
class KREPersistentAnimationContainer: NSObject {
    // MARK: - properties
    var layer: CALayer?
    var persistentAnimationKeys: [String]? {
        didSet(newAnimationKeys) {
            if newAnimationKeys != persistentAnimationKeys {
                if persistentAnimationKeys == nil {
                    registerForAppStateNotifications()
                } else if newAnimationKeys == nil {
                    unregisterFromAppStateNotifications()
                }
            }
        }
    }
    var persistedAnimations: [String: Any]?
    
    // MARK: -
    init(layer: CALayer?) {
        super.init()
        self.layer = layer
    }
    
    deinit {
        unregisterFromAppStateNotifications()
    }
    
    // MARK: - Persistence
    func persistLayerAnimationsAndPause() {
        if (layer == nil) {
            return
        }
        var animations = [String: Any]()
        for key in persistentAnimationKeys ?? [] {
            if let animation = layer?.animation(forKey: key) {
                animations[key] = animation
            }
        }
        if animations.count > 0 {
            persistedAnimations = animations
            layer?.KRE_pauseLayer()
        }
    }
    
    func restoreLayerAnimationsAndResume() {
        if layer == nil {
            return
        }
        
        if let animations = persistedAnimations {
            for (key, value) in animations {
                if let animation = value as? CAAnimation {
                    layer?.add(animation, forKey: key)
                }
            }
        }
        
        if persistedAnimations?.count ?? 0 > 0 {
            layer?.KRE_resumeLayer()
        }
        persistedAnimations = nil
    }
    
    // MARK: - Notifications
    func registerForAppStateNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object:nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object:nil)
    }
    
    func unregisterFromAppStateNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func applicationDidEnterBackground() {
        persistLayerAnimationsAndPause()
    }
    
    @objc func applicationWillEnterForeground() {
        restoreLayerAnimationsAndResume()
    }
}

// MARK: - KRELinearProgressBar
public class KRELinearProgressBar: UIView {
    // MARK: - properties
    public var progressBarColor = UIColor.lightRoyalBlue
    let animationLayer = CALayer()
    var isLoading: Bool = false {
        didSet {
            if isLoading {
                startAnimation()
            } else {
                stopAnimation()
            }
        }
    }
    
    // MARK: - start/stop animation
    func startAnimation() {
        let width = UIScreen.main.bounds.width * 0.7
        let animationDuration = TimeInterval(1.0)
        animationLayer.frame = CGRect(x: 0.0, y: 0.0, width: width, height: bounds.height)
        animationLayer.backgroundColor = progressBarColor.cgColor
        animationLayer.masksToBounds = true
        layer.addSublayer(animationLayer)

        let xPositionAnimation = CABasicAnimation(keyPath: "position.x")
        xPositionAnimation.duration = animationDuration
        xPositionAnimation.fromValue = -width
        xPositionAnimation.toValue = bounds.width
        xPositionAnimation.timingFunction = CAMediaTimingFunction(name: .easeIn)
        xPositionAnimation.fillMode = .forwards
        xPositionAnimation.repeatCount = .infinity
        xPositionAnimation.autoreverses = false
        animationLayer.add(xPositionAnimation, forKey: "basic")
    }
    
    func stopAnimation() {
        animationLayer.removeAllAnimations()
    }
}
