//
//  AdvanceListBubbleView.swift
//  KoreBotSDKFrameWork
//
//  Created by Kartheek Pagidimarri on 19/07/23.
//  Copyright © 2023 Kartheek.Pagidimarri. All rights reserved.
//

import UIKit

class AdvanceListBubbleView: BubbleView {
    let bundle = Bundle.sdkModule
    var tileBgv: UIView!
    var headerTitle: UILabel!
    var headerDesc: UILabel!
    var tableView: UITableView!
    var cardView: UIView!
    var sortBtn: UIButton!
    var searchBtn: UIButton!
    let kMaxTextWidth: CGFloat = BubbleViewMaxWidth - 32.0
    let kMinTextWidth: CGFloat = 20.0
    fileprivate let listCellIdentifier = "AdvancedTextCell"
    fileprivate let AdvancedListOptionsCellIdentifier = "AdvancedListOptionsCell"
    fileprivate let AdvancedListDefaultCellIdentifier = "AdvancedListDefaultCell"
    fileprivate let AdvanceListGridCellIdentifier = "AdvanceListGridCell"
    fileprivate let AdvancedListButtonCellIdentifier = "AdvancedListButtonCell"

    var arrayOfElements = [AdvancedListTempData]()
    //public var optionsAction: ((_ text: String?, _ payload: String?) -> Void)!
    //public var linkAction: ((_ text: String?) -> Void)!
    public var maskview: UIView!
    
    let tableOptionsCellHeight = 44.0
    let tableDefaultCellHeight = 30.0
    let tableGridCellHeight = 285.0
    let tableCellHeight = 66.0
    
    let tableOptionsFooterHeight = 50.0
    let tableDefaultFooterHeight = 200.0
   
    let tableHeaderHeight = 60.0
    
    var isCollapsedArray = [String]()
    var arrayOfCheckMarkSelected = NSMutableArray()
    var slectedRadioTitles = ""
    var slectedRadioValues = ""
    
    var footercollectionView: UICollectionView!
    var checkboxIndexPath = [IndexPath]()
    
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
    
    let colorDropDown = DropDown()
    lazy var dropDowns: [DropDown] = {
        return [
            self.colorDropDown
        ]
    }()
    
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
        self.tileBgv.backgroundColor = .clear
        if #available(iOS 11.0, *) {
            self.tileBgv.roundCorners([ .layerMinXMaxYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner], radius: 10.0, borderColor: UIColor.clear, borderWidth: 1.5)
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
        self.tableView.register(UINib(nibName: AdvancedListOptionsCellIdentifier, bundle: bundle), forCellReuseIdentifier: AdvancedListOptionsCellIdentifier)
        self.tableView.register(UINib(nibName: AdvancedListDefaultCellIdentifier, bundle: bundle), forCellReuseIdentifier: AdvancedListDefaultCellIdentifier)
        self.tableView.register(UINib(nibName: AdvanceListGridCellIdentifier, bundle: bundle), forCellReuseIdentifier: AdvanceListGridCellIdentifier)
        self.tableView.register(UINib(nibName: AdvancedListButtonCellIdentifier, bundle: bundle), forCellReuseIdentifier: AdvancedListButtonCellIdentifier)
        
//        tableView.layer.cornerRadius = 5.0
//        tableView.layer.borderWidth = 1.0
//        tableView.layer.borderColor = UIColor.lightGray.cgColor
//        tableView.clipsToBounds = true
        
        self.maskview = UIView(frame:.zero)
        self.maskview.translatesAutoresizingMaskIntoConstraints = false
        self.cardView.addSubview(self.maskview)
        self.maskview.isHidden = true
        maskview.backgroundColor = .clear
        
        let views: [String: UIView] = ["tileBgv": tileBgv, "tableView": tableView,"maskview": maskview]
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[tileBgv]-0-[tableView]-0-|", options: [], metrics: nil, views: views))
        
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[tileBgv]-0-|", options: [], metrics: nil, views: views))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-5-[tableView]-5-|", options: [], metrics: nil, views: views))
        
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[maskview]|", options: [], metrics: nil, views: views))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[maskview]-0-|", options: [], metrics: nil, views: views))
        
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        
        intializeHeaderViewLayout()
    }
    
    func intializeCardLayout(){
        self.cardView = UIView(frame:.zero)
        self.cardView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.cardView)
        cardView.layer.cornerRadius = 4.0
        cardView.layer.borderWidth = 1.0
        cardView.layer.borderColor = BubbleViewLeftTint.cgColor
        cardView.clipsToBounds = true
        cardView.backgroundColor =  UIColor.white
        let cardViews: [String: UIView] = ["cardView": cardView]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[cardView]-0-|", options: [], metrics: nil, views: cardViews))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[cardView]-0-|", options: [], metrics: nil, views: cardViews))
        
    }
    
    func intializeHeaderViewLayout(){
        headerTitle = UILabel(frame: CGRect.zero)
        headerTitle.textColor = BubbleViewBotChatTextColor
        headerTitle.font = UIFont(name: mediumCustomFont, size: 16.0)
        headerTitle.numberOfLines = 0
        headerTitle.lineBreakMode = NSLineBreakMode.byWordWrapping
        headerTitle.isUserInteractionEnabled = true
        headerTitle.contentMode = UIView.ContentMode.topLeft
        headerTitle.translatesAutoresizingMaskIntoConstraints = false
        self.tileBgv.addSubview(headerTitle)
        headerTitle.adjustsFontSizeToFitWidth = true
        headerTitle.backgroundColor = .clear
        headerTitle.layer.cornerRadius = 6.0
        headerTitle.clipsToBounds = true
        headerTitle.sizeToFit()
        
        headerDesc = UILabel(frame: CGRect.zero)
        headerDesc.textColor = BubbleViewBotChatTextColor
        headerDesc.font = UIFont(name: mediumCustomFont, size: 12.0)
        headerDesc.numberOfLines = 0
        headerDesc.lineBreakMode = NSLineBreakMode.byWordWrapping
        headerDesc.isUserInteractionEnabled = true
        headerDesc.contentMode = UIView.ContentMode.topLeft
        headerDesc.translatesAutoresizingMaskIntoConstraints = false
        self.tileBgv.addSubview(headerDesc)
        headerDesc.adjustsFontSizeToFitWidth = true
        headerDesc.backgroundColor = .clear
        headerDesc.layer.cornerRadius = 6.0
        headerDesc.clipsToBounds = true
        headerDesc.sizeToFit()
        
        
        sortBtn = UIButton(frame: CGRect.zero)
        sortBtn.backgroundColor = .clear
        sortBtn.setImage(UIImage(named: "sort", in: bundle, compatibleWith: nil), for: .normal)
        sortBtn.translatesAutoresizingMaskIntoConstraints = false
        sortBtn.clipsToBounds = true
        sortBtn.isHidden = false
        sortBtn.layer.cornerRadius = 5
        sortBtn.setTitleColor(.blue, for: .normal)
        sortBtn.setTitleColor(Common.UIColorRGB(0x999999), for: .disabled)
        sortBtn.titleLabel?.font = UIFont(name: mediumCustomFont, size: 15.0)
        self.tileBgv.addSubview(sortBtn)
        sortBtn.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.center
        //sortBtn.addTarget(self, action: #selector(self.sortButtonAction(_:)), for: .touchUpInside)
        
        searchBtn = UIButton(frame: CGRect.zero)
        searchBtn.backgroundColor = .clear
        searchBtn.setImage(UIImage(named: "search-1", in: bundle, compatibleWith: nil), for: .normal)
        searchBtn.translatesAutoresizingMaskIntoConstraints = false
        searchBtn.clipsToBounds = true
        searchBtn.isHidden = false
        sortBtn.layer.cornerRadius = 5
        searchBtn.setTitleColor(.blue, for: .normal)
        searchBtn.setTitleColor(Common.UIColorRGB(0x999999), for: .disabled)
        searchBtn.titleLabel?.font = UIFont(name: mediumCustomFont, size: 15.0)
        self.tileBgv.addSubview(searchBtn)
        searchBtn.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.center
        //searchBtn.addTarget(self, action: #selector(self.sortButtonAction(_:)), for: .touchUpInside)

        
        let subView: [String: UIView] = ["headerTitle": headerTitle, "headerDesc": headerDesc ,"sortBtn": sortBtn, "searchBtn": searchBtn]
        self.tileBgv.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[headerTitle(>=21)]-0-[headerDesc(>=21)]-0-|", options: [], metrics: nil, views: subView))
        self.tileBgv.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[sortBtn(25)]", options: [], metrics: nil, views: subView))
        self.tileBgv.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[searchBtn(25)]", options: [], metrics: nil, views: subView))
        self.tileBgv.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-8-[headerTitle]-5-[sortBtn(25)]-5-[searchBtn(25)]-8-|", options: [], metrics: nil, views: subView))
        self.tileBgv.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-8-[headerDesc]-8-|", options: [], metrics: nil, views: subView))
        
    }
    
    @objc func sortButtonAction(_ sender: UIButton!){
        arrayOfElements.shuffle()
        isCollapsedArray.shuffle()
        tableView.reloadData()
    }
    
    override func populateComponents() {
        if (components.count > 0) {
            let component: KREComponent = components.firstObject as! KREComponent
            if (component.componentDesc != nil) {
                let jsonString = component.componentDesc
                let jsonObject: NSDictionary = Utilities.jsonObjectFromString(jsonString: jsonString!) as! NSDictionary
                let jsonDecoder = JSONDecoder()
                guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject["listItems"] as Any , options: .prettyPrinted),
                    let allItems = try? jsonDecoder.decode([AdvancedListTempData].self, from: jsonData) else {
                        return
                }
                arrayOfElements = allItems
                if isCollapsedArray.count == 0{
                    slectedRadioValues = ""
                    slectedRadioTitles = ""
                    isCollapsedArray = []
                    for i in 0..<arrayOfElements.count{
                        let details = arrayOfElements[i]
                        if let isCollapsed = details.isCollapsed{
                            if isCollapsed == true{
                                isCollapsedArray.append("Collapse")
                            }else{
                                isCollapsedArray.append("Expand")
                            }
                        }else{
                            isCollapsedArray.append("No")
                        }
                        
                    }
                }

                headerTitle.text = jsonObject["title"] as? String
                headerDesc.text = jsonObject["description"] as? String
                ConfigureDropDownView()
                tableView.reloadData()
            }
        }
    }
    override var intrinsicContentSize : CGSize {
                
        let limitingSize: CGSize  = CGSize(width: kMaxTextWidth, height: CGFloat.greatestFiniteMagnitude)
        var headerTitleSize: CGSize = self.headerTitle.sizeThatFits(limitingSize)
        if headerTitleSize.height < self.headerTitle.font.pointSize {
            headerTitleSize.height = self.headerTitle.font.pointSize
        }
        var headerDescSize: CGSize = self.headerDesc.sizeThatFits(limitingSize)
        if headerDescSize.height < self.headerDesc.font.pointSize {
            headerDescSize.height = self.headerDesc.font.pointSize
        }
        let verticalSpace = 20
        var heraderViewHeight = 0
        var optionsCellHeight = 0
        var cellHeight = 0
        var footerViewHeight = 0
        for i in 0..<arrayOfElements.count{
            let elementDetails = arrayOfElements[i]
            if let isAccordian = elementDetails.isAccordian, isAccordian == true{
                 let optionsView = elementDetails.view
                if optionsView == "options"{
                    heraderViewHeight += Int(tableHeaderHeight)
                    
                    if isCollapsedArray[i]  == "Expand" || isCollapsedArray[i] == "No"{
                        let height = (elementDetails.optionsData?.count ?? 0) * Int(tableOptionsCellHeight)
                        optionsCellHeight += height
                        
                        footerViewHeight += Int(tableOptionsFooterHeight)
                    }else if isCollapsedArray[i]  == "Collapse"{
                        optionsCellHeight += 00
                        
                        footerViewHeight += 00
                    }
//                    else{
//                        let height = (elementDetails.optionsData?.count ?? 0) * Int(tableOptionsCellHeight)
//                        optionsCellHeight += height
//
//                        footerViewHeight += Int(tableOptionsFooterHeight)
//                    }
                    
                    
                }else if optionsView == "default"{
                    heraderViewHeight += Int(tableHeaderHeight)
                    
                    if isCollapsedArray[i]  == "Expand" || isCollapsedArray[i] == "No"{
                        for _ in 0..<(elementDetails.textInformation?.count ?? 0){
                            optionsCellHeight += Int(tableDefaultCellHeight)
                        }
                    
                        let displayLimit = Int(elementDetails.buttonsLayout?.displayLimit?.displayCount ?? "0") ?? 0
                        if displayLimit < elementDetails.buttons?.count ?? 0{
                            for _ in 0..<displayLimit + 1{ // For More button
                                footerViewHeight += 40 // button height
                            }
                        }else{
                            for _ in 0..<(elementDetails.buttons?.count ?? 0){
                                footerViewHeight += 40 // button height
                            }
                        }
                    }else if isCollapsedArray[i] == "Collapse"{
                        optionsCellHeight += 00
                        footerViewHeight += 00
                    }
                
                }else if optionsView == "table"{
                    heraderViewHeight += Int(tableHeaderHeight)
                    
                    if isCollapsedArray[i] == "Expand" || isCollapsedArray[i] == "No"{
                        if let tablelistData = elementDetails.tableListData, tablelistData.count > 0{
                            let tableData = tablelistData[0]
                            let gridCellHeight = 80
                            if let tableDataRows = tableData.rowData, tableDataRows.count > 0{
                                if tableDataRows.count < 2{
                                    optionsCellHeight += gridCellHeight
                                }else{
                                    let divedRows = tableData.rowData!.count/2
                                    if tableData.rowData!.count % 2 == 0 {
                                        optionsCellHeight += gridCellHeight * divedRows //Even
                                    } else {
                                        optionsCellHeight += gridCellHeight + gridCellHeight * divedRows //Add
                                    }
                                    
                                }
                               
                            }
                        }
                    }else if isCollapsedArray[i] == "Collapse"{
                        optionsCellHeight += 00
                    }
                    
                }else{
                    //cellHeight += 66
                }
            }else{
                cellHeight += Int(tableCellHeight)
            }
        }
        let extraSpace =  0
        let cellHeightt = cellHeight + optionsCellHeight + extraSpace
        return CGSize(width: 0.0, height: headerTitleSize.height+headerDescSize.height+CGFloat(verticalSpace)+CGFloat(cellHeightt)+CGFloat(heraderViewHeight)+CGFloat(footerViewHeight))
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    @objc fileprivate func headerOptionsBtnAction(_ sender: UIButton!) {
        let elementDetails = arrayOfElements[sender.tag]
        if let headerOptions = elementDetails.headerOptions, headerOptions.count > 0{
            let options = headerOptions[0]
            if options.contenttype == "button"{
                if options.type == "postback"{
                    self.optionsAction?(options.title, options.payload)
                }else if options.type == "url"{
                    self.linkAction?(options.headerurl)
                }
                
            }
        }
    }

}

extension AdvanceListBubbleView: UITableViewDelegate, UITableViewDataSource{
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return arrayOfElements.count
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let elementDetails = arrayOfElements[section]
        if let optionsView = elementDetails.view, optionsView == "options"{
            if isCollapsedArray[section] == "Expand"{
                return elementDetails.optionsData?.count ?? 0
            }else if isCollapsedArray[section] == "Collapse"{
                return 0
            }
            return elementDetails.optionsData?.count ?? 0
        }else if let optionsView = elementDetails.view, optionsView == "default"{
            if isCollapsedArray[section] == "Expand"{
                let tottalCount = elementDetails.textInformation?.count ?? 0
                return tottalCount
            }else if isCollapsedArray[section] == "Collapse"{
                return 0
            }
            let tottalCount = elementDetails.textInformation?.count ?? 0
            return tottalCount
        }else if let optionsView = elementDetails.view, optionsView == "table"{
            if let tablelistData = elementDetails.tableListData, tablelistData.count > 0{
                let tableData = tablelistData[0]
                if let tableDataRows = tableData.rowData, tableDataRows.count > 0{
                    if isCollapsedArray[section] == "Expand"{
                        return 1
                    }else if isCollapsedArray[section] == "Collapse"{
                        return 0
                    }
                    return 1
                }
                return 0
            }else{
                return 0
            }
        }
        return  1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let elementDetails = arrayOfElements[indexPath.section]
        if let optionsView = elementDetails.view, optionsView == "options"{
            let cell : AdvancedListOptionsCell = tableView.dequeueReusableCell(withIdentifier: AdvancedListOptionsCellIdentifier) as! AdvancedListOptionsCell
            cell.backgroundColor = UIColor.clear
            cell.selectionStyle = .none
            let optionsData = elementDetails.optionsData
            let optionsDataDetails = optionsData?[indexPath.row]
            cell.titleLbl.text = optionsDataDetails?.label
            if optionsDataDetails?.type == "checkbox"{
                cell.checkBtn.isHidden = false
                cell.checkImgV.isHidden = true
                if checkboxIndexPath.contains(indexPath) {
                    let radio_check = UIImage(named: "check", in: bundle, compatibleWith: nil)
                    let tintedradio_checkImage = radio_check?.withRenderingMode(.alwaysTemplate)
                    cell.checkBtn.setImage(tintedradio_checkImage, for: .normal)
                    cell.checkBtn.tintColor = themeColor
                }else{
                    let radio_check = UIImage(named: "uncheck", in: bundle, compatibleWith: nil)
                    let tintedradio_checkImage = radio_check?.withRenderingMode(.alwaysTemplate)
                    cell.checkBtn.setImage(tintedradio_checkImage, for: .normal)
                    cell.checkBtn.tintColor = themeColor
                }
            }else{
                cell.checkBtn.isHidden = true
                cell.checkImgV.isHidden = false
                cell.layer.cornerRadius = 5.0
                cell.clipsToBounds = true
                if checkboxIndexPath.contains(indexPath) {
                    let radio_check = UIImage(named: "radio_check", in: bundle, compatibleWith: nil)
                    let tintedradio_checkImage = radio_check?.withRenderingMode(.alwaysTemplate)
                    cell.checkImgV.image = tintedradio_checkImage
                    cell.checkImgV.tintColor = themeColor
                    cell.backgroundColor = BubbleViewLeftTint
                }else{
                    let radio_check = UIImage(named: "radio_uncheck", in: bundle, compatibleWith: nil)
                    let tintedradio_checkImage = radio_check?.withRenderingMode(.alwaysTemplate)
                    cell.checkImgV.image = tintedradio_checkImage
                    cell.checkImgV.tintColor = themeColor
                    cell.backgroundColor = UIColor.clear
                }
            }
            return cell
        }
        else if let optionsView = elementDetails.view, optionsView == "default"{
            let cell : AdvancedListDefaultCell = tableView.dequeueReusableCell(withIdentifier: AdvancedListDefaultCellIdentifier) as! AdvancedListDefaultCell
            cell.backgroundColor = UIColor.clear
            cell.selectionStyle = .none
            let textInformation = elementDetails.textInformation
            let txtDetails = textInformation?[indexPath.row]
            cell.titleLbl.text = txtDetails?.title
            if let iconImg = txtDetails?.icon{
                if iconImg.contains("base64"){
                    let image = Utilities.base64ToImage(base64String: iconImg)
                    cell.imagV.image = image
                }else{
                    if let url = URL(string: iconImg){
                        cell.imagV.af.setImage(withURL: url, placeholderImage: UIImage.init(named: "placeholder_image", in: bundle, compatibleWith: nil))
                    }
                }
            }
            return cell
        }else if let optionsView = elementDetails.view, optionsView == "table"{
            let cell : AdvanceListGridCell = tableView.dequeueReusableCell(withIdentifier: AdvanceListGridCellIdentifier) as! AdvanceListGridCell
            cell.backgroundColor = UIColor.clear
            cell.selectionStyle = .none
            if let tablelistData = elementDetails.tableListData, tablelistData.count > 0{
                let tableData = tablelistData[0]
                if let tableDataRows = tableData.rowData, tableDataRows.count > 0{
                    cell.configure(with: tableDataRows)
                }
            }
            
            return cell
        }else{
            
            let cell : AdvancedTextCell = tableView.dequeueReusableCell(withIdentifier: listCellIdentifier) as! AdvancedTextCell
            cell.backgroundColor = UIColor.clear
            cell.selectionStyle = .none
            cell.bgV.backgroundColor = UIColor.white
            if let elementStyles = elementDetails.elementStyles{
                cell.bgV.backgroundColor = UIColor.init(hexString: elementStyles.bground ?? "#ffffff")
            }
            cell.titleLbl.text = elementDetails.title
            cell.descLbl.text = elementDetails.desc
            cell.titleLbl.textColor = BubbleViewBotChatTextColor
            cell.descLbl.textColor = BubbleViewBotChatTextColor
            if let titleStyles = elementDetails.titleStyles?.color{
                cell.titleLbl.textColor = UIColor.init(hexString: titleStyles)
            }
            if let descriptionStyles = elementDetails.descriptionStyles?.color{
                cell.descLbl.textColor = UIColor.init(hexString: descriptionStyles)
            }

            cell.imagV.isHidden = true
            cell.imagV.layer.cornerRadius = 5.0
            cell.imagV.clipsToBounds = true
            cell.desciptionIcon.isHidden = true
            cell.descriptionRightIcon.isHidden = true
            cell.descLblLeadingConstraint.constant = 0.0
            cell.descIconWidthConstaint.constant = 0.0
            cell.imagVwidthConstraint.constant = 0.0
            cell.titlLblLedingConstraint.constant = 0.0
            cell.btnWidthConstraint.constant = 0.0
            cell.arrowImgwidthConstraint.constant = 0.0
            cell.underlineLbl.isHidden = false
            if let descIcon = elementDetails.descriptionIcon{
                if let descIconAlignMent = elementDetails.descriptionIconAlignment,descIconAlignMent == "right"{
                    cell.descriptionRightIcon.isHidden = false
                    if descIcon.contains("base64"){
                        let image = Utilities.base64ToImage(base64String: descIcon)
                        cell.descriptionRightIcon.image = image
                    }else{
                        if let url = URL(string: descIcon){
                            cell.desciptionIcon.af.setImage(withURL: url, placeholderImage: UIImage.init(named: "placeholder_image", in: bundle, compatibleWith: nil))
                        }
                    }
                }else{
                    if descIcon.contains("base64"){
                        let image = Utilities.base64ToImage(base64String: descIcon)
                        cell.desciptionIcon.image = image
                        cell.desciptionIcon.isHidden = false
                        cell.descIconWidthConstaint.constant = 15.0
                        cell.descLblLeadingConstraint.constant = 8.0
                    }else{
                        if let url = URL(string: descIcon){
                            cell.desciptionIcon.af.setImage(withURL: url, placeholderImage: UIImage.init(named: "placeholder_image", in: bundle, compatibleWith: nil))
                            cell.desciptionIcon.isHidden = false
                            cell.descIconWidthConstaint.constant = 15.0
                            cell.descLblLeadingConstraint.constant = 8.0
                        }
                    }
                }
    
            }
            if let iconImg = elementDetails.icon{
                if iconImg.contains("base64"){
                    let image = Utilities.base64ToImage(base64String: iconImg)
                    cell.imagV.image = image
                    cell.imagV.isHidden = false
                    cell.imagVwidthConstraint.constant = 40.0
                    cell.descLblLeadingConstraint.constant = 48.0
                    cell.titlLblLedingConstraint.constant = 8.0
                }else{
                    if let url = URL(string: iconImg){
                        cell.imagV.af.setImage(withURL: url, placeholderImage: UIImage.init(named: "placeholder_image", in: bundle, compatibleWith: nil))
                        cell.imagV.isHidden = false
                        cell.imagVwidthConstraint.constant = 40.0
                        cell.descLblLeadingConstraint.constant = 48.0
                        cell.titlLblLedingConstraint.constant = 8.0
                    }
                }
            }
            if let headerOptions = elementDetails.headerOptions, headerOptions.count > 0{
                 let options = headerOptions[0]
                  if options.contenttype == "button"{
                    cell.btnWidthConstraint.constant = 70.0
                      cell.btn.setTitle(options.title, for: .normal)
                      let btnStyles = options.buttonStyles
                      cell.btn.backgroundColor = UIColor(hexString: "#eaf1fe")
                      cell.btn.setTitleColor(UIColor(hexString: btnStyles?.color ?? "#10f4f4"), for: .normal)
                      
                      cell.btn.addTarget(self, action: #selector(self.headerOptionsBtnAction(_:)), for: .touchUpInside)
                      cell.btn.tag = indexPath.section
                }
                if let optionsType = options.type, optionsType == "dropdown"{
                    
                    cell.arrowImgwidthConstraint.constant = 15.0
                    let imgV = UIImage.init(named: "VDotMenu", in: bundle, compatibleWith: nil)
                    cell.arrowImag.image = imgV?.withRenderingMode(.alwaysTemplate)
                    cell.arrowImag.tintColor = .black
                }
            }
            if let isCollapsed = elementDetails.isCollapsed, isCollapsed == true{
                cell.arrowImgwidthConstraint.constant = 15.0
                let imgV = UIImage.init(named: "downarrow", in: bundle, compatibleWith: nil)
                cell.arrowImag.image = imgV?.withRenderingMode(.alwaysTemplate)
                cell.arrowImag.tintColor = .black
            }
            
            return cell
        }
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let elementDetails = arrayOfElements[indexPath.section]
        let optionsView = elementDetails.view
            if optionsView == "options"{
                let optionsData = elementDetails.optionsData
                let optionsDataDetails = optionsData?[indexPath.row]
                if optionsDataDetails?.type == "checkbox"{
                    if checkboxIndexPath.contains(indexPath) {
                        checkboxIndexPath.remove(at: checkboxIndexPath.firstIndex(of: indexPath)!)
                        var removedCheckArray = NSMutableArray()
                        removedCheckArray = arrayOfCheckMarkSelected
                        for i in 0..<arrayOfCheckMarkSelected.count{
                            if arrayOfCheckMarkSelected.count > i{
                                if arrayOfCheckMarkSelected[i] as? String == optionsDataDetails?.label{
                                    removedCheckArray.removeObject(at: i)
                                }
                            }
                            
                        }
                        arrayOfCheckMarkSelected = []
                        arrayOfCheckMarkSelected = removedCheckArray
                    }else{
                        checkboxIndexPath.append(indexPath)
                        arrayOfCheckMarkSelected.add(optionsDataDetails?.label ?? "")
                    }
                    tableView.reloadRows(at: [indexPath], with: .none)
                }else{
                    slectedRadioValues = optionsDataDetails?.value ?? ""
                    slectedRadioTitles = optionsDataDetails?.label ?? ""
                    checkboxIndexPath.removeAll(where: { $0.section == indexPath.section})
                     checkboxIndexPath.append(indexPath)
                    tableView.reloadSections(IndexSet(integer: indexPath.section), with: .none)
                }
            }else{
                
                if let headerOptions = elementDetails.headerOptions, headerOptions.count > 0{
                     let options = headerOptions[0]
                      if options.contenttype == "button"{
                        
                    }
                    if let optionsType = options.type, optionsType == "dropdown"{
                        let cell = tableView.cellForRow(at: indexPath)
                        //setupDropDown(with: options.dropdownOptions ?? [], dropDownPosition: Float(cell?.frame.midY ?? 0.0))
                        setupDropDown(with: options.dropdownOptions ?? [], dropDownPosition:  Float(cell?.frame.origin.y ?? 0.0), dropDownXPosition:  Float(cell?.frame.origin.y ?? 0.0))
                        colorDropDown.show()
                    }
                }
            }
    }
   
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let elementDetails = arrayOfElements[indexPath.section]
        let optionsView = elementDetails.view
            if optionsView == "options"{
                return tableOptionsCellHeight
            }else if optionsView == "default"{
                return tableDefaultCellHeight
            }else if optionsView == "table"{
                return tableGridCellHeight
            }
        return 66
    }
    
    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let elementDetails = arrayOfElements[indexPath.section]
            let optionsView = elementDetails.view
            if optionsView == "options"{
                return tableOptionsCellHeight
            }else if optionsView == "default"{
                return tableDefaultCellHeight
            }else if optionsView == "table"{
                return tableGridCellHeight
            }
        return 66
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let elementDetails = arrayOfElements[section]
        let optionsView = elementDetails.view
        if optionsView == "options"{
            if isCollapsedArray[section] == "Expand"{
                return tableOptionsFooterHeight
              }else if isCollapsedArray[section] == "Collapse"{
                return 0
            }
            return tableOptionsFooterHeight
        }else if optionsView == "default"{
           var footerViewHeight = 0
            if isCollapsedArray[section] == "Expand"{
                let displayLimit = Int(elementDetails.buttonsLayout?.displayLimit?.displayCount ?? "0") ?? 0
                if displayLimit < elementDetails.buttons?.count ?? 0{
                    for _ in 0..<displayLimit + 1{ // For More button
                        footerViewHeight += 40 // button height
                    }
                }else{
                    for _ in 0..<(elementDetails.buttons?.count ?? 0){
                        footerViewHeight += 40 // button height
                    }
                }
                return CGFloat(footerViewHeight)
            }else if isCollapsedArray[section] == "Collapse"{
                return CGFloat(footerViewHeight)
            }
            let displayLimit = Int(elementDetails.buttonsLayout?.displayLimit?.displayCount ?? "0") ?? 0
            if displayLimit < elementDetails.buttons?.count ?? 0{
                for _ in 0..<displayLimit + 1{ // For More button
                    footerViewHeight += 40 // button height
                }
            }else{
                for _ in 0..<(elementDetails.buttons?.count ?? 0){
                    footerViewHeight += 40 // button height
                }
            }
            return CGFloat(footerViewHeight)
        }else{
            return 0
        }
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let elementDetails = arrayOfElements[section]
        let optionsView = elementDetails.view
        if optionsView == "options"{
            let footerView = UIView()
            let layout = TagFlowLayout()
            layout.scrollDirection = .horizontal
            footercollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
            footercollectionView.translatesAutoresizingMaskIntoConstraints = false
            footercollectionView.dataSource = self
            footercollectionView.delegate = self
            footercollectionView.backgroundColor = .clear
            footercollectionView.showsHorizontalScrollIndicator = false
            footercollectionView.showsVerticalScrollIndicator = false
            footercollectionView.bounces = false
            footercollectionView.isScrollEnabled = true
            footerView.addSubview(footercollectionView)
            footercollectionView.tag = section
            
            footercollectionView.register(UINib(nibName: "ButtonLinkCell", bundle: bundle),
                                         forCellWithReuseIdentifier: "ButtonLinkCell")
            let elementDetails = arrayOfElements[section]
            if let alignment = elementDetails.buttonAligment, alignment == "right"{
                footercollectionView.semanticContentAttribute = .forceRightToLeft
            }else{
                footercollectionView.semanticContentAttribute = .forceLeftToRight
            }
            
            
            let footerunderline = UILabel(frame: CGRect.zero)
            footerunderline.backgroundColor = .lightGray
            footerunderline.isUserInteractionEnabled = true
            footerunderline.translatesAutoresizingMaskIntoConstraints = false
            footerView.addSubview(footerunderline)
            
            
            let views: [String: UIView] = ["footercollectionView": footercollectionView, "footerunderline": footerunderline]
            footerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[footercollectionView]-3-[footerunderline(1)]-0-|", options:[], metrics:nil, views:views))
            footerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[footercollectionView]-10-|", options:[], metrics:nil, views:views))
            footerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[footerunderline]-0-|", options:[], metrics:nil, views:views))
            return footerView
        }else if optionsView == "default"{
            let footerView = UIView()
            let layout = TagFlowLayout()
            layout.scrollDirection = .vertical
            footercollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
            footercollectionView.translatesAutoresizingMaskIntoConstraints = false
            footercollectionView.dataSource = self
            footercollectionView.delegate = self
            footercollectionView.backgroundColor = .clear
            footercollectionView.showsHorizontalScrollIndicator = false
            footercollectionView.showsVerticalScrollIndicator = false
            footercollectionView.bounces = false
            footercollectionView.isScrollEnabled = false
            footerView.addSubview(footercollectionView)
            footercollectionView.tag = section
            
            footercollectionView.register(UINib(nibName: "AdvancedListBtnCell", bundle: bundle),
                                         forCellWithReuseIdentifier: "AdvancedListBtnCell")
            let elementDetails = arrayOfElements[section]
            if let alignment = elementDetails.buttonAligment, alignment == "right"{
                footercollectionView.semanticContentAttribute = .forceRightToLeft
            }else{
                footercollectionView.semanticContentAttribute = .forceLeftToRight
            }
            
            
            let footerunderline = UILabel(frame: CGRect.zero)
            footerunderline.backgroundColor = .lightGray
            footerunderline.isUserInteractionEnabled = true
            footerunderline.translatesAutoresizingMaskIntoConstraints = false
            footerView.addSubview(footerunderline)
            
            
            let views: [String: UIView] = ["footercollectionView": footercollectionView, "footerunderline": footerunderline]
            footerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[footercollectionView]-3-[footerunderline(1)]-0-|", options:[], metrics:nil, views:views))
            footerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[footercollectionView]-10-|", options:[], metrics:nil, views:views))
            footerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[footerunderline]-0-|", options:[], metrics:nil, views:views))
            return footerView
        }else{
            return UIView()
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let elementDetails = arrayOfElements[section]
        let optionsView = elementDetails.view
        if optionsView == "options" || optionsView == "default" ||  optionsView == "table"{
            return tableHeaderHeight
        }
        return 0
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView  = AdvancedListHeaderView()
        let headerDetails = arrayOfElements[section]
        headerView.titleLabel.text = headerDetails.title
        headerView.subTilteLabel.text = headerDetails.desc
        
        if let descIcon = headerDetails.icon{
            headerView.imagView.clipsToBounds = true
            let iconsize = headerDetails.imageSize ?? "medium"
            if iconsize == "large"{
                headerView.imagVHeightConstraint.constant = 50.0
                headerView.imagVWidthConstraint.constant = 50.0
                
                if let iconShape = headerDetails.iconShape, iconShape == "circle-img"{
                    headerView.imagView.layer.cornerRadius = 25.0
                }
            }else if iconsize == "medium"{
                headerView.imagVHeightConstraint.constant = 30.0
                headerView.imagVWidthConstraint.constant = 30.0
                if let iconShape = headerDetails.iconShape, iconShape == "circle-img"{
                    headerView.imagView.layer.cornerRadius = 15.0
                }
            }else if iconsize == "small"{
                headerView.imagVHeightConstraint.constant = 20.0
                headerView.imagVWidthConstraint.constant = 20.0
                if let iconShape = headerDetails.iconShape, iconShape == "circle-img"{
                    headerView.imagView.layer.cornerRadius = 10.0
                }
            }
            
            if descIcon.contains("base64"){
                let image = Utilities.base64ToImage(base64String: descIcon)
                headerView.imagView.image = image
            }else{
                if let url = URL(string: descIcon){
                    headerView.imagView.af.setImage(withURL: url, placeholderImage: UIImage.init(named: "placeholder_image", in: bundle, compatibleWith: nil))
                }
            }
        }
        headerView.btnWidthConstraint.constant = 0.0
        headerView.dropDownBtnWidthConstraint.constant = 0.0
        //let optionsView = headerDetails.view
        //if optionsView == "table"{
            if let headerOptions = headerDetails.headerOptions, headerOptions.count > 0{
                for i in 0..<headerOptions.count{
                    let options = headerOptions[i]
                    if options.contenttype == "button"{
                        headerView.btnWidthConstraint.constant = 70.0
                        headerView.btn.setTitle(options.title, for: .normal)
                        let btnStyles = options.buttonStyles
                        headerView.btn.backgroundColor = UIColor(hexString: btnStyles?.bground ?? "#eaf1fe")
                        if let color =  btnStyles?.color{
                            headerView.btn.setTitleColor(UIColor(hexString: color), for: .normal)
                        }else{
                            headerView.btn.setTitleColor(bubbleViewBotChatButtonBgColor, for: .normal)
                        }
                        headerView.btn.addTarget(self, action: #selector(self.headerOptionsBtnAction(_:)), for: .touchUpInside)
                        headerView.btn.layer.borderWidth = 0.0
                        if (btnStyles?.btnBorder) != nil{
                            headerView.btn.layer.borderWidth = 1.0
                            if let color =  btnStyles?.color{
                                headerView.btn.layer.borderColor = UIColor(hexString: color).cgColor
                            }else{
                                headerView.btn.layer.borderColor = bubbleViewBotChatButtonBgColor.cgColor
                            }
                            headerView.btn.clipsToBounds = true
                        }
                        headerView.btn.tag = section
                    }
                    if options.type == "text"{
                        headerView.btnWidthConstraint.constant = 70.0
                        headerView.btn.setTitle(options.value, for: .normal)
                        let btnStyles = options.buttonStyles
                        headerView.btn.backgroundColor = UIColor(hexString: btnStyles?.bground ?? "#ffffff")
                        headerView.btn.setTitleColor(UIColor(hexString: btnStyles?.color ?? "#000000"), for: .normal)
                        //headerView.btn.addTarget(self, action: #selector(self.headerOptionsBtnAction(_:)), for: .touchUpInside)
                        headerView.btn.layer.borderWidth = 0.0
                        if (btnStyles?.btnBorder) != nil{
                            headerView.btn.layer.borderWidth = 1.0
                            headerView.btn.layer.borderColor = UIColor(hexString: btnStyles?.color ?? "#ffffff").cgColor
                            headerView.btn.clipsToBounds = true
                        }
                        headerView.btn.tag = section
                  }
                   if options.type == "icon"{
                       headerView.dropDownBtnWidthConstraint.constant = 15.0
                       let imgV = UIImage.init(named: "downarrow", in: bundle, compatibleWith: nil)
                       let tintedMenuImage = imgV?.withRenderingMode(.alwaysTemplate)
                       headerView.dropDownBtn.setImage(tintedMenuImage, for: .normal)
                       
                       if let icon = options.icon{
                           if icon.contains("base64"){
                               let image = Utilities.base64ToImage(base64String: icon)
                               headerView.dropDownBtn.setImage(image, for: .normal)
                           }
                       }
                       if isCollapsedArray[section] == "Collapse"{
                           headerView.dropDownBtn.transform = headerView.dropDownBtn.transform.rotated(by: 0)
                       }else{
                           headerView.dropDownBtn.transform = headerView.dropDownBtn.transform.rotated(by: .pi/2)
                       }
                       headerView.dropDownBtn.tintColor = .black
                       headerView.dropDownBtn.isUserInteractionEnabled = true
                       headerView.dropDownBtn.addTarget(self, action: #selector(self.headerDropDownBtnAction(_:)), for: .touchUpInside)
                       headerView.dropDownBtn.tag = section
                   }
                }
                 
            }
        //}
        return headerView
    }
    
    @objc fileprivate func headerDropDownBtnAction(_ sender: UIButton!) {
        if isCollapsedArray[sender.tag] == "Expand"{
            isCollapsedArray[sender.tag] = "Collapse"
        }else if isCollapsedArray[sender.tag] == "Collapse"{
            isCollapsedArray[sender.tag] = "Expand"
        }
        NotificationCenter.default.post(name: Notification.Name(reloadTableNotification), object: nil)
    }
}

extension AdvanceListBubbleView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let elementDetails = arrayOfElements[collectionView.tag]
            let optionsView = elementDetails.view
            if optionsView == "options"{
                return elementDetails.buttons?.count ?? 0
            }else if optionsView == "default"{
                let displayLimit = Int(elementDetails.buttonsLayout?.displayLimit?.displayCount ?? "0") ?? 0
                if displayLimit < elementDetails.buttons?.count ?? 0{
                    return displayLimit + 1  //For More Button
                }else{
                    return elementDetails.buttons?.count ?? 0
                }
            }
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let elementDetails = arrayOfElements[collectionView.tag]
            let optionsView = elementDetails.view
            if optionsView == "default"{
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AdvancedListBtnCell", for: indexPath) as! AdvancedListBtnCell
                cell.titleBtn.backgroundColor =  UIColor.init(hexString: "e9f1fe")
                cell.titleBtn.layer.cornerRadius = 2.0
                cell.titleBtn.clipsToBounds = true
                cell.titleBtn.setTitleColor(BubbleViewRightTint, for: .normal)
                let buttons =  elementDetails.buttons
                let buttonDetails = buttons?[indexPath.item]
                
                let displayLimit = Int(elementDetails.buttonsLayout?.displayLimit?.displayCount ?? "0") ?? 0
                if displayLimit < elementDetails.buttons?.count ?? 0{
                    if displayLimit == indexPath.item{
                        cell.titleBtn.setTitle("... More", for: .normal)
                        if #available(iOS 13.0, *) {
                            cell.titleBtn.setImage(UIImage(named: "", in: bundle, with: nil), for: .normal)
                        }
                    }else{
                        cell.titleBtn.setTitle(buttonDetails?.title, for: .normal)
                        if let imageIcon = buttonDetails?.icon{
                            if imageIcon.contains("base64"){
                                let image = Utilities.base64ToImage(base64String: imageIcon)
                                cell.titleBtn.setImage(image, for: .normal)
                            }else{
                                if let url = URL(string: imageIcon){
                                    cell.titleBtn.af.setImage(for: .normal, url: url)
                                }
                            }
                            cell.titleBtn.setTitle(" \(buttonDetails?.title ?? "")", for: .normal)
                        }
                    }
                }else{
                    cell.titleBtn.setTitle(buttonDetails?.title, for: .normal)
                    if let imageIcon = buttonDetails?.icon{
                        if imageIcon.contains("base64"){
                            let image = Utilities.base64ToImage(base64String: imageIcon)
                            cell.titleBtn.setImage(image, for: .normal)
                        }else{
                            if let url = URL(string: imageIcon){
                                cell.titleBtn.af.setImage(for: .normal, url: url)
                            }
                        }

                        cell.titleBtn.setTitle(" \(buttonDetails?.title ?? "")", for: .normal)
                    }
                }
                
                
                cell.titleBtn.isUserInteractionEnabled = false
//                cell.titleBtn.addTarget(self, action: #selector(self.collectionVbtnBtnAction(_:)), for: .touchUpInside)
//                cell.titleBtn.tag = indexPath.item
                return cell
            }else{
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ButtonLinkCell", for: indexPath) as! ButtonLinkCell
                cell.backgroundColor = .clear
                cell.bgV.backgroundColor = .clear
                cell.textlabel.font = UIFont(name: mediumCustomFont, size: 14.0)
                let buttons =  elementDetails.buttons
                let buttonDetails = buttons?[indexPath.item]
                cell.textlabel.text = buttonDetails?.title

                cell.textlabel.textAlignment = .center
                //cell.layer.borderColor = UIColor.init(hexString: "e9f1fe").cgColor
                cell.layer.borderWidth = 1.5
                cell.layer.cornerRadius = 5
                let btnBgActiveColor = bubbleViewBotChatButtonBgColor
                let btnActiveTextColor = bubbleViewBotChatButtonTextColor
                if indexPath.item == 0{
                    cell.textlabel.textColor = btnActiveTextColor
                    cell.layer.borderColor = btnBgActiveColor.cgColor
                    cell.backgroundColor = btnBgActiveColor
                }else{
                    cell.textlabel.textColor = BubbleViewBotChatTextColor
                    cell.layer.borderColor = btnBgActiveColor.cgColor
                    cell.backgroundColor = .clear
                }
                
                cell.imagvWidthConstraint.constant = 0.0
                return cell
            }
      
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let elementDetails = arrayOfElements[collectionView.tag]
        let optionsView = elementDetails.view
        if optionsView == "options"{
            let  options = elementDetails.buttons?[indexPath.item]
            if options?.btnType == "confirm"{
                
                let optionsData = elementDetails.optionsData
                let optionsDetails = optionsData?[indexPath.item]
                if optionsDetails?.type == "checkbox"{
                    if arrayOfCheckMarkSelected.count > 0{
                        var appendedStr = ""
                        for i in 0..<arrayOfCheckMarkSelected.count{
                            appendedStr += "\(arrayOfCheckMarkSelected[i]),"
                        }
                        let payloadStr = String(appendedStr.dropLast())
                        self.optionsAction?(payloadStr, payloadStr)
                        arrayOfCheckMarkSelected = []
                    }
                   
                }else if optionsDetails?.type == "radio"{
                    if slectedRadioTitles != ""{
                        self.optionsAction?("Confirm: \(slectedRadioValues)", slectedRadioValues)
                    }else{
                        self.optionsAction?(options?.title, options?.payload)
                    }
                    
                }else{
                    self.optionsAction?(options?.title, options?.payload)
                }
                
            }else{
                slectedRadioValues = ""
                slectedRadioTitles = ""
                checkboxIndexPath.removeAll(where: { $0.section == collectionView.tag})
                tableView.reloadSections(IndexSet(integer: collectionView.tag), with: .none)
            }
        }else if optionsView == "default"{
            let  options = elementDetails.buttons?[indexPath.item]
            let displayLimit = Int(elementDetails.buttonsLayout?.displayLimit?.displayCount ?? "0") ?? 0
            if displayLimit < elementDetails.buttons?.count ?? 0{
                if displayLimit == indexPath.item{
                    
                    var buttons = [DropdownOptions]()
                    for i in 0..<(elementDetails.buttons?.count ?? 0){
                        //if i >= displayLimit{ // add remaining buttons
                            buttons.append((elementDetails.buttons?[i])!)
                        //}
                    }
                    //let cell = collectionView.cellForItem(at: indexPath)
                    
                    let attributes = collectionView.layoutAttributesForItem(at: indexPath)
                    let cellRect = attributes?.frame
                    _ = collectionView.convert(cellRect ?? CGRect.zero, to: collectionView.superview)
                    
                    guard let cell = collectionView.cellForItem(at: indexPath) as? AdvancedListBtnCell else { return }
                        guard let layoutAttributes = collectionView.layoutAttributesForItem(at: indexPath) else { return }
                        guard let window = UIApplication.shared.keyWindow else { return }

                    let touchedLocationInWindow = collectionView.convert(cell.center, to: window)
                    
                    let cellRectt = layoutAttributes.frame
                    let cellFrameInSupervieww = collectionView.convert(cellRectt, to: collectionView.superview)
                    
                    setupDropDown(with: buttons, dropDownPosition: Float(touchedLocationInWindow.y - cellFrameInSupervieww.origin.y), dropDownXPosition: 0.0)
                    colorDropDown.show()
                }else{
                    if options?.type == "postback"{
                        self.optionsAction?(options?.title, options?.payload)
                    }else if options?.type == "url"{
                            self.linkAction?(options?.headerurl)
                    }
                }
            }else{
                if options?.type == "postback"{
                    self.optionsAction?(options?.title, options?.payload)
                }else if options?.type == "url"{
                        self.linkAction?(options?.headerurl)
                }
            }
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var text:String?
        let elementDetails = arrayOfElements[collectionView.tag]
        let buttons =  elementDetails.buttons
        let buttonDetails = buttons?[indexPath.item]
        text = buttonDetails?.title
        var textWidth = 10
        let size = text?.size(withAttributes:[.font: UIFont(name: mediumCustomFont, size: 14.0) as Any])
        if text != nil {
            textWidth = Int(size!.width)
        }
        let optionsView = elementDetails.view
        if optionsView == "default"{
            return CGSize(width: collectionView.frame.size.width , height: 40)
        }else{
            return CGSize(width: min(Int(maxContentWidth()) - 10 , textWidth + 32) , height: 40)
        }
        
    }
    
    func maxContentWidth() -> CGFloat {
        if let collectionViewLayout = footercollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let sectionInset: UIEdgeInsets = collectionViewLayout.sectionInset
            return max(frame.size.width - sectionInset.left - sectionInset.right, 1.0)
        }
        return 1.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0.0, left: 5.0, bottom: 0.0, right: 5.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }
}

extension AdvanceListBubbleView{
    func ConfigureDropDownView(){
        //DropDown
        dropDowns.forEach { $0.dismissMode = .onTap }
        dropDowns.forEach { $0.direction = .any }
    
        colorDropDown.backgroundColor = UIColor.init(hexString: "#eaf1fc")//UIColor(white: 1, alpha: 1)
        colorDropDown.selectionBackgroundColor = .clear//UIColor(red: 0.6494, green: 0.8155, blue: 1.0, alpha: 0.2)
        colorDropDown.separatorColor = UIColor(white: 0.7, alpha: 0.8)
        colorDropDown.cornerRadius = 10
        colorDropDown.shadowColor = UIColor(white: 0.6, alpha: 1)
        colorDropDown.shadowOpacity = 0.9
        colorDropDown.shadowRadius = 25
        colorDropDown.animationduration = 0.25
        colorDropDown.textColor = BubbleViewRightTint
        colorDropDown.addBorder(edge: .all, color: BubbleViewLeftTint, borderWidth: 1.0)
        
    }
    // MARK: Setup DropDown
    func setupDropDown(with dropDownArray: [DropdownOptions], dropDownPosition: Float, dropDownXPosition: Float) {
        colorDropDown.anchorView = tableView
        let titles = NSMutableArray()
        let payload = NSMutableArray()
        let type = NSMutableArray()
        for i in 0..<dropDownArray.count{
            let dropDownDetails = dropDownArray[i]
            titles.add(dropDownDetails.title ?? "")
            payload.add(dropDownDetails.payload ?? "")
            type.add(dropDownDetails.type ?? "")
        }
        
        colorDropDown.bottomOffset = CGPoint(x: Int(dropDownXPosition), y: Int(dropDownPosition))
        colorDropDown.dataSource = titles as! [String]
        colorDropDown.reloadInputViews()
        colorDropDown.reloadAllComponents()
        colorDropDown.reloadAllData()
        
        //colorDropDown.selectRow(0)
        // Action triggered on selection
        colorDropDown.selectionAction = { (index, item) in
            if let type = type[index] as? String, type == "postback"{
                self.maskview.isHidden = false
                self.optionsAction?(titles[index] as? String, payload[index] as? String )
            }else{
                //self.linkAction()
            }
        }
        
    }
    
}

extension UIView {

    func addBorder(edge: UIRectEdge, color: UIColor, borderWidth: CGFloat) {

        let seperator = UIView()
        self.addSubview(seperator)
        seperator.translatesAutoresizingMaskIntoConstraints = false

        seperator.backgroundColor = color

        if edge == .top || edge == .bottom
        {
            seperator.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
            seperator.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
            seperator.heightAnchor.constraint(equalToConstant: borderWidth).isActive = true

            if edge == .top
            {
                seperator.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
            }
            else
            {
                seperator.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
            }
        }
        else if edge == .left || edge == .right
        {
            seperator.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
            seperator.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
            seperator.widthAnchor.constraint(equalToConstant: borderWidth).isActive = true

            if edge == .left
            {
                seperator.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
            }
            else
            {
                seperator.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
            }
        }
    }

}
