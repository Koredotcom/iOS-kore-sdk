//
//  KREComposeBarView.swift
//  KoraApp
//
//  Created by Anoop Dhiman on 06/12/17.
//  Copyright © 2017 Kore. All rights reserved.
//

import UIKit
import SafariServices

public protocol KREComposeBarViewDelegate: class {
    func composeBarView(_: KREComposeBarView, sendButtonAction text: String)
    func composeBarViewSpeechToTextButtonAction(_: KREComposeBarView)
    func composeBarViewDidBecomeFirstResponder(_: KREComposeBarView)
    func composeBarHelpButtonAction(_: KREComposeBarView)
    func composeBarCancelButtonAction(_: KREComposeBarView)
}

open class KREComposeBarView: UIView {
    let bundle = Bundle.sdkModule
    public weak var delegate: KREComposeBarViewDelegate?
    
    fileprivate var topLineView: UIView!
    fileprivate var bottomLineView: UIView!
    public var growingTextView: KREGrowingTextView!
    public var sendButton: UIButton!
    public var sendButtonWithImage: UIButton!
    public var speechToTextButton: UIButton!
    public var composeCancelButton: UIButton!

    fileprivate var textViewTrailingConstraint: NSLayoutConstraint!
    public var cancelComposeWidthConstraint: NSLayoutConstraint!
    public  var isKeyboardEnabled: Bool = false
    fileprivate let themeColor = KREConstants.backgroundColor()
    var composeBarHandler:(() -> Void)?

    
    open var placeholderText: String? {
        didSet {
            let attributes: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font: UIFont.textFont(ofSize: 17.0, weight: .regular), NSAttributedString.Key.foregroundColor: UIColor(hex: 0xB5B9BA)]
            growingTextView.placeholderAttributedText = NSAttributedString(string: placeholderText!, attributes:attributes)
        }
    }

    override open func layoutSubviews() {
        super.layoutSubviews()
        roundCorners(cornerRadius: 27.5,button: sendButton)
        roundCorners(cornerRadius: 27.5,button: speechToTextButton)
    }

    
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    fileprivate func setupViews() {
        let cancelImage = UIImage(named: "composeCancel", in: bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        backgroundColor = .red
        
        composeCancelButton = UIButton(frame: CGRect.zero)
        composeCancelButton.setTitle("", for: .normal)
        composeCancelButton.setImage(cancelImage, for: .normal)
        composeCancelButton.imageView?.contentMode = .scaleAspectFit
        composeCancelButton.translatesAutoresizingMaskIntoConstraints = false
        composeCancelButton.tintColor = UIColor.charcoalGrey
        composeCancelButton.addTarget(self, action: #selector(composeCancelButtonAction(_ :)), for: .touchUpInside)
        addSubview(composeCancelButton)

        growingTextView = KREGrowingTextView.init(frame: CGRect.zero)
        growingTextView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(growingTextView)
        growingTextView.setContentCompressionResistancePriority(UILayoutPriority.defaultLow, for: .horizontal)
        
        growingTextView.textView.tintColor = UIColor.lightRoyalBlue
        growingTextView.textView.textColor = UIColor.charcoalGrey
        growingTextView.textView.textAlignment = .right
        growingTextView.maxNumberOfLines = 10
        growingTextView.font = UIFont.textFont(ofSize: 17.0, weight: .regular)
        growingTextView.textContainerInset = UIEdgeInsets(top: 7, left: 0, bottom: 7, right: 0)
        growingTextView.animateHeightChange = true
        growingTextView.backgroundColor = .white
        growingTextView.isUserInteractionEnabled = false
        
        placeholderText = NSLocalizedString("Type something...", comment: "Type something...")
        
        NotificationCenter.default.addObserver(self, selector: #selector(textDidBeginEditingNotification(_ :)), name: UITextView.textDidBeginEditingNotification, object: growingTextView.textView)
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChangeNotification(_ :)), name: UITextView.textDidChangeNotification, object: growingTextView.textView)
        
        sendButton = UIButton.init(frame: CGRect.zero)
        if let sendNewImage = UIImage(named: "right_send") {
            sendButton.setImage(sendNewImage, for: .normal)
        }
        sendButton.imageView?.contentMode = .scaleAspectFit
        sendButton.contentVerticalAlignment = .fill
        sendButton.contentHorizontalAlignment = .fill
        sendButton.imageEdgeInsets = UIEdgeInsets(top: 7, left: 7, bottom: 7, right: 7)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.setTitleColor(KREConstants.themeColor(), for: .normal)
        sendButton.setTitleColor(UIColor.gray, for: .disabled)
        sendButton.titleLabel?.font = UIFont.textFont(ofSize: 14.0, weight: .bold)
        sendButton.addTarget(self, action: #selector(sendButtonAction(_:)), for: .touchUpInside)
        sendButton.isHidden = true
        sendButton.clipsToBounds = true
        sendButton.backgroundColor = UIColor.lightRoyalBlue
        addSubview(sendButton)
        
        // Shadow
        layer.shadowRadius = 7.0
        layer.masksToBounds = false
        layer.shadowColor = UIColor.charcoalGrey30.cgColor
        layer.borderColor = UIColor.paleLilac.cgColor
        layer.borderWidth = 0.5
        layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        layer.shadowOpacity = 0.1
        
        sendButtonWithImage = UIButton.init(frame: CGRect.zero)
        sendButtonWithImage.setTitle("", for: .normal)
        sendButtonWithImage.translatesAutoresizingMaskIntoConstraints = false
        sendButtonWithImage.setTitleColor(KREConstants.themeColor(), for: .normal)
        sendButtonWithImage.setTitleColor(UIColor.gray, for: .disabled)
        sendButtonWithImage.titleLabel?.font = UIFont.textFont(ofSize: 14.0, weight: .bold)
        sendButtonWithImage.setImage( UIImage(named: "go"), for: .normal)

        sendButtonWithImage.addTarget(self, action: #selector(sendButtonAction(_:)), for: .touchUpInside)
        sendButtonWithImage.isHidden = true
        sendButtonWithImage.contentEdgeInsets = UIEdgeInsets(top: 9.0, left: 3.0, bottom: 7.0, right: 3.0)
        sendButtonWithImage.clipsToBounds = true
        addSubview(sendButtonWithImage)
        
        speechToTextButton = UIButton.init(frame: CGRect.zero)
        speechToTextButton.setTitle("", for: .normal)
        speechToTextButton.backgroundColor = UIColor.lightRoyalBlue
        speechToTextButton.translatesAutoresizingMaskIntoConstraints = false
        
        let audioImage = UIImage(named: "audio_image")?.withRenderingMode(.alwaysTemplate)
        speechToTextButton.setImage(audioImage, for: .normal)
        speechToTextButton.tintColor = .white
        speechToTextButton.imageView?.contentMode = .scaleAspectFit
        speechToTextButton.contentVerticalAlignment = .fill
        speechToTextButton.contentHorizontalAlignment = .fill
        speechToTextButton.imageEdgeInsets = UIEdgeInsets(top: 7, left: 7, bottom: 7, right: 7)
        speechToTextButton.addTarget(self, action: #selector(speechToTextButtonAction(_:)), for: .touchUpInside)
        speechToTextButton.isHidden = true
        speechToTextButton.clipsToBounds = true
        addSubview(speechToTextButton)
        
        topLineView = UIView.init(frame: CGRect.zero)
        topLineView.backgroundColor = KREConstants.backgroundColor()
        topLineView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(topLineView)
        
        bottomLineView = UIView.init(frame: CGRect.zero)
        bottomLineView.backgroundColor = KREConstants.backgroundColor()
        bottomLineView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(bottomLineView)
        backgroundColor = .white
        
        let views: [String : Any] = ["topLineView": topLineView, "bottomLineView": bottomLineView,  "growingTextView": growingTextView, "sendButton": sendButton,"sendButtonWithImage": sendButtonWithImage, "speechToTextButton": speechToTextButton, "composeCancelButton": composeCancelButton]
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[topLineView]|", options:[], metrics:nil, views:views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[topLineView(0.5)]", options:[], metrics:nil, views:views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[bottomLineView]|", options:[], metrics:nil, views:views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[bottomLineView(0.5)]|", options:[], metrics:nil, views:views))

        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[composeCancelButton(28)]-0-[growingTextView]-10-[sendButton(45)]|", options:[], metrics:nil, views:views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[growingTextView]-10-[sendButtonWithImage]-16-|", options:[], metrics:nil, views:views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[growingTextView]-20-[speechToTextButton(45)]|", options:[], metrics:nil, views:views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[growingTextView]-10-|", options:[], metrics:nil, views:views))
        let yConstraint = NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: sendButton, attribute: .centerY, multiplier: 1.0, constant: 0.0)
        addConstraint(yConstraint)
        
        let sendButtonHeight = NSLayoutConstraint.init(item: sendButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 31)
        addConstraint(sendButtonHeight)

        let yspeechToTextButtonConstraint = NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: speechToTextButton, attribute: .centerY, multiplier: 1.0, constant: 0.0)
        addConstraint(yspeechToTextButtonConstraint)
        let speechToTextButtonHeight = NSLayoutConstraint.init(item: speechToTextButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 31)
        addConstraint(speechToTextButtonHeight)

        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-6-[sendButtonWithImage]", options:[], metrics:nil, views:views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[composeCancelButton(28)]", options:[], metrics:nil, views:views))
        addConstraint(NSLayoutConstraint.init(item: composeCancelButton, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0.0))
        speechToTextButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
       
        speechToTextButton.setContentHuggingPriority(UILayoutPriority.defaultLow, for: .horizontal)
        speechToTextButton.setContentHuggingPriority(UILayoutPriority.defaultLow, for: .vertical)
        speechToTextButton.setContentCompressionResistancePriority(UILayoutPriority.defaultLow, for: .horizontal)
        speechToTextButton.setContentCompressionResistancePriority(UILayoutPriority.defaultLow, for: .vertical)
        
        textViewTrailingConstraint = NSLayoutConstraint.init(item: self, attribute: .trailing, relatedBy: .equal, toItem: growingTextView, attribute: .trailing, multiplier: 1.0, constant: 15.0)
        addConstraint(textViewTrailingConstraint)
        cancelComposeWidthConstraint =  NSLayoutConstraint.init(item: composeCancelButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 1.0)
        cancelComposeWidthConstraint.isActive = true
        addConstraint(cancelComposeWidthConstraint)
    }
    
    func roundCorners(cornerRadius: CGFloat, button: UIButton) {
        let path = UIBezierPath(roundedRect: button.bounds, byRoundingCorners: [.topLeft, .bottomLeft], cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = button.bounds
        maskLayer.path = path.cgPath
        button.layer.mask = maskLayer
        button.layoutSubviews()
    }
    
    // MARK: Public methods
    public func clear() {
        clearButtonAction(self)
    }
    
    public func configureViewForKeyboard(_ enable: Bool) {
        textViewTrailingConstraint.isActive = !enable
        isKeyboardEnabled = enable
        growingTextView.textView.textAlignment = .left//enable ? .left : .right
        growingTextView.isUserInteractionEnabled = enable
        valueChanged()
    }
    
    public func setText(_ text: String) -> Void {
        growingTextView.textView.text = text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        textDidChangeNotification(Notification(name: UITextView.textDidChangeNotification))
    }
    
    // MARK: Private methods
    @objc fileprivate func composeCancelButtonAction(_ sender: AnyObject!) {
        delegate?.composeBarCancelButtonAction(self)
    }
    
    @objc fileprivate func clearButtonAction(_ sender: AnyObject!) {
        growingTextView.textView.text = ""
        textDidChangeNotification(Notification(name: UITextView.textDidChangeNotification))
    }
    
    @objc fileprivate func sendButtonAction(_ sender: AnyObject!) {
        var text = growingTextView.textView.text
        text = text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        // is there any text?
        if ((text?.count)! > 0) {
            delegate?.composeBarView(self, sendButtonAction: text!)
        }
    }
    
    @objc fileprivate func speechToTextButtonAction(_ sender: AnyObject) {
        delegate?.composeBarViewSpeechToTextButtonAction(self)
    }
    
    fileprivate func valueChanged() {
        let hasText = growingTextView.textView.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).count > 0
        sendButton.isEnabled = hasText
        if isKeyboardEnabled {
            sendButton.isHidden = !hasText
            speechToTextButton.isHidden = hasText
        } else {
            sendButton.isHidden = true
            speechToTextButton.isHidden = true
        }
        if sendButton.isHidden {
            if isKeyboardEnabled {
                cancelComposeWidthConstraint.constant = 28.0
            } else {
                cancelComposeWidthConstraint.constant = 0.0
            }
        } else {
            cancelComposeWidthConstraint.constant = 28.0
        }
        composeBarHandler?()
    }
    
    // MARK: Notification handler
    @objc fileprivate func textDidBeginEditingNotification(_ notification: Notification) {
        delegate?.composeBarViewDidBecomeFirstResponder(self)
    }
    
    @objc fileprivate func textDidChangeNotification(_ notification: Notification) {
        valueChanged()
    }

    // MARK: UIResponder Methods
    
    open override var isFirstResponder: Bool {
        return growingTextView.isFirstResponder
    }
    
    open override func becomeFirstResponder() -> Bool {
        return growingTextView.becomeFirstResponder()
    }
    
    open override func resignFirstResponder() -> Bool {
        return growingTextView.resignFirstResponder()
    }
    
    // MARK:- deinit
    deinit {
        topLineView = nil
        bottomLineView = nil
        growingTextView = nil
        sendButton = nil
        speechToTextButton = nil
        textViewTrailingConstraint = nil
    }
}
