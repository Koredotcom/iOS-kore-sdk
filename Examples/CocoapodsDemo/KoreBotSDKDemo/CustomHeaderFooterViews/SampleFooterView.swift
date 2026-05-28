//
//  SampleFooterVieww.swift
//  KoreBotSDKDemo
//
//  Created by Pagidimarri Kartheek on 03/12/24.
//  Copyright © 2024 Kore. All rights reserved.
//

import Foundation
import KoreBotSDK
class SampleFooterView: ComposeBarView {
    var menuButton: UIButton = {
        let menuButton = UIButton(frame: .zero)
        menuButton.translatesAutoresizingMaskIntoConstraints = false
        menuButton.backgroundColor = UIColor.whiteTwo
        menuButton.setImage(UIImage(named: "menu", in: nil, compatibleWith: nil), for: .normal)
        menuButton.addTarget(self, action: #selector(menuBtnAction(_:)), for: .touchUpInside)
        return menuButton
    }()
    
    var sendButton: UIButton = {
        let sendButton = UIButton(frame: .zero)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.backgroundColor = UIColor.whiteTwo
        sendButton.setImage(UIImage(named: "send", in: nil, compatibleWith: nil), for: .normal)
        sendButton.addTarget(self, action: #selector(sendBtnAction(_:)), for: .touchUpInside)
        return sendButton
    }()
    
    var attachmentButton: UIButton = {
        let attachmentButton = UIButton(frame: .zero)
        attachmentButton.translatesAutoresizingMaskIntoConstraints = false
        attachmentButton.backgroundColor = UIColor.whiteTwo
        attachmentButton.setImage(UIImage(named: "add", in: nil, compatibleWith: nil), for: .normal)
        attachmentButton.addTarget(self, action: #selector(attachmentBtnAction(_:)), for: .touchUpInside)
        return attachmentButton
    }()
    
    var spechToTextButton: UIButton = {
        let spechToTextButton = UIButton(frame: .zero)
        spechToTextButton.translatesAutoresizingMaskIntoConstraints = false
        spechToTextButton.backgroundColor = UIColor.whiteTwo
        spechToTextButton.setImage(UIImage(named: "microphone", in: nil, compatibleWith: nil), for: .normal)
        spechToTextButton.addTarget(self, action: #selector(spechToTextBtnAction(_:)), for: .touchUpInside)
        return spechToTextButton
    }()

   
    
    var textV: KREGrowingTextView = {
        let textV = KREGrowingTextView(frame: .zero)
        textV.font = UIFont.systemFont(ofSize: 14)
        textV.contentMode = .scaleAspectFit
        textV.isHidden = false
        textV.translatesAutoresizingMaskIntoConstraints = false
        let attributes: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font:  UIFont.systemFont(ofSize: 14.0), NSAttributedString.Key.foregroundColor: Common.UIColorRGB(0xB5B9BA)]
        textV.placeholderAttributedText = NSAttributedString(string: "Message", attributes:attributes)
        return textV
    }()
   
    override func setupViews() {
        self.addSubview(menuButton)
        self.addSubview(textV)
        self.addSubview(sendButton)
        self.addSubview(attachmentButton)
        self.addSubview(spechToTextButton)
        NotificationCenter.default.addObserver(self, selector: #selector(eventOccurredInParent), name:  NSNotification.Name(rawValue: "koreFooterViewValueChanged"), object: nil)
        
        textV.layer.borderColor = UIColor.red.cgColor
        textV.layer.borderWidth = 0.0
        
        let views: [String : Any] = ["menuButton": menuButton, "textV": textV, "sendButton": sendButton, "attachmentButton": attachmentButton,"spechToTextButton": spechToTextButton]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[menuButton(30)]-5-[textV]-5-[sendButton(30)]-5-[attachmentButton(30)]-5-[spechToTextButton(30)]-10-|", options:[], metrics:nil, views:views))
       
       self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-7-[textV]-7-|", options:[], metrics:nil, views:views))
       self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[sendButton(30)]-8-|", options:[], metrics:nil, views:views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[menuButton(30)]-8-|", options:[], metrics:nil, views:views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[attachmentButton(30)]-8-|", options:[], metrics:nil, views:views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[spechToTextButton(30)]-8-|", options:[], metrics:nil, views:views))
        
        self.koreFooterViewBranding = {[weak self] (brandingDic) in
            guard let dic = brandingDic else {
                return
            }
            
            let footerBgColor = dic["footerBgColor"] as? String ?? "#FFFFFF"
            let footerTextColor = dic["footerTextColor"] as? String ?? "#000000"
            let footerPlaceholderColor = dic["footerPlaceholderColor"] as? String ?? "#999999"
            let footerPlaceholderText = dic["footerPlaceholderText"] as? String ?? "Type a message..."
            let footerBorderColor = dic["footerBorderColor"] as? String ?? "#E0E0E0"
            let footerTextViewBgColor = dic["footerTextViewBgColor"] as? String ?? "#FFFFFF"
            
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 14.0),
                .foregroundColor: UIColor(hexString: footerPlaceholderColor)
            ]
            
            self?.textV.placeholderAttributedText = NSAttributedString(
                string: footerPlaceholderText,
                attributes: attributes
            )
            
            self?.textV.textView.textColor = UIColor(hexString: footerTextColor)
            self?.textV.textView.tintColor = UIColor(hexString: footerTextColor)
            
            self?.textV.layer.borderColor = UIColor(hexString: footerBorderColor).cgColor
            self?.textV.layer.borderWidth = 1.0
            self?.textV.layer.cornerRadius = 5.0
            self?.textV.clipsToBounds = true
            
            self?.textV.backgroundColor = UIColor(hexString: footerTextViewBgColor)
            self?.backgroundColor = UIColor(hexString: footerBgColor)
        }
    }
    
    @objc func menuBtnAction(_ sender: AnyObject) {
        koreFooterViewMenuButtonAction?()
    }
    
    @objc func sendBtnAction(_ sender: AnyObject) {
        koreFooterViewSendButtonAction?(textV.textView.text)
        //textV.textView.text = ""
    }
    
    @objc func attachmentBtnAction(_ sender: AnyObject) {
        koreFooterViewAttachmentButtonAction?()
    }
    
    @objc func spechToTextBtnAction(_ sender: AnyObject) {
        koreFooterViewSpechToTextButtonAction?()
    }
    
    @objc func eventOccurredInParent(notification:Notification) {
        let dataString: String = notification.object as! String
        let jsonObject: NSDictionary = Utilities.jsonObjectFromString(jsonString: dataString) as! NSDictionary
        let isKoreKeyboardEnabled = jsonObject["isKeyboardEnabled"] as! Bool
        let koreAttachmentKeybord = jsonObject["attachmentKeybord"] as! Bool
        
        let hasText = textV.textView.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).count > 0
        self.sendButton.isEnabled = hasText
        if isKoreKeyboardEnabled {
            self.attachmentButton.isHidden = false
            if koreAttachmentKeybord{
                self.sendButton.isHidden = false
                self.sendButton.isEnabled = true
                self.spechToTextButton.isHidden = true
            }else{
                self.sendButton.isHidden = !hasText
                self.spechToTextButton.isHidden = hasText
            }
            self.menuButton.isHidden = false
        }else{
            self.sendButton.isHidden = true
            self.spechToTextButton.isHidden = true
            self.menuButton.isHidden = true
            self.attachmentButton.isHidden = true
        }
    }
    deinit {
        // Remove observer when parent view controller is deallocated
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "koreFooterViewValueChanged"), object: nil)
    }
}
