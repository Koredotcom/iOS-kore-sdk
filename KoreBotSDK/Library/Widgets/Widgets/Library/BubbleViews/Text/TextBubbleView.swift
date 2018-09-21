//
//  TextBubbleView.swift
//  KoreBotSDKDemo
//
//  Created by developer@kore.com on 09/05/16.
//  Copyright © 2016 Kore Inc. All rights reserved.
//

import UIKit

class TextBubbleView : BubbleView {
    var onChange: ((_ reload: Bool) -> ())!
    func kTextColor() -> UIColor {
        return (self.tailPosition == BubbleMaskTailPosition.left ? UIColorRGB(0x484848) : UIColorRGB(0xFFFFFF))
    }
    let kMaxTextWidth: CGFloat = BubbleViewMaxWidth - 20.0
    let kMinTextWidth: CGFloat = 20.0
    var textLabel: KREAttributedLabel!
    
    override func initialize() {
        super.initialize()
        
        self.textLabel = KREAttributedLabel(frame: CGRect.zero)
        self.textLabel.textColor = UIColorRGB(0x484848)
        self.textLabel.mentionTextColor = UIColorRGB(0x8ac85a)
        self.textLabel.hashtagTextColor = UIColorRGB(0x8ac85a)
        self.textLabel.linkTextColor = UIColorRGB(0x0076FF)
        self.textLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 16.0)
        self.textLabel.numberOfLines = 0
        self.textLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        self.textLabel.isUserInteractionEnabled = true
        self.textLabel.contentMode = UIViewContentMode.topLeft
        self.textLabel.translatesAutoresizingMaskIntoConstraints = false
        self.textLabel.imageDetectionBlock = { [unowned self] (reload) in
            self.onChange(reload)
        }

        self.addSubview(self.textLabel)
        
        let views: [String: UIView] = ["textLabel": textLabel]
        let metrics: [String: NSNumber] = ["textLabelMaxWidth": NSNumber(value: Float(kMaxTextWidth)), "textLabelMinWidth": NSNumber(value: Float(kMinTextWidth))]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[textLabel]-10-|", options: [], metrics: metrics, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[textLabel(>=textLabelMinWidth,<=textLabelMaxWidth)]-10-|", options: [], metrics: metrics, views: views))
    }
    
    func setTextColor() {
        if self.tailPosition == BubbleMaskTailPosition.left {
            self.textLabel.textColor = UIColorRGB(0x484848)
            self.textLabel.linkTextColor = UIColorRGB(0x0076FF)
        } else {
            self.textLabel.textColor = UIColorRGB(0xFFFFFF)
            self.textLabel.linkTextColor = UIColorRGB(0xFFFFFF)
        }
    }
    
    // MARK: populate components
    override func populateComponents() {
        if let component = components?.first {
            setTextColor()

            if let string = component.componentDesc {
                let htmlStrippedString = KREUtilities.getHTMLStrippedString(from: string)
                let parsedString:String = KREUtilities.formatHTMLEscapedString(htmlStrippedString);
                self.textLabel.setHTMLString(parsedString, withWidth: kMaxTextWidth)
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
}

class QuickReplyBubbleView : TextBubbleView {
    
    override func populateComponents() {
        if let component = components?.first {
            if (!component.isKind(of: KREComponent.self)) {
                return;
            }
            
            self.textLabel.textColor = self.kTextColor()
            if (component.componentDesc != nil) {
                let jsonString = component.componentDesc
                let jsonObject: NSDictionary = Utilities.jsonObjectFromString(jsonString: jsonString!) as! NSDictionary

                if let string: String = jsonObject["text"] as? String {
                    let htmlStrippedString = KREUtilities.getHTMLStrippedString(from: string)
                    let parsedString:String = KREUtilities.formatHTMLEscapedString(htmlStrippedString);
                    self.textLabel.setHTMLString(parsedString, withWidth: kMaxTextWidth)
                }else{
                    self.textLabel.setHTMLString("", withWidth: kMaxTextWidth)
                }
            }
        }
    }
}

class ErrorBubbleView: TextBubbleView {
    override func populateComponents() {
        if let component = components?.first, let jsonString = component.componentDesc {
            let jsonObject: NSDictionary = Utilities.jsonObjectFromString(jsonString: jsonString) as! NSDictionary
            
            if let string: String = jsonObject["text"] as? String{
                let htmlStrippedString = KREUtilities.getHTMLStrippedString(from: string)
                let parsedString:String = KREUtilities.formatHTMLEscapedString(htmlStrippedString);
                self.textLabel.setHTMLString(parsedString, withWidth: kMaxTextWidth)
            } else {
                self.textLabel.setHTMLString("", withWidth: kMaxTextWidth)
            }
            
            if var colorString: String = jsonObject["color"] as? String {
                if(colorString.hasPrefix("#")){
                    colorString = String(colorString.dropFirst())
                }
                self.textLabel.textColor = UIColorRGB(Int(colorString, radix: 16)!)
            }
        }
    }
}

class PickerBubbleView: TextBubbleView {
    override func populateComponents() {
        if let component = components?.first {
            if (!component.isKind(of: KREComponent.self)) {
                return;
            }
            
            self.textLabel.textColor = self.kTextColor()
            if (component.componentDesc != nil) {
                let jsonString = component.componentDesc
                let jsonObject: NSDictionary = Utilities.jsonObjectFromString(jsonString: jsonString!) as! NSDictionary
                
                if let string: String = jsonObject["text"] as? String {
                    let htmlStrippedString = KREUtilities.getHTMLStrippedString(from: string)
                    let parsedString:String = KREUtilities.formatHTMLEscapedString(htmlStrippedString);
                    self.textLabel.setHTMLString(parsedString, withWidth: kMaxTextWidth)
                } else {
                    self.textLabel.setHTMLString("", withWidth: kMaxTextWidth)
                }
            }
        }
    }
}

class SessionEndBubbleView: BubbleView {
    override func populateComponents() {
        
    }
}

class BottombubbleView: BubbleView {
    override func populateComponents() {
        
    }
}

class AgentTransferModeBubbleView: TextBubbleView {
    override func populateComponents() {
        if let component = components?.first {
            self.textLabel.setHTMLString("", withWidth: kMaxTextWidth)
            
            if let jsonString = component.componentDesc, let jsonObject = Utilities.jsonObjectFromString(jsonString: jsonString) as? [String: Any], let string: String = jsonObject["text"] as? String {
                let htmlStrippedString = KREUtilities.getHTMLStrippedString(from: string)
                let parsedString:String = KREUtilities.formatHTMLEscapedString(htmlStrippedString);
                self.textLabel.setHTMLString(parsedString, withWidth: kMaxTextWidth)
            }
        }
    }
}

