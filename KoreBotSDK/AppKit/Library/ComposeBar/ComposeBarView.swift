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
    fileprivate var growingTextViewHeightConstraint: NSLayoutConstraint!
    fileprivate var composeBarHeightConstraint: NSLayoutConstraint!
    fileprivate let minimumInputHeight: CGFloat = 34.0
    fileprivate let composeBarVerticalPadding: CGFloat = 18.0
    fileprivate(set) public var isKeyboardEnabled: Bool = false
    var isHideSpeeachToTextBtn = false
    var footerDic = FooterModel()
    var bgColor: String?
    var txtViewBgColor: String?
    var txtViewBorderColor: String?
    var txtViewPlaceHolderTxt: String?
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

    private func resolvedPlaceholderText() -> String {
        return koreSDKLocale.languageCode?.lowercased() == "ar" ? "رسالة" : "Message"
    }

    private func applyPlaceholderText() {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: regularCustomFont, size: 14.0) ?? UIFont.systemFont(ofSize: 14.0),
            .foregroundColor: UIColor(hexString: "#6C737F")
        ]
        self.growingTextView.placeholderAttributedText = NSAttributedString(
            string: resolvedPlaceholderText(),
            attributes: attributes
        )
    }

    private func resolvedUserBubbleColor() -> UIColor {
        if useColorPaletteOnly {
            return UIColor(hexString: genaralPrimaryColor)
        }
        if let userBubbleColor = brandingValues.body?.user_message?.bg_color,
           !userBubbleColor.isEmpty {
            return UIColor(hexString: userBubbleColor)
        }
        return BubbleViewRightTint
    }

    private func applyInputCursorColor() {
        let cursorColor = resolvedUserBubbleColor()
        self.growingTextView.tintColor = cursorColor
        self.growingTextView.textView.tintColor = cursorColor
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if sendButton != nil {
            var sendFrame = sendButton.frame
            sendFrame.size.height = 32.0
            sendFrame.origin.y = (bounds.height - sendFrame.height) / 2.0
            sendButton.frame = sendFrame
        }
    }
    
    fileprivate func setupViews() {
        semanticContentAttribute = isKoreSDKRTL ? .forceRightToLeft : .forceLeftToRight
        
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
        self.growingTextView.minimumHeight = minimumInputHeight
        self.growingTextViewHeightConstraint =
            self.growingTextView.heightAnchor.constraint(equalToConstant: minimumInputHeight)
        self.growingTextViewHeightConstraint.isActive = true
        self.composeBarHeightConstraint =
            self.heightAnchor.constraint(
                equalToConstant: minimumInputHeight + composeBarVerticalPadding
            )
        self.composeBarHeightConstraint.isActive = true
        
        self.applyInputCursorColor()
        self.growingTextView.textView.textColor = .black
        self.growingTextView.semanticContentAttribute = semanticContentAttribute
        self.growingTextView.textView.semanticContentAttribute = semanticContentAttribute
        self.growingTextView.textView.textAlignment = isKoreSDKRTL ? .right : .left
        self.growingTextView.placeholderLabel.textAlignment = isKoreSDKRTL ? .right : .left
        self.growingTextView.maxNumberOfLines = 4
        self.growingTextView.font = UIFont(name: regularCustomFont, size: 14.0) ?? UIFont.systemFont(ofSize: 14.0)
        let inputVerticalInset = max(0.0, (minimumInputHeight - self.growingTextView.font.lineHeight) / 2.0)
        self.growingTextView.textContainerInset = UIEdgeInsets(
            top: inputVerticalInset,
            left: 3.0,
            bottom: inputVerticalInset,
            right: 3.0
        )
        self.growingTextView.animateHeightChange = true
        self.growingTextView.backgroundColor = UIColor.init(hexString: txtViewBgColor ?? "#ffffff")
        self.growingTextView.layer.borderWidth = 1.0
        self.growingTextView.layer.borderColor = UIColor.init(hexString: txtViewBorderColor ?? "#EEF2F6").cgColor
        self.growingTextView.layer.cornerRadius = 4.0
        self.growingTextView.isUserInteractionEnabled = false
        
        applyPlaceholderText()
        
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
        self.sendButton.setImage(sendArrowImage(), for: .normal)
        self.sendButton.translatesAutoresizingMaskIntoConstraints = false
        self.sendButton.heightAnchor.constraint(equalToConstant: 32.0).isActive = true
        self.sendButton.backgroundColor = themeColor
        self.sendButton.layer.cornerRadius = 4
        self.sendButton.setTitleColor(Common.UIColorRGB(0xFFFFFF), for: .normal)
        self.sendButton.setTitleColor(Common.UIColorRGB(0x999999), for: .disabled)
        self.sendButton.titleLabel?.font = UIFont(name: boldCustomFont, size: 14.0)
        self.sendButton.addTarget(self, action: #selector(self.sendButtonAction(_:)), for: .touchUpInside)
        self.sendButton.isHidden = true
        self.setSendButtonEnabled(false)
        self.sendButton.contentEdgeInsets = UIEdgeInsets(top: 6.0, left: 6.0, bottom: 6.0, right: 6.0)
        self.sendButton.imageView?.contentMode = .scaleAspectFit
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
        
        self.topLineView = UIView.init(frame: CGRect.zero)
        self.topLineView.backgroundColor = .clear
        self.topLineView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.topLineView)
        
        self.bottomLineView = UIView.init(frame: CGRect.zero)
        self.bottomLineView.backgroundColor = .clear
        self.bottomLineView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.bottomLineView)
        
        let views: [String : Any] = ["topLineView": self.topLineView as Any, "bottomLineView": self.bottomLineView as Any,"menuButton": self.menuButton as Any, "growingTextView": self.growingTextView as Any, "sendButton": self.sendButton as Any, "speechToTextButton": self.speechToTextButton as Any, "attachmentButton": attachmentButton as Any]
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[topLineView]|", options:[], metrics:nil, views:views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[topLineView(0.5)]", options:[], metrics:nil, views:views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[bottomLineView]|", options:[], metrics:nil, views:views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[bottomLineView(0.5)]|", options:[], metrics:nil, views:views))
        

        let composerFormat: String
        let speechFormat: String
        let menuAttachmentSpacing = menuBtnWidth > 0 && attachmentBtnWidth > 0 ? 2 : 0
        let controlsInputSpacing = menuBtnWidth > 0 || attachmentBtnWidth > 0 ? 5 : 0
        if isKoreSDKRTL {
            composerFormat = "H:|-10-[sendButton(32)]-4-[growingTextView]-\(controlsInputSpacing)-[attachmentButton(\(attachmentBtnWidth))]-\(menuAttachmentSpacing)-[menuButton(\(menuBtnWidth))]-10-|"
            speechFormat = "H:|-13-[speechToTextButton(\(speeachToTextBtnWidth))]-8-[growingTextView]-5-[attachmentButton]"
        } else {
            composerFormat = "H:|-10-[menuButton(\(menuBtnWidth))]-\(menuAttachmentSpacing)-[attachmentButton(\(attachmentBtnWidth))]-\(controlsInputSpacing)-[growingTextView]-4-[sendButton(32)]-10-|"
            speechFormat = "H:[attachmentButton]-5-[growingTextView]-8-[speechToTextButton(\(speeachToTextBtnWidth))]-13-|"
        }
        // These formats describe physical left-to-right placement. Prevent UIKit
        // from mirroring the already mirrored RTL format a second time.
        let horizontalOptions: NSLayoutConstraint.FormatOptions = isKoreSDKRTL ? [.directionLeftToRight] : []
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: composerFormat, options:horizontalOptions, metrics:nil, views:views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: speechFormat, options:horizontalOptions, metrics:nil, views:views))
        self.addConstraint(NSLayoutConstraint(item: self.growingTextView as Any, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0.0))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|->=6-[sendButton]-6-|", options:[], metrics:nil, views:views))
         self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|->=6-[menuButton]-6-|", options:[], metrics:nil, views:views))
         self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|->=6-[attachmentButton(25)]-10-|", options:[], metrics:nil, views:views))
        self.addConstraint(NSLayoutConstraint.init(item: self.sendButton as Any, attribute: .centerY, relatedBy: .equal, toItem: self.speechToTextButton as Any, attribute: .centerY, multiplier: 1.0, constant: 0.0))
        self.addConstraint(NSLayoutConstraint.init(item: self.sendButton as Any, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0.0))
        self.addConstraint(NSLayoutConstraint.init(item: self.sendButton as Any, attribute: .height, relatedBy: .equal, toItem: self.speechToTextButton as Any, attribute: .height, multiplier: 1.0, constant: 0.0))
        self.speechToTextButton.setContentHuggingPriority(UILayoutPriority.defaultLow, for: .horizontal)
        self.speechToTextButton.setContentHuggingPriority(UILayoutPriority.defaultLow, for: .vertical)
        self.speechToTextButton.setContentCompressionResistancePriority(UILayoutPriority.defaultLow, for: .horizontal)
        self.speechToTextButton.setContentCompressionResistancePriority(UILayoutPriority.defaultLow, for: .vertical)
        
        if isKoreSDKRTL {
            self.textViewTrailingConstraint = NSLayoutConstraint.init(item: self, attribute: .leading, relatedBy: .equal, toItem: self.growingTextView, attribute: .leading, multiplier: 1.0, constant: -15.0)
        } else {
            self.textViewTrailingConstraint = NSLayoutConstraint.init(item: self, attribute: .trailing, relatedBy: .equal, toItem: self.growingTextView, attribute: .trailing, multiplier: 1.0, constant: 15.0)
        }
        self.addConstraint(self.textViewTrailingConstraint)
        
        self.setButtonIconColor()
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
        self.growingTextView.placeholderLabel.textColor = UIColor(hexString: "#6C737F")
        
        let attachmentImage = UIImage(named: "attach", in: bundle, compatibleWith: nil)
        let tintedAttachmentImage = attachmentImage?.withRenderingMode(.alwaysTemplate)
        attachmentButton.setBackgroundImage(tintedAttachmentImage, for: .normal)
        attachmentButton.tintColor = UIColor.init(hexString: footerIconColor)
        
        let speachTxtImage = UIImage(named: "audio_icon_1", in: bundle, compatibleWith: nil)
        let tintedSpeachTxtImageImage = speachTxtImage?.withRenderingMode(.alwaysTemplate)
        speechToTextButton.setImage(tintedSpeachTxtImageImage, for: .normal)
        speechToTextButton.tintColor = UIColor.init(hexString: footerIconColor)
        
        
        let menuImage = UIImage(named: "Menu", in: bundle, compatibleWith: nil)
        let tintedMenuImage = menuImage?.withRenderingMode(.alwaysTemplate)
        menuButton.setImage(tintedMenuImage, for: .normal)
        menuButton.tintColor = UIColor.init(hexString: footerIconColor)
        
        let sendBtnImage = sendArrowImage()
        sendButton.setImage(sendBtnImage?.withRenderingMode(.alwaysOriginal), for: .normal)
        
    }

    private func sendArrowImage() -> UIImage? {
        let image = UIImage(named: "LeadingIcon", in: bundle, compatibleWith: nil)
        return isKoreSDKRTL ? image : image?.withHorizontallyFlippedOrientation()
    }
    
    //MARK: Public methods
    public func clear() {
        self.clearButtonAction(self)
    }
    
    public func configureViewForKeyboard(_ enable: Bool) {
        self.textViewTrailingConstraint.isActive = !enable
        self.isKeyboardEnabled = enable
        self.growingTextView.textView.textAlignment = enable ? (isKoreSDKRTL ? .right : .left) : .right
        self.growingTextView.placeholderLabel.textAlignment = isKoreSDKRTL ? .right : .left
        self.growingTextView.isUserInteractionEnabled = enable
        self.valueChanged()
    }
    
    public func setText(_ text: String) -> Void {
        self.growingTextView.textView.text = text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        self.textDidChangeNotification(Notification(name: UITextView.textDidChangeNotification))
        self.growingTextView.refreshHeight()
    }

    /// Grows or shrinks the compose bar to match the measured input height.
    public func updateGrowingTextHeight(_ height: CGFloat) {
        let inputHeight = max(minimumInputHeight, height)
        guard abs(growingTextViewHeightConstraint.constant - inputHeight) > 0.5 else {
            return
        }
        growingTextViewHeightConstraint.constant = inputHeight
        composeBarHeightConstraint.constant = inputHeight + composeBarVerticalPadding
        setNeedsLayout()
    }

    //MARK: Private methods
    
    @objc fileprivate func clearButtonAction(_ sender: AnyObject!) {
        self.growingTextView.textView.text = "";
        self.textDidChangeNotification(Notification(name: UITextView.textDidChangeNotification))
        self.growingTextView.refreshHeight()
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
        //self.menuButton.setImage(UIImage(named: "Menu", in: bundle, compatibleWith: nil), for: .normal)
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
        self.setSendButtonEnabled(hasText)
        if self.isKeyboardEnabled {
            self.attachmentButton.isHidden = false
            if attachmentKeybord{
                self.sendButton.isHidden = false
                self.setSendButtonEnabled(true)
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

    private func setSendButtonEnabled(_ enabled: Bool) {
        self.sendButton.isEnabled = enabled
        self.sendButton.alpha = enabled ? 1.0 : 0.5
    }
    
    // MARK: Notification handler
    @objc fileprivate func textDidBeginEditingNotification(_ notification: Notification) {
        self.applyInputCursorColor()
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
        if let brandedFooter = brandingValues.footer {
            footerDic = brandedFooter
        }
        bgColor = footerDic.bg_color
        self.backgroundColor = UIColor.init(hexString: bgColor ?? "#EEF2F6")
        txtViewBgColor = footerDic.compose_bar?.bg_color
        txtViewBorderColor = footerDic.compose_bar?.outline_color
        txtViewPlaceHolderTxt = footerDic.compose_bar?.placeholder
        self.growingTextView.backgroundColor = UIColor.init(hexString: txtViewBgColor ?? "#ffffff")
        self.growingTextView.layer.borderColor = UIColor.init(hexString: txtViewBorderColor ?? "#EEF2F6").cgColor
        self.growingTextView.textView.textColor = .black
        self.applyInputCursorColor()
        self.growingTextView.layer.cornerRadius = 4.0
        applyPlaceholderText()
        if useColorPaletteOnly == true{
            self.backgroundColor = UIColor.init(hexString: genaralSecondaryColor)
            self.growingTextView.layer.borderColor = UIColor.init(hexString: genaralPrimaryColor).cgColor
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
