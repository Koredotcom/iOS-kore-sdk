//
//  TextBubbleView.swift
//  KoreBotSDKDemo
//
//  Created by developer@kore.com on 09/05/16.
//  Copyright © 2016 Kore Inc. All rights reserved.
//

import UIKit
import KoreTextParser

class TextBubbleView : BubbleView {
    var onChange: ((_ reload: Bool) -> ())!
    func kTextColor() -> UIColor {
        return (self.tailPosition == BubbleMaskTailPosition.left ? Common.UIColorRGB(0x484848) : Common.UIColorRGB(0xFFFFFF))
    }
    func kLeftMargin() -> CGFloat {
        return (self.tailPosition == BubbleMaskTailPosition.left ? 20.0 : 13.0)
    }
    func kRightMargin() -> CGFloat {
        return (self.tailPosition == BubbleMaskTailPosition.left ? 10.0 : 17.0)
    }
    let kVerticalMargin: CGFloat = 10.0
    let kMaxTextWidth: CGFloat = (BubbleViewMaxWidth)

    var textLabel: KREAttributedLabel!
    var text: NSAttributedString! {
        didSet {
            if (self.tailPosition == BubbleMaskTailPosition.right) {
                self.textLabel.textColor = self.kTextColor()
            }
            self.invalidateIntrinsicContentSize()
        }
    }
    override var components: NSArray! {
        didSet {
            if (components.count > 0) {
                let component: KREComponent = components[0] as! KREComponent
                
                if (!component.isKind(of: KREComponent.self)) {
                    return;
                }
                
                self.textLabel.textColor = self.kTextColor()
                if ((component.componentDesc) != nil) {
                    let string: String = component.componentDesc! as String
                    let htmlStrippedString = KREUtilities.getHTMLStrippedString(from: string)
                    let parsedString:String = KREUtilities.formatHTMLEscapedString(htmlStrippedString);

                    self.textLabel.setHTMLString(parsedString, withWidth: kMaxTextWidth)
                    self.textSizeThatFitsWithString(self.textLabel.attributedText!)
                }
            }
        }
    }
    
    override var tailPosition: BubbleMaskTailPosition! {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    override init() {
        super.init()
        self.initialize()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func initialize() {
        super.initialize()
        
        self.textLabel = KREAttributedLabel(frame: CGRect.zero)
        self.textLabel.textColor = Common.UIColorRGB(0x444444)
        self.textLabel.mentionTextColor = Common.UIColorRGB(0x8ac85a)
        self.textLabel.hashtagTextColor = Common.UIColorRGB(0x8ac85a)
        self.textLabel.linkTextColor = Common.UIColorRGB(0x0076FF)
        self.textLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 16.0)
        self.textLabel.numberOfLines = 0
        self.textLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        self.textLabel.isUserInteractionEnabled = true
        self.textLabel.contentMode = UIViewContentMode.topLeft
        self.textLabel.imageDetectionBlock = { (reload) in
            self.onChange(reload)
        }

        self.addSubview(self.textLabel)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        let textSize: CGSize = self.textSizeThatFits()
        self.textLabel.frame = CGRect(x: self.kLeftMargin(), y: self.kVerticalMargin - 4, width: textSize.width, height: textSize.height + self.kVerticalMargin)
    }

    override var intrinsicContentSize : CGSize {
        var textSize: CGSize  = self.textSizeThatFits()
        let minimumWidth: CGFloat = 15
        if textSize.width < minimumWidth {
            textSize.width = minimumWidth
        }
        
        return CGSize(width: textSize.width + 32, height: textSize.height + kVerticalMargin * 2.0);
    }

    func textSizeThatFits() -> CGSize {
        let limitingSize: CGSize  = CGSize(width: kMaxTextWidth , height: CGFloat.greatestFiniteMagnitude)
        let rect: CGRect = self.textLabel.attributedText!.boundingRect(with: limitingSize, options: NSStringDrawingOptions.usesLineFragmentOrigin, context: nil)
        return rect.size;
    }
    
    func textSizeThatFitsWithString(_ string: NSAttributedString) -> CGSize {
        let limitingSize: CGSize  = CGSize(width: kMaxTextWidth , height: CGFloat.greatestFiniteMagnitude)
        let rect: CGRect = string.boundingRect(with: limitingSize, options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                                                     context: nil)
        return rect.size;
    }
}

class QuickReplyBubbleView : TextBubbleView {
    override var components: NSArray! {
        didSet {
            if (components.count > 0) {
                let component: KREComponent = components[0] as! KREComponent
                
                if (!component.isKind(of: KREComponent.self)) {
                    return;
                }
                
                self.textLabel.textColor = self.kTextColor()
                if (component.componentDesc != nil) {
                    let jsonString = component.componentDesc
                    let jsonObject: NSDictionary = Utilities.jsonObjectFromString(jsonString: jsonString!) as! NSDictionary
                        if (jsonObject["text"] != nil) {
                            let string: String = jsonObject["text"] as! String
                            let htmlStrippedString = KREUtilities.getHTMLStrippedString(from: string)
                            let parsedString:String = KREUtilities.formatHTMLEscapedString(htmlStrippedString);
        
                            self.textLabel.setHTMLString(parsedString, withWidth: kMaxTextWidth)
                            self.textSizeThatFitsWithString(self.textLabel.attributedText!)
                        }
                }
            }
        }
    }
}
