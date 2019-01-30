//
//  CarouselBubbleView.swift
//  KoreBotSDKDemo
//
//  Created by anoop on 23/05/17.
//  Copyright © 2017 Kore. All rights reserved.
//

import UIKit
import KoreBotSDK

class CarouselBubbleView: BubbleView {
    var carouselView: KRECarouselView!
    
    public var optionsAction: ((_ text: String?) -> Void)!
    public var linkAction: ((_ text: String?) -> Void)!
    
    override func applyBubbleMask() {
        //nothing to put here
    }
    
    override var tailPosition: BubbleMaskTailPosition! {
        didSet {
            self.backgroundColor =  UIColor.clear
        }
    }
    
    override func initialize() {
        super.initialize()
        
        self.carouselView = KRECarouselView()
        self.carouselView.maxCardWidth = BubbleViewMaxWidth
        self.carouselView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.carouselView)
        
        let views: [String: UIView] = ["carouselView": carouselView]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[carouselView]|", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[carouselView]|", options: [], metrics: nil, views: views))
        
        self.carouselView.optionsAction = {[weak self] (text) in
            if((self?.optionsAction) != nil){
                self?.optionsAction(text)
            }
        }
        self.carouselView.linkAction = {[weak self] (text) in
            if(self?.linkAction != nil){
                self?.linkAction(text)
            }
        }
    }
    
    override func borderColor() -> UIColor {
        return UIColor.clear
    }
    
    // MARK: populate components
    override func populateComponents() {
        if (components.count > 0) {
            let component: KREComponent = components.firstObject as! KREComponent
            if (component.componentDesc != nil) {
                let jsonString = component.componentDesc
                let jsonObject: NSDictionary = Utilities.jsonObjectFromString(jsonString: jsonString!) as! NSDictionary
                let elements: Array<Dictionary<String, Any>> = jsonObject["elements"] != nil ? jsonObject["elements"] as! Array<Dictionary<String, Any>> : []
                let elementsCount: Int = min(elements.count, KRECarouselView.cardLimit)
                var cards: Array<KRECardInfo> = Array<KRECardInfo>()
                
                for i in 0..<elementsCount {
                    let dictionary = elements[i]
                    
                    let title: String = dictionary["title"] != nil ? dictionary["title"] as! String : ""
                    let subtitle: String = dictionary["subtitle"] != nil ? dictionary["subtitle"] as! String : ""
                    let imageUrl: String = dictionary["image_url"] != nil ? dictionary["image_url"] as! String : ""
                    
                    let cardInfo: KRECardInfo = KRECardInfo(title: title, subTitle: subtitle, imageURL: imageUrl)
                    if (dictionary["default_action"] != nil) {
                        let defaultAction = dictionary["default_action"] as! Dictionary<String, Any>
                        cardInfo.setDefaultAction(action: Utilities.getKREActionFromDictionary(dictionary: defaultAction)!)
                    }
                    
                    let buttons: Array<Dictionary<String, Any>> = dictionary["buttons"] != nil ? dictionary["buttons"] as! Array<Dictionary<String, Any>> : []
                    let buttonsCount: Int = min(buttons.count, KRECardInfo.buttonLimit)
                    var options: Array<KREOption> = Array<KREOption>()
                    
                    for i in 0..<buttonsCount {
                        let buttonElement = buttons[i]
                        let title: String = buttonElement["title"] != nil ? buttonElement["title"] as! String: ""
                        
                        let option: KREOption = KREOption(title: title, subTitle: "", imageURL: "", optionType: .button)
                        option.setDefaultAction(action: Utilities.getKREActionFromDictionary(dictionary: buttonElement)!)
                        options.append(option)
                    }
                    cardInfo.setOptions(options: options)
                    cards.append(cardInfo)
                }
                
                self.carouselView.cards.removeAll()
                self.carouselView.cards = cards
            }
        }
    }
    
    override var intrinsicContentSize : CGSize {
        return CGSize(width: 0.0, height: self.carouselView.maxCardHeight)
    }
    
    override func prepareForReuse() {
        self.carouselView.prepareForReuse()
    }
}
