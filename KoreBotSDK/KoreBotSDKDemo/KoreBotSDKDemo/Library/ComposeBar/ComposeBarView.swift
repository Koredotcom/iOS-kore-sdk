//
//  ComposeBarView.swift
//  KoreBotSDKDemo
//
//  Created by Anoop Dhiman on 26/07/17.
//  Copyright © 2017 Kore. All rights reserved.
//

import UIKit
import KoreWidgets

protocol ComposeBarViewDelegate {
    func composeBarView(_: ComposeBarView, sendButtonAction text: String)
    func composeBarViewSpeechToTextButtonAction(_: ComposeBarView)
}

class ComposeBarView: UIView {

    var delegate: ComposeBarViewDelegate?
    
    var topLineView: UIView!
    var bottomLineView: UIView!
    var growingTextView: KREGrowingTextView!
    var sendButton: UIButton!
    var speechToTextButton: UIButton!
    var textToSpeechButton: UIButton!
    
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
    
    func setupViews() {
        self.backgroundColor = Common.UIColorRGB(0xF9F9F9)
        
        self.topLineView = UIView.init(frame: CGRect.zero)
        self.topLineView.backgroundColor = Common.UIColorRGB(0xD7D9DA)
        self.topLineView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.topLineView)
        
        self.bottomLineView = UIView.init(frame: CGRect.zero)
        self.bottomLineView.backgroundColor = Common.UIColorRGB(0xD7D9DA)
        self.bottomLineView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.bottomLineView)
        
        self.growingTextView = KREGrowingTextView.init(frame: CGRect.zero)
        self.growingTextView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.growingTextView)
        
        self.growingTextView.maxNumberOfLines = 10
        self.growingTextView.font = UIFont(name: "HelveticaNeue", size: 14.0)!
        self.growingTextView.textContainerInset = UIEdgeInsets(top: 7, left: 5, bottom: 7, right: 20)
        self.growingTextView.animateHeightChange = true
        
        self.growingTextView.layer.borderColor = Common.UIColorRGB(0xCCCFD0).cgColor
        self.growingTextView.layer.borderWidth = 0.5
        self.growingTextView.layer.cornerRadius = 14
        self.growingTextView.textView.backgroundColor = UIColor.white
        self.growingTextView.backgroundColor = UIColor.white
        
        let attributes: [String : Any] = [NSFontAttributeName: UIFont(name: "HelveticaNeue", size: 14.0)!, NSForegroundColorAttributeName: Common.UIColorRGB(0xB5B9BA)]
        self.growingTextView.placeholderAttributedText = NSAttributedString(string: "Say Something...", attributes:attributes)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ComposeBarView.textDidChangeNotification(_ :)), name: NSNotification.Name.UITextViewTextDidChange, object: self.growingTextView.textView)
        
        self.sendButton = UIButton.init(frame: CGRect.zero)
        self.sendButton.setTitle("Send", for: .normal)
        self.sendButton.translatesAutoresizingMaskIntoConstraints = false
        self.sendButton.setTitleColor(Common.UIColorRGB(0x007AFF), for: .normal)
        self.sendButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 14.0)!
        self.sendButton.addTarget(self, action: #selector(self.sendButtonAction(_:)), for: .touchUpInside)
        self.sendButton.isHidden = true
        self.addSubview(self.sendButton)
        
        self.speechToTextButton = UIButton.init(frame: CGRect.zero)
        self.speechToTextButton.setTitle("", for: .normal)
        self.speechToTextButton.translatesAutoresizingMaskIntoConstraints = false
        self.speechToTextButton.setImage(UIImage(named: "audio_icon_select"), for: .normal)
        self.speechToTextButton.addTarget(self, action: #selector(self.speechToTextButtonAction(_:)), for: .touchUpInside)
        self.addSubview(self.speechToTextButton)
        
        self.textToSpeechButton = UIButton.init(frame: CGRect.zero)
        self.textToSpeechButton.setTitle("", for: .normal)
        self.textToSpeechButton.translatesAutoresizingMaskIntoConstraints = false
        self.textToSpeechButton.setImage(UIImage(named: "SpeakerMuteIcon"), for: .normal)
        self.textToSpeechButton.setImage(UIImage(named: "SpeakerIcon.png"), for: .selected)
        self.textToSpeechButton.addTarget(self, action: #selector(self.textToSpeechButtonAction(_:)), for: .touchUpInside)
        self.addSubview(self.textToSpeechButton)
        
        let views: [String : Any] = ["topLineView": self.topLineView, "bottomLineView": self.bottomLineView, "growingTextView": self.growingTextView, "sendButton": self.sendButton, "speechToTextButton": self.speechToTextButton, "textToSpeechButton": self.textToSpeechButton]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[topLineView]|", options:[], metrics:nil, views:views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[topLineView(0.5)]", options:[], metrics:nil, views:views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[bottomLineView]|", options:[], metrics:nil, views:views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[bottomLineView(0.5)]|", options:[], metrics:nil, views:views))
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[growingTextView]-6-[sendButton]-6-[textToSpeechButton]-12-|", options:[], metrics:nil, views:views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[growingTextView]-6-[speechToTextButton]-6-[textToSpeechButton]", options:[], metrics:nil, views:views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-6.5-[growingTextView]-6.5-|", options:[], metrics:nil, views:views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|->=6-[textToSpeechButton]-6-|", options:[], metrics:nil, views:views))
        self.addConstraint(NSLayoutConstraint.init(item: self.sendButton, attribute: .centerY, relatedBy: .equal, toItem: self.textToSpeechButton, attribute: .centerY, multiplier: 1.0, constant: 1.0))
        self.addConstraint(NSLayoutConstraint.init(item: self.sendButton, attribute: .centerY, relatedBy: .equal, toItem: self.speechToTextButton, attribute: .centerY, multiplier: 1.0, constant: 0.0))
    }
    
    func sendButtonAction(_ sender: AnyObject!) {
        var text = self.growingTextView.textView.text
        text = text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        // is there any text?
        if ((text?.characters.count)! > 0) {
            self.delegate?.composeBarView(self, sendButtonAction: text!)
        }
    }
    
    func textToSpeechButtonAction(_ sender: Any) {
        if self.textToSpeechButton.isSelected {
            self.textToSpeechButton.isSelected = false
            isSpeakingEnabled = false
            NotificationCenter.default.post(name: Notification.Name(stopSpeakingNotification), object: nil)
        }else{
            self.textToSpeechButton.isSelected = true
            isSpeakingEnabled = true
        }
    }
    
    func speechToTextButtonAction(_ sender: AnyObject) {
        self.delegate?.composeBarViewSpeechToTextButtonAction(self)
    }
    
    func valueChanged() {
        let hasText = self.growingTextView.textView.text.characters.count > 0
        self.sendButton.isHidden = !hasText
        self.speechToTextButton.isHidden = hasText
    }
    
    func clear() {
        self.growingTextView.textView.text = "";
        self.valueChanged()
    }
    
    // MARK: Notification handler
    func textDidChangeNotification(_ notification: Notification) {
        self.valueChanged()
    }
    
    // MARK: UIResponder Methods
    
    open override var isFirstResponder: Bool {
        return self.growingTextView.isFirstResponder
    }
    
    open override func becomeFirstResponder() -> Bool {
        return self.growingTextView.becomeFirstResponder()
    }
    
    open override func resignFirstResponder() -> Bool {
        return self.growingTextView.resignFirstResponder()
    }
    
    //MARK:- removing refernces to elements
    func prepareForDeinit(){
        
    }
    
    // MARK:- deinit
    deinit {
        NSLog("ComposeBarView dealloc")
    }
}
