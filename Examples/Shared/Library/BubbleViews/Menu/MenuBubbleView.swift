//
//  MenuBubbleView.swift
//  KoreBotSDKDemo
//
//  Created by Sowmya Ponangi on 04/04/18.
//  Copyright © 2018 Kore. All rights reserved.
//


import UIKit
import KoreBotSDK

class MenuBubbleView: BubbleView {
    static let btnLimit: Int = 3
    static let headerTextLimit: Int = 640
    
    var textLabel: KREAttributedLabel!
    var optionsView: KREOptionsView!
    var cardView: UIView!
    var showMoreButton: UIButton!
    var showMore = false
    
    public var optionsAction: ((_ text: String?) -> Void)!
    public var linkAction: ((_ text: String?) -> Void)!
    
    func intializeCardLayout(){
        self.cardView = UIView(frame:.zero)
        self.cardView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.cardView)
        cardView.layer.rasterizationScale =  UIScreen.main.scale
        cardView.layer.shadowColor = UIColor(red: 232/255, green: 232/255, blue: 230/255, alpha: 1).cgColor
        cardView.layer.shadowOpacity = 1
        cardView.layer.shadowOffset =  CGSize(width: 0.0, height: -3.0)
        cardView.layer.shadowRadius = 6.0
        cardView.layer.shouldRasterize = true
        cardView.backgroundColor =  UIColor.clear
        let cardViews: [String: UIView] = ["cardView": cardView]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[cardView]-10-|", options: [], metrics: nil, views: cardViews))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[cardView]-10-|", options: [], metrics: nil, views: cardViews))
    }
    
    override func initialize() {
        super.initialize()
        
        self.textLabel = KREAttributedLabel(frame: CGRect.zero)
        self.textLabel.textColor = UIColor.white
        
        self.textLabel.backgroundColor = UIColor.clear
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
        
        self.showMoreButton = UIButton.init(frame: CGRect.zero)
        self.showMoreButton.setTitle("Show More", for: .normal)
        self.showMoreButton.translatesAutoresizingMaskIntoConstraints = false
        self.showMoreButton.setTitleColor(UIColor(red: 95/255, green: 107/255, blue: 247/255, alpha: 1), for: .normal)
        self.showMoreButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 14.0)!
        self.showMoreButton.addTarget(self, action: #selector(self.showMoreButtonAction(_:)), for: .touchUpInside)
        self.showMoreButton.isHidden = true
        self.showMoreButton.clipsToBounds = true
        self.addSubview(self.showMoreButton)
        
        let views: [String: UIView] = ["textLabel": textLabel, "optionsView": optionsView, "showMoreButton": showMoreButton]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[textLabel]-10-[optionsView]|", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[textLabel]-10-|", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[optionsView]|", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[showMoreButton(36.0)]|", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[showMoreButton]-10-|", options: [], metrics: nil, views: views))
        
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
   override func borderColor() -> UIColor {
        if (self.tailPosition == BubbleMaskTailPosition.left) {
            return userColor//BubbleViewLeftTint
        }
        
        return BubbleViewRightTint
    }
    // MARK: populate components
    override func populateComponents() {
        if (components.count > 0) {
            let component: KREComponent = components.firstObject as! KREComponent
            if (component.componentDesc != nil) {
                let jsonString = component.componentDesc
                let jsonObject: NSDictionary = Utilities.jsonObjectFromString(jsonString: jsonString!) as! NSDictionary
                let buttons: Array<Dictionary<String, Any>> = jsonObject["buttons"] != nil ? jsonObject["buttons"] as! Array<Dictionary<String, Any>> : []
               var buttonsCount: Int = Int ()
                if(buttons.count > OptionsBubbleView.buttonsLimit && !showMore){
                    self.showMoreButton.isHidden = false
                }
                if(self.showMoreButton.isHidden){
                   buttonsCount = buttons.count
                }
                else{
                    buttonsCount = MenuBubbleView.btnLimit
                }
                var options: Array<KREOption> = Array<KREOption>()
                
                for i in 0..<buttonsCount {
                    let dictionary = buttons[i]
                    let title: String = dictionary["title"] != nil ? dictionary["title"] as! String : ""
                    let imageUrl: String = dictionary["image_url"] != nil ? dictionary["image_url"] as! String : ""
                    let option: KREOption = KREOption(title: title, subTitle: "", imageURL: imageUrl, optionType: .menu)
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
        var showMoreheight:CGFloat = 0
        if(!self.showMoreButton.isHidden){
            showMoreheight = 36
        }
        let limitingSize: CGSize  = CGSize(width: BubbleViewMaxWidth - 20, height: CGFloat.greatestFiniteMagnitude)
        let textSize: CGSize = self.textLabel.sizeThatFits(limitingSize)
        let rowsHeight = self.optionsView.getExpectedHeight(width: BubbleViewMaxWidth)
//        let rowsHeight = self.optionsView.getExpectedHeight(width: BubbleViewMaxWidth)
        return CGSize(width: BubbleViewMaxWidth, height: rowsHeight  + textSize.height + showMoreheight + 20.0)
    }
    
    @objc fileprivate func showMoreButtonAction(_ sender: AnyObject!) {
        self.showMoreButton.isHidden = true
        showMore = true
        NotificationCenter.default.post(name: Notification.Name(reloadTableNotification), object: nil)
        
    }
}

