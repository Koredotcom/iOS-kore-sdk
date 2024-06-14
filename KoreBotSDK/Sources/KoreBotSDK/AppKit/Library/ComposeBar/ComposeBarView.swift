//
//  ComposeBarView.swift
//  KoreBotSDKDemo
//
//  Created by Anoop Dhiman on 26/07/17.
//  Copyright © 2017 Kore. All rights reserved.
//

import UIKit

protocol ComposeBarViewDelegate {
    func composeBarView(_: ComposeBarView, sendButtonAction text: String)
    func composeBarViewSpeechToTextButtonAction(_: ComposeBarView)
    func composeBarViewDidBecomeFirstResponder(_: ComposeBarView)
    func composeBarTaskMenuButtonAction(_: ComposeBarView)
    func composeBarAttachmentButtonAction(_: ComposeBarView)
    func showTypingToAgent(_: ComposeBarView)
    func stopTypingToAgent(_: ComposeBarView)
}

class ComposeBarView: UIView {
    let bundle = Bundle.sdkModule
    public var delegate: ComposeBarViewDelegate?
    
    fileprivate var topLineView: UIView!
    fileprivate var bottomLineView: UIView!
    public var growingTextView: KREGrowingTextView!
    fileprivate var sendButton: UIButton!
    fileprivate var menuButton: UIButton!
    fileprivate var attachmentButton: UIButton!
    fileprivate var speechToTextButton: UIButton!

    fileprivate var textViewTrailingConstraint: NSLayoutConstraint!
    fileprivate(set) public var isKeyboardEnabled: Bool = false
    
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
        //self.backgroundColor = UIColor.init(hexString: "#eaeaea")
        
        self.growingTextView = KREGrowingTextView(frame: CGRect.zero)
        self.growingTextView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.growingTextView)
        self.growingTextView.setContentCompressionResistancePriority(UILayoutPriority.defaultLow, for: .horizontal)
        
        self.growingTextView.textView.tintColor = .black
        self.growingTextView.textView.textColor = UIColor.init(hexString: (brandingShared.widgetFooterTextColor) ?? "#26344A")
        self.growingTextView.textView.textAlignment = .right
        self.growingTextView.maxNumberOfLines = 10
        self.growingTextView.font = UIFont(name: regularCustomFont, size: 14.0) ?? UIFont.systemFont(ofSize: 14.0)
        self.growingTextView.textContainerInset = UIEdgeInsets(top: 7, left: 0, bottom: 7, right: 0)
        self.growingTextView.animateHeightChange = true
        self.growingTextView.backgroundColor = .white
        self.growingTextView.layer.cornerRadius = 10.0
        self.growingTextView.isUserInteractionEnabled = false
        //self.growingTextView.textView.text = ""
        
        let attributes: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font: UIFont(name: regularCustomFont, size: 14.0) ?? UIFont.systemFont(ofSize: 14.0), NSAttributedString.Key.foregroundColor: Common.UIColorRGB(0xB5B9BA)]
        self.growingTextView.placeholderAttributedText = NSAttributedString(string: "Message...", attributes:attributes)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.textDidBeginEditingNotification(_ :)), name: UITextView.textDidBeginEditingNotification, object: self.growingTextView.textView)
        NotificationCenter.default.addObserver(self, selector: #selector(self.textDidChangeNotification(_ :)), name: UITextView.textDidChangeNotification, object: self.growingTextView.textView)
        NotificationCenter.default.addObserver(self, selector: #selector(showAttachmentSendButton), name: NSNotification.Name(rawValue: showAttachmentSendButtonNotification), object: nil)
        
        self.menuButton = UIButton.init(frame: CGRect.zero)
        self.menuButton.translatesAutoresizingMaskIntoConstraints = false
        self.menuButton.layer.cornerRadius = 5
        self.menuButton.setTitleColor(Common.UIColorRGB(0xFFFFFF), for: .normal)
        self.menuButton.setTitleColor(Common.UIColorRGB(0x999999), for: .disabled)
        self.menuButton.setImage(UIImage(named: "Menu", in: bundle, compatibleWith: nil), for: .normal)
        self.menuButton.titleLabel?.font = UIFont(name: boldCustomFont, size: 14.0) ?? UIFont.boldSystemFont(ofSize: 14.0)
        self.menuButton.addTarget(self, action: #selector(self.taskMenuButtonAction(_:)), for: .touchUpInside)
        self.menuButton.isHidden = false
        self.menuButton.contentEdgeInsets = UIEdgeInsets(top: 9.0, left: 3.0, bottom: 7.0, right: 3.0)
        self.menuButton.clipsToBounds = true
        self.addSubview(self.menuButton)
        
        self.sendButton = UIButton.init(frame: CGRect.zero)
        self.sendButton.setImage(UIImage(named: "send", in: bundle, compatibleWith: nil), for: .normal)
        self.sendButton.translatesAutoresizingMaskIntoConstraints = false
        self.sendButton.backgroundColor = .clear
        self.sendButton.layer.cornerRadius = 5
        self.sendButton.setTitleColor(Common.UIColorRGB(0xFFFFFF), for: .normal)
        self.sendButton.setTitleColor(Common.UIColorRGB(0x999999), for: .disabled)
        self.sendButton.addTarget(self, action: #selector(self.sendButtonAction(_:)), for: .touchUpInside)
        self.sendButton.isHidden = true
        self.sendButton.contentEdgeInsets = UIEdgeInsets(top: 9.0, left: 3.0, bottom: 7.0, right: 3.0)
        self.sendButton.clipsToBounds = true
        self.addSubview(self.sendButton)
        
        self.speechToTextButton = UIButton.init(frame: CGRect.zero)
        self.speechToTextButton.setTitle("", for: .normal)
        self.speechToTextButton.translatesAutoresizingMaskIntoConstraints = false
        self.speechToTextButton.layer.cornerRadius = 5.0
        self.speechToTextButton.backgroundColor = .clear
        self.speechToTextButton.imageView?.contentMode = .scaleAspectFit
        self.speechToTextButton.setImage(UIImage(named: "audio_icon-1", in: bundle, compatibleWith: nil), for: .normal)
        self.speechToTextButton.addTarget(self, action: #selector(self.speechToTextButtonAction(_:)), for: .touchUpInside)
        self.speechToTextButton.isHidden = true
        self.speechToTextButton.contentEdgeInsets = UIEdgeInsets(top: 6.0, left: 3.0, bottom: 5.0, right: 3.0)
        self.speechToTextButton.clipsToBounds = true
        self.addSubview(self.speechToTextButton)
        
        self.attachmentButton = UIButton.init(frame: CGRect.zero)
        self.attachmentButton.translatesAutoresizingMaskIntoConstraints = false
        self.attachmentButton.layer.cornerRadius = 5
        self.attachmentButton.setTitleColor(Common.UIColorRGB(0xFFFFFF), for: .normal)
        self.attachmentButton.setTitleColor(Common.UIColorRGB(0x999999), for: .disabled)
        self.attachmentButton.setBackgroundImage (UIImage(named: "attach", in: bundle, compatibleWith: nil), for: .normal)
        self.attachmentButton.imageView?.contentMode = .scaleAspectFill
        self.attachmentButton.addTarget(self, action: #selector(self.composeBarAttachmentButtonAction(_:)), for: .touchUpInside)
        
        self.attachmentButton.contentEdgeInsets = UIEdgeInsets(top: 9.0, left: 3.0, bottom: 7.0, right: 3.0)
        self.attachmentButton.clipsToBounds = true
        self.addSubview(self.attachmentButton)
        
        self.topLineView = UIView.init(frame: CGRect.zero)
        self.topLineView.backgroundColor = .clear
        self.topLineView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.topLineView)
        
        self.bottomLineView = UIView.init(frame: CGRect.zero)
        self.bottomLineView.backgroundColor = .clear
        self.bottomLineView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.bottomLineView)
        
        let views: [String : Any] = ["topLineView": self.topLineView, "bottomLineView": self.bottomLineView,"menuButton": self.menuButton, "growingTextView": self.growingTextView, "sendButton": self.sendButton, "speechToTextButton": self.speechToTextButton, "attachmentButton": attachmentButton]
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[topLineView]|", options:[], metrics:nil, views:views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[topLineView(0.5)]", options:[], metrics:nil, views:views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[bottomLineView]|", options:[], metrics:nil, views:views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[bottomLineView(0.5)]|", options:[], metrics:nil, views:views))
        
        var menuBtnWidth = 0
        menuBtnWidth = isShowComposeMenuBtn == true ? 30 : 0
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[menuButton(\(menuBtnWidth))]-5-[growingTextView]-5-[sendButton(30)]-5-[attachmentButton(25)]-10-|", options:[], metrics:nil, views:views))
       self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[growingTextView]-5-[speechToTextButton]-5-[attachmentButton]-10-|", options:[], metrics:nil, views:views))
       self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-7-[growingTextView]-7-|", options:[], metrics:nil, views:views))
       self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|->=3-[sendButton]-3-|", options:[], metrics:nil, views:views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|->=6-[menuButton]-6-|", options:[], metrics:nil, views:views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|->=3-[attachmentButton(25)]-8-|", options:[], metrics:nil, views:views))
       self.addConstraint(NSLayoutConstraint.init(item: self.sendButton as Any, attribute: .centerY, relatedBy: .equal, toItem: self.speechToTextButton, attribute: .centerY, multiplier: 1.0, constant: 0.0))
       self.addConstraint(NSLayoutConstraint.init(item: self.sendButton as Any, attribute: .height, relatedBy: .equal, toItem: self.speechToTextButton, attribute: .height, multiplier: 1.0, constant: 0.0))
       self.speechToTextButton.setContentHuggingPriority(UILayoutPriority.defaultLow, for: .horizontal)
       self.speechToTextButton.setContentHuggingPriority(UILayoutPriority.defaultLow, for: .vertical)
       self.speechToTextButton.setContentCompressionResistancePriority(UILayoutPriority.defaultLow, for: .horizontal)
       self.speechToTextButton.setContentCompressionResistancePriority(UILayoutPriority.defaultLow, for: .vertical)
       
       self.textViewTrailingConstraint = NSLayoutConstraint.init(item: self, attribute: .trailing, relatedBy: .equal, toItem: self.growingTextView, attribute: .trailing, multiplier: 1.0, constant: 15.0)
       self.addConstraint(self.textViewTrailingConstraint)
    }
    
    func brandingChnages(){
        
        let attributes: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font: UIFont(name: regularCustomFont, size: 14.0) ?? UIFont.systemFont(ofSize: 14.0), NSAttributedString.Key.foregroundColor: UIColor.init(hexString: (brandingShared.widgetFooterPlaceholderColor) ?? "#000000")]
        self.growingTextView.placeholderAttributedText = NSAttributedString(string: "Message...", attributes:attributes)
        
        self.growingTextView.textView.tintColor = UIColor.init(hexString: (brandingShared.widgetFooterTextColor) ?? "#26344A")
        self.growingTextView.textView.textColor = UIColor.init(hexString: (brandingShared.widgetFooterTextColor) ?? "#26344A")
        self.growingTextView.layer.borderColor =  UIColor.init(hexString: (brandingShared.widgetFooterBorderColor) ?? "#000000").cgColor
        self.growingTextView.layer.borderWidth = 1.0
        self.growingTextView.clipsToBounds = true
        
        let buttonBgColor = UIColor.init(hexString: "#a9acb0")
        let attachmentImage = UIImage(named: "attach", in: bundle, compatibleWith: nil)
        let tintedAttachmentImage = attachmentImage?.withRenderingMode(.alwaysTemplate)
        attachmentButton.setBackgroundImage(tintedAttachmentImage, for: .normal)
        attachmentButton.tintColor = buttonBgColor
    
        let speachTxtImage = UIImage(named: "audio_icon-1", in: bundle, compatibleWith: nil)
        let tintedSpeachTxtImageImage = speachTxtImage?.withRenderingMode(.alwaysTemplate)
        speechToTextButton.setImage(tintedSpeachTxtImageImage, for: .normal)
        speechToTextButton.tintColor = buttonBgColor
        
        
        let menuImage = UIImage(named: "Menu", in: bundle, compatibleWith: nil)
        let tintedMenuImage = menuImage?.withRenderingMode(.alwaysTemplate)
        menuButton.setImage(tintedMenuImage, for: .normal)
        menuButton.tintColor = buttonBgColor
        
        let sendBtnImage = UIImage(named: "send", in: bundle, compatibleWith: nil)
        let tintedsendImage = sendBtnImage?.withRenderingMode(.alwaysTemplate)
        sendButton.setImage(tintedsendImage, for: .normal)
        sendButton.tintColor = buttonBgColor
        
    }
    
    //MARK: Public methods
    public func clear() {
        self.clearButtonAction(self)
    }
    
    public func configureViewForKeyboard(_ enable: Bool) {
        self.textViewTrailingConstraint.isActive = !enable
        self.isKeyboardEnabled = enable
        self.growingTextView.textView.textAlignment = enable ? .left : .right
        self.growingTextView.isUserInteractionEnabled = enable
        self.valueChanged()
    }
    
    public func setText(_ text: String) -> Void {
        self.growingTextView.textView.text = text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        self.textDidChangeNotification(Notification(name: UITextView.textDidChangeNotification))
    }
    
    //MARK: Private methods
    
    @objc fileprivate func clearButtonAction(_ sender: AnyObject!) {
        self.growingTextView.textView.text = "";
        self.textDidChangeNotification(Notification(name: UITextView.textDidChangeNotification))
    }
    
    @objc fileprivate func sendButtonAction(_ sender: AnyObject!) {
        var text = self.growingTextView.textView.text
        text = text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        // is there any text?
        if attachmentKeybord{
            self.delegate?.composeBarView(self, sendButtonAction: text ?? "")
        }else{
            if ((text?.count)! > 0) {
                self.delegate?.composeBarView(self, sendButtonAction: text!)
            }
        }
        
    }
    @objc fileprivate func taskMenuButtonAction(_ sender: UIButton!) {
        self.delegate?.composeBarTaskMenuButtonAction(self)
        self.menuButton.setImage(UIImage(named: "Menu", in: bundle, compatibleWith: nil), for: .normal)
        self.growingTextView.isUserInteractionEnabled = true
        self.sendButton.isUserInteractionEnabled = true
        self.speechToTextButton.isUserInteractionEnabled = true
    }
    @objc fileprivate func composeBarAttachmentButtonAction(_ sender: UIButton!) {
        self.delegate?.composeBarAttachmentButtonAction(self)
    }
    
    
    @objc fileprivate func speechToTextButtonAction(_ sender: AnyObject) {
        self.delegate?.composeBarViewSpeechToTextButtonAction(self)
    }
    
    fileprivate func valueChanged() {
        let hasText = self.growingTextView.textView.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).count > 0
        self.sendButton.isEnabled = hasText
        if self.isKeyboardEnabled {
            self.attachmentButton.isHidden = false
            if attachmentKeybord{
                self.sendButton.isHidden = false
                self.sendButton.isEnabled = true
                self.speechToTextButton.isHidden = true
            }else{
                self.sendButton.isHidden = !hasText
                self.speechToTextButton.isHidden = hasText
            }
            self.menuButton.isHidden = false
        }else{
            self.sendButton.isHidden = true
            self.speechToTextButton.isHidden = true
            self.menuButton.isHidden = true
            self.attachmentButton.isHidden = true
        }
    }
    
    // MARK: Notification handler
    @objc fileprivate func textDidBeginEditingNotification(_ notification: Notification) {
        self.delegate?.composeBarViewDidBecomeFirstResponder(self)
    }
    
    @objc fileprivate func textDidChangeNotification(_ notification: Notification) {
        self.valueChanged()
        if isAgentConnect{
            var text = self.growingTextView.textView.text
            text = text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            if text?.count == 0{
                self.delegate?.stopTypingToAgent(self)
            }else{
                self.delegate?.showTypingToAgent(self)
            }
        }
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
    @objc func showAttachmentSendButton(notification:Notification){
        self.valueChanged()
    }
    
    // MARK:- deinit
    deinit {
        self.topLineView = nil
        self.bottomLineView = nil
        self.growingTextView = nil
        self.sendButton = nil
        self.speechToTextButton = nil
        self.textViewTrailingConstraint = nil
    }
}
