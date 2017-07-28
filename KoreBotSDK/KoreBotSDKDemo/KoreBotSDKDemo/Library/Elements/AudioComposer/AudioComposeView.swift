//
//  AudioComposeView.swift
//  KoreBotSDKDemo
//
//  Created by Anoop Dhiman on 28/07/17.
//  Copyright © 2017 Kore. All rights reserved.
//

import UIKit

class AudioComposeView: UIView {
    
    public var isActive = false
    
    fileprivate var animateBGView: UIView!
    fileprivate var audioImageView: UIImageView!
    fileprivate var audiolabel: UILabel!
    fileprivate var cancelImageView: UIImageView!
    fileprivate var cancelView: UIView!
    
    fileprivate var audioImageWidthConstraint: NSLayoutConstraint!
    fileprivate var animationTimer:Timer!
    fileprivate var audioRecorderTimer:Timer!
    fileprivate var audioPeakOutput:Float = 0.3
    fileprivate var waveRadius:Float = 25
    
    public var getAudioPeakOutputPower: (() -> (Float))!
    public var cancelledSpeechToText: (() -> ())?
    public var voiceRecordingStarted: ((_ composeView: AudioComposeView?) -> Void)!
    public var voiceRecordingStopped: ((_ composeView: AudioComposeView?) -> Void)!
    
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
        self.backgroundColor = UIColor.white
        
        self.animateBGView = UIView.init(frame: CGRect.zero)
        self.animateBGView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.animateBGView)
        
        self.audioImageView = UIImageView(image: UIImage(named: "audio_icon"))
        self.audioImageView.contentMode = .scaleAspectFit
        self.audioImageView.translatesAutoresizingMaskIntoConstraints = false
        self.animateBGView.addSubview(self.audioImageView)
        
        self.audiolabel = UILabel()
        self.audiolabel.text = "Tap here"
        self.audiolabel.font = UIFont(name: "HelveticaNeue", size: 11.0)!
        self.audiolabel.textColor = Common.UIColorRGB(0x999999)
        self.audiolabel.textAlignment = .center
        self.audiolabel.translatesAutoresizingMaskIntoConstraints = false
        self.audiolabel.isHidden = true
        self.animateBGView.addSubview(self.audiolabel)
        
        self.animateBGView.addConstraint(NSLayoutConstraint.init(item: self.audioImageView, attribute: .centerY, relatedBy: .equal, toItem: self.animateBGView, attribute: .centerY, multiplier: 1.0, constant: 0.0))
        self.animateBGView.addConstraint(NSLayoutConstraint.init(item: self.audioImageView, attribute: .centerX, relatedBy: .equal, toItem: self.animateBGView, attribute: .centerX, multiplier: 1.0, constant: 0.0))
        self.animateBGView.addConstraint(NSLayoutConstraint.init(item: self.audioImageView, attribute: .width, relatedBy: .equal, toItem: self.audioImageView, attribute: .height, multiplier: 1.0, constant: 0.0))
        self.audioImageWidthConstraint = NSLayoutConstraint.init(item: self.audioImageView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 15.0)
        self.animateBGView.addConstraint(self.audioImageWidthConstraint)
        
        self.animateBGView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[audiolabel]-|", options:[], metrics:nil, views:["audiolabel": self.audiolabel]))
        self.animateBGView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[audiolabel]-|", options:[], metrics:nil, views:["audiolabel": self.audiolabel]))
        
        self.cancelView = UIView.init(frame: CGRect.zero)
        self.cancelView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.cancelView)
        
        self.cancelImageView = UIImageView(image: UIImage(named: "policy_close"))
        self.cancelImageView.contentMode = .scaleAspectFit
        self.cancelImageView.translatesAutoresizingMaskIntoConstraints = false
        self.cancelView.addSubview(self.cancelImageView)
        
        self.cancelView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[cancelImageView(28)]-4-|", options:[], metrics:nil, views:["cancelImageView": self.cancelImageView]))
        self.cancelView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[cancelImageView(28)]-4-|", options:[], metrics:nil, views:["cancelImageView": self.cancelImageView]))
        
        let views: [String : Any] = ["animateBGView": self.animateBGView, "cancelView": self.cancelView]
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[animateBGView(100)]", options:[], metrics:nil, views:views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-12-[animateBGView(100)]-12-|", options:[], metrics:nil, views:views))
        self.addConstraint(NSLayoutConstraint.init(item: self.animateBGView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0))
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[cancelView(50)]|", options:[], metrics:nil, views:views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[cancelView(50)]|", options:[], metrics:nil, views:views))
        
        let audioGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(self.audioButtonAction))
        self.animateBGView.addGestureRecognizer(audioGestureRecognizer)
        let cancelGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(self.cancelButtonAction))
        self.cancelView.addGestureRecognizer(cancelGestureRecognizer)
    }
    
    public func startRecording() {
        if !self.isActive {
            self.isActive = true
            self.audioButtonAction()
        }
    }
    
    public func stopRecording() {
        if self.isActive {
            self.stopAudioRecording()
        }
    }
    
    public func closeRecording() {
        if self.isActive {
            self.cancelButtonAction()
        }
    }
    
    @objc fileprivate func audioButtonAction() {
        if self.voiceRecordingStarted != nil {
            self.voiceRecordingStarted!(self)
        }
        self.audioImageWidthConstraint.constant = 20;
        self.animateBGView.isUserInteractionEnabled = false
        self.audioImageView.image = UIImage(named: "audio_icon")!
        self.audiolabel.isHidden = true
        self.startAnimationWaveTimer()
        self.audioRecordTimer()
    }
    
    @objc fileprivate func cancelButtonAction() {
        self.isActive = false
        self.stopAudioRecording()
        if((self.cancelledSpeechToText) != nil){
            self.cancelledSpeechToText!()
        }
    }
    
    @objc fileprivate func showCircleWaveAnimation() {
        let circleView = UIView()
        circleView.frame = CGRect(x: self.animateBGView.frame.size.width/2 - 2.5, y: self.animateBGView.frame.size.height/2 - 2.5, width: CGFloat(5), height: CGFloat(5))
        
        self.animateBGView.addSubview(circleView)
        circleView.backgroundColor = Common.UIColorRGB(0x009FA7)
        circleView.layer.cornerRadius = circleView.frame.size.width / 2
        circleView.alpha = 1.0
        var radius:CGFloat = 7.0
        if(self.audioPeakOutput > 0.9){
            radius = CGFloat(self.randomInt(min: 17, max: 25))
        }
        self.animateBGView.bringSubview(toFront: self.audioImageView)
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
        
        self.audioImageWidthConstraint.constant = 30;
        self.animateBGView.isUserInteractionEnabled = true
        self.audioImageView.image = UIImage(named: "speech")!
        self.audiolabel.isHidden = false
        
        if self.voiceRecordingStopped != nil {
            self.voiceRecordingStopped!(self)
        }
    }
    
    @objc fileprivate func updateRecordTimer() {
        if(self.getAudioPeakOutputPower != nil){
            self.audioPeakOutput =  self.decibelToLinear(power: self.getAudioPeakOutputPower())
        }
    }
    
    // MARK: Timers
    
    fileprivate func startAnimationWaveTimer() {
        self.animationTimer = Timer.scheduledTimer(timeInterval: 0.35, target: self, selector: #selector(self.showCircleWaveAnimation), userInfo: nil, repeats: true)
        RunLoop.main.add(self.animationTimer, forMode: RunLoopMode.defaultRunLoopMode)
    }
    
    fileprivate func audioRecordTimer() {
        self.audioRecorderTimer = Timer.scheduledTimer(timeInterval: 0.001, target: self, selector: #selector(self.updateRecordTimer), userInfo: nil, repeats: true)
        RunLoop.main.add(self.audioRecorderTimer, forMode: RunLoopMode.defaultRunLoopMode)
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
