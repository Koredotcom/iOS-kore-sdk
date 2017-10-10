//
//  AudioView.swift
//  KoreBotSDKDemo
//
//  Created by Anoop Dhiman on 08/10/17.
//  Copyright © 2017 Kore. All rights reserved.
//

import UIKit
import AVFoundation

class AudioView: UIView {

    public var isActive = false
    
    fileprivate var animateBGView: UIView!
    fileprivate var audioActionView: UIView!
    fileprivate var audioImageView: UIImageView!
    fileprivate var audiolabel: UILabel!
    fileprivate var cancelImageView: UIImageView!
    fileprivate var cancelView: UIView!
    fileprivate var keyboardImageView: UIImageView!
    
    fileprivate var audioImageWidthConstraint: NSLayoutConstraint!
    fileprivate var animationTimer:Timer!
    fileprivate var audioRecorderTimer:Timer!
    fileprivate var audioPeakOutput:Float = 0.3
    fileprivate var waveRadius:Float = 25
    
    public var getAudioPeakOutputPower: (() -> (Float))!
    public var cancelledSpeechToText: (() -> ())?
    public var voiceRecordingStarted: ((_ composeView: AudioView?) -> Void)!
    public var voiceRecordingStopped: ((_ composeView: AudioView?) -> Void)!
    
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
        self.backgroundColor = .clear
        
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
        
        self.cancelView = UIView.init(frame: CGRect.zero)
        self.cancelView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.cancelView)
        
        self.cancelImageView = UIImageView(image: UIImage(named: "policy_close"))
        self.cancelImageView.contentMode = .scaleAspectFit
        self.cancelImageView.translatesAutoresizingMaskIntoConstraints = false
        self.cancelView.addSubview(self.cancelImageView)
        
        self.cancelView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[cancelImageView(28)]", options:[], metrics:nil, views:["cancelImageView": self.cancelImageView]))
        self.cancelView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[cancelImageView(28)]", options:[], metrics:nil, views:["cancelImageView": self.cancelImageView]))
        self.cancelView.addConstraint(NSLayoutConstraint.init(item: self.cancelImageView, attribute: .centerY, relatedBy: .equal, toItem: self.cancelView, attribute: .centerY, multiplier: 1.0, constant: 0.0))
        self.cancelView.addConstraint(NSLayoutConstraint.init(item: self.cancelImageView, attribute: .centerX, relatedBy: .equal, toItem: self.cancelView, attribute: .centerX, multiplier: 1.0, constant: 0.0))
        
        self.keyboardImageView = UIImageView(image: UIImage(named: "keyboard"))
        self.keyboardImageView.contentMode = .scaleAspectFit
        self.keyboardImageView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.keyboardImageView)
        
        let views: [String : Any] = ["animateBGView": self.animateBGView, "audioActionView": self.audioActionView, "cancelView": self.cancelView, "keyboardImageView": self.keyboardImageView]
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[animateBGView(100)]", options:[], metrics:nil, views:views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[animateBGView(70)]-|", options:[], metrics:nil, views:views))
        self.addConstraint(NSLayoutConstraint.init(item: self.animateBGView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0))
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[audioActionView(100)]", options:[], metrics:nil, views:views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[audioActionView(70)]-|", options:[], metrics:nil, views:views))
        self.addConstraint(NSLayoutConstraint.init(item: self.audioActionView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0))
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[cancelView(50)]", options:[], metrics:nil, views:views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[cancelView(50)]", options:[], metrics:nil, views:views))
        self.addConstraint(NSLayoutConstraint.init(item: self.cancelView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0.0))
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[keyboardImageView(30)]-20-|", options:[], metrics:nil, views:views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[keyboardImageView(30)]", options:[], metrics:nil, views:views))
        self.addConstraint(NSLayoutConstraint.init(item: self.keyboardImageView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0.0))
        
        let audioGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(self.audioButtonAction))
        self.audioActionView.addGestureRecognizer(audioGestureRecognizer)
        let cancelGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(self.cancelButtonAction))
        self.cancelView.addGestureRecognizer(cancelGestureRecognizer)
    }
    
    public func stopRecording() {
        if self.isActive {
            self.isActive = false
            self.stopAudioRecording()
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
        self.cancelledSpeechToText = nil
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
    
    func checkAudioRecordPermission(block:(() -> Void)?) {
        let audioSession = AVAudioSession.sharedInstance()
        if (audioSession.responds(to: #selector(AVAudioSession.requestRecordPermission(_:)))) {
            audioSession.requestRecordPermission({ (granted: Bool) in
                if(granted){
                    DispatchQueue.main.async {
                        block!()
                    }
                }else{
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Microphone Access Denied", message: "This app requires access to your device's Microphone.\n\nPlease enable Microphone access for this app in Settings / Privacy / Microphone", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.cancel, handler: nil))
                        
                        // Get root view controller
                        if let viewController = UIApplication.shared.keyWindow?.rootViewController {
                            viewController.present(alert, animated: true, completion: nil)
                        }
                    }
                }
            })
        }
    }
    
    @objc fileprivate func audioButtonAction() {
        if !self.isActive {
            self.checkAudioRecordPermission(block: { [weak self] in
                self?.isActive = true
                self?.startRecording()
            })
        } else {
            self.isActive = false
            self.stopAudioRecording()
        }
    }
    
    @objc fileprivate func cancelButtonAction() {
        if((self.cancelledSpeechToText) != nil){
            self.cancelledSpeechToText!()
        }
    }
    
    fileprivate func startRecording(){
        if self.voiceRecordingStarted != nil {
            self.voiceRecordingStarted!(self)
        }
        self.audiolabel.isHidden = true
        self.cancelView.isHidden = true
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
        self.cancelView.isHidden = false
        
        if self.voiceRecordingStopped != nil {
            self.voiceRecordingStopped!(self)
        }
    }
    
    //MARK: Wave animation
    
    @objc fileprivate func showCircleWaveAnimation() {
        let circleView = UIView()
        circleView.frame = CGRect(x: self.animateBGView.frame.size.width/2 - 2.5, y: self.animateBGView.frame.size.height/2 - 2.5, width: CGFloat(5), height: CGFloat(5))
        
        self.animateBGView.addSubview(circleView)
        circleView.backgroundColor = .white// Common.UIColorRGB(0x009FA7)
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
