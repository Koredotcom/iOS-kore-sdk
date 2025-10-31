//
//  TextBubbleView.swift
//  KoreBotSDKDemo
//
//  Created by developer@kore.com on 09/05/16.
//  Copyright © 2016 Kore Inc. All rights reserved.
//

import UIKit
#if SWIFT_PACKAGE
import ObjcSupport
#endif
class TextBubbleView : BubbleView {
    var onChange: ((_ reload: Bool) -> ())!
    func kTextColor() -> UIColor {
        return (self.tailPosition == BubbleMaskTailPosition.left ? Common.UIColorRGB(0x484848) : Common.UIColorRGB(0xFFFFFF))
    }
    var kMaxTextWidth: CGFloat {
        // Maintain the same percentage of screen width as portrait across orientations
        let windowWidth = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.bounds.width ?? UIScreen.main.bounds.size.width
        let portraitBase = min(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height)
        let portraitMax = portraitBase - 90.0
        let ratio = portraitBase > 0 ? (portraitMax / portraitBase) : 1.0
        let bubbleMaxWidth = ratio * windowWidth
        // Subtract internal horizontal padding (10 + 10)
        return bubbleMaxWidth - 20.0
    }
    let kMinTextWidth: CGFloat = 20.0
    var textLabel: KREAttributedLabel!
    private var textLabelMaxWidthConstraint: NSLayoutConstraint?
    
    override func initialize() {
        super.initialize()
        
        self.textLabel = KREAttributedLabel(frame: CGRect.zero)
        self.textLabel.textColor = Common.UIColorRGB(0x484848)
        self.textLabel.mentionTextColor = Common.UIColorRGB(0x8ac85a)
        self.textLabel.hashtagTextColor = Common.UIColorRGB(0x8ac85a)
        self.textLabel.linkTextColor = Common.UIColorRGB(0x0076FF)
        self.textLabel.font = UIFont(name: mediumCustomFont, size: 16.0)
        self.textLabel.numberOfLines = 0
        self.textLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        self.textLabel.isUserInteractionEnabled = true
        self.textLabel.contentMode = UIView.ContentMode.topLeft
        self.textLabel.translatesAutoresizingMaskIntoConstraints = false
        self.textLabel.imageDetectionBlock = {[weak self] (reload) in
            self?.onChange(reload)
        }

        self.addSubview(self.textLabel)
        
        let views: [String: UIView] = ["textLabel": textLabel]
        let metrics: [String: NSNumber] = ["textLabelMaxWidth": NSNumber(value: Float(kMaxTextWidth)), "textLabelMinWidth": NSNumber(value: Float(kMinTextWidth))]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[textLabel]-10-|", options: [], metrics: metrics, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[textLabel(>=textLabelMinWidth,<=textLabelMaxWidth)]-10-|", options: [], metrics: metrics, views: views))
        // Capture the lessThanOrEqual width constraint created by VFL for dynamic updates
        for constraint in self.constraints {
            if constraint.firstItem as? UIView === self.textLabel && constraint.firstAttribute == .width && constraint.relation == .lessThanOrEqual {
                self.textLabelMaxWidthConstraint = constraint
                break
            }
        }
    }
    
    func setTextColor() {
        if self.tailPosition == BubbleMaskTailPosition.left {
            self.textLabel.textColor = BubbleViewBotChatTextColor
            self.textLabel.linkTextColor = Common.UIColorRGB(0x0076FF)
        }else{
            self.textLabel.textColor = BubbleViewUserChatTextColor
            self.textLabel.linkTextColor = Common.UIColorRGB(0xFFFFFF)
        }
    }
    
    // MARK: populate components
    override func populateComponents() {
        if (components.count > 0) {
            let component: KREComponent = components[0] as! KREComponent
            
            if (!component.isKind(of: KREComponent.self)) {
                return;
            }
            
            setTextColor()
            if ((component.componentDesc) != nil) {
                let string: String = component.componentDesc! as String
                let htmlStrippedString = KREUtilities.getHTMLStrippedString(from: string)
                if let parsedString = KREUtilities.formatHTMLEscapedString(htmlStrippedString) {
                    var replaceStr = parsedString
                    if isEmojiDispaly{
                        replaceStr = replaceUnicodeWithEmojis(input: replaceStr)
                    }
                    self.textLabel.setHTMLString(replaceStr, withWidth: kMaxTextWidth)
                }else{
                    var replaceStr = string
                    if isEmojiDispaly{
                        replaceStr = replaceUnicodeWithEmojis(input: replaceStr)
                    }
                    self.textLabel.text = replaceStr
                }
            }
        }
    }
    
    override var intrinsicContentSize : CGSize {
        let limitingSize: CGSize  = CGSize(width: kMaxTextWidth, height: CGFloat.greatestFiniteMagnitude)
        var textSize: CGSize = self.textLabel.sizeThatFits(limitingSize)
        if textSize.height < self.textLabel.font.pointSize {
            textSize.height = self.textLabel.font.pointSize
        }
        return CGSize(width: textSize.width + 20, height: textSize.height + 20)
    }
    
    func replaceUnicodeWithEmojis(input: String) -> String {
        // Dictionary mapping Unicode sequences to Emojis
        let emojis = emojiDic["emojis"] as? [String: String] ?? [:]
        let unicodeToEmoji: [String: String] = emojis
        
        var output = input
        
        // Replace each Unicode with corresponding emoji
        for (unicode, emoji) in unicodeToEmoji {
             let emojiStr = emoji.unicode
            output = output.replacingOccurrences(of: unicode, with: emojiStr ?? "")
        }
        
        return output
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Update the max width constraint to maintain portrait-based margins across orientations
        if let c = textLabelMaxWidthConstraint {
            let newMax = kMaxTextWidth
            if abs(c.constant - newMax) > 0.5 {
                c.constant = newMax
                self.textLabel.preferredMaxLayoutWidth = newMax
                self.invalidateIntrinsicContentSize()
            }
        }
    }
}

class QuickReplyBubbleView : TextBubbleView {
    
    override func populateComponents() {
        if (components.count > 0) {
            let component: KREComponent = components[0] as! KREComponent
            
            if (!component.isKind(of: KREComponent.self)) {
                return;
            }
            
            setTextColor()
            if (component.componentDesc != nil) {
                let jsonString = component.componentDesc
                let jsonObject: NSDictionary = Utilities.jsonObjectFromString(jsonString: jsonString!) as! NSDictionary

                if let string: String = jsonObject["text"] as? String {
                    let htmlStrippedString = KREUtilities.getHTMLStrippedString(from: string)
                    if let parsedString = KREUtilities.formatHTMLEscapedString(htmlStrippedString) {
                        self.textLabel.setHTMLString(parsedString, withWidth: kMaxTextWidth)
                    }
                }else{
                    self.textLabel.setHTMLString("", withWidth: kMaxTextWidth)
                }
            }
        }
    }
}

class ErrorBubbleView : TextBubbleView {
    
    override func populateComponents() {
        if (components.count > 0) {
            let component: KREComponent = components[0] as! KREComponent
            
            if (!component.isKind(of: KREComponent.self)) {
                return;
            }
            
            if (component.componentDesc != nil) {
                let jsonString = component.componentDesc
                let jsonObject: NSDictionary = Utilities.jsonObjectFromString(jsonString: jsonString!) as! NSDictionary
                
                if let string: String = jsonObject["text"] as? String{
                    let htmlStrippedString = KREUtilities.getHTMLStrippedString(from: string)
                    if let parsedString = KREUtilities.formatHTMLEscapedString(htmlStrippedString) {
                        self.textLabel.setHTMLString(parsedString, withWidth: kMaxTextWidth)
                    }
                }else{
                    self.textLabel.setHTMLString("", withWidth: kMaxTextWidth)
                }
            
                if var colorString: String = jsonObject["color"] as? String {
                    if(colorString.hasPrefix("#")){
                        colorString = String(colorString.dropFirst())
                    }
                    self.textLabel.textColor = Common.UIColorRGB(Int(colorString, radix: 16)!)
                }
            }
        }
    }
}
extension String {
    var unicode: String? {
        if let charCode = UInt32(self, radix: 16),
           let unicode = UnicodeScalar(charCode) {
            let str = String(unicode)
            return str
        }
        return nil
    }
}
