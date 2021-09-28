//
//  OptionsBubbleView.swift
//  KoreBotSDKDemo
//
//  Created by developer@kore.com on 09/05/16.
//  Copyright © 2016 Kore Inc. All rights reserved.
//

import UIKit
import KoreBotSDK

class OptionsBubbleView: BubbleView {
    static let buttonsLimit: Int = 5
    static let headerTextLimit: Int = 640
    
    var textLabel: KREAttributedLabel!
    var optionsView: KREOptionsView!
    public var maskview: UIView!
    
    public var optionsAction: ((_ text: String?, _ payload: String?) -> Void)?
    public var linkAction: ((_ text: String?) -> Void)?
    
    override func initialize() {
        super.initialize()
        
        self.textLabel = KREAttributedLabel(frame: CGRect.zero)
        self.textLabel.textColor = BubbleViewBotChatTextColor
        self.textLabel.backgroundColor = UIColor.clear
        self.textLabel.mentionTextColor = Common.UIColorRGB(0x8ac85a)
        self.textLabel.hashtagTextColor = Common.UIColorRGB(0x8ac85a)
        self.textLabel.linkTextColor = Common.UIColorRGB(0x0076FF)
        self.textLabel.font = UIFont(name: "Gilroy-Medium", size: 16.0)
        self.textLabel.numberOfLines = 0
        self.textLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        self.textLabel.isUserInteractionEnabled = true
        self.textLabel.contentMode = UIView.ContentMode.topLeft
        self.textLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.textLabel)
        
        self.optionsView = KREOptionsView()
        self.optionsView.translatesAutoresizingMaskIntoConstraints = false
        self.optionsView.isUserInteractionEnabled = true
        self.optionsView.contentMode = UIView.ContentMode.topLeft
        self.addSubview(self.optionsView)
        
        self.maskview = UIView(frame:.zero)
        self.maskview.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.maskview)
        self.maskview.isHidden = true
        maskview.backgroundColor = UIColor(white: 1, alpha: 0.5)
        
        let views: [String: UIView] = ["textLabel": textLabel, "optionsView": optionsView, "maskview": maskview]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-16-[textLabel]-16-[optionsView]|", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[maskview]|", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[textLabel]-16-|", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[optionsView]|", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[maskview]|", options: [], metrics: nil, views: views))
        
        self.textLabel.setContentHuggingPriority(UILayoutPriority.defaultHigh, for: NSLayoutConstraint.Axis.vertical)
        
        self.optionsView.optionsButtonAction = {[weak self] (text, payload) in
            //self?.maskview.isHidden = false
            //isReloadTabV = false
            self?.optionsAction?(text, payload)
        }
        self.optionsView.detailLinkAction = { [weak self] (text) in
            //self?.maskview.isHidden = false
            //rowIndex = 1000
            //isReloadTabV = false
            self?.linkAction?(text)
        }
    }
    
    // MARK: populate components
    override func populateComponents() {
        if (components.count > 0) {
            let component: KREComponent = components.firstObject as! KREComponent
            if (component.componentDesc != nil) {
                let jsonString = component.componentDesc
                let jsonObject: NSDictionary = Utilities.jsonObjectFromString(jsonString: jsonString!) as! NSDictionary
                let buttons: Array<Dictionary<String, Any>> = jsonObject["buttons"] != nil ? jsonObject["buttons"] as! Array<Dictionary<String, Any>> : []
                let buttonsCount: Int = buttons.count //min(buttons.count, OptionsBubbleView.buttonsLimit)
                var options: Array<KREOption> = Array<KREOption>()
                
                for i in 0..<buttonsCount {
                    let dictionary = buttons[i]
                   // let title: String = dictionary["title"] != nil ? dictionary["title"] as! String : ""
                     let title: String = (dictionary["title"] != nil ? dictionary["title"] as? String : "") ?? String(dictionary["title"] as! Int) //kk
                    
                    let option: KREOption = KREOption(title: title, subTitle: "", imageURL: "", optionType: .button)
                    if let action = Utilities.getKREActionFromDictionary(dictionary: dictionary) {
                        option.setDefaultAction(action: action)
                    }
                    options.append(option)
                }
                self.optionsView.options = options
                
                var headerText: String = jsonObject["text"] != nil ? jsonObject["text"] as! String : ""
                headerText = KREUtilities.formatHTMLEscapedString(headerText);
                
                if(headerText.count > OptionsBubbleView.headerTextLimit){
                    headerText = String(headerText[..<headerText.index(headerText.startIndex, offsetBy: OptionsBubbleView.headerTextLimit)]) + "..."
                }
                self.textLabel.setHTMLString(headerText, withWidth: BubbleViewMaxWidth - 20)
            }
        }
    }

    override var intrinsicContentSize : CGSize {
        self.textLabel.font = UIFont(name: "Gilroy-Medium", size: 16.0)
        let limitingSize: CGSize  = CGSize(width: BubbleViewMaxWidth - 32, height: CGFloat.greatestFiniteMagnitude)
        let textSize: CGSize = self.textLabel.sizeThatFits(limitingSize)
        let rowsHeight = self.optionsView.getExpectedHeight(width: BubbleViewMaxWidth)
        return CGSize(width: BubbleViewMaxWidth, height: textSize.height + rowsHeight + 32)
    }
}
