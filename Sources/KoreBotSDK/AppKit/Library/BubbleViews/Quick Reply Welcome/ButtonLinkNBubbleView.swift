//
//  ButtonLinkNBubbleView.swift
//  KoreBotSDKFrameWork
//
//  Created by Kartheek.Pagidimarri on 16/08/22.
//  Copyright © 2022 Kartheek.Pagidimarri. All rights reserved.
//

import UIKit
#if SWIFT_PACKAGE
import ObjcSupport
#endif
class ButtonLinkNBubbleView: BubbleView {
    let bundle = Bundle.sdkModule
    var tileBgv: UIView!
    public var maskview: UIView!
    var titleLbl: KREAttributedLabel!
    var tableView: UITableView!
    var cardView: UIView!
    let kMaxTextWidth: CGFloat = BubbleViewMaxWidth - 20.0
    let kMinTextWidth: CGFloat = 20.0
    fileprivate let listCellIdentifier = "ButtonLinkNCell"
    var arrayOfElements = [ComponentElements]()
    
    var textLabelBottomConstraint: NSLayoutConstraint!
    var textLabelTopConstraint: NSLayoutConstraint!
    var textLabelHeightConstraint: NSLayoutConstraint!
    var templateLanguage:String?
    var tileBgvHeightConstraint: NSLayoutConstraint!

    
    var checkboxIndexPath = [IndexPath]()
    var arrayOfSeletedValues = [String]()
    var arrayOfSeletedTitles = [String]()
    
    override func prepareForReuse() {
        checkboxIndexPath = [IndexPath]()
         arrayOfSeletedValues = [String]()
        arrayOfSeletedTitles = [String]()
    }
    
    override func applyBubbleMask() {
        //nothing to put here
        if(self.maskLayer == nil){
            self.maskLayer = CAShapeLayer()
        }
        self.maskLayer.path = self.createBezierPath().cgPath
        self.maskLayer.position = CGPoint(x:0, y:0)
    }
    
    override var tailPosition: BubbleMaskTailPosition! {
        didSet {
            self.backgroundColor = .clear
        }
    }
    
    override func initialize() {
        super.initialize()
        intializeCardLayout()
        
        self.tileBgv = UIView(frame:.zero)
        self.tileBgv.translatesAutoresizingMaskIntoConstraints = false
        self.tileBgv.layer.rasterizationScale =  UIScreen.main.scale
        self.tileBgv.layer.shouldRasterize = true
        self.tileBgv.layer.cornerRadius = 10.0
        self.tileBgv.layer.borderColor = UIColor.lightGray.cgColor
        self.tileBgv.clipsToBounds = true
        self.tileBgv.layer.borderWidth = 0.0
        self.cardView.addSubview(self.tileBgv)
        self.tileBgv.backgroundColor = BubbleViewLeftTint
        if #available(iOS 11.0, *) {
            self.tileBgv.roundCorners([ .layerMaxXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMaxYCorner], radius: 10.0, borderColor: UIColor.lightGray, borderWidth: 0.0)
        } else {
            // Fallback on earlier versions
        }
        
        self.tableView = UITableView(frame: CGRect.zero,style:.plain)
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.backgroundColor = .clear
        self.tableView.showsHorizontalScrollIndicator = false
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.bounces = false
        self.tableView.separatorStyle = .none
        self.cardView.addSubview(self.tableView)
        self.tableView.isScrollEnabled = false
        
        self.tableView.register(UINib(nibName: listCellIdentifier, bundle: bundle), forCellReuseIdentifier: listCellIdentifier)
        
        self.maskview = UIView(frame:.zero)
        self.maskview.translatesAutoresizingMaskIntoConstraints = false
        self.cardView.addSubview(self.maskview)
        self.maskview.isHidden = true
        maskview.backgroundColor = .clear //UIColor(white: 1, alpha: 0.5)
        

        let views: [String: UIView] = ["tileBgv": tileBgv, "tableView": tableView, "maskview": maskview]
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[tileBgv]-(-5)-[tableView]-0-|", options: [], metrics: nil, views: views))
         self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[maskview]|", options: [], metrics: nil, views: views))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[tileBgv]-0-|", options: [], metrics: nil, views: views))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[tableView]-0-|", options: [], metrics: nil, views: views))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[maskview]-0-|", options: [], metrics: nil, views: views))
        
        
        tileBgvHeightConstraint = NSLayoutConstraint.init(item: self.tileBgv as Any, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 0.0)
        self.cardView.addConstraint(tileBgvHeightConstraint)
        tileBgvHeightConstraint.isActive = false
        
        self.titleLbl = KREAttributedLabel(frame: CGRect.zero)
        self.titleLbl.textColor = BubbleViewBotChatTextColor
        self.titleLbl.font = UIFont(name: mediumCustomFont, size: 16.0)
        self.titleLbl.numberOfLines = 0
        self.titleLbl.lineBreakMode = NSLineBreakMode.byWordWrapping
        self.titleLbl.isUserInteractionEnabled = true
        self.titleLbl.contentMode = UIView.ContentMode.topLeft
        self.titleLbl.translatesAutoresizingMaskIntoConstraints = false
        self.tileBgv.addSubview(self.titleLbl)
        self.titleLbl.adjustsFontSizeToFitWidth = true
        self.titleLbl.backgroundColor = .clear
        self.titleLbl.layer.cornerRadius = 6.0
        self.titleLbl.clipsToBounds = true
        self.titleLbl.sizeToFit()
        
        let subView: [String: UIView] = ["titleLbl": titleLbl]
        self.tileBgv.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-16-[titleLbl]-16-|", options: [], metrics: nil, views: subView))
        self.tileBgv.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[titleLbl]-16-|", options: [], metrics: nil, views: subView))
        
        self.textLabelBottomConstraint = NSLayoutConstraint.init(item: self.tileBgv as Any, attribute: .bottom, relatedBy: .equal, toItem: self.titleLbl, attribute: .bottom, multiplier: 1.0, constant: 0.0)
        self.tileBgv.addConstraint(self.textLabelBottomConstraint)
        
        self.textLabelTopConstraint = NSLayoutConstraint.init(item: self.tileBgv as Any, attribute: .top, relatedBy: .equal, toItem: self.titleLbl, attribute: .top, multiplier: 1.0, constant: 0.0)
        self.tileBgv.addConstraint(self.textLabelTopConstraint)
        
        self.textLabelHeightConstraint = NSLayoutConstraint.init(item: self.tileBgv as Any, attribute: .height, relatedBy: .equal, toItem: self.titleLbl, attribute: .height, multiplier: 1.0, constant: 0.0)
        self.tileBgv.addConstraint(self.textLabelHeightConstraint)
        self.textLabelHeightConstraint.isActive = false
        
        //self.tileBgv.bringSubviewToFront(self.tableView)
         self.cardView.bringSubviewToFront(tileBgv)
         self.tileBgv.sendSubviewToBack(tableView)

    }
    
    func intializeCardLayout(){
        self.cardView = UIView(frame:.zero)
        self.cardView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.cardView)
        cardView.backgroundColor =  UIColor.clear
        let cardViews: [String: UIView] = ["cardView": cardView]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[cardView]-0-|", options: [], metrics: nil, views: cardViews))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[cardView]-0-|", options: [], metrics: nil, views: cardViews))
        
    }
    
    // MARK: populate components
    override func populateComponents() {
        if (components.count > 0) {
            let component: KREComponent = components.firstObject as! KREComponent
            if (component.componentDesc != nil) {
                let jsonString = component.componentDesc
                let jsonObject: NSDictionary = Utilities.jsonObjectFromString(jsonString: jsonString!) as! NSDictionary
                
                let jsonDecoder = JSONDecoder()
                guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject as Any , options: .prettyPrinted),
                    let allItems = try? jsonDecoder.decode(Componentss.self, from: jsonData) else {
                                                return
                                        }
                arrayOfElements = allItems.elements ?? []
                if let text = allItems.text{
                    self.titleLbl.setHTMLString(text, withWidth: kMaxTextWidth)
                }else{
                    self.titleLbl.text = ""
                }
                tableView.reloadData()
            }
        }
    }
    
    //MARK: View height calculation
    override var intrinsicContentSize : CGSize {
        
        self.titleLbl.textColor = BubbleViewBotChatTextColor
        self.titleLbl.mentionTextColor = BubbleViewBotChatTextColor
        self.titleLbl.hashtagTextColor = BubbleViewBotChatTextColor
        self.titleLbl.linkTextColor = BubbleViewBotChatTextColor
        self.titleLbl.tintColor = BubbleViewBotChatTextColor
        
        let limitingSize: CGSize  = CGSize(width: kMaxTextWidth, height: CGFloat.greatestFiniteMagnitude)
        var textSize: CGSize = self.titleLbl.sizeThatFits(limitingSize)
        if textSize.height < self.titleLbl.font?.pointSize ?? 0.0 {
            textSize.height = self.titleLbl.font?.pointSize ?? 0.0
        }
        
        var cellHeight : CGFloat = 0.0
        
        let rows = arrayOfElements.count
        var finalHeight: CGFloat = 0.0
        var verticalSpace = 32
        var textHeight = textSize.height
        
        self.textLabelTopConstraint.constant = 16
        self.textLabelBottomConstraint.constant = 16
        
        
        self.textLabelHeightConstraint.isActive = false
        
        tileBgvHeightConstraint.isActive = false
        tileBgvHeightConstraint.constant = 0.0
        tileBgv.isHidden = false
        if textSize.width == 0.0{
             verticalSpace = 0
            self.textLabelTopConstraint.constant = 0
            self.textLabelBottomConstraint.constant = 0
            self.textLabelHeightConstraint.constant = 0
            textHeight = 0
            self.textLabelHeightConstraint.isActive = true
            
            tileBgvHeightConstraint.isActive = true
            tileBgvHeightConstraint.constant = 5.0
            tileBgv.isHidden = true
        }
        
        for _ in 0..<rows {
            cellHeight = 52
            finalHeight += cellHeight
        }
        return CGSize(width: 0.0, height: textHeight + CGFloat(verticalSpace) + finalHeight)
    }
}


extension ButtonLinkNBubbleView: UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 52
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 52
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return arrayOfElements.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : ButtonLinkNCell = tableView.dequeueReusableCell(withIdentifier: listCellIdentifier) as! ButtonLinkNCell
        cell.selectionStyle = .none
        let elements = arrayOfElements[indexPath.row]
        cell.titleBtn.setTitle(elements.title, for: .normal)
        cell.titleBtn.isUserInteractionEnabled = false
        
            cell.titleBtn.semanticContentAttribute = .forceLeftToRight
            cell.titleBtn.titleEdgeInsets = UIEdgeInsets(top: 2, left: 15, bottom: 0, right: 0)
            if let samePageNavigation = elements.isSamePageNavigation, samePageNavigation{
              cell.titleBtn.setImage(UIImage.init(named: "deeplinkE", in: bundle, compatibleWith: nil), for: .normal)
            }else{
              cell.titleBtn.setImage(UIImage.init(named: "external_linkE", in: bundle, compatibleWith: nil), for: .normal)
             }
      return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let elements = arrayOfElements[indexPath.row]
        if let isSamePageNavigation = elements.isSamePageNavigation, isSamePageNavigation == true{
            //ReactNativeEventMsg = ["event_code": "DEEPLINK_ROUTER", "event_message": "Deeplink navigation", "path": "\(elements.elementUrl ?? "")"]
            NotificationCenter.default.post(name: Notification.Name(deepLinkNotification), object: elements.elementUrl ?? "")
        }else{
            if elements.elementType == "web_url" || elements.elementType == "url"{
                self.linkAction?(elements.elementUrl)
            }else{
                if let title = elements.title{
                    self.optionsAction?(title, elements.value ?? title)
                }
            }
        }
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
}
