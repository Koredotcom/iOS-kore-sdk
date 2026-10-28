//
//  ComposeBarView.swift
//  KoreBotSDKDemo
//
//  Created by Anoop Dhiman on 26/07/17.
//  Copyright © 2017 Kore. All rights reserved.
//

import UIKit
import KoreBotSDK

public protocol ComposeBarViewDelegate {
    func composeBarView(_: ComposeBarView, sendButtonAction text: String)
    func composeBarViewSpeechToTextButtonAction(_: ComposeBarView)
    func composeBarViewDidBecomeFirstResponder(_: ComposeBarView)
    func composeBarTaskMenuButtonAction(_: ComposeBarView)
    func composeBarAttachmentButtonAction(_: ComposeBarView)
    func showTypingToAgent(_: ComposeBarView)
    func stopTypingToAgent(_: ComposeBarView)
}

open class ComposeBarView: UIView {
    let bundle = Bundle.sdkModule
    public var delegate: ComposeBarViewDelegate?
    public var clickToCallAction: (() -> Void)?
    fileprivate var topLineView: UIView!
    fileprivate var bottomLineView: UIView!
    public var growingTextView: KREGrowingTextView!
    fileprivate var sendButton: UIButton!
    fileprivate var menuButton: UIButton!
    fileprivate var attachmentButton: UIButton!
    fileprivate var speechToTextButton: UIButton!
    fileprivate var clickToCallButton: UIButton!
    fileprivate var textViewTrailingConstraint: NSLayoutConstraint!
    fileprivate(set) public var isKeyboardEnabled: Bool = false
    var isHideSpeeachToTextBtn = false
    var footerDic = FooterModel()
    var bgColor: String?
    var txtViewBgColor: String?
    var txtViewBorderColor: String?
    var txtViewPlaceHolderTxt: String?
    
    public var koreFooterViewMenuButtonAction: (() -> Void)?
    public var koreFooterViewSpechToTextButtonAction: (() -> Void)?
    public var koreFooterViewSendButtonAction: ((_ text: String?) -> Void)?
    public var koreFooterViewAttachmentButtonAction: (() -> Void)?
    public var koreFooterViewBranding: ((_ dic: FooterModel?) -> Void)?
    public var koreFooterViewClickToCallButtonAction: (() -> Void)?
    
    public convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
    }
    
     required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupViews()
    }
    
    open func setupViews() {
        if dynamicFooterview != nil{
            self.addSubview(dynamicFooterview!)
            growingTextView = dynamicGrowingTxtv
            dynamicFooterview?.koreFooterViewBranding?(brandingValues.footer)
            dynamicFooterview?.translatesAutoresizingMaskIntoConstraints = false
            let views: [String : Any] = ["dynamicFooterview": dynamicFooterview]
            
            self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[dynamicFooterview]|", options:[], metrics:nil, views:views))
            self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[dynamicFooterview]|", options:[], metrics:nil, views:views))
            
            self.textViewTrailingConstraint = NSLayoutConstraint.init(item: self, attribute: .trailing, relatedBy: .equal, toItem: self.growingTextView, attribute: .trailing, multiplier: 1.0, constant: 15.0)
             self.addConstraint(self.textViewTrailingConstraint)
            
            dynamicFooterview?.koreFooterViewMenuButtonAction = { [weak self]  in
                self?.dynamicFooterViewMenuBtnAction()
            }
            dynamicFooterview?.koreFooterViewSendButtonAction = { [weak self] text in
                self?.dynamicFooterViewSendTextBtnAction()
            }
            dynamicFooterview?.koreFooterViewSpechToTextButtonAction = { [weak self]  in
                self?.dynamicFooterViewSpeacToTextBtnAction()
            }
           
            dynamicFooterview?.koreFooterViewAttachmentButtonAction = { [weak self]  in
                self?.dynamicFooterViewAttachmentBtnAction()
            }
            
            dynamicFooterview?.koreFooterViewClickToCallButtonAction = { [weak self]  in
                self?.clickToCallAction?()
            }
            
            NotificationCenter.default.addObserver(self, selector: #selector(self.textDidBeginEditingNotification(_ :)), name: UITextView.textDidBeginEditingNotification, object: self.growingTextView.textView)
            NotificationCenter.default.addObserver(self, selector: #selector(self.textDidChangeNotification(_ :)), name: UITextView.textDidChangeNotification, object: self.growingTextView.textView)
            NotificationCenter.default.addObserver(self, selector: #selector(showAttachmentSendButton), name: NSNotification.Name(rawValue: showAttachmentSendButtonNotification), object: nil)
        }else{
            if let footerDic = brandingValues.footer{
                self.footerDic = footerDic
            }
            bgColor = footerDic.bg_color
            self.backgroundColor = UIColor.init(hexString: bgColor ?? "#EEF2F6")
            txtViewBgColor = footerDic.compose_bar?.bg_color
            txtViewBorderColor = footerDic.compose_bar?.outline_color
            txtViewPlaceHolderTxt = footerDic.compose_bar?.placeholder
            let menuBtnWidth = footerDic.buttons?.menu?.show == true ? 30 : 00
            let attachmentBtnWidth = footerDic.buttons?.attachment?.show == true ? 25 : 00
            let speeachToTextBtnWidth = footerDic.buttons?.microphone?.show == true ? 30 : 00
            isHideSpeeachToTextBtn = footerDic.buttons?.microphone?.show == true ? true : false

            self.growingTextView = KREGrowingTextView(frame: CGRect.zero)
            self.growingTextView.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(self.growingTextView)
            self.growingTextView.setContentCompressionResistancePriority(UILayoutPriority.defaultLow, for: .horizontal)
            
            self.growingTextView.textView.tintColor = .black
            self.growingTextView.textView.textColor = .black
            self.growingTextView.textView.textAlignment = .right
            self.growingTextView.maxNumberOfLines = 10
            self.growingTextView.font = UIFont(name: regularCustomFont, size: 14.0) ?? UIFont.systemFont(ofSize: 14.0)
            self.growingTextView.textContainerInset = UIEdgeInsets(top: 7, left: 0, bottom: 7, right: 0)
            self.growingTextView.animateHeightChange = true
            self.growingTextView.backgroundColor = UIColor.init(hexString: txtViewBgColor ?? "#ffffff")
            self.growingTextView.layer.borderWidth = 1.0
            self.growingTextView.layer.borderColor = UIColor.init(hexString: txtViewBorderColor ?? "#EEF2F6").cgColor
            self.growingTextView.layer.cornerRadius = 4.0
            self.growingTextView.isUserInteractionEnabled = false
            
            let attributes: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font: UIFont(name: regularCustomFont, size: 14.0) ?? UIFont.systemFont(ofSize: 14.0), NSAttributedString.Key.foregroundColor: Common.UIColorRGB(0xB5B9BA)]
            self.growingTextView.placeholderAttributedText = NSAttributedString(string: txtViewPlaceHolderTxt ?? "Type a message", attributes:attributes)
            
            NotificationCenter.default.addObserver(self, selector: #selector(self.textDidBeginEditingNotification(_ :)), name: UITextView.textDidBeginEditingNotification, object: self.growingTextView.textView)
            NotificationCenter.default.addObserver(self, selector: #selector(self.textDidChangeNotification(_ :)), name: UITextView.textDidChangeNotification, object: self.growingTextView.textView)
            NotificationCenter.default.addObserver(self, selector: #selector(showAttachmentSendButton), name: NSNotification.Name(rawValue: showAttachmentSendButtonNotification), object: nil)
            
            self.menuButton = UIButton.init(frame: CGRect.zero)
            self.menuButton.translatesAutoresizingMaskIntoConstraints = false
            self.menuButton.layer.cornerRadius = 5
            self.menuButton.setTitleColor(Common.UIColorRGB(0xFFFFFF), for: .normal)
            self.menuButton.setTitleColor(Common.UIColorRGB(0x999999), for: .disabled)
            self.menuButton.setImage(UIImage(named: "Menu", in: bundle, compatibleWith: nil), for: .normal)
            self.menuButton.titleLabel?.font = UIFont(name: boldCustomFont, size: 14.0)
            self.menuButton.addTarget(self, action: #selector(self.taskMenuButtonAction(_:)), for: .touchUpInside)
            self.menuButton.isHidden = false
            self.menuButton.contentEdgeInsets = UIEdgeInsets(top: 9.0, left: 3.0, bottom: 7.0, right: 3.0)
            self.menuButton.clipsToBounds = true
            self.addSubview(self.menuButton)
            
            self.sendButton = UIButton.init(frame: CGRect.zero)
            //self.sendButton.setTitle("Send", for: .normal)
            self.sendButton.setImage(UIImage(named: "SendW", in: bundle, compatibleWith: nil), for: .normal)
            self.sendButton.translatesAutoresizingMaskIntoConstraints = false
            self.sendButton.backgroundColor = themeColor
            self.sendButton.layer.cornerRadius = 5
            self.sendButton.setTitleColor(Common.UIColorRGB(0xFFFFFF), for: .normal)
            self.sendButton.setTitleColor(Common.UIColorRGB(0x999999), for: .disabled)
            self.sendButton.titleLabel?.font = UIFont(name: boldCustomFont, size: 14.0)
            self.sendButton.addTarget(self, action: #selector(self.sendButtonAction(_:)), for: .touchUpInside)
            self.sendButton.isHidden = true
            self.sendButton.contentEdgeInsets = UIEdgeInsets(top: 9.0, left: 3.0, bottom: 7.0, right: 3.0)
            self.sendButton.clipsToBounds = true
            self.addSubview(self.sendButton)
            
            self.speechToTextButton = UIButton.init(frame: CGRect.zero)
            self.speechToTextButton.setTitle("", for: .normal)
            self.speechToTextButton.translatesAutoresizingMaskIntoConstraints = false
            self.speechToTextButton.setImage(UIImage(named: "audio_icon_1", in: bundle, compatibleWith: nil), for: .normal)
            self.speechToTextButton.layer.cornerRadius = 5.0
            self.speechToTextButton.backgroundColor = .clear
            self.speechToTextButton.imageView?.contentMode = .scaleAspectFit
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
            self.attachmentButton.setBackgroundImage(UIImage(named: "attach", in: bundle, compatibleWith: nil), for: .normal)
            self.attachmentButton.imageView?.contentMode = .scaleAspectFill
            self.attachmentButton.titleLabel?.font = UIFont(name: boldCustomFont, size: 14.0)
            self.attachmentButton.addTarget(self, action: #selector(self.composeBarAttachmentButtonAction(_:)), for: .touchUpInside)
            
            self.attachmentButton.contentEdgeInsets = UIEdgeInsets(top: 9.0, left: 3.0, bottom: 7.0, right: 3.0)
            self.attachmentButton.clipsToBounds = true
            self.addSubview(self.attachmentButton)

            let clickToCallWidth = footerDic.buttons?.click_to_call?.show == true ? 30 : 0
            self.clickToCallButton = UIButton(type: .system)
            self.clickToCallButton.translatesAutoresizingMaskIntoConstraints = false
            self.clickToCallButton.backgroundColor = .clear
            self.clickToCallButton.accessibilityLabel = "Call a voice agent"
            self.clickToCallButton.addTarget(self, action: #selector(clickToCallButtonAction), for: .touchUpInside)
            self.clickToCallButton.isHidden = clickToCallWidth == 0
            self.clickToCallButton.isEnabled = false
            if let icon = footerDic.buttons?.click_to_call?.icon,
               !icon.isEmpty, let image = UIImage(named: icon, in: bundle, compatibleWith: nil) {
                self.clickToCallButton.setImage(image.withRenderingMode(.alwaysTemplate), for: .normal)
            } else if #available(iOS 13.0, *) {
                self.clickToCallButton.setImage(UIImage(systemName: "phone.fill"), for: .normal)
            } else {
                self.clickToCallButton.setTitle("☎", for: .normal)
            }
            self.clickToCallButton.imageView?.contentMode = .scaleAspectFit
            self.addSubview(self.clickToCallButton)
            
            self.topLineView = UIView.init(frame: CGRect.zero)
            self.topLineView.backgroundColor = .clear
            self.topLineView.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(self.topLineView)
            
            self.bottomLineView = UIView.init(frame: CGRect.zero)
            self.bottomLineView.backgroundColor = .clear
            self.bottomLineView.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(self.bottomLineView)
            
            let views: [String : Any] = ["topLineView": self.topLineView as Any, "bottomLineView": self.bottomLineView as Any,"menuButton": self.menuButton as Any, "growingTextView": self.growingTextView as Any, "sendButton": self.sendButton as Any, "speechToTextButton": self.speechToTextButton as Any, "attachmentButton": attachmentButton as Any, "clickToCallButton": clickToCallButton as Any]
            
            self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[topLineView]|", options:[], metrics:nil, views:views))
            self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[topLineView(0.5)]", options:[], metrics:nil, views:views))
            self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[bottomLineView]|", options:[], metrics:nil, views:views))
            self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[bottomLineView(0.5)]|", options:[], metrics:nil, views:views))
            

            let callToTextSpacing = clickToCallWidth > 0 ? 5 : 0
            self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[menuButton(\(menuBtnWidth))]-2-[attachmentButton(\(attachmentBtnWidth))]-5-[clickToCallButton(\(clickToCallWidth))]-\(callToTextSpacing)-[growingTextView]-8-[sendButton(35)]-8-|", options:[], metrics:nil, views:views))
            self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[attachmentButton]-5-[clickToCallButton(\(clickToCallWidth))]-\(callToTextSpacing)-[growingTextView]-8-[speechToTextButton(\(speeachToTextBtnWidth))]-13-|", options:[], metrics:nil, views:views))
            self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-7-[growingTextView]-7-|", options:[], metrics:nil, views:views))
            self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|->=6-[sendButton]-6-|", options:[], metrics:nil, views:views))
             self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|->=6-[menuButton]-6-|", options:[], metrics:nil, views:views))
             self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|->=6-[attachmentButton(25)]-10-|", options:[], metrics:nil, views:views))
            self.addConstraint(NSLayoutConstraint.init(item: clickToCallButton as Any, attribute: .centerY, relatedBy: .equal, toItem: growingTextView as Any, attribute: .centerY, multiplier: 1.0, constant: 0.0))
            self.addConstraint(NSLayoutConstraint.init(item: clickToCallButton as Any, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 30.0))
            self.addConstraint(NSLayoutConstraint.init(item: self.sendButton as Any, attribute: .centerY, relatedBy: .equal, toItem: self.speechToTextButton as Any, attribute: .centerY, multiplier: 1.0, constant: 0.0))
            self.addConstraint(NSLayoutConstraint.init(item: self.sendButton as Any, attribute: .height, relatedBy: .equal, toItem: self.speechToTextButton as Any, attribute: .height, multiplier: 1.0, constant: 0.0))
            self.speechToTextButton.setContentHuggingPriority(UILayoutPriority.defaultLow, for: .horizontal)
            self.speechToTextButton.setContentHuggingPriority(UILayoutPriority.defaultLow, for: .vertical)
            self.speechToTextButton.setContentCompressionResistancePriority(UILayoutPriority.defaultLow, for: .horizontal)
            self.speechToTextButton.setContentCompressionResistancePriority(UILayoutPriority.defaultLow, for: .vertical)
            
            self.textViewTrailingConstraint = NSLayoutConstraint.init(item: self, attribute: .trailing, relatedBy: .equal, toItem: self.growingTextView, attribute: .trailing, multiplier: 1.0, constant: 15.0)
            self.addConstraint(self.textViewTrailingConstraint)
            
            self.setButtonIconColor()
        }
        
    }

    func setClickToCallAvailability(_ available: Bool) {
        guard footerDic.buttons?.click_to_call?.show == true else {
            clickToCallButton.isHidden = true
            clickToCallButton.isEnabled = false
            return
        }
        clickToCallButton.isHidden = false
        clickToCallButton.isEnabled = available
        clickToCallButton.alpha = available ? 1.0 : 0.45
    }

    @objc private func clickToCallButtonAction() {
        clickToCallAction?()
    }
    
    func setButtonIconColor(){
        var footerIconColor = "#000000"
        
        if useColorPaletteOnly == true{
            //footerIconColor =  genaralPrimaryColor
            self.backgroundColor = UIColor.init(hexString: genaralSecondaryColor)
            self.growingTextView.layer.borderColor = UIColor.init(hexString: genaralPrimaryColor).cgColor
        }else{
            footerIconColor =  footerDic.icons_color ?? "#000000"
        }
        self.growingTextView.placeholderLabel.textColor = BubbleViewRightTint
        
        let attachmentImage = UIImage(named: "attach", in: bundle, compatibleWith: nil)
        let tintedAttachmentImage = attachmentImage?.withRenderingMode(.alwaysTemplate)
        attachmentButton.setBackgroundImage(tintedAttachmentImage, for: .normal)
        attachmentButton.tintColor = UIColor.init(hexString: footerIconColor)
        
        let speachTxtImage = UIImage(named: "audio_icon_1", in: bundle, compatibleWith: nil)
        let tintedSpeachTxtImageImage = speachTxtImage?.withRenderingMode(.alwaysTemplate)
        speechToTextButton.setImage(tintedSpeachTxtImageImage, for: .normal)
        speechToTextButton.tintColor = UIColor.init(hexString: footerIconColor)
        clickToCallButton.tintColor = UIColor.init(hexString: footerIconColor)
        
        
        let menuImage = UIImage(named: "Menu", in: bundle, compatibleWith: nil)
        let tintedMenuImage = menuImage?.withRenderingMode(.alwaysTemplate)
        menuButton.setImage(tintedMenuImage, for: .normal)
        menuButton.tintColor = UIColor.init(hexString: footerIconColor)
        
        let sendBtnImage = UIImage(named: "SendW", in: bundle, compatibleWith: nil)
        let tintedsendImage = sendBtnImage?.withRenderingMode(.alwaysTemplate)
        sendButton.setImage(tintedsendImage, for: .normal)
        sendButton.tintColor = BubbleViewUserChatTextColor//UIColor.init(hexString: footerIconColor)
        
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
    @objc fileprivate func taskMenuButtonAction(_ sender: AnyObject!) {
        self.delegate?.composeBarTaskMenuButtonAction(self)
        //self.menuButton.setImage(UIImage(named: "Menu", in: bundle, compatibleWith: nil), for: .normal)
        self.growingTextView.isUserInteractionEnabled = true
        if dynamicFooterview == nil{
            self.sendButton.isUserInteractionEnabled = true
            self.speechToTextButton.isUserInteractionEnabled = true
        }
    }
    @objc fileprivate func composeBarAttachmentButtonAction(_ sender: AnyObject!) {
        self.delegate?.composeBarAttachmentButtonAction(self)
    }
    
    
    @objc fileprivate func speechToTextButtonAction(_ sender: AnyObject) {
        self.delegate?.composeBarViewSpeechToTextButtonAction(self)
    }
    
    fileprivate func valueChanged() {
        if dynamicFooterview != nil{
            let dic = ["isKeyboardEnabled": isKeyboardEnabled, "attachmentKeybord":attachmentKeybord]
            let jsonString = Utilities.stringFromJSONObject(object: dic)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "koreFooterViewValueChanged"), object: jsonString)
        }else{
            let hasText = self.growingTextView.textView.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).count > 0
            self.sendButton.isEnabled = hasText
            if self.isKeyboardEnabled {
                self.attachmentButton.isHidden = false
                if attachmentKeybord{
                    self.sendButton.isHidden = false
                    self.sendButton.isEnabled = true
                    self.speechToTextButton.isHidden = true
                }else{
                    if isHideSpeeachToTextBtn{
                        self.sendButton.isHidden = !hasText
                        self.speechToTextButton.isHidden = hasText
                    }else{
                        self.sendButton.isHidden = false
                        self.speechToTextButton.isHidden = true
                    }
                }
                self.menuButton.isHidden = false
            }else{
                self.sendButton.isHidden = true
                self.speechToTextButton.isHidden = true
                self.menuButton.isHidden = true
                self.attachmentButton.isHidden = true
            }
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

    open func changeBgColorForAudioComposeBar(){
        self.backgroundColor = .clear
        self.growingTextView.backgroundColor = UIColor.init(hexString: bgColor ?? "#EEF2F6")
        self.growingTextView.textView.textColor = BubbleViewRightTint
        if #available(iOS 11.0, *) {
            self.growingTextView.roundCorners([ .layerMaxXMaxYCorner, .layerMinXMaxYCorner, .layerMinXMinYCorner], radius: 15.0, borderColor:  BubbleViewRightTint, borderWidth: 1.0)
        }
    }
    open func changeBgColorForComposeBar(){
        bgColor = footerDic.bg_color
        self.backgroundColor = UIColor.init(hexString: bgColor ?? "#EEF2F6")
        txtViewBgColor = footerDic.compose_bar?.bg_color
        txtViewBorderColor = footerDic.compose_bar?.outline_color
        txtViewPlaceHolderTxt = footerDic.compose_bar?.placeholder
        self.growingTextView.backgroundColor = UIColor.init(hexString: txtViewBgColor ?? "#ffffff")
        self.growingTextView.layer.borderColor = UIColor.init(hexString: txtViewBorderColor ?? "#EEF2F6").cgColor
        self.growingTextView.textView.textColor = .black
        self.growingTextView.layer.cornerRadius = 4.0
        if useColorPaletteOnly == true{
            self.backgroundColor = UIColor.init(hexString: genaralSecondaryColor)
            self.growingTextView.layer.borderColor = UIColor.init(hexString: genaralPrimaryColor).cgColor
        }
    }
    // MARK: UIResponder Methods
    
    open override var isFirstResponder: Bool {
        if dynamicFooterview != nil{
            return ((self.growingTextView?.isFirstResponder) != nil)
        }else{
            return self.growingTextView.isFirstResponder
        }
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
    
    func dynamicFooterViewMenuBtnAction(){
        taskMenuButtonAction(self)
    }
    func dynamicFooterViewSendTextBtnAction(){
        sendButtonAction(self)
    }
    func dynamicFooterViewSpeacToTextBtnAction(){
        speechToTextButtonAction(self)
    }
    func dynamicFooterViewAttachmentBtnAction(){
        composeBarAttachmentButtonAction(self)
    }
    
}
