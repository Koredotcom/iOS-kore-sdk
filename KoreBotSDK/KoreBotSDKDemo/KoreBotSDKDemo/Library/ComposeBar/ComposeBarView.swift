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
}

class ComposeBarView: UIView {

    var delegate: ComposeBarViewDelegate?
    
    var topLineView: UIView!
    var bottomLineView: UIView!
    var growingTextView: KREGrowingTextView!
    var sendButton: UIButton!
    var textToSpeechButton: UIButton!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    func setup() {
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
        
        self.sendButton = UIButton.init(frame: CGRect.zero)
        self.sendButton.setTitle("Send", for: .normal)
        self.sendButton.translatesAutoresizingMaskIntoConstraints = false
        self.sendButton.setTitleColor(Common.UIColorRGB(0x007AFF), for: .normal)
        self.sendButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 14.0)!
        self.sendButton.addTarget(self, action: #selector(self.sendButtonAction(_:)), for: .touchUpInside)
        self.addSubview(self.sendButton)
        
        self.textToSpeechButton = UIButton.init(frame: CGRect.zero)
        self.textToSpeechButton.setTitle("", for: .normal)
        self.textToSpeechButton.translatesAutoresizingMaskIntoConstraints = false
        self.textToSpeechButton.setImage(UIImage(named: "SpeakerMuteIcon"), for: .normal)
        self.textToSpeechButton.setImage(UIImage(named: "SpeakerIcon.png"), for: .selected)
        self.textToSpeechButton.addTarget(self, action: #selector(self.textToSpeechButtonAction(_:)), for: .touchUpInside)
        self.addSubview(self.textToSpeechButton)
        
        let views: [String : Any] = ["topLineView": self.topLineView, "bottomLineView": self.bottomLineView, "growingTextView": self.growingTextView, "sendButton": self.sendButton, "textToSpeechButton": self.textToSpeechButton]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[topLineView]|", options:[], metrics:nil, views:views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[topLineView(0.5)]", options:[], metrics:nil, views:views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[bottomLineView]|", options:[], metrics:nil, views:views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[bottomLineView(0.5)]|", options:[], metrics:nil, views:views))
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[growingTextView]-6-[sendButton]-6-[textToSpeechButton]-12-|", options:[], metrics:nil, views:views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-6.5-[growingTextView]-6.5-|", options:[], metrics:nil, views:views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|->=6-[textToSpeechButton]-6-|", options:[], metrics:nil, views:views))
        self.addConstraint(NSLayoutConstraint.init(item: self.sendButton, attribute: .centerY, relatedBy: .equal, toItem: self.textToSpeechButton, attribute: .centerY, multiplier: 1.0, constant: 1.0))
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
        
    }
    
    func clear() {
        self.growingTextView.textView.text = "";
    }
    
    //MARK: UIResponder Methods
    
    open override var isFirstResponder: Bool {
        return self.growingTextView.isFirstResponder
    }
    
    open override func becomeFirstResponder() -> Bool {
        return self.growingTextView.becomeFirstResponder()
    }
    
    open override func resignFirstResponder() -> Bool {
        return self.growingTextView.resignFirstResponder()
    }
}
