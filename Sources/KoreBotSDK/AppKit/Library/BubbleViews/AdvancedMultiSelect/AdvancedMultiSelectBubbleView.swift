//
//  AdvancedMultiSelectBubbleView.swift
//  KoreBotSDKDemo
//
//  Created by Kartheek Pagidimarri on 11/10/23.
//  Copyright © 2023 Kore. All rights reserved.
//

import UIKit

class AdvancedMultiSelectBubbleView: BubbleView {
    let bundle = Bundle.sdkModule
    var tileBgv: UIView!
    var titleLbl: UILabel!
    var tableView: UITableView!
    var cardView: UIView!
    let kMaxTextWidth: CGFloat = BubbleViewMaxWidth - 20.0
    let kMinTextWidth: CGFloat = 20.0
    fileprivate let multiSelectCellIdentifier = "AdvancedMultiSelectCell"
    public var maskview: UIView!
    var sectionLimit = 1
    var isShowMoreIsHidden = false
    var checkboxIndexPath = [IndexPath]() //for Rows checkbox
    var arrayOfSeletedValues = [String]()
    var arrayOfSeletedTitles = [String]()
    var arrayOfHeaderCheck = [String]()
    var isSliderView = false
    var doneButton: UIButton!
    let yourAttributes : [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.font : UIFont(name: boldCustomFont, size: 12.0) as Any,
        NSAttributedString.Key.foregroundColor : UIColor.white]
    
    var arrayOfElements = [ComponentElements]()
    var arrayOfButtons = [ComponentItemAction]()
    var showMore = false
    //public var optionsAction: ((_ text: String?, _ payload: String?) -> Void)!
    //public var linkAction: ((_ text: String?) -> Void)!
    var messageId = ""
    var componentDescDic:[String:Any] = [:]
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
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override func initialize() {
        super.initialize()
       // UserDefaults.standard.set(false, forKey: "SliderKey")
        intializeCardLayout()
        self.tileBgv = UIView(frame:.zero)
        self.tileBgv.translatesAutoresizingMaskIntoConstraints = false
        self.tileBgv.layer.rasterizationScale =  UIScreen.main.scale
        self.tileBgv.layer.shouldRasterize = true
        self.tileBgv.layer.cornerRadius = 10.0
        self.cardView.addSubview(self.tileBgv)
        self.tileBgv.backgroundColor = BubbleViewLeftTint
        
        
        self.tableView = UITableView(frame: CGRect.zero,style:.plain)
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.backgroundColor = .white
        self.tableView.showsHorizontalScrollIndicator = false
        self.tableView.showsVerticalScrollIndicator = true
        self.tableView.bounces = false
        self.tableView.separatorStyle = .none
        self.cardView.addSubview(self.tableView)
        self.tableView.isScrollEnabled = true
        
        self.maskview = UIView(frame:.zero)
        self.maskview.translatesAutoresizingMaskIntoConstraints = false
        self.cardView.addSubview(self.maskview)
        self.maskview.isHidden = true
        self.maskview.backgroundColor = .clear

        self.tableView.register(Bundle.xib(named: multiSelectCellIdentifier), forCellReuseIdentifier: multiSelectCellIdentifier)
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        if #available(iOS 11.0, *) {
            self.tableView.roundCorners([.layerMaxXMinYCorner, .layerMinXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMaxYCorner], radius: 5.0, borderColor: UIColor.lightGray, borderWidth: 0.0)
        }
        
        let views: [String: UIView] = ["tileBgv": tileBgv, "tableView": tableView, "maskview": maskview]
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[tileBgv]-5-[tableView]-0-|", options: [], metrics: nil, views: views))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[tableView]-0-|", options: [], metrics: nil, views: views))
        
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[maskview]|", options: [], metrics: nil, views: views))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[maskview]-0-|", options: [], metrics: nil, views: views))

        self.titleLbl = UILabel(frame: CGRect.zero)
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
        let metrics: [String: NSNumber] = ["textLabelMaxWidth": NSNumber(value: Float(kMaxTextWidth)), "textLabelMinWidth": NSNumber(value: Float(kMinTextWidth))]
        self.tileBgv.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[titleLbl]-10-|", options: [], metrics: metrics, views: subView))
        self.tileBgv.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[titleLbl(>=textLabelMinWidth,<=textLabelMaxWidth)]-10-|", options: [], metrics: metrics, views: subView))
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
            if (component.message != nil) {
                //let jsonString = component.message?.messageId
                //print(jsonString!)
                
            }
            if (component.componentDesc != nil) {
                let jsonString = component.componentDesc
                let jsonObject: NSDictionary = Utilities.jsonObjectFromString(jsonString: jsonString!) as! NSDictionary
                componentDescDic = jsonObject as! [String : Any]
                messageId = component.message?.messageId ?? ""
                let jsonDecoder = JSONDecoder()
                 guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject as Any , options: .prettyPrinted),
                let allItems = try? jsonDecoder.decode(Componentss.self, from: jsonData) else {
                    return
                }
                self.titleLbl.text = allItems.heading ?? ""
                isSliderView = allItems.sliderView  ?? false
               
                arrayOfElements = allItems.elements ?? []
                arrayOfButtons = allItems.buttons ?? []
//                if !isShowMoreIsHidden{
//                    arrayOfSeletedValues = []
//                    checkboxIndexPath = [IndexPath]()
//                    arrayOfSeletedValues = [String]()
//                    sectionLimit = allItems.limit ?? arrayOfElements.count
//                    for _ in 0..<arrayOfElements.count{
//                        arrayOfHeaderCheck.append("Uncheck")
//                    }
//                }

                checkboxIndexPath = []
                if let slectedValue = jsonObject["selectedValue"] as? [String: Any]{
                    //print(slectedValue)
                    if let isShow = slectedValue["isSelectedShowMore"] as? Bool, isShow == true{
                        isShowMoreIsHidden = isShow
                        sectionLimit = arrayOfElements.count
                    }else{
                        isShowMoreIsHidden = false
                        sectionLimit = 1
                    }
                    if let value = slectedValue["value"] as? [[String: Any]]{
                        arrayOfHeaderCheck = []
                        checkboxIndexPath = []
                        arrayOfSeletedValues = []
                        arrayOfSeletedTitles = []
                        for i in 0..<value.count{
                            let selectedIndexpath = value[i]
                            let section = selectedIndexpath["section"] as! Int
                            let row = selectedIndexpath["row"] as! Int
                            let indexPath = IndexPath(row: row , section: section)
                            checkboxIndexPath.append(indexPath)
                        }
                        for i in 0..<arrayOfElements.count{
                            let elementsCollection = arrayOfElements[i]
                            let section = i
                            let rowCountInSection = checkboxIndexPath.filter { $0.section == section }.count
                            if elementsCollection.collection?.count == rowCountInSection{
                                arrayOfHeaderCheck.append("Check")
                            }else{
                                arrayOfHeaderCheck.append("Uncheck")
                            }
                        }
                    }
                    
                }else{
                    sectionLimit = 1
                    isShowMoreIsHidden = false
                    arrayOfHeaderCheck = []
                    checkboxIndexPath = []
                    arrayOfSeletedValues = []
                    arrayOfSeletedTitles = []
                    sectionLimit = allItems.limit ?? arrayOfElements.count
                    for _ in 0..<arrayOfElements.count{
                        arrayOfHeaderCheck.append("Uncheck")
                    }
                }
                
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
        if isSliderView{
            return CGSize(width: 0.0, height: textSize.height + 20.0)
        }else{
            var cellHeight : CGFloat = 0.0
            var finalHeight: CGFloat = 0.0
            var HeaderVHeight: CGFloat = 0.0
            let footerHeight: CGFloat = 40.0
            for cellSection in 0..<sectionLimit{
                let elements = arrayOfElements[cellSection]
                if let collectionCount = elements.collection?.count{
                    for i in 0..<collectionCount{
                        let row = tableView.dequeueReusableCell(withIdentifier: multiSelectCellIdentifier, for: IndexPath(row: i, section: cellSection))as! AdvancedMultiSelectCell
                        cellHeight = row.bounds.height
                        finalHeight += cellHeight
                        
                    }
                    
                    if collectionCount == 1{
                        HeaderVHeight += 45.0
                    }else{
                        HeaderVHeight += 75.0
                    }
                }
            }
            return CGSize(width: 0.0, height: textSize.height+30+finalHeight+HeaderVHeight+footerHeight)
        }
        
    }
    
    func insertSelectedValueIntoComponectDesc(value: [IndexPath]){
        var indexPathArry: [[String: Any]] = []
        var indexpathDic:[String:Any] = [:]
        for indexPath in value {
            //print("Selected section: \(indexPath.section), row: \(indexPath.row)")
            indexpathDic["section"] = indexPath.section
            indexpathDic["row"] = indexPath.row
            indexPathArry.append(indexpathDic)
        }
        let dic = ["value": indexPathArry,"isSelectedShowMore": isShowMoreIsHidden] as [String : Any]
        componentDescDic["selectedValue"] = dic
        self.updateMessage?(messageId, Utilities.stringFromJSONObject(object: componentDescDic))
    }
}

extension AdvancedMultiSelectBubbleView: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionLimit
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let elementsCollection = arrayOfElements[section]
        return elementsCollection.collection?.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : AdvancedMultiSelectCell = self.tableView.dequeueReusableCell(withIdentifier: multiSelectCellIdentifier) as! AdvancedMultiSelectCell
        cell.backgroundColor = UIColor.clear
        cell.selectionStyle = .none
        let elements = arrayOfElements[indexPath.section]
        let elementsCollection = elements.collection?[indexPath.row]
        cell.titleLbl.text = elementsCollection?.title
        cell.descLbl.text = elementsCollection?.descrip
        
        if let urlStr = elementsCollection?.image_url, let url = URL(string: urlStr){
            cell.imagV.af.setImage(withURL: url, placeholderImage: UIImage(named: "placeholder_image"))
            cell.imgVWidthConstraint.constant = 52.0
            cell.imgVLeadingConstraint.constant = 5.0
        }else{
            cell.imgVWidthConstraint.constant = 0.0
            cell.imgVLeadingConstraint.constant = 0.0
        }
        if checkboxIndexPath.contains(indexPath) {
            let imgV = UIImage.init(named: "check", in: bundle, compatibleWith: nil)
            cell.checkImage.image = imgV?.withRenderingMode(.alwaysTemplate)
            cell.checkImage.tintColor = BubbleViewRightTint
        }else{
            let imgV = UIImage.init(named: "uncheck", in: bundle, compatibleWith: nil)
            cell.checkImage.image = imgV?.withRenderingMode(.alwaysTemplate)
            cell.checkImage.tintColor = BubbleViewLeftTint
        }
        return cell
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let elements = arrayOfElements[indexPath.section]
        let elementsCollection = elements.collection?[indexPath.row]
        if checkboxIndexPath.contains(indexPath) {
            removeSelectedValues(value: elementsCollection?.value ?? "", titles: elementsCollection?.title ?? "")
            checkboxIndexPath.remove(at: checkboxIndexPath.firstIndex(of: indexPath)!)
        }else{
            checkboxIndexPath.append(indexPath)
            let value = "\(elementsCollection?.value ?? "")"
            arrayOfSeletedValues.append(value)
            arrayOfSeletedTitles.append("\(elementsCollection?.title ?? "")")
        }
        var zzz = 0
        if let collectionCount = elements.collection?.count{
            for i in 0..<collectionCount{
                let elementsCollection = elements.collection?[i]
                let collectionTitle = elementsCollection?.value
                for j in 0..<arrayOfSeletedValues.count{
                    let selectedTitles = arrayOfSeletedValues[j]
                    if collectionTitle == selectedTitles{
                        zzz += 1
                    }
                }
            }
            if zzz == collectionCount{
                arrayOfHeaderCheck[indexPath.section] = "Check"
            }else{
                arrayOfHeaderCheck[indexPath.section] = "Uncheck"
            }
        }
        tableView.reloadData()
        hideDoneButton()
    }
    func hideDoneButton(){
        if arrayOfSeletedValues.count > 0{
            doneButton.isHidden = false
        }else{
            doneButton.isHidden = false
        }
    }
    func removeSelectedValues(value:String,titles:String){
        arrayOfSeletedValues = arrayOfSeletedValues.filter(){$0 != value}
        arrayOfSeletedTitles = arrayOfSeletedTitles.filter(){$0 != titles}
        //print(arrayOfSeletedValues)
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let elements = arrayOfElements[section]
        if let elementsCollection = elements.collection?.count, elementsCollection == 1{
            return 45.0
        }else{
            return 75.0
        }
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .white
        let headerSubView  = AdvancedMultiSelectHeaderV()
        headerSubView.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(headerSubView)
        let elements = arrayOfElements[section]
        if let elementsCollection = elements.collection?.count, elementsCollection == 1{
            headerSubView.selectallVHeightConstraint.constant = 0.0
        }else{
            headerSubView.selectallVHeightConstraint.constant = 30.0
        }
        headerSubView.titleLbl.text = elements.collectionTitle
        headerSubView.titleLbl.font =  UIFont(name: boldCustomFont, size: 15.0)
        headerSubView.descLbl.font =  UIFont(name: mediumCustomFont, size: 14.0)
        headerSubView.descLbl.textColor = BubbleViewBotChatTextColor
        headerSubView.headerCheckBtn.addTarget(self, action: #selector(self.SelectAllButtonAction(_:)), for: .touchUpInside)
        headerSubView.headerCheckBtn.tag = section
        
        if arrayOfHeaderCheck[section] == "Check" {
            let menuImage = UIImage(named: "check", in: bundle, compatibleWith: nil)
            let tintedMenuImage = menuImage?.withRenderingMode(.alwaysTemplate)
            headerSubView.headerCheckBtn.setImage(tintedMenuImage, for: .normal)
            headerSubView.headerCheckBtn.tintColor = BubbleViewRightTint
        }else{
            let menuImage = UIImage(named: "uncheck", in: bundle, compatibleWith: nil)
            let tintedMenuImage = menuImage?.withRenderingMode(.alwaysTemplate)
            headerSubView.headerCheckBtn.setImage(tintedMenuImage, for: .normal)
            headerSubView.headerCheckBtn.tintColor = BubbleViewLeftTint
        }
        
        let views: [String: UIView] = ["headerSubView": headerSubView]
        headerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-5-[headerSubView]-5-|", options:[], metrics:nil, views:views))
        headerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-1-[headerSubView]-1-|", options:[], metrics:nil, views:views))
        return headerView
    }
    @objc fileprivate func SelectAllButtonAction(_ sender: UIButton!) {
        let elements = arrayOfElements[sender.tag]
        if arrayOfHeaderCheck[sender.tag] == "Check" {
            arrayOfHeaderCheck[sender.tag] = "Uncheck"
            if let collectionCount = elements.collection?.count{
                for i in 0..<collectionCount{
                    let indexPath = IndexPath(row: i , section: sender.tag)
                    let elementsCollection = elements.collection?[i]
                    if checkboxIndexPath.contains(indexPath) {
                        removeSelectedValues(value: elementsCollection?.value ?? "", titles: elementsCollection?.title ?? "")
                        checkboxIndexPath.remove(at: checkboxIndexPath.firstIndex(of: indexPath)!)
                    }
                }
            }
        }else{
            arrayOfHeaderCheck[sender.tag] = "Check"
            if let collectionCount = elements.collection?.count{
                for i in 0..<collectionCount{
                    let indexPath = IndexPath(row: i , section: sender.tag)
                    let elementsCollection = elements.collection?[i]
                    if checkboxIndexPath.contains(indexPath) {
                        
                    }else{
                        checkboxIndexPath.append(indexPath)
                        let value = "\(elementsCollection?.value ?? "")"
                        arrayOfSeletedValues.append(value)
                        arrayOfSeletedTitles.append(elementsCollection?.title ?? "")
                        
                    }
                }
            }
        }
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if arrayOfElements.count > 1{
            let lastIndex = sectionLimit - 1
            if lastIndex == section{
                return 40
            }
            return 00
        }
        return 00
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        let showMoreButton = UIButton(frame: CGRect.zero)
        showMoreButton.backgroundColor = .clear
        showMoreButton.translatesAutoresizingMaskIntoConstraints = false
        showMoreButton.clipsToBounds = true
        showMoreButton.layer.cornerRadius = 5
        showMoreButton.layer.borderWidth = 1
        showMoreButton.layer.borderColor = themeColor.cgColor
        showMoreButton.setTitleColor(themeColor, for: .normal)
        showMoreButton.setTitleColor(Common.UIColorRGB(0x999999), for: .disabled)
        showMoreButton.setTitle("View more", for: .normal)
        showMoreButton.titleLabel?.font = UIFont(name: boldCustomFont, size: 12.0)
        view.addSubview(showMoreButton)
        showMoreButton.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.center
        showMoreButton.addTarget(self, action: #selector(self.showMoreButtonAction(_:)), for: .touchUpInside)
        showMoreButton.isHidden = isShowMoreIsHidden
        
        doneButton = UIButton(frame: CGRect.zero)
        doneButton.backgroundColor = themeColor
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.clipsToBounds = true
        doneButton.layer.cornerRadius = 5
        doneButton.layer.borderColor = themeColor.cgColor
        doneButton.titleLabel?.font = UIFont(name: boldCustomFont, size: 12.0)
        doneButton.layer.borderWidth = 1
        doneButton.setTitleColor(Common.UIColorRGB(0x999999), for: .disabled)
        view.addSubview(doneButton)
        doneButton.addTarget(self, action: #selector(self.doneButtonButtonAction(_:)), for: .touchUpInside)
        hideDoneButton()
        
        if arrayOfButtons.count>0{
            let btnTitle: String = arrayOfButtons[0].title!
            let attributeString = NSMutableAttributedString(string: btnTitle,
                                                            attributes: yourAttributes)
            doneButton.setAttributedTitle(attributeString, for: .normal)
        }
        
        let views: [String: UIView] = ["showMoreButton": showMoreButton, "doneButton": doneButton]
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[showMoreButton(40)]-0-|", options:[], metrics:nil, views:views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[showMoreButton(100)]", options:[], metrics:nil, views:views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[doneButton(40)]-0-|", options:[], metrics:nil, views:views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[doneButton(100)]-10-|", options:[], metrics:nil, views:views))
        return view
    }
    @objc fileprivate func showMoreButtonAction(_ sender: AnyObject!) {
            let dic = ["isSelectedShowMore": true]
            componentDescDic["selectedValue"] = dic
            self.updateMessage?(messageId, Utilities.stringFromJSONObject(object: componentDescDic))
          Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { (_) in
                self.isShowMoreIsHidden = true
                self.sectionLimit = self.arrayOfElements.count
               NotificationCenter.default.post(name: Notification.Name(reloadTableNotification), object: nil)
           }
    }
    
    @objc fileprivate func doneButtonButtonAction(_ sender: AnyObject!) {
        if arrayOfSeletedValues.count > 0{
            self.maskview.isHidden = false
            insertSelectedValueIntoComponectDesc(value: checkboxIndexPath)
            let joinedValues = arrayOfSeletedValues.joined(separator: ", ")
            let joinedTitles = arrayOfSeletedTitles.joined(separator: ", ")

            self.optionsAction?("Here are selected items: \(joinedTitles)",joinedValues)
        }
    }
}
