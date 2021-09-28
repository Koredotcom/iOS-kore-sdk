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
    let kMaxTextWidth: CGFloat = BubbleViewMaxWidth - 32.0
    let kMinTextWidth: CGFloat = 20.0
    fileprivate let listCellIdentifier = "NewListTableViewCell"
    fileprivate let listTransACellIdentifier = "NewListTrannsActionCell"
    var rowsDataLimit = 4
    var isShowMore = false
    var isBoxShadow = false
    var dateCompareStr:String?
    var duplicateDates = [Bool]()
    
    let yourAttributes : [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.font : UIFont(name: "Gilroy-Regular", size: 12.0) as Any,
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
            self.tileBgv.roundCorners([ .layerMinXMaxYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner], radius: 10.0, borderColor: UIColor.lightGray, borderWidth: 1.5)
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
         self.tableView.register(UINib(nibName: listTransACellIdentifier, bundle: frameworkBundle), forCellReuseIdentifier: listTransACellIdentifier)
        
        
        self.maskview = UIView(frame:.zero)
        self.maskview.translatesAutoresizingMaskIntoConstraints = false
        self.cardView.addSubview(self.maskview)
        self.maskview.isHidden = true
        maskview.backgroundColor = UIColor(white: 1, alpha: 0.5)
        

        let views: [String: UIView] = ["tileBgv": tileBgv, "tableView": tableView, "maskview": maskview]
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[tileBgv]-10-[tableView]-0-|", options: [], metrics: nil, views: views))
         self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[maskview]", options: [], metrics: nil, views: views))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[tileBgv]-0-|", options: [], metrics: nil, views: views))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[tableView]-0-|", options: [], metrics: nil, views: views))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[maskview]-0-|", options: [], metrics: nil, views: views))
        
        self.maskViewBottomConstraint = NSLayoutConstraint.init(item: self.cardView as Any, attribute: .bottom, relatedBy: .equal, toItem: self.maskview, attribute: .bottom, multiplier: 1.0, constant: 0.0)
        self.cardView.addConstraint(self.maskViewBottomConstraint)
        self.maskViewBottomConstraint.isActive = true

        self.titleLbl = UILabel(frame: CGRect.zero)
        self.titleLbl.textColor = BubbleViewBotChatTextColor
        self.titleLbl.font = UIFont(name: "Gilroy-Regular", size: 16.0)
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
        self.tileBgv.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-16-[titleLbl(>=21)]-16-|", options: [], metrics: nil, views: subView))
        self.tileBgv.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[titleLbl]-16-|", options: [], metrics: nil, views: subView))
//        Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { (_) in
//              // TODO: - whatever you want
//           // NotificationCenter.default.post(name: Notification.Name(reloadTableNotification), object: nil)
//           }
         
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
                duplicateDates = []
                arrayOfComponents = allItems.elements ?? []
                arrayOfButtons = allItems.buttons ?? []
                self.titleLbl.text = allItems.text ?? ""
                self.rowsDataLimit = (allItems.moreCount != nil ? allItems.moreCount : arrayOfComponents.count)!
                isShowMore = (allItems.seeMore != nil ? allItems.seeMore : false)!
                isBoxShadow = (allItems.boxShadow != nil ? allItems.boxShadow : false)!
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
        
        var verticalSpace = 45
        if isBoxShadow{
            
            for i in 0..<rows {
                let elements = arrayOfComponents[i]
                if i == 0 {
                    dateCompareStr = elements.subtitle
                    duplicateDates.append(false)
                    cellHeight = 75
                }else{
//                    if i == 1 || i == 2{
//                        duplicateDates.append(true)
//                        cellHeight = 50
//                    }else{
                        if dateCompareStr == elements.subtitle{
                            duplicateDates.append(true)
                            cellHeight = 50
                        }else{
                            dateCompareStr = elements.subtitle
                            duplicateDates.append(false)
                            cellHeight = 75
//                        }
                    }
                    
                }
                finalHeight += cellHeight
            }
        }else{
            for i in 0..<rows {
                let elements = arrayOfComponents[i]
                cellHeight = 74
                if elements.subtitle == nil{

                }
                finalHeight += cellHeight
            }
        }
        
        moreButtonHeight =  arrayOfComponents.count > rowsDataLimit ? 50.0 : 0.0
        if moreButtonHeight == 0.0 {
            self.maskViewBottomConstraint.constant = 0.0
        }else{
            maskview.isHidden = true
            self.maskViewBottomConstraint.constant = 50.0
            verticalSpace = 50
        }
        return CGSize(width: 0.0, height: textSize.height+CGFloat(verticalSpace)+finalHeight+moreButtonHeight)
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
        if isBoxShadow{
            if duplicateDates.count > 0 {
                if duplicateDates[indexPath.row] == true{
                               return 50
                           }
                           return 75
            }
            return 75
        }
        return 74
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isBoxShadow{
            if duplicateDates.count > 0 {
                if duplicateDates[indexPath.row] == true{
                               return 50
                           }
                           return 75
            }
            return 75
        }
        return 74
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return arrayOfComponents.count > rowsDataLimit ? rowsDataLimit : arrayOfComponents.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isBoxShadow{
            let cell : NewListTrannsActionCell = tableView.dequeueReusableCell(withIdentifier: listTransACellIdentifier) as! NewListTrannsActionCell
            cell.backgroundColor = UIColor.clear
            cell.selectionStyle = .none
            
            let elements = arrayOfComponents[indexPath.row]
            cell.titleLabl.numberOfLines = 2
            cell.titleLabl.text = elements.title
            cell.dateLbl.text = elements.subtitle
            cell.priceLbl.text = elements.value
            cell.dateHeightConstraint.constant = 17.0
            cell.dateTopConstaint.constant = 16.0
//            if indexPath.row == 0 {
//                dateCompareStr = elements.subtitle
//            }else{
//                if dateCompareStr == elements.subtitle{
//                    cell.dateHeightConstraint.constant = 0.0
//                    cell.dateTopConstaint.constant = 8.0
//                }else{
//                    dateCompareStr = elements.subtitle
//                }
//            }
            
            if duplicateDates[indexPath.row] == true{
                cell.dateHeightConstraint.constant = 0.0
                cell.dateTopConstaint.constant = 10.0
            }
            
            let dateFormatterUK = DateFormatter()
            dateFormatterUK.dateFormat = "MM/dd/yy"
            let stringDate = elements.subtitle ?? "date"
            if let date = dateFormatterUK.date(from: stringDate) {
                //               if let sentOn = date as Date? {
                //                    let dateFormatter = DateFormatter()
                //                    dateFormatter.dateFormat = "d MMMM YYYY"
                //                    cell.dateLbl.text = dateFormatter.string(from: sentOn)
                //                }
                
                
                // Use this to add st, nd, th, to the day
                let numberFormatter = NumberFormatter()
                numberFormatter.numberStyle = .ordinal
                numberFormatter.locale = Locale.current
                
                //Set other sections as preferred
                let monthFormatter = DateFormatter()
                monthFormatter.dateFormat = "MMMM"
                
                // Works well for adding suffix
                let dayFormatter = DateFormatter()
                dayFormatter.dateFormat = "dd"
                
                // Works well for adding suffix
                let yearFormatter = DateFormatter()
                yearFormatter.dateFormat = "YYYY"
                
                let dayString = dayFormatter.string(from: date)
                let monthString = monthFormatter.string(from: date)
                let yearString = yearFormatter.string(from: date)
                
                // Add the suffix to the day
                let dayNumber = NSNumber(value: Int(dayString)!)
                let day = numberFormatter.string(from: dayNumber)!
                
                cell.dateLbl.text = "\(day) \(monthString) \(yearString)"
                
            }
            
            return cell
        }else{
             let cell : NewListTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: listCellIdentifier) as! NewListTableViewCell
                    cell.backgroundColor = UIColor.clear
                    cell.selectionStyle = .none
                    cell.bgView.backgroundColor =  UIColor.init(hexString: (brandingShared.brandingInfoModel?.widgetBodyColor)!)//bubbleViewBotChatButtonBgColor
                    
                    let elements = arrayOfComponents[indexPath.row]
                    if elements.imageURL == nil{
                        cell.imageViewWidthConstraint.constant = 0.0
                        cell.imageVLeadingConstraint.constant = 5.0
                    }else{
                        cell.imageViewWidthConstraint.constant = 50.0
                        cell.imageVLeadingConstraint.constant = 10.0
                        let url = URL(string: elements.imageURL!)
                        cell.imgView.af.setImage(withURL: url!, placeholderImage: UIImage(named: "placeholder_image"))
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
                    cell.titlaLblTopConstriant.constant = 16.0
                    cell.priceLblTopConstraint.constant = 16.0
                    cell.subTitleHeightConstraint.constant = 16.0
                    cell.subTitle2HeightConstraint.constant = 16.0
                    if elements.subtitle == nil{
                        cell.titlaLblTopConstriant.constant = 18.0
                        cell.priceLblTopConstraint.constant = 22.0
                        cell.subTitleHeightConstraint.constant = 0.0
                        cell.subTitle2HeightConstraint.constant = 0.0
                        cell.subTitleLabel2.text = ""
                    }else{
                       let str = elements.subtitle! //"XX"
                        //print("full str:  \(str)")
                        if str.count >= 3{
                        cell.subTitleLabel.text = "\(str.prefix(3))"
                        //print("firstCharacter str:  \(str.prefix(3))")
                        
                        let startIndex = str.index(str.startIndex, offsetBy: 3)
                        //print("secondCharacter str:  \((str[startIndex...]))")
                        cell.subTitleLabel2.text = (String(str[startIndex...]))
                        }else{
                            cell.subTitleLabel.text = str
                            cell.subTitleLabel2.text = ""
                        }
                    }
                    
                    if elements.value == nil{
                        cell.valueLabelWidthConstraint.constant = 0
                    }
            
            cell.tagBtn.isHidden = true
            if elements.tag != nil {
                cell.tagBtn.isHidden = false
                cell.tagBtn.setTitle("  \(elements.tag!)  ", for: .normal)
                cell.tagBtn.backgroundColor = BubbleViewLeftTint
                cell.tagBtn.setTitleColor(themeColor, for: .normal)
                cell.tagBtn.layer.cornerRadius = 5.0
            }
                    
                    
            //       let moreButtonHeight =  arrayOfComponents.count > rowsDataLimit ? 35.0 : 0.0
            //        if moreButtonHeight == 0.0{
            //            cell.bgView.layer.masksToBounds = false
            //            cell.underlineLbl.isHidden = true
            //        }else{
            //            cell.bgView.layer.masksToBounds = true
            //            cell.underlineLbl.isHidden = false
            //        }
                    
                    return cell
        }
       
        
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
                        self.optionsAction(elements.title, payload)
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
            showMoreButton.titleLabel?.font = UIFont(name: "Gilroy-Semibold", size: 14.0)!
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
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-15-[showMoreButton(35)]", options:[], metrics:nil, views:views))
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[showMoreButton(90)]", options:[], metrics:nil, views:views))
        }
        return view
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return self.isShowMore ? 50 : 0
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
