//
//  ListBubbleView.swift
//  KoreBotSDKDemo
//
//  Created by developer@kore.com on 12/23/16.
//  Copyright © 2016 Kore Inc. All rights reserved.
//

import UIKit
import KoreBotSDK

class ListBubbleView: BubbleView {
    static let elementsLimit: Int = 4

    var optionsView: KREOptionsView!
    
    public var optionsAction: ((_ text: String?) -> Void)!
    public var linkAction: ((_ text: String?) -> Void)!
    
    override func initialize() {
        super.initialize()
        
        self.optionsView = KREOptionsView()
        self.optionsView.translatesAutoresizingMaskIntoConstraints = false
        self.optionsView.isUserInteractionEnabled = true
        self.addSubview(self.optionsView)
        
        let views: [String: UIView] = ["optionsView": optionsView]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[optionsView]|", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[optionsView]|", options: [], metrics: nil, views: views))
        
        // property blocks
        self.optionsView.optionsButtonAction = {[weak self] (text) in
            if((self?.optionsAction) != nil){
                self?.optionsAction(text)
            }
        }
        self.optionsView.detailLinkAction = {[weak self] (text) in
            if (self?.linkAction != nil && ((text?.count) != nil)) {
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
                let elements: Array<Dictionary<String, Any>> = jsonObject["elements"] != nil ? jsonObject["elements"] as! Array<Dictionary<String, Any>> : []
                let elementsCount: Int = min(elements.count, ListBubbleView.elementsLimit)
                var options: Array<KREOption> = Array<KREOption>()
                
                for i in 0..<elementsCount {
                    let dictionary = elements[i]
                    
                    let title: String = dictionary["title"] != nil ? dictionary["title"] as! String : ""
                    let subtitle: String = dictionary["subtitle"] != nil ? dictionary["subtitle"] as! String : ""
                    let imageUrl: String = dictionary["image_url"] != nil ? dictionary["image_url"] as! String : ""
                    
                    let option: KREOption = KREOption(title: title, subTitle: subtitle, imageURL: imageUrl, optionType: .list)
                    if (dictionary["default_action"] != nil) {
                        let defaultAction = dictionary["default_action"] as! Dictionary<String, Any>
                        option.setDefaultAction(action: Utilities.getKREActionFromDictionary(dictionary: defaultAction)!)
                    }
                    
                    let buttons: Array<Dictionary<String, Any>> = dictionary["buttons"] != nil ? dictionary["buttons"] as! Array<Dictionary<String, Any>> : []
                    if (buttons.count > 0) {
                        let buttonElement: Dictionary<String, Any> = buttons.first! as Dictionary<String, Any>
                        option.setButtonAction(action: Utilities.getKREActionFromDictionary(dictionary: buttonElement)!)
                    }
                    
                    options.append(option)
                }
                
                let buttons: Array<Dictionary<String, Any>> = jsonObject["buttons"] != nil ? jsonObject["buttons"] as! Array<Dictionary<String, Any>> : []
                if (buttons.count > 0) {
                    let buttonElement: Dictionary<String, Any> = buttons.first! as Dictionary<String, Any>
                    let title: String = buttonElement["title"] != nil ? buttonElement["title"] as! String : ""
                    
                    let option: KREOption = KREOption(title: title, subTitle: "", imageURL: "", optionType: .button)
                    option.setDefaultAction(action: Utilities.getKREActionFromDictionary(dictionary: buttonElement)!)
                    options.append(option)
                }
                
                self.optionsView.options.removeAll()
                self.optionsView.options = options
            }
        }
    }
    
    //MARK: View height calculation
    override var intrinsicContentSize : CGSize {
        let height = self.optionsView.getExpectedHeight(width: BubbleViewMaxWidth)
        let viewSize:CGSize = CGSize(width: BubbleViewMaxWidth, height: height)
        return viewSize;
    }
}
