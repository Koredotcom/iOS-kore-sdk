//
//  AudioComposeView.swift
//  KoreBotSDKDemo
//
//  Created by Anoop Dhiman on 28/07/17.
//  Copyright © 2017 Kore. All rights reserved.
//

import UIKit
import AVFoundation

class AudioComposeView: UIView {
    
    public var isActive = false
    let bundle = Bundle.sdkModule
    fileprivate var animateBGView: UIView!
    fileprivate var audioActionView: UIView!
    fileprivate var audioImageView: UIImageView!
    fileprivate var audioSubImageView: UIImageView!
    fileprivate var audiolabel: UILabel!
    fileprivate var keyboardButton: UIButton!
    fileprivate var playbackButton: UIButton!
    fileprivate var menuButton: UIButton!
    fileprivate var attachmentButton: UIButton!
    var footerDic = FooterModel()
    fileprivate var subImageVColor = BubbleViewUserChatTextColor
    var footerIconColor = "#000000"
    
    fileprivate var audioImageWidthConstraint: NSLayoutConstraint!
    fileprivate var audioSubImageWidthConstraint: NSLayoutConstraint!
    fileprivate var animationTimer:Timer!
    fileprivate var audioRecorderTimer:Timer!
    fileprivate var audioPeakOutput:Float = 0.3
    fileprivate var waveRadius:Float = 25
    
    public var getAudioPeakOutputPower: (() -> (Float))!
    public var voiceRecordingStarted: ((_ composeView: AudioComposeView?) -> Void)!
    public var voiceRecordingStopped: ((_ composeView: AudioComposeView?) -> Void)!
    public var onKeyboardButtonAction: (() -> Void)!
    public var audioComposeBarTaskMenuButtonAction: (() -> Void)!
    public var audioComposeBarAttachmentButtonAction: (() -> Void)!
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupViews()
    }
    
    fileprivate func setupViews() {
        self.backgroundColor = UIColor.clear
        
        if let footerDic = brandingValues.footer{
            self.footerDic = footerDic
        }
       
        
        let menuBtnWidth = footerDic.buttons?.menu?.show == true ? 30 : 00
        let attachmentBtnWidth = footerDic.buttons?.attachment?.show == true ? 25 : 00
        
        self.animateBGView = UIView.init(frame: CGRect.zero)
        self.animateBGView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.animateBGView)
        
        self.audioActionView = UIView.init(frame: CGRect.zero)
        self.audioActionView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.audioActionView)
        
        self.audioImageView = UIImageView(image: UIImage(named: "audio_icon-13", in: self.bundle, compatibleWith: nil))
        self.audioImageView.contentMode = .scaleAspectFit
        self.audioImageView.translatesAutoresizingMaskIntoConstraints = false
        self.animateBGView.addSubview(self.audioImageView)
        
        self.audioSubImageView = UIImageView(image: UIImage(named: "wave", in: self.bundle, compatibleWith: nil))
        self.audioSubImageView.contentMode = .scaleAspectFit
        self.audioSubImageView.translatesAutoresizingMaskIntoConstraints = false
        self.animateBGView.addSubview(self.audioSubImageView)
       
        
        self.audiolabel = UILabel()
        self.audiolabel.text = "Tap microphone to speak"
        self.audiolabel.font = UIFont(name: "HelveticaNeue", size: 11.0)
        self.audiolabel.textColor = UIColor.init(hexString: "#697586")
        self.audiolabel.textAlignment = .center
        self.audiolabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.audiolabel)
        
        self.animateBGView.addConstraint(NSLayoutConstraint.init(item: self.audioImageView as Any, attribute: .centerY, relatedBy: .equal, toItem: self.animateBGView, attribute: .centerY, multiplier: 1.0, constant: 0.0))
        self.animateBGView.addConstraint(NSLayoutConstraint.init(item: self.audioImageView as Any, attribute: .centerX, relatedBy: .equal, toItem: self.animateBGView, attribute: .centerX, multiplier: 1.0, constant: 0.0))
        self.animateBGView.addConstraint(NSLayoutConstraint.init(item: self.audioImageView as Any, attribute: .width, relatedBy: .equal, toItem: self.audioImageView, attribute: .height, multiplier: 1.0, constant: 0.0))
        self.audioImageWidthConstraint = NSLayoutConstraint.init(item: self.audioImageView as Any, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 50.0)
        self.animateBGView.addConstraint(self.audioImageWidthConstraint)
        
        self.animateBGView.addConstraint(NSLayoutConstraint.init(item: self.audioSubImageView as Any, attribute: .centerY, relatedBy: .equal, toItem: self.audioImageView, attribute: .centerY, multiplier: 1.0, constant: 0.0))
        self.animateBGView.addConstraint(NSLayoutConstraint.init(item: self.audioSubImageView as Any, attribute: .centerX, relatedBy: .equal, toItem: self.audioImageView, attribute: .centerX, multiplier: 1.0, constant: 0.0))
        self.animateBGView.addConstraint(NSLayoutConstraint.init(item: self.audioSubImageView as Any, attribute: .width, relatedBy: .equal, toItem: self.audioSubImageView, attribute: .height, multiplier: 1.0, constant: 0.0))
        self.audioSubImageWidthConstraint = NSLayoutConstraint.init(item: self.audioSubImageView as Any, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 30.0)
        self.animateBGView.addConstraint(self.audioSubImageWidthConstraint)
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[audiolabel]-|", options:[], metrics:nil, views:["audiolabel": self.audiolabel as Any]))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[audiolabel]-10-|", options:[], metrics:nil, views:["audiolabel": self.audiolabel as Any]))
        
        self.keyboardButton = UIButton.init(frame: CGRect.zero)
        self.keyboardButton.setTitle("", for: .normal)
        self.keyboardButton.translatesAutoresizingMaskIntoConstraints = false
        self.keyboardButton.setImage(UIImage(named: "keyboard", in: bundle, compatibleWith: nil), for: .normal)
        self.keyboardButton.imageView?.contentMode = .center
        self.keyboardButton.addTarget(self, action: #selector(self.keyboardButtonAction), for: .touchUpInside)
//        self.keyboardButton.contentEdgeInsets = UIEdgeInsetsMake(2.0, 10.0, 0.0, 10.0)
        self.keyboardButton.clipsToBounds = true
        self.addSubview(self.keyboardButton)
        
        self.menuButton = UIButton.init(frame: CGRect.zero)
        self.menuButton.setTitle("", for: .normal)
        self.menuButton.translatesAutoresizingMaskIntoConstraints = false
        self.menuButton.setImage(UIImage(named: "Menu", in: bundle, compatibleWith: nil), for: .normal)
        self.menuButton.imageView?.contentMode = .center
        self.menuButton.addTarget(self, action: #selector(self.menuButtonAction), for: .touchUpInside)
//        self.menuButton.contentEdgeInsets = UIEdgeInsetsMake(2.0, 10.0, 0.0, 10.0)
        self.menuButton.clipsToBounds = true
        self.addSubview(self.menuButton)
        
        self.attachmentButton = UIButton.init(frame: CGRect.zero)
        self.attachmentButton.setTitle("", for: .normal)
        self.attachmentButton.translatesAutoresizingMaskIntoConstraints = false
        self.attachmentButton.setImage(UIImage(named: "attach", in: bundle, compatibleWith: nil), for: .normal)
        self.attachmentButton.imageView?.contentMode = .center
        self.attachmentButton.addTarget(self, action: #selector(self.attachmentButtonAction), for: .touchUpInside)
//        self.menuButton.contentEdgeInsets = UIEdgeInsetsMake(2.0, 10.0, 0.0, 10.0)
        self.attachmentButton.clipsToBounds = true
        self.addSubview(self.attachmentButton)
        
        self.playbackButton = UIButton.init(frame: CGRect.zero)
        self.playbackButton.setTitle("", for: .normal)
        self.playbackButton.translatesAutoresizingMaskIntoConstraints = false
        self.playbackButton.setImage(UIImage(named: "unmute", in: bundle, compatibleWith: nil), for: .normal)
        self.playbackButton.imageView?.contentMode = .scaleAspectFit
        self.playbackButton.addTarget(self, action: #selector(self.playbackButtonAction), for: .touchUpInside)
//        self.playbackButton.contentEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)
        self.playbackButton.clipsToBounds = true
        self.addSubview(self.playbackButton)
        
        let views: [String : Any] = ["animateBGView": self.animateBGView as Any, "audioActionView": self.audioActionView as Any, "menuButton": menuButton as Any, "attachmentButton": self.attachmentButton as Any ,"keyboardButton": self.keyboardButton as Any, "playbackButton": self.playbackButton as Any]
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[animateBGView(100)]", options:[], metrics:nil, views:views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[animateBGView(70)]", options:[], metrics:nil, views:views))
        self.addConstraint(NSLayoutConstraint.init(item: self.animateBGView as Any, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0))
        self.addConstraint(NSLayoutConstraint.init(item: self.animateBGView as Any, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: -10.0))
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[audioActionView(100)]", options:[], metrics:nil, views:views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[audioActionView(70)]", options:[], metrics:nil, views:views))
        self.addConstraint(NSLayoutConstraint.init(item: self.audioActionView as Any, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0))
        self.addConstraint(NSLayoutConstraint.init(item: self.audioActionView as Any, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0.0))
        
        let audioGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(self.audioButtonAction))
        self.audioActionView.addGestureRecognizer(audioGestureRecognizer)
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[menuButton(\(menuBtnWidth))]-2-[attachmentButton(\(attachmentBtnWidth))]", options:[], metrics:nil, views:views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[menuButton(50)]", options:[], metrics:nil, views:views))
        self.addConstraint(NSLayoutConstraint.init(item: self.menuButton as Any, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0.0))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[attachmentButton(50)]", options:[], metrics:nil, views:views))
        self.addConstraint(NSLayoutConstraint.init(item: self.attachmentButton as Any, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0.0))
        
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[playbackButton(60)]-2-[keyboardButton(30)]-10-|", options:[], metrics:nil, views:views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[keyboardButton(50)]", options:[], metrics:nil, views:views))
        self.addConstraint(NSLayoutConstraint.init(item: self.keyboardButton as Any, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0.0))
        
//        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[playbackButton(00)]-10-|", options:[], metrics:nil, views:views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[playbackButton(60)]", options:[], metrics:nil, views:views))
        self.addConstraint(NSLayoutConstraint.init(item: self.playbackButton as Any, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0.0))
        setButtonIconColor()
    }
    
    func setButtonIconColor(){
       
        let bgColor = footerDic.bg_color
        if useColorPaletteOnly == true{
            self.backgroundColor = UIColor.init(hexString: genaralSecondaryColor)
            footerIconColor =  genaralPrimaryColor
        }else{
            self.backgroundColor = UIColor.init(hexString: bgColor ?? "#EEF2F6")
            footerIconColor =  footerDic.icons_color ?? "#000000"
        }
        
        let imgV = UIImage.init(named: "audio_icon-13", in: bundle, compatibleWith: nil)
        self.audioImageView.image = imgV?.withRenderingMode(.alwaysTemplate)
        self.audioImageView.tintColor = BubbleViewRightTint
        self.audioImageView.contentMode = .scaleAspectFit
        
        subImageVColor = BubbleViewUserChatTextColor
        audiolabel.textColor = BubbleViewUserChatTextColor
        
        let attachmentImage = UIImage(named: "attach", in: bundle, compatibleWith: nil)
        let tintedAttachmentImage = attachmentImage?.withRenderingMode(.alwaysTemplate)
        attachmentButton.setImage(tintedAttachmentImage, for: .normal)
        attachmentButton.tintColor = UIColor.init(hexString: footerIconColor)
        
        
        let keyBoardImage = UIImage(named: "keyboard", in: bundle, compatibleWith: nil)
        let tintedKeyboardImageImage = keyBoardImage?.withRenderingMode(.alwaysTemplate)
        keyboardButton.setImage(tintedKeyboardImageImage, for: .normal)
        keyboardButton.tintColor = UIColor.init(hexString: footerIconColor)
        
        
        let menuImage = UIImage(named: "Menu", in: bundle, compatibleWith: nil)
        let tintedMenuImage = menuImage?.withRenderingMode(.alwaysTemplate)
        menuButton.setImage(tintedMenuImage, for: .normal)
        menuButton.tintColor = UIColor.init(hexString: footerIconColor)
        
        let playImage = UIImage(named: "mute", in: bundle, compatibleWith: nil)
        let tintedPlayImage = playImage?.withRenderingMode(.alwaysTemplate)
        playbackButton.setImage(tintedPlayImage, for: .normal)
        playbackButton.tintColor = UIColor.init(hexString: footerIconColor)
        
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: 80.0)
    }
    
    public func startRecording() {
        if !self.isActive {
            self.audioButtonAction()
        }
    }
    
    public func stopRecording() {
        if self.isActive {
            self.audioButtonAction()
        }
    }
    
    public func enablePlayback(enable: Bool){
        if enable {
            self.playbackButton.setImage(UIImage(named: "unmute", in: bundle, compatibleWith: nil), for: .normal)
        }else{
            self.playbackButton.setImage(UIImage(named: "mute", in: bundle, compatibleWith: nil), for: .normal)
        }
    }

    //MARK:- removing refernces to elements
    public func prepareForDeinit(){
        if(self.animationTimer != nil){
            self.animationTimer.invalidate()
            self.animationTimer = nil;
        }
        if(self.audioRecorderTimer != nil){
            self.audioRecorderTimer.invalidate()
            self.audioRecorderTimer = nil
        }
        self.voiceRecordingStarted = nil
        self.voiceRecordingStopped = nil
        self.getAudioPeakOutputPower = nil
    }
    
    // MARK:- deinit
    deinit {
        self.animateBGView = nil
        self.audioImageView = nil
        self.audioSubImageView = nil
        self.audiolabel = nil
        self.audioImageWidthConstraint = nil
        self.animationTimer = nil
        self.audioRecorderTimer = nil
    }
    
    @objc fileprivate func audioButtonAction() {
        if !self.isActive {
            KoraASRService.shared.checkAudioRecordPermission({ [weak self] in
                self?.isActive = true
                self?.startAudioRecording()
            })
        } else {
            self.isActive = false
            self.stopAudioRecording()
        }
    }
    
    @objc fileprivate func keyboardButtonAction() {
        self.stopRecording()
        if self.onKeyboardButtonAction != nil {
            self.onKeyboardButtonAction!()
        }
    }
    
    @objc fileprivate func menuButtonAction() {
        self.stopRecording()
        if self.audioComposeBarTaskMenuButtonAction != nil{
            self.audioComposeBarTaskMenuButtonAction!()
        }
    }
    @objc fileprivate func attachmentButtonAction() {
        self.stopRecording()
        if self.audioComposeBarAttachmentButtonAction != nil{
            self.audioComposeBarAttachmentButtonAction!()
        }
    }
    
    @objc fileprivate func playbackButtonAction() {
        if isSpeakingEnabled {
            //self.playbackButton.setImage(UIImage(named: "mute", in: bundle, compatibleWith: nil), for: .normal)
            let playImage = UIImage(named: "mute", in: bundle, compatibleWith: nil)
            let tintedPlayImage = playImage?.withRenderingMode(.alwaysTemplate)
            playbackButton.setImage(tintedPlayImage, for: .normal)
            playbackButton.tintColor = UIColor.init(hexString: footerIconColor)
            isSpeakingEnabled =  false
            NotificationCenter.default.post(name: Notification.Name(stopSpeakingNotification), object: nil)
        }else{
            //self.playbackButton.setImage(UIImage(named: "unmute", in: bundle, compatibleWith: nil), for: .normal)
            let playImage = UIImage(named: "unmute", in: bundle, compatibleWith: nil)
            let tintedPlayImage = playImage?.withRenderingMode(.alwaysTemplate)
            playbackButton.setImage(tintedPlayImage, for: .normal)
            playbackButton.tintColor = UIColor.init(hexString: footerIconColor)
            NotificationCenter.default.post(name: Notification.Name(startSpeakingNotification), object: nil)
            isSpeakingEnabled = true
        }
//        isSpeakingEnabled = !isSpeakingEnabled
//        self.enablePlayback(enable: isSpeakingEnabled)
    }
    
    fileprivate func startAudioRecording(){
        if self.voiceRecordingStarted != nil {
            self.voiceRecordingStarted!(self)
        }
        self.audiolabel.isHidden = true
        self.startAnimationWaveTimer()
        self.audioRecordTimer()

        let subimgV = UIImage.init(named: "wave", in: bundle, compatibleWith: nil)
        self.audioSubImageView.image = subimgV?.withRenderingMode(.alwaysTemplate)
        self.audioSubImageView.tintColor = subImageVColor
        self.audioSubImageView.contentMode = .scaleAspectFit
        
        
        self.attachmentButton.isHidden = true
        self.menuButton.isHidden = true
        self.keyboardButton.isHidden = true
        self.playbackButton.isHidden = true
    }
    
    fileprivate func stopAudioRecording()  {
        //stop timers
        if(self.animationTimer != nil){
            self.animationTimer.invalidate()
            self.animationTimer = nil;
        }
        if(self.audioRecorderTimer != nil){
            self.audioRecorderTimer.invalidate()
            self.audioRecorderTimer = nil
        }
        self.audiolabel.isHidden = false
        if self.voiceRecordingStopped != nil {
            self.voiceRecordingStopped!(self)
        }
        
        let subimgV = UIImage.init(named: "Microphone", in: bundle, compatibleWith: nil)
        self.audioSubImageView.image = subimgV?.withRenderingMode(.alwaysTemplate)
        self.audioSubImageView.tintColor = subImageVColor
        self.audioSubImageView.contentMode = .scaleAspectFit
        
        self.attachmentButton.isHidden = false
        self.menuButton.isHidden = false
        self.keyboardButton.isHidden = false
        self.playbackButton.isHidden = false
    }
    
    @objc fileprivate func showCircleWaveAnimation() {
        let circleView = UIView()
        circleView.frame = CGRect(x: self.animateBGView.frame.size.width/2 - 2.5, y: self.animateBGView.frame.size.height/2 - 2.5, width: CGFloat(5), height: CGFloat(5))
        
        self.animateBGView.addSubview(circleView)
        circleView.backgroundColor = userColor
        circleView.layer.cornerRadius = circleView.frame.size.width / 2
        circleView.alpha = 1.0
        var radius:CGFloat = 7.0
        if(self.audioPeakOutput > 0.9){
            radius = CGFloat(self.randomInt(min: 17, max: 25))
        }
        self.animateBGView.bringSubviewToFront(self.audioImageView)
        self.animateBGView.bringSubviewToFront(self.audioSubImageView)
        circleView.layer.shadowColor = UIColor.white.cgColor
        circleView.layer.shadowOpacity = 0.6
        circleView.layer.shadowRadius = 1.0
        circleView.layer.shadowOffset = CGSize(width: CGFloat(0.0), height: CGFloat(0.0))
        UIView.animate(withDuration: 1.95, animations: {() -> Void in
            circleView.transform = CGAffineTransform(scaleX: radius, y: radius)
            circleView.alpha = 0.0
            
        }, completion: {(_ finished: Bool) -> Void in
            circleView.removeFromSuperview()
        })
    }
    
    @objc fileprivate func updateRecordTimer() {
        if(self.getAudioPeakOutputPower != nil){
            self.audioPeakOutput =  self.decibelToLinear(power: self.getAudioPeakOutputPower())
        }
    }
    
    // MARK: Timers
    
    fileprivate func startAnimationWaveTimer() {
        self.animationTimer = Timer.scheduledTimer(timeInterval: 0.35, target: self, selector: #selector(self.showCircleWaveAnimation), userInfo: nil, repeats: true)
        RunLoop.main.add(self.animationTimer, forMode: RunLoop.Mode.default)
    }
    
    fileprivate func audioRecordTimer() {
        self.audioRecorderTimer = Timer.scheduledTimer(timeInterval: 0.001, target: self, selector: #selector(self.updateRecordTimer), userInfo: nil, repeats: true)
        RunLoop.main.add(self.audioRecorderTimer, forMode: RunLoop.Mode.default)
    }
    
    // MARK: Decibel to Linear conversion
    
    func decibelToLinear(power:Float) -> (Float) {
        let normalizedDecbl:Float = pow (10, power / 20);// converted to linear
        return normalizedDecbl * waveRadius ;
    }
    
    func randomInt(min: Int, max:Int) -> Int {
        return min + Int(arc4random_uniform(UInt32(max - min + 1)))
    }
}
