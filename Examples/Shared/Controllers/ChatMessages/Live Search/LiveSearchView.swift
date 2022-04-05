//
//  LiveSearchView.swift
//  KoreBotSDKDemo
//
//  Created by Kartheek.Pagidimarri on 14/10/20.
//  Copyright © 2020 Kore. All rights reserved.
//

import UIKit
protocol LiveSearchViewDelegate {
    func optionsButtonTapAction(text:String)
    func optionsButtonTapNewAction(text:String, payload:String)
    func linkButtonTapAction(urlString:String)
    func addTextToTextView(text:String)
    func optionsButtonTapTaskAction(text:String, payload:String, taskData: [String:Any]?)
    //func showOrHideLiveSeachView(text:String)
    
}

class LiveSearchView: UIView {
    
    var autoSearchView: UIView!
    var autoSearchTableView: UITableView!
    var autoSearchHeightConstraint: NSLayoutConstraint!
    var tableView: UITableView!
    var notifyLabel: UILabel!
    fileprivate let recentSearchCellIdentifier = "RecentSearchCell"
    fileprivate let liveSearchFaqCellIdentifier = "LiveSearchFaqTableViewCell"
    fileprivate let liveSearchPageCellIdentifier = "LiveSearchPageTableViewCell"
    fileprivate let liveSearchTaskCellIdentifier = "LiveSearchTaskTableViewCell"
    fileprivate let liveSearchNewTaskCellIdentifier = "LiveSearchNewTaskViewCell"
    
    fileprivate let titleWithImageCellIdentifier = "TitleWithImageCell"
    fileprivate let titleWithCenteredContentCellIdentifier = "TitleWithCenteredContentCell"
    fileprivate let TitleWithHeaderCellIdentifier = "TitleWithHeaderCell"
    
    fileprivate let GridTableViewCellIdentifier = "GridTableViewCell"
    fileprivate let CarouselTableViewCellIdentifier = "CarouselTableViewCell"
    
    
    
    
    var headerArray = ["POPULAR SEARCHS","RECENT SEARCHS"]
    var kaBotClient = KABotClient()
    var popularSearchArray:NSMutableArray = []
    var recentSearchNewArray:NSArray = []
    var autoSuggestionSearchItems = AutoSuggestionModel()
    var arrayOfResults = [TemplateResultElements]()
    
    var arrayOfFaqResults = [TemplateResultElements]()
    var arrayOfPageResults = [TemplateResultElements]()
    var arrayOfTaskResults = [TemplateResultElements]()
    var arrayOfFileResults = [TemplateResultElements]()
    var arrayOfDataResults = [TemplateResultElements]()
    
    var faqsExpandArray:NSMutableArray = []
    var pagesExpandArray:NSMutableArray = []
    var filesExpandArray:NSMutableArray = []
    var dataExpandArray:NSMutableArray = []
    
    var likeAndDislikeArray:NSMutableArray = []
    var headersExpandArray:NSMutableArray = []
    
    var viewDelegate: LiveSearchViewDelegate?
    var isPopularSearch = true
    var liveSearchJsonString:String?
    
    let yourAttributes : [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.font : UIFont(name: "HelveticaNeue-Bold", size: 15.0) as Any,
        NSAttributedString.Key.foregroundColor : themeColor]
    
    
    
    let sectionAndRowsLimit:Int = (serachInterfaceItems?.interactionsConfig?.liveSearchResultsLimit)!
    
    
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
    var isSearchType = "liveSearch"
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
    
    enum LiveSearchTypes: String{
        case listTemplate = "list"//listTemplate
        case grid = "grid"
        case carousel = "carousel"
    }
    
    var resultTypeString:String?
    var resultTypeFlatString = "flat"
    
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupViews()
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
    var isGroupResults:Bool?
    
    fileprivate func setupViews() {
        
        headerNArray = []
        for i in 0..<(resultViewSettingItems?.settings?.count ?? 0){
            let settings = resultViewSettingItems?.settings?[i]
            //isGroupResults = settings?.groupResults
            if settings?.interface == "liveSearch"{
                for j in 0..<(settings?.groupSetting?.conditions?.count ?? 0){
                    if let condtion = settings?.groupSetting?.conditions?[j]{
                        headerNArray.append(condtion.fieldValue ?? "")
                        
                        if let isGroupResults = settings?.groupResults, isGroupResults{
                            arrayOfResultSettingTemplateType.add(condtion.template?.type ?? "list")
                            arrayOfResultSettingLayOutType.add(condtion.template?.layout?.layoutType ?? "l1")
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
                    /*
                     if condtion?.fieldValue == "faq"{
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
                     
                     }else if condtion?.fieldValue == "file"{
                     liveSearchFileTemplateType = condtion?.template?.type ?? "listTemplate1"
                     fileLayOutType = condtion?.template?.layout?.layoutType ?? "tileWithText"
                     isFileClickable = condtion?.template?.layout?.isClickable ?? true
                     fileListType =  condtion?.template?.layout?.listType ?? "plain"
                     fileTextAlignment =  condtion?.template?.layout?.textAlignment ?? "center"
                     
                     fileHeading = condtion?.template?.mapping?.heading ?? ""
                     fileDescription = condtion?.template?.mapping?.descrip ?? ""
                     fileImg = condtion?.template?.mapping?.img ?? ""
                     fileUrl = condtion?.template?.mapping?.url ?? ""
                     
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
        
        self.tableView = UITableView(frame: CGRect.zero,style:.plain)
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.backgroundColor = .clear
        self.tableView.showsHorizontalScrollIndicator = false
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.bounces = false
        self.tableView.separatorStyle = .none
        self.addSubview(self.tableView)
        self.tableView.isScrollEnabled = true
        self.tableView.register(UINib(nibName: recentSearchCellIdentifier, bundle: nil), forCellReuseIdentifier: recentSearchCellIdentifier)
        self.tableView.register(UINib(nibName: liveSearchFaqCellIdentifier, bundle: nil), forCellReuseIdentifier: liveSearchFaqCellIdentifier)
        self.tableView.register(UINib(nibName: liveSearchPageCellIdentifier, bundle: nil), forCellReuseIdentifier: liveSearchPageCellIdentifier)
        self.tableView.register(UINib(nibName: liveSearchTaskCellIdentifier, bundle: nil), forCellReuseIdentifier: liveSearchTaskCellIdentifier)
        self.tableView.register(UINib(nibName: liveSearchNewTaskCellIdentifier, bundle: nil), forCellReuseIdentifier: liveSearchNewTaskCellIdentifier)
        
        
        self.tableView.register(UINib(nibName: titleWithImageCellIdentifier, bundle: nil), forCellReuseIdentifier: titleWithImageCellIdentifier)
        self.tableView.register(UINib(nibName: titleWithCenteredContentCellIdentifier, bundle: nil), forCellReuseIdentifier: titleWithCenteredContentCellIdentifier)
        self.tableView.register(UINib(nibName: TitleWithHeaderCellIdentifier, bundle: nil), forCellReuseIdentifier: TitleWithHeaderCellIdentifier)
        
        self.tableView.register(UINib(nibName: GridTableViewCellIdentifier, bundle: nil), forCellReuseIdentifier: GridTableViewCellIdentifier)
        self.tableView.register(UINib(nibName: CarouselTableViewCellIdentifier, bundle: nil), forCellReuseIdentifier: CarouselTableViewCellIdentifier)
        
        
        self.notifyLabel = UILabel(frame: CGRect.zero)
        self.notifyLabel.textColor = Common.UIColorRGB(0x484848)
        self.notifyLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 18.0)
        self.notifyLabel.numberOfLines = 0
        self.notifyLabel.text = "No results found"
        notifyLabel.textAlignment = .center
        self.notifyLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        self.notifyLabel.isUserInteractionEnabled = true
        self.notifyLabel.contentMode = UIView.ContentMode.topLeft
        self.notifyLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.notifyLabel)
        self.notifyLabel.adjustsFontSizeToFitWidth = true
        self.notifyLabel.backgroundColor = .clear
        self.notifyLabel.layer.cornerRadius = 6.0
        self.notifyLabel.clipsToBounds = true
        self.notifyLabel.sizeToFit()
        self.notifyLabel.isHidden = true
        
        self.autoSearchView = UIView(frame: CGRect.zero)
        autoSearchView.backgroundColor = .white //UIColor.init(red: 248/255, green: 249/255, blue: 250/255, alpha: 1.0)
        self.autoSearchView.layer.cornerRadius = 10
        self.autoSearchView.clipsToBounds = true
        self.autoSearchView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.autoSearchView)
        
        let suggestionsTileLbl = UILabel(frame: .zero)
        suggestionsTileLbl.text = "SUGGESTIONS"
        suggestionsTileLbl.translatesAutoresizingMaskIntoConstraints = false
        suggestionsTileLbl.textAlignment = .left
        suggestionsTileLbl.font = UIFont(name: "HelveticaNeue-Bold", size: 15.0)
        suggestionsTileLbl.textColor = .black
        autoSearchView.addSubview(suggestionsTileLbl)
        
        self.autoSearchTableView = UITableView(frame: CGRect.zero,style:.plain)
        self.autoSearchTableView.translatesAutoresizingMaskIntoConstraints = false
        self.autoSearchTableView.dataSource = self
        self.autoSearchTableView.delegate = self
        self.autoSearchTableView.backgroundColor = .clear
        self.autoSearchTableView.showsHorizontalScrollIndicator = false
        self.autoSearchTableView.showsVerticalScrollIndicator = false
        self.autoSearchTableView.bounces = false
        self.autoSearchTableView.separatorStyle = .none
        self.autoSearchView.addSubview(self.autoSearchTableView)
        self.autoSearchTableView.isScrollEnabled = true
        self.autoSearchView.isHidden = true
        
        let autoViews: [String: UIView] = ["suggestionsTileLbl":suggestionsTileLbl, "autoSearchTableView": autoSearchTableView]
        self.autoSearchView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[suggestionsTileLbl(21)]-5-[autoSearchTableView]-0-|", options: [], metrics: nil, views: autoViews))
        self.autoSearchView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[suggestionsTileLbl]-10-|", options: [], metrics: nil, views: autoViews))
        self.autoSearchView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[autoSearchTableView]-0-|", options: [], metrics: nil, views: autoViews))
        
        
        
        let views: [String: UIView] = ["tableView": tableView, "notifyLabel":notifyLabel, "autoSearchView":autoSearchView]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-15-[tableView]-10-[autoSearchView(200)]-0-|", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-100-[notifyLabel]-0-|", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[tableView]-10-|", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[notifyLabel]-10-|", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[autoSearchView]-10-|", options: [], metrics: nil, views: views))
        
        self.autoSearchHeightConstraint = NSLayoutConstraint.init(item: self.autoSearchView as Any, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 0.0)
        self.addConstraint(self.autoSearchHeightConstraint)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(callingLiveSearchView(notification:)), name: NSNotification.Name(rawValue: "textViewDidChange"), object: nil)
        
        
        
        if #available(iOS 11.0, *) {
            self.roundCorners([ .layerMinXMinYCorner, .layerMaxXMinYCorner], radius: 20.0, borderColor: UIColor.lightGray, borderWidth: 0)
            self.autoSearchTableView.roundCorners([ .layerMinXMinYCorner, .layerMaxXMinYCorner], radius: 20.0, borderColor: UIColor.lightGray, borderWidth: 0)
        } else {
            // Fallback on earlier versions
        }
        self.backgroundColor = UIColor.init(red: 240/255, green: 242/255, blue: 244/255, alpha: 1.0)
        
        headerArray = []
        //callingPopularSearchApi() //kk
        callingRecentSearchApi()
    }
    
    var isLiveSearchApiCalling = false
    var isLiveAutoSuggestionApiCalling = false
    
    @objc func callingLiveSearchView(notification:Notification) {
        let dataString: String = notification.object as! String
        print("LiveSearchView: \(dataString)")
        
        if dataString == ""{
            self.autoSearchHeightConstraint.constant = 0.0
            autoSuggestionSearchItems = AutoSuggestionModel()
            autoSearchTableView.reloadData()
            autoSearchView.isHidden = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5, execute: {
                self.headerArray = []
                //self.callingPopularSearchApi() //kk
                self.callingRecentSearchApi()
            })
            
        }else{
            self.autoSearchHeightConstraint.constant = 120.0
            let timeCount = 2
            autoSearchView.isHidden = false
            headerArray = []
            
            
            callingAutoSuggestionSearchApi(searchText: dataString)
            
            self.callingLiveSearchApi(searchText: dataString)
            
            //            if !isLiveSearchApiCalling{
            //                isLiveSearchApiCalling = true
            //                Timer.scheduledTimer(withTimeInterval: TimeInterval(timeCount), repeats: false) { (_) in
            //                    print("number of times,")
            //                    self.callingLiveSearchApi(searchText: dataString)
            //                }
            //            }
        }
    }
    
    func callingPopularSearchApi(){
        kaBotClient.getPopularSearchResults(success: { [weak self] (arrayOfResults) in
            DispatchQueue.main.async {
                self?.popularSearchArray = arrayOfResults.mutableCopy() as! NSMutableArray
                self?.isPopularSearch = true
                if (self?.popularSearchArray.count)! > 0{
                    self?.headerArray.append("POPULAR SEARCHS")
                }
                
                self!.tableView.reloadData()
            }
            
        }, failure: { (error) in
            print(error)
            self.isPopularSearch = true
            // self.headerArray = ["POPULAR SEARCHS","RECENT SEARCHS"]
            self.tableView.reloadData()
            
        })
    }
    func callingRecentSearchApi(){
        kaBotClient.getRecentSearchResults(success: { [weak self] (dictionary) in
            DispatchQueue.main.async {
                self?.recentSearchNewArray = dictionary["recentSearches"] as? NSArray ?? []
                self?.isPopularSearch = true
                if (self?.recentSearchNewArray.count)! > 0{
                    self?.headerArray.append("RECENT SEARCHS")
                }
                
                self!.tableView.reloadData()
            }
        }, failure: { (error) in
            print(error)
            self.isPopularSearch = true
            // self.headerArray = ["POPULAR SEARCHS","RECENT SEARCHS"]
            self.tableView.reloadData()
            
        })
    }
    
    
    
    func callingAutoSuggestionSearchApi(searchText: String){
        kaBotClient.autoSuggestionSearchResults(searchText ,success: { [weak self] (dictionary) in
            let jsonDecoder = JSONDecoder()
            guard let jsonData = try? JSONSerialization.data(withJSONObject: dictionary as Any , options: .prettyPrinted),
                  let allItems = try? jsonDecoder.decode(AutoSuggestionModel.self, from: jsonData) else {
                return
            }
            self?.autoSuggestionSearchItems = allItems
            DispatchQueue.main.async {
                self!.autoSearchTableView.reloadData()
            }
        }, failure: { (error) in
            print(error)
        })
        
    }
    
    func callingLiveSearchApi(searchText: String){
        kaBotClient.getLiveSearchResults(searchText ,success: { [weak self] (dictionary) in
            self?.isLiveSearchApiCalling = false
            if let theJSONData = try?  JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted
            ),
            let theJSONText = String(data: theJSONData, encoding: String.Encoding.ascii) {
                self?.liveSearchJsonString = theJSONText
            }
            if let isBotLocked = dictionary["isBotLocked"] as? Bool, isBotLocked{
                isEndOfTask = false
            }else{
                isEndOfTask = true
                DispatchQueue.main.async {
                    self?.hashMapDic = dictionary as NSDictionary
                    let jsonDecoder = JSONDecoder()
                    guard let jsonData = try? JSONSerialization.data(withJSONObject: dictionary as Any , options: .prettyPrinted),
                          let _ = try? jsonDecoder.decode(LiveSearchChatItems.self, from: jsonData) else {
                        return
                    }
                    
                    self?.arrayOfResults = []
                    self?.headerArray = []
                    
                    self?.faqsExpandArray = []
                    self?.pagesExpandArray = []
                    self?.filesExpandArray = []
                    self?.dataExpandArray = []
                    
                    self?.headersExpandArray = []
                    self?.likeAndDislikeArray = []
                    
                    // ...........
                    self?.arrayOfLiveSearchTemplateType = []
                    self?.arrayOfLayOutType = []
                    self?.arrayOfIsClickable = []
                    self?.arrayOfListType = []
                    self?.arrayOfTextAlignment = []
                    
                    self?.arrayOfHeading = []
                    self?.arrayOfDescription = []
                    self?.arrayOfImg = []
                    self?.arrayOfUrl = []
                    
                    self?.arrayOfSearchResults = []
                    self?.arrayOfSearchResultsExpand = []
                    self?.arrayOfSearchResultsLikeDislike = []
                    
                    if let templateDic = self?.hashMapDic["template"] as? [String: Any]{
                        
                        let resultType =  templateDic["resultType"] as? String
                        self?.resultTypeString = resultType
                        if self?.resultTypeString  == self?.resultTypeFlatString{
                            if let mappingResults = templateDic["results"] as? [String: Any]{
                                if let resultDic = mappingResults as? [String: Any]{
                                    guard let jsonData = try? JSONSerialization.data(withJSONObject: resultDic["data"] as Any , options: .prettyPrinted),
                                          let allItems = try? jsonDecoder.decode([TemplateResultElements].self, from: jsonData) else {
                                        return
                                    }
                                    print(allItems)
                                    self?.arrayOfSearchResults.add(allItems)
                                    
                                    self?.headerArray.append("")
                                    self?.headersExpandArray.add("open")
                                    
                                    let expandArray = NSMutableArray()
                                    let likeDislikeArray = NSMutableArray()
                                    for _ in 0..<allItems.count{
                                        expandArray.add("close")
                                        likeDislikeArray.add("")
                                    }
                                    self?.arrayOfSearchResultsExpand.add(expandArray)
                                    self?.arrayOfSearchResultsLikeDislike.add(likeDislikeArray)
                                    
                                    if self?.arrayOfResultSettingTemplateType.count ?? 0 > 0{
                                        self?.arrayOfLiveSearchTemplateType.add(self?.arrayOfResultSettingTemplateType[0] as Any)
                                        self?.arrayOfLayOutType.add(self?.arrayOfResultSettingLayOutType[0] as Any)
                                        self?.arrayOfIsClickable.add(self?.arrayOfResultSettingIsClickable[0] as Any)
                                        self?.arrayOfListType.add(self?.arrayOfResultSettingListType[0] as Any)
                                        self?.arrayOfTextAlignment.add(self?.arrayOfResultSettingTextAlignment[0] as Any)
                                        
                                        self?.arrayOfHeading.add(self?.arrayOfResultSettingHeading[0] as Any)
                                        self?.arrayOfDescription.add(self?.arrayOfResultSettingDescription[0] as Any)
                                        self?.arrayOfImg.add(self?.arrayOfResultSettingImg[0] as Any)
                                        self?.arrayOfUrl.add(self?.arrayOfResultSettingUrl[0] as Any)
                                        
                                    }
                                }
                            }
                            
                        }else{
                            for i in 0..<self!.headerNArray.count{
                                let results = self!.headerNArray[i]
                                if let mappingResults = templateDic["results"] as? [String:Any]{
                                    if let mappingResultDic = mappingResults["\(results)"] as? [String:Any]{
                                        print(mappingResultDic as Any)
                                        if let resultDic = mappingResultDic as? [String: Any]{
                                            guard let jsonData = try? JSONSerialization.data(withJSONObject: resultDic["data"] as Any , options: .prettyPrinted),
                                                  let allItems = try? jsonDecoder.decode([TemplateResultElements].self, from: jsonData) else {
                                                return
                                            }
                                            print(allItems)
                                            self?.arrayOfSearchResults.add(allItems)
                                            
                                            self?.headerArray.append(self!.headerNArray[i])
                                            self?.headersExpandArray.add("open")
                                            
                                            let expandArray = NSMutableArray()
                                            let likeDislikeArray = NSMutableArray()
                                            for _ in 0..<allItems.count{
                                                expandArray.add("close")
                                                likeDislikeArray.add("")
                                            }
                                            self?.arrayOfSearchResultsExpand.add(expandArray)
                                            self?.arrayOfSearchResultsLikeDislike.add(likeDislikeArray)
                                            
                                            self?.arrayOfLiveSearchTemplateType.add(self?.arrayOfResultSettingTemplateType[i] as Any)
                                            self?.arrayOfLayOutType.add(self?.arrayOfResultSettingLayOutType[i] as Any)
                                            self?.arrayOfIsClickable.add(self?.arrayOfResultSettingIsClickable[i] as Any)
                                            self?.arrayOfListType.add(self?.arrayOfResultSettingListType[i] as Any)
                                            self?.arrayOfTextAlignment.add(self?.arrayOfResultSettingTextAlignment[i] as Any)
                                            
                                            self?.arrayOfHeading.add(self?.arrayOfResultSettingHeading[i] as Any)
                                            self?.arrayOfDescription.add(self?.arrayOfResultSettingDescription[i] as Any)
                                            self?.arrayOfImg.add(self?.arrayOfResultSettingImg[i] as Any)
                                            self?.arrayOfUrl.add(self?.arrayOfResultSettingUrl[i] as Any)
                                            
                                        }
                                    }
                                }
                            }
                            
                        }
                        
                    }
                    
                    
                    
                    
                    print(self?.headerArray as Any)
                    
                    /*
                     let faqs = allItems.template?.results?.faq?.data
                     self?.arrayOfFaqResults = faqs ?? []
                     if self!.arrayOfFaqResults.count > 0 {
                     self!.headerArray.append(LiveSearchHeaderTypes.faq.rawValue)
                     self!.headersExpandArray.add("open")
                     }
                     for _ in 0..<self!.arrayOfFaqResults.count{
                     self!.faqsExpandArray.add("close")
                     self?.likeAndDislikeArray.add("")
                     }
                     
                     let pages = allItems.template?.results?.page?.data
                     self?.arrayOfPageResults = pages ?? []
                     if self!.arrayOfPageResults.count > 0 {
                     self!.headerArray.append(LiveSearchHeaderTypes.web.rawValue)
                     self!.headersExpandArray.add("open")
                     }
                     for _ in 0..<self!.arrayOfPageResults.count{
                     self!.pagesExpandArray.add("close")
                     }
                     
                     let task = allItems.template?.results?.task?.data
                     self?.arrayOfTaskResults = task ?? []
                     if self!.arrayOfTaskResults.count > 0 {
                     self!.headerArray.append(LiveSearchHeaderTypes.task.rawValue)
                     self!.headersExpandArray.add("open")
                     //isShowLoginView = true //kk
                     }else{
                     //isShowLoginView = false //kk
                     }
                     
                     let files = allItems.template?.results?.file?.data
                     self?.arrayOfFileResults = files ?? []
                     if self!.arrayOfFileResults.count > 0 {
                     self!.headerArray.append(LiveSearchHeaderTypes.file.rawValue)
                     self!.headersExpandArray.add("open")
                     }
                     for _ in 0..<self!.arrayOfFileResults.count{
                     self!.filesExpandArray.add("close")
                     }
                     
                     let data = allItems.template?.results?.data?.data
                     self?.arrayOfDataResults = data ?? []
                     if self!.arrayOfDataResults.count > 0 {
                     self!.headerArray.append(LiveSearchHeaderTypes.data.rawValue)
                     self!.headersExpandArray.add("open")
                     }
                     for _ in 0..<self!.arrayOfDataResults.count{
                     self!.dataExpandArray.add("close")
                     }
                     */
                    
                    self?.isPopularSearch = false
                    
                    self!.tableView.reloadData()
                    self?.notifyLabel.isHidden = true
                    self?.reloadTableViewSilently()
                }
            }
            
        }, failure: { (error) in
            print(error)
        })
    }
    
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
}

extension LiveSearchView: UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == autoSearchTableView{
            return UITableView.automaticDimension
        }else{
            if isPopularSearch{
                return UITableView.automaticDimension
            }else {
                //                       let headerName = headerArray[indexPath.section]
                //                       switch headerName {
                //                       case "FAQS":
                //                           if faqsExpandArray[indexPath.row] as! String == "close"{
                //                               return 75
                //                           }
                //                           return UITableView.automaticDimension
                //                       case "PAGES":
                //                           if  pagesExpandArray[indexPath.row] as! String == "close"{
                //                               return 75
                //                           }
                //                           return UITableView.automaticDimension
                //                       default:
                //                           break
                //                       }
                //                       return UITableView.automaticDimension
                
                if let expandValues = arrayOfSearchResultsExpand[indexPath.section] as? NSMutableArray{
                    if expandValues[indexPath.row] as! String == "close"{
                        return 75
                    }
                    return UITableView.automaticDimension
                }
                return UITableView.automaticDimension
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == autoSearchTableView{
            return UITableView.automaticDimension
        }else{
            if isPopularSearch{
                return UITableView.automaticDimension
            }else {
                //                        let headerName:LiveSearchHeaderTypes = LiveSearchHeaderTypes(rawValue: headerArray[indexPath.section])!
                //                        switch headerName {
                //                        case .faq:
                //                            return   heightForTable(resultExpandArray: faqsExpandArray, layoutType: faqLayOutType, TemplateType: liveSearchFAQsTemplateType, index: indexPath.row)
                //
                //                        case .web:
                //                            return   heightForTable(resultExpandArray: pagesExpandArray, layoutType: pageLayOutType, TemplateType: liveSearchPageTemplateType, index: indexPath.row)
                //                        case .file:
                //
                //                             return   heightForTable(resultExpandArray: filesExpandArray, layoutType: fileLayOutType, TemplateType: liveSearchFileTemplateType, index: indexPath.row)
                //
                //                        case .data:
                //                            return   heightForTable(resultExpandArray: dataExpandArray, layoutType: dataLayOutType, TemplateType: liveSearchDataTemplateType, index: indexPath.row)
                //
                //                            case .task:
                //                            return UITableView.automaticDimension
                //                        }
                
                return   heightForTable(resultExpandArray: (arrayOfSearchResultsExpand[indexPath.section] as? NSMutableArray)!, layoutType: arrayOfLayOutType[indexPath.section] as! String, TemplateType: arrayOfLiveSearchTemplateType[indexPath.section] as! String, indexPath: indexPath)
            }
        }
        
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == autoSearchTableView{
            return 1
        }
        return headerArray.count > sectionAndRowsLimit ? sectionAndRowsLimit : headerArray.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == autoSearchTableView{
            let autoSearchItems = autoSuggestionSearchItems.autoComplete?.querySuggestions?.count ?? 0
            return autoSearchItems //> 3 ? 3 :  autoSearchItems
        }else{
            if isPopularSearch{
                if headerArray.count > 0{
                    if headerArray[section] == "POPULAR SEARCHS"{
                        return popularSearchArray.count
                    }
                    return recentSearchNewArray.count
                }
                return 0
                
            }else {
                
                if headersExpandArray [section] as! String == "open"{
                    if arrayOfLiveSearchTemplateType[section] as? String == LiveSearchTypes.grid.rawValue || arrayOfLiveSearchTemplateType[section] as? String == LiveSearchTypes.carousel.rawValue{
                        return 1
                    }else{
                        let rowsCount = (arrayOfSearchResults[section] as AnyObject).count > sectionAndRowsLimit ? sectionAndRowsLimit : (arrayOfSearchResults[section] as AnyObject).count
                        return rowsCount ?? 0
                    }
                    
                }
                return 0
                
                /* let headerName: LiveSearchHeaderTypes = LiveSearchHeaderTypes(rawValue: headerArray[section])!
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
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == autoSearchTableView{
            
            let cell : RecentSearchCell = self.tableView.dequeueReusableCell(withIdentifier: recentSearchCellIdentifier) as! RecentSearchCell
            cell.backgroundColor = UIColor.clear
            cell.selectionStyle = .none
            let autoResults = autoSuggestionSearchItems.autoComplete?.querySuggestions![indexPath.row]
            cell.titleLabel.text = (autoResults!)
            cell.titleLabel.numberOfLines = 1
            cell.titleLabel.textColor = .black
            cell.titleLabel.font = UIFont.systemFont(ofSize: 14.0)
            cell.closeButtonWidthConstraint.constant = CGFloat(30.0)
            cell.subVLeadingConstraint.constant = 15.0
            cell.subVTrailingConstraint.constant = 15.0
            cell.subView.layer.cornerRadius = 15
            cell.subView.layer.borderWidth = 0.0
            cell.subView.layer.borderColor = UIColor.lightGray.cgColor
            cell.closeButton.isUserInteractionEnabled = false
            return cell
            
        }else{
            if isPopularSearch{
                let cell : RecentSearchCell = self.tableView.dequeueReusableCell(withIdentifier: recentSearchCellIdentifier) as! RecentSearchCell
                cell.backgroundColor = UIColor.clear
                cell.selectionStyle = .none
                if headerArray[indexPath.section] == "POPULAR SEARCHS"{
                    cell.titleLabel.text = ((popularSearchArray.object(at: indexPath.row) as AnyObject).object(forKey: "_id") as! String)
                }else{
                    cell.titleLabel.text = (recentSearchNewArray.object(at: indexPath.row) as AnyObject) as? String         //cell.titleLabel.text = ((recentSearchArray.object(at: indexPath.row) as AnyObject).object(forKey: "_id") as! String)
                    cell.closeButton.addTarget(self, action: #selector(closeButtonAction(_:)), for: .touchUpInside)
                    cell.closeButton.tag = indexPath.row
                }
                
                cell.titleLabel.textColor = .black
                let width = headerArray[indexPath.section] == "RECENT SEARCHS" ? 30.0 : 0.0
                cell.closeButtonWidthConstraint.constant = CGFloat(width)
                cell.closeButton.isUserInteractionEnabled = false
                return cell
            }else{
                
                let mappingResults = ((hashMapDic.object(forKey: "template") as AnyObject).object(forKey: "results") as AnyObject)
                let headerName = headerArray[indexPath.section]
                
                
                if arrayOfLiveSearchTemplateType[indexPath.section] as? String == LiveSearchTypes.grid.rawValue{
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
                
                
                /*let mappingResults = ((hashMapDic.object(forKey: "template") as AnyObject).object(forKey: "results") as AnyObject)
                 let headerName: LiveSearchHeaderTypes = LiveSearchHeaderTypes(rawValue: headerArray[indexPath.section])!
                 switch headerName {
                 case .faq:
                 if liveSearchFAQsTemplateType == LiveSearchTypes.grid.rawValue{
                 let cell = tableView.dequeueReusableCell(withIdentifier: GridTableViewCellIdentifier, for: indexPath) as! GridTableViewCell
                 let mappingResultDic = (mappingResults.object(forKey: "faq") as AnyObject)
                 if let hashMapArray = mappingResultDic["data"] as? NSArray{
                 cell.configureNew(with: arrayOfFaqResults, appearanceType: headerName.rawValue, layOutType: faqLayOutType, templateType:liveSearchFAQsTemplateType, hashMapArray: hashMapArray , isSearchScreen: isSearchType)
                 }
                 
                 return cell
                 }else if liveSearchFAQsTemplateType == LiveSearchTypes.carousel.rawValue{
                 let cell = tableView.dequeueReusableCell(withIdentifier: CarouselTableViewCellIdentifier, for: indexPath) as! CarouselTableViewCell
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
                 //                        cell.configure(with: arrayOfPageResults, appearanceType: headerName.rawValue, layOutType: pageLayOutType, templateType:liveSearchPageTemplateType)
                 let mappingResultDic = (mappingResults.object(forKey: "web") as AnyObject)
                 if let hashMapArray = mappingResultDic["data"] as? NSArray{
                 cell.configureNew(with: arrayOfPageResults, appearanceType: headerName.rawValue, layOutType: pageLayOutType, templateType:liveSearchPageTemplateType, hashMapArray: hashMapArray , isSearchScreen: isSearchType)
                 }
                 return cell
                 }else if liveSearchPageTemplateType == LiveSearchTypes.carousel.rawValue{
                 let cell = tableView.dequeueReusableCell(withIdentifier: CarouselTableViewCellIdentifier, for: indexPath) as! CarouselTableViewCell
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
                 TitleWithHeaderCellMethod(cell: cell, cellResultArray: arrayOfPageResults, expandArray: pagesExpandArray, indexPath: indexPath, isClickable: isPagesClickable, templateType: pageListType, appearanceType: headerName.rawValue , textAlignment: pageTextAlignment)
                 return cell
                 }
                 }
                 
                 case .file:
                 if liveSearchFileTemplateType == LiveSearchTypes.grid.rawValue {
                 let cell = tableView.dequeueReusableCell(withIdentifier: GridTableViewCellIdentifier, for: indexPath) as! GridTableViewCell
                 //cell.configure(with: arrayOfFileResults, appearanceType: headerName.rawValue, layOutType: fileLayOutType, templateType:liveSearchFileTemplateType)
                 let mappingResultDic = (mappingResults.object(forKey: "file") as AnyObject)
                 if let hashMapArray = mappingResultDic["data"] as? NSArray{
                 cell.configureNew(with: arrayOfFileResults, appearanceType: headerName.rawValue, layOutType: fileLayOutType, templateType:liveSearchFileTemplateType, hashMapArray: hashMapArray, isSearchScreen: isSearchType)
                 }
                 return cell
                 }else if liveSearchFileTemplateType == LiveSearchTypes.carousel.rawValue{
                 let cell = tableView.dequeueReusableCell(withIdentifier: CarouselTableViewCellIdentifier, for: indexPath) as! CarouselTableViewCell
                 let mappingResultDic = (mappingResults.object(forKey: "file") as AnyObject)
                 if let hashMapArray = mappingResultDic["data"] as? NSArray{
                 cell.configureNew(with: arrayOfFileResults, appearanceType: headerName.rawValue, layOutType: fileLayOutType, templateType:liveSearchFileTemplateType, hashMapArray: hashMapArray, isSearchScreen: isSearchType)
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
                 //cell.configure(with: arrayOfDataResults, appearanceType: headerName.rawValue, layOutType: dataLayOutType, templateType:liveSearchDataTemplateType)
                 let mappingResultDic = (mappingResults.object(forKey: "default_group") as AnyObject)
                 if let hashMapArray = mappingResultDic["data"] as? NSArray{
                 cell.configureNew(with: arrayOfDataResults, appearanceType: headerName.rawValue, layOutType: dataLayOutType, templateType:liveSearchDataTemplateType, hashMapArray: hashMapArray, isSearchScreen: isSearchType)
                 
                 }
                 return cell
                 }else if liveSearchDataTemplateType == LiveSearchTypes.carousel.rawValue{
                 let cell = tableView.dequeueReusableCell(withIdentifier: CarouselTableViewCellIdentifier, for: indexPath) as! CarouselTableViewCell
                 //cell.configure(with: arrayOfDataResults, appearanceType: headerName.rawValue, layOutType: dataLayOutType, templateType:liveSearchDataTemplateType)
                 let mappingResultDic = (mappingResults.object(forKey: "default_group") as AnyObject)
                 if let hashMapArray = mappingResultDic["data"] as? NSArray{
                 cell.configureNew(with: arrayOfDataResults, appearanceType: headerName.rawValue, layOutType: dataLayOutType, templateType:liveSearchDataTemplateType, hashMapArray: hashMapArray, isSearchScreen: isSearchType)
                 
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
                 /*let cell : LiveSearchTaskTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: liveSearchTaskCellIdentifier) as! LiveSearchTaskTableViewCell
                 cell.backgroundColor = UIColor.clear
                 cell.selectionStyle = .none
                 cell.titleLabel.textColor = .black
                 let results = arrayOfTaskResults[indexPath.row]
                 cell.titleLabel?.text = results.name
                 var gridImage: String?
                 gridImage = results.imageUrl
                 if gridImage == nil || gridImage == ""{
                 cell.profileImageView.image = UIImage(named: "task")
                 }else{
                 let url = URL(string: gridImage!)
                 cell.profileImageView.setImageWith(url!, placeholderImage: UIImage(named: "task"))
                 }*/
                 
                 let cell : LiveSearchNewTaskViewCell = self.tableView.dequeueReusableCell(withIdentifier: liveSearchNewTaskCellIdentifier) as! LiveSearchNewTaskViewCell
                 cell.backgroundColor = UIColor.clear
                 cell.selectionStyle = .none
                 let results = arrayOfTaskResults[indexPath.row]
                 cell.titleLabel?.text = "\(results.name!)     "
                 cell.titleLabel?.layer.cornerRadius = 5.0
                 cell.titleLabel?.layer.borderWidth = 0.0
                 cell.titleLabel.layer.shadowOpacity = 0.7
                 cell.titleLabel.layer.shadowOffset = CGSize(width: 2, height: 2)
                 cell.titleLabel.layer.shadowRadius = 8.0
                 cell.titleLabel.layer.shadowColor = UIColor.init(red: 209/255, green: 217/255, blue: 224/255, alpha: 1.0).cgColor
                 return cell
                 }*/
            }
        }
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if !isLiveSearchApiCalling{
            
            if tableView == autoSearchTableView {
                let autoResults = autoSuggestionSearchItems.autoComplete?.querySuggestions![indexPath.row]
                viewDelegate?.optionsButtonTapAction(text: autoResults!)
            }else{
                autoSearchView.isHidden = false //kk
                if isPopularSearch{
                    let headerName = headerArray[indexPath.section]
                    switch headerName {
                    case "POPULAR SEARCHS":
                        self.viewDelegate?.addTextToTextView(text: ((popularSearchArray.object(at: indexPath.row) as AnyObject).object(forKey: "_id") as! String))
                    case "RECENT SEARCHS":
                        self.viewDelegate?.addTextToTextView(text: ((recentSearchNewArray.object(at: indexPath.row) as AnyObject) as? String)!)
                    default:
                        break
                    }
                }else{
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
                        //let mappingResultDic = (mappingResults.object(forKey: "\(headerArray[indexPath.row])") as AnyObject)
                        var mappingResultDic:AnyObject?
                        if self.resultTypeString  == self.resultTypeFlatString{
                            mappingResultDic = mappingResults
                        }else{
                            mappingResultDic = (mappingResults.object(forKey: "\(headerArray[indexPath.row])") as AnyObject)
                        }
                        if let hashMapArray = mappingResultDic?["data"] as? NSArray{
                            let url = ((hashMapArray.object(at: indexPath.row) as AnyObject).object(forKey: "\(arrayOfUrl[indexPath.section])") as? String)
                            if url != "" {
                                viewDelegate?.linkButtonTapAction(urlString: url!)
                            }
                        }
                        
                    }
                    /* let headerName:LiveSearchHeaderTypes = LiveSearchHeaderTypes(rawValue: headerArray[indexPath.section])!
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
                     viewDelegate?.linkButtonTapAction(urlString: url!)
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
                     let url = ((hashMapArray.object(at: indexPath.row) as AnyObject).object(forKey: "\(webUrl)") as? String)
                     if url != "" {
                     viewDelegate?.linkButtonTapAction(urlString: url!)
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
                     viewDelegate?.linkButtonTapAction(urlString: url!)
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
                     if url != "" {
                     viewDelegate?.linkButtonTapAction(urlString: url!)
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
                     viewDelegate?.optionsButtonTapTaskAction(text: arrayOfTaskResults[indexPath.row].name!, payload: payload, taskData: taskData as? [String : Any])
                     }
                     isEndOfTask = false //kk
                     }*/
                }
            }
        }
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        let headerLabel = UILabel(frame: .zero)
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.textAlignment = .left
        headerLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 15.0)
        headerLabel.font = headerLabel.font.withSize(15.0)
        
        headerLabel.textColor = .black
        
        view.addSubview(headerLabel)
        
        let dropDownBtn = UIButton(frame: CGRect.zero)
        dropDownBtn.backgroundColor = .clear
        dropDownBtn.translatesAutoresizingMaskIntoConstraints = false
        dropDownBtn.clipsToBounds = true
        dropDownBtn.layer.cornerRadius = 5
        dropDownBtn.setTitleColor(.gray, for: .normal)
        dropDownBtn.setTitleColor(Common.UIColorRGB(0x999999), for: .disabled)
        
        dropDownBtn.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
        dropDownBtn.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
        dropDownBtn.titleLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 15.0)!
        view.addSubview(dropDownBtn)
        dropDownBtn.tag = section
        dropDownBtn.semanticContentAttribute = .forceLeftToRight
        
        dropDownBtn.addTarget(self, action: #selector(self.headerDropDownButtonAction(_:)), for: .touchUpInside)
        
        let showMoreButton = UIButton(frame: CGRect.zero)
        showMoreButton.backgroundColor = .clear
        showMoreButton.translatesAutoresizingMaskIntoConstraints = false
        showMoreButton.clipsToBounds = true
        showMoreButton.layer.cornerRadius = 5
        showMoreButton.setTitleColor(.blue, for: .normal)
        showMoreButton.setTitleColor(Common.UIColorRGB(0x999999), for: .disabled)
        showMoreButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 14.0)!
        view.addSubview(showMoreButton)
        showMoreButton.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.center
        showMoreButton.addTarget(self, action: #selector(self.showMoreButtonAction(_:)), for: .touchUpInside)
        let attributeString = NSMutableAttributedString(string: "See all results",
                                                        attributes: yourAttributes)
        showMoreButton.setAttributedTitle(attributeString, for: .normal)
        showMoreButton.isHidden = true
        
        if tableView != autoSearchTableView{
            headerLabel.text =  headerArray[section].capitalized
            dropDownBtn.setTitle(" \(headerArray[section])", for: .normal)
            view.backgroundColor = UIColor.init(red: 240/255, green: 242/255, blue: 244/255, alpha: 1.0)
            if isPopularSearch {
                showMoreButton.isHidden = true
                dropDownBtn.isHidden = true
                headerLabel.isHidden = false
            }else{
                let boolValue = section == 0 ? false : true
                showMoreButton.isHidden = true //boolValue
                dropDownBtn.isHidden = false
                headerLabel.isHidden = true
                if headersExpandArray[section] as! String == "open"{
                    dropDownBtn.setImage(UIImage.init(named: "downarrow"), for: .normal)
                }else{dropDownBtn.setImage(UIImage.init(named: "rightarrow"), for: .normal)}
            }
        }
        
        let views: [String: UIView] = ["headerLabel": headerLabel, "dropDownBtn": dropDownBtn ,"showMoreButton": showMoreButton]
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[headerLabel]-5-[showMoreButton(100)]-10-|", options:[], metrics:nil, views:views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[dropDownBtn]-5-[showMoreButton(100)]-10-|", options:[], metrics:nil, views:views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[headerLabel]-5-|", options:[], metrics:nil, views:views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[showMoreButton]-5-|", options:[], metrics:nil, views:views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[dropDownBtn]-5-|", options:[], metrics:nil, views:views))
        
        return view
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView == autoSearchTableView{
            return 0.0//20
        }
        return 30
    }
}

extension LiveSearchView{
    @objc fileprivate func closeButtonAction(_ sender: AnyObject!) {
        //        recentSearchArray.removeObject(at: sender.tag)
        //        tableView.reloadData()
    }
    @objc fileprivate func shareButtonAction(_ sender: AnyObject!) {
        let results = arrayOfPageResults[sender.tag]
        if results.url != nil {
            viewDelegate?.linkButtonTapAction(urlString: results.url!)
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
    
    @objc fileprivate func showMoreButtonAction(_ sender: AnyObject!) {
        NotificationCenter.default.post(name: Notification.Name(showLiveSearchTemplateNotification), object: liveSearchJsonString! + ",,All")
    }
    
    @objc fileprivate func headerDropDownButtonAction(_ sender: UIButton!) {
        autoSearchView.isHidden = false //kk
        if headersExpandArray[sender.tag] as! String == "open"{
            headersExpandArray.replaceObject(at: sender.tag, with: "close")
        }else{
            headersExpandArray.replaceObject(at: sender.tag, with: "open")
        }
        tableView.reloadData()
    }
}

extension LiveSearchView{
    
    func heightForTable(resultExpandArray: NSMutableArray, layoutType: String, TemplateType: String, indexPath: IndexPath) -> CGFloat{
        if TemplateType == LiveSearchTypes.grid.rawValue{
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
                    return 50
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
        
       
        
        //let mappingResults = ((hashMapDic.object(forKey: "template") as AnyObject).object(forKey: "results") as AnyObject)
        if let templateDic = (hashMapDic["template"] as? [String: Any]), let  mappingResults = templateDic["results"] as? [String: Any]{
            var mappingResultDic:AnyObject?
            if self.resultTypeString  == self.resultTypeFlatString{
                mappingResultDic = mappingResults as AnyObject
            }else{
                mappingResultDic = mappingResults["\(appearanceType)"] as AnyObject
            }
            if let hashMapArray = mappingResultDic?["data"] as? NSArray{
                cell.titleLabel?.text = ((hashMapArray.object(at: indexPath.row) as AnyObject).object(forKey: "\(arrayOfHeading[indexPath.section])") as? String)
            }
        }
        
        /*
         let headerName:LiveSearchHeaderTypes = LiveSearchHeaderTypes(rawValue: appearanceType)!
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
        if let templateDic = (hashMapDic["template"] as? [String: Any]), let  mappingResults = templateDic["results"] as? [String: Any]{
            var mappingResultDic:AnyObject?
            if self.resultTypeString  == self.resultTypeFlatString{
                mappingResultDic = mappingResults as AnyObject
            }else{
                mappingResultDic = mappingResults["\(appearanceType)"] as AnyObject
            }
        if let hashMapArray = mappingResultDic?["data"] as? NSArray{
            cell.titleLabel?.text = ((hashMapArray.object(at: indexPath.row) as AnyObject).object(forKey: "\(arrayOfHeading[indexPath.section])") as? String)
            cell.descriptionLabel?.text = ((hashMapArray.object(at: indexPath.row) as AnyObject).object(forKey: "\(arrayOfDescription[indexPath.section])") as? String)
         }
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
        //let results = cellResultArray[indexPath.row]
        if let templateDic = (hashMapDic["template"] as? [String: Any]), let  mappingResults = templateDic["results"] as? [String: Any]{
            var mappingResultDic:AnyObject?
            if self.resultTypeString  == self.resultTypeFlatString{
                mappingResultDic = mappingResults as AnyObject
            }else{
                mappingResultDic = mappingResults["\(appearanceType)"] as AnyObject
            }
        if let hashMapArray = mappingResultDic?["data"] as? NSArray{
            cell.titleLabel?.text = ((hashMapArray.object(at: indexPath.row) as AnyObject).object(forKey: "\(arrayOfHeading[indexPath.section])") as? String)
            cell.descriptionLabel?.text = ((hashMapArray.object(at: indexPath.row) as AnyObject).object(forKey: "\(arrayOfDescription[indexPath.section])") as? String)
        }
        }
        /*let headerName:LiveSearchHeaderTypes = LiveSearchHeaderTypes(rawValue: appearanceType)!
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
    
    // MARK:- ListType - L4
    func titleWithImageCellMethod(cell: TitleWithImageCell,cellResultArray: [TemplateResultElements],expandArray: NSMutableArray, indexPath: IndexPath, isClickable: Bool, templateType: String, appearanceType: String){
        cell.backgroundColor = UIColor.clear
        cell.selectionStyle = .none
        cell.titleLabel.textColor = .black
        cell.descriptionLabel.textColor = .dark
        cell.titleLabel?.numberOfLines = 0 //2
        cell.descriptionLabel?.numberOfLines = 0 //2
        //let results = cellResultArray[indexPath.row]
        var gridImage: String?
        if let templateDic = (hashMapDic["template"] as? [String: Any]), let  mappingResults = templateDic["results"] as? [String: Any]{
            var mappingResultDic:AnyObject?
            if self.resultTypeString  == self.resultTypeFlatString{
                mappingResultDic = mappingResults as AnyObject
            }else{
                mappingResultDic = mappingResults["\(appearanceType)"] as AnyObject
            }
        if let hashMapArray = mappingResultDic?["data"] as? NSArray{
            cell.titleLabel?.text = ((hashMapArray.object(at: indexPath.row) as AnyObject).object(forKey: "\(arrayOfHeading[indexPath.section])") as? String)
            cell.descriptionLabel?.text = ((hashMapArray.object(at: indexPath.row) as AnyObject).object(forKey: "\(arrayOfDescription[indexPath.section])") as? String)
            gridImage = ((hashMapArray.object(at: indexPath.row) as AnyObject).object(forKey: "\(arrayOfImg[indexPath.section])") as? String)
        }
        }
        
        /*let headerName:LiveSearchHeaderTypes = LiveSearchHeaderTypes(rawValue: appearanceType)!
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
        var gridImage: String?
        if let templateDic = (hashMapDic["template"] as? [String: Any]), let  mappingResults = templateDic["results"] as? [String: Any]{
            var mappingResultDic:AnyObject?
            if self.resultTypeString  == self.resultTypeFlatString{
                mappingResultDic = mappingResults as AnyObject
            }else{
                mappingResultDic = mappingResults["\(appearanceType)"] as AnyObject
            }
        if let hashMapArray = mappingResultDic?["data"] as? NSArray{
            cell.titleLabel?.text = ((hashMapArray.object(at: indexPath.row) as AnyObject).object(forKey: "\(arrayOfHeading[indexPath.section])") as? String)
            cell.descriptionLabel?.text = ((hashMapArray.object(at: indexPath.row) as AnyObject).object(forKey: "\(arrayOfDescription[indexPath.section])") as? String)
            gridImage = ((hashMapArray.object(at: indexPath.row) as AnyObject).object(forKey: "\(arrayOfImg[indexPath.section])") as? String)
        }
        }
        
        /*let headerName:LiveSearchHeaderTypes = LiveSearchHeaderTypes(rawValue: appearanceType)!
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
