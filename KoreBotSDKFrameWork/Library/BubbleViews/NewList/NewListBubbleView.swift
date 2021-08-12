//
//  NewListBubbleView.swift
//  KoreBotSDKDemo
//
//  Created by MatrixStream_01 on 11/05/20.
//  Copyright © 2020 Kore. All rights reserved.
//

import UIKit
import KoreBotSDK
class NewListBubbleView: BubbleView {
    static let elementsLimit: Int = 4
    
    var tileBgv: UIView!
    public var maskview: UIView!
    var titleLbl: UILabel!
    var tableView: UITableView!
    var cardView: UIView!
    let kMaxTextWidth: CGFloat = BubbleViewMaxWidth - 20.0
    let kMinTextWidth: CGFloat = 20.0
    fileprivate let listCellIdentifier = "NewListTableViewCell"
    var rowsDataLimit = 4
    var isShowMore = false
    
    let yourAttributes : [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.font : UIFont(name: "Gilroy-Bold", size: 15.0) as Any,
        NSAttributedString.Key.foregroundColor : themeColor,
        NSAttributedString.Key.underlineStyle : NSUnderlineStyle.single.rawValue]
 
    var arrayOfComponents = [ComponentElements]()
    var arrayOfButtons = [ComponentItemAction]()
    var maskViewBottomConstraint: NSLayoutConstraint!
    
    var showMore = false
    public var optionsAction: ((_ text: String?, _ payload: String?) -> Void)!
    public var linkAction: ((_ text: String?) -> Void)!
    override func applyBubbleMask() {
        //nothing to put here
        if(self.maskLayer == nil){
            self.maskLayer = CAShapeLayer()
            //self.tileBgv.layer.mask = self.maskLayer
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
        self.tileBgv.layer.borderWidth = 1.0
        self.cardView.addSubview(self.tileBgv)
        self.tileBgv.backgroundColor = BubbleViewLeftTint
        if #available(iOS 11.0, *) {
            self.tileBgv.roundCorners([ .layerMinXMaxYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner], radius: 15.0, borderColor: UIColor.lightGray, borderWidth: 1.5)
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
        self.tableView.register(UINib(nibName: listCellIdentifier, bundle: frameworkBundle), forCellReuseIdentifier: listCellIdentifier)
        
        self.maskview = UIView(frame:.zero)
        self.maskview.translatesAutoresizingMaskIntoConstraints = false
        self.cardView.addSubview(self.maskview)
        self.maskview.isHidden = true
        maskview.backgroundColor = UIColor(white: 1, alpha: 0.5)

        let views: [String: UIView] = ["tileBgv": tileBgv, "tableView": tableView, "maskview": maskview]
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[tileBgv]-5-[tableView]-0-|", options: [], metrics: nil, views: views))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[maskview]", options: [], metrics: nil, views: views))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[tileBgv]-0-|", options: [], metrics: nil, views: views))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[tableView]-0-|", options: [], metrics: nil, views: views))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[maskview]-0-|", options: [], metrics: nil, views: views))
        
        self.maskViewBottomConstraint = NSLayoutConstraint.init(item: self.cardView as Any, attribute: .bottom, relatedBy: .equal, toItem: self.maskview, attribute: .bottom, multiplier: 1.0, constant: 0.0)
        self.cardView.addConstraint(self.maskViewBottomConstraint)
        self.maskViewBottomConstraint.isActive = true

        self.titleLbl = UILabel(frame: CGRect.zero)
        self.titleLbl.textColor = BubbleViewBotChatTextColor
        self.titleLbl.font = UIFont(name: "Gilroy-Medium", size: 16.0)
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
        self.tileBgv.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[titleLbl(>=31)]-10-|", options: [], metrics: nil, views: subView))
        self.tileBgv.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[titleLbl]-10-|", options: [], metrics: nil, views: subView))
        Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { (_) in
              // TODO: - whatever you want
           // NotificationCenter.default.post(name: Notification.Name(reloadTableNotification), object: nil)
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
        
        if selectedTheme == "Theme 1"{
            self.tileBgv.layer.borderWidth = 0.0
        }else{
            self.tileBgv.layer.borderWidth = 0.0
        }
        
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
                arrayOfComponents = allItems.elements ?? []
                arrayOfButtons = allItems.buttons ?? []
                self.titleLbl.text = allItems.text ?? ""
                self.rowsDataLimit = (allItems.moreCount != nil ? allItems.moreCount : arrayOfComponents.count)!
                isShowMore = (allItems.seeMore != nil ? allItems.seeMore : false)!
                self.tableView.reloadData()
            }
        }
    }
    
    //MARK: View height calculation
    override var intrinsicContentSize : CGSize {
        
        let limitingSize: CGSize  = CGSize(width: kMaxTextWidth, height: CGFloat.greatestFiniteMagnitude)
        var textSize: CGSize = self.titleLbl.sizeThatFits(limitingSize)
        if textSize.height < self.titleLbl.font.pointSize {
            textSize.height = self.titleLbl.font.pointSize
        }
        
        var cellHeight : CGFloat = 0.0
        var moreButtonHeight : CGFloat = 30.0
        let rows = arrayOfComponents.count > rowsDataLimit ? rowsDataLimit : arrayOfComponents.count
        var finalHeight: CGFloat = 0.0
        for i in 0..<rows {
            let row = tableView.dequeueReusableCell(withIdentifier: listCellIdentifier, for: IndexPath(row: i, section: 0))as! NewListTableViewCell
                    cellHeight = row.bounds.height
                    finalHeight += cellHeight
            }
        
        moreButtonHeight =  arrayOfComponents.count > rowsDataLimit ? 35.0 : 0.0
        if moreButtonHeight == 0.0 {
            self.maskViewBottomConstraint.constant = 0.0
        }else{
            maskview.isHidden = true
            self.maskViewBottomConstraint.constant = 35.0
        }
        return CGSize(width: 0.0, height: textSize.height+45+finalHeight+moreButtonHeight)
    }
    
    @objc fileprivate func showMoreButtonAction(_ sender: AnyObject!) {
        if (isShowMore) {
            let component: KREComponent = components.firstObject as! KREComponent
            if (component.componentDesc != nil) {
                let jsonString = component.componentDesc
                NotificationCenter.default.post(name: Notification.Name(showListViewTemplateNotification), object: jsonString)
            }
        }
    }
}

extension NewListBubbleView: UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return arrayOfComponents.count > rowsDataLimit ? rowsDataLimit : arrayOfComponents.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : NewListTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: listCellIdentifier) as! NewListTableViewCell
        cell.backgroundColor = UIColor.clear
        cell.selectionStyle = .none
        cell.bgView.backgroundColor =  UIColor.init(hexString: (brandingShared.brandingInfoModel?.widgetBodyColor)!)//bubbleViewBotChatButtonBgColor
        cell.titleLabel.textColor = .black //bubbleViewBotChatButtonTextColor
        cell.subTitleLabel.textColor = bubbleViewBotChatButtonInactiveTextColor
        cell.priceLbl.textColor = .black //bubbleViewBotChatButtonTextColor
        
        let elements = arrayOfComponents[indexPath.row]
        if elements.imageURL == nil{
            cell.imageViewWidthConstraint.constant = 0.0
        }else{
            cell.imageViewWidthConstraint.constant = 50.0
            let url = URL(string: elements.imageURL!)
            cell.imgView.setImageWith(url!, placeholderImage: UIImage(named: "placeholder_image"))
        }
        cell.titleLabel.numberOfLines = 1
        cell.subTitleLabel.numberOfLines = 1
        cell.priceLbl.numberOfLines = 1
        cell.titleLabel.text = elements.title
        cell.subTitleLabel.text = elements.subtitle
        cell.priceLbl.text = elements.value
        if selectedTheme == "Theme 1"{
            cell.bgView.layer.borderWidth = 0.0
        }else{
            cell.bgView.layer.borderWidth = 1.5
        }
        cell.valueLabelWidthConstraint.constant = 85
        if elements.subtitle == nil{
            cell.priceLbl.text = ""
            cell.subTitleLabel.text = elements.value
            cell.valueLabelWidthConstraint.constant = 0
        }else if elements.value == nil{
            cell.valueLabelWidthConstraint.constant = 0
        }
        return cell
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let elements = arrayOfComponents[indexPath.row]
        //if elements.action?.type != nil {
            if elements.action?.type == "postback"{
                maskview.isHidden = false
                let payload = elements.action?.payload == "" || elements.action?.payload == nil ? elements.action?.title : elements.action?.payload
                self.optionsAction(elements.action?.title, payload)
            }else{
                if elements.action?.fallback_url != nil {
                    self.linkAction(elements.action?.fallback_url)
                } else if elements.action?.url != nil {
                    self.linkAction(elements.action?.url)
                }else{
                    if elements.action?.payload != nil{
                        maskview.isHidden = false
                    let payload = elements.action?.payload == "" || elements.action?.payload == nil ? elements.action?.title : elements.action?.payload
                        self.optionsAction(elements.action?.title, payload)
                    }
                   
                }
            }
       // }
       
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        
        if arrayOfComponents.count > rowsDataLimit {
            let showMoreButton = UIButton(frame: CGRect.zero)
            showMoreButton.backgroundColor = .clear
            showMoreButton.translatesAutoresizingMaskIntoConstraints = false
            showMoreButton.clipsToBounds = true
            showMoreButton.layer.cornerRadius = 5
            showMoreButton.setTitleColor(themeColor, for: .normal)
            showMoreButton.setTitleColor(Common.UIColorRGB(0x999999), for: .disabled)
            showMoreButton.titleLabel?.font = UIFont(name: "Gilroy-Bold", size: 14.0)!
            view.addSubview(showMoreButton)
            showMoreButton.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.center
            showMoreButton.addTarget(self, action: #selector(self.showMoreButtonAction(_:)), for: .touchUpInside)
             var btnTitle: String?
            if self.isShowMore{
                if arrayOfButtons.count>0{
                  btnTitle = arrayOfButtons[0].title!
                }else{
                     btnTitle = "Show More"
                }
            }
            showMoreButton.setTitle(btnTitle ?? "See More", for: .normal)
            showMoreButton.layer.borderWidth = 1
            showMoreButton.layer.borderColor = themeColor.cgColor
          
            
            let views: [String: UIView] = ["showMoreButton": showMoreButton]
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-5-[showMoreButton(30)]-0-|", options:[], metrics:nil, views:views))
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[showMoreButton(100)]", options:[], metrics:nil, views:views))
        }
        return view
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return self.isShowMore ? 35 : 0
    }
    
}
class DictionaryDecoder {
    private let decoder = JSONDecoder()
    var dateDecodingStrategy: JSONDecoder.DateDecodingStrategy {
        set { decoder.dateDecodingStrategy = newValue }
        get { return decoder.dateDecodingStrategy }
        
    }
    var dataDecodingStrategy: JSONDecoder.DataDecodingStrategy {
        set { decoder.dataDecodingStrategy = newValue }
        get { return decoder.dataDecodingStrategy }
        
    }
    var nonConformingFloatDecodingStrategy: JSONDecoder.NonConformingFloatDecodingStrategy {
        set { decoder.nonConformingFloatDecodingStrategy = newValue }
        get { return decoder.nonConformingFloatDecodingStrategy }
        
    }
    var keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy {
        set { decoder.keyDecodingStrategy = newValue }
        get { return decoder.keyDecodingStrategy }
        
    }
    func decode<T>(_ type: T.Type, from dictionary: [String: Any]) throws -> T where T : Decodable {
        let data = try JSONSerialization.data(withJSONObject: dictionary, options: [])
        return try decoder.decode(type, from: data)
    }
}
