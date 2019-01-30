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
    static let buttonsLimit: Int = 3
    static let headerTextLimit: Int = 640
    
    var textLabel: KREAttributedLabel!
    var optionsView: KREOptionsView!
    
    public var optionsAction: ((_ text: String?) -> Void)!
    public var linkAction: ((_ text: String?) -> Void)!
    
    override func initialize() {
        super.initialize()
        
        self.textLabel = KREAttributedLabel(frame: CGRect.zero)
        self.textLabel.textColor = Common.UIColorRGB(0x444444)
        self.textLabel.backgroundColor = UIColor.clear
        self.textLabel.mentionTextColor = Common.UIColorRGB(0x8ac85a)
        self.textLabel.hashtagTextColor = Common.UIColorRGB(0x8ac85a)
        self.textLabel.linkTextColor = Common.UIColorRGB(0x0076FF)
        self.textLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 16.0)
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
        
        let views: [String: UIView] = ["textLabel": textLabel, "optionsView": optionsView]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[textLabel]-10-[optionsView]|", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[textLabel]-10-|", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[optionsView]|", options: [], metrics: nil, views: views))
        
        self.textLabel.setContentHuggingPriority(UILayoutPriority.defaultHigh, for: NSLayoutConstraint.Axis.vertical)
        
        self.optionsView.optionsButtonAction = {[weak self] (text) in
            if((self?.optionsAction) != nil){
                self?.optionsAction(text)
            }
        }
        self.optionsView.detailLinkAction = {[weak self] (text) in
            if((self?.linkAction) != nil){
                self?.linkAction(text)
            }
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
                let buttonsCount: Int = min(buttons.count, OptionsBubbleView.buttonsLimit)
                var options: Array<KREOption> = Array<KREOption>()
                
                for i in 0..<buttonsCount {
                    let dictionary = buttons[i]
                    let title: String = dictionary["title"] != nil ? dictionary["title"] as! String : ""
                    
                    let option: KREOption = KREOption(title: title, subTitle: "", imageURL: "", optionType: .button)
                    option.setDefaultAction(action: Utilities.getKREActionFromDictionary(dictionary: dictionary)!)
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
        let limitingSize: CGSize  = CGSize(width: BubbleViewMaxWidth - 20, height: CGFloat.greatestFiniteMagnitude)
        let textSize: CGSize = self.textLabel.sizeThatFits(limitingSize)
        let rowsHeight = self.optionsView.getExpectedHeight(width: BubbleViewMaxWidth)
        return CGSize(width: BubbleViewMaxWidth, height: textSize.height + rowsHeight + 20)
    }
}
