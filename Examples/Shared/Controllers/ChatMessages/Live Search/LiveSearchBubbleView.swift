//
//  LiveSearchBubbleView.swift
//  KoreBotSDKDemo
//
//  Created by Kartheek.Pagidimarri on 15/10/20.
//  Copyright © 2020 Kore. All rights reserved.
//

import UIKit

class LiveSearchBubbleView: BubbleView {
    var tileBgv: UIView!
    var titleLbl: UILabel!
    var tableView: UITableView!
    var iconImageView: UIImageView!
    var cardView: UIView!
    let kMaxTextWidth: CGFloat = BubbleViewMaxWidth - 20.0
    let kMinTextWidth: CGFloat = 20.0
    fileprivate let liveSearchFaqCellIdentifier = "LiveSearchFaqTableViewCell"
    fileprivate let liveSearchPageCellIdentifier = "LiveSearchPageTableViewCell"
    fileprivate let liveSearchTaskCellIdentifier = "LiveSearchTaskTableViewCell"
    fileprivate let liveSearchNewTaskCellIdentifier = "LiveSearchNewTaskViewCell"
    
    fileprivate let titleWithImageCellIdentifier = "TitleWithImageCell"
    fileprivate let titleWithCenteredContentCellIdentifier = "TitleWithCenteredContentCell"
    fileprivate let TitleWithHeaderCellIdentifier = "TitleWithHeaderCell"
    
    fileprivate let GridTableViewCellIdentifier = "GridTableViewCell"
    
    // var rowsDataLimit = 2
    var isShowMore = false
    
    var reloadTableView = true
    
    let yourAttributes : [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.font : UIFont(name: "HelveticaNeue-Bold", size: 15.0) as Any,
        NSAttributedString.Key.foregroundColor : themeColor]
    
    var arrayOfResults = [TemplateResultElements]()
    var arrayOfFaqResults = [TemplateResultElements]()
    var arrayOfPageResults = [TemplateResultElements]()
    var arrayOfTaskResults = [TemplateResultElements]()
    var headerArray = ["POPULAR SEARCHS","RECENT SEARCHS"]
    var faqsExpandArray:NSMutableArray = []
    var pagesExpandArray:NSMutableArray = []
    var likeAndDislikeArray:NSMutableArray = []
    var headersExpandArray:NSMutableArray = []
    var checkboxIndexPath = [IndexPath]()
    
    let sectionAndRowsLimit:Int = (serachInterfaceItems?.interactionsConfig?.liveSearchResultsLimit)!
    
    let searchFAQsTemplateType = "listTemplate3" //listTemplate1 gridTemplate
    let searchPageTemplateType = "gridTemplate"
    let searchDocumentTemplateType = "listTemplate3"
    
    let faqLayOutType = "tileWithText"
    let pageLayOutType = "tileWithImage"
    let DocumentLayOutType = "tileWithText"
    
    let isFaqsExpand = false
    let isPagesExpand = true
    enum searchTemplateTypes: String{
        case listTemplate1 = "listTemplate1"
        case listTemplate2 = "listTemplate2"
        case listTemplate3 = "listTemplate3"
    }
    
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
        self.tileBgv.backgroundColor = UIColor.init(red: 248/255, green: 249/255, blue: 250/255, alpha: 1.0)//.white //Common.UIColorRGB(0xEDEFF2)
        if #available(iOS 11.0, *) {
            self.tileBgv.roundCorners([ .layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner], radius: 15.0, borderColor: UIColor.lightGray, borderWidth: 1.5)
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
        self.tableView.isScrollEnabled = true
        self.tableView.register(UINib(nibName: liveSearchFaqCellIdentifier, bundle: nil), forCellReuseIdentifier: liveSearchFaqCellIdentifier)
        self.tableView.register(UINib(nibName: liveSearchPageCellIdentifier, bundle: nil), forCellReuseIdentifier: liveSearchPageCellIdentifier)
        self.tableView.register(UINib(nibName: liveSearchTaskCellIdentifier, bundle: nil), forCellReuseIdentifier: liveSearchTaskCellIdentifier)
        self.tableView.register(UINib(nibName: liveSearchNewTaskCellIdentifier, bundle: nil), forCellReuseIdentifier: liveSearchNewTaskCellIdentifier)
        
        self.tableView.register(UINib(nibName: titleWithImageCellIdentifier, bundle: nil), forCellReuseIdentifier: titleWithImageCellIdentifier)
        self.tableView.register(UINib(nibName: titleWithCenteredContentCellIdentifier, bundle: nil), forCellReuseIdentifier: titleWithCenteredContentCellIdentifier)
        self.tableView.register(UINib(nibName: TitleWithHeaderCellIdentifier, bundle: nil), forCellReuseIdentifier: TitleWithHeaderCellIdentifier)
        
        self.tableView.register(UINib(nibName: GridTableViewCellIdentifier, bundle: nil), forCellReuseIdentifier: GridTableViewCellIdentifier)
        
        
        let views: [String: UIView] = ["tileBgv": tileBgv, "tableView": tableView]
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-15-[tileBgv]-5-[tableView]-0-|", options: [], metrics: nil, views: views))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[tileBgv]-0-|", options: [], metrics: nil, views: views))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[tableView]-0-|", options: [], metrics: nil, views: views))
        
        iconImageView = UIImageView(frame: CGRect.zero)
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.image = UIImage.init(named: "findly")
        self.tileBgv.addSubview(iconImageView)
        
        self.titleLbl = UILabel(frame: CGRect.zero)
        self.titleLbl.textColor = Common.UIColorRGB(0x484848)
        self.titleLbl.font = UIFont(name: "HelveticaNeue-Medium", size: 16.0)
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
        
        let subView: [String: UIView] = ["titleLbl": titleLbl, "iconImageView": iconImageView]
        self.tileBgv.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-5-[titleLbl(>=31)]-5-|", options: [], metrics: nil, views: subView))
        self.tileBgv.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[iconImageView(20)]", options: [], metrics: nil, views: subView))
        self.tileBgv.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[iconImageView(20)]-5-[titleLbl]-10-|", options: [], metrics: nil, views: subView))
        NotificationCenter.default.post(name: Notification.Name(reloadTableNotification), object: nil)
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
            self.tileBgv.layer.borderWidth = 0.5
        }else{
            self.tileBgv.layer.borderWidth = 1.0
        }
        
        if reloadTableView {
            if (components.count > 0) {
                let component: KREComponent = components.firstObject as! KREComponent
                if (component.componentDesc != nil) {
                    let jsonString = component.componentDesc
                    let jsonObject: NSDictionary = Utilities.jsonObjectFromString(jsonString: jsonString!) as! NSDictionary
                    let jsonDecoder = JSONDecoder()
                    guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject as Any , options: .prettyPrinted),
                        let allItems = try? jsonDecoder.decode(LiveSearchChatItems.self, from: jsonData) else {
                            return
                    }
                    
                    self.headerArray = []
                    self.faqsExpandArray = []
                    self.pagesExpandArray = []
                    self.likeAndDislikeArray = []
                    self.headersExpandArray = []
                    let faqs = allItems.template?.results?.faq
                    self.arrayOfFaqResults = faqs ?? []
                    if self.arrayOfFaqResults.count > 0 {
                        self.headerArray.append("FAQS")
                        self.headersExpandArray.add("open")
                    }
                    for _ in 0..<self.arrayOfFaqResults.count{
                        self.faqsExpandArray.add("close")
                        self.likeAndDislikeArray.add("")
                    }
                    
                    let pages = allItems.template?.results?.page
                    self.arrayOfPageResults = pages ?? []
                    if self.arrayOfPageResults.count > 0 {
                        self.headerArray.append("PAGES")
                        self.headersExpandArray.add("open")
                    }
                    for _ in 0..<self.arrayOfPageResults.count{
                        self.pagesExpandArray.add("close")
                    }
                    
                    let task = allItems.template?.results?.task
                    self.arrayOfTaskResults = task ?? []
                    if self.arrayOfTaskResults.count > 0 {
                        self.headerArray.append("TASKS")
                        self.headersExpandArray.add("open")
                    }
                    self.titleLbl.text = "Sure, please find the matched results below"
                    self.tableView.reloadData()
                    
                }
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
        return CGSize(width: 0.0, height: textSize.height+60+tableView.contentSize.height)
    }
    
    @objc fileprivate func showMoreButtonAction(_ sender: AnyObject!) {
        let component: KREComponent = components.firstObject as! KREComponent
        if (component.componentDesc != nil) {
            let jsonString = component.componentDesc
            NotificationCenter.default.post(name: Notification.Name(showLiveSearchTemplateNotification), object: jsonString)
        }
    }
}

extension LiveSearchBubbleView: UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        //        let headerName = headerArray[indexPath.section]
        //        switch headerName {
        //        case "FAQS":
        //            if checkboxIndexPath.contains(indexPath) {
        //                return UITableView.automaticDimension
        //            }
        //            return 120
        //        default:
        //            break
        //        }
        //        return UITableView.automaticDimension
        let headerName = headerArray[indexPath.section]
        switch headerName {
        case "FAQS":
            if faqsExpandArray[indexPath.row] as! String == "close"{
                return 75
            }
            return UITableView.automaticDimension
        case "PAGES":
            if  pagesExpandArray[indexPath.row] as! String == "close"{
                return 75
            }
            return UITableView.automaticDimension
        default:
            break
        }
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //        let headerName = headerArray[indexPath.section]
        //        switch headerName {
        //        case "FAQS":
        //             if checkboxIndexPath.contains(indexPath) {
        //                return UITableView.automaticDimension
        //             }
        //            return 120
        //        default:
        //            break
        //        }
        //        return UITableView.automaticDimension
        
        let headerName = headerArray[indexPath.section]
        switch headerName {
        case "FAQS":
            if searchFAQsTemplateType == "gridTemplate"{
                return UITableView.automaticDimension
            }else{
                let layOutType = faqLayOutType
                switch layOutType {
                case "tileWithText":
                    
                    if  faqsExpandArray[indexPath.row] as! String == "close"{
                        return 75
                    }
                    return UITableView.automaticDimension
                    
                    
                case "tileWithImage":
                    if  faqsExpandArray[indexPath.row] as! String == "close"{
                        return 75
                    }
                    return UITableView.automaticDimension
                case "tileWithCenteredContent":
                    if  faqsExpandArray[indexPath.row] as! String == "close"{
                        return 75+100
                    }
                    return UITableView.automaticDimension
                case "tileWithHeader":
                    if  faqsExpandArray[indexPath.row] as! String == "close"{
                        return 50
                    }
                    return UITableView.automaticDimension
                default:
                    break
                }
            }
            
        case "PAGES":
            if searchPageTemplateType == "gridTemplate"{
                return UITableView.automaticDimension
            }else{
                let layOutType = pageLayOutType
                switch layOutType {
                case "tileWithText":
                    if  pagesExpandArray[indexPath.row] as! String == "close"{
                        return 75
                    }
                    return UITableView.automaticDimension
                    
                case "tileWithImage":
                    if  pagesExpandArray[indexPath.row] as! String == "close"{
                        return 75
                    }
                    return UITableView.automaticDimension
                case "tileWithCenteredContent":
                    if  pagesExpandArray[indexPath.row] as! String == "close"{
                        return 75+100
                    }
                    return UITableView.automaticDimension
                case "tileWithHeader":
                    if  pagesExpandArray[indexPath.row] as! String == "close"{
                        return 50
                    }
                    return UITableView.automaticDimension
                default:
                    break
                }
            }
            
        default:
            break
        }
        return UITableView.automaticDimension
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return headerArray.count > sectionAndRowsLimit ? sectionAndRowsLimit : headerArray.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let headerName = headerArray[section]
        switch headerName {
        case "FAQS":
            if headersExpandArray [section] as! String == "open"{
                if searchFAQsTemplateType == "gridTemplate"{
                    return 1
                }
                return arrayOfFaqResults.count > sectionAndRowsLimit ? sectionAndRowsLimit : arrayOfFaqResults.count
            }
            return 0
        case "PAGES":
            if headersExpandArray [section] as! String == "open"{
                if searchPageTemplateType == "gridTemplate"{
                    return 1
                }
                return arrayOfPageResults.count > sectionAndRowsLimit ? sectionAndRowsLimit : arrayOfPageResults.count
            }
            return 0
        case "TASKS":
            if headersExpandArray [section] as! String == "open"{
                return arrayOfTaskResults.count > sectionAndRowsLimit ? sectionAndRowsLimit : arrayOfTaskResults.count
            }
            return 0
        default:
            break
        }
        return 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let headerName = headerArray[indexPath.section]
        switch headerName {
        case "FAQS":
            if searchFAQsTemplateType == "gridTemplate"{
                let cell = tableView.dequeueReusableCell(withIdentifier: GridTableViewCellIdentifier, for: indexPath) as! GridTableViewCell
                cell.configure(with: arrayOfFaqResults, appearanceType: headerName, layOutType: faqLayOutType)
                return cell
            }else{
                let layOutType = faqLayOutType
                switch layOutType {
                case "tileWithText":
                    let cell : LiveSearchFaqTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: liveSearchFaqCellIdentifier) as! LiveSearchFaqTableViewCell
                    titleWithTextCellMethod(cell: cell, cellResultArray: arrayOfFaqResults, expandArray: faqsExpandArray, indexPath: indexPath, isExpand: isFaqsExpand, templateType: searchFAQsTemplateType, appearanceType: headerName)
                    return cell
                case "tileWithImage":
                    let cell : TitleWithImageCell = self.tableView.dequeueReusableCell(withIdentifier: titleWithImageCellIdentifier) as! TitleWithImageCell
                    titleWithImageCellMethod(cell: cell, cellResultArray: arrayOfFaqResults, expandArray: faqsExpandArray, indexPath: indexPath, isExpand: isFaqsExpand, templateType: searchFAQsTemplateType, appearanceType: headerName)
                    return cell
                case "tileWithCenteredContent":
                    let cell : TitleWithCenteredContentCell = self.tableView.dequeueReusableCell(withIdentifier: titleWithCenteredContentCellIdentifier) as! TitleWithCenteredContentCell
                    titleWithCenteredContentCellMethod(cell: cell, cellResultArray: arrayOfFaqResults, expandArray: faqsExpandArray, indexPath: indexPath, isExpand: isFaqsExpand, templateType: searchFAQsTemplateType, appearanceType: headerName)
                    return cell
                case "tileWithHeader":
                    let cell : TitleWithHeaderCell = self.tableView.dequeueReusableCell(withIdentifier: TitleWithHeaderCellIdentifier) as! TitleWithHeaderCell
                    TitleWithHeaderCellMethod(cell: cell, cellResultArray: arrayOfFaqResults, expandArray: faqsExpandArray, indexPath: indexPath, isExpand: isFaqsExpand, templateType: searchFAQsTemplateType, appearanceType: headerName)
                    return cell
                default:
                    break
                }
            }
        case "PAGES":
            if searchPageTemplateType == "gridTemplate"{
                let cell = tableView.dequeueReusableCell(withIdentifier: GridTableViewCellIdentifier, for: indexPath) as! GridTableViewCell
                cell.configure(with: arrayOfPageResults, appearanceType: headerName, layOutType: pageLayOutType)
                return cell
            }else{
                let layOutType = pageLayOutType
                switch layOutType {
                case "tileWithText":
                    let cell : LiveSearchFaqTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: liveSearchFaqCellIdentifier) as! LiveSearchFaqTableViewCell
                    titleWithTextCellMethod(cell: cell, cellResultArray: arrayOfPageResults, expandArray: pagesExpandArray, indexPath: indexPath, isExpand: isPagesExpand, templateType: searchPageTemplateType, appearanceType: headerName)
                    return cell
                case "tileWithImage":
                    let cell : TitleWithImageCell = self.tableView.dequeueReusableCell(withIdentifier: titleWithImageCellIdentifier) as! TitleWithImageCell
                    titleWithImageCellMethod(cell: cell, cellResultArray: arrayOfPageResults, expandArray:
                        pagesExpandArray, indexPath: indexPath, isExpand: isPagesExpand, templateType: searchPageTemplateType, appearanceType: headerName)
                    return cell
                case "tileWithCenteredContent":
                    let cell : TitleWithCenteredContentCell = self.tableView.dequeueReusableCell(withIdentifier: titleWithCenteredContentCellIdentifier) as! TitleWithCenteredContentCell
                    titleWithCenteredContentCellMethod(cell: cell, cellResultArray: arrayOfPageResults, expandArray: pagesExpandArray, indexPath: indexPath, isExpand: isPagesExpand, templateType: searchPageTemplateType, appearanceType: headerName)
                    return cell
                case "tileWithHeader":
                    let cell : TitleWithHeaderCell = self.tableView.dequeueReusableCell(withIdentifier: TitleWithHeaderCellIdentifier) as! TitleWithHeaderCell
                    TitleWithHeaderCellMethod(cell: cell, cellResultArray: arrayOfPageResults, expandArray: pagesExpandArray, indexPath: indexPath, isExpand: isPagesExpand, templateType: searchPageTemplateType, appearanceType: headerName)
                    return cell
                default:
                    break
                }
            }
        case "TASKS":
            /*
             let cell : LiveSearchTaskTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: liveSearchTaskCellIdentifier) as! LiveSearchTaskTableViewCell
             cell.backgroundColor = UIColor.clear
             cell.selectionStyle = .none
             cell.titleLabel.textColor = .black
             let results = arrayOfTaskResults[indexPath.row]
             cell.titleLabel?.text = results.name
             if results.imageUrl == nil || results.imageUrl == ""{
             cell.profileImageView.image = UIImage(named: "task")
             }else{
             let url = URL(string: results.imageUrl!)
             cell.profileImageView.setImageWith(url!, placeholderImage: UIImage(named: "task"))
             }
             
             cell.subViewLeadingConstraint.constant = 5.0
             cell.subViewTopConstaint.constant = 5.0
             cell.subViewTrailingConstraint.constant = 5.0
             
             //            cell.subView.layer.shadowOpacity = 0.7
             //            cell.subView.layer.shadowOffset = CGSize(width: 2, height: 2)
             //            cell.subView.layer.shadowRadius = 8.0
             //            cell.subView.clipsToBounds = false
             //            cell.subView.layer.shadowColor = UIColor.init(red: 209/255, green: 217/255, blue: 224/255, alpha: 1.0).cgColor
             
             return cell
             */
            
            let cell : LiveSearchNewTaskViewCell = self.tableView.dequeueReusableCell(withIdentifier: liveSearchNewTaskCellIdentifier) as! LiveSearchNewTaskViewCell
            cell.backgroundColor = UIColor.clear
            cell.selectionStyle = .none
            cell.titleLabel.textColor = UIColor.init(red: 44/255, green: 128/255, blue: 248/255, alpha: 1.0)
            let results = arrayOfTaskResults[indexPath.row]
            cell.titleLabel?.text = "\(results.name!)     "
            cell.titleLabel?.layer.cornerRadius = 5.0
            cell.titleLabel?.layer.borderWidth = 1.0
            cell.titleLabel?.layer.borderColor = UIColor.init(red: 44/255, green: 128/255, blue: 248/255, alpha: 1.0).cgColor
            return cell
        default:
            break
        }
        return UITableViewCell()
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let headerName = headerArray[indexPath.section]
        switch headerName {
        case "FAQS":
            if checkboxIndexPath.contains(indexPath) {
                
                checkboxIndexPath.remove(at: checkboxIndexPath.firstIndex(of: indexPath)!)
            }else{
                checkboxIndexPath.append(indexPath)
            }
            tableView.reloadData()
            NotificationCenter.default.post(name: Notification.Name(reloadTableNotification), object: nil)
        case "PAGES":
            let results = arrayOfPageResults[indexPath.row]
            if results.url != nil {
                self.linkAction(results.url!)
            }
            break
        case "TASKS":
            if let payload = arrayOfTaskResults[indexPath.row].payload {
                self.optionsAction(arrayOfTaskResults[indexPath.row].name, payload)
            }
            isEndOfTask = false //kk
            //if results.postBackPayload?.payload != nil{
            //    self.optionsAction(results.postBackPayload?.payload, results.postBackPayload?.payload)
        //}
        default:
            break
        }
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        //view.frame = CGRect(x: 10, y: 5, width: tableView.frame.size.width, height: 30)
        view.backgroundColor = UIColor.init(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0)
        let headerLabel = UILabel(frame: .zero)
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.textAlignment = .left
        headerLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 15.0)
        headerLabel.font = headerLabel.font.withSize(15.0)
        
        headerLabel.textColor = .gray
        //headerLabel.text =  headerArray[section]
        view.addSubview(headerLabel)
        
        let dropDownBtn = UIButton(frame: CGRect.zero)
        dropDownBtn.backgroundColor = .clear
        dropDownBtn.translatesAutoresizingMaskIntoConstraints = false
        dropDownBtn.clipsToBounds = true
        dropDownBtn.layer.cornerRadius = 5
        dropDownBtn.setTitleColor(.gray, for: .normal)
        dropDownBtn.setTitleColor(Common.UIColorRGB(0x999999), for: .disabled)
        dropDownBtn.setTitle(" \(headerArray[section])", for: .normal)
        dropDownBtn.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
        dropDownBtn.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
        dropDownBtn.titleLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 15.0)!
        view.addSubview(dropDownBtn)
        dropDownBtn.tag = section
        dropDownBtn.semanticContentAttribute = .forceLeftToRight
        
        dropDownBtn.addTarget(self, action: #selector(self.headerDropDownButtonAction(_:)), for: .touchUpInside)
        if headersExpandArray[section] as! String == "open"{
            dropDownBtn.setImage(UIImage.init(named: "downarrow"), for: .normal)
        }else{
            dropDownBtn.setImage(UIImage.init(named: "rightarrow"), for: .normal)
        }
        
        let showMoreButton = UIButton(frame: CGRect.zero)
        showMoreButton.backgroundColor = .clear
        showMoreButton.translatesAutoresizingMaskIntoConstraints = false
        showMoreButton.clipsToBounds = true
        showMoreButton.layer.cornerRadius = 5
        showMoreButton.setTitleColor(.darkGray, for: .normal)
        showMoreButton.setTitle("Show All", for: .normal)
        showMoreButton.setTitleColor(Common.UIColorRGB(0x999999), for: .disabled)
        showMoreButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 14.0)!
        view.addSubview(showMoreButton)
        showMoreButton.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.center
        showMoreButton.addTarget(self, action: #selector(self.showMoreButtonAction(_:)), for: .touchUpInside)
//        let attributeString = NSMutableAttributedString(string: "Show All",
//                                                        attributes: yourAttributes)
//        showMoreButton.setAttributedTitle(attributeString, for: .normal)
        
//        let boolValue = section == 0 ? false : true
//        showMoreButton.isHidden = boolValue
        
        let views: [String: UIView] = ["dropDownBtn": headerLabel, "showMoreButton": showMoreButton]
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-5-[dropDownBtn]-5-[showMoreButton(100)]-0-|", options:[], metrics:nil, views:views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-5-[dropDownBtn]-5-|", options:[], metrics:nil, views:views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-5-[showMoreButton]-5-|", options:[], metrics:nil, views:views))
        
        return view
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let indexOfLastSection = self.tableView.numberOfSections - 1
        if(section == indexOfLastSection){
            return 40
        }
        return 0
        
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.frame = CGRect(x: 10, y: 5, width: tableView.frame.size.width, height: 30)
        view.backgroundColor = UIColor.init(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0)
        let headerLabel = UILabel(frame: .zero)
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.textAlignment = .left
        headerLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 15.0)
        headerLabel.font = headerLabel.font.withSize(15.0)
        headerLabel.textColor = .gray
        headerLabel.text =  "(516 results)"
        view.addSubview(headerLabel)
        
        let dropDownBtn = UIButton(frame: CGRect.zero)
        dropDownBtn.backgroundColor = .clear
        dropDownBtn.translatesAutoresizingMaskIntoConstraints = false
        dropDownBtn.clipsToBounds = true
        dropDownBtn.layer.cornerRadius = 5
        dropDownBtn.setTitleColor(.blue, for: .normal)
        dropDownBtn.setTitleColor(Common.UIColorRGB(0x999999), for: .disabled)
        dropDownBtn.setTitle("See all", for: .normal)
        dropDownBtn.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
        dropDownBtn.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
        dropDownBtn.titleLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 15.0)!
        view.addSubview(dropDownBtn)
        dropDownBtn.tag = section
        dropDownBtn.semanticContentAttribute = .forceLeftToRight
       
        dropDownBtn.addTarget(self, action: #selector(self.showMoreButtonAction(_:)), for: .touchUpInside)
        
        let views: [String: UIView] = ["dropDownBtn": dropDownBtn, "headerLabel": headerLabel]
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-5-[dropDownBtn(100)]|", options:[], metrics:nil, views:views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-60-[headerLabel(100)]|", options:[], metrics:nil, views:views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[dropDownBtn]-5-|", options:[], metrics:nil, views:views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[headerLabel]-5-|", options:[], metrics:nil, views:views))
        
        return view
        
    }
    
    @objc fileprivate func closeButtonAction(_ sender: AnyObject!) {
        recentSearchArray.removeObject(at: sender.tag)
        tableView.reloadData()
    }
    @objc fileprivate func shareButtonAction(_ sender: AnyObject!) {
        let results = arrayOfPageResults[sender.tag]
        if results.url != nil {
            self.linkAction(results.url!)
        }
    }
    
    @objc fileprivate func likeButtonAction(_ sender: UIButton!) {
        likeAndDislikeArray.replaceObject(at: sender.tag, with: "Like")
        tableView.reloadData()
    }
    @objc fileprivate func disLikeButtonAction(_ sender: UIButton!) {
        likeAndDislikeArray.replaceObject(at: sender.tag, with: "DisLike")
        tableView.reloadData()
    }
    
    @objc fileprivate func headerDropDownButtonAction(_ sender: AnyObject!) {
        if headersExpandArray[sender.tag] as! String == "open"{
            headersExpandArray.replaceObject(at: sender.tag, with: "close")
        }else{
            headersExpandArray.replaceObject(at: sender.tag, with: "open")
        }
        tableView.reloadData()
        reloadTableView = false
        NotificationCenter.default.post(name: Notification.Name(reloadTableNotification), object: nil)
    }
}

extension LiveSearchBubbleView{
    
    func titleWithTextCellMethod(cell: LiveSearchFaqTableViewCell,cellResultArray: [TemplateResultElements],expandArray: NSMutableArray, indexPath: IndexPath, isExpand: Bool, templateType: String, appearanceType: String){
        
        cell.backgroundColor = UIColor.clear
        cell.selectionStyle = .none
        cell.titleLabel.textColor = .black
        cell.descriptionLabel.textColor = .dark
        cell.titleLabel?.numberOfLines = 0 //2
        cell.descriptionLabel?.numberOfLines = 0 //2
        let results = cellResultArray[indexPath.row]
        if appearanceType == "FAQS" {
            cell.titleLabel?.text = results.question
            cell.descriptionLabel?.text = results.answer
        }else{
            cell.titleLabel?.text = results.pageTitle
            cell.descriptionLabel?.text = results.pageSearchResultPreview
        }
        let buttonsHeight = expandArray[indexPath.row] as! String == "close" ? 0.0: 0.0 //30.0
        cell.likeAndDislikeButtonHeightConstrain.constant = CGFloat(buttonsHeight)
        
        cell.likeButton.addTarget(self, action: #selector(self.likeButtonAction(_:)), for: .touchUpInside)
        cell.likeButton.tag = indexPath.row
        cell.dislikeButton.addTarget(self, action: #selector(self.disLikeButtonAction(_:)), for: .touchUpInside)
        cell.dislikeButton.tag = indexPath.row
        
        
        cell.subViewLeadingConstraint.constant = 5.0
        cell.subViewTopConstaint.constant = 5.0
        cell.subViewTrailingConstraint.constant = 5.0
        
        
        
        if isExpand{
            cell.imageVWidthConstraint.constant = 10
            if expandArray [indexPath.row] as! String == "open"{
                cell.topImageV.image = UIImage(named: "downarrow")
            }else{
                cell.topImageV.image = UIImage(named: "rightarrow")
            }
        }else{
            cell.imageVWidthConstraint.constant = 0
        }
        let templateType: searchTemplateTypes = searchTemplateTypes(rawValue: templateType)!
        switch templateType {
        case .listTemplate1:
            cell.subViewBottomConstrain.constant =  10.0
            cell.subView.layer.cornerRadius = 10
            cell.underLineLabel.isHidden = true
            
            cell.subView.layer.shadowOpacity = 0.7
            cell.subView.layer.shadowOffset = CGSize(width: 2, height: 2)
            cell.subView.layer.shadowRadius = 8.0
            cell.subView.clipsToBounds = false
            cell.subView.layer.shadowColor = UIColor.init(red: 209/255, green: 217/255, blue: 224/255, alpha: 1.0).cgColor
            
        case .listTemplate2:
            cell.subViewBottomConstrain.constant = 0.0
            cell.subView.layer.cornerRadius = 0.0
            cell.underLineLabel.isHidden = false
            let totalRow = tableView.numberOfRows(inSection: indexPath.section)
            if(indexPath.row == totalRow - 1){
                //cell.underLineLabel.isHidden = true
            }
            
            //            cell.subViewTopConstaint.constant = 0.0
            //            cell.subView.layer.shadowOpacity = 1
            //            cell.subView.layer.shadowOffset = CGSize(width: 0, height: 0)
            //            cell.subView.layer.shadowRadius = 5.0
            //            cell.subView.clipsToBounds = false
            //            cell.subView.layer.shadowColor = UIColor.init(red: 209/255, green: 217/255, blue: 224/255, alpha: 1.0).cgColor
            
        case .listTemplate3:
            cell.subViewBottomConstrain.constant = 0.0
            cell.subView.layer.cornerRadius = 0.0
            cell.underLineLabel.isHidden = false
            if #available(iOS 11.0, *) {
                if indexPath.row == 0{
                    cell.subView.roundCorners([ .layerMinXMinYCorner, .layerMaxXMinYCorner], radius: 10.0, borderColor: UIColor.clear, borderWidth: 1.5)
                }else{
                    let totalRow = tableView.numberOfRows(inSection: indexPath.section)
                    if(indexPath.row == totalRow - 1){
                        cell.subView.roundCorners([ .layerMinXMaxYCorner, .layerMaxXMaxYCorner], radius: 10.0, borderColor: UIColor.clear, borderWidth: 1.5)
                        cell.underLineLabel.isHidden = true
                        cell.subViewBottomConstrain.constant = 1.0
                        
                    }
                }
                
                cell.subViewTopConstaint.constant = 1.0
                cell.subView.layer.shadowOpacity = 0.7
                cell.subView.layer.shadowOffset = CGSize(width: 2, height: 2)
                cell.subView.layer.shadowRadius = 8.0
                cell.subView.clipsToBounds = false
                cell.subView.layer.shadowColor = UIColor.init(red: 209/255, green: 217/255, blue: 224/255, alpha: 1.0).cgColor
                
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    func titleWithImageCellMethod(cell: TitleWithImageCell,cellResultArray: [TemplateResultElements],expandArray: NSMutableArray, indexPath: IndexPath, isExpand: Bool, templateType: String, appearanceType: String){
        cell.backgroundColor = UIColor.clear
        cell.selectionStyle = .none
        cell.titleLabel.textColor = .black
        cell.descriptionLabel.textColor = .dark
        cell.titleLabel?.numberOfLines = 0 //2
        cell.descriptionLabel?.numberOfLines = 0 //2
        let results = cellResultArray[indexPath.row]
        if appearanceType == "FAQS" {
            cell.titleLabel?.text = results.question
            cell.descriptionLabel?.text = results.answer
        }else{
            cell.titleLabel?.text = results.pageTitle
            cell.descriptionLabel?.text = results.pageSearchResultPreview
        }
        
        let buttonsHeight = expandArray[indexPath.row] as! String == "close" ? 0.0: 0.0 //30.0
        cell.likeAndDislikeButtonHeightConstrain.constant = CGFloat(buttonsHeight)
        
        if results.imageUrl == nil || results.imageUrl == ""{
            cell.topImageV.image = UIImage(named: "placeholder_image")
            //cell.bottomImageV.image = UIImage(named: "placeholder_image")
        }else{
            let url = URL(string: results.imageUrl!)
            cell.topImageV.setImageWith(url!, placeholderImage: UIImage(named: "placeholder_image"))
            //cell.bottomImageV.setImageWith(url!, placeholderImage: UIImage(named: "placeholder_image"))
        }
        
        if isExpand{
            if expandArray [indexPath.row] as! String == "open"{
                cell.topImageVWidthConstrain.constant = 10
                cell.topImageVHeightConstrain.constant = 20
                cell.bottomImageVWidthConstrain.constant = 50
                cell.topImageV.image = UIImage(named: "downarrow")
                if results.imageUrl == nil || results.imageUrl == ""{
                    cell.bottomImageV.image = UIImage(named: "placeholder_image")
                }else{
                    let url = URL(string: results.imageUrl!)
                    cell.bottomImageV.setImageWith(url!, placeholderImage: UIImage(named: "placeholder_image"))
                }
            }else{
                cell.topImageV.image = UIImage(named: "rightarrow")
                cell.topImageVWidthConstrain.constant = 10
                cell.topImageVHeightConstrain.constant = 20
                cell.bottomImageVWidthConstrain.constant = 0
            }
        }
        
        cell.likeButton.addTarget(self, action: #selector(self.likeButtonAction(_:)), for: .touchUpInside)
        cell.likeButton.tag = indexPath.row
        cell.dislikeButton.addTarget(self, action: #selector(self.disLikeButtonAction(_:)), for: .touchUpInside)
        cell.dislikeButton.tag = indexPath.row
        //        if likeAndDislikeArray[indexPath.row] as! String == "Like"{
        //            cell.likeButton.tintColor = .blue
        //            cell.dislikeButton.tintColor = .darkGray
        //        }else if likeAndDislikeArray[indexPath.row] as! String == "DisLike"{
        //            cell.likeButton.tintColor = .darkGray
        //            cell.dislikeButton.tintColor = .blue
        //        }
        
        cell.subViewLeadingConstraint.constant = 5.0
        cell.subViewTopConstaint.constant = 5.0
        cell.subViewTrailingConstraint.constant = 5.0
        
        let templateType: searchTemplateTypes = searchTemplateTypes(rawValue: templateType)!
        switch templateType {
        case .listTemplate1:
            cell.subViewBottomConstrain.constant =  11.0
            cell.subView.layer.cornerRadius = 10
            cell.underLineLabel.isHidden = true
            
            cell.subView.layer.shadowOpacity = 0.7
            cell.subView.layer.shadowOffset = CGSize(width: 2, height: 2)
            cell.subView.layer.shadowRadius = 8.0
            cell.subView.clipsToBounds = false
            cell.subView.layer.shadowColor = UIColor.init(red: 209/255, green: 217/255, blue: 224/255, alpha: 1.0).cgColor
            
        case .listTemplate2:
            cell.subViewBottomConstrain.constant = 0.0
            cell.subView.layer.cornerRadius = 0.0
            cell.underLineLabel.isHidden = false
            let totalRow = tableView.numberOfRows(inSection: indexPath.section)
            if(indexPath.row == totalRow - 1){
                cell.underLineLabel.isHidden = true
            }
        case .listTemplate3:
            cell.subViewBottomConstrain.constant = 0.0
            cell.subView.layer.cornerRadius = 0.0
            cell.underLineLabel.isHidden = false
            if #available(iOS 11.0, *) {
                if indexPath.row == 0{
                    cell.subView.roundCorners([ .layerMinXMinYCorner, .layerMaxXMinYCorner], radius: 10.0, borderColor: UIColor.clear, borderWidth: 1.5)
                }else{
                    let totalRow = tableView.numberOfRows(inSection: indexPath.section)
                    if(indexPath.row == totalRow - 1){
                        cell.subView.roundCorners([ .layerMinXMaxYCorner, .layerMaxXMaxYCorner], radius: 10.0, borderColor: UIColor.clear, borderWidth: 1.5)
                        cell.underLineLabel.isHidden = true
                        cell.subViewBottomConstrain.constant = 1.0
                    }
                }
                
                cell.subViewTopConstaint.constant = 1.0
                cell.subView.layer.shadowOpacity = 0.7
                cell.subView.layer.shadowOffset = CGSize(width: 2, height: 2)
                cell.subView.layer.shadowRadius = 8.0
                cell.subView.clipsToBounds = false
                cell.subView.layer.shadowColor = UIColor.init(red: 209/255, green: 217/255, blue: 224/255, alpha: 1.0).cgColor
                
            } else {
                
            }
        }
        
    }
    
    func titleWithCenteredContentCellMethod(cell: TitleWithCenteredContentCell,cellResultArray: [TemplateResultElements],expandArray: NSMutableArray, indexPath: IndexPath, isExpand: Bool, templateType: String, appearanceType: String){
        
        cell.backgroundColor = UIColor.clear
        cell.selectionStyle = .none
        cell.titleLabel.textColor = .black
        cell.descriptionLabel.textColor = .dark
        cell.titleLabel?.numberOfLines = 0 //2
        cell.descriptionLabel?.numberOfLines = 0 //2
        let results = cellResultArray[indexPath.row]
        if appearanceType == "FAQS" {
            cell.titleLabel?.text = results.question
            cell.descriptionLabel?.text = results.answer
        }else{
            cell.titleLabel?.text = results.pageTitle
            cell.descriptionLabel?.text = results.pageSearchResultPreview
        }
        let buttonsHeight = expandArray[indexPath.row] as! String == "close" ? 0.0: 0.0 //30.0
        cell.likeAndDislikeButtonHeightConstrain.constant = CGFloat(buttonsHeight)
        
        if isExpand{
            cell.topCenterImagV.isHidden = true
            cell.titleLabel.textAlignment = .left
            cell.descriptionLabel.textAlignment = .left
            
            if expandArray [indexPath.row] as! String == "open"{
                cell.centerImagV.isHidden = false
                cell.centerImagVHeightConstrain.constant = 100
                
                cell.topImageVWidthConstrain.constant = 10
                cell.topImageVHeightConstrain.constant = 20
                cell.topCenterImageVHeightConstrain.constant = 5
                cell.topImageV.image = UIImage(named: "downarrow")
                if results.imageUrl == nil || results.imageUrl == ""{
                    cell.centerImagV.image = UIImage(named: "placeholder_image")
                }else{
                    let url = URL(string: results.imageUrl!)
                    cell.centerImagV.setImageWith(url!, placeholderImage: UIImage(named: "placeholder_image"))
                }
            }else{
                cell.centerImagV.isHidden = true
                cell.centerImagVHeightConstrain.constant = 0
                
                cell.topImageV.image = UIImage(named: "rightarrow")
                cell.topImageVWidthConstrain.constant = 10
                cell.topImageVHeightConstrain.constant = 20
            }
        }else{
            cell.topCenterImagV.isHidden = false
            cell.titleLabel.textAlignment = .center
            cell.descriptionLabel.textAlignment = .center
            cell.centerImagV.isHidden = true
            
            cell.topImageVWidthConstrain.constant = 0
            cell.topCenterImageVHeightConstrain.constant = 100
            cell.titleLabelHorizontalConstrain.constant = 0
            
            if results.imageUrl == nil || results.imageUrl == ""{
                cell.topCenterImagV.image = UIImage(named: "placeholder_image")
                
            }else{
                let url = URL(string: results.imageUrl!)
                cell.topCenterImagV.setImageWith(url!, placeholderImage: UIImage(named: "placeholder_image"))
                
            }
        }
        
        cell.likeButton.addTarget(self, action: #selector(self.likeButtonAction(_:)), for: .touchUpInside)
        cell.likeButton.tag = indexPath.row
        cell.dislikeButton.addTarget(self, action: #selector(self.disLikeButtonAction(_:)), for: .touchUpInside)
        cell.dislikeButton.tag = indexPath.row
        //        if likeAndDislikeArray[indexPath.row] as! String == "Like"{
        //            cell.likeButton.tintColor = .blue
        //            cell.dislikeButton.tintColor = .darkGray
        //        }else if likeAndDislikeArray[indexPath.row] as! String == "DisLike"{
        //            cell.likeButton.tintColor = .darkGray
        //            cell.dislikeButton.tintColor = .blue
        //        }
        
        cell.subViewLeadingConstraint.constant = 5.0
        cell.subViewTopConstaint.constant = 5.0
        cell.subViewTrailingConstraint.constant = 5.0
        
        let templateType: searchTemplateTypes = searchTemplateTypes(rawValue: templateType)!
        switch templateType {
        case .listTemplate1:
            cell.subViewBottomConstrain.constant =  11.0
            cell.subView.layer.cornerRadius = 10
            cell.underLineLabel.isHidden = true
            
            cell.subView.layer.shadowOpacity = 0.7
            cell.subView.layer.shadowOffset = CGSize(width: 2, height: 2)
            cell.subView.layer.shadowRadius = 8.0
            cell.subView.clipsToBounds = false
            cell.subView.layer.shadowColor = UIColor.init(red: 209/255, green: 217/255, blue: 224/255, alpha: 1.0).cgColor
            
        case .listTemplate2:
            cell.subViewBottomConstrain.constant = 0.0
            cell.subView.layer.cornerRadius = 0.0
            cell.underLineLabel.isHidden = false
            let totalRow = tableView.numberOfRows(inSection: indexPath.section)
            if(indexPath.row == totalRow - 1){
                cell.underLineLabel.isHidden = true
            }
        case .listTemplate3:
            cell.subViewBottomConstrain.constant = 0.0
            cell.subView.layer.cornerRadius = 0.0
            cell.underLineLabel.isHidden = false
            if #available(iOS 11.0, *) {
                if indexPath.row == 0{
                    cell.subView.roundCorners([ .layerMinXMinYCorner, .layerMaxXMinYCorner], radius: 10.0, borderColor: UIColor.clear, borderWidth: 1.5)
                }else{
                    let totalRow = tableView.numberOfRows(inSection: indexPath.section)
                    if(indexPath.row == totalRow - 1){
                        cell.subView.roundCorners([ .layerMinXMaxYCorner, .layerMaxXMaxYCorner], radius: 10.0, borderColor: UIColor.clear, borderWidth: 1.5)
                        cell.underLineLabel.isHidden = true
                        cell.subViewBottomConstrain.constant = 1.0
                    }
                }
                
                cell.subViewTopConstaint.constant = 1.0
                cell.subView.layer.shadowOpacity = 0.7
                cell.subView.layer.shadowOffset = CGSize(width: 2, height: 2)
                cell.subView.layer.shadowRadius = 8.0
                cell.subView.clipsToBounds = false
                cell.subView.layer.shadowColor = UIColor.init(red: 209/255, green: 217/255, blue: 224/255, alpha: 1.0).cgColor
                
            } else {
                
            }
        }
        
    }
    
    func TitleWithHeaderCellMethod(cell: TitleWithHeaderCell,cellResultArray: [TemplateResultElements],expandArray: NSMutableArray, indexPath: IndexPath, isExpand: Bool, templateType: String, appearanceType: String) {
        
        cell.backgroundColor = UIColor.clear
        cell.selectionStyle = .none
        cell.titleLabel.textColor = .black
        
        cell.titleLabel?.numberOfLines = 0 //2
        
        let results = cellResultArray[indexPath.row]
        if appearanceType == "FAQS" {
            cell.titleLabel?.text = results.question
        }else{
            cell.titleLabel?.text = results.pageTitle
        }
        
        let buttonsHeight = expandArray[indexPath.row] as! String == "close" ? 0.0: 0.0 //30.0
        cell.likeAndDislikeButtonHeightConstrain.constant = CGFloat(buttonsHeight)
        
        cell.likeButton.addTarget(self, action: #selector(self.likeButtonAction(_:)), for: .touchUpInside)
        cell.likeButton.tag = indexPath.row
        cell.dislikeButton.addTarget(self, action: #selector(self.disLikeButtonAction(_:)), for: .touchUpInside)
        cell.dislikeButton.tag = indexPath.row
        //     if likeAndDislikeArray[indexPath.row] as! String == "Like"{
        //         cell.likeButton.tintColor = .blue
        //         cell.dislikeButton.tintColor = .darkGray
        //     }else if likeAndDislikeArray[indexPath.row] as! String == "DisLike"{
        //         cell.likeButton.tintColor = .darkGray
        //         cell.dislikeButton.tintColor = .blue
        //     }
        
        cell.subViewLeadingConstraint.constant = 5.0
        cell.subViewTopConstaint.constant = 5.0
        cell.subViewTrailingConstraint.constant = 5.0
        
        let templateType: searchTemplateTypes = searchTemplateTypes(rawValue: templateType)!
        switch templateType {
        case .listTemplate1:
            cell.subViewBottomConstrain.constant =  11.0
            cell.subView.layer.cornerRadius = 10
            cell.underLineLabel.isHidden = true
            
            cell.subView.layer.shadowOpacity = 0.7
            cell.subView.layer.shadowOffset = CGSize(width: 2, height: 2)
            cell.subView.layer.shadowRadius = 8.0
            cell.subView.clipsToBounds = false
            cell.subView.layer.shadowColor = UIColor.init(red: 209/255, green: 217/255, blue: 224/255, alpha: 1.0).cgColor
            
        case .listTemplate2:
            cell.subViewBottomConstrain.constant = 0.0
            cell.subView.layer.cornerRadius = 0.0
            cell.underLineLabel.isHidden = false
            let totalRow = tableView.numberOfRows(inSection: indexPath.section)
            if(indexPath.row == totalRow - 1){
                cell.underLineLabel.isHidden = true
            }
        case .listTemplate3:
            cell.subViewBottomConstrain.constant = 0.0
            cell.subView.layer.cornerRadius = 0.0
            cell.underLineLabel.isHidden = false
            if #available(iOS 11.0, *) {
                if indexPath.row == 0{
                    cell.subView.roundCorners([ .layerMinXMinYCorner, .layerMaxXMinYCorner], radius: 10.0, borderColor: UIColor.clear, borderWidth: 1.5)
                }else{
                    let totalRow = tableView.numberOfRows(inSection: indexPath.section)
                    if(indexPath.row == totalRow - 1){
                        cell.subView.roundCorners([ .layerMinXMaxYCorner, .layerMaxXMaxYCorner], radius: 10.0, borderColor: UIColor.clear, borderWidth: 1.5)
                        cell.underLineLabel.isHidden = true
                        cell.subViewBottomConstrain.constant = 1.0
                    }
                }
                
                cell.subViewTopConstaint.constant = 1.0
                cell.subView.layer.shadowOpacity = 0.7
                cell.subView.layer.shadowOffset = CGSize(width: 2, height: 2)
                cell.subView.layer.shadowRadius = 8.0
                cell.subView.clipsToBounds = false
                cell.subView.layer.shadowColor = UIColor.init(red: 209/255, green: 217/255, blue: 224/255, alpha: 1.0).cgColor
                
            } else {
                
            }
        }
        
    }
    
    func  reloadTableViewSilently() {
        DispatchQueue.main.async {
            //            self.tabV.beginUpdates()
            //            self.tabV.endUpdates()
            self.tableView.reloadData()
        }
    }
}
