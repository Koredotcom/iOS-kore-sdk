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
    
    fileprivate var animateBGView: UIView!
    fileprivate var audioActionView: UIView!
    fileprivate var audioImageView: UIImageView!
    fileprivate var audiolabel: UILabel!
    fileprivate var keyboardButton: UIButton!
    fileprivate var playbackButton: UIButton!
    
    fileprivate var audioImageWidthConstraint: NSLayoutConstraint!
    fileprivate var animationTimer:Timer!
    fileprivate var audioRecorderTimer:Timer!
    fileprivate var audioPeakOutput:Float = 0.3
    fileprivate var waveRadius:Float = 25
    
    public var getAudioPeakOutputPower: (() -> (Float))!
    public var voiceRecordingStarted: ((_ composeView: AudioComposeView?) -> Void)!
    public var voiceRecordingStopped: ((_ composeView: AudioComposeView?) -> Void)!
    public var onKeyboardButtonAction: (() -> Void)!
    
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
        
        self.animateBGView = UIView.init(frame: CGRect.zero)
        self.animateBGView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.animateBGView)
        
        self.audioActionView = UIView.init(frame: CGRect.zero)
        self.audioActionView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.audioActionView)
        
        self.audioImageView = UIImageView(image: UIImage(named: "audio_icon"))
        self.audioImageView.contentMode = .scaleAspectFit
        self.audioImageView.translatesAutoresizingMaskIntoConstraints = false
        self.animateBGView.addSubview(self.audioImageView)
        
        self.audiolabel = UILabel()
        self.audiolabel.text = "Tap to speak"
        self.audiolabel.font = UIFont(name: "HelveticaNeue", size: 11.0)!
        self.audiolabel.textColor = .white
        self.audiolabel.textAlignment = .center
        self.audiolabel.translatesAutoresizingMaskIntoConstraints = false
        self.animateBGView.addSubview(self.audiolabel)
        
        self.animateBGView.addConstraint(NSLayoutConstraint.init(item: self.audioImageView, attribute: .centerY, relatedBy: .equal, toItem: self.animateBGView, attribute: .centerY, multiplier: 1.0, constant: 0.0))
        self.animateBGView.addConstraint(NSLayoutConstraint.init(item: self.audioImageView, attribute: .centerX, relatedBy: .equal, toItem: self.animateBGView, attribute: .centerX, multiplier: 1.0, constant: 0.0))
        self.animateBGView.addConstraint(NSLayoutConstraint.init(item: self.audioImageView, attribute: .width, relatedBy: .equal, toItem: self.audioImageView, attribute: .height, multiplier: 1.0, constant: 0.0))
        self.audioImageWidthConstraint = NSLayoutConstraint.init(item: self.audioImageView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 40.0)
        self.animateBGView.addConstraint(self.audioImageWidthConstraint)
        
        self.animateBGView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[audiolabel]-|", options:[], metrics:nil, views:["audiolabel": self.audiolabel]))
        self.animateBGView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[audiolabel]|", options:[], metrics:nil, views:["audiolabel": self.audiolabel]))
        
        self.keyboardButton = UIButton.init(frame: CGRect.zero)
        self.keyboardButton.setTitle("", for: .normal)
        self.keyboardButton.translatesAutoresizingMaskIntoConstraints = false
        self.keyboardButton.setImage(UIImage(named: "keyboard"), for: .normal)
        self.keyboardButton.imageView?.contentMode = .center
        self.keyboardButton.addTarget(self, action: #selector(self.keyboardButtonAction), for: .touchUpInside)
//        self.keyboardButton.contentEdgeInsets = UIEdgeInsetsMake(2.0, 10.0, 0.0, 10.0)
        self.keyboardButton.clipsToBounds = true
        self.addSubview(self.keyboardButton)
        
        self.playbackButton = UIButton.init(frame: CGRect.zero)
        self.playbackButton.setTitle("", for: .normal)
        self.playbackButton.translatesAutoresizingMaskIntoConstraints = false
        self.playbackButton.setImage(UIImage(named: "unmute"), for: .normal)
        self.playbackButton.imageView?.contentMode = .scaleAspectFit
        self.playbackButton.addTarget(self, action: #selector(self.playbackButtonAction), for: .touchUpInside)
//        self.playbackButton.contentEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)
        self.playbackButton.clipsToBounds = true
        self.addSubview(self.playbackButton)
        
        let views: [String : Any] = ["animateBGView": self.animateBGView, "audioActionView": self.audioActionView, "keyboardButton": self.keyboardButton, "playbackButton": self.playbackButton]
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[animateBGView(100)]", options:[], metrics:nil, views:views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[animateBGView(70)]", options:[], metrics:nil, views:views))
        self.addConstraint(NSLayoutConstraint.init(item: self.animateBGView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0))
        self.addConstraint(NSLayoutConstraint.init(item: self.animateBGView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0.0))
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[audioActionView(100)]", options:[], metrics:nil, views:views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[audioActionView(70)]", options:[], metrics:nil, views:views))
        self.addConstraint(NSLayoutConstraint.init(item: self.audioActionView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0))
        self.addConstraint(NSLayoutConstraint.init(item: self.audioActionView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0.0))
        
        let audioGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(self.audioButtonAction))
        self.audioActionView.addGestureRecognizer(audioGestureRecognizer)
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[keyboardButton(50)]", options:[], metrics:nil, views:views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[keyboardButton(50)]", options:[], metrics:nil, views:views))
        self.addConstraint(NSLayoutConstraint.init(item: self.keyboardButton, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0.0))
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[playbackButton(60)]-10-|", options:[], metrics:nil, views:views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[playbackButton(60)]", options:[], metrics:nil, views:views))
        self.addConstraint(NSLayoutConstraint.init(item: self.playbackButton, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0.0))
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
            self.playbackButton.setImage(UIImage(named: "unmute"), for: .normal)
        }else{
            self.playbackButton.setImage(UIImage(named: "mute"), for: .normal)
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
    
    @objc fileprivate func playbackButtonAction() {
        if isSpeakingEnabled {
            self.playbackButton.setImage(UIImage(named: "mute"), for: .normal)
            isSpeakingEnabled =  false
            NotificationCenter.default.post(name: Notification.Name(stopSpeakingNotification), object: nil)
        }else{
            self.playbackButton.setImage(UIImage(named: "unmute"), for: .normal)
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
