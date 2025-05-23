//
//  ListBubbleView.swift
//  KoreBotSDKDemo
//
//  Created by developer@kore.com on 12/23/16.
//  Copyright © 2016 Kore Inc. All rights reserved.
//

import UIKit

class ListBubbleView: BubbleView {
    static let elementsLimit: Int = 3
    var tileBgv : UIView!
    var optionsView: KREOptionsView!
    var reloadTable = false
    //public var optionsAction: ((_ text: String?, _ payload: String?) -> Void)!
    //public var linkAction: ((_ text: String?) -> Void)!
    var spaceing = 0.0
    
    override func initialize() {
        super.initialize()
        
        self.tileBgv = UIView(frame:.zero)
        self.tileBgv.translatesAutoresizingMaskIntoConstraints = false
        self.tileBgv.layer.rasterizationScale =  UIScreen.main.scale
        self.tileBgv.layer.shouldRasterize = true
        self.tileBgv.layer.cornerRadius = 0.0
        self.tileBgv.layer.borderColor = UIColor.clear.cgColor
        self.tileBgv.clipsToBounds = true
        self.tileBgv.layer.borderWidth = 0.0
        self.addSubview(self.tileBgv)
        self.tileBgv.backgroundColor = .white
        
        let views: [String: UIView] = ["tileBgv": tileBgv]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[tileBgv]-0-|", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[tileBgv]-0-|", options: [], metrics: nil, views: views))
        
        self.optionsView = KREOptionsView()
        self.optionsView.translatesAutoresizingMaskIntoConstraints = false
        self.optionsView.isUserInteractionEnabled = true
        self.tileBgv.addSubview(self.optionsView)
        
        optionsView.layer.cornerRadius = 0.0
        optionsView.layer.borderWidth = 1.0
        optionsView.layer.borderColor = BubbleViewLeftTint.cgColor
        
        let viewss: [String: UIView] = ["optionsView": optionsView]
        self.tileBgv.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-2-[optionsView]-2-|", options: [], metrics: nil, views: viewss))
        self.tileBgv.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-2-[optionsView]-2-|", options: [], metrics: nil, views: viewss))
        
        
        
        // property blocks
        self.optionsView.optionsButtonAction = { [weak self] (text, payload) in
            if((self?.optionsAction) != nil){
                self?.optionsAction?(text,payload)
            }
        }
        self.optionsView.detailLinkAction = {[weak self] (text) in
            if (self?.linkAction != nil && ((text?.count) != nil)) {
                self?.linkAction?(text)
            }
        }
        
        //if !reloadTable{
           // reloadTable = true
            NotificationCenter.default.post(name: Notification.Name(reloadTableNotification), object: nil)
       // }
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
                    if let defaultAction = dictionary["default_action"] as? [String: Any],
                        let action = Utilities.getKREActionFromDictionary(dictionary: defaultAction) {
                        option.setDefaultAction(action: action)
                    }
                    
                    if let buttons = dictionary["buttons"] as? Array<[String: Any]>, let buttonElement = buttons.first,
                        let action = Utilities.getKREActionFromDictionary(dictionary: buttonElement) {
                        option.setButtonAction(action: action)
                    }
                    
                    options.append(option)
                }
                spaceing = 0.0
                if elements.count > 3{
                    spaceing = 15.0
                    if let buttons = jsonObject["buttons"] as? Array<[String: Any]>, let buttonElement = buttons.first {
                        let title: String = buttonElement["title"] != nil ? buttonElement["title"] as! String : ""
                        
                        let option: KREOption = KREOption(title: title, subTitle: "", imageURL: "", optionType: .button)
                        if let action = Utilities.getKREActionFromDictionary(dictionary: buttonElement) {
                            option.setDefaultAction(action: action)
                        }
                        options.append(option)
                    }
                }
                self.optionsView.options.removeAll()
                self.optionsView.options = options
            }
        }
    }
    
    //MARK: View height calculation
    override var intrinsicContentSize : CGSize {
        let height = self.optionsView.getExpectedHeight(width: BubbleViewMaxWidth)
        let viewSize:CGSize = CGSize(width: BubbleViewMaxWidth, height: height + CGFloat(spaceing))
        return viewSize;
    }
}
