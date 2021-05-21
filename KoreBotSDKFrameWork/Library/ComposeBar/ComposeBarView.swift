//
//  ComposeBarView.swift
//  KoreBotSDKDemo
//
//  Created by Anoop Dhiman on 26/07/17.
//  Copyright © 2017 Kore. All rights reserved.
//

import UIKit
import KoreBotSDK

protocol ComposeBarViewDelegate {
    func composeBarView(_: ComposeBarView, sendButtonAction text: String)
    func composeBarViewSpeechToTextButtonAction(_: ComposeBarView)
    func composeBarViewDidBecomeFirstResponder(_: ComposeBarView)
    func composeBarTaskMenuButtonAction(_: ComposeBarView)
}


class ComposeBarView: UIView {
    let bundle = Bundle(for: ComposeBarView.self)
    
    public var delegate: ComposeBarViewDelegate?
    
    fileprivate var topLineView: UIView!
    fileprivate var bottomLineView: UIView!
    public var growingTextView: KREGrowingTextView!
    fileprivate var sendButton: UIButton!
    fileprivate var menuButton: UIButton!
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
        self.backgroundColor = UIColor.init(hexString: "#f8f9fc")
        loadCustomFonts()
        
        self.growingTextView = KREGrowingTextView(frame: CGRect.zero)
        self.growingTextView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.growingTextView)
        self.growingTextView.setContentCompressionResistancePriority(UILayoutPriority.defaultLow, for: .horizontal)
        
        let composeBarTextColor = UIColor.init(hexString: (brandingShared.brandingInfoModel?.widgetTextColor)!)
        self.growingTextView.textView.tintColor = composeBarTextColor
        self.growingTextView.textView.textColor = composeBarTextColor
        self.growingTextView.textView.textAlignment = .right
        self.growingTextView.maxNumberOfLines = 10
        
        self.growingTextView.font = UIFont(name: "Gilroy-Regular", size: 14.0)!
        self.growingTextView.textView.textColor = .black
        self.growingTextView.animateHeightChange = true
        self.growingTextView.backgroundColor = .clear
        self.growingTextView.layer.cornerRadius = 10.0
        self.growingTextView.isUserInteractionEnabled = false
        
        let attributes: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font: UIFont(name: "Gilroy-Regular", size: 14.0)!, NSAttributedString.Key.foregroundColor: UIColor.init(hexString: (brandingShared.brandingInfoModel?.userchatBgColor)!)]
        self.growingTextView.placeholderAttributedText = NSAttributedString(string: "Type your message here...", attributes:attributes)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.textDidBeginEditingNotification(_ :)), name: UITextView.textDidBeginEditingNotification, object: self.growingTextView.textView)
        NotificationCenter.default.addObserver(self, selector: #selector(self.textDidChangeNotification(_ :)), name: UITextView.textDidChangeNotification, object: self.growingTextView.textView)
        
        self.menuButton = UIButton.init(frame: CGRect.zero)
        self.menuButton.translatesAutoresizingMaskIntoConstraints = false
        self.menuButton.layer.cornerRadius = 5
        self.menuButton.setTitleColor(Common.UIColorRGB(0xFFFFFF), for: .normal)
        self.menuButton.setTitleColor(Common.UIColorRGB(0x999999), for: .disabled)
        self.menuButton.setImage(UIImage(named: "Menu", in: bundle, compatibleWith: nil), for: .normal)
        self.menuButton.titleLabel?.font = UIFont(name: "Gilroy-Bold", size: 14.0)!
        self.menuButton.addTarget(self, action: #selector(self.taskMenuButtonAction(_:)), for: .touchUpInside)
        self.menuButton.isHidden = false
        self.menuButton.contentEdgeInsets = UIEdgeInsets(top: 9.0, left: 3.0, bottom: 7.0, right: 3.0)
        self.menuButton.clipsToBounds = true
        self.addSubview(self.menuButton)
        
        let buttonBg = (brandingShared.brandingInfoModel?.widgetHeaderColor) ?? "#2881DF" == "#FFFFFF" ? "#2881DF" : (brandingShared.brandingInfoModel?.widgetHeaderColor) ?? "#2881DF"
        
        //let widgetHeaderColor = UIColor.init(hexString: buttonBg)
        self.sendButton = UIButton.init(frame: CGRect.zero)
        //self.sendButton.setTitle("Send", for: .normal)
        self.sendButton.translatesAutoresizingMaskIntoConstraints = false
        //self.sendButton.backgroundColor = widgetHeaderColor
        
        self.sendButton.setImage(UIImage(named: "send", in: bundle, compatibleWith: nil), for: .normal)
        self.sendButton.layer.cornerRadius = 5
        self.sendButton.setTitleColor(Common.UIColorRGB(0xFFFFFF), for: .normal)
        self.sendButton.setTitleColor(Common.UIColorRGB(0x999999), for: .disabled)
        self.sendButton.titleLabel?.font = UIFont(name: "Gilroy-Bold", size: 14.0)!
        self.sendButton.addTarget(self, action: #selector(self.sendButtonAction(_:)), for: .touchUpInside)
        self.sendButton.isHidden = true
        self.sendButton.contentEdgeInsets = UIEdgeInsets(top: 9.0, left: 3.0, bottom: 7.0, right: 3.0)
        self.sendButton.clipsToBounds = true
        self.addSubview(self.sendButton)
        
        self.speechToTextButton = UIButton.init(frame: CGRect.zero)
        self.speechToTextButton.setTitle("", for: .normal)
        self.speechToTextButton.translatesAutoresizingMaskIntoConstraints = false
        self.speechToTextButton.setImage(UIImage(named: "audio_icon", in: bundle, compatibleWith: nil), for: .normal)
        self.speechToTextButton.layer.cornerRadius = 5.0
        self.speechToTextButton.backgroundColor = .clear
        self.speechToTextButton.imageView?.contentMode = .scaleAspectFit
        self.speechToTextButton.addTarget(self, action: #selector(self.speechToTextButtonAction(_:)), for: .touchUpInside)
        self.speechToTextButton.isHidden = true
        self.speechToTextButton.contentEdgeInsets = UIEdgeInsets(top: 6.0, left: 3.0, bottom: 5.0, right: 3.0)
        self.speechToTextButton.clipsToBounds = true
        self.addSubview(self.speechToTextButton)
        
        self.topLineView = UIView.init(frame: CGRect.zero)
        self.topLineView.backgroundColor = .lightGray
        self.topLineView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.topLineView)
        
        self.bottomLineView = UIView.init(frame: CGRect.zero)
        self.bottomLineView.backgroundColor = .clear
        self.bottomLineView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.bottomLineView)
        
        let views: [String : Any] = ["topLineView": self.topLineView, "bottomLineView": self.bottomLineView,"menuButton": self.menuButton, "growingTextView": self.growingTextView, "sendButton": self.sendButton, "speechToTextButton": self.speechToTextButton]
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[topLineView]|", options:[], metrics:nil, views:views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[topLineView(0.5)]", options:[], metrics:nil, views:views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[bottomLineView]|", options:[], metrics:nil, views:views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[bottomLineView(0.5)]|", options:[], metrics:nil, views:views))
        
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-5-[menuButton(30)]-5-[growingTextView]-5-[sendButton]-8-[speechToTextButton]-5-|", options:[], metrics:nil, views:views))
        //self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[growingTextView]-5-[speechToTextButton]-5-|", options:[], metrics:nil, views:views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-7-[growingTextView]-7-|", options:[], metrics:nil, views:views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|->=6-[sendButton]-6-|", options:[], metrics:nil, views:views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|->=6-[menuButton]-6-|", options:[], metrics:nil, views:views))
        self.addConstraint(NSLayoutConstraint.init(item: self.sendButton, attribute: .centerY, relatedBy: .equal, toItem: self.speechToTextButton, attribute: .centerY, multiplier: 1.0, constant: 0.0))
        self.addConstraint(NSLayoutConstraint.init(item: self.sendButton, attribute: .height, relatedBy: .equal, toItem: self.speechToTextButton, attribute: .height, multiplier: 1.0, constant: 0.0))
        self.speechToTextButton.setContentHuggingPriority(UILayoutPriority.defaultLow, for: .horizontal)
        self.speechToTextButton.setContentHuggingPriority(UILayoutPriority.defaultLow, for: .vertical)
        self.speechToTextButton.setContentCompressionResistancePriority(UILayoutPriority.defaultLow, for: .horizontal)
        self.speechToTextButton.setContentCompressionResistancePriority(UILayoutPriority.defaultLow, for: .vertical)
        
        self.textViewTrailingConstraint = NSLayoutConstraint.init(item: self, attribute: .trailing, relatedBy: .equal, toItem: self.growingTextView, attribute: .trailing, multiplier: 1.0, constant: 15.0)
        self.addConstraint(self.textViewTrailingConstraint)
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
        if ((text?.count)! > 0) {
            self.delegate?.composeBarView(self, sendButtonAction: text!)
        }
    }
    @objc fileprivate func taskMenuButtonAction(_ sender: UIButton!) {
        self.delegate?.composeBarTaskMenuButtonAction(self)
        self.menuButton.setImage(UIImage(named: "Menu", in: bundle, compatibleWith: nil), for: .normal)
        self.growingTextView.isUserInteractionEnabled = true
        self.sendButton.isUserInteractionEnabled = true
        self.speechToTextButton.isUserInteractionEnabled = true
    }
    
    @objc fileprivate func speechToTextButtonAction(_ sender: AnyObject) {
        self.delegate?.composeBarViewSpeechToTextButtonAction(self)
    }
    
    fileprivate func valueChanged() {
        let hasText = self.growingTextView.textView.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).count > 0
        self.sendButton.isEnabled = hasText
        if hasText{
            topLineView.backgroundColor = .black
            //self.sendButton.setImage(UIImage(named: "sendS", in: bundle, compatibleWith: nil), for: .normal)
        }else{
            topLineView.backgroundColor = .lightGray
            //self.sendButton.setImage(UIImage(named: "send", in: bundle, compatibleWith: nil), for: .normal)
        }
        
        if self.isKeyboardEnabled {
            self.sendButton.isHidden = false
            self.speechToTextButton.isHidden =  false
            self.menuButton.isHidden = false
        }else{
            self.sendButton.isHidden = true
            self.speechToTextButton.isHidden = true
            self.menuButton.isHidden = true
        }
    }
    
    // MARK: Notification handler
    @objc fileprivate func textDidBeginEditingNotification(_ notification: Notification) {
        self.sendButton.setImage(UIImage(named: "sendS", in: bundle, compatibleWith: nil), for: .normal)
        self.delegate?.composeBarViewDidBecomeFirstResponder(self)
    }
    
    @objc fileprivate func textDidChangeNotification(_ notification: Notification) {
        self.valueChanged()
    }
    
    // MARK: UIResponder Methods
    
    open override var isFirstResponder: Bool {
        self.sendButton.setImage(UIImage(named: "send", in: bundle, compatibleWith: nil), for: .normal)
        return self.growingTextView.isFirstResponder
    }
    
    open override func becomeFirstResponder() -> Bool {
        return self.growingTextView.becomeFirstResponder()
    }
    
    open override func resignFirstResponder() -> Bool {
        self.sendButton.setImage(UIImage(named: "send", in: bundle, compatibleWith: nil), for: .normal)
        return self.growingTextView.resignFirstResponder()
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
    
    func loadCustomFonts(){
        ComposeBarView.loadMyCustomFont(name: "/Gilroy-Regular")
        ComposeBarView.loadMyCustomFont(name: "/Gilroy-Medium")
        ComposeBarView.loadMyCustomFont(name: "/Gilroy-Bold")
        ComposeBarView.loadMyCustomFont(name: "/Gilroy-Semibold")
    }
    
    public class func loadMyCustomFont(name:String) -> Bool{
        let bundle = Bundle(for: Self.self)
        let fontPath = bundle.path(forResource: name, ofType: "otf")!
        let inData = NSData(contentsOfFile:fontPath)
        var error: Unmanaged<CFError>?
        let provider = CGDataProvider(data: inData!)
        if let font = CGFont(provider!) {
            CTFontManagerRegisterGraphicsFont(font, &error)
            if error != nil {
                print(error as Any) //Or logged it
                return false
            }
        }
        return true
    }
}


