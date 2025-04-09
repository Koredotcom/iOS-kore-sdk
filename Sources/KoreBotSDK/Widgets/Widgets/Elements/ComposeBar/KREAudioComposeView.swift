//
//  KREAudioComposeView.swift
//  KoraApp
//
//  Created by Anoop Dhiman on 06/12/17.
//  Copyright © 2017 Kore. All rights reserved.
//

import UIKit
import AVFoundation
import QuartzCore
import SpriteKit

public protocol KREAudioComposeViewDelegate {
    func audioBarView(_: KREAudioComposeView, indexPath: IndexPath)
    
}

open class KREAudioComposeView: UIView {
    // MARK: -
    let bundle = Bundle.sdkModule
    let mScaleFactor: CGFloat = 1.0
    public var isActive = false
    public lazy var containerView: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    public lazy var leftWidgetBtn = UIButton(frame: .zero)
    public lazy var rightWidgetBtn = UIButton(frame: .zero)
    public lazy var thunderBoltActionButton = KREAudioView(frame: .zero)
    public lazy var audioView = UIButton(frame: .zero)
    public lazy var inputContainerView = UIView(frame: .zero)
    public lazy var keyboardButton = UIButton(frame: CGRect.zero)
    public lazy var audioButton = KREAudioView(frame: .zero)

    fileprivate var animateBGViewWidthConstraint: NSLayoutConstraint!
    fileprivate var animationTimer: Timer!
    fileprivate var audioPeakOutput: Float = 0.3
    fileprivate var waveRadius: Float = 25
    
    public var getAudioPeakOutputPower: (() -> (CGFloat))?
    public var voiceRecordingStarted: ((_ composeView: KREAudioComposeView?) -> Void)?
    public var voiceRecordingStopped: ((_ composeView: KREAudioComposeView?) -> Void)?
    public var onKeyboardButtonAction: (() -> Void)?
    public var onHelpButtonAction: (() -> Void)?
    public var onRightWidgetButtonAction: (() -> Void)?
    public var onLeftWidgetButtonAction: (() -> Void)?
    public var onContainertTapAction: (() -> Void)?
    
    var containerViewHeightConstraint: NSLayoutConstraint!
    open var swipeHandler:((_ isRecording: Bool) -> ())?
    
    // MARK: - init
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    // MARK: -
    func setupViews() {
        backgroundColor = .white

        var shawdowLine = UIView.init(frame: .zero)
        addSubview(shawdowLine)

        shawdowLine.backgroundColor = UIColor.init(red: CGFloat(237.0/255.0), green: CGFloat(237.0/255.0), blue: CGFloat(239.0/255.0), alpha: 1.0)
        shawdowLine.layer.masksToBounds = false
        shawdowLine.layer.shadowOpacity = 0.3
        shawdowLine.layer.shadowColor = UIColor.init(red: CGFloat(237.0/255.0), green: CGFloat(237.0/255.0), blue: CGFloat(239.0/255.0), alpha: 1.0).cgColor
        shawdowLine.layer.shadowOffset = CGSize(width: 0.7, height: 0.7)
        shawdowLine.translatesAutoresizingMaskIntoConstraints = false
        shawdowLine.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        shawdowLine.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        shawdowLine.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        shawdowLine.heightAnchor.constraint(equalToConstant: 1.0).isActive = true
        
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 27.5
        containerView.layer.masksToBounds = false
        containerView.layer.borderColor = UIColor.lightGreyBlue.cgColor
        containerView.layer.borderWidth = 2.0
        addSubview(containerView)
        
        inputContainerView.backgroundColor = .white
        inputContainerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(inputContainerView)

        leftWidgetBtn.setTitle("", for: .normal)
        let leftImage = UIImage(named: "widget", in: bundle, compatibleWith: nil)
        let leftWidgetImage = leftImage?.withRenderingMode(.alwaysTemplate)
        leftWidgetBtn.setImage(leftWidgetImage, for: .normal)
        leftWidgetBtn.imageView?.tintColor = UIColor.lightGreyBlue
        leftWidgetBtn.imageView?.contentMode = .scaleAspectFit
        leftWidgetBtn.translatesAutoresizingMaskIntoConstraints = false
        leftWidgetBtn.addTarget(self, action: #selector(leftWidgetButtonAction), for: .touchUpInside)
        addSubview(leftWidgetBtn)
        
        leftWidgetBtn.backgroundColor = .white
        leftWidgetBtn.layer.cornerRadius = 36/2
        leftWidgetBtn.layer.masksToBounds = false
        leftWidgetBtn.layer.borderColor  = UIColor.lightGreyBlue.cgColor
        leftWidgetBtn.layer.borderWidth = 2
        leftWidgetBtn.layer.shadowOffset = .zero
        leftWidgetBtn.imageEdgeInsets = UIEdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 8.0)
        addSubview(leftWidgetBtn)
        
        rightWidgetBtn.setTitle("", for: .normal)
        let rightImage = UIImage(named: "knowledge", in: bundle, compatibleWith: nil)
        let rightWidgetImage = rightImage?.withRenderingMode(.alwaysTemplate)
        rightWidgetBtn.setImage(rightWidgetImage, for: .normal)
        rightWidgetBtn.imageView?.contentMode = .scaleAspectFit
        rightWidgetBtn.translatesAutoresizingMaskIntoConstraints = false
        rightWidgetBtn.addTarget(self, action: #selector(rightWidgetButtonAction), for: .touchUpInside)
        rightWidgetBtn.backgroundColor = .white
        rightWidgetBtn.layer.cornerRadius = 36/2
        rightWidgetBtn.layer.masksToBounds = false
        rightWidgetBtn.imageView?.tintColor = UIColor.lightGreyBlue
        rightWidgetBtn.layer.borderColor  = UIColor.lightGreyBlue.cgColor
        rightWidgetBtn.layer.borderWidth = 1
        rightWidgetBtn.layer.shadowOffset = .zero
        rightWidgetBtn.imageEdgeInsets = UIEdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 8.0)
        addSubview(rightWidgetBtn)
        
        audioView.setTitle("", for: .normal)
        let audioImage = UIImage(named: "audio_icon", in: bundle, compatibleWith: nil)
        let audioViewmage = audioImage?.withRenderingMode(.alwaysTemplate)
        audioView.setImage(audioViewmage, for: .normal)
        audioView.imageView?.contentMode = .scaleAspectFit
        audioView.translatesAutoresizingMaskIntoConstraints = false
        audioView.imageView?.tintColor = UIColor.lightGreyBlue
        audioView.backgroundColor = .clear
        audioView.imageEdgeInsets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
        audioView.addTarget(self, action: #selector(audioButtonAction), for: .touchUpInside)
        audioView.clipsToBounds = true
        inputContainerView.addSubview(audioView)
        
        let image = UIImage(named: "microphone", in: bundle, compatibleWith: nil)
        audioButton.setTitle("", for: .normal)
        audioButton.translatesAutoresizingMaskIntoConstraints = false
        audioButton.addTarget(self, action: #selector(audioButtonAction), for: .touchUpInside)
        audioButton.clipsToBounds = true
        audioButton.isHidden = true
        audioButton.backgroundColor = UIColor.clear
        audioButton.setImage(image, for: .normal)
        audioButton.layer.cornerRadius = 2.5
        containerView.addSubview(audioButton)
        
        let thunderImage = UIImage(named: "thunderbolt", in: bundle, compatibleWith: nil)
        thunderBoltActionButton.setTitle("", for: .normal)
        thunderBoltActionButton.translatesAutoresizingMaskIntoConstraints = false
        thunderBoltActionButton.addTarget(self, action: #selector(actionButtonAction), for: .touchUpInside)
        thunderBoltActionButton.clipsToBounds = true
        thunderBoltActionButton.isHidden = false
        thunderBoltActionButton.backgroundColor = UIColor.clear
        let thunderBoltImage = thunderImage?.withRenderingMode(.alwaysTemplate)
        thunderBoltActionButton.setImage(thunderBoltImage, for: .normal)
        thunderBoltActionButton.imageView?.tintColor = UIColor.lightGreyBlue
        thunderBoltActionButton.layer.cornerRadius = 2.5
        containerView.addSubview(thunderBoltActionButton)
        
        keyboardButton.setTitle("", for: .normal)
        keyboardButton.backgroundColor = .clear
        keyboardButton.translatesAutoresizingMaskIntoConstraints = false
        let keyboardImage = UIImage(named: "keyboard", in: Bundle.sdkModule, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        keyboardButton.setImage(keyboardImage, for: .normal)
        keyboardButton.imageView?.tintColor = UIColor.lightGreyBlue
        keyboardButton.imageView?.contentMode = .scaleAspectFit
        keyboardButton.addTarget(self, action: #selector(keyboardButtonAction), for: .touchUpInside)
        keyboardButton.imageEdgeInsets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
        keyboardButton.clipsToBounds = true
        inputContainerView.addSubview(keyboardButton)
        containerView.addSubview(inputContainerView)

        inputContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[keyboardButton(44)]|", options:[], metrics:nil, views: ["keyboardButton": keyboardButton]))
        inputContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[keyboardButton(44)]", options:[], metrics:nil, views: ["keyboardButton": keyboardButton]))
        inputContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[audioView(44)]", options:[], metrics:nil, views: ["audioView": audioView]))
        inputContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[audioView(44)]", options:[], metrics:nil, views: ["audioView": audioView]))
        inputContainerView.addConstraint(NSLayoutConstraint(item: keyboardButton, attribute: .centerY, relatedBy: .equal, toItem: inputContainerView, attribute: .centerY, multiplier: 1.0, constant: 0.0))

        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[thunderBoltActionButton(44)]", options:[], metrics:nil, views: ["thunderBoltActionButton": thunderBoltActionButton]))
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[inputContainerView(44)]", options:[], metrics:nil, views: ["inputContainerView": inputContainerView]))
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-11-[thunderBoltActionButton(44)]-[inputContainerView]-11-|", options:[], metrics:nil, views: ["thunderBoltActionButton": thunderBoltActionButton, "inputContainerView": inputContainerView]))
        containerView.addConstraint(NSLayoutConstraint(item: thunderBoltActionButton, attribute: .centerY, relatedBy: .equal, toItem: containerView, attribute: .centerY, multiplier: 1.0, constant: 0.0))
        containerView.addConstraint(NSLayoutConstraint(item: inputContainerView, attribute: .centerY, relatedBy: .equal, toItem: containerView, attribute: .centerY, multiplier: 1.0, constant: 0.0))

        let views: [String : Any] = ["containerView": containerView, "leftWidgetBtn": leftWidgetBtn, "rightWidgetBtn": rightWidgetBtn]
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[containerView(173)]", options:[], metrics:nil, views:views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[containerView]", options:[], metrics:nil, views:views))
        addConstraint(NSLayoutConstraint(item: containerView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0))
        addConstraint(NSLayoutConstraint(item: containerView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: -12.0))
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-21-[leftWidgetBtn(36)]", options:[], metrics:nil, views:views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[leftWidgetBtn(36)]", options:[], metrics:nil, views:views))
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[rightWidgetBtn(36)]-21-|", options:[], metrics:nil, views:views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[rightWidgetBtn(36)]", options:[], metrics:nil, views:views))
        addConstraint(NSLayoutConstraint(item: leftWidgetBtn, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: -5.0))
        addConstraint(NSLayoutConstraint(item: rightWidgetBtn, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: -5.0))
        
        containerViewHeightConstraint = NSLayoutConstraint(item: containerView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 54.0)
        addConstraint(containerViewHeightConstraint)
        containerViewHeightConstraint.isActive = true
        
        audioButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        audioButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        audioButton.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        audioButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true

    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override open var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: 54.0)
    }

    public func startRecording() {
        if !isActive {
            audioButtonAction()
        }
    }
    
    public func stopRecording() {
        if isActive {
            audioButtonAction()
        }
    }

    // MARK:- removing refernces to elements
    public func prepareForDeinit() {
        if animationTimer != nil {
            animationTimer.invalidate()
            animationTimer = nil
        }
       
        voiceRecordingStarted = nil
        voiceRecordingStopped = nil
        getAudioPeakOutputPower = nil
    }
    
    // MARK:- deinit
    deinit {
        animationTimer = nil
        animationTimer = nil
    }
    
    // MARK: - button actions
    @objc fileprivate func audioButtonAction() {
        if !self.isActive {
            KREASRService.shared.checkAudioRecordPermission({ [weak self] in
                self?.isActive = true
                self?.startAudioRecording()
                self?.swipeHandler?(true)
            })
        } else {
            isActive = false
            stopAudioRecording()
            self.swipeHandler?(false)
        }
    }
    
    @objc fileprivate func actionButtonAction() {
        onHelpButtonAction?()
    }
    
    @objc fileprivate func leftWidgetButtonAction() {
       onLeftWidgetButtonAction?()
    }
    
    @objc fileprivate func rightWidgetButtonAction() {
        onRightWidgetButtonAction?()
    }
    
    @objc func handleTapGesture(_ sender: UITapGestureRecognizer) {
        
    }
    
    @objc fileprivate func keyboardButtonAction() {
        stopAudioRecording()
        onKeyboardButtonAction?()
    }
    
    fileprivate func startAudioRecording(){
        voiceRecordingStarted?(self)
        startAnimationWaveTimer()
        updateContainerView(true)
    }
    
    fileprivate func stopAudioRecording()  {
        //stop timers
        if animationTimer != nil {
            animationTimer.invalidate()
            animationTimer = nil
        }
        
        voiceRecordingStopped?(self)
        updateContainerView(false)
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        if !self.isActive {
            KREASRService.shared.checkAudioRecordPermission({ [weak self] in
                self?.isActive = true
                self?.startAudioRecording()
            })
        } else {
            self.isActive = false
            self.audioView.alpha = 1
            self.stopAudioRecording()
        }
    }
    
    // MARK: -
    @objc fileprivate func updateMeter() {
        if let peakPower = getAudioPeakOutputPower?() {
            audioButton.update(peakPower)
        }
    }
    
    // MARK: Timers
    fileprivate func startAnimationWaveTimer() {
        self.animationTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateMeter), userInfo: nil, repeats: true)
        RunLoop.main.add(self.animationTimer, forMode:RunLoop.Mode.default)
    }
    
    func updateContainerView(_ isRecording: Bool) {
        onContainertTapAction?()
        if isRecording {
            keyboardButton.isHidden = true
            thunderBoltActionButton.isHidden = true
            inputContainerView.isHidden = true
            audioView.isHidden = true
            leftWidgetBtn.isHidden = true
            rightWidgetBtn.isHidden = true
            audioButton.isHidden = false
            backgroundColor = .white
        } else {
            keyboardButton.isHidden = false
            thunderBoltActionButton.isHidden = false
            inputContainerView.isHidden = false
            audioView.isHidden = false
            leftWidgetBtn.isHidden = false
            rightWidgetBtn.isHidden = false
            audioButton.isHidden = true
            backgroundColor = .white
        }
    }
    
    public func setRightWidgetImage(_ image: UIImage?) {
        if image == nil {
            let rightImage = UIImage(named: "knowledge", in: bundle, compatibleWith: nil)
            let widgetImage = rightImage?.withRenderingMode(.alwaysTemplate)
            rightWidgetBtn.setImage(widgetImage, for: .normal)
        } else {
            rightWidgetBtn.setImage(image, for: .normal)
        }
    }
}

// MARK: - KREAudioView
public class KREAudioView: UIButton {
    let bundle = Bundle.sdkModule
    public var rate: CGFloat = 0.0
    
    var fillColor: UIColor = UIColor.lightRoyalBlue {
        didSet {
            setNeedsDisplay()
        }
    }
    public var image: UIImage! {
        didSet {
            setNeedsDisplay()
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        image = UIImage(named: "speech", in: bundle, compatibleWith: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        image = UIImage(named: "speech", in: bundle, compatibleWith: nil)
    }
    
    public func update(_ rate: CGFloat) {
        self.rate = rate
        setNeedsDisplay()
    }
    
    override public func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        context?.translateBy(x: 0, y: bounds.size.height)
        context?.scaleBy(x: 1, y: -1)
        
        context?.draw(image.cgImage!, in: bounds)
        context?.clip(to: bounds, mask: image.cgImage!)
        
        context?.setFillColor(fillColor.cgColor.components!)
        context?.fill(CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height * rate))
    }
    
    override public func prepareForInterfaceBuilder() {
        let bundle = Bundle.sdkModule
        image = UIImage(named: "speech", in: bundle, compatibleWith: self.traitCollection)
    }
}
