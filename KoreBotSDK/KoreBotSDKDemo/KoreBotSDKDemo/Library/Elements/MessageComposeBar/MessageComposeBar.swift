//
//  MessageComposeBar.swift
//  KoreBotSDKDemo
//
//  Created by Srinivas Vasadi on 25/05/16.
//  Copyright © 2016 Kore. All rights reserved.
//

import UIKit

class MessageComposeBar: UIView, UITextViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    let kButtonSwitchDuration: CGFloat = 0.3
    let kAttachmentCellHeight: CGFloat = 74.0

    @IBOutlet weak var showAccessoryButton :UIButton!
    @IBOutlet weak var closeAccessoryButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var hintTextView: UITextView!
    
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var promptLabel: UILabel!;
    
    weak var ownerViewController: UIViewController!
    
    var value: NSString!
    var actionKeyboardActions: NSArray!
    var isKora: Bool = false
    var isSwitchingKeyboards: Bool = false
    var showingActionKeyboard: Bool = false
    var attachments: NSMutableArray!

    
    // MARK: private properties
    var keyboardUserInfo: NSDictionary!
    var keyboardImage: UIImageView!
    var oldKeyWindow: UIWindow!
    var animationWindow: UIWindow!
    var updatingTextPosition: Bool!
    
    var sendButtonAction: ((_ composeBar: MessageComposeBar?, _ composedMessage: Message?) -> Void)!
    var valueDidChange: ((_ composeBar: MessageComposeBar?) -> Void)!

    var enableSendButton: Bool! {
        didSet(enableButton) {
            if (self.enableSendButton != enableButton) {
                self.setNeedsLayout()
                self.promptLabel.alpha = self.textView.text.characters.count > 0 ? 0.0 : 1.0
                self.layoutIfNeeded()
                
                self.attachmentsCollectionView.reloadData()
            }
            self.sendButton.isEnabled = self.enableSendButton
        }
    }
    
    @IBOutlet weak var containterViewLeadingConstriant: NSLayoutConstraint!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var attachmentsCollectionView: UICollectionView!
    @IBOutlet weak var textViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var topLineHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomLineHeightConstraint: NSLayoutConstraint!
    
    // MARK: init
    override func awakeFromNib() {
        self.containerView.layer.borderColor = Common.UIColorRGB(0xCCCFD0).cgColor
        self.containerView.layer.borderWidth = 0.5
        self.containerView.layer.cornerRadius = 6.0
        self.topLineHeightConstraint.constant = 0.5
        self.bottomLineHeightConstraint.constant = 0.5
        
        self.attachmentsCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier:"Cell")
        
        self.promptLabel.text = "Say Something..."
        self.attachments = NSMutableArray()

        NotificationCenter.default.addObserver(self, selector: #selector(MessageComposeBar.willShowKeyboard(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MessageComposeBar.willHideKeyboard(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MessageComposeBar.didShowKeyboard(_:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MessageComposeBar.didHideKeyboard(_:)), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
        
        
        self.showingActionKeyboard = false;
        
        self.closeAccessoryButton.alpha = self.showAccessoryButton != nil ? 0.0 : 1.0
        self.showAccessoryButton.alpha = self.showAccessoryButton != nil  ? 1.0 : 0.0

        self.textView.font = self.composeBarFont()

        self.enableSendButton = false
        self.closeAccessoryButton.isHidden = true;
        self.showAccessoryButton.isHidden = true;
        self.containterViewLeadingConstriant.constant = 10;
    }
    
    func composeBarFont() -> UIFont {
        return UIFont(name: "HelveticaNeue", size: 14.0)!
    }
    
    func setAlternateInputView(_ alternateInputView: UIView!) {
        
    }
    
    func revertToPriorInputView() {
        
    }
    
    func hideAlternateKeyboard() {
        
    }
    
    func resetKeyboard() {
        self.isSwitchingKeyboards = false
        self.showingActionKeyboard = false
        self.textView.inputView = nil;
        
        self.showAccessoryButton.alpha = 1.0
        self.closeAccessoryButton.alpha = 0.0
        
        self.showAccessoryButton.transform = CGAffineTransform.identity
        self.closeAccessoryButton.isHidden = true;
        self.showAccessoryButton.isHidden = true;

//        self.closeAccessoryButton.transform = CGAffineTransformScale(CGAffineTransformMakeRotation(DEG_TO_RAD(-45.0)), 0.4722, 0.4722)
    }
    
    func clear() {
        self.textView.text = "";
        self.attachments.removeAllObjects()
        self.valueChanged()
    }
    
    func insertText(_ text: NSString!) {
        
    }
    
    func valueChanged() {
        self.invalidateIntrinsicContentSize()
        self.enableSendButton = (self.textView.text.characters.count > 0) || (self.attachments.count > 0)
        
        if (self.valueDidChange != nil) {
//            self.valueDidChange(composeBar: self)
        }
    }

    // MARK: event handlers
    @IBAction func accessoryButtonPressed(_ sender: AnyObject!) {
        self.textView.becomeFirstResponder()
        self.showingActionKeyboard = !self.showingActionKeyboard;
    }
    
    @IBAction func sendButtonPressed(_ sender: AnyObject!) {
        if (self.sendButtonAction != nil) {
            
            let message: Message = Message()
            message.messageType = .default
            message.sentDate = Date()
            
            var currentGroup: ComponentGroup!
            
            // is there any text?
            if (self.textView.text.characters.count > 0) {
                let textComponent: TextComponent = TextComponent()
                textComponent.text = self.textView.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) as NSString!
                
                message.addComponent(textComponent, currentGroup:&currentGroup)
            }
            
            self.sendButtonAction!(self, message)
        }
    }
    
    func willShowKeyboard(_ notification: Notification!) {
        keyboardUserInfo = notification.userInfo! as NSDictionary!
    }
    
    func didShowKeyboard(_ notification: Notification!) {
        // This is done to keep updating the keyboard image
        if (!self.isSwitchingKeyboards && !self.showingActionKeyboard) {
            keyboardImage = UIImageView.init(image: self.getKeyboardImage())
            keyboardImage.frame = (keyboardUserInfo[UIKeyboardFrameEndUserInfoKey]! as AnyObject).cgRectValue
        }
    }
    
    func willHideKeyboard(_ notification: Notification!) {
        keyboardUserInfo = notification.userInfo! as NSDictionary!
        if (!self.isSwitchingKeyboards) {
            let durationValue = keyboardUserInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber
            let duration = durationValue.doubleValue
            let options = UIViewAnimationOptions(rawValue: UInt((keyboardUserInfo[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).int32Value << 16))

            UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
                self.resetKeyboard()
                }, completion: { (Bool) in
                    
            })
        }
    }
    
    func didHideKeyboard(_ notification: Notification!) {
        if (!self.isSwitchingKeyboards) {
            self.textView.inputView = nil;
            self.oldKeyWindow = nil;
            self.animationWindow = nil;
            self.keyboardImage = nil;
        }
    }
    
    // MARK: UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: UICollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        return cell
    }
    
    // MARK: UITextViewDelegate
    func textViewDidChange(_ textView: UITextView) {
        self.valueChanged()
    }

    // MARK: 
    func getKeyboardImage() -> UIImage {
        return UIImage()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.enableSendButton = (self.textView.text.characters.count > 0) || (self.attachments.count > 0)
        
        let range: NSRange = self.textView.selectedRange
        if (range.location >= self.textView.text.characters.count) {
            // scroll to the bottom
            self.textView.scrollRangeToVisible(NSMakeRange(self.textView.text.characters.count, 0))
            self.textView.isScrollEnabled = false
            self.textView.isScrollEnabled = true
        }
    }
    
    override func updateConstraints() {
        self.textViewHeightConstraint.constant = self.calculatedTextHeight()
        super.updateConstraints()
    }
    
    override var intrinsicContentSize : CGSize {
        let collectionHeight: CGFloat = (kAttachmentCellHeight + 4.0) * ceil(CGFloat(self.attachments.count) / 2.0) + (self.attachments.count > 0 ? 4 : 0);
        
        return CGSize(width: UIViewNoIntrinsicMetric, height: self.calculatedTextHeight() + collectionHeight + 12)
    }
    
    func calculatedTextHeight() -> CGFloat {
        let sizingString: NSString = "\n\n\n\n\n\n\n";
        let rect: CGRect = sizingString.boundingRect(with: CGSize(width: self.textView.bounds.size.width, height: CGFloat.greatestFiniteMagnitude),
                                                              options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                                              attributes: [NSFontAttributeName: self.composeBarFont()],
                                                              context: nil)
        let textSize: CGSize = self.textView.sizeThatFits(CGSize(width: self.textView.bounds.size.width, height: CGFloat.greatestFiniteMagnitude))
        return min(textSize.height, rect.size.height + 5);
    }
}
