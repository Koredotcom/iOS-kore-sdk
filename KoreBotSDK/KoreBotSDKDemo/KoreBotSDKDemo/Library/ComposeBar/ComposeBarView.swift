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
    func composeBarViewDidBecomeFirstResponder(_: ComposeBarView)
}

class ComposeBarView: UIView {

    public var delegate: ComposeBarViewDelegate?
    
    fileprivate var topLineView: UIView!
    fileprivate var bottomLineView: UIView!
    public var growingTextView: KREGrowingTextView!
    fileprivate var clearButton: UIButton!
    fileprivate var sendButton: UIButton!
    fileprivate var speechToTextButton: UIButton!
    fileprivate var textToSpeechButton: UIButton!
    public var contentView: UIView!
    
    fileprivate var contentViewHeightConstraint: NSLayoutConstraint!
    fileprivate var textToSpeechButtonWidthConstraint: NSLayoutConstraint!
    fileprivate var mainString: String!
    fileprivate var intermediateString: String!
    fileprivate var isSpeechEnabled: Bool = false
    
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
        self.backgroundColor = Common.UIColorRGB(0xF9F9F9)
        
        self.contentView = UIView.init(frame: CGRect.zero)
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.contentView)
        
        self.growingTextView = KREGrowingTextView.init(frame: CGRect.zero)
        self.growingTextView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.growingTextView)
        self.growingTextView.setContentCompressionResistancePriority(UILayoutPriorityDefaultLow, for: .horizontal)
        
        self.growingTextView.maxNumberOfLines = 10
        self.growingTextView.font = UIFont(name: "HelveticaNeue", size: 14.0)!
        self.growingTextView.textContainerInset = UIEdgeInsets(top: 7, left: 5, bottom: 7, right: 20)
        self.growingTextView.animateHeightChange = true
        
        self.growingTextView.layer.borderColor = Common.UIColorRGB(0xCCCFD0).cgColor
        self.growingTextView.layer.borderWidth = 0.5
        self.growingTextView.layer.cornerRadius = 14
        self.growingTextView.backgroundColor = UIColor.white
        
        let attributes: [String : Any] = [NSFontAttributeName: UIFont(name: "HelveticaNeue", size: 14.0)!, NSForegroundColorAttributeName: Common.UIColorRGB(0xB5B9BA)]
        self.growingTextView.placeholderAttributedText = NSAttributedString(string: "Say Something...", attributes:attributes)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.textDidBeginEditingNotification(_ :)), name: NSNotification.Name.UITextViewTextDidBeginEditing, object: self.growingTextView.textView)
        NotificationCenter.default.addObserver(self, selector: #selector(self.textDidChangeNotification(_ :)), name: NSNotification.Name.UITextViewTextDidChange, object: self.growingTextView.textView)
        
        self.clearButton = UIButton.init(frame: CGRect.zero)
        self.clearButton.setTitle("", for: .normal)
        self.clearButton.translatesAutoresizingMaskIntoConstraints = false
        self.clearButton.setImage(UIImage(named: "clear_icon"), for: .normal)
        self.clearButton.setImage(UIImage(named: "clear_icon"), for: .highlighted)
        self.clearButton.addTarget(self, action: #selector(self.clearButtonAction(_:)), for: .touchUpInside)
        self.clearButton.isHidden = true
        self.addSubview(self.clearButton)
        
        self.sendButton = UIButton.init(frame: CGRect.zero)
        self.sendButton.setTitle("Send", for: .normal)
        self.sendButton.translatesAutoresizingMaskIntoConstraints = false
        self.sendButton.setTitleColor(Common.UIColorRGB(0x007AFF), for: .normal)
        self.sendButton.setTitleColor(Common.UIColorRGB(0x999999), for: .disabled)
        self.sendButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 14.0)!
        self.sendButton.addTarget(self, action: #selector(self.sendButtonAction(_:)), for: .touchUpInside)
        self.sendButton.isHidden = true
        self.sendButton.contentEdgeInsets = UIEdgeInsetsMake(9.0, 3.0, 7.0, 3.0)
        self.addSubview(self.sendButton)
        
        self.speechToTextButton = UIButton.init(frame: CGRect.zero)
        self.speechToTextButton.setTitle("", for: .normal)
        self.speechToTextButton.translatesAutoresizingMaskIntoConstraints = false
        self.speechToTextButton.setImage(UIImage(named: "audio_icon_select"), for: .normal)
        self.speechToTextButton.addTarget(self, action: #selector(self.speechToTextButtonAction(_:)), for: .touchUpInside)
        self.speechToTextButton.contentEdgeInsets = UIEdgeInsetsMake(6.0, 3.0, 5.0, 3.0)
        self.addSubview(self.speechToTextButton)
        
        self.textToSpeechButton = UIButton.init(frame: CGRect.zero)
        self.textToSpeechButton.setTitle("", for: .normal)
        self.textToSpeechButton.translatesAutoresizingMaskIntoConstraints = false
        self.textToSpeechButton.setImage(UIImage(named: "SpeakerMuteIcon"), for: .normal)
        self.textToSpeechButton.setImage(UIImage(named: "SpeakerIcon.png"), for: .selected)
        self.textToSpeechButton.addTarget(self, action: #selector(self.textToSpeechButtonAction(_:)), for: .touchUpInside)
        self.textToSpeechButton.contentEdgeInsets = UIEdgeInsetsMake(0.0, 4.0, 1.0, 4.0)
        self.addSubview(self.textToSpeechButton)
        
        self.topLineView = UIView.init(frame: CGRect.zero)
        self.topLineView.backgroundColor = Common.UIColorRGB(0xD7D9DA)
        self.topLineView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.topLineView)
        
        self.bottomLineView = UIView.init(frame: CGRect.zero)
        self.bottomLineView.backgroundColor = Common.UIColorRGB(0xD7D9DA)
        self.bottomLineView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.bottomLineView)
        
        let views: [String : Any] = ["topLineView": self.topLineView, "bottomLineView": self.bottomLineView, "growingTextView": self.growingTextView,  "clearButton": self.clearButton, "sendButton": self.sendButton, "speechToTextButton": self.speechToTextButton, "textToSpeechButton": self.textToSpeechButton, "contentView": self.contentView]
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[contentView]|", options:[], metrics:nil, views:views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[contentView]|", options:[], metrics:nil, views:views))
        self.contentViewHeightConstraint = NSLayoutConstraint.init(item: self.contentView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 0.0)
        self.addConstraint(self.contentViewHeightConstraint)
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[topLineView]|", options:[], metrics:nil, views:views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[topLineView(0.5)]", options:[], metrics:nil, views:views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[bottomLineView]|", options:[], metrics:nil, views:views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[bottomLineView(0.5)][contentView]", options:[], metrics:nil, views:views))
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[growingTextView]-3-[sendButton][textToSpeechButton]-|", options:[], metrics:nil, views:views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[growingTextView]-3-[speechToTextButton][textToSpeechButton]", options:[], metrics:nil, views:views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-7-[growingTextView]-7-[contentView]", options:[], metrics:nil, views:views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|->=6-[sendButton]-6-[contentView]", options:[], metrics:nil, views:views))
        self.addConstraint(NSLayoutConstraint.init(item: self.sendButton, attribute: .centerY, relatedBy: .equal, toItem: self.textToSpeechButton, attribute: .centerY, multiplier: 1.0, constant: 0.0))
        self.addConstraint(NSLayoutConstraint.init(item: self.sendButton, attribute: .centerY, relatedBy: .equal, toItem: self.speechToTextButton, attribute: .centerY, multiplier: 1.0, constant: 0.0))
        self.textToSpeechButtonWidthConstraint = NSLayoutConstraint.init(item: self.textToSpeechButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 0.0)
        self.addConstraint(self.textToSpeechButtonWidthConstraint)
        self.textToSpeechButtonWidthConstraint.isActive = false
        
        self.addConstraint(NSLayoutConstraint.init(item: self.clearButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 20.0))
        self.addConstraint(NSLayoutConstraint.init(item: self.clearButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 20.0))
        self.addConstraint(NSLayoutConstraint.init(item: self.clearButton, attribute: .trailing, relatedBy: .equal, toItem: self.growingTextView, attribute: .trailing, multiplier: 1.0, constant: -5.5))
        self.addConstraint(NSLayoutConstraint.init(item: self.clearButton, attribute: .top, relatedBy: .equal, toItem: self.growingTextView, attribute: .top, multiplier: 1.0, constant: 5.5))
    }
    
    //MARK: Public methods
    
    public func addSubComposeView(_ view: UIView) {
        self.contentViewHeightConstraint.isActive = false
        self.contentView.addSubview(view)
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|", options:[], metrics:nil, views:["view" : view]))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|", options:[], metrics:nil, views:["view" : view]))
        self.contentView.layoutIfNeeded()
    }
    
    public func removeSubComposeView(_ view: UIView) {
        view.removeFromSuperview()
        self.contentViewHeightConstraint.isActive = true
    }
    
    public func clear() {
        self.clearButtonAction(self.clearButton)
    }
    
    public func configureViewForSpeech(_ enable: Bool) {
        if enable {
            self.textToSpeechEnable(false)
        }
        self.textToSpeechButtonWidthConstraint.isActive = enable
        self.textToSpeechButton.isHidden = enable
        self.isSpeechEnabled = enable
        self.valueChanged()
    }
    
    // MARK: Speech Output - sttDelegate
    public func onReceiveMessageFromSTTClient(dataDictionary: [AnyHashable : Any]?) -> Void {
        if(dataDictionary == nil){
            return;
        }
        let final:Bool = (dataDictionary!["final"] as? Bool)!
        let hypotheses:NSDictionary! = (dataDictionary!["hypotheses"] as! NSArray!).firstObject as! NSDictionary!
        var str:String = hypotheses.value(forKey: "transcript") as! String
        str = str.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let transcript:String = str.characters.count > 0 ? str + " " : ""
        
        DispatchQueue.main.async {
            if final{
                self.mainString.append(transcript)
                self.growingTextView.textView.text = self.mainString
                self.intermediateString = ""
            }else{
                self.intermediateString = self.mainString.copy() as! String
                self.intermediateString.append(transcript)
                self.growingTextView.textView.text = self.intermediateString
            }
            self.textDidChangeNotification(Notification(name: NSNotification.Name.UITextViewTextDidChange))
        }
    }
    
    //MARK: Private methods
    
    @objc fileprivate func clearButtonAction(_ sender: AnyObject!) {
        self.growingTextView.textView.text = "";
        self.mainString = ""
        self.textDidChangeNotification(Notification(name: NSNotification.Name.UITextViewTextDidChange))
    }
    
    @objc fileprivate func sendButtonAction(_ sender: AnyObject!) {
        var text = self.growingTextView.textView.text
        text = text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        // is there any text?
        if ((text?.characters.count)! > 0) {
            self.delegate?.composeBarView(self, sendButtonAction: text!)
        }
    }
    
    @objc fileprivate func textToSpeechButtonAction(_ sender: Any) {
        self.textToSpeechEnable(!self.textToSpeechButton.isSelected)
    }
    
    @objc fileprivate func speechToTextButtonAction(_ sender: AnyObject) {
        self.mainString = self.growingTextView.textView.text
        self.delegate?.composeBarViewSpeechToTextButtonAction(self)
    }
    
    fileprivate func valueChanged() {
        let hasText = self.growingTextView.textView.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).characters.count > 0
        self.sendButton.isEnabled = hasText
        self.clearButton.isHidden = !hasText
        if self.isSpeechEnabled {
            self.sendButton.isHidden = false
            self.speechToTextButton.isHidden = true
        }else{
            self.sendButton.isHidden = !hasText
            self.speechToTextButton.isHidden = hasText
        }
    }
    
    fileprivate func textToSpeechEnable(_ enable: Bool) {
        self.textToSpeechButton.isSelected = enable
        isSpeakingEnabled = enable
        if !enable {
            NotificationCenter.default.post(name: Notification.Name(stopSpeakingNotification), object: nil)
        }
    }
    
    // MARK: Notification handler
    @objc fileprivate func textDidBeginEditingNotification(_ notification: Notification) {
        self.delegate?.composeBarViewDidBecomeFirstResponder(self)
    }
    
    @objc fileprivate func textDidChangeNotification(_ notification: Notification) {
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
    
    // MARK:- deinit
    deinit {
//        NSLog("ComposeBarView dealloc")
        self.topLineView = nil
        self.bottomLineView = nil
        self.growingTextView = nil
        self.clearButton = nil
        self.sendButton = nil
        self.speechToTextButton = nil
        self.textToSpeechButton = nil
        self.contentView = nil
        self.contentViewHeightConstraint = nil
        self.textToSpeechButtonWidthConstraint = nil
        self.mainString = nil
        self.intermediateString = nil
    }
}
