//
//  ListWidgetNewBubbleView.swift
//  KoreBotSDK
//
//  Created by Pagidimarri Kartheek on 13/05/25.
//

import UIKit
#if SWIFT_PACKAGE
import ObjcSupport
#endif
class ListWidgetNewBubbleView: BubbleView {

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
    public var maskview: UIView!
    fileprivate let listCellIdentifier = "ListwidgetCell"
    var arrayOfElements = [ListWidgetElements]()
    
    let tableHeaderHeight = 60.0
    let tableFooterHeight = 40.0
    var footercollectionView: UICollectionView!
    var isCollapsedArray = [String]()
    let tickMarkText = "✓ "
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
        cardView.layer.borderColor = UIColor.init(hexString: templateBoarderColor).cgColor
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
        
        let subView: [String: UIView] = ["headerTitle": headerTitle, "headerDesc": headerDesc]
        self.tileBgv.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[headerTitle(>=21)]-0-[headerDesc(>=21)]-0-|", options: [], metrics: nil, views: subView))
        self.tileBgv.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-8-[headerTitle]-8-|", options: [], metrics: nil, views: subView))
        self.tileBgv.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-8-[headerDesc]-8-|", options: [], metrics: nil, views: subView))
        
    }
    
    override func populateComponents() {
        if (components.count > 0) {
            let component: KREComponent = components.firstObject as! KREComponent
            if (component.componentDesc != nil) {
                let jsonString = component.componentDesc
                let jsonObject: NSDictionary = Utilities.jsonObjectFromString(jsonString: jsonString!) as! NSDictionary
                let jsonDecoder = JSONDecoder()
                guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject["elements"] as Any , options: .prettyPrinted),
                    let allItems = try? jsonDecoder.decode([ListWidgetElements].self, from: jsonData) else {
                        return
                }
                arrayOfElements = allItems ?? []
                headerTitle.text = jsonObject["title"] as? String
                headerDesc.text = jsonObject["description"] as? String
                if isCollapsedArray.count == 0{
                    isCollapsedArray = []
                    for i in 0..<arrayOfElements.count{
                        let element = arrayOfElements[i]
                        if let btnsLayout = element.buttonsLayout{
                            if let style = btnsLayout.style{
                                if style == "float" || style == "fitToWidth"{
                                    if let elementsDetails = element.elementDetails, elementsDetails.count > 0{
                                        isCollapsedArray.append("Collapse")
                                    }else{
                                        isCollapsedArray.append("Expand")
                                    }
                                }else{
                                    isCollapsedArray.append("Collapse")
                                }
                            }else{
                                isCollapsedArray.append("Collapse")
                            }
                            
                        }else{
                            isCollapsedArray.append("Collapse")
                        }
                    }
                }
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
        
        var footerViewHeight = 0.0
        var HederViewHeight = 0.0
        var tableViewCellsHeight = 0.0
        for i in 0..<arrayOfElements.count{
            let element = arrayOfElements[i]
            if let cellsHeight = element.elementDetails?.count{
                tableViewCellsHeight += Double(Int(cellsHeight * 44))
            }
            let btnStyle = element.buttonsLayout?.style
            HederViewHeight += tableHeaderHeight
                if btnStyle == "fitToWidth"{ //Verticle CollectionV
                    if isCollapsedArray[i] == "Expand"{
                        if let btnscount = element.buttons?.count{
                            footerViewHeight += tableFooterHeight*Double(btnscount)
                        }
                      }else if isCollapsedArray[i] == "Collapse"{
                          footerViewHeight += 0.0
                    }
                }else if btnStyle == "float"{ // Horizontal CollectionV
                    if isCollapsedArray[i] == "Expand"{
                        if let btnscount = element.buttons?.count{
                            footerViewHeight += tableFooterHeight
                        }
                    }else if isCollapsedArray[i] == "Collapse"{
                        footerViewHeight += 0.0
                    }
                }
        }
       
        let verticalSpace = 30.0
        return CGSize(width: 0.0, height: headerTitleSize.height+headerDescSize.height+tableViewCellsHeight+footerViewHeight+HederViewHeight+verticalSpace)
    }
    
    @objc fileprivate func headerPopUpBtnAction(_ sender: UIButton!) {
        let elementDetails = arrayOfElements[sender.tag]
        if let optionsValue = elementDetails.elementValue{
            let optionsType = optionsValue.type
            if optionsType == "menu"{
                let cell = tableView.cellForRow(at: IndexPath(row: 0, section: sender.tag))
                setupDropDown(with: optionsValue.menu ?? [], dropDownPosition:  198.0, dropDownXPosition:  200.0)
                colorDropDown.show()
            }
        }
    }

    @objc fileprivate func dropDownBtnAction(_ sender: UIButton!) {
        if isCollapsedArray[sender.tag] == "Expand"{
            isCollapsedArray[sender.tag] = "Collapse"
        }else{
            isCollapsedArray[sender.tag] = "Expand"
        }
        NotificationCenter.default.post(name: Notification.Name(reloadTableNotification), object: nil)
    }
    
}

extension ListWidgetNewBubbleView: UITableViewDelegate, UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return arrayOfElements.count
    }
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let details = arrayOfElements[section].elementDetails
        return details?.count ?? 0
    }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell : ListwidgetCell = tableView.dequeueReusableCell(withIdentifier: listCellIdentifier) as! ListwidgetCell
            cell.backgroundColor = UIColor.clear
            cell.selectionStyle = .none
            let element = arrayOfElements[indexPath.section]
            let details = element.elementDetails
            cell.titleLbl.text = details?[indexPath.row].descr
            if let iconImg = details?[indexPath.row].elementImage?.image_src{
            if iconImg.contains("base64"){
                let image = Utilities.base64ToImage(base64String: iconImg)
                cell.imageV.image = image
                cell.imageV.isHidden = false
            }else{
                if let url = URL(string: iconImg){
                    cell.imageV.af.setImage(withURL: url, placeholderImage: UIImage.init(named: "placeholder_image", in: bundle, compatibleWith: nil))
                    cell.imageV.isHidden = false
                }
            }
                cell.arrowBtn.isHidden = true
                cell.arrowBtn.addTarget(self, action: #selector(self.dropDownBtnAction(_:)), for: .touchUpInside)
                cell.arrowBtn.tag = indexPath.section
                if indexPath.row == ((details?.count ?? 0) - 1){
                    if let btnStyle = element.buttonsLayout?.style{
                        if btnStyle == "fitToWidth"{
                            cell.arrowBtn.isHidden = false
                            if isCollapsedArray[indexPath.section] == "Collapse"{
                                let menuImage = UIImage(named: "cheveron-right", in: bundle, compatibleWith: nil)
                                let tintedMenuImage = menuImage?.withRenderingMode(.alwaysTemplate)
                                cell.arrowBtn.setImage(tintedMenuImage, for: .normal)
                                cell.arrowBtn.tintColor = .black
                                
                            }else{
                                let menuImage = UIImage(named: "cheveron-Down", in: bundle, compatibleWith: nil)
                                let tintedMenuImage = menuImage?.withRenderingMode(.alwaysTemplate)
                                cell.arrowBtn.setImage(tintedMenuImage, for: .normal)
                                cell.arrowBtn.tintColor = .black
                            }
                        }
                    }
                }
        }
            return cell
    }
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let element = arrayOfElements[section]
        let btnStyle = element.buttonsLayout?.style
        if btnStyle == "fitToWidth"{
            if isCollapsedArray[section] == "Expand"{
                var footerViewHeight = 0.0
                if let btnsCount = element.buttons?.count{
                    footerViewHeight += tableFooterHeight*Double(btnsCount)
                }
                return footerViewHeight
              }else if isCollapsedArray[section] == "Collapse"{
                return 0
            }
        }else if btnStyle == "float"{
            if isCollapsedArray[section] == "Expand"{
                return tableFooterHeight
            }else if isCollapsedArray[section] == "Collapse"{
                return 0
            }
        }
        return 0
    }
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let elementDetails = arrayOfElements[section]
        let btnStyle = elementDetails.buttonsLayout?.style
        if btnStyle == "float"{
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
            footercollectionView.semanticContentAttribute = .forceLeftToRight
            footercollectionView.reloadData()
            let footerunderline = UILabel(frame: CGRect.zero)
            footerunderline.backgroundColor = .lightGray
            footerunderline.isUserInteractionEnabled = true
            footerunderline.translatesAutoresizingMaskIntoConstraints = false
            footerunderline.isHidden = true
            footerView.addSubview(footerunderline)
            
            
            let views: [String: UIView] = ["footercollectionView": footercollectionView, "footerunderline": footerunderline]
            footerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[footercollectionView]-3-[footerunderline(1)]-0-|", options:[], metrics:nil, views:views))
            footerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[footercollectionView]-0-|", options:[], metrics:nil, views:views))
            footerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[footerunderline]-0-|", options:[], metrics:nil, views:views))
            return footerView
        }else if btnStyle == "fitToWidth"{
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
            footercollectionView.reloadData()
            footercollectionView.register(UINib(nibName: "AdvancedListBtnCell", bundle: bundle),
                                         forCellWithReuseIdentifier: "AdvancedListBtnCell")
            let elementDetails = arrayOfElements[section]
        
            footercollectionView.semanticContentAttribute = .forceLeftToRight
            let footerunderline = UILabel(frame: CGRect.zero)
            footerunderline.backgroundColor = .lightGray
            footerunderline.isUserInteractionEnabled = true
            footerunderline.translatesAutoresizingMaskIntoConstraints = false
            footerunderline.isHidden = true
            footerView.addSubview(footerunderline)
            
            let views: [String: UIView] = ["footercollectionView": footercollectionView, "footerunderline": footerunderline]
            footerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[footercollectionView]-3-[footerunderline(1)]-0-|", options:[], metrics:nil, views:views))
            footerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[footercollectionView]-0-|", options:[], metrics:nil, views:views))
            footerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[footerunderline]-0-|", options:[], metrics:nil, views:views))
            return footerView
        }else{
            return UIView()
        }
    }
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return tableHeaderHeight
    }
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView  = AdvancedListHeaderView()
        headerView.tag = section
        let headerDetails = arrayOfElements[section]
        headerView.titleLabel.text = headerDetails.title
        headerView.subTilteLabel.text = headerDetails.subtitle
        headerView.titleLabel.textColor = BubbleViewBotChatTextColor
        headerView.subTilteLabel.textColor = BubbleViewBotChatTextColor
        if let descIcon = headerDetails.icon{
            headerView.imagView.clipsToBounds = true
            headerView.imagVHeightConstraint.constant = 50.0
            headerView.imagVWidthConstraint.constant = 50.0
            
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
        headerView.btn.contentHorizontalAlignment = .left
        if let headerOptions = headerDetails.elementValue{
            let optionsType = headerOptions.type
            if optionsType == "text"{
                headerView.btnWidthConstraint.constant = 70.0
                headerView.btn.setTitle(headerOptions.text, for: .normal)
                headerView.btn.backgroundColor = .clear
                headerView.btn.setTitleColor(BubbleViewBotChatTextColor, for: .normal)
                headerView.btn.layer.borderWidth = 0.0
                headerView.btn.tag = section
            }else if optionsType == "menu"{
                headerView.btnWidthConstraint.constant = 70.0
                let sendBtnImage = UIImage(named: "VDotMenu", in: bundle, compatibleWith: nil)
                let tintedsendImage = sendBtnImage?.withRenderingMode(.alwaysTemplate)
                headerView.btn.setImage(tintedsendImage, for: .normal)
                headerView.btn.tintColor = .black
                headerView.btn.backgroundColor = .clear
                headerView.btn.setTitle("", for: .normal)
                headerView.btn.contentHorizontalAlignment = .right
                headerView.btn.addTarget(self, action: #selector(self.headerPopUpBtnAction(_:)), for: .touchUpInside)
                headerView.btn.tag = section
          }
        }
        return headerView
    }
    
}
extension ListWidgetNewBubbleView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let elementDetails = arrayOfElements[collectionView.tag]
        let btnStyle = elementDetails.buttonsLayout?.style
        
        if let displayLimit = Int(elementDetails.buttonsLayout?.displayLimit?.displayCount ?? "0"){
            if displayLimit < elementDetails.buttons?.count ?? 0{
                    return displayLimit + 1
            }else{
                return elementDetails.buttons?.count ?? 0
            }
        }else{
            return elementDetails.buttons?.count ?? 0
        }
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let elementDetails = arrayOfElements[collectionView.tag]
        let btnStyle = elementDetails.buttonsLayout?.style
        if btnStyle == "fitToWidth"{
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AdvancedListBtnCell", for: indexPath) as! AdvancedListBtnCell
                cell.titleBtn.backgroundColor =  UIColor.init(hexString: "e9f1fe")
                cell.titleBtn.layer.cornerRadius = 5.0
                cell.titleBtn.clipsToBounds = true
                cell.titleBtn.setTitleColor(BubbleViewRightTint, for: .normal)
                let buttons =  elementDetails.buttons
                let buttonDetails = buttons?[indexPath.item]
                
                let displayLimit = Int(elementDetails.buttonsLayout?.displayLimit?.displayCount ?? "0") ?? 0
                if displayLimit < elementDetails.buttons?.count ?? 0{
                    if displayLimit == indexPath.item{
                        cell.titleBtn.setTitle("... More", for: .normal)
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
                            cell.titleBtn.setTitle("\(tickMarkText)\(buttonDetails?.title ?? "")", for: .normal)
                        }
                    }
                }else{
                    cell.titleBtn.setTitle("\(tickMarkText)\(buttonDetails?.title ?? "")", for: .normal)
                    if let imageIcon = buttonDetails?.icon{
                        if imageIcon.contains("base64"){
                            let image = Utilities.base64ToImage(base64String: imageIcon)
                            cell.titleBtn.setImage(image, for: .normal)
                        }else{
                            if let url = URL(string: imageIcon){
                                cell.titleBtn.af.setImage(for: .normal, url: url)
                            }
                        }

                        cell.titleBtn.setTitle("\(tickMarkText)\(buttonDetails?.title ?? "")", for: .normal)
                    }
                }
                cell.titleBtn.isUserInteractionEnabled = false
                return cell
            }else{
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ButtonLinkCell", for: indexPath) as! ButtonLinkCell
                cell.backgroundColor = .clear
                cell.bgV.backgroundColor = .clear
                cell.textlabel.font = UIFont(name: regularCustomFont, size: 14.0)
                let buttons =  elementDetails.buttons
                let buttonDetails = buttons?[indexPath.item]
            
                cell.textlabel.textAlignment = .center
                cell.layer.borderWidth = 0
                cell.layer.cornerRadius = 5
                cell.textlabel.textColor = BubbleViewRightTint
                cell.backgroundColor = UIColor.init(hexString: "e9f1fe")
                cell.imagvWidthConstraint.constant = 0.0
                
                let displayLimit = Int(elementDetails.buttonsLayout?.displayLimit?.displayCount ?? "0") ?? 0
                if displayLimit < elementDetails.buttons?.count ?? 0{
                    if displayLimit == indexPath.item{
                        cell.textlabel.text = "... More"
                    }else{
                        cell.textlabel.text = "\(tickMarkText)\(buttonDetails?.title ?? "")"
                    }
                }else{
                    cell.textlabel.text = "\(tickMarkText)\(buttonDetails?.title ?? "")"
                }
                
                return cell
            }
      
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let elementDetails = arrayOfElements[collectionView.tag]
            let  options = elementDetails.buttons?[indexPath.item]
            let displayLimit = Int(elementDetails.buttonsLayout?.displayLimit?.displayCount ?? "0") ?? 0
            if displayLimit < elementDetails.buttons?.count ?? 0{
                if displayLimit == indexPath.item{
                    
                    var buttons = [DropdownOptions]()
                    for i in 0..<(elementDetails.buttons?.count ?? 0){
                        //if i >= displayLimit{
                            buttons.append((elementDetails.buttons?[i])!)
                        //}
                    }
                    if let collectionView = footercollectionView,
                       let tableView = tableView,
                       let cell = collectionView.cellForItem(at: indexPath) {
                        let pointInCollectionView = cell.center
                        let pointInTableView = collectionView.convert(pointInCollectionView, to: cardView)
                        let collectionVFooterHeight = 50.0
                        setupDropDown(with: buttons, dropDownPosition: Float(pointInTableView.y - collectionVFooterHeight), dropDownXPosition: 200.0)
                        colorDropDown.show()
                    }
                }else{
                    if options?.type == "postback"{
                        self.maskview.isHidden = false
                        self.optionsAction?(options?.title, options?.payload)
                    }else if options?.type == "url"{
                            self.linkAction?(options?.headerurl)
                    }
                }
            }else{
                if options?.type == "postback"{
                    self.maskview.isHidden = false
                    self.optionsAction?(options?.title, options?.payload)
                }else if options?.type == "url"{
                    if var urlStr = options?.headerurl{
                        if urlStr.contains("https://"){
                            self.linkAction?(urlStr)
                        }else{
                            self.linkAction?("https://\(urlStr)")
                        }
                        
                    }
                        
                }
            }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let elementDetails = arrayOfElements[collectionView.tag]
        let btnStyle = elementDetails.buttonsLayout?.style
        if btnStyle == "fitToWidth"{
            return CGSize(width: collectionView.frame.size.width - 20.0 , height: 40)
        }else{
            var text:String?
            let buttons =  elementDetails.buttons
            let buttonDetails = buttons?[indexPath.item]
            if let displayLimit = Int(elementDetails.buttonsLayout?.displayLimit?.displayCount ?? "0"){
                if displayLimit < elementDetails.buttons?.count ?? 0{
                    text = "... More"
                }else{
                    text = "\(tickMarkText)\(buttonDetails?.title ?? "")"
                }
            }else{
                text = "\(tickMarkText)\(buttonDetails?.title ?? "")"
            }
            
            var textWidth = 10
            let size = text?.size(withAttributes:[.font: UIFont(name: regularCustomFont, size: 14.0) as Any])
            if text != nil {
                textWidth = Int(size!.width)
            }
            return CGSize(width:textWidth + 50 , height: 40)
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
        let elementDetails = arrayOfElements[collectionView.tag]
        let btnStyle = elementDetails.buttonsLayout?.style
        if btnStyle == "fitToWidth"{
            return 0.0
        }else{
            return 10.0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }
}
extension ListWidgetNewBubbleView{
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
