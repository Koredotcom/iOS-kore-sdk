//
//  ComposeBarView.swift
//  KoreBotSDKDemo
//
//  Created by Anoop Dhiman on 26/07/17.
//  Copyright © 2017 Kore. All rights reserved.
//

import UIKit

public protocol ComposeBarViewDelegate: class {
    func composeBarView(_: ComposeBarView, sendButtonAction text: String)
    func composeBarViewSpeechToTextButtonAction(_: ComposeBarView)
    func composeBarViewDidBecomeFirstResponder(_: ComposeBarView)
}

open class ComposeBarView: UIView {

    public var delegate: ComposeBarViewDelegate?
    
    fileprivate var topLineView: UIView!
    fileprivate var bottomLineView: UIView!
    public var growingTextView: KREGrowingTextView!
    public var sendButton: UIButton!
    public var speechToTextButton: UIButton!

    fileprivate var textViewTrailingConstraint: NSLayoutConstraint!
    fileprivate(set) public var isKeyboardEnabled: Bool = false
    
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupViews()
    }
    
    fileprivate func setupViews() {
        self.backgroundColor = .clear
        
        self.growingTextView = KREGrowingTextView.init(frame: CGRect.zero)
        self.growingTextView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.growingTextView)
        
        self.growingTextView.textView.tintColor = .black
        self.growingTextView.textView.textColor = .black
        self.growingTextView.textView.textAlignment = .right
        self.growingTextView.maxNumberOfLines = 10
        self.growingTextView.font = UIFont(name: "HelveticaNeue", size: 15.0)!
        self.growingTextView.textContainerInset = UIEdgeInsets(top: 22, left: 6, bottom: 14, right: 0)
        self.growingTextView.animateHeightChange = true
        self.growingTextView.backgroundColor = .clear
        self.growingTextView.isUserInteractionEnabled = false
        
        let attributes: [NSAttributedStringKey : Any] = [NSAttributedStringKey.font: UIFont(name: "HelveticaNeue", size: 14.0)!, NSAttributedStringKey.foregroundColor: UIColorRGB(0xB5B9BA)]
        self.growingTextView.placeholderAttributedText = NSAttributedString(string: "Type your message …", attributes:attributes)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.textDidBeginEditingNotification(_ :)), name: NSNotification.Name.UITextViewTextDidBeginEditing, object: self.growingTextView.textView)
        NotificationCenter.default.addObserver(self, selector: #selector(self.textDidChangeNotification(_ :)), name: NSNotification.Name.UITextViewTextDidChange, object: self.growingTextView.textView)
        
        self.sendButton = UIButton.init(frame: CGRect.zero)
        self.sendButton.setTitle("Send", for: .normal)
        self.sendButton.translatesAutoresizingMaskIntoConstraints = false
        self.sendButton.backgroundColor = KoreBotUIKit.User.SendButton.backgroundColor
        self.sendButton.layer.cornerRadius = 5
        self.sendButton.setTitleColor(UIColorRGB(0x999999), for: .disabled)
        self.sendButton.setTitleColor(UIColorRGB(0x1432FF), for: .normal)
        self.sendButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 14.0)!
        self.sendButton.addTarget(self, action: #selector(self.sendButtonAction(_:)), for: .touchUpInside)
        self.sendButton.isHidden = false
        self.sendButton.contentEdgeInsets = UIEdgeInsetsMake(20.0, 14.0, 18.0, 18.0)
        self.sendButton.clipsToBounds = true
        self.addSubview(self.sendButton)
        
        self.speechToTextButton = UIButton.init(frame: CGRect.zero)
        self.speechToTextButton.setTitle("", for: .normal)
        self.speechToTextButton.translatesAutoresizingMaskIntoConstraints = false
        self.speechToTextButton.setImage(UIImage(named: "micActive", in: Bundle(for: self.classForCoder), compatibleWith: nil), for: .selected)
        self.speechToTextButton.setImage(UIImage(named: "micInactive", in: Bundle(for: self.classForCoder), compatibleWith: nil), for: .normal)
        self.speechToTextButton.imageView?.contentMode = .scaleAspectFit
        self.speechToTextButton.addTarget(self, action: #selector(self.speechToTextButtonAction(_:)), for: .touchUpInside)
        self.speechToTextButton.isHidden = false
        self.speechToTextButton.contentEdgeInsets = UIEdgeInsetsMake(19.0, 16.0, 18.0, 20.0)
        self.speechToTextButton.clipsToBounds = true
        self.addSubview(self.speechToTextButton)
        
        self.topLineView = UIView.init(frame: CGRect.zero)
        self.topLineView.backgroundColor = UIColorRGB(0xE7E7E7)
        self.topLineView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.topLineView)
        
        self.bottomLineView = UIView.init(frame: CGRect.zero)
        self.bottomLineView.backgroundColor = .clear
        self.bottomLineView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.bottomLineView)
        
        let views: [String : Any] = ["topLineView": self.topLineView, "bottomLineView": self.bottomLineView, "growingTextView": self.growingTextView, "sendButton": self.sendButton, "speechToTextButton": self.speechToTextButton]
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[topLineView]|", options:[], metrics:nil, views:views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[topLineView(1)]", options:[], metrics:nil, views:views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[bottomLineView]|", options:[], metrics:nil, views:views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[bottomLineView(0.5)]|", options:[], metrics:nil, views:views))
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[speechToTextButton(0)][growingTextView][sendButton(71)]|", options:[], metrics:nil, views:views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[speechToTextButton]|", options:[], metrics:nil, views:views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[growingTextView]|", options:[], metrics:nil, views:views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[sendButton]|", options:[], metrics:nil, views:views))
    }
    
    //MARK: Public methods
    public func clear() {
        self.clearButtonAction(self)
    }
    
    public func configureViewForKeyboard(_ enable: Bool) {
        self.isKeyboardEnabled = enable
        self.growingTextView.textView.textAlignment = enable ? .left : .right
        self.growingTextView.isUserInteractionEnabled = enable
        self.valueChanged()
    }
    
    public func setText(_ text: String) -> Void {
        self.growingTextView.textView.text = text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        self.textDidChangeNotification(Notification(name: NSNotification.Name.UITextViewTextDidChange))
    }
    
    // MARK: Private methods
    @objc fileprivate func clearButtonAction(_ sender: AnyObject!) {
        self.growingTextView.textView.text = "";
        self.textDidChangeNotification(Notification(name: NSNotification.Name.UITextViewTextDidChange))
    }
    
    @objc fileprivate func sendButtonAction(_ sender: AnyObject!) {
        var text = self.growingTextView.textView.text
        text = text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
         self.speechToTextButton.isHidden = false
        
        // is there any text?
        if let text = text, text.count > 0 {
            self.delegate?.composeBarView(self, sendButtonAction: text)
        }
    }
    
    @objc fileprivate func speechToTextButtonAction(_ sender: AnyObject) {
        self.delegate?.composeBarViewSpeechToTextButtonAction(self)
    }
    
    fileprivate func valueChanged() {
        let hasText = self.growingTextView.textView.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).count > 0
        self.sendButton.isEnabled = hasText
     
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
        self.topLineView = nil
        self.bottomLineView = nil
        self.growingTextView = nil
        self.sendButton = nil
        self.speechToTextButton = nil
        self.textViewTrailingConstraint = nil
    }
}
