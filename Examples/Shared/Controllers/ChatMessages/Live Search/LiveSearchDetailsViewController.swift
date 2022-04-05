//
//  LiveSearchDetailsViewController.swift
//  KoreBotSDKDemo
//
//  Created by Kartheek.Pagidimarri on 15/10/20.
//  Copyright © 2020 Kore. All rights reserved.
//

import UIKit
import SafariServices
protocol LiveSearchDetailsViewDelegate {
    func optionsButtonTapNewAction(text:String, payload:String)
    func optionsButtonTapAction(text:String)
    func linkButtonTapAction(urlString:String)
    func optionsButtonTapTaskAction(text:String, payload:String, taskData: [String:Any]?)
}

class LiveSearchDetailsViewController: UIViewController, UIGestureRecognizerDelegate {
    var rowsDataLimit = 1000
    var numberofRowsLimit = 10
    var pageNumber = 0
    
    @IBOutlet weak var subView: UIView!
    @IBOutlet weak var headingLebel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var filterView: UIView!
    @IBOutlet weak var filterTableView: UITableView!
    @IBOutlet weak var filterSubview: UIView!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var cleartButton: UIButton!
    @IBOutlet weak var clearBtnWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var topFilterButton: UIButton!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var flotingButtonView: UIView!
    @IBOutlet weak var badgeView: UIView!
    @IBOutlet weak var badgeLabel: UILabel!
    
    @IBOutlet weak var topBadgeView: UIView!
    @IBOutlet weak var topBadgeLabel: UILabel!
    
    
    @IBOutlet weak var currentPageNoLbl: UILabel!
    @IBOutlet weak var totalPageNoLbl: UILabel!
    @IBOutlet weak var pagenationView: UIView!
    @IBOutlet weak var pageNationVHeightConstraint: NSLayoutConstraint!
    
    var maximumPageNumber = 0
    
    @IBOutlet weak var errorImagV: UIImageView!
    var tabFacetsDic = TabFacetModel()
    var isMultiSelect = false
    
    fileprivate let liveSearchFaqCellIdentifier = "LiveSearchFaqTableViewCell"
    fileprivate let liveSearchPageCellIdentifier = "LiveSearchPageTableViewCell"
    fileprivate let liveSearchTaskCellIdentifier = "LiveSearchTaskTableViewCell"
    fileprivate let liveSearchNewTaskCellIdentifier = "LiveSearchNewTaskViewCell"
    fileprivate let LiveSearchCollectionViewCellIdentifier = "LiveSearchCollectionViewCell"
    fileprivate let SearchDetailsCollectionViewCellIdentifier = "SearchDetailsCollectionViewCell"
    fileprivate let FilterTableCellIdentifier = "FilterTableCell"
    
    fileprivate let titleWithImageCellIdentifier = "TitleWithImageCell"
    fileprivate let titleWithCenteredContentCellIdentifier = "TitleWithCenteredContentCell"
    fileprivate let TitleWithHeaderCellIdentifier = "TitleWithHeaderCell"
    
    fileprivate let GridTableViewCellIdentifier = "GridTableViewCell"
    fileprivate let CarouselTableViewCellIdentifier = "CarouselTableViewCell"
    
    var headerArray = [String]()
    var arrayOfCollectionView = [String]()
    var arrayOfCollectionViewImagesSelected = ["all results","faq", "pages","actions", "docs","files"]
    var arrayOfCollectionViewImages = ["all results-S","faq-S", "pages-S","actions-S", "docs-S","files-S"]
    var collectionViewSelectedIndex = 0
    var arrayOfResults = [TemplateResultElements]()
    
    var arrayOfFaqResults = [TemplateResultElements]()
    var arrayOfPageResults = [TemplateResultElements]()
    var arrayOfTaskResults = [TemplateResultElements]()
    var arrayOfFileResults = [TemplateResultElements]()
    var arrayOfDataResults = [TemplateResultElements]()
    
     
    
    var arrayOfSearchFacets = [TemplateSearchFacets]()
    //var arrayOfmultiSelectOrSingleSelect = NSMutableArray()
    var checkboxIndexPath = [IndexPath]() //for Rows checkbox
    var arrayOfSeletedValues : [[String: String]] = []
    
    
    var faqsExpandArray:NSMutableArray = []
    var pagesExpandArray:NSMutableArray = []
    var actionExpandArray:NSMutableArray = []
    var filesExpandArray:NSMutableArray = []
    var dataExpandArray:NSMutableArray = []
    
    
    var likeAndDislikeArray:NSMutableArray = []
    var arrayOfCollectionViewCount:NSMutableArray = []
    var factsArray:NSMutableArray = []
    var resultGrpORtabConfigDic:[String: Any] = [:]
    var sysContentType = "All"
    var isFilterApply = false
    
    
    var dataString: String!
    var jsonData : Componentss?
    var viewDelegate: LiveSearchDetailsViewDelegate?
    var kaBotClient = KABotClient()
    var tapToDismissGestureRecognizer: UITapGestureRecognizer!
    
    let yourAttributes : [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.font : UIFont(name: "HelveticaNeue-Bold", size: 15.0) as Any,
        NSAttributedString.Key.foregroundColor : themeColor]
    
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
    
    var isShowFileterView = false
    
    var hashMapDic = NSMutableDictionary()
    var hashMapDic1 = [String:Any]()
    var isSearchType = "fullSearch"
    
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
    

    var header_Array = NSMutableArray()
    var sysContentTypeArray = NSMutableArray()
//    var header_allResults = "All Results"
//    var header_faq = "FAQs"
//    var header_web = "Web Results"
//    var header_task = "Actions"
//    var header_file = "Files"
//    var header_data = "Structured Data"
    
    
    enum LiveSearchSysContentTypes: String{
        case allResults = "All"
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
    
    // MARK: init
    init(dataString: String, tabFacetsDic: TabFacetModel) {
        super.init(nibName: "LiveSearchDetailsViewController", bundle: nil)
        self.dataString = dataString
        self.tabFacetsDic = tabFacetsDic
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        headerNArray = []
        for i in 0..<(resultViewSettingItems?.settings?.count ?? 0){
            let settings = resultViewSettingItems?.settings?[i]
            if settings?.interface == "fullSearch"{
                isShowFileterView = settings?.facetsSetting?.enabled ?? false
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
                    
                    /*
                     if condtion?.fieldValue == "file"{
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
        
        if !isShowFileterView {
            topBadgeView.isHidden = true
            topFilterButton.isHidden = true
            flotingButtonView.isHidden = true
            badgeView.isHidden = true
        }
        
        pageNationVHeightConstraint.constant = 0
        currentPageNoLbl.layer.cornerRadius = 5
        currentPageNoLbl.layer.borderWidth = 1.0
        currentPageNoLbl.layer.borderColor = UIColor.lightGray.cgColor
        errorImagV.isHidden = true
        
        
        
        flotingButtonView.layer.cornerRadius = 22.5
        flotingButtonView.clipsToBounds = true
        
        badgeView.isHidden = true
        badgeView.layer.cornerRadius = 10
        badgeView.clipsToBounds = true
        badgeLabel.text = "0"
        
        topBadgeView.isHidden = true
        topBadgeView.layer.cornerRadius = 10
        topBadgeView.clipsToBounds = true
        topBadgeLabel.text = "0"
        
        collectionView.delegate = nil
        collectionView.dataSource = nil
        
        submitButton.isHidden = true
        cleartButton.isHidden = true
        
        filterView.isHidden = true
        filterSubview.layer.borderWidth = 1.0
        filterSubview.layer.borderColor = UIColor.clear.cgColor
        if #available(iOS 11.0, *) {
            filterSubview.roundCorners([ .layerMinXMinYCorner, .layerMaxXMinYCorner], radius: 20.0, borderColor: UIColor.lightGray, borderWidth: 0)
        } else {
            // Fallback on earlier versions
        }
        filterSubview.layer.shadowOpacity = 0.7
        filterSubview.layer.shadowOffset = CGSize(width: 3, height: 1)
        filterSubview.layer.shadowRadius = 5.0
        filterSubview.clipsToBounds = false
        filterSubview.layer.shadowColor = UIColor.darkGray.cgColor
        
        self.subView.backgroundColor = UIColor.init(red: 240/255, green: 242/255, blue: 244/255, alpha: 1.0)
        subView.layer.masksToBounds = false
        //subView?.layer.shadowColor = UIColor.lightGray.cgColor
        subView?.layer.shadowOffset =  CGSize.zero
        //subView?.layer.shadowOpacity = 0.5
        subView?.layer.shadowRadius = 10
        
        // Do any additional setup after loading the view.
        tableView.register(UINib(nibName: liveSearchFaqCellIdentifier, bundle: nil), forCellReuseIdentifier: liveSearchFaqCellIdentifier)
        tableView.register(UINib(nibName: liveSearchPageCellIdentifier, bundle: nil), forCellReuseIdentifier: liveSearchPageCellIdentifier)
        tableView.register(UINib(nibName: liveSearchTaskCellIdentifier, bundle: nil), forCellReuseIdentifier: liveSearchTaskCellIdentifier)
        tableView.register(UINib(nibName: liveSearchNewTaskCellIdentifier, bundle: nil), forCellReuseIdentifier: liveSearchNewTaskCellIdentifier)
        
        filterTableView.register(UINib(nibName: FilterTableCellIdentifier, bundle: nil), forCellReuseIdentifier: FilterTableCellIdentifier)
        
        collectionView.backgroundColor = UIColor.init(hexString: "#eaeaea")
        //collectionView.register(UINib(nibName: LiveSearchCollectionViewCellIdentifier, bundle: nil), forCellWithReuseIdentifier: LiveSearchCollectionViewCellIdentifier)
        collectionView.register(UINib(nibName: SearchDetailsCollectionViewCellIdentifier, bundle: nil), forCellWithReuseIdentifier: SearchDetailsCollectionViewCellIdentifier)
        
        self.tableView.register(UINib(nibName: titleWithImageCellIdentifier, bundle: nil), forCellReuseIdentifier: titleWithImageCellIdentifier)
        self.tableView.register(UINib(nibName: titleWithCenteredContentCellIdentifier, bundle: nil), forCellReuseIdentifier: titleWithCenteredContentCellIdentifier)
        self.tableView.register(UINib(nibName: TitleWithHeaderCellIdentifier, bundle: nil), forCellReuseIdentifier: TitleWithHeaderCellIdentifier)
        
        self.tableView.register(UINib(nibName: GridTableViewCellIdentifier, bundle: nil), forCellReuseIdentifier: GridTableViewCellIdentifier)
        self.tableView.register(UINib(nibName: CarouselTableViewCellIdentifier, bundle: nil), forCellReuseIdentifier: CarouselTableViewCellIdentifier)
        
        
        self.tapToDismissGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(LiveSearchDetailsViewController.hidFilterView(_:)))
        self.tapToDismissGestureRecognizer.delegate = self
        self.filterView.addGestureRecognizer(tapToDismissGestureRecognizer)
        
        //getData()
        
        let seletedType = self.dataString.components(separatedBy:",,")
        self.dataString = seletedType[0]
        
        let jsonObject: NSDictionary = Utilities.jsonObjectFromString(jsonString: dataString!) as! NSDictionary
        self.receviceMessage(dictionary: jsonObject as! [String : Any], isReload: false)
        
        let dataStrSelectType: LiveSearchSysContentTypes = LiveSearchSysContentTypes(rawValue: seletedType[1])!
        switch dataStrSelectType {
        case .allResults:
            sysContentType = LiveSearchSysContentTypes.allResults.rawValue
            collectionView(collectionView, didSelectItemAt: IndexPath(row: 0, section: 0))
        case .faq:
            sysContentType = LiveSearchSysContentTypes.faq.rawValue
             collectionView(collectionView, didSelectItemAt: IndexPath(row: 1, section: 0))
        case .web:
            sysContentType = LiveSearchSysContentTypes.web.rawValue
             collectionView(collectionView, didSelectItemAt: IndexPath(row: 2, section: 0))
        case .task:
            sysContentType = LiveSearchSysContentTypes.task.rawValue
            collectionView(collectionView, didSelectItemAt: IndexPath(row: 3, section: 0))
        case .data:
            sysContentType = LiveSearchSysContentTypes.data.rawValue
            collectionView(collectionView, didSelectItemAt: IndexPath(row: 4, section: 0))
        case .file:
            sysContentType = LiveSearchSysContentTypes.file.rawValue
            collectionView(collectionView, didSelectItemAt: IndexPath(row: 5, section: 0))
        }
        
       // callingSearchApi(filterArray: [])
    }
    override func viewDidAppear(_ animated: Bool) {
        hideFilterView()
    }
    @objc func hidFilterView(_ gesture: UITapGestureRecognizer) {
        hideFilterView()
    }
    func hideFilterView(){
        //        filterView.isHidden = true
        //        self.filterView.frame = CGRect(x: 0, y: UIScreen.main.bounds.origin.y+self.filterView.bounds.size.height, width: self.filterView.bounds.size.width, height: self.filterView.bounds.size.height)
        self.movingDown()
    }
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view?.isDescendant(of: self.filterTableView) == true {
            return false
        }
        return true
    }
    
    func callingSearchApi(filterArray: NSMutableArray){
        if filterArray.count == 0{
            clearBtnWidthConstraint.constant = 65
            isFilterApply = false
            submitButton.isHidden = true
            cleartButton.isHidden = true
        }else{
            isFilterApply = true
        }
        hideFilterView()
        
        indicatorView.startAnimating()
        indicatorView.isHidden = false
        let jsonObject: NSDictionary = Utilities.jsonObjectFromString(jsonString: dataString!) as! NSDictionary
        let template = jsonObject["template"] as! Dictionary<String, Any>
        let query = template["originalQuery"] as! String
        //let query = "Pay now"
        self.kaBotClient.getSearchResults(query, resultGrpORtabConfigDic ,filterArray, pageNumber ,success: { [weak self] (dictionary) in
            //print(dictionary)
            self?.receviceMessage(dictionary: dictionary, isReload: true)
            }, failure: { (error) in
                print(error)
                self.indicatorView.stopAnimating()
                self.indicatorView.isHidden = true
        })
    }
    func receviceMessage(dictionary:[String: Any], isReload: Bool){
        var resposeDic = dictionary
        if pageNumber == 0{
        }else{
            let dic = NSMutableDictionary(dictionary: resposeDic)
            let mappingResults = ((dic.object(forKey: "template") as AnyObject).object(forKey: "results") as AnyObject)
            let data = (mappingResults.object(forKey: "data") as! NSArray)
            print(data)
        
            
            if sysContentType == "data"{
                sysContentType = "default_group"
            }
            
            if let template = dictionary["template"] as? [String: Any], let results = template["results"] as? [String: Any], let data = results["data"] as? NSArray{
                let hashMapDicData = hashMapDic.mutableCopy() as? NSMutableDictionary
                
                let resultType =  ((self.hashMapDic.object(forKey: "template") as AnyObject).object(forKey: "resultType") as? String)
                self.resultTypeString = resultType
                var dataArray = NSMutableArray()
                if self.resultTypeString  == self.resultTypeFlatString{
                    dataArray = (((((hashMapDicData?.object(forKey: "template") as AnyObject).object(forKey: "results") as AnyObject).object(forKey: "data") as? NSArray)?.mutableCopy() as? NSMutableArray) ?? [])
                    dataArray.addObjects(from: data as [AnyObject])
                    let finalDic = NSMutableDictionary()
                    let resultDic = NSMutableDictionary()
                    //let templaTypeDic = NSMutableDictionary()
                    let dataDic = NSMutableDictionary()
                    dataDic.setObject(dataArray as Any, forKey: "data" as NSCopying)
                    //templaTypeDic.setObject(dataDic, forKey: sysContentType as NSCopying)
                    resultDic.setObject(dataDic, forKey: "results" as NSCopying)
                    resultDic.setObject("flat", forKey: "resultType" as NSCopying)
                    finalDic.setObject(resultDic, forKey: "template" as NSCopying)
                    resposeDic = finalDic as? [String : Any] ?? [:]
                }else{
                    dataArray = ((((((hashMapDicData?.object(forKey: "template") as AnyObject).object(forKey: "results") as AnyObject).object(forKey: sysContentType) as AnyObject).object(forKey: "data") as? NSArray)?.mutableCopy() as? NSMutableArray) ?? [])
                    dataArray.addObjects(from: data as [AnyObject])
                    let finalDic = NSMutableDictionary()
                    let resultDic = NSMutableDictionary()
                    let templaTypeDic = NSMutableDictionary()
                    let dataDic = NSMutableDictionary()
                    dataDic.setObject(dataArray as Any, forKey: "data" as NSCopying)
                    templaTypeDic.setObject(dataDic, forKey: sysContentType as NSCopying)
                    resultDic.setObject(templaTypeDic, forKey: "results" as NSCopying)
                    finalDic.setObject(resultDic, forKey: "template" as NSCopying)
                    resposeDic = finalDic as? [String : Any] ?? [:]
                }
                
            }
        }
        
        let jsonDecoder = JSONDecoder()
        guard let jsonData = try? JSONSerialization.data(withJSONObject: resposeDic as Any , options: .prettyPrinted),
            let allItems = try? jsonDecoder.decode(LiveSearchChatItems.self, from: jsonData) else {
                return
        }
        if arrayOfSearchFacets.count == 0{
           // arrayOfmultiSelectOrSingleSelect = []
            arrayOfSearchFacets = allItems.template?.facets ?? []
//            for i in 0..<arrayOfSearchFacets.count {
//                //arrayOfmultiSelectOrSingleSelect
//                let array = NSMutableArray()
//                if let buckets = arrayOfSearchFacets[i].buckets{
//                    for _ in  0..<buckets.count{
//                        array.add("uncheck")
//                    }
//                }
//                arrayOfmultiSelectOrSingleSelect.add(array)
//            }
            
        }
        hideFilterView()
        
   // if pageNumber == 0{
        self.headerArray = []
        self.faqsExpandArray = []
        pagesExpandArray = []
        actionExpandArray = []
        filesExpandArray = []
        dataExpandArray = []
        
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
        
        if isReload{
            
            //self.hashMapDic1 = resposeDic
            self.hashMapDic = NSMutableDictionary(dictionary: resposeDic)
            self.likeAndDislikeArray = []
            
            let resultType =  ((self.hashMapDic.object(forKey: "template") as AnyObject).object(forKey: "resultType") as? String)
            self.resultTypeString = resultType
            if self.resultTypeString  == self.resultTypeFlatString{
                
                
                let mappingResults = ((self.hashMapDic.object(forKey: "template") as AnyObject).object(forKey: "results") as AnyObject)
                
                if let resultDic = mappingResults as? [String: Any]{
                    guard let jsonData = try? JSONSerialization.data(withJSONObject: resultDic["data"] as Any , options: .prettyPrinted),
                          let allItems = try? jsonDecoder.decode([TemplateResultElements].self, from: jsonData) else {
                        return
                    }
                    print(allItems)
                    self.arrayOfSearchResults.add(allItems)
                    
                    self.headerArray.append("")
                    
                    
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
            let faqs = allItems.template?.results?.faq?.data
            self.arrayOfFaqResults = faqs ?? []
            if self.arrayOfFaqResults.count > 0 {
                self.headerArray.append(LiveSearchHeaderTypes.faq.rawValue)
            }
            for _ in 0..<self.arrayOfFaqResults.count{
                self.faqsExpandArray.add("close")
                self.likeAndDislikeArray.add("")
            }
            
            let pages = allItems.template?.results?.page?.data
            self.arrayOfPageResults = pages ?? []
            if self.arrayOfPageResults.count > 0 {
                self.headerArray.append(LiveSearchHeaderTypes.web.rawValue)
            }
            for _ in 0..<self.arrayOfPageResults.count{
                self.pagesExpandArray.add("close")
            }
            
            let task = allItems.template?.results?.task?.data
            self.arrayOfTaskResults = task ?? []
            if self.arrayOfTaskResults.count > 0 {
                self.headerArray.append(LiveSearchHeaderTypes.task.rawValue)
            }
            for _ in 0..<self.arrayOfTaskResults.count{
                self.actionExpandArray.add("close")
            }
            
            let data = allItems.template?.results?.data?.data
            self.arrayOfDataResults = data ?? []
            if self.arrayOfDataResults.count > 0 {
                self.headerArray.append(LiveSearchHeaderTypes.data.rawValue)
                
            }
            for _ in 0..<self.arrayOfDataResults.count{
                self.dataExpandArray.add("close")
            }
            
            
            let files = allItems.template?.results?.file?.data
            self.arrayOfFileResults = files ?? []
            if self.arrayOfFileResults.count > 0 {
                self.headerArray.append(LiveSearchHeaderTypes.file.rawValue)
                
            }
            for _ in 0..<self.arrayOfFileResults.count{
                self.filesExpandArray.add("close")
            }*/
            
            
            
            errorImagV.isHidden = headerArray.count > 0 ? true : false
        }
      
        if pageNumber == 0{
        
        //arrayOfCollectionViewCount = []
//        arrayOfCollectionViewCount.add(allItems.template?.facets?.all_results as Any)
//        arrayOfCollectionViewCount.add(allItems.template?.facets?.faq as Any)
//        arrayOfCollectionViewCount.add(allItems.template?.facets?.web as Any)
//        arrayOfCollectionViewCount.add(allItems.template?.facets?.task as Any)
//        arrayOfCollectionViewCount.add(allItems.template?.facets?.data as Any)
//        arrayOfCollectionViewCount.add(allItems.template?.facets?.file as Any)
        
        //if arrayOfCollectionViewCount.count == 0{
            arrayOfCollectionViewCount = []
            arrayOfCollectionView = []
            arrayOfCollectionViewImagesSelected = []
            arrayOfCollectionViewImages = []
            
            var allResultCount = 0
            if let searchTemplateTabFacet = allItems.template?.tabFacet{
                if let bucket = searchTemplateTabFacet.buckets{
                    for i in 0..<bucket.count{
                        let result = bucket[i]
                        allResultCount += result.doc_count ?? 0
                    }
                }
            }
            header_Array = []
            sysContentTypeArray = []
            
            header_Array.add("All")
            sysContentTypeArray.add("All")
            
            //header_allResults = "All"
            arrayOfCollectionView.append("All")
            arrayOfCollectionViewCount.add(allResultCount)
            arrayOfCollectionViewImagesSelected.append("all results")
            arrayOfCollectionViewImages.append("all results-S")
           
        //because Tabs Order as per web
        if let tabFcet = self.tabFacetsDic.tabs, tabFcet.count > 0{
            isMultiSelect = self.tabFacetsDic.multiselect ?? false
            for i in 0..<tabFcet.count{
                let tabs = tabFcet[i]
                let fieldValue = tabs.fieldValue
                
                if let searchTemplateTabFacet = allItems.template?.tabFacet{
                    if let bucket = searchTemplateTabFacet.buckets{
                        for j in 0..<bucket.count{
                            let templateTabs = bucket[j]
                            let templateTabsfieldValue = templateTabs.key
                            
                            if fieldValue == templateTabsfieldValue{
                             header_Array.add(templateTabs.name ?? "")
                             sysContentTypeArray.add(templateTabs.key ?? "")
                             arrayOfCollectionView.append(templateTabs.name ?? "")
                             arrayOfCollectionViewCount.add(templateTabs.doc_count as Any)
                             arrayOfCollectionViewImagesSelected.append("faq")
                             arrayOfCollectionViewImages.append("faq-S")
                            }
                            /*
                            if fieldValue == templateTabsfieldValue{
                                switch fieldValue {
                                case LiveSearchSysContentTypes.faq.rawValue:
                                    header_faq = templateTabs.name ?? ""
                                    arrayOfCollectionView.append(templateTabs.name ?? "")
                                    arrayOfCollectionViewCount.add(templateTabs.doc_count as Any)
                                    arrayOfCollectionViewImagesSelected.append("faq")
                                    arrayOfCollectionViewImages.append("faq-S")
                                    break
                                case LiveSearchSysContentTypes.web.rawValue:
                                    header_web = templateTabs.name ?? ""
                                    arrayOfCollectionView.append(templateTabs.name ?? "")
                                    arrayOfCollectionViewCount.add(templateTabs.doc_count as Any)
                                    arrayOfCollectionViewImagesSelected.append("pages")
                                    arrayOfCollectionViewImages.append("pages-S")
                                    break
                                case LiveSearchSysContentTypes.task.rawValue:
                                    header_task = templateTabs.name ?? ""
                                    arrayOfCollectionView.append(templateTabs.name ?? "")
                                    arrayOfCollectionViewCount.add(templateTabs.doc_count as Any)
                                    arrayOfCollectionViewImagesSelected.append("actions")
                                    arrayOfCollectionViewImages.append("actions-S")
                                    break
                                case LiveSearchSysContentTypes.data.rawValue:
                                    header_data = templateTabs.name ?? ""
                                    arrayOfCollectionView.append(templateTabs.name ?? "")
                                    arrayOfCollectionViewCount.add(templateTabs.doc_count as Any)
                                    arrayOfCollectionViewImagesSelected.append("docs")
                                    arrayOfCollectionViewImages.append("docs-S")
                                    break
                                case LiveSearchSysContentTypes.file.rawValue:
                                    header_file = templateTabs.name ?? ""
                                    arrayOfCollectionView.append(templateTabs.name ?? "")
                                    arrayOfCollectionViewCount.add(templateTabs.doc_count as Any)
                                    arrayOfCollectionViewImagesSelected.append("files")
                                    arrayOfCollectionViewImages.append("files-S")
                                    break
                                default:
                                    break
                                }
                            }*/
                            
                        }
                    }
                }
            }
        }
    }
        //}
        
//        }else{
//
//            let dic = NSMutableDictionary(dictionary: dictionary)
//            let mappingResults = ((dic.object(forKey: "template") as AnyObject).object(forKey: "results") as AnyObject)
//            let data = (mappingResults.object(forKey: "data") as! NSArray)
//            print(data)
//
//
//            if let template = dictionary["template"] as? [String: Any], let results = template["results"] as? [String: Any], let data = results["data"] as? NSArray{
//                let hashMapDicData = hashMapDic.mutableCopy() as? NSMutableDictionary
//                let dataArray = (((((hashMapDicData?.object(forKey: "template") as AnyObject).object(forKey: "results") as AnyObject).object(forKey: sysContentType) as AnyObject).object(forKey: "data") as? NSArray)?.mutableCopy() as? NSMutableArray)
//                dataArray?.addObjects(from: data as [AnyObject])
//
//
//                let finalDic = NSMutableDictionary()
//                let resultDic = NSMutableDictionary()
//                let templaTypeDic = NSMutableDictionary()
//                let dataDic = NSMutableDictionary()
//                dataDic.setObject(dataArray as Any, forKey: "data" as NSCopying)
//                templaTypeDic.setObject(dataDic, forKey: sysContentType as NSCopying)
//                resultDic.setObject(templaTypeDic, forKey: "results" as NSCopying)
//                finalDic.setObject(resultDic, forKey: "template" as NSCopying)
//                hashMapDic = finalDic
//            }
//        }
        
        
        if isReload{
            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.reloadData()
            tableView.reloadData()
            filterTableView.reloadData()
            indicatorView.stopAnimating()
            indicatorView.isHidden = true
            reloadTableViewSilently()
        }
        
    }

    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    @IBAction func tapsOnCloseBtnAct(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tapsOnFilterBtnAct(_ sender: UIButton) {
        if filterView.isHidden{
            //filterView.isHidden = false
            self.movingUp()
        }else{
            hideFilterView()
        }
    }
    
    @IBAction func tapsOnClearAllBtnAct(_ sender: Any) {
        //        var set = Set<String>()
        //        let arrayFieldName: [[String: Any]] = arrayOfSeletedValues.compactMap {
        //            guard let name = $0["fieldName"] else { return nil }
        //            return set.insert(name).inserted ? $0 : nil
        //        }
        //
        //
        //        let factsArray = NSMutableArray()
        //        for i in 0..<arrayFieldName.count{
        //            let index = arrayFieldName[i]
        //            let facetValue = NSMutableArray()
        //            for j in 0..<arrayOfSeletedValues.count{
        //                let selectedindex = arrayOfSeletedValues[j]
        //                if index["fieldName"] as! String == selectedindex["fieldName"]!{
        //                   facetValue.add(selectedindex["value"]!)
        //                }
        //            }
        //            let facts: [String: Any] = ["facetType": "value", "fieldName": index["fieldName"] as! String ,"facetValue": facetValue]
        //            factsArray.add(facts)
        //        }
        //        print(factsArray)
        //        //filterView.isHidden = true
        
        clearBtnWidthConstraint.constant = 65
        isFilterApply = false
        submitButton.isHidden = true
        cleartButton.isHidden = true
        self.pageNumber = 0
        callingSearchApi(filterArray: [])
        arrayOfSeletedValues = []
        badgeLabel.text = "\(arrayOfSeletedValues.count)"
        topBadgeLabel.text = "\(arrayOfSeletedValues.count)"
        checkboxIndexPath = []
        filterTableView.reloadData()
    }
    
    @IBAction func tapsOnSubmitBnAct(_ sender: Any) {
        self.pageNumber = 0
        callingSearchApi(filterArray: factsArray)
    }
    
    @IBAction func tapsOnLeftArrowBtnact(_ sender: Any) {
        let collectionBounds = self.collectionView.bounds
        let contentOffset = CGFloat(floor(self.collectionView.contentOffset.x - collectionBounds.size.width))
        self.moveCollectionToFrame(contentOffset: contentOffset)
    }
    
    @IBAction func tapsOnRightArrowBtnact(_ sender: Any) {
        let collectionBounds = self.collectionView.bounds
        let contentOffset = CGFloat(floor(self.collectionView.contentOffset.x + collectionBounds.size.width))
        self.moveCollectionToFrame(contentOffset: contentOffset)
    }
    func moveCollectionToFrame(contentOffset : CGFloat) {
        let frame: CGRect = CGRect(x : contentOffset ,y : self.collectionView.contentOffset.y ,width : self.collectionView.frame.width,height : self.collectionView.frame.height)
        self.collectionView.scrollRectToVisible(frame, animated: true)
    }
    
    @IBAction func tapsOnRightArrowBtnAct(_ sender: Any) {
        let maximumPage = maximumPageNumber-1
        if maximumPage > self.pageNumber {
            self.pageNumber = self.pageNumber+1
        }
        
        if  self.pageNumber <= maximumPage{
            currentPageNoLbl.text =  "\(self.pageNumber+1)"
            apiMethods()
        }
    }
    
    @IBAction func tapsOnDobuleRightArrowBtnAct(_ sender: Any) {
        self.pageNumber = maximumPageNumber-1
        currentPageNoLbl.text =  "\(maximumPageNumber)"
        apiMethods()
    }
    
    @IBAction func tapsOnLeftArrowBtnAct(_ sender: Any) {
        if self.pageNumber > 0 {
            self.pageNumber = self.pageNumber-1
        }
        
        let maximumPage = maximumPageNumber-1
        if maximumPage >= self.pageNumber{
           
           currentPageNoLbl.text =  "\(self.pageNumber+1)"
          apiMethods()
        }
    }
    @IBAction func tapsOnDobuleLeftArrowBtnAct(_ sender: Any) {
        self.pageNumber = 0
        currentPageNoLbl.text =  "\(self.pageNumber+1)"
        apiMethods()
    }
    
    func apiMethods() {
        if self.factsArray.count > 0{
            self.callingSearchApi(filterArray: self.factsArray)
        }else{
            self.callingSearchApi(filterArray: [])
        }
    }
    
}

extension LiveSearchDetailsViewController: UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == filterTableView {
            return UITableView.automaticDimension
        }
        let headerName = headerArray[indexPath.section]
        switch headerName {
        case "FAQS":
            return UITableView.automaticDimension
        default:
            break
        }
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == filterTableView {
            return UITableView.automaticDimension
        }else{
            if headerArray.count>0{
                return   heightForTable(resultExpandArray: (arrayOfSearchResultsExpand[indexPath.section] as? NSMutableArray)!, layoutType: arrayOfLayOutType[indexPath.section] as! String, TemplateType: arrayOfLiveSearchTemplateType[indexPath.section] as! String, indexPath: indexPath)
                /*
                let headerName:LiveSearchHeaderTypes = LiveSearchHeaderTypes(rawValue: headerArray[indexPath.section])!
                           switch headerName {
                           case .faq:
                               return   heightForTable(resultExpandArray: faqsExpandArray, layoutType: faqLayOutType, TemplateType: liveSearchFAQsTemplateType, index: indexPath.row)
                               
                           case .web:
                               return   heightForTable(resultExpandArray: pagesExpandArray, layoutType: pageLayOutType, TemplateType: liveSearchPageTemplateType, index: indexPath.row)
                               
                           case .task:
                              return UITableView.automaticDimension
                               
                           case .file:
                               return   heightForTable(resultExpandArray: filesExpandArray, layoutType: fileLayOutType, TemplateType: liveSearchFileTemplateType, index: indexPath.row)
                               
                           case .data:
                               return   heightForTable(resultExpandArray: dataExpandArray, layoutType: dataLayOutType, TemplateType: liveSearchDataTemplateType, index: indexPath.row)
                           }*/
            }
            return UITableView.automaticDimension
           
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == filterTableView {
            return arrayOfSearchFacets.count
        }else if tableView == tableView{
            return headerArray.count
        }
        return 0
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == filterTableView {
            return arrayOfSearchFacets[section].buckets!.count
        }else{
            
            if arrayOfLiveSearchTemplateType.count > 0{
            if arrayOfLiveSearchTemplateType[section] as? String == LiveSearchTypes.grid.rawValue || arrayOfLiveSearchTemplateType[section] as? String == LiveSearchTypes.carousel.rawValue{
                return 1
            }else{
                if arrayOfSearchResults.count > 0{
                let rowsCount = (arrayOfSearchResults[section] as AnyObject).count > rowsDataLimit ? rowsDataLimit : (arrayOfSearchResults[section] as AnyObject).count
                return rowsCount ?? 0
                }
                return 0
            }}
            return 0
            /*
            let headerName: LiveSearchHeaderTypes = LiveSearchHeaderTypes(rawValue: headerArray[section])!
            switch headerName {
            case .faq:
                if liveSearchFAQsTemplateType == LiveSearchTypes.grid.rawValue || liveSearchFAQsTemplateType == LiveSearchTypes.carousel.rawValue{
                        return 1
                    }
                    return arrayOfFaqResults.count > rowsDataLimit ? rowsDataLimit : arrayOfFaqResults.count
            case .web:
                    if liveSearchPageTemplateType == LiveSearchTypes.grid.rawValue || liveSearchPageTemplateType == LiveSearchTypes.carousel.rawValue{
                        return 1
                    }
                    return arrayOfPageResults.count > rowsDataLimit ? rowsDataLimit : arrayOfPageResults.count
            case .task:
                    return arrayOfTaskResults.count > rowsDataLimit ? rowsDataLimit : arrayOfTaskResults.count
            case .file:
                if liveSearchFileTemplateType == LiveSearchTypes.grid.rawValue || liveSearchFileTemplateType == LiveSearchTypes.carousel.rawValue{
                        return 1
                    }
                    return arrayOfFileResults.count > rowsDataLimit ? rowsDataLimit : arrayOfFileResults.count
            case .data:
                if liveSearchDataTemplateType == LiveSearchTypes.grid.rawValue || liveSearchDataTemplateType == LiveSearchTypes.carousel.rawValue{
                    return 1
                }
                return arrayOfDataResults.count > rowsDataLimit ? rowsDataLimit : arrayOfDataResults.count
            }*/
        }
            
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == filterTableView {
            let cell : FilterTableCell = self.filterTableView.dequeueReusableCell(withIdentifier: FilterTableCellIdentifier) as! FilterTableCell
            cell.backgroundColor = UIColor.clear
            cell.selectionStyle = .none
            let buckets = arrayOfSearchFacets[indexPath.section].buckets![indexPath.row]
            cell.titleLabel.text = buckets.key
            cell.countLabel.text = "(\(buckets.doc_count!))"
            if checkboxIndexPath.contains(indexPath) {
                cell.checkImage.image = UIImage(named:"check")
            }else{
                cell.checkImage.image = UIImage(named:"uncheck")
            }
            return cell
        }else{
            if headerArray.count > 0{
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
                }else if  arrayOfLiveSearchTemplateType[indexPath.section] as? String == LiveSearchTypes.carousel.rawValue{
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
                /*
                let mappingResults = ((hashMapDic.object(forKey: "template") as AnyObject).object(forKey: "results") as AnyObject)
                let headerName: LiveSearchHeaderTypes = LiveSearchHeaderTypes(rawValue: headerArray[indexPath.section])!
                switch headerName{
                case .faq:
                    if liveSearchFAQsTemplateType == LiveSearchTypes.grid.rawValue {
                        let cell = tableView.dequeueReusableCell(withIdentifier: GridTableViewCellIdentifier, for: indexPath) as! GridTableViewCell
                        //cell.configure(with: arrayOfFaqResults, appearanceType: headerName.rawValue, layOutType: faqLayOutType, templateType:liveSearchFAQsTemplateType)
                        //let hashMapArray = (mappingResults.object(forKey: "faq") as AnyObject)
                        let mappingResultDic = (mappingResults.object(forKey: "faq") as AnyObject)
                        if let hashMapArray = mappingResultDic["data"] as? NSArray{
                            cell.configureNew(with: arrayOfFaqResults, appearanceType: headerName.rawValue, layOutType: faqLayOutType, templateType:liveSearchFAQsTemplateType, hashMapArray: hashMapArray, isSearchScreen: isSearchType)
                        }
                        return cell
                    }else if  liveSearchFAQsTemplateType == LiveSearchTypes.carousel.rawValue{
                        let cell = tableView.dequeueReusableCell(withIdentifier: CarouselTableViewCellIdentifier, for: indexPath) as! CarouselTableViewCell
                        //cell.configure(with: arrayOfFaqResults, appearanceType: headerName.rawValue, layOutType: faqLayOutType, templateType:liveSearchFAQsTemplateType)
                        //let hashMapArray = (mappingResults.object(forKey: "faq") as AnyObject)
                        let mappingResultDic = (mappingResults.object(forKey: "faq") as AnyObject)
                        if let hashMapArray = mappingResultDic["data"] as? NSArray{
                            cell.configureNew(with: arrayOfFaqResults, appearanceType: headerName.rawValue, layOutType: faqLayOutType, templateType:liveSearchFAQsTemplateType, hashMapArray: hashMapArray, isSearchScreen: isSearchType)
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
                            TitleWithHeaderCellMethod(cell: cell, cellResultArray: arrayOfFaqResults, expandArray: faqsExpandArray, indexPath: indexPath, isClickable: isFaqsClickable, templateType: faqListType, appearanceType: headerName.rawValue, textAlignment:faqTextAlignment)
                            return cell
                        }
                    }
                case .web:
                    if liveSearchPageTemplateType == LiveSearchTypes.grid.rawValue {
                        let cell = tableView.dequeueReusableCell(withIdentifier: GridTableViewCellIdentifier, for: indexPath) as! GridTableViewCell
//                        cell.configure(with: arrayOfPageResults, appearanceType: headerName.rawValue, layOutType: pageLayOutType, templateType:liveSearchPageTemplateType)
                        //let hashMapArray = (mappingResults.object(forKey: "web") as AnyObject)
                        let mappingResultDic = (mappingResults.object(forKey: "web") as AnyObject)
                        if let hashMapArray = mappingResultDic["data"] as? NSArray{
                            cell.configureNew(with: arrayOfPageResults, appearanceType: headerName.rawValue, layOutType: pageLayOutType, templateType:liveSearchPageTemplateType, hashMapArray: hashMapArray, isSearchScreen: isSearchType)
                        }
                        return cell
                    }else if  liveSearchPageTemplateType == LiveSearchTypes.carousel.rawValue{
                        let cell = tableView.dequeueReusableCell(withIdentifier: CarouselTableViewCellIdentifier, for: indexPath) as! CarouselTableViewCell
//                        cell.configure(with: arrayOfPageResults, appearanceType: headerName.rawValue, layOutType: pageLayOutType, templateType:liveSearchPageTemplateType)
                        //let hashMapArray = (mappingResults.object(forKey: "web") as AnyObject)
                        let mappingResultDic = (mappingResults.object(forKey: "web") as AnyObject)
                        if let hashMapArray = mappingResultDic["data"] as? NSArray{
                            cell.configureNew(with: arrayOfPageResults, appearanceType: headerName.rawValue, layOutType: pageLayOutType, templateType:liveSearchPageTemplateType, hashMapArray: hashMapArray, isSearchScreen: isSearchType)
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
                            TitleWithHeaderCellMethod(cell: cell, cellResultArray: arrayOfPageResults, expandArray: pagesExpandArray, indexPath: indexPath, isClickable: isPagesClickable, templateType: pageListType, appearanceType: headerName.rawValue, textAlignment:pageTextAlignment)
                            return cell
                        }
                    }
                    
                case .file:
                    if liveSearchFileTemplateType == LiveSearchTypes.grid.rawValue{
                        let cell = tableView.dequeueReusableCell(withIdentifier: GridTableViewCellIdentifier, for: indexPath) as! GridTableViewCell
//                        cell.configure(with: arrayOfFileResults, appearanceType: headerName.rawValue, layOutType: fileLayOutType, templateType:liveSearchFileTemplateType)
                        //let hashMapArray = (mappingResults.object(forKey: "file") as AnyObject)
                        let mappingResultDic = (mappingResults.object(forKey: "file") as AnyObject)
                        if let hashMapArray = mappingResultDic["data"] as? NSArray{
                            cell.configureNew(with: arrayOfFileResults, appearanceType: headerName.rawValue, layOutType: fileLayOutType, templateType:liveSearchFileTemplateType, hashMapArray: hashMapArray, isSearchScreen: isSearchType)
                        }
                        return cell
                    }else if liveSearchFileTemplateType == LiveSearchTypes.carousel.rawValue{
                        let cell = tableView.dequeueReusableCell(withIdentifier: CarouselTableViewCellIdentifier, for: indexPath) as! CarouselTableViewCell
//                        cell.configure(with: arrayOfFileResults, appearanceType: headerName.rawValue, layOutType: fileLayOutType, templateType:liveSearchFileTemplateType)
                        //let hashMapArray = (mappingResults.object(forKey: "file") as AnyObject)
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
                            TitleWithHeaderCellMethod(cell: cell, cellResultArray: arrayOfFileResults, expandArray: filesExpandArray, indexPath: indexPath, isClickable: isFileClickable, templateType: fileListType, appearanceType: headerName.rawValue,textAlignment: fileTextAlignment)
                            return cell
                        }
                    }
                    
                case .data:
                    if liveSearchDataTemplateType == LiveSearchTypes.grid.rawValue {
                        let cell = tableView.dequeueReusableCell(withIdentifier: GridTableViewCellIdentifier, for: indexPath) as! GridTableViewCell
//                        cell.configure(with: arrayOfDataResults, appearanceType: headerName.rawValue, layOutType: dataLayOutType, templateType:liveSearchDataTemplateType)
                        //let hashMapArray = (mappingResults.object(forKey: "data") as AnyObject)
                        let mappingResultDic = (mappingResults.object(forKey: "default_group") as AnyObject)
                        if let hashMapArray = mappingResultDic["data"] as? NSArray{
                            cell.configureNew(with: arrayOfDataResults, appearanceType: headerName.rawValue, layOutType: dataLayOutType, templateType:liveSearchDataTemplateType, hashMapArray: hashMapArray, isSearchScreen: isSearchType)
                        }
                        return cell
                    }else if  liveSearchDataTemplateType == LiveSearchTypes.carousel.rawValue{
                        let cell = tableView.dequeueReusableCell(withIdentifier: CarouselTableViewCellIdentifier, for: indexPath) as! CarouselTableViewCell
//                        cell.configure(with: arrayOfDataResults, appearanceType: headerName.rawValue, layOutType: dataLayOutType, templateType:liveSearchDataTemplateType)
                        //let hashMapArray = (mappingResults.object(forKey: "data") as AnyObject)
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
                    //                let cell : LiveSearchTaskTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: liveSearchTaskCellIdentifier) as! LiveSearchTaskTableViewCell
                    //                cell.backgroundColor = UIColor.clear
                    //                cell.selectionStyle = .none
                    //                cell.titleLabel.textColor = .black
                    //                let results = arrayOfTaskResults[indexPath.row]
                    //                cell.titleLabel?.text = results.name
                    //                var gridImage: String?
                    //                gridImage = results.imageUrl
                    //                if gridImage == nil || gridImage == ""{
                    //                    cell.profileImageView.image = UIImage(named: "task")
                    //                }else{
                    //                    let url = URL(string: gridImage!)
                    //                    cell.profileImageView.setImageWith(url!, placeholderImage: UIImage(named: "task"))
                    //                }
                    //                return cell
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
            }else{
                return UITableViewCell()
            }
            
        }
        
    }
    func removeSelectedValues(value:String){
        arrayOfSeletedValues = arrayOfSeletedValues.filter(){$0["value"] != value}
        //print(arrayOfSeletedValues)
        
    }
    func createJsonData(){
        var set = Set<String>()
        let arrayFieldName: [[String: Any]] = arrayOfSeletedValues.compactMap {
            guard let name = $0["fieldName"] else { return nil }
            return set.insert(name).inserted ? $0 : nil
        }
        
        
        factsArray = []
        for i in 0..<arrayFieldName.count{
            let index = arrayFieldName[i]
            let facetValue = NSMutableArray()
            for j in 0..<arrayOfSeletedValues.count{
                let selectedindex = arrayOfSeletedValues[j]
                if index["fieldName"] as! String == selectedindex["fieldName"]!{
                    facetValue.add(selectedindex["value"]!)
                }
            }
            let facts: [String: Any] = ["subtype": "value", "fieldName": index["fieldName"] as! String ,"facetValue": facetValue, "name": index["fieldName"] as! String]
            factsArray.add(facts)
        }
        
        resultGrpORtabConfigDic = [:]
        //This for select collectionView type
        if sysContentType != "All"{
//            let facetValue = NSMutableArray()
//            facetValue.add(sysContentType)
//            let facts: [String: Any] = ["subtype": "value", "fieldName": "sys_content_type" ,"facetValue": facetValue, "name": "facetContentType"]
//            factsArray.add(facts) //sysContentType
            
            let tabFilter: [String: Any] = ["fieldName" : "sys_content_type","facetValue":[sysContentType]]
            let tabConfig: [String: Any] = ["filter": tabFilter]
            resultGrpORtabConfigDic = tabConfig
        }
        print(factsArray)
        print(resultGrpORtabConfigDic)
        
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == filterTableView {
            let multiselect = (arrayOfSearchFacets[indexPath.section].multiselect ?? false) as Bool
            let elements = arrayOfSearchFacets[indexPath.section].buckets?[indexPath.row]
            if multiselect{
                if checkboxIndexPath.contains(indexPath) {
                    removeSelectedValues(value: (elements?.key)!)
                    checkboxIndexPath.remove(at: checkboxIndexPath.firstIndex(of: indexPath)!)
                }else{
                    checkboxIndexPath.append(indexPath)
                    let dic = NSMutableDictionary()
                    dic.setValue((elements?.key)!, forKey: "value")
                    dic.setValue(arrayOfSearchFacets[indexPath.section].fieldName, forKey: "fieldName")
                    arrayOfSeletedValues.append(dic as! [String : String])
                }
                filterTableView.reloadRows(at: [indexPath], with: .none)
                createJsonData()
            }else{
                    //checkboxIndexPath = []
                   // arrayOfSeletedValues = []
                    
                var removeIndexPathArray = [IndexPath]()
                removeIndexPathArray = checkboxIndexPath
                for i in 0..<checkboxIndexPath.count{
                    let indexSec = checkboxIndexPath[i]
                    if indexSec.section == indexPath.section{
                        removeIndexPathArray.remove(at: i)
                    }
                }
                    checkboxIndexPath = removeIndexPathArray
                    checkboxIndexPath.append(indexPath)
                    let dic = NSMutableDictionary()
                    dic.setValue((elements?.key)!, forKey: "value")
                    dic.setValue(arrayOfSearchFacets[indexPath.section].fieldName, forKey: "fieldName")
                    arrayOfSeletedValues.append(dic as! [String : String])
                
                filterTableView.reloadData()
                createJsonData()
            }
           
            
            if arrayOfSeletedValues.count>0{
                submitButton.isHidden = false
                cleartButton.isHidden = false
            }else{
                submitButton.isHidden = true
                cleartButton.isHidden = true
                clearBtnWidthConstraint.constant = 65
                if isFilterApply {
                    submitButton.isHidden = false
                    clearBtnWidthConstraint.constant = 0
                }
                
            }
            badgeLabel.text = "\(arrayOfSeletedValues.count)"
            topBadgeLabel.text = "\(arrayOfSeletedValues.count)"
            if arrayOfSeletedValues.count > 0 {
                topBadgeView.isHidden = false
                badgeView.isHidden = false
            }else{
                topBadgeView.isHidden = true
                badgeView.isHidden = true
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
                    mappingResultDic = (mappingResults.object(forKey: "\("\(headerArray[indexPath.row])")") as AnyObject)
                }
                if let hashMapArray = mappingResultDic?["data"] as? NSArray{
                    let url = ((hashMapArray.object(at: indexPath.row) as AnyObject).object(forKey: "\(arrayOfUrl[indexPath.section])") as? String)
                    if url != "" {
                        self.movetoWebViewController(urlString: url!)
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
                            //viewDelegate?.linkButtonTapAction(urlString: url!)
                            self.movetoWebViewController(urlString: url!)
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
                            self.movetoWebViewController(urlString: url!)
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
                     
                    self.dismiss(animated: true, completion: nil)
                }
               isEndOfTask = false //kk
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
                            self.movetoWebViewController(urlString: url!)
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
                            self.movetoWebViewController(urlString: url!)
                        }
                    }
                }
                
            }*/
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
        if tableView == filterTableView {
            headerLabel.text =  arrayOfSearchFacets[section].name
            
        }else{
            headerLabel.text =  headerArray[section]
        }
        view.addSubview(headerLabel)
        
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
        let attributeString = NSMutableAttributedString(string: "Show More",
                                                        attributes: yourAttributes)
        showMoreButton.setAttributedTitle(attributeString, for: .normal)
        showMoreButton.isHidden = true
        let views: [String: UIView] = ["headerLabel": headerLabel, "showMoreButton": showMoreButton]
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[headerLabel]-5-[showMoreButton(100)]-10-|", options:[], metrics:nil, views:views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[headerLabel]-0-|", options:[], metrics:nil, views:views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[showMoreButton]-0-|", options:[], metrics:nil, views:views))
        
        return view
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.init(red: 240/255, green: 242/255, blue: 244/255, alpha: 1.0)
        let showMoreButton = UIButton(frame: CGRect.zero)
        showMoreButton.backgroundColor = .clear
        showMoreButton.translatesAutoresizingMaskIntoConstraints = false
        showMoreButton.clipsToBounds = true
        showMoreButton.layer.cornerRadius = 5
        showMoreButton.setTitleColor(.blue, for: .normal)
        showMoreButton.setTitleColor(Common.UIColorRGB(0x999999), for: .disabled)
        showMoreButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 14.0)!
        view.addSubview(showMoreButton)
        showMoreButton.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
        showMoreButton.addTarget(self, action: #selector(self.showMoreButtonAction(_:)), for: .touchUpInside)
        showMoreButton.tag = section
        let attributeString = NSMutableAttributedString(string: "Show More",
                                                        attributes: yourAttributes)
        showMoreButton.setAttributedTitle(attributeString, for: .normal)
        let views: [String: UIView] = ["showMoreButton": showMoreButton]
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[showMoreButton(35)]", options:[], metrics:nil, views:views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[showMoreButton]-0-|", options:[], metrics:nil, views:views))
        
        return view
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if tableView == filterTableView {
            return 0
        }else{
            if arrayOfSearchResults.count > 0{
                if let results = arrayOfSearchResults[section] as? [TemplateResultElements]{
                    return results.count > rowsDataLimit ? 35 : 0
                }
            }
        }
//        let headerName : LiveSearchHeaderTypes = LiveSearchHeaderTypes(rawValue: headerArray[section])!
//        switch headerName {
//        case .faq:
//            return arrayOfFaqResults.count > rowsDataLimit ? 35 : 0
//        case .web:
//            return arrayOfPageResults.count > rowsDataLimit ? 35 : 0
//        case .task:
//            return arrayOfTaskResults.count > rowsDataLimit ? 35 : 0
//        case .data:
//            return arrayOfDataResults.count > rowsDataLimit ? 35 : 0
//        case .file:
//            return arrayOfFileResults.count > rowsDataLimit ? 35 : 0
//        default:
//            break
//        }
        return 0
    }
    
    
    @objc fileprivate func shareButtonAction(_ sender: AnyObject!) {
        let results = arrayOfPageResults[sender.tag]
        if results.url != nil {
            movetoWebViewController(urlString: results.url!)
        }
    }
    @objc fileprivate func documentShareButtonAction(_ sender: AnyObject!) {
        let results = arrayOfDataResults[sender.tag]
        if results.externalFileUrl != nil {
            movetoWebViewController(urlString: results.externalFileUrl!)
        }
    }
    
    @objc fileprivate func showMoreButtonAction(_ sender: AnyObject!) {
        collectionViewSelectedIndex = sender.tag
        headerArray = []
        if self.arrayOfFaqResults.count > 0 {
            self.headerArray.append(LiveSearchHeaderTypes.faq.rawValue)
        }
        if self.arrayOfPageResults.count > 0 {
            self.headerArray.append(LiveSearchHeaderTypes.web.rawValue)
        }
        if self.arrayOfTaskResults.count > 0 {
            self.headerArray.append(LiveSearchHeaderTypes.task.rawValue)
        }
        if self.arrayOfDataResults.count > 0 {
            self.headerArray.append(LiveSearchHeaderTypes.data.rawValue)
        }
        if self.arrayOfFileResults.count > 0 {
            self.headerArray.append(LiveSearchHeaderTypes.file.rawValue)
        }
        
        //rowsDataLimit = 100
        let headerName : LiveSearchHeaderTypes = LiveSearchHeaderTypes(rawValue: headerArray[sender.tag])!
        switch headerName {
        case .faq:
            collectionViewSelectedIndex = 1
            headerArray = []
            if self.arrayOfFaqResults.count > 0 {
                self.headerArray.append(LiveSearchHeaderTypes.faq.rawValue)
            }
        case .web:
            collectionViewSelectedIndex = 2
            headerArray = []
            if self.arrayOfPageResults.count > 0 {
                self.headerArray.append(LiveSearchHeaderTypes.web.rawValue)
            }
        case .task:
            collectionViewSelectedIndex = 3
            headerArray = []
            if self.arrayOfTaskResults.count > 0 {
                self.headerArray.append(LiveSearchHeaderTypes.task.rawValue)
            }
        case .data:
            collectionViewSelectedIndex = 4
            headerArray = []
            if self.arrayOfDataResults.count > 0 {
                self.headerArray.append(LiveSearchHeaderTypes.data.rawValue)
            }
        case .file:
            collectionViewSelectedIndex = 5
            headerArray = []
            if self.arrayOfFileResults.count > 0 {
                self.headerArray.append(LiveSearchHeaderTypes.file.rawValue)
            }
        }
        collectionView.reloadData()
        self.collectionView.scrollToItem(at: IndexPath(row: collectionViewSelectedIndex, section: 0), at: UICollectionView.ScrollPosition.centeredHorizontally, animated: true)
        tableView.reloadData()
    }
    
    func movetoWebViewController(urlString:String){
        if (urlString.count > 0) {
            let url: URL = URL(string: urlString)!
            let webViewController = SFSafariViewController(url: url)
            present(webViewController, animated: true, completion:nil)
        }
    }
}

extension LiveSearchDetailsViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    //MARK: collection view delegate methods
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayOfCollectionView.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // swiftlint:disable force_cast
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchDetailsCollectionViewCellIdentifier, for: indexPath) as! SearchDetailsCollectionViewCell
        cell.backgroundColor = .clear
        cell.imageV.image = UIImage.init(named: "\(arrayOfCollectionViewImages[indexPath.item])")
        cell.titleLabel.text = "\(arrayOfCollectionView[indexPath.item]) (\(arrayOfCollectionViewCount[indexPath.item]))"
        cell.layer.cornerRadius = 5
        if collectionViewSelectedIndex == indexPath.item {
            //cell.backgroundColor = .white
            cell.titleLabel.textColor = .black
            cell.imageV.image = UIImage.init(named: "\(arrayOfCollectionViewImagesSelected[indexPath.item])")
        }else{
            //cell.backgroundColor = .clear
            cell.imageV.image = UIImage.init(named: "\(arrayOfCollectionViewImages[indexPath.item])")
            cell.titleLabel.textColor = UIColor.init(red: 153/255, green: 187/255, blue: 207/255, alpha: 1.0)
        }
        return cell
    }
    func indexPathIsValid(indexPath: NSIndexPath) -> Bool {
        return indexPath.section < numberOfSections(in: collectionView) && indexPath.row < collectionView.numberOfItems(inSection: (indexPath.section))
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionViewSelectedIndex = indexPath.item
        headerArray = []
        
        //rowsDataLimit = 100
        
        self.headerArray.append(arrayOfCollectionView[indexPath.item])
        
        let headerName = arrayOfCollectionView[indexPath.item]
        sysContentType = sysContentTypeArray[indexPath.item] as! String
        /*
        switch headerName {
        case header_allResults:
            if self.arrayOfFaqResults.count > 0 {
                self.headerArray.append(LiveSearchHeaderTypes.faq.rawValue)
            }
            if self.arrayOfPageResults.count > 0 {
                self.headerArray.append(LiveSearchHeaderTypes.web.rawValue)
            }
            if self.arrayOfTaskResults.count > 0 {
                self.headerArray.append(LiveSearchHeaderTypes.task.rawValue)
            }
            if self.arrayOfDataResults.count > 0 {
                self.headerArray.append(LiveSearchHeaderTypes.data.rawValue)
            }
            if self.arrayOfFileResults.count > 0 {
                self.headerArray.append(LiveSearchHeaderTypes.file.rawValue)
            }
            sysContentType = LiveSearchSysContentTypes.allResults.rawValue
            
        case header_faq:
            if self.arrayOfFaqResults.count > 0 {
                self.headerArray.append(LiveSearchHeaderTypes.faq.rawValue)
            }
            sysContentType = LiveSearchSysContentTypes.faq.rawValue
        case header_web:
            if self.arrayOfPageResults.count > 0 {
                self.headerArray.append(LiveSearchHeaderTypes.web.rawValue)
            }
            sysContentType = LiveSearchSysContentTypes.web.rawValue
        case header_task:
            if self.arrayOfTaskResults.count > 0 {
                self.headerArray.append(LiveSearchHeaderTypes.task.rawValue)
            }
            sysContentType = LiveSearchSysContentTypes.task.rawValue
        case header_data:
            if self.arrayOfDataResults.count > 0 {
                self.headerArray.append(LiveSearchHeaderTypes.data.rawValue)
            }
            sysContentType = LiveSearchSysContentTypes.data.rawValue
        case header_file:
            if self.arrayOfFileResults.count > 0 {
                self.headerArray.append(LiveSearchHeaderTypes.file.rawValue)
            }
            sysContentType = LiveSearchSysContentTypes.file.rawValue
        default:
            break
        }
        */
        collectionView.reloadData()
        if indexPathIsValid(indexPath: IndexPath(row: indexPath.item, section: 0) as NSIndexPath){
             self.collectionView.scrollToItem(at: IndexPath(row: indexPath.item, section: 0), at: UICollectionView.ScrollPosition.centeredHorizontally, animated: true)
        }
       
        //tableView.reloadData() //kk
        
        if arrayOfCollectionViewCount.count > 0{
        let tottalCount = arrayOfCollectionViewCount[indexPath.item] as! Int
        var roundvalue: Double = Double(tottalCount) / Double(numberofRowsLimit) //rowsDataLimit //kkk
            if roundvalue >= 1.0{
                roundvalue = roundvalue + 1
            }
            maximumPageNumber = Int(Double(roundvalue))//Int(round(roundvalue))
        }
        
        createJsonData()
        self.pageNumber = 0
        totalPageNoLbl.text = "\(maximumPageNumber)"
        currentPageNoLbl.text = "\(pageNumber+1)"
        if sysContentType == "All"{
            pageNationVHeightConstraint.constant = 0
            if arrayOfSeletedValues.count > 0 {
                callingSearchApi(filterArray: factsArray)
            }else{
                callingSearchApi(filterArray: [])
            }
        }else{
            if maximumPageNumber == 0 || maximumPageNumber == 1{
                pageNationVHeightConstraint.constant = 00
            }else{
                pageNationVHeightConstraint.constant = 50
            }
            callingSearchApi(filterArray: factsArray)
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5.0, left: 10.0, bottom: 5.0, right: 10.0)
    }
    
}
extension LiveSearchDetailsViewController{
    @objc fileprivate func likeButtonAction(_ sender: UIButton!) {
        likeAndDislikeArray.replaceObject(at: sender.tag, with: "Like")
        tableView.reloadData()
    }
    @objc fileprivate func disLikeButtonAction(_ sender: UIButton!) {
        likeAndDislikeArray.replaceObject(at: sender.tag, with: "DisLike")
        tableView.reloadData()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.isEqual(tableView){
            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveLinear], animations: {
                self.flotingButtonView.alpha = 1 // Here you will get the animation you want
                self.badgeView.alpha = 1
            }, completion: { _ in
                
                let height = scrollView.frame.size.height
                let contentYoffset = scrollView.contentOffset.y
                let distanceFromBottom = scrollView.contentSize.height - contentYoffset
                if distanceFromBottom < height || Int(distanceFromBottom) == Int(height) {
                    print(" you reached end of the table")
                    
                    if self.sysContentType != "All"{
                        self.pageNumber = self.pageNumber+1
                        if self.factsArray.count > 0{
                            //self.callingSearchApi(filterArray: self.factsArray)
                        }else{
                            //self.callingSearchApi(filterArray: [])
                        }
                    }
                }
                
                if self.isShowFileterView{
                    self.flotingButtonView.isHidden = false // Here you hide it when animation done
                    if self.arrayOfSeletedValues.count > 0{
                        self.badgeView.isHidden = false
                    }else{
                        self.badgeView.isHidden = true
                    }
                }
            })
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView.isEqual(tableView){
            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveLinear] , animations: {
                self.flotingButtonView.alpha = 0 // Here you will get the animation you want
                self.badgeView.alpha = 0
            }, completion: { _ in
                self.flotingButtonView.isHidden = true // Here you hide it when animation done
                self.badgeView.isHidden = true
            })
        }
    }
    
    func movingUp()  {
        UIView.animate(withDuration: 1.0, delay: 0.2, options: [.curveEaseInOut], animations: {
            self.filterView.isHidden = false
            self.filterView.frame = CGRect(x: 0, y: UIScreen.main.bounds.origin.y+54, width: self.filterView.bounds.size.width, height: self.filterView.bounds.size.height)
        }) { (finished) in
            if finished {
                // Repeat animation to bottom to top
            }
        }
        
    }
    
    func movingDown()  {
        UIView.animate(withDuration: 1.0, delay: 0.2, options: [.curveEaseInOut], animations: {
            self.filterView.frame = CGRect(x: 0, y: UIScreen.main.bounds.origin.y+self.filterView.bounds.size.height, width: self.filterView.bounds.size.width, height: self.filterView.bounds.size.height)
            
        }) { (finished) in
            if finished {
                // Repeat animation to bottom to top
                self.filterView.isHidden = true
            }
        }
        
    }
}

extension LiveSearchDetailsViewController{
    
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
    //MARK:- ListType - L1
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
    //MARK:- ListType - L2
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
    
    //MARK:- ListType - L3
    func titleWithTextCellMethod(cell: LiveSearchFaqTableViewCell,cellResultArray: [TemplateResultElements],expandArray: NSMutableArray, indexPath: IndexPath, isClickable: Bool, templateType: String, appearanceType: String){
        
        cell.backgroundColor = UIColor.clear
        cell.selectionStyle = .none
        cell.titleLabel.textColor = .black
        cell.descriptionLabel.textColor = .dark
        cell.titleLabel?.numberOfLines = 0 //2
        cell.descriptionLabel?.numberOfLines = 0 //2
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
    //MARK:- ListType - L4
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
    //MARK:- ListType - L6
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
