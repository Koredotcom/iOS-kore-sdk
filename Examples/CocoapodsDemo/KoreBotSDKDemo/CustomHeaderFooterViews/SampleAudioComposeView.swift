//
//  SampleFooterView.swift
//  KoreBotSDKDemo
//
//  Created by Pagidimarri Kartheek on 03/12/24.
//  Copyright © 2024 Kore. All rights reserved.
//

import Foundation
import KoreBotSDK
class SampleAudioComposeView: AudioComposeView {
    
    var keyboardButton: UIButton = {
        let keyboardButton = UIButton(frame: .zero)
        keyboardButton.translatesAutoresizingMaskIntoConstraints = false
        keyboardButton.backgroundColor = UIColor.whiteTwo
        keyboardButton.setImage(UIImage(named: "keyboard", in: nil, compatibleWith: nil), for: .normal)
        keyboardButton.addTarget(self, action: #selector(menuBtnAction(_:)), for: .touchUpInside)
        return keyboardButton
    }()
    
    var soundButton: UIButton = {
        let soundButton = UIButton(frame: .zero)
        soundButton.translatesAutoresizingMaskIntoConstraints = false
        soundButton.backgroundColor = UIColor.whiteTwo
        soundButton.setImage(UIImage(named: "mute", in: nil, compatibleWith: nil), for: .normal)
        soundButton.addTarget(self, action: #selector(sendBtnAction(_:)), for: .touchUpInside)
        return soundButton
    }()
    var TaptoSpeakButton: UIButton = {
        let TaptoSpeakButton = UIButton(frame: .zero)
        TaptoSpeakButton.translatesAutoresizingMaskIntoConstraints = false
        TaptoSpeakButton.backgroundColor = UIColor.whiteTwo
        TaptoSpeakButton.setTitle("Tap to speak", for: .normal)
        TaptoSpeakButton.setTitleColor(.black, for: .normal)
        TaptoSpeakButton.titleLabel?.font = UIFont.systemFont(ofSize: 12.0)
        TaptoSpeakButton.addTarget(self, action: #selector(taptoSpeakButtonAction(_:)), for: .touchUpInside)
        return TaptoSpeakButton
    }()
    var isSpeaking = false
    override func setupViews() {
        self.backgroundColor = .veryLightBlue
        self.addSubview(keyboardButton)
        self.addSubview(soundButton)
        self.addSubview(TaptoSpeakButton)
        NotificationCenter.default.addObserver(self, selector: #selector(startOrStopRecording), name:  NSNotification.Name(rawValue: "StartOrStopRecordingNotification"), object: nil)
        let views: [String: UIView] = ["keyboardButton": keyboardButton, "soundButton": soundButton, "TaptoSpeakButton": TaptoSpeakButton]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[keyboardButton(30)]-10-[TaptoSpeakButton(100)]", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[keyboardButton(30)]", options:[], metrics:nil, views:views))
        self.addConstraint(NSLayoutConstraint.init(item: keyboardButton as Any, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0.0))
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[soundButton(30)]-5-|", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[soundButton(30)]", options:[], metrics:nil, views:views))
        self.addConstraint(NSLayoutConstraint.init(item: soundButton as Any, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0.0))
        
        self.addConstraint(NSLayoutConstraint.init(item: TaptoSpeakButton as Any, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0))
        
        
    }
    
    @objc func menuBtnAction(_ sender: AnyObject) {
        koreFooterViewonKeyboardButtonAction?()
    }
    @objc func sendBtnAction(_ sender: AnyObject) {
        koreFooterViewPlaybackButtonAction?()
        if isSpeaking{
            isSpeaking = false
            soundButton.setImage(UIImage(named: "mute", in: nil, compatibleWith: nil), for: .normal)
        }else{
            isSpeaking = true
            soundButton.setImage(UIImage(named: "unmute", in: nil, compatibleWith: nil), for: .normal)
        }
    }
    @objc func taptoSpeakButtonAction(_ sender: AnyObject) {
        koreFooterViewAudioButtonAction?()
    }
    @objc func startOrStopRecording(notification:Notification) {
        let dataString: String = notification.object as! String
        let jsonObject: NSDictionary = Utilities.jsonObjectFromString(jsonString: dataString) as! NSDictionary
        let isVoiceRecording =  jsonObject["voiceRecording"] as! Bool
        if isVoiceRecording{
            TaptoSpeakButton.setTitle("Recording..", for: .normal)
        }else{
            TaptoSpeakButton.setTitle("Tap to speak", for: .normal)
        }
    }
    deinit {
        // Remove observer when parent view controller is deallocated
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "StartOrStopRecordingNotification"), object: nil)
    }
}
