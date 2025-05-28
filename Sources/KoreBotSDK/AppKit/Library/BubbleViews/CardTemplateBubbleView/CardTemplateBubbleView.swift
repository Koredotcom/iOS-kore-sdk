//
//  CardTemplateBubbleView.swift
//  KoreBotSDKFrameWork
//
//  Created by Kartheek Pagidimarri on 31/07/23.
//  Copyright © 2023 Kartheek.Pagidimarri. All rights reserved.
//

import UIKit

class CardTemplateBubbleView: BubbleView {
    let bundle = Bundle.sdkModule
    var tileBgv: UIView!
    var headerTitle: UILabel!
    var headerDesc: UILabel!
    var tableView: UITableView!
    var cardView: UIView!
    let kMaxTextWidth: CGFloat = BubbleViewMaxWidth - 32.0
    let kMinTextWidth: CGFloat = 20.0
    fileprivate let listCellIdentifier = "CardTemplateCell"
    fileprivate let gridListCellIdentifier = "CardTemplateListCell"
    
    var arrayOfElements = [Cards]()
    let yourAttributes : [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.font : UIFont(name: mediumCustomFont, size: 15.0) as Any,
        NSAttributedString.Key.foregroundColor : UIColor.blue,
        NSAttributedString.Key.underlineStyle : NSUnderlineStyle.single.rawValue]
    
    //public var optionsAction: ((_ text: String?, _ payload: String?) -> Void)!
    //public var linkAction: ((_ text: String?) -> Void)!
    var arrayOfExpandViews = NSMutableArray()
    var arrayOfCollapse = NSMutableArray()
    
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
    
    let tableviewCellHeight = 40.0
    let tableviewGridCellHeight = 55.0
    let tableviewHeaderHeight = 65.0
    let tableviewFooterHeight = 45.0
    
    override func initialize() {
        super.initialize()
        intializeCardLayout()
        
        if #available(iOS 13.0, *) {
            self.tableView = UITableView(frame: CGRect.zero,style:.grouped) //grouped
        } else {
            // Fallback on earlier versions
            self.tableView = UITableView(frame: CGRect.zero,style:.plain)
        }
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
        self.tableView.register(UINib(nibName: gridListCellIdentifier, bundle: bundle), forCellReuseIdentifier: gridListCellIdentifier)
        
        self.tableView.layer.cornerRadius = 2.0
        self.tableView.clipsToBounds = true
        self.tableView.layer.masksToBounds = false
        self.tableView.layer.shadowColor = UIColor.lightGray.cgColor
        self.tableView.layer.shadowOffset =  CGSize.zero
        self.tableView.layer.shadowOpacity = 0.3
        self.tableView.layer.shadowRadius = 4
        self.tableView.layer.shadowOffset = CGSize(width: 0 , height:1)
        
        
        let views: [String: UIView] = ["tableView": tableView]
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[tableView]-0-|", options: [], metrics: nil, views: views))
        
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[tableView]-0-|", options: [], metrics: nil, views: views))
        
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
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

    override func populateComponents() {
        if (components.count > 0) {
            let component: KREComponent = components.firstObject as! KREComponent
            if (component.componentDesc != nil) {
                let jsonString = component.componentDesc
                let jsonObject: NSDictionary = Utilities.jsonObjectFromString(jsonString: jsonString!) as! NSDictionary
                let jsonDecoder = JSONDecoder()
                guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject["cards"] as Any , options: .prettyPrinted),
                    let allItems = try? jsonDecoder.decode([Cards].self, from: jsonData) else {
                        return
                }
                arrayOfElements = []
                arrayOfElements = allItems
                ConfigureDropDownView()
                tableView.reloadData()
            }
        }
    }
    override var intrinsicContentSize : CGSize {
        var  cellHeight = 0.0
        var  headerHeight = 0.0
        var footerHeight = 0.0
        
        for i in 0..<arrayOfElements.count{
            let elements = arrayOfElements[i]
            if let cardType = elements.cardType, cardType == "list" {
                if let cardlistData = elements.cardDescription, cardlistData.count > 0{
                    cellHeight += tableviewGridCellHeight
                }
            }else{
                for _ in 0..<(elements.cardDescription?.count ?? 0){
                    cellHeight += tableviewCellHeight
                }
            }
            
            let headerDetails = elements.cardHeading
            if headerDetails?.desc == nil{
                headerHeight += tableviewHeaderHeight - 10
            }else{
                headerHeight += tableviewHeaderHeight
            }
            
            if let footerBtns = elements.buttons, footerBtns.count > 0 {
                footerHeight += tableviewFooterHeight
            }
        }
        //let cellHeigtht = 150 * arrayOfElements.count
        return CGSize(width: 0.0, height: CGFloat(cellHeight + headerHeight + footerHeight))
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    @objc fileprivate func headerOptionsBtnAction(_ sender: UIButton!) {
        
    }

}
extension CardTemplateBubbleView: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let elements = arrayOfElements[indexPath.section]
        if let cardType = elements.cardType, cardType == "list" {
            if let cardlistData = elements.cardDescription, cardlistData.count > 0{
                return tableviewGridCellHeight
            }else{
                return 0
            }
        }else{
            return tableviewCellHeight
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return  arrayOfElements.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let elements = arrayOfElements[section]
        if let cardType = elements.cardType, cardType == "list" {
            if let cardlistData = elements.cardDescription, cardlistData.count > 0{
                return 1
            }else{
                return 0
            }
        }else{
            return elements.cardDescription?.count ?? 0
        }
        
    }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let elements = arrayOfElements[indexPath.section]
        let cards = elements.cardDescription?[indexPath.row]
        if let cardType = elements.cardType, cardType == "list" {
            let cell : CardTemplateListCell = tableView.dequeueReusableCell(withIdentifier: gridListCellIdentifier) as! CardTemplateListCell
            cell.backgroundColor = UIColor.clear
            cell.selectionStyle = .none
            if let cardlistData = elements.cardDescription, cardlistData.count > 0{
                cell.configure(with: cardlistData)
            }
            if #available(iOS 11.0, *) {
                if let footerBtns = elements.buttons, footerBtns.count > 0 {
                    cell.collV.roundCorners([.layerMaxXMaxYCorner, .layerMinXMaxYCorner], radius: 0.0, borderColor: UIColor.clear, borderWidth: 1.0)
                }else{
                    cell.collV.roundCorners([.layerMaxXMaxYCorner, .layerMinXMaxYCorner], radius: 10.0, borderColor: UIColor.clear, borderWidth: 1.0)
                }
                
            }
            cell.veriticalLblWidthConstaint.constant = 0.0
            if let cardStyles = elements.cardStyles{
                if let bgColor = cardStyles.background_color{
                    cell.collV.backgroundColor = UIColor(hexString: bgColor)
                    if let border = cardStyles.border_left{
                        let array = border.components(separatedBy: " ")
                        if array.count > 2{
                            let bordercolor = array.last!
                            cell.veriticalLblWidthConstaint.constant = 5.0
                            cell.verticalLbl.backgroundColor = UIColor(hexString: bordercolor)
                            if #available(iOS 11.0, *) {
                                cell.verticalLbl.roundCorners([.layerMinXMaxYCorner], radius: 5.0, borderColor: UIColor.clear, borderWidth: 0.0)
                            }
                        }
                    }
                }
            }
            
            return cell
        }else{
            let cell : CardTemplateCell = tableView.dequeueReusableCell(withIdentifier: listCellIdentifier) as! CardTemplateCell
            cell.backgroundColor = UIColor.clear
            cell.selectionStyle = .none
            
            cell.titleLbl.text = cards?.title
            if let iconImg = cards?.icon{
                if iconImg.contains("base64"){
                    let image = Utilities.base64ToImage(base64String: iconImg)
                    cell.imagV.image = image
                }else{
                    if let url = URL(string: iconImg){
                        cell.imagV.af.setImage(withURL: url, placeholderImage: UIImage.init(named: "placeholder_image", in: bundle, compatibleWith: nil))
                    }
                }
            }
            
            let cardContentStyle = elements.cardContentStyles
            cell.bgV.backgroundColor = UIColor.init(hexString: "#ffffff")
            if let bgColor = cardContentStyle?.background_color{
                cell.bgV.backgroundColor = UIColor.init(hexString: bgColor)
            }
            
            cell.underlineLbl.backgroundColor = .clear
            cell.leftLineLbl.backgroundColor = .clear
            cell.rightLineLbl.backgroundColor = .clear
            cell.underlineLbl.isHidden = true
            cell.bgV.clipsToBounds = false
            
            if #available(iOS 11.0, *) {
                cell.bgV.roundCorners([], radius: 0.0, borderColor: .clear, borderWidth: 1.0)
                cell.bgV.clipsToBounds = true
            }
            
            let lastRowIndex =  (elements.cardDescription?.count ?? 0) - 1
            if let border = cardContentStyle?.border{
                let array = border.components(separatedBy: " ")
                var bordercolor = "#0D6EFD"
                if array.count > 2{
                    bordercolor = array.last!
                }
                cell.underlineLbl.backgroundColor = UIColor(hexString: bordercolor)
                cell.leftLineLbl.backgroundColor = UIColor(hexString: bordercolor)
                cell.rightLineLbl.backgroundColor = UIColor(hexString: bordercolor)
                
                if (indexPath.row == lastRowIndex) {
                    if #available(iOS 11.0, *) {
                        cell.bgV.roundCorners([.layerMinXMaxYCorner, .layerMaxXMaxYCorner], radius: 2.0, borderColor: .clear, borderWidth: 1.0)
                        cell.bgV.clipsToBounds = true
                    }
                    cell.underlineLbl.isHidden = false
                }
            }else{
                if (indexPath.row == lastRowIndex) {
                    if #available(iOS 11.0, *) {
                        cell.bgV.roundCorners([.layerMinXMaxYCorner, .layerMaxXMaxYCorner], radius: 10.0, borderColor: .clear, borderWidth: 1.0)
                        cell.bgV.clipsToBounds = true
                    }
                }
            }
            
           
            
            
            return cell
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let elements = arrayOfElements[section]
        let headerDetails = elements.cardHeading
        if headerDetails?.desc == nil{
            return tableviewHeaderHeight - 10
        }else{
            return tableviewHeaderHeight
        }
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let elements = arrayOfElements[section]
        let headerDetails = elements.cardHeading
        let  headerStyles = headerDetails?.headerStyles
        let bgColor = headerStyles?.background_color ?? "#0D6EFD"
        let textColor = headerStyles?.colorr ?? "#000000"
        let fontWeight = headerStyles?.font_weight ?? "Medium"
        if headerDetails?.desc == nil{
            let headerView = UIView()
            
            let subView = UIView()
            subView.backgroundColor = .clear
            subView.translatesAutoresizingMaskIntoConstraints = false
            subView.layer.cornerRadius = 5.0
            subView.clipsToBounds = true
            headerView.addSubview(subView)
            
            let headerLabel = UILabel(frame: .zero)
            headerLabel.translatesAutoresizingMaskIntoConstraints = false
            headerLabel.textAlignment = .left
            if fontWeight == "bold"{
                headerLabel.font = UIFont.boldSystemFont(ofSize: 15.0)
            }else{
                headerLabel.font = headerLabel.font.withSize(15.0)
            }
            
            headerLabel.textColor = .black
            headerLabel.text = headerDetails?.title
            subView.addSubview(headerLabel)
            if #available(iOS 11.0, *) {
                if let borderr = headerStyles?.border{
                    let array = borderr.components(separatedBy: " ")
                    var bordercolor = "#0D6EFD"
                    if array.count > 2{
                        bordercolor = array.last!
                    }
                    
                    subView.roundCorners([.layerMaxXMinYCorner, .layerMinXMinYCorner], radius: 10.0, borderColor: UIColor(hexString: bordercolor), borderWidth: 1.0)
                }else{
                    subView.roundCorners([.layerMaxXMinYCorner, .layerMinXMinYCorner], radius: 10.0, borderColor: UIColor.clear, borderWidth: 1.0)
                }
            }
            headerLabel.textColor = UIColor(hexString: textColor)
            subView.backgroundColor  = UIColor(hexString: bgColor)
            
            
            let views: [String: UIView] = ["headerLabel": headerLabel]
            subView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[headerLabel]", options:[], metrics:nil, views:views))
            subView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-5-[headerLabel]-5-|", options:[], metrics:nil, views:views))
            
            let subViews: [String: UIView] = ["subView": subView]
            headerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[subView]-0-|", options:[], metrics:nil, views:subViews))
            headerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-8-[subView]-0-|", options:[], metrics:nil, views:subViews))
            
            return headerView
        
        }else{
            let headerView = UIView()
            
            let cardHView  = CardTemplateHedaderView()
            //cardHView.frame = CGRect(x: 0, y: 5, width: tableView.frame.width, height: 60)
            cardHView.translatesAutoresizingMaskIntoConstraints = false
            cardHView.titleLabel.text = headerDetails?.title
            cardHView.subTilteLabel.text = headerDetails?.desc
            headerView.addSubview(cardHView)
            
            cardHView.titleLabel.textColor = BubbleViewBotChatTextColor
            cardHView.backgroundColor  = UIColor(hexString: bgColor)
            
            cardHView.imagVHeightConstraint.constant = 0.0
            cardHView.imagVWidthConstraint.constant = 0.0
            cardHView.verticalLblWidthConstraint.constant = 0.0
            cardHView.verticalLblLeadingConstraint.constant = 0.0
            
            if let cardContentStyles = elements.cardContentStyles{
                if let verticalLblColor =  cardContentStyles.border_left{
                    let array = verticalLblColor.components(separatedBy: " ")
                    if array.count > 2{
                        cardHView.verticalLblWidthConstraint.constant = 4.0
                        cardHView.verticalLblLeadingConstraint.constant = 8.0
                        if #available(iOS 11.0, *) {
                            cardHView.verticalLabel.roundCorners([.layerMinXMaxYCorner, .layerMinXMinYCorner], radius: 5.0, borderColor: UIColor.clear, borderWidth: 0.0)
                        }
                        cardHView.verticalLabel.clipsToBounds = true
                        cardHView.verticalLabel.backgroundColor =  UIColor.init(hexString: array.last!)
                    }
                }
            }
            
            cardHView.cardVerLbl.isHidden = true
            cardHView.cardBoaderTopLbl.isHidden = true
            if let cardStyles = elements.cardStyles{
                if let bgColor = cardStyles.background_color{
                    cardHView.bgV.backgroundColor = UIColor(hexString: bgColor)
                    if let border = cardStyles.border_left{
                        let array = border.components(separatedBy: " ")
                        if array.count > 2{
                            cardHView.cardVerLbl.isHidden = false
                            cardHView.verticalLblLeadingConstraint.constant = 8.0 //verticalLabel Leading
                            let bordercolor = array.last!
                            cardHView.cardVerLbl.backgroundColor = UIColor(hexString: bordercolor)
                            if #available(iOS 11.0, *) {
                                cardHView.cardVerLbl.roundCorners([.layerMinXMinYCorner], radius: 5.0, borderColor: UIColor.clear, borderWidth: 0.0)
                            }
                        }
                    }
                    
                    if let border = cardStyles.border_top{
                        let array = border.components(separatedBy: " ")
                        if array.count > 2{
                            cardHView.cardBoaderTopLbl.isHidden = false
                            let bordercolor = array.last!
                            cardHView.cardBoaderTopLbl.backgroundColor = UIColor(hexString: bordercolor)
                            if #available(iOS 11.0, *) {
                                cardHView.cardBoaderTopLbl.roundCorners([.layerMaxXMinYCorner, .layerMinXMinYCorner], radius: 5.0, borderColor: UIColor.clear, borderWidth: 0.0)
                            }
                        }
                    }
                }
            }
            
            if let descIcon = headerDetails?.icon{
                let iconsize = headerDetails?.iconSize ?? "medium"
                if iconsize == "large"{
                    cardHView.imagVHeightConstraint.constant = 50.0
                    cardHView.imagVWidthConstraint.constant = 50.0
                    
                    if let iconShape = headerDetails?.iconShape, iconShape == "circle-img"{
                        cardHView.imagView.layer.cornerRadius = 25.0
                    }
                }else if iconsize == "medium"{
                    cardHView.imagVHeightConstraint.constant = 30.0
                    cardHView.imagVWidthConstraint.constant = 30.0
                    if let iconShape = headerDetails?.iconShape, iconShape == "circle-img"{
                        cardHView.imagView.layer.cornerRadius = 15.0
                    }
                }else if iconsize == "small"{
                    cardHView.imagVHeightConstraint.constant = 20.0
                    cardHView.imagVWidthConstraint.constant = 20.0
                    if let iconShape = headerDetails?.iconShape, iconShape == "circle-img"{
                        cardHView.imagView.layer.cornerRadius = 10.0
                    }
                }
                
                if descIcon.contains("base64"){
                    let image = Utilities.base64ToImage(base64String: descIcon)
                    cardHView.imagView.image = image
                }else{
                    if let url = URL(string: descIcon){
                        cardHView.imagView.af.setImage(withURL: url, placeholderImage: UIImage.init(named: "placeholder_image", in: bundle, compatibleWith: nil))
                    }
                }
            }
            cardHView.btnWidthConstraint.constant = 0.0
            cardHView.dropDownBtnWidthConstraint.constant = 0.0
            
            if let headerExtraInfo = headerDetails?.headerExtraInfo{
                if let headerExtraInfotitle = headerExtraInfo.title{
                    let tagBtnText = " \(headerExtraInfotitle) "
                    let btnFont = UIFont.systemFont(ofSize: 14)
                    let size = tagBtnText.size(withAttributes:[.font: btnFont])
                    cardHView.btnWidthConstraint.constant = (size.width)
                    cardHView.btn.setTitle(headerExtraInfotitle, for: .normal)
                    cardHView.btn.setTitleColor(.lightGray, for: .normal)
                    cardHView.btn.backgroundColor = .clear
                }
                if let headerExtraInfotitle = headerExtraInfo.icon{
                    cardHView.dropDownBtnWidthConstraint.constant = 30.0
                    var tintedMenuImage = UIImage()
                    if headerExtraInfotitle.contains("/svg"){
                        let imgV = UIImage.init(named: "VDotMenu", in: bundle, compatibleWith: nil)
                        tintedMenuImage = (imgV?.withRenderingMode(.alwaysTemplate))!
                    }else{
                        let image = Utilities.base64ToImage(base64String: headerExtraInfotitle)
                        let imgV = image
                         tintedMenuImage = imgV.withRenderingMode(.alwaysTemplate)
                    }
                    cardHView.dropDownBtn.setImage(tintedMenuImage, for: .normal)
                    cardHView.dropDownBtn.tintColor = .black
                    cardHView.dropDownBtn.isUserInteractionEnabled = true
                    cardHView.dropDownBtn.addTarget(self, action: #selector(self.headerDropDownBtnAction(_:)), for: .touchUpInside)
                    cardHView.dropDownBtn.tag = section
                }
                    
            }
            
            
            let subViews: [String: UIView] = ["cardHView": cardHView]
            headerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[cardHView]-0-|", options:[], metrics:nil, views:subViews))
            headerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-8-[cardHView]-0-|", options:[], metrics:nil, views:subViews))
            
            
             var bordercolor = ""
            if #available(iOS 11.0, *) {
                cardHView.clipsToBounds = true
                if let borderr = headerStyles?.border{
                    let array = borderr.components(separatedBy: " ")
                    if array.count > 2{
                        bordercolor = array.last!
                    }
                }
                
                //Corner Radiun Setting
                if let cardType = elements.cardType, cardType == "list" {
                    if  elements.cardDescription?.count ?? 0 > 0{
                        if bordercolor == ""{
                            cardHView.roundCorners([.layerMaxXMinYCorner, .layerMinXMinYCorner], radius: 10.0, borderColor: UIColor.clear, borderWidth: 1.0)
                        }else{
                            cardHView.roundCorners([.layerMaxXMinYCorner, .layerMinXMinYCorner], radius: 10.0, borderColor: UIColor(hexString: bordercolor), borderWidth: 1.0)
                        }
                       
                    }else{
                        if bordercolor == ""{
                            cardHView.roundCorners([.layerMaxXMinYCorner, .layerMinXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMaxYCorner], radius: 10.0, borderColor: UIColor.clear, borderWidth: 1.0)
                        }else{
                            cardHView.roundCorners([.layerMaxXMinYCorner, .layerMinXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMaxYCorner], radius: 10.0, borderColor: UIColor(hexString: bordercolor), borderWidth: 1.0)
                        }
                        
                    }
                }else{
                    if  elements.cardDescription?.count ?? 0 > 0{
                        if bordercolor == ""{
                            cardHView.roundCorners([.layerMaxXMinYCorner, .layerMinXMinYCorner], radius: 10.0, borderColor: UIColor.clear, borderWidth: 1.0)
                        }else{
                            cardHView.roundCorners([.layerMaxXMinYCorner, .layerMinXMinYCorner], radius: 10.0, borderColor: UIColor(hexString: bordercolor), borderWidth: 1.0)
                        }
                    }else{
                        if bordercolor == ""{
                            cardHView.roundCorners([.layerMaxXMinYCorner, .layerMinXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMaxYCorner], radius: 10.0, borderColor: UIColor.clear, borderWidth: 1.0)
                        }else{
                            cardHView.roundCorners([.layerMaxXMinYCorner, .layerMinXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMaxYCorner], radius: 10.0, borderColor: UIColor(hexString: bordercolor), borderWidth: 1.0)
                        }
                        
                    }
                }
            }
            
            return headerView
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let elements = arrayOfElements[section]
        if let footerBtns = elements.buttons, footerBtns.count > 0 {
            return tableviewFooterHeight
        }else{
            return 0
        }
        
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        let footerBtn = UIButton(frame: CGRect.zero)
        footerBtn.backgroundColor = .clear
        footerBtn.translatesAutoresizingMaskIntoConstraints = false
        footerBtn.clipsToBounds = true
        footerBtn.layer.cornerRadius = 5
        footerBtn.setTitleColor(.blue, for: .normal)
        footerBtn.setTitleColor(Common.UIColorRGB(0x999999), for: .disabled)
        footerBtn.titleLabel?.font = UIFont(name: mediumCustomFont, size: 15.0)
        view.addSubview(footerBtn)
        footerBtn.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.center
        footerBtn.addTarget(self, action: #selector(self.footerButtonAction(_:)), for: .touchUpInside)
        footerBtn.tag = section
        
        if #available(iOS 11.0, *) {
            footerBtn.roundCorners([.layerMinXMaxYCorner, .layerMaxXMaxYCorner], radius: 10.0, borderColor: .clear, borderWidth: 1.0)
            footerBtn.clipsToBounds = true
        }
        let elements = arrayOfElements[section]
        if let footerBtns = elements.buttons, footerBtns.count > 0 {
            let btns = footerBtns[0]
            let btnTitle: String = btns.title ?? "Confirm"
            footerBtn.setTitle(btnTitle, for: .normal)
            footerBtn.setTitleColor(.black, for: .normal)
            if let buttonContentStyles = btns.buttonStyles{
                footerBtn.setTitleColor(UIColor.init(hexString: buttonContentStyles.colorr ?? "#fff"), for: .normal)
                footerBtn.backgroundColor = UIColor.init(hexString: buttonContentStyles.background_color ?? "#0D6EFD")
                if let borderr = buttonContentStyles.border{
                    let array = borderr.components(separatedBy: " ")
                    var bordercolor = "#0D6EFD"
                    if array.count > 2{
                        bordercolor = array.last!
                        footerBtn.layer.borderColor = UIColor.init(hexString: bordercolor).cgColor
                        footerBtn.layer.borderWidth = 1.0
                        footerBtn.clipsToBounds = true
                    }
                }
                
            }
        }
            let views: [String: UIView] = ["footerBtn": footerBtn]
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-2-[footerBtn]-0-|", options:[], metrics:nil, views:views))
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[footerBtn]-0-|", options:[], metrics:nil, views:views))
            return view
        }
        
    @objc fileprivate func footerButtonAction(_ sender: AnyObject!) {
        let elements = arrayOfElements[sender.tag]
        if let footerBtns = elements.buttons, footerBtns.count > 0 {
            let btns = footerBtns[0]
            if btns.type == "postback"{
                self.optionsAction?(btns.title, btns.payload ?? btns.title)
            }else if btns.type == "url"{
                self.linkAction?(btns.linkurl)
            }
            
        }
    }
    @objc fileprivate func headerDropDownBtnAction(_ sender: AnyObject!) {
        let elements = arrayOfElements[sender.tag]
        let headerDetails = elements.cardHeading
        if let dropDownOptions = headerDetails?.headerExtraInfo?.dropdownOptions, dropDownOptions.count > 0{
            let indexPath = NSIndexPath(row: 0, section: sender.tag)
            let cell = tableView.cellForRow(at: indexPath as IndexPath)
            setupDropDown(with: dropDownOptions, dropDownPosition: Float(cell?.frame.origin.y ?? 0.0))
            colorDropDown.show()
        }
       
    }
}
extension CardTemplateBubbleView{
    func ConfigureDropDownView(){
        //DropDown
        dropDowns.forEach { $0.dismissMode = .onTap }
        dropDowns.forEach { $0.direction = .any }
        
        colorDropDown.backgroundColor = UIColor(white: 1, alpha: 1)
        colorDropDown.selectionBackgroundColor = .clear//UIColor(red: 0.6494, green: 0.8155, blue: 1.0, alpha: 0.2)
        colorDropDown.separatorColor = UIColor(white: 0.7, alpha: 0.8)
        colorDropDown.cornerRadius = 10
        colorDropDown.shadowColor = UIColor(white: 0.6, alpha: 1)
        colorDropDown.shadowOpacity = 0.9
        colorDropDown.shadowRadius = 25
        colorDropDown.animationduration = 0.25
        colorDropDown.textColor = .darkGray
        
    }
    // MARK: Setup DropDown
    func setupDropDown(with dropDownArray: [DropdownOptions], dropDownPosition: Float) {
        colorDropDown.anchorView = tableView
        let titles = NSMutableArray()
        let payload = NSMutableArray()
        let type = NSMutableArray()
        for i in 0..<dropDownArray.count{
            let dropDownDetails = dropDownArray[i]
            titles.add(dropDownDetails.title ?? "")
            payload.add(dropDownDetails.payload ?? dropDownDetails.title ?? "")
            type.add(dropDownDetails.type ?? "")
        }
        colorDropDown.bottomOffset = CGPoint(x: Int(200), y: Int(dropDownPosition - 30))
        colorDropDown.dataSource = titles as! [String]
        colorDropDown.reloadInputViews()
        colorDropDown.reloadAllComponents()
        colorDropDown.reloadAllData()
        
        //colorDropDown.selectRow(0)
        // Action triggered on selection
        colorDropDown.selectionAction = { (index, item) in
            //if let type = type[index] as? String, type == "postback"{
                self.optionsAction?(titles[index] as? String, payload[index] as? String )
//            }else{
//                //self.linkAction()
//            }
        }
        
    }
    
}
