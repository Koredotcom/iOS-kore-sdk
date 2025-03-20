//
//  KRETypingStatusView.swift
//  KoraApp
//
//  Created by Srinivas Vasadi on 06/01/19.
//  Copyright © 2017 Kore Inc. All rights reserved.
//

import UIKit

open class KRETypingStatusView: UIView {
    // MARK: - properties
    let bundle = Bundle.sdkModule
    var typingImageView: UIImageView = {
        let typingImageView = UIImageView(frame: .zero)
        typingImageView.backgroundColor = UIColor.clear
        typingImageView.layer.masksToBounds = true
        typingImageView.contentMode = .scaleAspectFill
        typingImageView.translatesAutoresizingMaskIntoConstraints = false
        typingImageView.clipsToBounds = true
        typingImageView.layer.cornerRadius = 0.0//15.0
        return typingImageView
    }()
    var dancingDots: KRETypingActivityIndicator = {
        let dancingDots = KRETypingActivityIndicator(frame: .zero)
        dancingDots.translatesAutoresizingMaskIntoConstraints = false
        dancingDots.dotSize = 4.5
        return dancingDots
    }()
    
    // MARK: - init
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    // MARK: -
    func setup() {
        backgroundColor = UIColor.clear
        
        let image = UIImage(named: "kora", in: bundle, compatibleWith: nil)?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        typingImageView.image = image
        addSubview(typingImageView)
        addSubview(dancingDots)
        
        let views: [String: Any] = ["typingImageView": typingImageView, "dancingDots": dancingDots]
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[typingImageView]-2-[dancingDots(30)]-|", options: [], metrics: nil, views: views))
        typingImageView.widthAnchor.constraint(equalToConstant: 30.0).isActive = true
        typingImageView.heightAnchor.constraint(equalToConstant: 30.0).isActive = true
        typingImageView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 0.0).isActive = true
        dancingDots.heightAnchor.constraint(equalToConstant: 12.0).isActive = true
        dancingDots.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 0.0).isActive = true
    }
    
    override open var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: 32.0)
    }
    
    // MARK: -
    func startTypingStatus(using urlString: String? = nil, dotColor: UIColor = .lightRoyalBlue) {
        let image = UIImage(named: "kore", in: bundle, compatibleWith: nil)?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        if let urlString = urlString, let url = URL(string: urlString) {
            typingImageView.af.setImage(withURL: url, placeholderImage: image)
        } else {
            typingImageView.image = image
        }
        dancingDots.dotColor = dotColor
        dancingDots.startAnimation()
        isHidden = false
    }
    
    @objc func stopTypingStatus() {
        dancingDots.stopAnimation()
        isHidden = true
    }
    
    // MARK: - deinit
    deinit {

    }
}

// MARK: - KRETypingActivityIndicator
class KRETypingActivityIndicator: UIView {
    // MARK: - properties
    let kMaxDots: Int = 3
    let kMinAnimationValue: CGFloat = -3.0
    let kMaxAnimationValue: CGFloat = 3.0
    let kDelay: CGFloat = 0.2
    let kDuration: CGFloat = 1.0
    let kAnimationSpeed: CGFloat = 3.0
    let kSpacingMultiplier: CGFloat = 1.5
    var dotSize: CGFloat = 0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    var dotColor = UIColor.lightRoyalBlue {
        didSet {
            setup()
        }
    }
    
    // MARK: - init
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override func layoutSubviews() {
        guard let sublayers = layer.sublayers else {
            return
        }
        
        var xPosition: CGFloat = kSpacingMultiplier * dotSize
        for layer in sublayers {
            layer.position = CGPoint(x: xPosition, y: (bounds.size.height - dotSize)/2.0)
            layer.bounds = CGRect(x: xPosition, y: (bounds.size.height - dotSize)/2.0, width: dotSize, height: dotSize)
            layer.cornerRadius = dotSize/2.0
            xPosition += kSpacingMultiplier * dotSize
        }
    }
    
    // MARK: -
    func setup() {
        for sublayer in layer.sublayers ?? [] {
            sublayer.removeFromSuperlayer()
        }

        for _ in 0..<kMaxDots {
            let nLayer = CALayer()
            nLayer.contentsScale = UIScreen.main.scale
            nLayer.backgroundColor = dotColor.cgColor
            layer.addSublayer(nLayer)
        }
        clipsToBounds = true
    }
    
    func startAnimation() {
        guard let sublayers = layer.sublayers else {
            return
        }
        
        var counter: Int = 0
        if sublayers.count > 0, let _ = sublayers.first?.animationKeys {
            for layer in sublayers {
                let animation = CAKeyframeAnimation(keyPath: "position.y")
                animation.duration = CFTimeInterval(kDuration)
                animation.speed = Float(kAnimationSpeed)
                animation.values = [dotSize + kMaxAnimationValue, dotSize + kMinAnimationValue]
                animation.timingFunction = CAMediaTimingFunction(name: .linear)
                animation.autoreverses = true
                animation.repeatCount = .infinity
                animation.fillMode = .forwards
                animation.beginTime = CACurrentMediaTime() + Double(kDelay * CGFloat(counter))
                layer.add(animation, forKey: "position.y")
                counter = counter + 1
            }
        }
    }
    
    func stopAnimation() {
        guard let sublayers = layer.sublayers else {
            return
        }
        
        sublayers.forEach { $0.removeAllAnimations() }
    }
}
