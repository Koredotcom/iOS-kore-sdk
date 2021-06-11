//
//  LiveSearchView.swift
//  KoreBotSDKDemo
//
//  Created by Kartheek.Pagidimarri on 14/10/20.
//  Copyright © 2020 Kore. All rights reserved.
//

import UIKit
protocol LiveSearchViewDelegate {
    func optionsButtonTapNewAction(text:String, payload:String)
    func linkButtonTapAction(urlString:String)
    func addTextToTextView(text:String)
    //func showOrHideLiveSeachView(text:String)
    
}

class LiveSearchView: UIView {
    
    var tableView: UITableView!
    var notifyLabel: UILabel!
    fileprivate let popularSearchCellIdentifier = "PopularLiveSearchCell"
    fileprivate let liveSearchFaqCellIdentifier = "LiveSearchFaqTableViewCell"
    fileprivate let liveSearchPageCellIdentifier = "LiveSearchPageTableViewCell"
    fileprivate let liveSearchTaskCellIdentifier = "LiveSearchTaskTableViewCell"
    
    fileprivate let titleWithImageCellIdentifier = "TitleWithImageCell"
    fileprivate let titleWithCenteredContentCellIdentifier = "TitleWithCenteredContentCell"
    fileprivate let TitleWithHeaderCellIdentifier = "TitleWithHeaderCell"
    
    fileprivate let GridTableViewCellIdentifier = "GridTableViewCell"
    
    
    
    
    var headerArray = ["POPULAR SEARCHS","RECENT SEARCHS"]
    var kaBotClient = KABotClient()
    var popularSearchArray:NSMutableArray = []
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
        if #available(iOS 11.0, *) {
            self.roundCorners([ .layerMinXMinYCorner, .layerMaxXMinYCorner], radius: 20.0, borderColor: UIColor.lightGray, borderWidth: 0)
        } else {
            // Fallback on earlier versions
        }
        self.backgroundColor = UIColor.init(red: 240/255, green: 242/255, blue: 244/255, alpha: 1.0)
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
        
        let views: [String: UIView] = ["tableView": tableView, "notifyLabel":notifyLabel]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-15-[tableView]-0-|", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-100-[notifyLabel]-0-|", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[tableView]-10-|", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[notifyLabel]-10-|", options: [], metrics: nil, views: views))
        NotificationCenter.default.addObserver(self, selector: #selector(callingLiveSearchView(notification:)), name: NSNotification.Name(rawValue: "textViewDidChange"), object: nil)
        callingPopularSearchApi()
    }
    @objc func callingLiveSearchView(notification:Notification) {
        let dataString: String = notification.object as! String
        print("LiveSearchView: \(dataString)")
        
        if dataString == ""{
            callingPopularSearchApi()
        }else{
            callingLiveSearchApi(searchText: dataString)
        }
    }
    
    func callingPopularSearchApi(){
        kaBotClient.getPopularSearchResults(success: { [weak self] (arrayOfResults) in
            self?.popularSearchArray = arrayOfResults.mutableCopy() as! NSMutableArray
            self?.isPopularSearch = true
            self?.headerArray = ["POPULAR SEARCHS","RECENT SEARCHS"]
            DispatchQueue.main.async {
                self!.tableView.reloadData()
            }
            
            }, failure: { (error) in
                print(error)
                self.isPopularSearch = true
                self.headerArray = ["POPULAR SEARCHS","RECENT SEARCHS"]
                self.tableView.reloadData()
                
        })
    }
    
    func callingLiveSearchApi(searchText: String){
        kaBotClient.getLiveSearchResults(searchText ,success: { [weak self] (dictionary) in
            if let theJSONData = try?  JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted
                ),
                let theJSONText = String(data: theJSONData, encoding: String.Encoding.ascii) {
                self?.liveSearchJsonString = theJSONText
            }
            
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
                self!.headerArray.append("FAQS")
                self!.headersExpandArray.add("open")
            }
            for _ in 0..<self!.arrayOfFaqResults.count{
                self!.faqsExpandArray.add("close")
                self?.likeAndDislikeArray.add("")
            }
            
            let pages = allItems.template?.results?.page
            self?.arrayOfPageResults = pages ?? []
            if self!.arrayOfPageResults.count > 0 {
                self!.headerArray.append("WEB")
                self!.headersExpandArray.add("open")
            }
            for _ in 0..<self!.arrayOfPageResults.count{
                self!.pagesExpandArray.add("close")
            }
            
            let task = allItems.template?.results?.task
            self?.arrayOfTaskResults = task ?? []
            if self!.arrayOfTaskResults.count > 0 {
                self!.headerArray.append("TASKS")
                self!.headersExpandArray.add("open")
                isShowLoginView = true
            }else{
                isShowLoginView = false
            }
             
            let files = allItems.template?.results?.file
            self?.arrayOfFileResults = files ?? []
            if self!.arrayOfFileResults.count > 0 {
                self!.headerArray.append("Files")
                self!.headersExpandArray.add("open")
            }
            for _ in 0..<self!.arrayOfFileResults.count{
                self!.filesExpandArray.add("close")
            }
            
            let data = allItems.template?.results?.data
            self?.arrayOfDataResults = data ?? []
            if self!.arrayOfDataResults.count > 0 {
                self!.headerArray.append("DATA")
                self!.headersExpandArray.add("open")
            }
            for _ in 0..<self!.arrayOfDataResults.count{
                self!.dataExpandArray.add("close")
            }
            
            
            self?.isPopularSearch = false
            DispatchQueue.main.async {
                self!.tableView.reloadData()
                self?.notifyLabel.isHidden = true
                self?.reloadTableViewSilently()
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isPopularSearch{
            return UITableView.automaticDimension
        }else {
            let headerName:LiveSearchHeaderTypes = LiveSearchHeaderTypes(rawValue: headerArray[indexPath.section])!
            switch headerName {
            case .faq:
//                if liveSearchFAQsTemplateType == "gridTemplate" || liveSearchFAQsTemplateType == "carousel"{
//                    return UITableView.automaticDimension
//                }else{
//                    let layOutType = faqLayOutType
//                    switch layOutType {
//                    case "tileWithText":
//
//                        if  faqsExpandArray[indexPath.row] as! String == "close"{
//                            return 75
//                        }
//                        return UITableView.automaticDimension
//
//
//                    case "tileWithImage":
//                        if  faqsExpandArray[indexPath.row] as! String == "close"{
//                            return 75
//                        }
//                        return UITableView.automaticDimension
//                    case "tileWithCenteredContent":
//                        if  faqsExpandArray[indexPath.row] as! String == "close"{
//                            return 75+100
//                        }
//                        return UITableView.automaticDimension
//                    case "tileWithHeader":
//                        if  faqsExpandArray[indexPath.row] as! String == "close"{
//                            return 50
//                        }
//                        return UITableView.automaticDimension
//                    default:
//                        break
//                    }
//                }
                
                return   heightForTable(resultExpandArray: faqsExpandArray, layoutType: faqLayOutType, TemplateType: liveSearchFAQsTemplateType, index: indexPath.row)
                
            case .web:
//                if liveSearchPageTemplateType == "gridTemplate" || liveSearchPageTemplateType == "carousel"{
//                    return UITableView.automaticDimension
//                }else{
//                    let layOutType = pageLayOutType
//                    switch layOutType {
//                    case "tileWithText":
//                        if  pagesExpandArray[indexPath.row] as! String == "close"{
//                            return 75
//                        }
//                        return UITableView.automaticDimension
//
//                    case "tileWithImage":
//                        if  pagesExpandArray[indexPath.row] as! String == "close"{
//                            return 75
//                        }
//                        return UITableView.automaticDimension
//                    case "tileWithCenteredContent":
//                        if  pagesExpandArray[indexPath.row] as! String == "close"{
//                            return 75+100
//                        }
//                        return UITableView.automaticDimension
//                    case "tileWithHeader":
//                        if  pagesExpandArray[indexPath.row] as! String == "close"{
//                            return 50
//                        }
//                        return UITableView.automaticDimension
//                    default:
//                        break
//                    }
//                }
                 return   heightForTable(resultExpandArray: pagesExpandArray, layoutType: pageLayOutType, TemplateType: liveSearchPageTemplateType, index: indexPath.row)
            case .file:
//                if liveSearchFileTemplateType == "gridTemplate" || liveSearchFileTemplateType == "carousel"{
//                    return UITableView.automaticDimension
//                }else{
//                    let layOutType = fileLayOutType
//                    switch layOutType {
//                    case "tileWithText":
//                        if  filesExpandArray[indexPath.row] as! String == "close"{
//                            return 75
//                        }
//                        return UITableView.automaticDimension
//
//                    case "tileWithImage":
//                        if  filesExpandArray[indexPath.row] as! String == "close"{
//                            return 75
//                        }
//                        return UITableView.automaticDimension
//                    case "tileWithCenteredContent":
//                        if  filesExpandArray[indexPath.row] as! String == "close"{
//                            return 75+100
//                        }
//                        return UITableView.automaticDimension
//                    case "tileWithHeader":
//                        if  filesExpandArray[indexPath.row] as! String == "close"{
//                            return 50
//                        }
//                        return UITableView.automaticDimension
//                    default:
//                        break
//                    }
//                }
                 return   heightForTable(resultExpandArray: filesExpandArray, layoutType: fileLayOutType, TemplateType: liveSearchFileTemplateType, index: indexPath.row)
                
            case .data:
//                if liveSearchDataTemplateType == "gridTemplate" || liveSearchDataTemplateType == "carousel"{
//                    return UITableView.automaticDimension
//                }else{
//                    let layOutType = dataLayOutType
//                    switch layOutType {
//                    case "tileWithText":
//                        if  dataExpandArray[indexPath.row] as! String == "close"{
//                            return 75
//                        }
//                        return UITableView.automaticDimension
//
//                    case "tileWithImage":
//                        if  dataExpandArray[indexPath.row] as! String == "close"{
//                            return 75
//                        }
//                        return UITableView.automaticDimension
//                    case "tileWithCenteredContent":
//                        if  dataExpandArray[indexPath.row] as! String == "close"{
//                            return 75+100
//                        }
//                        return UITableView.automaticDimension
//                    case "tileWithHeader":
//                        if  dataExpandArray[indexPath.row] as! String == "close"{
//                            return 50
//                        }
//                        return UITableView.automaticDimension
//                    default:
//                        break
//                    }
//                }
                return   heightForTable(resultExpandArray: dataExpandArray, layoutType: dataLayOutType, TemplateType: liveSearchDataTemplateType, index: indexPath.row)
                
                case .task:
                return UITableView.automaticDimension
            }
           
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return headerArray.count > sectionAndRowsLimit ? sectionAndRowsLimit : headerArray.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isPopularSearch{
            if section == 0{
                return popularSearchArray.count
            }
            return recentSearchArray.count
        }else {
            let headerName: LiveSearchHeaderTypes = LiveSearchHeaderTypes(rawValue: headerArray[section])!
            switch headerName {
            case .faq:
                if headersExpandArray [section] as! String == "open"{
                    if liveSearchFAQsTemplateType == "gridTemplate" || liveSearchFAQsTemplateType == "carousel"{
                        return 1
                    }
                    return arrayOfFaqResults.count > sectionAndRowsLimit ? sectionAndRowsLimit : arrayOfFaqResults.count
                }
                return 0
            case .web:
                if headersExpandArray [section] as! String == "open"{
                    if liveSearchPageTemplateType == "gridTemplate" || liveSearchPageTemplateType == "carousel"{
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
                    return arrayOfFileResults.count > sectionAndRowsLimit ? sectionAndRowsLimit : arrayOfFileResults.count
                }
                return 0
            case .data:
                if headersExpandArray [section] as! String == "open"{
                    return arrayOfDataResults.count > sectionAndRowsLimit ? sectionAndRowsLimit : arrayOfDataResults.count
                }
                return 0
            }
        }
        
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if isPopularSearch{
            let cell : PopularLiveSearchCell = self.tableView.dequeueReusableCell(withIdentifier: popularSearchCellIdentifier) as! PopularLiveSearchCell
            cell.backgroundColor = UIColor.clear
            cell.selectionStyle = .none
            if headerArray[indexPath.section] == "POPULAR SEARCHS"{
                cell.titleLabel.text = ((popularSearchArray.object(at: indexPath.row) as AnyObject).object(forKey: "_id") as! String)
            }else{
                cell.titleLabel.text = ((recentSearchArray.object(at: indexPath.row) as AnyObject).object(forKey: "_id") as! String)
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
                if liveSearchFAQsTemplateType == "gridTemplate" || liveSearchFAQsTemplateType == "carousel"{
                    let cell = tableView.dequeueReusableCell(withIdentifier: GridTableViewCellIdentifier, for: indexPath) as! GridTableViewCell
                    cell.configure(with: arrayOfFaqResults, appearanceType: headerName.rawValue, layOutType: faqLayOutType)
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
                if liveSearchPageTemplateType == "gridTemplate" || liveSearchPageTemplateType == "carousel"{
                    let cell = tableView.dequeueReusableCell(withIdentifier: GridTableViewCellIdentifier, for: indexPath) as! GridTableViewCell
                    cell.configure(with: arrayOfPageResults, appearanceType: headerName.rawValue, layOutType: pageLayOutType)
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
                if liveSearchFileTemplateType == "gridTemplate" || liveSearchFileTemplateType == "carousel"{
                    let cell = tableView.dequeueReusableCell(withIdentifier: GridTableViewCellIdentifier, for: indexPath) as! GridTableViewCell
                    cell.configure(with: arrayOfFileResults, appearanceType: headerName.rawValue, layOutType: fileLayOutType)
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
                if liveSearchDataTemplateType == "gridTemplate" || liveSearchDataTemplateType == "carousel"{
                    let cell = tableView.dequeueReusableCell(withIdentifier: GridTableViewCellIdentifier, for: indexPath) as! GridTableViewCell
                    cell.configure(with: arrayOfDataResults, appearanceType: headerName.rawValue, layOutType: dataLayOutType)
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
                let cell : LiveSearchTaskTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: liveSearchTaskCellIdentifier) as! LiveSearchTaskTableViewCell
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
                }
                return cell
            }
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if isPopularSearch{
            let headerName = headerArray[indexPath.section]
            switch headerName {
            case "POPULAR SEARCHS":
                self.viewDelegate?.addTextToTextView(text: ((popularSearchArray.object(at: indexPath.row) as AnyObject).object(forKey: "_id") as! String))
            case "RECENT SEARCHS":
                self.viewDelegate?.addTextToTextView(text: ((recentSearchArray.object(at: indexPath.row) as AnyObject).object(forKey: "_id") as! String))
            default:
                break
            }
        }else{
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
                    let results = arrayOfFaqResults[indexPath.row]
                       if results.fileUrl != nil {
                           viewDelegate?.linkButtonTapAction(urlString: results.fileUrl!)
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
                    let results = arrayOfPageResults[indexPath.row]
                        if results.pageUrl != nil {
                            viewDelegate?.linkButtonTapAction(urlString: results.pageUrl!)
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
                    let results = arrayOfFileResults[indexPath.row]
                       if results.fileUrl != nil {
                           viewDelegate?.linkButtonTapAction(urlString: results.fileUrl!)
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
                    let results = arrayOfDataResults[indexPath.row]
                       if results.dataUrl != nil {
                           viewDelegate?.linkButtonTapAction(urlString: results.dataUrl!)
                    }
                }
            case .task:
                break
            }
        }
        
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.init(red: 240/255, green: 242/255, blue: 244/255, alpha: 1.0)
        let headerLabel = UILabel(frame: .zero)
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.textAlignment = .left
        headerLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 15.0)
        headerLabel.font = headerLabel.font.withSize(15.0)
        
        headerLabel.textColor = .gray
        headerLabel.text =  headerArray[section]
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
        
        if isPopularSearch {
            showMoreButton.isHidden = true
            dropDownBtn.isHidden = true
            headerLabel.isHidden = false
        }else{
            let boolValue = section == 0 ? false : true
            showMoreButton.isHidden = boolValue
            dropDownBtn.isHidden = false
            headerLabel.isHidden = true
            if headersExpandArray[section] as! String == "open"{
                dropDownBtn.setImage(UIImage.init(named: "downarrow"), for: .normal)
            }else{dropDownBtn.setImage(UIImage.init(named: "rightarrow"), for: .normal)}
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
        return 30
    }
}

extension LiveSearchView{
    @objc fileprivate func closeButtonAction(_ sender: AnyObject!) {
        recentSearchArray.removeObject(at: sender.tag)
        tableView.reloadData()
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
        NotificationCenter.default.post(name: Notification.Name(showLiveSearchTemplateNotification), object: liveSearchJsonString)
    }
    
    @objc fileprivate func headerDropDownButtonAction(_ sender: AnyObject!) {
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
        if TemplateType == "gridTemplate" || TemplateType == "carousel"{
            return UITableView.automaticDimension
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
                    return 75
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
        let results = cellResultArray[indexPath.row]
        let headerName:LiveSearchHeaderTypes = LiveSearchHeaderTypes(rawValue: appearanceType)!
        switch headerName {
        case .faq:
            cell.titleLabel?.text = results.faqQuestion
            cell.descriptionLabel?.text = results.faqAnswer
        case .web:
            cell.titleLabel?.text = results.pageTitle
            cell.descriptionLabel?.text = results.pagePreview
        case .file:
            cell.titleLabel?.text = results.fileTitle
            cell.descriptionLabel?.text = results.filePreview
        case .data:
            cell.titleLabel?.text = results.category
            cell.descriptionLabel?.text = results.product
        case .task:
            break
        }
//        if appearanceType == "FAQS" {
//            cell.titleLabel?.text = results.faqQuestion
//            cell.descriptionLabel?.text = results.faqAnswer
//        }else if appearanceType == "PAGES"{
//            cell.titleLabel?.text = results.pageTitle
//            cell.descriptionLabel?.text = results.pagePreview
//        }else if appearanceType == "Files"{
//            cell.titleLabel?.text = results.fileTitle
//            cell.descriptionLabel?.text = results.filePreview
//        }else if appearanceType == "DATA" {
//            cell.titleLabel?.text = results.category
//            cell.descriptionLabel?.text = results.product
//        }
        
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
        let results = cellResultArray[indexPath.row]
        var gridImage: String?
        let headerName:LiveSearchHeaderTypes = LiveSearchHeaderTypes(rawValue: appearanceType)!
        switch headerName {
        case .faq:
           cell.titleLabel?.text = results.faqQuestion
            cell.descriptionLabel?.text = results.faqAnswer
             gridImage = results.imageUrl
        case .web:
            cell.titleLabel?.text = results.pageTitle
            cell.descriptionLabel?.text = results.pagePreview
            gridImage = results.pageImageUrl
        case .file:
            cell.titleLabel?.text = results.fileTitle
            cell.descriptionLabel?.text = results.filePreview
            gridImage = results.fileimageUrl
        case .data:
            cell.titleLabel?.text = results.category
            cell.descriptionLabel?.text = results.product
            gridImage = results.dataImageUrl
        case .task:
            break
        }
        
//        if appearanceType == "FAQS" {
//            cell.titleLabel?.text = results.faqQuestion
//            cell.descriptionLabel?.text = results.faqAnswer
//             gridImage = results.imageUrl
//        }else if appearanceType == "PAGES"{
//            cell.titleLabel?.text = results.pageTitle
//            cell.descriptionLabel?.text = results.pagePreview
//            gridImage = results.pageImageUrl
//        }else if appearanceType == "Files"{
//            cell.titleLabel?.text = results.fileTitle
//            cell.descriptionLabel?.text = results.filePreview
//            gridImage = results.fileimageUrl
//        }else if appearanceType == "DATA" {
//            cell.titleLabel?.text = results.category
//            cell.descriptionLabel?.text = results.product
//            gridImage = results.dataImageUrl
//        }
        
        let buttonsHeight = expandArray[indexPath.row] as! String == "close" ? 0.0: 0.0 //30.0
        cell.likeAndDislikeButtonHeightConstrain.constant = CGFloat(buttonsHeight)
        
        if gridImage == nil || gridImage == ""{
            cell.topImageV.image = UIImage(named: "placeholder_image")
            //cell.bottomImageV.image = UIImage(named: "placeholder_image")
        }else{
            let url = URL(string: gridImage!)
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
                    let url = URL(string: gridImage!)
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
        let results = cellResultArray[indexPath.row]
        var gridImage: String?
        let headerName:LiveSearchHeaderTypes = LiveSearchHeaderTypes(rawValue: appearanceType)!
        switch headerName {
        case .faq:
           cell.titleLabel?.text = results.faqQuestion
           cell.descriptionLabel?.text = results.faqAnswer
           gridImage = results.imageUrl
        case .web:
            cell.titleLabel?.text = results.pageTitle
            cell.descriptionLabel?.text = results.pagePreview
            gridImage = results.pageImageUrl
        case .file:
            cell.titleLabel?.text = results.fileTitle
            cell.descriptionLabel?.text = results.filePreview
            gridImage = results.fileimageUrl
        case .data:
           cell.titleLabel?.text = results.category
           cell.descriptionLabel?.text = results.product
           gridImage = results.dataImageUrl
        case .task:
            break
        }
        
//        if appearanceType == "FAQS" {
//            cell.titleLabel?.text = results.faqQuestion
//            cell.descriptionLabel?.text = results.faqAnswer
//            gridImage = results.imageUrl
//        }else if appearanceType == "PAGES" {
//            cell.titleLabel?.text = results.pageTitle
//            cell.descriptionLabel?.text = results.pagePreview
//            gridImage = results.pageImageUrl
//        }else if appearanceType == "Files"{
//            cell.titleLabel?.text = results.fileTitle
//            cell.descriptionLabel?.text = results.filePreview
//            gridImage = results.fileimageUrl
//        }else if appearanceType == "DATA" {
//            cell.titleLabel?.text = results.category
//            cell.descriptionLabel?.text = results.product
//            gridImage = results.dataImageUrl
//        }
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
                    let url = URL(string: gridImage!)
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
                let url = URL(string: gridImage!)
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
        
        let results = cellResultArray[indexPath.row]
        let headerName:LiveSearchHeaderTypes = LiveSearchHeaderTypes(rawValue: appearanceType)!
        switch headerName {
        case .faq:
           cell.titleLabel?.text = results.faqQuestion
        case .web:
            cell.titleLabel?.text = results.pageTitle
        case .file:
           cell.titleLabel?.text = results.fileTitle
        case .data:
           cell.titleLabel?.text = results.category
        case .task:
            break
        }
        
//        if appearanceType == "FAQS" {
//            cell.titleLabel?.text = results.faqQuestion
//        }else if appearanceType == "PAGES" {
//            cell.titleLabel?.text = results.pageTitle
//        }else if appearanceType == "Files" {
//            cell.titleLabel?.text = results.fileTitle
//        }else if appearanceType == "DATA" {
//            cell.titleLabel?.text = results.category
//        }
        
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
