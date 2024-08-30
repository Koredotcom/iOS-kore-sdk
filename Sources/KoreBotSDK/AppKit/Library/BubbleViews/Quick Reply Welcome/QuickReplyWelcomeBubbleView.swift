//
//  QuickReplyWelcomeBubbleView.swift
//  KoreBotSDKDemo
//
//  Created by Kartheek Pagidimarri on 7/17/20.
//  Copyright © 2020 Kore. All rights reserved.
//

import UIKit
import KoreBotSDK
#if SWIFT_PACKAGE
import ObjcSupport
#endif
class QuickReplyWelcomeBubbleView: BubbleView {
    static let elementsLimit: Int = 4
    
    public var maskview: UIView!
    var tileBgv: UIView!
    var titleLbl: KREAttributedLabel!
    var tableView: UITableView!
    var cardView: UIView!
    let kMaxTextWidth: CGFloat = BubbleViewMaxWidth - 20.0
    let kMinTextWidth: CGFloat = 00.0
    var collectionView: UICollectionView!
    let customCellIdentifier = "ButtonLinkCell"
    
    var arraySelectedHeader = NSMutableArray() //for header checkbox
    var checkboxIndexPath = [IndexPath]() //for Rows checkbox
    var arrayOfSeletedValues = [String]()
    
    var quickReplyViewHeightConstraint: NSLayoutConstraint!
    var quickRepliesCount: Array<Dictionary<String, AnyObject>> = []
    public var selectBtnIndex: Int?
        
    var titleBgvHeightConstraint: NSLayoutConstraint!
    var collectionVTopConstraint: NSLayoutConstraint!
    
    var arrayOfElements = [QuickRepliesWelcomeData]()
    var arrayOfButtons = [ComponentItemAction]()
    var showMore = false
    var isQuickReplies  = true
    var isReloadBtnLink = true
    
    var quickReplyView: KREQuickSelectView!
    
   // public var optionsAction: ((_ text: String?, _ payload: String?) -> Void)!
   // public var linkAction: ((_ text: String?) -> Void)!
    public var selectBtnState: ((_ Index: Int?) -> Void)!
    override func applyBubbleMask() {
        //nothing to put here
        if(self.maskLayer == nil){
            self.maskLayer = CAShapeLayer()
           // self.tileBgv.layer.mask = self.maskLayer
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
      
        selectBtnIndex = 100
        intializeCardLayout()
        
        self.tileBgv = UIView(frame:.zero)
        self.tileBgv.translatesAutoresizingMaskIntoConstraints = false
        self.tileBgv.layer.rasterizationScale =  UIScreen.main.scale
        self.tileBgv.layer.shouldRasterize = true
        self.tileBgv.layer.cornerRadius = 10.0
        self.tileBgv.layer.borderColor = UIColor.lightGray.cgColor
        self.tileBgv.clipsToBounds = true
        self.tileBgv.layer.borderWidth = 0.0
        self.tileBgv.backgroundColor = .lightGray
        self.cardView.addSubview(self.tileBgv)
        self.tileBgv.backgroundColor = BubbleViewLeftTint
        
        let layout = TagFlowLayout()
        layout.scrollDirection = .vertical
        self.collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.backgroundColor = .clear
        self.collectionView.showsHorizontalScrollIndicator = false
        self.collectionView.showsVerticalScrollIndicator = false
        self.collectionView.bounces = false
        self.collectionView.isScrollEnabled = false
        self.cardView.addSubview(self.collectionView)
    
        if let xib = Bundle.xib(named: "ButtonLinkCell") {
                    self.collectionView.register(xib, forCellWithReuseIdentifier: customCellIdentifier)
                }
        
        self.maskview = UIView(frame:.zero)
        self.maskview.translatesAutoresizingMaskIntoConstraints = false
        self.cardView.addSubview(self.maskview)
        self.maskview.isHidden = true
        self.maskview.backgroundColor = .clear
        
        let views: [String: UIView] = ["tileBgv": tileBgv, "collectionView": collectionView, "maskview": maskview]
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[tileBgv]-10-[collectionView]-5-|", options: [], metrics: nil, views: views))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[tileBgv]", options: [], metrics: nil, views: views))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[maskview]|", options: [], metrics: nil, views: views))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[collectionView]-0-|", options: [], metrics: nil, views: views))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[maskview]-0-|", options: [], metrics: nil, views: views))
        
        self.titleBgvHeightConstraint = NSLayoutConstraint.init(item: self.tileBgv as Any, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 0.0)
        self.cardView.addConstraint(self.titleBgvHeightConstraint)
        self.titleBgvHeightConstraint.isActive = false
        
        self.collectionVTopConstraint = NSLayoutConstraint(item: collectionView as Any, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0.0)
        self.cardView.addConstraint(self.collectionVTopConstraint)
        self.collectionVTopConstraint.isActive = false
        
        
        
        self.titleLbl = KREAttributedLabel(frame: CGRect.zero)
        self.titleLbl.textColor = BubbleViewBotChatTextColor
        self.titleLbl.mentionTextColor = Common.UIColorRGB(0x8ac85a)
        self.titleLbl.hashtagTextColor = Common.UIColorRGB(0x8ac85a)
        self.titleLbl.linkTextColor = Common.UIColorRGB(0x0076FF)
        self.titleLbl.font = UIFont(name: mediumCustomFont, size: 16.0)
        self.titleLbl.numberOfLines = 0
        self.titleLbl.lineBreakMode = NSLineBreakMode.byWordWrapping
        self.titleLbl.isUserInteractionEnabled = true
        self.titleLbl.contentMode = UIView.ContentMode.topLeft
        self.titleLbl.translatesAutoresizingMaskIntoConstraints = false
        self.tileBgv.addSubview(self.titleLbl)
        
        let subView: [String: UIView] = ["titleLbl": titleLbl]
        let metrics: [String: NSNumber] = ["textLabelMaxWidth": NSNumber(value: Float(kMaxTextWidth)), "textLabelMinWidth": NSNumber(value: Float(kMinTextWidth))]
        self.tileBgv.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-16-[titleLbl]-16-|", options: [], metrics: metrics, views: subView))
        self.tileBgv.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[titleLbl(>=textLabelMinWidth,<=textLabelMaxWidth)]-16-|", options: [], metrics: metrics, views: subView))
        
        if isReloadBtnLink {
            print("yeReload")
            isReloadBtnLink = false
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { (_) in
              NotificationCenter.default.post(name: Notification.Name(reloadTableNotification), object: nil)
            }
        }
        setCornerRadiousToTitleView()
    }
    
    func setCornerRadiousToTitleView(){
        let bubbleStyle = brandingShared.bubbleShape
        var radius = 10.0
        let borderWidth = 0.0
        let borderColor = UIColor.clear
        if #available(iOS 11.0, *) {
            if bubbleStyle == "balloon"{
                self.tileBgv.roundCorners([.layerMaxXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMaxYCorner], radius: radius, borderColor: borderColor, borderWidth: borderWidth)
            }else if bubbleStyle == "rounded" || bubbleStyle == "circle"{
                radius = 15.0
                self.tileBgv.roundCorners([.layerMaxXMinYCorner, .layerMinXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMaxYCorner], radius: radius, borderColor: borderColor, borderWidth: borderWidth)
            }else if bubbleStyle == "rectangle"{
                radius = 8.0
                self.tileBgv.roundCorners([.layerMaxXMinYCorner, .layerMinXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMaxYCorner], radius: radius, borderColor: borderColor, borderWidth: borderWidth)
            }else if bubbleStyle == "square"{
                self.tileBgv.roundCorners([ .layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner], radius: radius, borderColor: borderColor, borderWidth: borderWidth)
            }else{
                self.tileBgv.roundCorners([ .layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner], radius: 20.0, borderColor: UIColor.lightGray, borderWidth: 0.0)
            }
        }
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
                if ((component.componentDesc) != nil) {
                    let jsonObject: NSDictionary = Utilities.jsonObjectFromString(jsonString: component.componentDesc!) as! NSDictionary
                    
                    let titleStr = jsonObject["text"] as? String
                    let newString = titleStr?.replacingOccurrences(of: ":)", with: "\u{1f642}")
                    
                    if let parsedString = KREUtilities.formatHTMLEscapedString(newString) {
                        var replaceStr = parsedString.replacingOccurrences(of: ":)", with: "😊")
                        replaceStr = replaceStr.replacingOccurrences(of: "&quot;", with: "\"")
                        self.titleLbl.setHTMLString(replaceStr, withWidth: kMaxTextWidth)
                    }else{
                        var replaceStr = newString?.replacingOccurrences(of: ":)", with: "😊")
                        replaceStr = replaceStr?.replacingOccurrences(of: "&quot;", with: "\"")
                        self.titleLbl.text = replaceStr
                    }
                    
                    let jsonDecoder = JSONDecoder()
                    guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject as Any , options: .prettyPrinted),
                          let allItems = try? jsonDecoder.decode(Componentss.self, from: jsonData) else {
                        return
                    }
                    
                    //var quickReplies: Array<Dictionary<String, AnyObject>>
                    if jsonObject["template_type"] as! String == "button"{
                        isQuickReplies = false
                        arrayOfButtons = allItems.buttons ?? []
                    }else{
                        isQuickReplies = true
                        
                        arrayOfElements = allItems.quickReplies ?? []
                    }
                    
                    self.collectionView.collectionViewLayout.invalidateLayout()
                    self.collectionView.reloadData()
                    
                }
               
            }
           
        }
    }
    
    //MARK: View height calculation
    override var intrinsicContentSize : CGSize {
        
        self.titleLbl.textColor = BubbleViewBotChatTextColor
        self.titleLbl.tintColor = BubbleViewBotChatTextColor
        
        let limitingSize: CGSize  = CGSize(width: kMaxTextWidth, height: CGFloat.greatestFiniteMagnitude)
        var textSize: CGSize = self.titleLbl.sizeThatFits(limitingSize)
        if textSize.height < self.titleLbl.font?.pointSize ?? 0.0 {
            textSize.height = self.titleLbl.font?.pointSize ?? 0.0
        }
        if textSize.width == 0.0{
            self.titleBgvHeightConstraint.isActive = true
            self.collectionVTopConstraint.isActive = true
            let collectionviewHeight  = Double(self.collectionView.collectionViewLayout.collectionViewContentSize.height)
            return CGSize(width: 0.0, height: 5 + CGFloat(collectionviewHeight))
        }else{
            self.titleBgvHeightConstraint.isActive = false
            self.collectionVTopConstraint.isActive = false
            let collectionviewHeight  = Double(self.collectionView.collectionViewLayout.collectionViewContentSize.height)
            return CGSize(width: 0.0, height: textSize.height + 47 + CGFloat(collectionviewHeight))
        }
    }
    
}
    
extension QuickReplyWelcomeBubbleView : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    //MARK: collection view delegate methods
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isQuickReplies{
            return arrayOfElements.count
        }else{
            return arrayOfButtons.count
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // swiftlint:disable force_cast
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: customCellIdentifier, for: indexPath) as! ButtonLinkCell
        cell.backgroundColor = .clear
        
        if isQuickReplies{
            let elements = arrayOfElements[indexPath.row]
            cell.textlabel.text = elements.title
        }else{
            let elements = arrayOfButtons[indexPath.row]
            cell.textlabel.text = elements.title
        }
        let bgColor = (brandingShared.buttonActiveBgColor) ?? "#f3f3f5"
        let textColor = (brandingShared.buttonActiveTextColor) ?? "#2881DF"
        cell.bgV.backgroundColor = UIColor.init(hexString: bgColor)
        
        cell.textlabel.font = UIFont(name: mediumCustomFont, size: 12.0)
        cell.textlabel.textAlignment = .center
        cell.textlabel.textColor = UIColor.init(hexString: textColor)
        cell.textlabel.numberOfLines = 2
        cell.imagvWidthConstraint.constant = 0.0
        
        cell.layer.borderColor =  UIColor.init(hexString: bgColor).cgColor
        cell.layer.borderWidth = 1.5
        cell.layer.cornerRadius = 5
        cell.backgroundColor = .clear
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        if isQuickReplies{
            let elements = arrayOfElements[indexPath.row]
            if elements.type == "web_url" || elements.type == "url"{
                    self.linkAction?(elements.url)
            }else{
                self.optionsAction?(elements.title, elements.payload)
                self.maskview.isHidden = false
            }
        }else{
            let elements = arrayOfButtons[indexPath.row]
            if elements.type == "web_url" || elements.type == "url"{
                self.linkAction?(elements.url)
            }else{
                self.optionsAction?(elements.title, elements.payload)
                self.maskview.isHidden = false
            }
        }
        
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var text:String?
        if isQuickReplies{
            let elements = arrayOfElements[indexPath.row]
            text = elements.title
        }else{
            let elements = arrayOfButtons[indexPath.row]
            text = elements.title
        }
        var textWidth = 10
        let size = text?.size(withAttributes:[.font: UIFont(name: mediumCustomFont, size: 12.0) as Any])
        if text != nil {
            textWidth = Int(size!.width)
        }
        return CGSize(width: min(Int(maxContentWidth()) - 10 , textWidth + 28) , height: 40)
    }
    
    func maxContentWidth() -> CGFloat {
        if let collectionViewLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let sectionInset: UIEdgeInsets = collectionViewLayout.sectionInset
            return max(frame.size.width - sectionInset.left - sectionInset.right, 1.0)
        }
        return 1.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }
    
}


extension UIView {
    @available(iOS 11.0, *)
    func roundCorners(_ corners: CACornerMask, radius: CGFloat, borderColor: UIColor, borderWidth: CGFloat) {
      self.layer.maskedCorners = corners
      self.layer.cornerRadius = radius
      self.layer.borderWidth = borderWidth
      self.layer.borderColor = borderColor.cgColor
    }

}
