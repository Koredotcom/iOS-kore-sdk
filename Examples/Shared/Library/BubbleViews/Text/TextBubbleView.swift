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
        return (self.tailPosition == BubbleMaskTailPosition.left ? Common.UIColorRGB(0x484848) : Common.UIColorRGB(0xFFFFFF))
    }
    let kMaxTextWidth: CGFloat = BubbleViewMaxWidth - 20.0
    let kMinTextWidth: CGFloat = 20.0
    var textLabel: KREAttributedLabel!
    var iconImageView: UIImageView!
    var iconImageViewWidthConstraint: NSLayoutConstraint!
    
    override func initialize() {
        super.initialize()
        
        self.textLabel = KREAttributedLabel(frame: CGRect.zero)
        self.textLabel.textColor = Common.UIColorRGB(0x484848)
        self.textLabel.mentionTextColor = Common.UIColorRGB(0x8ac85a)
        self.textLabel.hashtagTextColor = Common.UIColorRGB(0x8ac85a)
        self.textLabel.linkTextColor = Common.UIColorRGB(0x0076FF)
        self.textLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 16.0)
        self.textLabel.numberOfLines = 0
        self.textLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        self.textLabel.isUserInteractionEnabled = true
        self.textLabel.contentMode = UIView.ContentMode.topLeft
        self.textLabel.translatesAutoresizingMaskIntoConstraints = false
        self.textLabel.imageDetectionBlock = {[weak self] (reload) in
            self?.onChange(reload)
        }

        self.addSubview(self.textLabel)
        
        iconImageView = UIImageView(frame: CGRect.zero)
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.image = UIImage.init(named: "findly")
        self.addSubview(iconImageView)
        
        let views: [String: UIView] = ["textLabel": textLabel, "iconImageView":iconImageView]
        let metrics: [String: NSNumber] = ["textLabelMaxWidth": NSNumber(value: Float(kMaxTextWidth)), "textLabelMinWidth": NSNumber(value: Float(kMinTextWidth))]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[textLabel]-10-|", options: [], metrics: metrics, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[iconImageView(20)]", options: [], metrics: metrics, views: views))
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[iconImageView(20)]-5-[textLabel(>=textLabelMinWidth,<=textLabelMaxWidth)]-10-|", options: [], metrics: metrics, views: views))
        
        iconImageViewWidthConstraint = NSLayoutConstraint(item: iconImageView, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 20)
        addConstraint(iconImageViewWidthConstraint)
        iconImageViewWidthConstraint.isActive = true
        
    }
    
    func setTextColor() {
        if self.tailPosition == BubbleMaskTailPosition.left {
            self.textLabel.textColor = Common.UIColorRGB(0x484848)
            self.textLabel.linkTextColor = Common.UIColorRGB(0x0076FF)
            iconImageViewWidthConstraint.constant = 20
        }else{
            self.textLabel.textColor = Common.UIColorRGB(0x484848) //0xFFFFFF
            self.textLabel.linkTextColor = Common.UIColorRGB(0xFFFFFF)
            iconImageViewWidthConstraint.constant = 0.0
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
                let parsedString:String = KREUtilities.formatHTMLEscapedString(htmlStrippedString);
                self.textLabel.setHTMLString(parsedString, withWidth: kMaxTextWidth)
                
                let welcomeMsg = serachInterfaceItems?.interactionsConfig?.welcomeMsg
                if welcomeMsg == parsedString{
                    let url = URL(string: (serachInterfaceItems?.interactionsConfig?.welcomeMsgEmoji)!)
                    iconImageView.downloaded(from: url!)

                }else{
                    iconImageView.image = UIImage.init(named: "findly")
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
}

class QuickReplyBubbleView : TextBubbleView {
    
    override func populateComponents() {
        if (components.count > 0) {
            let component: KREComponent = components[0] as! KREComponent
            
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
                    let parsedString:String = KREUtilities.formatHTMLEscapedString(htmlStrippedString);
                    self.textLabel.setHTMLString(parsedString, withWidth: kMaxTextWidth)
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
