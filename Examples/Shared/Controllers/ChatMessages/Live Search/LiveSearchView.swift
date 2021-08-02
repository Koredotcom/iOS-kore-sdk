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
    var tableView: UITableView!
    var notifyLabel: UILabel!
    fileprivate let popularSearchCellIdentifier = "PopularLiveSearchCell"
    fileprivate let liveSearchFaqCellIdentifier = "LiveSearchFaqTableViewCell"
    fileprivate let liveSearchPageCellIdentifier = "LiveSearchPageTableViewCell"
    fileprivate let liveSearchTaskCellIdentifier = "LiveSearchTaskTableViewCell"
    fileprivate let liveSearchNewTaskCellIdentifier = "LiveSearchNewTaskViewCell"
    
    fileprivate let titleWithImageCellIdentifier = "TitleWithImageCell"
    fileprivate let titleWithCenteredContentCellIdentifier = "TitleWithCenteredContentCell"
    fileprivate let TitleWithHeaderCellIdentifier = "TitleWithHeaderCell"
    
    fileprivate let GridTableViewCellIdentifier = "GridTableViewCell"
    
    
    
    
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
    
    let liveSearchFileTemplateType = resultViewSettingItems?.settings?[2].appearance?[0].template?.type ?? "listTemplate1"
    let fileLayOutType = resultViewSettingItems?.settings?[2].appearance?[0].template?.layout?.layoutType ?? "tileWithText"
    let isFileClickable = resultViewSettingItems?.settings?[2].appearance?[0].template?.layout?.isClickable ?? true
    
    let liveSearchFAQsTemplateType = resultViewSettingItems?.settings?[2].appearance?[1].template?.type ?? "listTemplate1"
    let faqLayOutType = resultViewSettingItems?.settings?[2].appearance?[1].template?.layout?.layoutType ??  "tileWithText"
    let isFaqsClickable = resultViewSettingItems?.settings?[2].appearance?[1].template?.layout?.isClickable ?? true
    
    let liveSearchPageTemplateType = resultViewSettingItems?.settings?[2].appearance?[2].template?.type ?? "listTemplate1"
    let pageLayOutType = resultViewSettingItems?.settings?[2].appearance?[2].template?.layout?.layoutType ?? "tileWithImage"
    let isPagesClickable = resultViewSettingItems?.settings?[2].appearance?[2].template?.layout?.isClickable ?? true
    
    let liveSearchDataTemplateType = resultViewSettingItems?.settings?[2].appearance?[3].template?.type ?? "listTemplate1"
    let dataLayOutType = resultViewSettingItems?.settings?[2].appearance?[3].template?.layout?.layoutType ?? "tileWithText"
    let isDataClickable = resultViewSettingItems?.settings?[2].appearance?[3].template?.layout?.isClickable ?? true
    
    let fileHeading = resultViewSettingItems?.settings?[2].appearance?[0].template?.mapping?.heading ?? ""
    let fileDescription = resultViewSettingItems?.settings?[2].appearance?[0].template?.mapping?.descrip ?? ""
    let fileImg = resultViewSettingItems?.settings?[2].appearance?[0].template?.mapping?.img ?? ""
    let fileUrl = resultViewSettingItems?.settings?[2].appearance?[0].template?.mapping?.url ?? ""
    
    let faqHeading = resultViewSettingItems?.settings?[2].appearance?[1].template?.mapping?.heading ?? ""
    let faqDescription = resultViewSettingItems?.settings?[2].appearance?[1].template?.mapping?.descrip ?? ""
    let faqImg = resultViewSettingItems?.settings?[2].appearance?[1].template?.mapping?.img ?? ""
    let faqUrl = resultViewSettingItems?.settings?[2].appearance?[1].template?.mapping?.url ?? ""
    
    let webHeading = resultViewSettingItems?.settings?[2].appearance?[2].template?.mapping?.heading ?? ""
    let webDescription = resultViewSettingItems?.settings?[2].appearance?[2].template?.mapping?.descrip ?? ""
    let webImg = resultViewSettingItems?.settings?[2].appearance?[2].template?.mapping?.img ?? ""
    let webUrl = resultViewSettingItems?.settings?[2].appearance?[2].template?.mapping?.url ?? ""
    
    let dataHeading = resultViewSettingItems?.settings?[2].appearance?[3].template?.mapping?.heading ?? ""
    let dataDescription = resultViewSettingItems?.settings?[2].appearance?[3].template?.mapping?.descrip ?? ""
    let dataImg = resultViewSettingItems?.settings?[2].appearance?[3].template?.mapping?.img ?? ""
    let dataUrl = resultViewSettingItems?.settings?[2].appearance?[3].template?.mapping?.url ?? ""
    var hashMapDic: NSDictionary = [String: Any]() as NSDictionary
   
    enum LiveSearchHeaderTypes: String{
        case faq = "FAQS"
        case web = "WEB"
        case task = "TASKS"
        case file = "Files"
        case data = "DATA"
    }
    enum LiveSearchLayoutTypes: String{
        case tileWithText = "tileWithText"
        case tileWithImage = "tileWithImage"
        case tileWithCenteredContent = "tileWithCenteredContent"
        case tileWithHeader = "tileWithHeader"
    }
    enum LiveSearchTemplateTypes: String{
        case listTemplate1 = "listTemplate1"
        case listTemplate2 = "listTemplate2"
        case listTemplate3 = "listTemplate3"
    }
    
    enum LiveSearchTypes: String{
        case listTemplate = "listTemplate"
        case grid = "grid"
        case carousel = "carousel"
    }
    
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
    
    fileprivate func setupViews() {
        
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
        self.tableView.register(UINib(nibName: popularSearchCellIdentifier, bundle: nil), forCellReuseIdentifier: popularSearchCellIdentifier)
        self.tableView.register(UINib(nibName: liveSearchFaqCellIdentifier, bundle: nil), forCellReuseIdentifier: liveSearchFaqCellIdentifier)
        self.tableView.register(UINib(nibName: liveSearchPageCellIdentifier, bundle: nil), forCellReuseIdentifier: liveSearchPageCellIdentifier)
        self.tableView.register(UINib(nibName: liveSearchTaskCellIdentifier, bundle: nil), forCellReuseIdentifier: liveSearchTaskCellIdentifier)
        self.tableView.register(UINib(nibName: liveSearchNewTaskCellIdentifier, bundle: nil), forCellReuseIdentifier: liveSearchNewTaskCellIdentifier)
        
        
        self.tableView.register(UINib(nibName: titleWithImageCellIdentifier, bundle: nil), forCellReuseIdentifier: titleWithImageCellIdentifier)
        self.tableView.register(UINib(nibName: titleWithCenteredContentCellIdentifier, bundle: nil), forCellReuseIdentifier: titleWithCenteredContentCellIdentifier)
        self.tableView.register(UINib(nibName: TitleWithHeaderCellIdentifier, bundle: nil), forCellReuseIdentifier: TitleWithHeaderCellIdentifier)
        
        self.tableView.register(UINib(nibName: GridTableViewCellIdentifier, bundle: nil), forCellReuseIdentifier: GridTableViewCellIdentifier)
        
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
        autoSearchView.backgroundColor = UIColor.init(red: 248/255, green: 249/255, blue: 250/255, alpha: 1.0)
        self.autoSearchView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.autoSearchView)
        
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
        self.autoSearchTableView.isScrollEnabled = false
        self.autoSearchView.isHidden = true
        
        let autoViews: [String: UIView] = ["autoSearchTableView": autoSearchTableView]
        self.autoSearchView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-20-[autoSearchTableView]-0-|", options: [], metrics: nil, views: autoViews))
        self.autoSearchView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[autoSearchTableView]-0-|", options: [], metrics: nil, views: autoViews))
        
        
        let views: [String: UIView] = ["tableView": tableView, "notifyLabel":notifyLabel, "autoSearchView":autoSearchView]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-15-[tableView]-0-|", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-100-[notifyLabel]-0-|", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[tableView]-10-|", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[notifyLabel]-10-|", options: [], metrics: nil, views: views))
         self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[autoSearchView(200)]-0-|", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[autoSearchView]-0-|", options: [], metrics: nil, views: views))
        NotificationCenter.default.addObserver(self, selector: #selector(callingLiveSearchView(notification:)), name: NSNotification.Name(rawValue: "textViewDidChange"), object: nil)
        
        if #available(iOS 11.0, *) {
            self.roundCorners([ .layerMinXMinYCorner, .layerMaxXMinYCorner], radius: 20.0, borderColor: UIColor.lightGray, borderWidth: 0)
            self.autoSearchTableView.roundCorners([ .layerMinXMinYCorner, .layerMaxXMinYCorner], radius: 20.0, borderColor: UIColor.lightGray, borderWidth: 1)
        } else {
            // Fallback on earlier versions
        }
        self.backgroundColor = UIColor.init(red: 240/255, green: 242/255, blue: 244/255, alpha: 1.0)
        
        headerArray = []
        callingPopularSearchApi()
        callingRecentSearchApi()
    }
    @objc func callingLiveSearchView(notification:Notification) {
        let dataString: String = notification.object as! String
        print("LiveSearchView: \(dataString)")
        
        if dataString == ""{
            autoSuggestionSearchItems = AutoSuggestionModel()
            autoSearchTableView.reloadData()
            autoSearchView.isHidden = true
             
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                self.headerArray = []
                self.callingPopularSearchApi()
                self.callingRecentSearchApi()
            })
            
        }else{
            autoSearchView.isHidden = false
             headerArray = []
            callingAutoSuggestionSearchApi(searchText: dataString)
            callingLiveSearchApi(searchText: dataString)
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
                    let allItems = try? jsonDecoder.decode(LiveSearchChatItems.self, from: jsonData) else {
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
                
                let faqs = allItems.template?.results?.faq
                self?.arrayOfFaqResults = faqs ?? []
                if self!.arrayOfFaqResults.count > 0 {
                    self!.headerArray.append(LiveSearchHeaderTypes.faq.rawValue)
                    self!.headersExpandArray.add("open")
                }
                for _ in 0..<self!.arrayOfFaqResults.count{
                    self!.faqsExpandArray.add("close")
                    self?.likeAndDislikeArray.add("")
                }
                
                let pages = allItems.template?.results?.page
                self?.arrayOfPageResults = pages ?? []
                if self!.arrayOfPageResults.count > 0 {
                    self!.headerArray.append(LiveSearchHeaderTypes.web.rawValue)
                    self!.headersExpandArray.add("open")
                }
                for _ in 0..<self!.arrayOfPageResults.count{
                    self!.pagesExpandArray.add("close")
                }
                
                let task = allItems.template?.results?.task
                self?.arrayOfTaskResults = task ?? []
                if self!.arrayOfTaskResults.count > 0 {
                    self!.headerArray.append(LiveSearchHeaderTypes.task.rawValue)
                    self!.headersExpandArray.add("open")
                    //isShowLoginView = true //kk
                }else{
                    //isShowLoginView = false //kk
                }
                 
                let files = allItems.template?.results?.file
                self?.arrayOfFileResults = files ?? []
                if self!.arrayOfFileResults.count > 0 {
                    self!.headerArray.append(LiveSearchHeaderTypes.file.rawValue)
                    self!.headersExpandArray.add("open")
                }
                for _ in 0..<self!.arrayOfFileResults.count{
                    self!.filesExpandArray.add("close")
                }
                
                let data = allItems.template?.results?.data
                self?.arrayOfDataResults = data ?? []
                if self!.arrayOfDataResults.count > 0 {
                    self!.headerArray.append(LiveSearchHeaderTypes.data.rawValue)
                    self!.headersExpandArray.add("open")
                }
                for _ in 0..<self!.arrayOfDataResults.count{
                    self!.dataExpandArray.add("close")
                }
                
                
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
            }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == autoSearchTableView{
            return UITableView.automaticDimension
        }else{
            if isPopularSearch{
                        return UITableView.automaticDimension
                    }else {
                        let headerName:LiveSearchHeaderTypes = LiveSearchHeaderTypes(rawValue: headerArray[indexPath.section])!
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
                        }
                       
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
            return autoSearchItems > 3 ? 3 :  autoSearchItems
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
                let headerName: LiveSearchHeaderTypes = LiveSearchHeaderTypes(rawValue: headerArray[section])!
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
                }
            }
        }
        
        
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == autoSearchTableView{
            
            let cell : PopularLiveSearchCell = self.tableView.dequeueReusableCell(withIdentifier: popularSearchCellIdentifier) as! PopularLiveSearchCell
            cell.backgroundColor = UIColor.clear
            cell.selectionStyle = .none
            let autoResults = autoSuggestionSearchItems.autoComplete?.querySuggestions![indexPath.row]
            cell.titleLabel.text = (autoResults!)
            cell.titleLabel.numberOfLines = 1
            cell.titleLabel.textColor = .black
            cell.titleLabel.font = UIFont.systemFont(ofSize: 13.0)
            cell.closeButtonWidthConstraint.constant = CGFloat(00.0)
            cell.subVLeadingConstraint.constant = 15.0
            cell.subVTrailingConstraint.constant = 15.0
            cell.subView.layer.cornerRadius = 15
            cell.subView.layer.borderWidth = 1.0
            cell.subView.layer.borderColor = UIColor.lightGray.cgColor
            return cell
            
        }else{
            if isPopularSearch{
                let cell : PopularLiveSearchCell = self.tableView.dequeueReusableCell(withIdentifier: popularSearchCellIdentifier) as! PopularLiveSearchCell
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
                let width = headerArray[indexPath.section] == "RECENT SEARCHS" ? 00.0 : 0.0
                cell.closeButtonWidthConstraint.constant = CGFloat(width)
                return cell
            }else{
                let headerName: LiveSearchHeaderTypes = LiveSearchHeaderTypes(rawValue: headerArray[indexPath.section])!
                switch headerName {
                case .faq:
                    if liveSearchFAQsTemplateType == LiveSearchTypes.grid.rawValue || liveSearchFAQsTemplateType == LiveSearchTypes.carousel.rawValue{
                        let cell = tableView.dequeueReusableCell(withIdentifier: GridTableViewCellIdentifier, for: indexPath) as! GridTableViewCell
                        cell.configure(with: arrayOfFaqResults, appearanceType: headerName.rawValue, layOutType: faqLayOutType, templateType:liveSearchFAQsTemplateType)
                        return cell
                    }else{
                        let layOutType :LiveSearchLayoutTypes = LiveSearchLayoutTypes(rawValue: faqLayOutType)!
                        switch layOutType {
                        case .tileWithText:
                            let cell : LiveSearchFaqTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: liveSearchFaqCellIdentifier) as! LiveSearchFaqTableViewCell
                            titleWithTextCellMethod(cell: cell, cellResultArray: arrayOfFaqResults, expandArray: faqsExpandArray, indexPath: indexPath, isClickable: isFaqsClickable, templateType: liveSearchFAQsTemplateType, appearanceType: headerName.rawValue)
                            return cell
                        case .tileWithImage:
                            let cell : TitleWithImageCell = self.tableView.dequeueReusableCell(withIdentifier: titleWithImageCellIdentifier) as! TitleWithImageCell
                            titleWithImageCellMethod(cell: cell, cellResultArray: arrayOfFaqResults, expandArray: faqsExpandArray, indexPath: indexPath, isClickable: isFaqsClickable, templateType: liveSearchFAQsTemplateType, appearanceType: headerName.rawValue)
                            return cell
                        case .tileWithCenteredContent:
                            let cell : TitleWithCenteredContentCell = self.tableView.dequeueReusableCell(withIdentifier: titleWithCenteredContentCellIdentifier) as! TitleWithCenteredContentCell
                            titleWithCenteredContentCellMethod(cell: cell, cellResultArray: arrayOfFaqResults, expandArray: faqsExpandArray, indexPath: indexPath, isClickable: isFaqsClickable, templateType: liveSearchFAQsTemplateType, appearanceType: headerName.rawValue)
                            return cell
                        case .tileWithHeader:
                            let cell : TitleWithHeaderCell = self.tableView.dequeueReusableCell(withIdentifier: TitleWithHeaderCellIdentifier) as! TitleWithHeaderCell
                            TitleWithHeaderCellMethod(cell: cell, cellResultArray: arrayOfFaqResults, expandArray: faqsExpandArray, indexPath: indexPath, isClickable: isFaqsClickable, templateType: liveSearchFAQsTemplateType, appearanceType: headerName.rawValue)
                            return cell
                        }
                    }
                case .web:
                    if liveSearchPageTemplateType == LiveSearchTypes.grid.rawValue || liveSearchPageTemplateType == LiveSearchTypes.carousel.rawValue{
                        let cell = tableView.dequeueReusableCell(withIdentifier: GridTableViewCellIdentifier, for: indexPath) as! GridTableViewCell
                        cell.configure(with: arrayOfPageResults, appearanceType: headerName.rawValue, layOutType: pageLayOutType, templateType:liveSearchPageTemplateType)
                        return cell
                    }else{
                        let layOutType :LiveSearchLayoutTypes = LiveSearchLayoutTypes(rawValue: pageLayOutType)!
                        switch layOutType {
                        case .tileWithText:
                            let cell : LiveSearchFaqTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: liveSearchFaqCellIdentifier) as! LiveSearchFaqTableViewCell
                            titleWithTextCellMethod(cell: cell, cellResultArray: arrayOfPageResults, expandArray: pagesExpandArray, indexPath: indexPath, isClickable: isPagesClickable, templateType: liveSearchPageTemplateType, appearanceType: headerName.rawValue)
                            return cell
                        case .tileWithImage:
                            let cell : TitleWithImageCell = self.tableView.dequeueReusableCell(withIdentifier: titleWithImageCellIdentifier) as! TitleWithImageCell
                            titleWithImageCellMethod(cell: cell, cellResultArray: arrayOfPageResults, expandArray:
                                pagesExpandArray, indexPath: indexPath, isClickable: isPagesClickable, templateType: liveSearchPageTemplateType, appearanceType: headerName.rawValue)
                            return cell
                        case .tileWithCenteredContent:
                            let cell : TitleWithCenteredContentCell = self.tableView.dequeueReusableCell(withIdentifier: titleWithCenteredContentCellIdentifier) as! TitleWithCenteredContentCell
                            titleWithCenteredContentCellMethod(cell: cell, cellResultArray: arrayOfPageResults, expandArray: pagesExpandArray, indexPath: indexPath, isClickable: isPagesClickable, templateType: liveSearchPageTemplateType, appearanceType: headerName.rawValue)
                            return cell
                        case .tileWithHeader:
                            let cell : TitleWithHeaderCell = self.tableView.dequeueReusableCell(withIdentifier: TitleWithHeaderCellIdentifier) as! TitleWithHeaderCell
                            TitleWithHeaderCellMethod(cell: cell, cellResultArray: arrayOfPageResults, expandArray: pagesExpandArray, indexPath: indexPath, isClickable: isPagesClickable, templateType: liveSearchPageTemplateType, appearanceType: headerName.rawValue)
                            return cell
                        }
                    }
                    
                case .file:
                    if liveSearchFileTemplateType == LiveSearchTypes.grid.rawValue || liveSearchFileTemplateType == LiveSearchTypes.carousel.rawValue{
                        let cell = tableView.dequeueReusableCell(withIdentifier: GridTableViewCellIdentifier, for: indexPath) as! GridTableViewCell
                        cell.configure(with: arrayOfFileResults, appearanceType: headerName.rawValue, layOutType: fileLayOutType, templateType:liveSearchFileTemplateType)
                        return cell
                    }else{
                        let layOutType :LiveSearchLayoutTypes = LiveSearchLayoutTypes(rawValue: fileLayOutType)!
                        switch layOutType {
                        case .tileWithText:
                            let cell : LiveSearchFaqTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: liveSearchFaqCellIdentifier) as! LiveSearchFaqTableViewCell
                            titleWithTextCellMethod(cell: cell, cellResultArray: arrayOfFileResults, expandArray: filesExpandArray, indexPath: indexPath, isClickable: isFileClickable, templateType: liveSearchFileTemplateType, appearanceType: headerName.rawValue)
                            return cell
                        case .tileWithImage:
                            let cell : TitleWithImageCell = self.tableView.dequeueReusableCell(withIdentifier: titleWithImageCellIdentifier) as! TitleWithImageCell
                            titleWithImageCellMethod(cell: cell, cellResultArray: arrayOfFileResults, expandArray:
                                filesExpandArray, indexPath: indexPath, isClickable: isFileClickable, templateType: liveSearchFileTemplateType, appearanceType: headerName.rawValue)
                            return cell
                        case .tileWithCenteredContent:
                            let cell : TitleWithCenteredContentCell = self.tableView.dequeueReusableCell(withIdentifier: titleWithCenteredContentCellIdentifier) as! TitleWithCenteredContentCell
                            titleWithCenteredContentCellMethod(cell: cell, cellResultArray: arrayOfFileResults, expandArray: filesExpandArray, indexPath: indexPath, isClickable: isFileClickable, templateType: liveSearchFileTemplateType, appearanceType: headerName.rawValue)
                            return cell
                        case .tileWithHeader:
                            let cell : TitleWithHeaderCell = self.tableView.dequeueReusableCell(withIdentifier: TitleWithHeaderCellIdentifier) as! TitleWithHeaderCell
                            TitleWithHeaderCellMethod(cell: cell, cellResultArray: arrayOfFileResults, expandArray: filesExpandArray, indexPath: indexPath, isClickable: isFileClickable, templateType: liveSearchFileTemplateType, appearanceType: headerName.rawValue)
                            return cell
                        }
                    }
                    
                case .data:
                    if liveSearchDataTemplateType == LiveSearchTypes.grid.rawValue || liveSearchDataTemplateType == LiveSearchTypes.carousel.rawValue{
                        let cell = tableView.dequeueReusableCell(withIdentifier: GridTableViewCellIdentifier, for: indexPath) as! GridTableViewCell
                        cell.configure(with: arrayOfDataResults, appearanceType: headerName.rawValue, layOutType: dataLayOutType, templateType:liveSearchDataTemplateType)
                        return cell
                    }else{
                        let layOutType :LiveSearchLayoutTypes = LiveSearchLayoutTypes(rawValue:  dataLayOutType)!
                        switch layOutType {
                        case .tileWithText:
                            let cell : LiveSearchFaqTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: liveSearchFaqCellIdentifier) as! LiveSearchFaqTableViewCell
                            titleWithTextCellMethod(cell: cell, cellResultArray: arrayOfDataResults, expandArray: dataExpandArray, indexPath: indexPath, isClickable: isDataClickable, templateType: liveSearchDataTemplateType, appearanceType: headerName.rawValue)
                            return cell
                        case .tileWithImage:
                            let cell : TitleWithImageCell = self.tableView.dequeueReusableCell(withIdentifier: titleWithImageCellIdentifier) as! TitleWithImageCell
                            titleWithImageCellMethod(cell: cell, cellResultArray: arrayOfDataResults, expandArray:
                                dataExpandArray, indexPath: indexPath, isClickable: isDataClickable, templateType: liveSearchDataTemplateType, appearanceType: headerName.rawValue)
                            return cell
                        case .tileWithCenteredContent:
                            let cell : TitleWithCenteredContentCell = self.tableView.dequeueReusableCell(withIdentifier: titleWithCenteredContentCellIdentifier) as! TitleWithCenteredContentCell
                            titleWithCenteredContentCellMethod(cell: cell, cellResultArray: arrayOfDataResults, expandArray: dataExpandArray, indexPath: indexPath, isClickable: isDataClickable, templateType: liveSearchDataTemplateType, appearanceType: headerName.rawValue)
                            return cell
                        case .tileWithHeader:
                            let cell : TitleWithHeaderCell = self.tableView.dequeueReusableCell(withIdentifier: TitleWithHeaderCellIdentifier) as! TitleWithHeaderCell
                            TitleWithHeaderCellMethod(cell: cell, cellResultArray: arrayOfDataResults, expandArray: dataExpandArray, indexPath: indexPath, isClickable: isDataClickable, templateType: liveSearchDataTemplateType, appearanceType: headerName.rawValue)
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
                }
            }
        }
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView == autoSearchTableView {
            let autoResults = autoSuggestionSearchItems.autoComplete?.querySuggestions![indexPath.row]
            viewDelegate?.optionsButtonTapAction(text: autoResults!)
        }else{
            autoSearchView.isHidden = true
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
                        let url = (((mappingResults.object(forKey: "faq") as AnyObject).object(at: indexPath.row) as AnyObject).object(forKey: "\(faqUrl)") as? String)
                           if url != "" {
                            viewDelegate?.linkButtonTapAction(urlString: url!)
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
                        let url = (((mappingResults.object(forKey: "web") as AnyObject).object(at: indexPath.row) as AnyObject).object(forKey: "\(webUrl)") as? String)
                           if url != "" {
                            viewDelegate?.linkButtonTapAction(urlString: url!)
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
                        let url = (((mappingResults.object(forKey: "file") as AnyObject).object(at: indexPath.row) as AnyObject).object(forKey: "\(fileUrl)") as? String)
                           if url != "" {
                            viewDelegate?.linkButtonTapAction(urlString: url!)
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
                        let url = (((mappingResults.object(forKey: "data") as AnyObject).object(at: indexPath.row) as AnyObject).object(forKey: "\(dataUrl)") as? String)
                           if url != "" {
                            viewDelegate?.linkButtonTapAction(urlString: url!)
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
        
        headerLabel.textColor = .gray
        
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
            headerLabel.text =  headerArray[section]
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
            return 20
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
    
    @objc fileprivate func headerDropDownButtonAction(_ sender: AnyObject!) {
        autoSearchView.isHidden = true
        if headersExpandArray[sender.tag] as! String == "open"{
            headersExpandArray.replaceObject(at: sender.tag, with: "close")
        }else{
            headersExpandArray.replaceObject(at: sender.tag, with: "open")
        }
        tableView.reloadData()
    }
}

extension LiveSearchView{
    
    func heightForTable(resultExpandArray: NSMutableArray, layoutType: String, TemplateType: String, index: Int) -> CGFloat{
        if TemplateType == LiveSearchTypes.grid.rawValue{
            return UITableView.automaticDimension
        }else if TemplateType == LiveSearchTypes.carousel.rawValue{
            return 160 //250
        }else{
            let layOutType:LiveSearchLayoutTypes = LiveSearchLayoutTypes(rawValue: layoutType)!
            switch layOutType {
            case .tileWithText:
                if  resultExpandArray[index] as! String == "close"{
                    return 75
                }
                return UITableView.automaticDimension
                
            case .tileWithImage:
                if  resultExpandArray[index] as! String == "close"{
                    return 80
                }
                return UITableView.automaticDimension
            case .tileWithCenteredContent:
                if  resultExpandArray[index] as! String == "close"{
                    return 75+100
                }
                return UITableView.automaticDimension
            case .tileWithHeader:
                if  resultExpandArray[index] as! String == "close"{
                    return 50
                }
                return UITableView.automaticDimension
            }
        }
    }
    
    func titleWithTextCellMethod(cell: LiveSearchFaqTableViewCell,cellResultArray: [TemplateResultElements],expandArray: NSMutableArray, indexPath: IndexPath, isClickable: Bool, templateType: String, appearanceType: String){
        
        cell.backgroundColor = UIColor.clear
        cell.selectionStyle = .none
        cell.titleLabel.textColor = .black
        cell.descriptionLabel.textColor = .dark
        cell.titleLabel?.numberOfLines = 0 //2
        cell.descriptionLabel?.numberOfLines = 0 //2
        //let results = cellResultArray[indexPath.row]
        let mappingResults = ((hashMapDic.object(forKey: "template") as AnyObject).object(forKey: "results") as AnyObject)
        let headerName:LiveSearchHeaderTypes = LiveSearchHeaderTypes(rawValue: appearanceType)!
        switch headerName {
        case .faq:
            cell.titleLabel?.text = (((mappingResults.object(forKey: "faq") as AnyObject).object(at: indexPath.row) as AnyObject).object(forKey: "\(faqHeading)") as? String)
            cell.descriptionLabel?.text = (((mappingResults.object(forKey: "faq") as AnyObject).object(at: indexPath.row) as AnyObject).object(forKey: "\(faqDescription)") as? String)
        case .web:
            cell.titleLabel?.text = (((mappingResults.object(forKey: "web") as AnyObject).object(at: indexPath.row) as AnyObject).object(forKey: "\(webHeading)") as? String)
            cell.descriptionLabel?.text = (((mappingResults.object(forKey: "web") as AnyObject).object(at: indexPath.row) as AnyObject).object(forKey: "\(webDescription)") as? String)
        case .file:
            cell.titleLabel?.text = (((mappingResults.object(forKey: "file") as AnyObject).object(at: indexPath.row) as AnyObject).object(forKey: "\(fileHeading)") as? String)
            cell.descriptionLabel?.text = (((mappingResults.object(forKey: "file") as AnyObject).object(at: indexPath.row) as AnyObject).object(forKey: "\(fileDescription)") as? String)
        case .data:
            cell.titleLabel?.text = (((mappingResults.object(forKey: "data") as AnyObject).object(at: indexPath.row) as AnyObject).object(forKey: "\(dataHeading)") as? String)
            cell.descriptionLabel?.text = (((mappingResults.object(forKey: "data") as AnyObject).object(at: indexPath.row) as AnyObject).object(forKey: "\(dataDescription)") as? String)
        case .task:
            break
        }

        
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
        let headerName:LiveSearchHeaderTypes = LiveSearchHeaderTypes(rawValue: appearanceType)!
        switch headerName {
        case .faq:
             cell.titleLabel?.text = (((mappingResults.object(forKey: "faq") as AnyObject).object(at: indexPath.row) as AnyObject).object(forKey: "\(faqHeading)") as? String)
            cell.descriptionLabel?.text = (((mappingResults.object(forKey: "faq") as AnyObject).object(at: indexPath.row) as AnyObject).object(forKey: "\(faqDescription)") as? String)
             gridImage = (((mappingResults.object(forKey: "faq") as AnyObject).object(at: indexPath.row) as AnyObject).object(forKey: "\(faqImg)") as? String)
        case .web:
            cell.titleLabel?.text = (((mappingResults.object(forKey: "web") as AnyObject).object(at: indexPath.row) as AnyObject).object(forKey: "\(webHeading)") as? String)
            cell.descriptionLabel?.text = (((mappingResults.object(forKey: "web") as AnyObject).object(at: indexPath.row) as AnyObject).object(forKey: "\(webDescription)") as? String)
            gridImage = (((mappingResults.object(forKey: "web") as AnyObject).object(at: indexPath.row) as AnyObject).object(forKey: "\(webImg)") as? String)
        case .file:
            cell.titleLabel?.text = (((mappingResults.object(forKey: "file") as AnyObject).object(at: indexPath.row) as AnyObject).object(forKey: "\(fileHeading)") as? String)
            cell.descriptionLabel?.text = (((mappingResults.object(forKey: "file") as AnyObject).object(at: indexPath.row) as AnyObject).object(forKey: "\(fileDescription)") as? String)
            gridImage = (((mappingResults.object(forKey: "file") as AnyObject).object(at: indexPath.row) as AnyObject).object(forKey: "\(fileImg)") as? String)
        case .data:
            cell.titleLabel?.text = (((mappingResults.object(forKey: "data") as AnyObject).object(at: indexPath.row) as AnyObject).object(forKey: "\(dataHeading)") as? String)
            cell.descriptionLabel?.text = (((mappingResults.object(forKey: "data") as AnyObject).object(at: indexPath.row) as AnyObject).object(forKey: "\(dataDescription)") as? String)
            gridImage = (((mappingResults.object(forKey: "data") as AnyObject).object(at: indexPath.row) as AnyObject).object(forKey: "\(dataImg)") as? String)
        case .task:
            break
        }
                
        let buttonsHeight = expandArray[indexPath.row] as! String == "close" ? 0.0: 0.0 //30.0
        cell.likeAndDislikeButtonHeightConstrain.constant = CGFloat(buttonsHeight)
        
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
        let headerName:LiveSearchHeaderTypes = LiveSearchHeaderTypes(rawValue: appearanceType)!
        switch headerName {
        case .faq:
            cell.titleLabel?.text = (((mappingResults.object(forKey: "faq") as AnyObject).object(at: indexPath.row) as AnyObject).object(forKey: "\(faqHeading)") as? String)
            cell.descriptionLabel?.text = (((mappingResults.object(forKey: "faq") as AnyObject).object(at: indexPath.row) as AnyObject).object(forKey: "\(faqDescription)") as? String)
           gridImage = (((mappingResults.object(forKey: "faq") as AnyObject).object(at: indexPath.row) as AnyObject).object(forKey: "\(faqImg)") as? String)
        case .web:
            cell.titleLabel?.text = (((mappingResults.object(forKey: "web") as AnyObject).object(at: indexPath.row) as AnyObject).object(forKey: "\(webHeading)") as? String)
            cell.descriptionLabel?.text = (((mappingResults.object(forKey: "web") as AnyObject).object(at: indexPath.row) as AnyObject).object(forKey: "\(webDescription)") as? String)
            gridImage = (((mappingResults.object(forKey: "web") as AnyObject).object(at: indexPath.row) as AnyObject).object(forKey: "\(webImg)") as? String)
        case .file:
            cell.titleLabel?.text = (((mappingResults.object(forKey: "file") as AnyObject).object(at: indexPath.row) as AnyObject).object(forKey: "\(fileHeading)") as? String)
            cell.descriptionLabel?.text = (((mappingResults.object(forKey: "file") as AnyObject).object(at: indexPath.row) as AnyObject).object(forKey: "\(fileDescription)") as? String)
            gridImage = (((mappingResults.object(forKey: "file") as AnyObject).object(at: indexPath.row) as AnyObject).object(forKey: "\(fileImg)") as? String)
        case .data:
           cell.titleLabel?.text = (((mappingResults.object(forKey: "data") as AnyObject).object(at: indexPath.row) as AnyObject).object(forKey: "\(dataHeading)") as? String)
           cell.descriptionLabel?.text = (((mappingResults.object(forKey: "data") as AnyObject).object(at: indexPath.row) as AnyObject).object(forKey: "\(dataDescription)") as? String)
           gridImage = (((mappingResults.object(forKey: "data") as AnyObject).object(at: indexPath.row) as AnyObject).object(forKey: "\(dataImg)") as? String)
        case .task:
            break
        }
        
        let buttonsHeight = expandArray[indexPath.row] as! String == "close" ? 0.0: 0.0 //30.0
        cell.likeAndDislikeButtonHeightConstrain.constant = CGFloat(buttonsHeight)
        
        if !isClickable{
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
    
    func TitleWithHeaderCellMethod(cell: TitleWithHeaderCell,cellResultArray: [TemplateResultElements],expandArray: NSMutableArray, indexPath: IndexPath, isClickable: Bool, templateType: String, appearanceType: String) {
        
        cell.backgroundColor = UIColor.clear
        cell.selectionStyle = .none
        cell.titleLabel.textColor = .black
        
        cell.titleLabel?.numberOfLines = 0 //2
        
        //let results = cellResultArray[indexPath.row]
        let mappingResults = ((hashMapDic.object(forKey: "template") as AnyObject).object(forKey: "results") as AnyObject)
        let headerName:LiveSearchHeaderTypes = LiveSearchHeaderTypes(rawValue: appearanceType)!
        switch headerName {
        case .faq:
            cell.titleLabel?.text = (((mappingResults.object(forKey: "faq") as AnyObject).object(at: indexPath.row) as AnyObject).object(forKey: "\(faqHeading)") as? String)
        case .web:
            cell.titleLabel?.text = (((mappingResults.object(forKey: "web") as AnyObject).object(at: indexPath.row) as AnyObject).object(forKey: "\(webHeading)") as? String)
        case .file:
           cell.titleLabel?.text = (((mappingResults.object(forKey: "file") as AnyObject).object(at: indexPath.row) as AnyObject).object(forKey: "\(fileHeading)") as? String)
        case .data:
           cell.titleLabel?.text = (((mappingResults.object(forKey: "data") as AnyObject).object(at: indexPath.row) as AnyObject).object(forKey: "\(dataHeading)") as? String)
        case .task:
            break
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