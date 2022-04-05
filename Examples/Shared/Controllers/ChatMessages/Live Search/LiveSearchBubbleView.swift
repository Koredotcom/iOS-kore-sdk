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
    fileprivate let CarouselTableViewCellIdentifier = "CarouselTableViewCell"
    
    var totalNumOfResults = 0
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
    var arrayOfFileResults = [TemplateResultElements]()
    var arrayOfDataResults = [TemplateResultElements]()
    
    var headerArray = ["POPULAR SEARCHS","RECENT SEARCHS"]
    var headerArrayDisplay:NSMutableArray = []
    var faqsExpandArray:NSMutableArray = []
    var pagesExpandArray:NSMutableArray = []
    var filesExpandArray:NSMutableArray = []
    var dataExpandArray:NSMutableArray = []
    
    
    var likeAndDislikeArray:NSMutableArray = []
    var headersExpandArray:NSMutableArray = []
    var checkboxIndexPath = [IndexPath]()
    
    let sectionAndRowsLimit:Int = 2//(serachInterfaceItems?.interactionsConfig?.liveSearchResultsLimit)!
    
    var liveSearchFileTemplateType = "list"
    var fileLayOutType =  "l1"
    var isFileClickable =  true
    var fileListType =  "plain"
    var fileTextAlignment =  "center"
    
    var liveSearchFAQsTemplateType = "list"
    var faqLayOutType =  "l1"
    var isFaqsClickable =  true
    var faqListType =  "plain"
    var faqTextAlignment =  "center"
    
    var liveSearchPageTemplateType =  "list"
    var pageLayOutType =  "l1"
    var isPagesClickable =  true
    var pageListType =  "plain"
    var pageTextAlignment =  "center"
    
    var liveSearchDataTemplateType =  "list"
    var dataLayOutType =  "l1"
    var isDataClickable =  true
    var dataListType =  "plain"
    var dataTextAlignment =  "center"
    
    var fileHeading =  ""
    var fileDescription =  ""
    var fileImg = ""
    var fileUrl = ""
    
    var faqHeading = ""
    var faqDescription = ""
    var faqImg = ""
    var faqUrl = ""
    
    var webHeading = ""
    var webDescription = ""
    var webImg = ""
    var webUrl = ""
    
    var dataHeading = "question"
    var dataDescription = ""
    var dataImg = ""
    var dataUrl = ""
    
    var hashMapDic: NSDictionary = [String: Any]() as NSDictionary
    var isSearchType = "conversationalSearch"
    
     enum LiveSearchHeaderTypes: String{
         case faq = "FAQS"
         case web = "WEB"
         case task = "TASKS"
         case file = "Files"
         case data = "DATA"
     }
     enum LiveSearchLayoutTypes: String{
        case tileWithHeader = "l1"
        case descriptionText = "l2"
        case tileWithText = "l3"
        case tileWithImage = "l4"
        case tileWithCenteredContent = "l6"
    }
     enum LiveSearchTemplateTypes: String{
        case listTemplate1 = "classic"
        case listTemplate2 = "list"
        case listTemplate3 = "plain"
    }
    
    enum LiveSearchSysContentTypes: String{
           case faq = "faq"
           case web = "web"
           case task = "task"
           case file = "file"
           case data = "data"
       }
    
    enum LiveSearchTypes: String{
        case listTemplate = "list"//listTemplate
        case grid = "grid"
        case carousel = "carousel"
    }
    
    var headerNArray = ["POPULAR SEARCHS","RECENT SEARCHS"]
    var arrayOfSearchResults = NSMutableArray()
    var arrayOfSearchResultsExpand = NSMutableArray()
    var arrayOfSearchResultsLikeDislike = NSMutableArray()
    
    var arrayOfLiveSearchTemplateType = NSMutableArray()
    var arrayOfLayOutType = NSMutableArray()
    var arrayOfIsClickable = NSMutableArray()
    var arrayOfListType =  NSMutableArray()
    var arrayOfTextAlignment =  NSMutableArray()
    
    var arrayOfHeading = NSMutableArray()
    var arrayOfDescription = NSMutableArray()
    var arrayOfImg = NSMutableArray()
    var arrayOfUrl = NSMutableArray()
    
    var arrayOfResultSettingTemplateType = NSMutableArray()
    var arrayOfResultSettingLayOutType = NSMutableArray()
    var arrayOfResultSettingIsClickable = NSMutableArray()
    var arrayOfResultSettingListType =  NSMutableArray()
    var arrayOfResultSettingTextAlignment =  NSMutableArray()
    
    var arrayOfResultSettingHeading = NSMutableArray()
    var arrayOfResultSettingDescription = NSMutableArray()
    var arrayOfResultSettingImg = NSMutableArray()
    var arrayOfResultSettingUrl = NSMutableArray()
    
    var resultTypeString:String?
    var resultTypeFlatString = "flat"
    
    public var optionsAction: ((_ text: String?, _ payload: String?) -> Void)!
    public var optionsTaskAction: ((_ text: String?, _ payload: String?, _ taskData: [String: Any]) -> Void)!
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
        
        headerNArray = []
        for i in 0..<(resultViewSettingItems?.settings?.count ?? 0){
            let settings = resultViewSettingItems?.settings?[i]
            //let isGroupResults = settings?.groupResults
            if settings?.interface == "conversationalSearch"{
                for j in 0..<(settings?.groupSetting?.conditions?.count ?? 0){
                    if let condtion = settings?.groupSetting?.conditions?[j]{
                        headerNArray.append(condtion.fieldValue ?? "")
                        
                        if let isGroupResults = settings?.groupResults, isGroupResults{
                            arrayOfResultSettingTemplateType.add(condtion.template?.type ?? "listTemplate1")
                            arrayOfResultSettingLayOutType.add(condtion.template?.layout?.layoutType ?? "tileWithText")
                            arrayOfResultSettingIsClickable.add(condtion.template?.layout?.isClickable ?? true)
                            arrayOfResultSettingListType.add(condtion.template?.layout?.listType ?? "plain")
                            arrayOfResultSettingTextAlignment.add(condtion.template?.layout?.textAlignment ?? "center")
                            
                            arrayOfResultSettingHeading.add(condtion.template?.mapping?.heading ?? "")
                            arrayOfResultSettingDescription.add(condtion.template?.mapping?.descrip ?? "")
                            arrayOfResultSettingImg.add(condtion.template?.mapping?.img ?? "")
                            arrayOfResultSettingUrl.add(condtion.template?.mapping?.url ?? "")
                        }else{
                            if let defaultTemplate = settings?.defaultTemplate{
                                arrayOfResultSettingTemplateType.add(defaultTemplate.type ?? "list")
                                arrayOfResultSettingLayOutType.add(defaultTemplate.layout?.layoutType ?? "l1")
                                arrayOfResultSettingIsClickable.add(defaultTemplate.layout?.isClickable ?? true)
                                arrayOfResultSettingListType.add(defaultTemplate.layout?.listType ?? "plain")
                                arrayOfResultSettingTextAlignment.add(defaultTemplate.layout?.textAlignment ?? "center")
                                
                                arrayOfResultSettingHeading.add(defaultTemplate.mapping?.heading ?? "")
                                arrayOfResultSettingDescription.add(defaultTemplate.mapping?.descrip ?? "")
                                arrayOfResultSettingImg.add(defaultTemplate.mapping?.img ?? "")
                                arrayOfResultSettingUrl.add(defaultTemplate.mapping?.url ?? "")
                            }
                        }
                    }
                    /* if condtion?.fieldValue == "file"{
                     liveSearchFileTemplateType = condtion?.template?.type ?? "listTemplate1"
                     fileLayOutType = condtion?.template?.layout?.layoutType ?? "tileWithText"
                     isFileClickable = condtion?.template?.layout?.isClickable ?? true
                     fileListType =  condtion?.template?.layout?.listType ?? "plain"
                     fileTextAlignment =  condtion?.template?.layout?.textAlignment ?? "center"
                     
                     fileHeading = condtion?.template?.mapping?.heading ?? ""
                     fileDescription = condtion?.template?.mapping?.descrip ?? ""
                     fileImg = condtion?.template?.mapping?.img ?? ""
                     fileUrl = condtion?.template?.mapping?.url ?? ""
                     
                     }else if condtion?.fieldValue == "faq"{
                     liveSearchFAQsTemplateType = condtion?.template?.type ?? "listTemplate1"
                     faqLayOutType = condtion?.template?.layout?.layoutType ??  "tileWithText"
                     isFaqsClickable = condtion?.template?.layout?.isClickable ?? true
                     faqListType =  condtion?.template?.layout?.listType ?? "plain"
                     faqTextAlignment =  condtion?.template?.layout?.textAlignment ?? "center"
                     
                     faqHeading = condtion?.template?.mapping?.heading ?? ""
                     faqDescription = condtion?.template?.mapping?.descrip ?? ""
                     faqImg = condtion?.template?.mapping?.img ?? ""
                     faqUrl = condtion?.template?.mapping?.url ?? ""
                     
                     }else if condtion?.fieldValue == "web"{
                     liveSearchPageTemplateType = condtion?.template?.type ?? "listTemplate1"
                     pageLayOutType = condtion?.template?.layout?.layoutType ?? "tileWithImage"
                     isPagesClickable = condtion?.template?.layout?.isClickable ?? true
                     pageListType =  condtion?.template?.layout?.listType ?? "plain"
                     pageTextAlignment =  condtion?.template?.layout?.textAlignment ?? "center"
                     
                     webHeading = condtion?.template?.mapping?.heading ?? ""
                     webDescription = condtion?.template?.mapping?.descrip ?? ""
                     webImg = condtion?.template?.mapping?.img ?? ""
                     webUrl = condtion?.template?.mapping?.url ?? ""
                     
                     }else if condtion?.fieldValue == "data"{
                     liveSearchDataTemplateType = condtion?.template?.type ?? "listTemplate1"
                     dataLayOutType = condtion?.template?.layout?.layoutType ?? "tileWithText"
                     isDataClickable = condtion?.template?.layout?.isClickable ?? true
                     dataListType =  condtion?.template?.layout?.listType ?? "plain"
                     dataTextAlignment =  condtion?.template?.layout?.textAlignment ?? "center"
                     
                     dataHeading = condtion?.template?.mapping?.heading ?? ""
                     dataDescription = condtion?.template?.mapping?.descrip ?? ""
                     dataImg = condtion?.template?.mapping?.img ?? ""
                     dataUrl = condtion?.template?.mapping?.url ?? ""
                     }else if condtion?.fieldValue == "task"{
                     
                     }*/
                    
                }
            }
        }
        
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
        self.tableView.register(UINib(nibName: CarouselTableViewCellIdentifier, bundle: nil), forCellReuseIdentifier: CarouselTableViewCellIdentifier)
        
        
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
                    searchRequestId = allItems.requestId
                    self.hashMapDic = jsonObject as NSDictionary
                    self.headerArray = []
                    headerArrayDisplay = []
                    self.faqsExpandArray = []
                    self.pagesExpandArray = []
                    self.likeAndDislikeArray = []
                    self.headersExpandArray = []
                    
                    // ...........
                    self.arrayOfLiveSearchTemplateType = []
                    self.arrayOfLayOutType = []
                    self.arrayOfIsClickable = []
                    self.arrayOfListType = []
                    self.arrayOfTextAlignment = []
                     
                    self.arrayOfHeading = []
                    self.arrayOfDescription = []
                    self.arrayOfImg = []
                    self.arrayOfUrl = []
                     
                    self.arrayOfSearchResults = []
                    self.arrayOfSearchResultsExpand = []
                    self.arrayOfSearchResultsLikeDislike = []
                    
                    let resultType =  ((self.hashMapDic.object(forKey: "template") as AnyObject).object(forKey: "resultType") as? String)
                    self.resultTypeString = resultType
                    if self.resultTypeString  == self.resultTypeFlatString{
                        
                        let mappingResults = ((self.hashMapDic.object(forKey: "template") as AnyObject).object(forKey: "results") as AnyObject)
                        let mappingResultDic = mappingResults
                        if let resultDic = mappingResultDic as? [String: Any]{
                            guard let jsonData = try? JSONSerialization.data(withJSONObject: resultDic["data"] as Any , options: .prettyPrinted),
                                  let allItems = try? jsonDecoder.decode([TemplateResultElements].self, from: jsonData) else {
                                return
                            }
                            print(allItems)
                            self.arrayOfSearchResults.add(allItems)
                            
                            self.headerArray.append("")
                            self.headersExpandArray.add("open")
                            
                            let expandArray = NSMutableArray()
                            let likeDislikeArray = NSMutableArray()
                            for _ in 0..<allItems.count{
                                expandArray.add("close")
                                likeDislikeArray.add("")
                            }
                            self.arrayOfSearchResultsExpand.add(expandArray)
                            self.arrayOfSearchResultsLikeDislike.add(likeDislikeArray)
                            
                            if self.arrayOfResultSettingTemplateType.count > 0{
                                self.arrayOfLiveSearchTemplateType.add(self.arrayOfResultSettingTemplateType[0] as Any)
                                self.arrayOfLayOutType.add(self.arrayOfResultSettingLayOutType[0] as Any)
                                self.arrayOfIsClickable.add(self.arrayOfResultSettingIsClickable[0] as Any)
                                self.arrayOfListType.add(self.arrayOfResultSettingListType[0] as Any)
                                self.arrayOfTextAlignment.add(self.arrayOfResultSettingTextAlignment[0] as Any)
                                
                                self.arrayOfHeading.add(self.arrayOfResultSettingHeading[0] as Any)
                                self.arrayOfDescription.add(self.arrayOfResultSettingDescription[0] as Any)
                                self.arrayOfImg.add(self.arrayOfResultSettingImg[0] as Any)
                                self.arrayOfUrl.add(self.arrayOfResultSettingUrl[0] as Any)
                                
                            }
                        }
                        
                    }else{
                        
                    for i in 0..<self.headerNArray.count{
                        let results = self.headerNArray[i]
                        let mappingResults = ((self.hashMapDic.object(forKey: "template") as AnyObject).object(forKey: "results") as AnyObject)
                        let mappingResultDic = (mappingResults.object(forKey: results) as AnyObject)
                        print(mappingResultDic)
                        if let resultDic = mappingResultDic as? [String: Any]{
                            guard let jsonData = try? JSONSerialization.data(withJSONObject: resultDic["data"] as Any , options: .prettyPrinted),
                                  let allItems = try? jsonDecoder.decode([TemplateResultElements].self, from: jsonData) else {
                                return
                            }
                            print(allItems)
                            self.arrayOfSearchResults.add(allItems)
                            
                            self.headerArray.append(self.headerNArray[i])
                            self.headersExpandArray.add("open")
                            
                            let expandArray = NSMutableArray()
                            let likeDislikeArray = NSMutableArray()
                            for _ in 0..<allItems.count{
                                expandArray.add("close")
                                likeDislikeArray.add("")
                            }
                            self.arrayOfSearchResultsExpand.add(expandArray)
                            self.arrayOfSearchResultsLikeDislike.add(likeDislikeArray)
                            
                            self.arrayOfLiveSearchTemplateType.add(self.arrayOfResultSettingTemplateType[i] as Any)
                            self.arrayOfLayOutType.add(self.arrayOfResultSettingLayOutType[i] as Any)
                            self.arrayOfIsClickable.add(self.arrayOfResultSettingIsClickable[i] as Any)
                            self.arrayOfListType.add(self.arrayOfResultSettingListType[i] as Any)
                            self.arrayOfTextAlignment.add(self.arrayOfResultSettingTextAlignment[i] as Any)
                            
                            self.arrayOfHeading.add(self.arrayOfResultSettingHeading[i] as Any)
                            self.arrayOfDescription.add(self.arrayOfResultSettingDescription[i] as Any)
                            self.arrayOfImg.add(self.arrayOfResultSettingImg[i] as Any)
                            self.arrayOfUrl.add(self.arrayOfResultSettingUrl[i] as Any)
                            
                        }
                    }
                    }
                    print(self.headerArray)
                    
                   /*
                    //FAQS
                    let faqs = allItems.template?.results?.faq?.data
                    self.arrayOfFaqResults = faqs ?? []
                    if self.arrayOfFaqResults.count > 0 {
                        self.headerArray.append(LiveSearchHeaderTypes.faq.rawValue)
                        headerArrayDisplay.add("Faqs")
                        self.headersExpandArray.add("open")
                    }
                    for _ in 0..<self.arrayOfFaqResults.count{
                        self.faqsExpandArray.add("close")
                        self.likeAndDislikeArray.add("")
                    }
                    //Page Or Web
                    let pages = allItems.template?.results?.page?.data
                    self.arrayOfPageResults = pages ?? []
                    if self.arrayOfPageResults.count > 0 {
                        self.headerArray.append(LiveSearchHeaderTypes.web.rawValue)
                        headerArrayDisplay.add("Web")
                        self.headersExpandArray.add("open")
                    }
                    for _ in 0..<self.arrayOfPageResults.count{
                        self.pagesExpandArray.add("close")
                    }
                    //Tasks
                    let task = allItems.template?.results?.task?.data
                    self.arrayOfTaskResults = task ?? []
                    if self.arrayOfTaskResults.count > 0 {
                        self.headerArray.append(LiveSearchHeaderTypes.task.rawValue)
                        headerArrayDisplay.add("Tasks")
                        self.headersExpandArray.add("open")
                    }
                    //Files
                    let files = allItems.template?.results?.file?.data
                    self.arrayOfFileResults = files ?? []
                    if self.arrayOfFileResults.count > 0 {
                        self.headerArray.append(LiveSearchHeaderTypes.file.rawValue)
                        headerArrayDisplay.add("Files")
                        self.headersExpandArray.add("open")
                    }
                    for _ in 0..<self.arrayOfFileResults.count{
                        self.filesExpandArray.add("close")
                    }
                    //Data
                    let data = allItems.template?.results?.data?.data
                    self.arrayOfDataResults = data ?? []
                    if self.arrayOfDataResults.count > 0 {
                        self.headerArray.append(LiveSearchHeaderTypes.data.rawValue)
                        headerArrayDisplay.add("Data")
                        self.headersExpandArray.add("open")
                    }
                    for _ in 0..<self.arrayOfDataResults.count{
                        self.dataExpandArray.add("close")
                    }*/
                    
                    self.titleLbl.text = "Sure, please find the matched results below"
                    //totalNumOfResults =  allItems.template?.totalNumOfResults
                    if let searchTemplateTabFacet = allItems.template?.tabFacet{
                        totalNumOfResults = 0
                        if let bucket = searchTemplateTabFacet.buckets{
                            for i in 0..<bucket.count{
                                let result = bucket[i]
                                let count = result.doc_count ?? 0
                                totalNumOfResults  += count
                            }
                        }
                    }
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
        let tableViewHeight = tableView.contentSize.height < 120 ? 120 : tableView.contentSize.height
        return CGSize(width: 0.0, height: textSize.height+tableViewHeight+30)  //150
    }
    
    @objc fileprivate func showMoreButtonAction(_ sender: UIButton!) {
        let component: KREComponent = components.firstObject as! KREComponent
        if (component.componentDesc != nil) {
            let jsonString = component.componentDesc
            
            NotificationCenter.default.post(name: Notification.Name(showLiveSearchTemplateNotification), object: jsonString! + ",,\([headerArray[sender.tag]])")
            /*
            let headerName:LiveSearchHeaderTypes = LiveSearchHeaderTypes(rawValue: headerArray[sender.tag])!
            switch headerName {
            case .faq:
                NotificationCenter.default.post(name: Notification.Name(showLiveSearchTemplateNotification), object: jsonString! + ",,\(LiveSearchSysContentTypes.faq.rawValue)")
            case .web:
               NotificationCenter.default.post(name: Notification.Name(showLiveSearchTemplateNotification), object: jsonString! + ",,\(LiveSearchSysContentTypes.web.rawValue)")
            case .file:
                NotificationCenter.default.post(name: Notification.Name(showLiveSearchTemplateNotification), object: jsonString! + ",,\(LiveSearchSysContentTypes.file.rawValue)")
            case .data:
                NotificationCenter.default.post(name: Notification.Name(showLiveSearchTemplateNotification), object: jsonString! + ",,\(LiveSearchSysContentTypes.data.rawValue)")
            case .task:
                NotificationCenter.default.post(name: Notification.Name(showLiveSearchTemplateNotification), object: jsonString! + ",,\(LiveSearchSysContentTypes.task.rawValue)")
            }*/
        }
    }
    
    @objc fileprivate func showMoreFooterButtonAction(_ sender: AnyObject!) {
        let component: KREComponent = components.firstObject as! KREComponent
        if (component.componentDesc != nil) {
            let jsonString = component.componentDesc
            NotificationCenter.default.post(name: Notification.Name(showLiveSearchTemplateNotification), object: jsonString! + ",,All")
        }
    }
}

extension LiveSearchBubbleView: UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
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
        return   heightForTable(resultExpandArray: (arrayOfSearchResultsExpand[indexPath.section] as? NSMutableArray)!, layoutType: arrayOfLayOutType[indexPath.section] as! String, TemplateType: arrayOfLiveSearchTemplateType[indexPath.section] as! String, indexPath: indexPath)
        /*let headerName:LiveSearchHeaderTypes = LiveSearchHeaderTypes(rawValue: headerArray[indexPath.section])!
                switch headerName {
                case .faq:
                    return   heightForTable(resultExpandArray: faqsExpandArray, layoutType: faqLayOutType, TemplateType: liveSearchFAQsTemplateType, index: indexPath.row)
                case .web:
                    return   heightForTable(resultExpandArray: pagesExpandArray, layoutType: pageLayOutType, TemplateType: liveSearchPageTemplateType, index: indexPath.row)
                case .file:
                    return   heightForTable(resultExpandArray: filesExpandArray, layoutType: fileLayOutType, TemplateType: liveSearchFileTemplateType, index: indexPath.row)
                case .data:
                    return   heightForTable(resultExpandArray: dataExpandArray, layoutType: dataLayOutType, TemplateType: liveSearchDataTemplateType, index: indexPath.row)
                case .task:
                    return UITableView.automaticDimension
                }*/
               
            }
    func numberOfSections(in tableView: UITableView) -> Int {
        return headerArray.count //> 3 ? 3 : headerArray.count //sectionAndRowsLimit
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if headersExpandArray [section] as! String == "open"{
            if arrayOfLiveSearchTemplateType[section] as? String == LiveSearchTypes.grid.rawValue || arrayOfLiveSearchTemplateType[section] as? String == LiveSearchTypes.carousel.rawValue{
                return 1
            }else{
                let rowsCount = (arrayOfSearchResults[section] as AnyObject).count > sectionAndRowsLimit ? sectionAndRowsLimit : (arrayOfSearchResults[section] as AnyObject).count
                return rowsCount ?? 0
            }
            
        }
        return 0
        /*let headerName: LiveSearchHeaderTypes = LiveSearchHeaderTypes(rawValue: headerArray[section])!
        switch headerName {
        case .faq:
            if headersExpandArray [section] as! String == "open"{
                if liveSearchFAQsTemplateType == LiveSearchTypes.grid.rawValue || liveSearchFAQsTemplateType == LiveSearchTypes.carousel.rawValue{
                    return 1
                }
                return arrayOfFaqResults.count > sectionAndRowsLimit ? sectionAndRowsLimit : arrayOfFaqResults.count
            }
            return 0
        case .web:
            if headersExpandArray [section] as! String == "open"{
                if liveSearchPageTemplateType == LiveSearchTypes.grid.rawValue || liveSearchPageTemplateType == LiveSearchTypes.carousel.rawValue{
                    return 1
                }
                return arrayOfPageResults.count > sectionAndRowsLimit ? sectionAndRowsLimit : arrayOfPageResults.count
            }
            return 0
        case .task:
            if headersExpandArray [section] as! String == "open"{
                return arrayOfTaskResults.count > sectionAndRowsLimit ? sectionAndRowsLimit : arrayOfTaskResults.count
            }
            return 0
        case .file:
            if headersExpandArray [section] as! String == "open"{
                if liveSearchFileTemplateType == LiveSearchTypes.grid.rawValue || liveSearchFileTemplateType == LiveSearchTypes.carousel.rawValue{
                    return 1
                }
                return arrayOfFileResults.count > sectionAndRowsLimit ? sectionAndRowsLimit : arrayOfFileResults.count
            }
            return 0
        case .data:
            if headersExpandArray [section] as! String == "open"{
                if liveSearchDataTemplateType == LiveSearchTypes.grid.rawValue || liveSearchDataTemplateType == LiveSearchTypes.carousel.rawValue{
                    return 1
                }
                return arrayOfDataResults.count > sectionAndRowsLimit ? sectionAndRowsLimit : arrayOfDataResults.count
            }
            return 0
        }*/
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let mappingResults = ((hashMapDic.object(forKey: "template") as AnyObject).object(forKey: "results") as AnyObject)
        let headerName = headerArray[indexPath.section]
        if arrayOfLiveSearchTemplateType[indexPath.section] as? String == LiveSearchTypes.grid.rawValue {
            let cell = tableView.dequeueReusableCell(withIdentifier: GridTableViewCellIdentifier, for: indexPath) as! GridTableViewCell
            
            var mappingResultDic:AnyObject?
            if self.resultTypeString  == self.resultTypeFlatString{
                mappingResultDic = mappingResults
            }else{
                mappingResultDic = (mappingResults.object(forKey: "\(headerName)") as AnyObject)
            }
            if let hashMapArray = mappingResultDic?["data"] as? NSArray{
                cell.configure(with: arrayOfSearchResults[indexPath.section] as! [TemplateResultElements], appearanceType: headerName, layOutType: arrayOfLayOutType[indexPath.section] as! String, templateType:arrayOfLiveSearchTemplateType[indexPath.section] as! String, hashMapArray: hashMapArray , isSearchScreen: isSearchType, headingStr: arrayOfHeading[indexPath.section] as! String, descriptionStr: arrayOfDescription[indexPath.section] as! String, imageStr: arrayOfImg[indexPath.section] as! String, urlStr: arrayOfUrl[indexPath.section] as! String)
            }
            return cell
        }else if arrayOfLiveSearchTemplateType[indexPath.section] as? String == LiveSearchTypes.carousel.rawValue{
            let cell = tableView.dequeueReusableCell(withIdentifier: CarouselTableViewCellIdentifier, for: indexPath) as! CarouselTableViewCell
            var mappingResultDic:AnyObject?
            if self.resultTypeString  == self.resultTypeFlatString{
                mappingResultDic = mappingResults
            }else{
                mappingResultDic = (mappingResults.object(forKey: "\(headerName)") as AnyObject)
            }
            if let hashMapArray = mappingResultDic?["data"] as? NSArray{
                cell.configure(with: arrayOfSearchResults[indexPath.section] as! [TemplateResultElements], appearanceType: headerName, layOutType: arrayOfLayOutType[indexPath.section] as! String, templateType:arrayOfLiveSearchTemplateType[indexPath.section] as! String, hashMapArray: hashMapArray , isSearchScreen: isSearchType, headingStr: arrayOfHeading[indexPath.section] as! String, descriptionStr: arrayOfDescription[indexPath.section] as! String, imageStr: arrayOfImg[indexPath.section] as! String, urlStr: arrayOfUrl[indexPath.section] as! String)
            }
            return cell
        }else{
            let layOutType :LiveSearchLayoutTypes = LiveSearchLayoutTypes(rawValue: arrayOfLayOutType[indexPath.section] as! String)!
            switch layOutType {
            case .descriptionText:
                  let cell : LiveSearchFaqTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: liveSearchFaqCellIdentifier) as! LiveSearchFaqTableViewCell
                descriptionTextCellMethod(cell: cell, cellResultArray: arrayOfSearchResults[indexPath.section] as! [TemplateResultElements], expandArray: arrayOfSearchResultsExpand[indexPath.section] as! NSMutableArray, indexPath: indexPath, isClickable: arrayOfIsClickable[indexPath.section] as! Bool, templateType: arrayOfListType[indexPath.section] as! String, appearanceType: headerName)
            return cell
            case .tileWithText:
                let cell : LiveSearchFaqTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: liveSearchFaqCellIdentifier) as! LiveSearchFaqTableViewCell
                titleWithTextCellMethod(cell: cell, cellResultArray: arrayOfSearchResults[indexPath.section] as! [TemplateResultElements], expandArray: arrayOfSearchResultsExpand[indexPath.section] as! NSMutableArray, indexPath: indexPath, isClickable: arrayOfIsClickable[indexPath.section] as! Bool, templateType: arrayOfListType[indexPath.section] as! String, appearanceType: headerName)
                return cell
            case .tileWithImage:
                let cell : TitleWithImageCell = self.tableView.dequeueReusableCell(withIdentifier: titleWithImageCellIdentifier) as! TitleWithImageCell
                titleWithImageCellMethod(cell: cell, cellResultArray: arrayOfSearchResults[indexPath.section] as! [TemplateResultElements], expandArray: arrayOfSearchResultsExpand[indexPath.section] as! NSMutableArray, indexPath: indexPath, isClickable: arrayOfIsClickable[indexPath.section] as! Bool, templateType: arrayOfListType[indexPath.section] as! String, appearanceType: headerName)
                return cell
            case .tileWithCenteredContent:
                let cell : TitleWithCenteredContentCell = self.tableView.dequeueReusableCell(withIdentifier: titleWithCenteredContentCellIdentifier) as! TitleWithCenteredContentCell
                titleWithCenteredContentCellMethod(cell: cell, cellResultArray: arrayOfSearchResults[indexPath.section] as! [TemplateResultElements], expandArray: arrayOfSearchResultsExpand[indexPath.section] as! NSMutableArray, indexPath: indexPath, isClickable: arrayOfIsClickable[indexPath.section] as! Bool, templateType: arrayOfListType[indexPath.section] as! String, appearanceType: headerName)
                return cell
            case .tileWithHeader:
                let cell : TitleWithHeaderCell = self.tableView.dequeueReusableCell(withIdentifier: TitleWithHeaderCellIdentifier) as! TitleWithHeaderCell
                TitleWithHeaderCellMethod(cell: cell, cellResultArray: arrayOfSearchResults[indexPath.section] as! [TemplateResultElements], expandArray: arrayOfSearchResultsExpand[indexPath.section] as! NSMutableArray, indexPath: indexPath, isClickable: arrayOfIsClickable[indexPath.section] as! Bool, templateType: arrayOfListType[indexPath.section] as! String, appearanceType: headerName, textAlignment: arrayOfTextAlignment[indexPath.section] as! String)
                return cell
            }
        }
        /*let headerName: LiveSearchHeaderTypes = LiveSearchHeaderTypes(rawValue: headerArray[indexPath.section])!
        switch headerName {
        case .faq:
            if liveSearchFAQsTemplateType == LiveSearchTypes.grid.rawValue {
                let cell = tableView.dequeueReusableCell(withIdentifier: GridTableViewCellIdentifier, for: indexPath) as! GridTableViewCell
                
                let mappingResultDic = (mappingResults.object(forKey: "faq") as AnyObject)
                if let hashMapArray = mappingResultDic["data"] as? NSArray{
                    cell.configureNew(with: arrayOfFaqResults, appearanceType: headerName.rawValue, layOutType: faqLayOutType, templateType:liveSearchFAQsTemplateType, hashMapArray: hashMapArray , isSearchScreen: isSearchType)
                }
                return cell
            }else if liveSearchFAQsTemplateType == LiveSearchTypes.carousel.rawValue{
                let cell = tableView.dequeueReusableCell(withIdentifier: CarouselTableViewCellIdentifier, for: indexPath) as! CarouselTableViewCell
                //cell.configure(with: arrayOfFaqResults, appearanceType: headerName.rawValue, layOutType: faqLayOutType, templateType:liveSearchFAQsTemplateType)
                let mappingResultDic = (mappingResults.object(forKey: "faq") as AnyObject)
                if let hashMapArray = mappingResultDic["data"] as? NSArray{
                    cell.configureNew(with: arrayOfFaqResults, appearanceType: headerName.rawValue, layOutType: faqLayOutType, templateType:liveSearchFAQsTemplateType, hashMapArray: hashMapArray , isSearchScreen: isSearchType)
                }
                return cell
            }else{
                let layOutType :LiveSearchLayoutTypes = LiveSearchLayoutTypes(rawValue: faqLayOutType)!
                switch layOutType {
                case .descriptionText:
                    let cell : LiveSearchFaqTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: liveSearchFaqCellIdentifier) as! LiveSearchFaqTableViewCell
                    descriptionTextCellMethod(cell: cell, cellResultArray: arrayOfFaqResults, expandArray: faqsExpandArray, indexPath: indexPath, isClickable: isFaqsClickable, templateType: faqListType, appearanceType: headerName.rawValue)
                    return cell
                case .tileWithText:
                    let cell : LiveSearchFaqTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: liveSearchFaqCellIdentifier) as! LiveSearchFaqTableViewCell
                    titleWithTextCellMethod(cell: cell, cellResultArray: arrayOfFaqResults, expandArray: faqsExpandArray, indexPath: indexPath, isClickable: isFaqsClickable, templateType: faqListType, appearanceType: headerName.rawValue)
                    return cell
                case .tileWithImage:
                    let cell : TitleWithImageCell = self.tableView.dequeueReusableCell(withIdentifier: titleWithImageCellIdentifier) as! TitleWithImageCell
                    titleWithImageCellMethod(cell: cell, cellResultArray: arrayOfFaqResults, expandArray: faqsExpandArray, indexPath: indexPath, isClickable: isFaqsClickable, templateType: faqListType, appearanceType: headerName.rawValue)
                    return cell
                case .tileWithCenteredContent:
                    let cell : TitleWithCenteredContentCell = self.tableView.dequeueReusableCell(withIdentifier: titleWithCenteredContentCellIdentifier) as! TitleWithCenteredContentCell
                    titleWithCenteredContentCellMethod(cell: cell, cellResultArray: arrayOfFaqResults, expandArray: faqsExpandArray, indexPath: indexPath, isClickable: isFaqsClickable, templateType: faqListType, appearanceType: headerName.rawValue)
                    return cell
                case .tileWithHeader:
                    let cell : TitleWithHeaderCell = self.tableView.dequeueReusableCell(withIdentifier: TitleWithHeaderCellIdentifier) as! TitleWithHeaderCell
                    TitleWithHeaderCellMethod(cell: cell, cellResultArray: arrayOfFaqResults, expandArray: faqsExpandArray, indexPath: indexPath, isClickable: isFaqsClickable, templateType: faqListType, appearanceType: headerName.rawValue, textAlignment: faqTextAlignment)
                    return cell
                }
            }
        case .web:
            if liveSearchPageTemplateType == LiveSearchTypes.grid.rawValue {
                let cell = tableView.dequeueReusableCell(withIdentifier: GridTableViewCellIdentifier, for: indexPath) as! GridTableViewCell
                //cell.configure(with: arrayOfPageResults, appearanceType: headerName.rawValue, layOutType: pageLayOutType, templateType:liveSearchPageTemplateType)
                //let hashMapArray = (mappingResults.object(forKey: "web") as AnyObject)
                let mappingResultDic = (mappingResults.object(forKey: "web") as AnyObject)
                if let hashMapArray = mappingResultDic["data"] as? NSArray{
                    cell.configureNew(with: arrayOfPageResults, appearanceType: headerName.rawValue, layOutType: pageLayOutType, templateType:liveSearchPageTemplateType, hashMapArray: hashMapArray , isSearchScreen: isSearchType)
                }
                return cell
            }else if liveSearchPageTemplateType == LiveSearchTypes.carousel.rawValue{
                let cell = tableView.dequeueReusableCell(withIdentifier: CarouselTableViewCellIdentifier, for: indexPath) as! CarouselTableViewCell
                //cell.configure(with: arrayOfPageResults, appearanceType: headerName.rawValue, layOutType: pageLayOutType, templateType:liveSearchPageTemplateType)
                //let hashMapArray = (mappingResults.object(forKey: "web") as AnyObject)
                let mappingResultDic = (mappingResults.object(forKey: "web") as AnyObject)
                if let hashMapArray = mappingResultDic["data"] as? NSArray{
                    cell.configureNew(with: arrayOfPageResults, appearanceType: headerName.rawValue, layOutType: pageLayOutType, templateType:liveSearchPageTemplateType, hashMapArray: hashMapArray , isSearchScreen: isSearchType)
                }
                return cell
            }else{
                let layOutType :LiveSearchLayoutTypes = LiveSearchLayoutTypes(rawValue: pageLayOutType)!
                switch layOutType {
                case .descriptionText:
                    let cell : LiveSearchFaqTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: liveSearchFaqCellIdentifier) as! LiveSearchFaqTableViewCell
                    descriptionTextCellMethod(cell: cell, cellResultArray: arrayOfPageResults, expandArray: pagesExpandArray, indexPath: indexPath, isClickable: isPagesClickable, templateType: pageListType, appearanceType: headerName.rawValue)
                    return cell
                case .tileWithText:
                    let cell : LiveSearchFaqTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: liveSearchFaqCellIdentifier) as! LiveSearchFaqTableViewCell
                    titleWithTextCellMethod(cell: cell, cellResultArray: arrayOfPageResults, expandArray: pagesExpandArray, indexPath: indexPath, isClickable: isPagesClickable, templateType: pageListType, appearanceType: headerName.rawValue)
                    return cell
                case .tileWithImage:
                    let cell : TitleWithImageCell = self.tableView.dequeueReusableCell(withIdentifier: titleWithImageCellIdentifier) as! TitleWithImageCell
                    titleWithImageCellMethod(cell: cell, cellResultArray: arrayOfPageResults, expandArray:
                        pagesExpandArray, indexPath: indexPath, isClickable: isPagesClickable, templateType: pageListType, appearanceType: headerName.rawValue)
                    return cell
                case .tileWithCenteredContent:
                    let cell : TitleWithCenteredContentCell = self.tableView.dequeueReusableCell(withIdentifier: titleWithCenteredContentCellIdentifier) as! TitleWithCenteredContentCell
                    titleWithCenteredContentCellMethod(cell: cell, cellResultArray: arrayOfPageResults, expandArray: pagesExpandArray, indexPath: indexPath, isClickable: isPagesClickable, templateType: pageListType, appearanceType: headerName.rawValue)
                    return cell
                case .tileWithHeader:
                    let cell : TitleWithHeaderCell = self.tableView.dequeueReusableCell(withIdentifier: TitleWithHeaderCellIdentifier) as! TitleWithHeaderCell
                    TitleWithHeaderCellMethod(cell: cell, cellResultArray: arrayOfPageResults, expandArray: pagesExpandArray, indexPath: indexPath, isClickable: isPagesClickable, templateType: pageListType, appearanceType: headerName.rawValue, textAlignment: pageTextAlignment)
                    return cell
                }
            }
            
        case .file:
            if liveSearchFileTemplateType == LiveSearchTypes.grid.rawValue {
                let cell = tableView.dequeueReusableCell(withIdentifier: GridTableViewCellIdentifier, for: indexPath) as! GridTableViewCell
//                cell.configure(with: arrayOfFileResults, appearanceType: headerName.rawValue, layOutType: fileLayOutType, templateType:liveSearchFileTemplateType)
               // let hashMapArray = (mappingResults.object(forKey: "file") as AnyObject)
                let mappingResultDic = (mappingResults.object(forKey: "file") as AnyObject)
                if let hashMapArray = mappingResultDic["data"] as? NSArray{
                    cell.configureNew(with: arrayOfFileResults, appearanceType: headerName.rawValue, layOutType: fileLayOutType, templateType:liveSearchFileTemplateType, hashMapArray: hashMapArray , isSearchScreen: isSearchType)
                }
               
                return cell
            }else if liveSearchFileTemplateType == LiveSearchTypes.carousel.rawValue{
                let cell = tableView.dequeueReusableCell(withIdentifier: CarouselTableViewCellIdentifier, for: indexPath) as! CarouselTableViewCell
//                cell.configure(with: arrayOfFileResults, appearanceType: headerName.rawValue, layOutType: fileLayOutType, templateType:liveSearchFileTemplateType)
               // let hashMapArray = (mappingResults.object(forKey: "file") as AnyObject)
                let mappingResultDic = (mappingResults.object(forKey: "file") as AnyObject)
                if let hashMapArray = mappingResultDic["data"] as? NSArray{
                    cell.configureNew(with: arrayOfFileResults, appearanceType: headerName.rawValue, layOutType: fileLayOutType, templateType:liveSearchFileTemplateType, hashMapArray: hashMapArray , isSearchScreen: isSearchType)
                }
               
                return cell
            }else{
                let layOutType :LiveSearchLayoutTypes = LiveSearchLayoutTypes(rawValue: fileLayOutType)!
                switch layOutType {
                case .descriptionText:
                    let cell : LiveSearchFaqTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: liveSearchFaqCellIdentifier) as! LiveSearchFaqTableViewCell
                    descriptionTextCellMethod(cell: cell, cellResultArray: arrayOfFileResults, expandArray: filesExpandArray, indexPath: indexPath, isClickable: isFileClickable, templateType: fileListType, appearanceType: headerName.rawValue)
                    return cell
                case .tileWithText:
                    let cell : LiveSearchFaqTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: liveSearchFaqCellIdentifier) as! LiveSearchFaqTableViewCell
                    titleWithTextCellMethod(cell: cell, cellResultArray: arrayOfFileResults, expandArray: filesExpandArray, indexPath: indexPath, isClickable: isFileClickable, templateType: fileListType, appearanceType: headerName.rawValue)
                    return cell
                case .tileWithImage:
                    let cell : TitleWithImageCell = self.tableView.dequeueReusableCell(withIdentifier: titleWithImageCellIdentifier) as! TitleWithImageCell
                    titleWithImageCellMethod(cell: cell, cellResultArray: arrayOfFileResults, expandArray:
                        filesExpandArray, indexPath: indexPath, isClickable: isFileClickable, templateType: fileListType, appearanceType: headerName.rawValue)
                    return cell
                case .tileWithCenteredContent:
                    let cell : TitleWithCenteredContentCell = self.tableView.dequeueReusableCell(withIdentifier: titleWithCenteredContentCellIdentifier) as! TitleWithCenteredContentCell
                    titleWithCenteredContentCellMethod(cell: cell, cellResultArray: arrayOfFileResults, expandArray: filesExpandArray, indexPath: indexPath, isClickable: isFileClickable, templateType: fileListType, appearanceType: headerName.rawValue)
                    return cell
                case .tileWithHeader:
                    let cell : TitleWithHeaderCell = self.tableView.dequeueReusableCell(withIdentifier: TitleWithHeaderCellIdentifier) as! TitleWithHeaderCell
                    TitleWithHeaderCellMethod(cell: cell, cellResultArray: arrayOfFileResults, expandArray: filesExpandArray, indexPath: indexPath, isClickable: isFileClickable, templateType: fileListType, appearanceType: headerName.rawValue, textAlignment: fileTextAlignment)
                    return cell
                }
            }
            
        case .data:
            if liveSearchDataTemplateType == LiveSearchTypes.grid.rawValue {
                let cell = tableView.dequeueReusableCell(withIdentifier: GridTableViewCellIdentifier, for: indexPath) as! GridTableViewCell
//                cell.configure(with: arrayOfDataResults, appearanceType: headerName.rawValue, layOutType: dataLayOutType, templateType: liveSearchDataTemplateType)
                //let hashMapArray = (mappingResults.object(forKey: "data") as AnyObject)
                let mappingResultDic = (mappingResults.object(forKey: "default_group") as AnyObject)
                if let hashMapArray = mappingResultDic["data"] as? NSArray{
                    cell.configureNew(with: arrayOfDataResults, appearanceType: headerName.rawValue, layOutType: dataLayOutType, templateType: liveSearchDataTemplateType, hashMapArray: hashMapArray , isSearchScreen: isSearchType)
                }
                return cell
            }else if liveSearchDataTemplateType == LiveSearchTypes.carousel.rawValue{
                let cell = tableView.dequeueReusableCell(withIdentifier: CarouselTableViewCellIdentifier, for: indexPath) as! CarouselTableViewCell
//                cell.configure(with: arrayOfDataResults, appearanceType: headerName.rawValue, layOutType: dataLayOutType, templateType: liveSearchDataTemplateType)
                //let hashMapArray = (mappingResults.object(forKey: "data") as AnyObject)
                let mappingResultDic = (mappingResults.object(forKey: "default_group") as AnyObject)
                if let hashMapArray = mappingResultDic["data"] as? NSArray{
                    cell.configureNew(with: arrayOfDataResults, appearanceType: headerName.rawValue, layOutType: dataLayOutType, templateType: liveSearchDataTemplateType, hashMapArray: hashMapArray , isSearchScreen: isSearchType)
                }
                return cell
            }else{
                let layOutType :LiveSearchLayoutTypes = LiveSearchLayoutTypes(rawValue:  dataLayOutType)!
                switch layOutType {
                case .descriptionText:
                    let cell : LiveSearchFaqTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: liveSearchFaqCellIdentifier) as! LiveSearchFaqTableViewCell
                    descriptionTextCellMethod(cell: cell, cellResultArray: arrayOfDataResults, expandArray: dataExpandArray, indexPath: indexPath, isClickable: isDataClickable, templateType: dataListType, appearanceType: headerName.rawValue)
                    return cell
                case .tileWithText:
                    let cell : LiveSearchFaqTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: liveSearchFaqCellIdentifier) as! LiveSearchFaqTableViewCell
                    titleWithTextCellMethod(cell: cell, cellResultArray: arrayOfDataResults, expandArray: dataExpandArray, indexPath: indexPath, isClickable: isDataClickable, templateType: dataListType, appearanceType: headerName.rawValue)
                    return cell
                case .tileWithImage:
                    let cell : TitleWithImageCell = self.tableView.dequeueReusableCell(withIdentifier: titleWithImageCellIdentifier) as! TitleWithImageCell
                    titleWithImageCellMethod(cell: cell, cellResultArray: arrayOfDataResults, expandArray:
                        dataExpandArray, indexPath: indexPath, isClickable: isDataClickable, templateType: dataListType, appearanceType: headerName.rawValue)
                    return cell
                case .tileWithCenteredContent:
                    let cell : TitleWithCenteredContentCell = self.tableView.dequeueReusableCell(withIdentifier: titleWithCenteredContentCellIdentifier) as! TitleWithCenteredContentCell
                    titleWithCenteredContentCellMethod(cell: cell, cellResultArray: arrayOfDataResults, expandArray: dataExpandArray, indexPath: indexPath, isClickable: isDataClickable, templateType: dataListType, appearanceType: headerName.rawValue)
                    return cell
                case .tileWithHeader:
                    let cell : TitleWithHeaderCell = self.tableView.dequeueReusableCell(withIdentifier: TitleWithHeaderCellIdentifier) as! TitleWithHeaderCell
                    TitleWithHeaderCellMethod(cell: cell, cellResultArray: arrayOfDataResults, expandArray: dataExpandArray, indexPath: indexPath, isClickable: isDataClickable, templateType: dataListType, appearanceType: headerName.rawValue, textAlignment: dataTextAlignment)
                    return cell
                }
            }
            
        case .task:
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
            //cell.titleLabel.textColor = UIColor.init(red: 44/255, green: 128/255, blue: 248/255, alpha: 1.0)
            let results = arrayOfTaskResults[indexPath.row]
            cell.titleLabel?.text = "\(results.name!)     "
            cell.titleLabel?.layer.cornerRadius = 5.0
            cell.titleLabel?.layer.borderWidth = 0.0
            cell.titleLabel.layer.shadowOpacity = 0.7
            cell.titleLabel.layer.shadowOffset = CGSize(width: 2, height: 2)
            cell.titleLabel.layer.shadowRadius = 8.0
            //cell.titleLabel.clipsToBounds = false
            cell.titleLabel.layer.shadowColor = UIColor.init(red: 209/255, green: 217/255, blue: 224/255, alpha: 1.0).cgColor
           // cell.titleLabel?.layer.borderColor = UIColor.init(red: 44/255, green: 128/255, blue: 248/255, alpha: 1.0).cgColor
            return cell
        }*/
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let mappingResults = ((hashMapDic.object(forKey: "template") as AnyObject).object(forKey: "results") as AnyObject)
        if let isclickble = arrayOfIsClickable[indexPath.section] as? Bool, !isclickble{
            if let expandValues = arrayOfSearchResultsExpand[indexPath.section] as? NSMutableArray{
                if expandValues[indexPath.row] as! String == "close"{
                    expandValues.replaceObject(at: indexPath.row, with: "open")
                }else{
                    expandValues.replaceObject(at: indexPath.row, with: "close")
                }
                arrayOfSearchResultsExpand.replaceObject(at: indexPath.section, with: expandValues)
            }
            tableView.reloadData()
        }else{
            var mappingResultDic:AnyObject?
            if self.resultTypeString  == self.resultTypeFlatString{
                mappingResultDic = mappingResults
            }else{
                mappingResultDic = (mappingResults.object(forKey: "\(headerArray[indexPath.row])") as AnyObject)
            }
            if let hashMapArray = mappingResultDic?["data"] as? NSArray{
                let url = ((hashMapArray.object(at: indexPath.row) as AnyObject).object(forKey: "\(arrayOfUrl[indexPath.section])") as? String)
                   if url != "" {
                     self.linkAction(url!)
                 }
            }
        }
        
        /*
            let headerName:LiveSearchHeaderTypes = LiveSearchHeaderTypes(rawValue: headerArray[indexPath.section])!
            switch headerName {
            case .faq:
                if !isFaqsClickable{
                    if faqsExpandArray[indexPath.row] as! String == "close" {
                        faqsExpandArray.replaceObject(at: indexPath.row, with: "open")
                    }else{
                        faqsExpandArray.replaceObject(at: indexPath.row, with: "close")
                    }
                    tableView.reloadData()
                }else{
                    let mappingResultDic = (mappingResults.object(forKey: "faq") as AnyObject)
                    if let hashMapArray = mappingResultDic["data"] as? NSArray{
                        let url = ((hashMapArray.object(at: indexPath.row) as AnyObject).object(forKey: "\(faqUrl)") as? String)
                         if url != "" {
                             self.linkAction(url!)
                         }
                    }
                }
                
            case .web:
                if !isPagesClickable{
                    if pagesExpandArray[indexPath.row] as! String == "close" {
                        pagesExpandArray.replaceObject(at: indexPath.row, with: "open")
                    }else{
                        pagesExpandArray.replaceObject(at: indexPath.row, with: "close")
                    }
                    tableView.reloadData()
                }else{
                    let mappingResultDic = (mappingResults.object(forKey: "web") as AnyObject)
                    if let hashMapArray = mappingResultDic["data"] as? NSArray{
                        let url = (((mappingResults.object(forKey: "web") as AnyObject).object(at: indexPath.row) as AnyObject).object(forKey: "\(webUrl)") as? String)
                        if url != "" {
                                self.linkAction(url!)
                         }
                    }
                }
                break
            case .file:
                if !isFileClickable{
                    if filesExpandArray[indexPath.row] as! String == "close" {
                        filesExpandArray.replaceObject(at: indexPath.row, with: "open")
                    }else{
                        filesExpandArray.replaceObject(at: indexPath.row, with: "close")
                    }
                    tableView.reloadData()
                }else{
                    let mappingResultDic = (mappingResults.object(forKey: "file") as AnyObject)
                    if let hashMapArray = mappingResultDic["data"] as? NSArray{
                        let url = ((hashMapArray.object(at: indexPath.row) as AnyObject).object(forKey: "\(fileUrl)") as? String)
                        if url != "" {
                              self.linkAction(url!)
                       }
                    }
                     
                }
            case .data:
                if !isDataClickable{
                    if dataExpandArray[indexPath.row] as! String == "close" {
                        dataExpandArray.replaceObject(at: indexPath.row, with: "open")
                    }else{
                        dataExpandArray.replaceObject(at: indexPath.row, with: "close")
                    }
                    tableView.reloadData()
                }else{
                    let mappingResultDic = (mappingResults.object(forKey: "default_group") as AnyObject)
                    if let hashMapArray = mappingResultDic["data"] as? NSArray{
                        let url = ((hashMapArray.object(at: indexPath.row) as AnyObject).object(forKey: "\(dataUrl)") as? String)
                        if url != "" || url != nil{
                               self.linkAction(url!)
                        }
                    }
                }
            case .task:
                 if let payload = arrayOfTaskResults[indexPath.row].payload {
                    let taskData = NSMutableDictionary()
                    taskData.setValue(arrayOfTaskResults[indexPath.row].name, forKey: "intent")
                    if let childBotname =  arrayOfTaskResults[indexPath.row].childBotName{
                        taskData.setValue(childBotname, forKey: "childBotName")
                    }else{
                         taskData.setValue("null", forKey: "childBotName")
                    }
                    taskData.setValue(true, forKey: "isRefresh")
                    self.optionsTaskAction(arrayOfTaskResults[indexPath.row].name, payload, taskData as! [String : Any])
                }
                isEndOfTask = false //kk
                //if results.postBackPayload?.payload != nil{
                //    self.optionsAction(results.postBackPayload?.payload, results.postBackPayload?.payload)
                //}
            }*/
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
        showMoreButton.setTitle("Show All \(headerArray[section])", for: .normal)
        showMoreButton.setTitleColor(Common.UIColorRGB(0x999999), for: .disabled)
        showMoreButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 14.0)!
        view.addSubview(showMoreButton)
        showMoreButton.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.center
        showMoreButton.tag = section
        showMoreButton.addTarget(self, action: #selector(showMoreButtonAction(_:)), for: .touchUpInside)
//        let attributeString = NSMutableAttributedString(string: "Show All",
//                                                        attributes: yourAttributes)
//        showMoreButton.setAttributedTitle(attributeString, for: .normal)
        
//        let boolValue = section == 0 ? false : true
//        showMoreButton.isHidden = boolValue
        showMoreButton.isHidden = true
        
        let views: [String: UIView] = ["dropDownBtn": dropDownBtn, "showMoreButton": showMoreButton]
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-5-[dropDownBtn]-5-[showMoreButton(110)]-0-|", options:[], metrics:nil, views:views))
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
        headerLabel.text =  "(\(totalNumOfResults ?? 0) results)"
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
       
        dropDownBtn.addTarget(self, action: #selector(self.showMoreFooterButtonAction(_:)), for: .touchUpInside)
        
        let views: [String: UIView] = ["dropDownBtn": dropDownBtn, "headerLabel": headerLabel]
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-5-[dropDownBtn(100)]|", options:[], metrics:nil, views:views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-60-[headerLabel(100)]|", options:[], metrics:nil, views:views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[dropDownBtn]-5-|", options:[], metrics:nil, views:views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[headerLabel]-5-|", options:[], metrics:nil, views:views))
        
        return view
        
    }
    
    @objc fileprivate func closeButtonAction(_ sender: AnyObject!) {
//        recentSearchArray.removeObject(at: sender.tag)
//        tableView.reloadData() //kaka
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
    
    func heightForTable(resultExpandArray: NSMutableArray, layoutType: String, TemplateType: String, indexPath: IndexPath) -> CGFloat{
        if TemplateType == LiveSearchTypes.grid.rawValue {
            return UITableView.automaticDimension
        }else if TemplateType == LiveSearchTypes.carousel.rawValue{
            if LiveSearchLayoutTypes.tileWithHeader.rawValue == arrayOfLayOutType[indexPath.section] as! String || LiveSearchLayoutTypes.descriptionText.rawValue == arrayOfLayOutType[indexPath.section] as! String{
                return 65
            }else {
                return 160
            }
        }else{
            let layOutType:LiveSearchLayoutTypes = LiveSearchLayoutTypes(rawValue: layoutType)!
            switch layOutType {
            case .descriptionText:
                if  resultExpandArray[indexPath.row] as! String == "close"{
                    return 75
                }
                return UITableView.automaticDimension
            case .tileWithText:
                if  resultExpandArray[indexPath.row] as! String == "close"{
                    return 75
                }
                return UITableView.automaticDimension
                
            case .tileWithImage:
                if  resultExpandArray[indexPath.row] as! String == "close"{
                    return 80
                }
                return UITableView.automaticDimension
            case .tileWithCenteredContent:
                if  resultExpandArray[indexPath.row] as! String == "close"{
                    return 75+100
                }
                return UITableView.automaticDimension
            case .tileWithHeader:
                if  resultExpandArray[indexPath.row] as! String == "close"{
                    return 60
                }
                return UITableView.automaticDimension
            }
        }
    }
    // MARK:- ListType - L1
    func TitleWithHeaderCellMethod(cell: TitleWithHeaderCell,cellResultArray: [TemplateResultElements],expandArray: NSMutableArray, indexPath: IndexPath, isClickable: Bool, templateType: String, appearanceType: String, textAlignment: String) {
        
        cell.backgroundColor = UIColor.clear
        cell.selectionStyle = .none
        cell.titleLabel.textColor = .black
        cell.titleLabel?.numberOfLines = 0 //2
        
        if textAlignment == "center"{
            cell.titleLabel.textAlignment = .center
        }
        
        //let results = cellResultArray[indexPath.row]
        let mappingResults = ((hashMapDic.object(forKey: "template") as AnyObject).object(forKey: "results") as AnyObject)
        var mappingResultDic:AnyObject?
        if self.resultTypeString  == self.resultTypeFlatString{
            mappingResultDic = mappingResults
        }else{
            mappingResultDic = (mappingResults.object(forKey: "\(appearanceType)") as AnyObject)
        }
        if let hashMapArray = mappingResultDic?["data"] as? NSArray{
            cell.titleLabel?.text = ((hashMapArray.object(at: indexPath.row) as AnyObject).object(forKey: "\(arrayOfHeading[indexPath.section])") as? String)
        }
        
        /*let headerName:LiveSearchHeaderTypes = LiveSearchHeaderTypes(rawValue: appearanceType)!
        switch headerName {
        case .faq:
            let mappingResultDic = (mappingResults.object(forKey: "faq") as AnyObject)
            if let hashMapArray = mappingResultDic["data"] as? NSArray{
                cell.titleLabel?.text = ((hashMapArray.object(at: indexPath.row) as AnyObject).object(forKey: "\(faqHeading)") as? String)
            }
        case .web:
            let mappingResultDic = (mappingResults.object(forKey: "web") as AnyObject)
            if let hashMapArray = mappingResultDic["data"] as? NSArray{
                cell.titleLabel?.text = ((hashMapArray.object(at: indexPath.row) as AnyObject).object(forKey: "\(webHeading)") as? String)
            }
        case .file:
            let mappingResultDic = (mappingResults.object(forKey: "file") as AnyObject)
            if let hashMapArray = mappingResultDic["data"] as? NSArray{
                cell.titleLabel?.text = ((hashMapArray.object(at: indexPath.row) as AnyObject).object(forKey: "\(fileHeading)") as? String)
            }
        case .data:
            let mappingResultDic = (mappingResults.object(forKey: "default_group") as AnyObject)
            if let hashMapArray = mappingResultDic["data"] as? NSArray{
                cell.titleLabel?.text = ((hashMapArray.object(at: indexPath.row) as AnyObject).object(forKey: "\(dataHeading)") as? String)
            }
        case .task:
            break
        }*/
        
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
        
        let templateType: LiveSearchTemplateTypes = LiveSearchTemplateTypes(rawValue: templateType)!
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
    // MARK:- ListType - L2
    func descriptionTextCellMethod(cell: LiveSearchFaqTableViewCell,cellResultArray: [TemplateResultElements],expandArray: NSMutableArray, indexPath: IndexPath, isClickable: Bool, templateType: String, appearanceType: String){
        
        cell.backgroundColor = UIColor.clear
        cell.selectionStyle = .none
        cell.titleLabel.textColor = .black
        cell.descriptionLabel.textColor = .dark
        cell.titleLabel?.numberOfLines = 0 //2
        cell.descriptionLabel?.numberOfLines = 0 //2
        //let results = cellResultArray[indexPath.row]
        cell.titleLblHeightConstraint.constant  = 0
        cell.descriptionLblTopConstraint.constant = 0
        let mappingResults = ((hashMapDic.object(forKey: "template") as AnyObject).object(forKey: "results") as AnyObject)
        var mappingResultDic:AnyObject?
        if self.resultTypeString  == self.resultTypeFlatString{
            mappingResultDic = mappingResults
        }else{
            mappingResultDic = (mappingResults.object(forKey: "\(appearanceType)") as AnyObject)
        }
        if let hashMapArray = mappingResultDic?["data"] as? NSArray{
            cell.titleLabel?.text = ((hashMapArray.object(at: indexPath.row) as AnyObject).object(forKey: "\(arrayOfHeading[indexPath.section])") as? String)
            cell.descriptionLabel?.text = ((hashMapArray.object(at: indexPath.row) as AnyObject).object(forKey: "\(arrayOfDescription[indexPath.section])") as? String)
        }
        
        /*
        let headerName:LiveSearchHeaderTypes = LiveSearchHeaderTypes(rawValue: appearanceType)!
        switch headerName {
        case .faq:
            let mappingResultDic = (mappingResults.object(forKey: "faq") as AnyObject)
            if let hashMapArray = mappingResultDic["data"] as? NSArray{
                cell.titleLabel?.text = ((hashMapArray.object(at: indexPath.row) as AnyObject).object(forKey: "\(faqHeading)") as? String)
                cell.descriptionLabel?.text = ((hashMapArray.object(at: indexPath.row) as AnyObject).object(forKey: "\(faqDescription)") as? String)
            }
        case .web:
            let mappingResultDic = (mappingResults.object(forKey: "web") as AnyObject)
            if let hashMapArray = mappingResultDic["data"] as? NSArray{
            cell.titleLabel?.text = ((hashMapArray.object(at: indexPath.row) as AnyObject).object(forKey: "\(webHeading)") as? String)
            cell.descriptionLabel?.text = ((hashMapArray.object(at: indexPath.row) as AnyObject).object(forKey: "\(webDescription)") as? String)
            }
        case .file:
            let mappingResultDic = (mappingResults.object(forKey: "file") as AnyObject)
            if let hashMapArray = mappingResultDic["data"] as? NSArray{
            cell.titleLabel?.text = ((hashMapArray.object(at: indexPath.row) as AnyObject).object(forKey: "\(fileHeading)") as? String)
            cell.descriptionLabel?.text = ((hashMapArray.object(at: indexPath.row) as AnyObject).object(forKey: "\(fileDescription)") as? String)
            }
        case .data:
            let mappingResultDic = (mappingResults.object(forKey: "default_group") as AnyObject)
            if let hashMapArray = mappingResultDic["data"] as? NSArray{
            cell.titleLabel?.text = ((hashMapArray.object(at: indexPath.row) as AnyObject).object(forKey: "\(dataHeading)") as? String)
            cell.descriptionLabel?.text = ((hashMapArray.object(at: indexPath.row) as AnyObject).object(forKey: "\(dataDescription)") as? String)
            }
        case .task:
            break
        }*/

        
        let buttonsHeight = expandArray[indexPath.row] as! String == "close" ? 0.0: 0.0 //30.0
        cell.likeAndDislikeButtonHeightConstrain.constant = CGFloat(buttonsHeight)
        
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
        if !isClickable{
            cell.imageVWidthConstraint.constant = 10
            if expandArray [indexPath.row] as! String == "open"{
                cell.topImageV.image = UIImage(named: "downarrow")
            }else{
                cell.topImageV.image = UIImage(named: "rightarrow")
            }
        }else{
            cell.imageVWidthConstraint.constant = 0
        }
        let templateType: LiveSearchTemplateTypes = LiveSearchTemplateTypes(rawValue: templateType)!
        switch templateType {
        case .listTemplate1:
            cell.subViewBottomConstrain.constant =  11.0
            cell.subView.layer.cornerRadius = 10
            cell.underLineLabel.isHidden = true
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
                    }
                }
                
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    // MARK:- ListType - L3
        func titleWithTextCellMethod(cell: LiveSearchFaqTableViewCell,cellResultArray: [TemplateResultElements],expandArray: NSMutableArray, indexPath: IndexPath, isClickable: Bool, templateType: String, appearanceType: String){
            
            cell.backgroundColor = UIColor.clear
            cell.selectionStyle = .none
            cell.titleLabel.textColor = .black
            cell.descriptionLabel.textColor = .dark
            cell.titleLabel?.numberOfLines = 0 //2
            cell.descriptionLabel?.numberOfLines = 0 //2
           // let results = cellResultArray[indexPath.row]
            let mappingResults = ((hashMapDic.object(forKey: "template") as AnyObject).object(forKey: "results") as AnyObject)
            var mappingResultDic:AnyObject?
            if self.resultTypeString  == self.resultTypeFlatString{
                mappingResultDic = mappingResults
            }else{
                mappingResultDic = (mappingResults.object(forKey: "\(appearanceType)") as AnyObject)
            }
            if let hashMapArray = mappingResultDic?["data"] as? NSArray{
                cell.titleLabel?.text = ((hashMapArray.object(at: indexPath.row) as AnyObject).object(forKey: "\(arrayOfHeading[indexPath.section])") as? String)
                cell.descriptionLabel?.text = ((hashMapArray.object(at: indexPath.row) as AnyObject).object(forKey: "\(arrayOfDescription[indexPath.section])") as? String)
            }
            /*
             let headerName:LiveSearchHeaderTypes = LiveSearchHeaderTypes(rawValue: appearanceType)!
                   switch headerName {
                   case .faq:
                    let mappingResultDic = (mappingResults.object(forKey: "faq") as AnyObject)
                    if let hashMapArray = mappingResultDic["data"] as? NSArray{
                        cell.titleLabel?.text = ((hashMapArray.object(at: indexPath.row) as AnyObject).object(forKey: "\(faqHeading)") as? String)
                        cell.descriptionLabel?.text = ((hashMapArray.object(at: indexPath.row) as AnyObject).object(forKey: "\(faqDescription)") as? String)
                    }
                   case .web:
                    let mappingResultDic = (mappingResults.object(forKey: "web") as AnyObject)
                    if let hashMapArray = mappingResultDic["data"] as? NSArray{
                        cell.titleLabel?.text = ((hashMapArray.object(at: indexPath.row) as AnyObject).object(forKey: "\(webHeading)") as? String)
                        cell.descriptionLabel?.text = ((hashMapArray.object(at: indexPath.row) as AnyObject).object(forKey: "\(webDescription)") as? String)
                    }
                       
                   case .file:
                    let mappingResultDic = (mappingResults.object(forKey: "file") as AnyObject)
                    if let hashMapArray = mappingResultDic["data"] as? NSArray{
                        cell.titleLabel?.text = ((hashMapArray.object(at: indexPath.row) as AnyObject).object(forKey: "\(fileHeading)") as? String)
                        cell.descriptionLabel?.text = ((hashMapArray.object(at: indexPath.row) as AnyObject).object(forKey: "\(fileDescription)") as? String)
                    }
                   case .data:
                        let mappingResultDic = (mappingResults.object(forKey: "default_group") as AnyObject)
                        if let hashMapArray = mappingResultDic["data"] as? NSArray{
                            cell.titleLabel?.text = ((hashMapArray.object(at: indexPath.row) as AnyObject).object(forKey: "\(dataHeading)") as? String)
                            cell.descriptionLabel?.text = ((hashMapArray.object(at: indexPath.row) as AnyObject).object(forKey: "\(dataDescription)") as? String)
                        }
                   case .task:
                       break
                   }*/
            
            let buttonsHeight = expandArray[indexPath.row] as! String == "close" ? 0.0: 0.0 //30.0
            cell.likeAndDislikeButtonHeightConstrain.constant = CGFloat(buttonsHeight)
            
            cell.likeButton.addTarget(self, action: #selector(self.likeButtonAction(_:)), for: .touchUpInside)
            cell.likeButton.tag = indexPath.row
            cell.dislikeButton.addTarget(self, action: #selector(self.disLikeButtonAction(_:)), for: .touchUpInside)
            cell.dislikeButton.tag = indexPath.row
            
            
            cell.subViewLeadingConstraint.constant = 5.0
            cell.subViewTopConstaint.constant = 5.0
            cell.subViewTrailingConstraint.constant = 5.0
            
            
            
            if !isClickable{
                cell.imageVWidthConstraint.constant = 10
                if expandArray [indexPath.row] as! String == "open"{
                    cell.topImageV.image = UIImage(named: "downarrow")
                }else{
                    cell.topImageV.image = UIImage(named: "rightarrow")
                }
            }else{
                cell.imageVWidthConstraint.constant = 0
            }
            let templateType: LiveSearchTemplateTypes = LiveSearchTemplateTypes(rawValue: templateType)!
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
        
    // MARK:- ListType - L4
        func titleWithImageCellMethod(cell: TitleWithImageCell,cellResultArray: [TemplateResultElements],expandArray: NSMutableArray, indexPath: IndexPath, isClickable: Bool, templateType: String, appearanceType: String){
            cell.backgroundColor = UIColor.clear
            cell.selectionStyle = .none
            cell.titleLabel.textColor = .black
            cell.descriptionLabel.textColor = .dark
            cell.titleLabel?.numberOfLines = 0 //2
            cell.descriptionLabel?.numberOfLines = 0 //2
            //let results = cellResultArray[indexPath.row]
            let mappingResults = ((hashMapDic.object(forKey: "template") as AnyObject).object(forKey: "results") as AnyObject)
            var gridImage: String?
            var mappingResultDic:AnyObject?
            if self.resultTypeString  == self.resultTypeFlatString{
                mappingResultDic = mappingResults
            }else{
                mappingResultDic = (mappingResults.object(forKey: "\(appearanceType)") as AnyObject)
            }
            if let hashMapArray = mappingResultDic?["data"] as? NSArray{
                cell.titleLabel?.text = ((hashMapArray.object(at: indexPath.row) as AnyObject).object(forKey: "\(arrayOfHeading[indexPath.section])") as? String)
               cell.descriptionLabel?.text = ((hashMapArray.object(at: indexPath.row) as AnyObject).object(forKey: "\(arrayOfDescription[indexPath.section])") as? String)
                gridImage = ((hashMapArray.object(at: indexPath.row) as AnyObject).object(forKey: "\(arrayOfImg[indexPath.section])") as? String)
            }
            /*
            let headerName:LiveSearchHeaderTypes = LiveSearchHeaderTypes(rawValue: appearanceType)!
            switch headerName {
            case .faq:
                let mappingResultDic = (mappingResults.object(forKey: "faq") as AnyObject)
                if let hashMapArray = mappingResultDic["data"] as? NSArray{
                    cell.titleLabel?.text = ((hashMapArray.object(at: indexPath.row) as AnyObject).object(forKey: "\(faqHeading)") as? String)
                   cell.descriptionLabel?.text = ((hashMapArray.object(at: indexPath.row) as AnyObject).object(forKey: "\(faqDescription)") as? String)
                    gridImage = ((hashMapArray.object(at: indexPath.row) as AnyObject).object(forKey: "\(faqImg)") as? String)
                }
            case .web:
                let mappingResultDic = (mappingResults.object(forKey: "web") as AnyObject)
                if let hashMapArray = mappingResultDic["data"] as? NSArray{
                    cell.titleLabel?.text = ((hashMapArray.object(at: indexPath.row) as AnyObject).object(forKey: "\(webHeading)") as? String)
                    cell.descriptionLabel?.text = ((hashMapArray.object(at: indexPath.row) as AnyObject).object(forKey: "\(webDescription)") as? String)
                    gridImage = ((hashMapArray.object(at: indexPath.row) as AnyObject).object(forKey: "\(webImg)") as? String)
                }
            case .file:
                let mappingResultDic = (mappingResults.object(forKey: "file") as AnyObject)
                if let hashMapArray = mappingResultDic["data"] as? NSArray{
                    cell.titleLabel?.text = ((hashMapArray.object(at: indexPath.row) as AnyObject).object(forKey: "\(fileHeading)") as? String)
                    cell.descriptionLabel?.text = ((hashMapArray.object(at: indexPath.row) as AnyObject).object(forKey: "\(fileDescription)") as? String)
                    gridImage = ((hashMapArray.object(at: indexPath.row) as AnyObject).object(forKey: "\(fileImg)") as? String)
                }
            case .data:
                let mappingResultDic = (mappingResults.object(forKey: "default_group") as AnyObject)
                if let hashMapArray = mappingResultDic["data"] as? NSArray{
                    cell.titleLabel?.text = ((hashMapArray.object(at: indexPath.row) as AnyObject).object(forKey: "\(dataHeading)") as? String)
                    cell.descriptionLabel?.text = ((hashMapArray.object(at: indexPath.row) as AnyObject).object(forKey: "\(dataDescription)") as? String)
                    gridImage = ((hashMapArray.object(at: indexPath.row) as AnyObject).object(forKey: "\(dataImg)") as? String)
                }
            case .task:
                break
            }*/
            
            let buttonsHeight = expandArray[indexPath.row] as! String == "close" ? 0.0: 0.0 //30.0
            cell.likeAndDislikeButtonHeightConstrain.constant = CGFloat(buttonsHeight)
            
            cell.topImageV.contentMode = UIImageView.ContentMode.scaleAspectFill
            if gridImage == nil || gridImage == ""{
                cell.topImageV.image = UIImage(named: "placeholder_image")
                //cell.bottomImageV.image = UIImage(named: "placeholder_image")
            }else{
                let urlString = gridImage?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                let url = URL(string: urlString!)
                cell.topImageV.setImageWith(url!, placeholderImage: UIImage(named: "placeholder_image"))
                //cell.bottomImageV.setImageWith(url!, placeholderImage: UIImage(named: "placeholder_image"))
            }
            
            if !isClickable{
                cell.topImageV.contentMode = UIImageView.ContentMode.scaleAspectFit
                if expandArray [indexPath.row] as! String == "open"{
                    cell.topImageVWidthConstrain.constant = 10
                    cell.topImageVHeightConstrain.constant = 20
                    cell.bottomImageVWidthConstrain.constant = 50
                    cell.topImageV.image = UIImage(named: "downarrow")
                    if gridImage == nil || gridImage == ""{
                        cell.bottomImageV.image = UIImage(named: "placeholder_image")
                    }else{
                        let urlString = gridImage?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                        let url = URL(string: urlString!)
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
            
            let templateType: LiveSearchTemplateTypes = LiveSearchTemplateTypes(rawValue: templateType)!
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
    // MARK:- ListType - L6
        func titleWithCenteredContentCellMethod(cell: TitleWithCenteredContentCell,cellResultArray: [TemplateResultElements],expandArray: NSMutableArray, indexPath: IndexPath, isClickable: Bool, templateType: String, appearanceType: String){
            
            cell.backgroundColor = UIColor.clear
            cell.selectionStyle = .none
            cell.titleLabel.textColor = .black
            cell.descriptionLabel.textColor = .dark
            cell.titleLabel?.numberOfLines = 0 //2
            cell.descriptionLabel?.numberOfLines = 0 //2
            //let results = cellResultArray[indexPath.row]
            let mappingResults = ((hashMapDic.object(forKey: "template") as AnyObject).object(forKey: "results") as AnyObject)
            var gridImage: String?
            var mappingResultDic:AnyObject?
            if self.resultTypeString  == self.resultTypeFlatString{
                mappingResultDic = mappingResults
            }else{
                mappingResultDic = (mappingResults.object(forKey: "\(appearanceType)") as AnyObject)
            }
            if let hashMapArray = mappingResultDic?["data"] as? NSArray{
                cell.titleLabel?.text = ((hashMapArray.object(at: indexPath.row) as AnyObject).object(forKey: "\(arrayOfHeading[indexPath.section])") as? String)
                cell.descriptionLabel?.text = ((hashMapArray.object(at: indexPath.row) as AnyObject).object(forKey: "\(arrayOfDescription[indexPath.section])") as? String)
               gridImage = ((hashMapArray.object(at: indexPath.row) as AnyObject).object(forKey: "\(arrayOfImg[indexPath.section])") as? String)
            }
            /*
            let headerName:LiveSearchHeaderTypes = LiveSearchHeaderTypes(rawValue: appearanceType)!
            switch headerName {
            case .faq:
                let mappingResultDic = (mappingResults.object(forKey: "faq") as AnyObject)
                if let hashMapArray = mappingResultDic["data"] as? NSArray{
                    cell.titleLabel?.text = ((hashMapArray.object(at: indexPath.row) as AnyObject).object(forKey: "\(faqHeading)") as? String)
                    cell.descriptionLabel?.text = ((hashMapArray.object(at: indexPath.row) as AnyObject).object(forKey: "\(faqDescription)") as? String)
                   gridImage = ((hashMapArray.object(at: indexPath.row) as AnyObject).object(forKey: "\(faqImg)") as? String)
                }
              
            case .web:
                let mappingResultDic = (mappingResults.object(forKey: "web") as AnyObject)
                if let hashMapArray = mappingResultDic["data"] as? NSArray{
                    cell.titleLabel?.text = ((hashMapArray.object(at: indexPath.row) as AnyObject).object(forKey: "\(webHeading)") as? String)
                    cell.descriptionLabel?.text = ((hashMapArray.object(at: indexPath.row) as AnyObject).object(forKey: "\(webDescription)") as? String)
                    gridImage = ((hashMapArray.object(at: indexPath.row) as AnyObject).object(forKey: "\(webImg)") as? String)
                }
                
            case .file:
                let mappingResultDic = (mappingResults.object(forKey: "file") as AnyObject)
                if let hashMapArray = mappingResultDic["data"] as? NSArray{
                    cell.titleLabel?.text = ((hashMapArray.object(at: indexPath.row) as AnyObject).object(forKey: "\(fileHeading)") as? String)
                    cell.descriptionLabel?.text = ((hashMapArray.object(at: indexPath.row) as AnyObject).object(forKey: "\(fileDescription)") as? String)
                    gridImage = ((hashMapArray.object(at: indexPath.row) as AnyObject).object(forKey: "\(fileImg)") as? String)
                }
               
            case .data:
                let mappingResultDic = (mappingResults.object(forKey: "default_group") as AnyObject)
                if let hashMapArray = mappingResultDic["data"] as? NSArray{
                    cell.titleLabel?.text = ((hashMapArray.object(at: indexPath.row) as AnyObject).object(forKey: "\(dataHeading)") as? String)
                    cell.descriptionLabel?.text = ((hashMapArray.object(at: indexPath.row) as AnyObject).object(forKey: "\(dataDescription)") as? String)
                    gridImage = ((hashMapArray.object(at: indexPath.row) as AnyObject).object(forKey: "\(dataImg)") as? String)
                }
              
            case .task:
                break
            }*/
            
            let buttonsHeight = expandArray[indexPath.row] as! String == "close" ? 0.0: 0.0 //30.0
            cell.likeAndDislikeButtonHeightConstrain.constant = CGFloat(buttonsHeight)
            
            if !isClickable{
                cell.topImageV.contentMode = UIImageView.ContentMode.scaleAspectFit
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
                    if gridImage == nil || gridImage == ""{
                        cell.centerImagV.image = UIImage(named: "placeholder_image")
                    }else{
                        let urlString = gridImage?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                        let url = URL(string: urlString!)
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
                
                if gridImage == nil || gridImage == ""{
                    cell.topCenterImagV.image = UIImage(named: "placeholder_image")
                    
                }else{
                    let urlString = gridImage?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                    let url = URL(string: urlString!)
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
            
            let templateType: LiveSearchTemplateTypes = LiveSearchTemplateTypes(rawValue: templateType)!
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
