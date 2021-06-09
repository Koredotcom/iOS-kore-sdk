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
}

class LiveSearchDetailsViewController: UIViewController, UIGestureRecognizerDelegate {
    var rowsDataLimit = 5
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
    
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var flotingButtonView: UIView!
    @IBOutlet weak var badgeView: UIView!
    @IBOutlet weak var badgeLabel: UILabel!
    
    @IBOutlet weak var topBadgeView: UIView!
    @IBOutlet weak var topBadgeLabel: UILabel!
    
    
    fileprivate let liveSearchFaqCellIdentifier = "LiveSearchFaqTableViewCell"
    fileprivate let liveSearchPageCellIdentifier = "LiveSearchPageTableViewCell"
    fileprivate let liveSearchTaskCellIdentifier = "LiveSearchTaskTableViewCell"
    fileprivate let LiveSearchCollectionViewCellIdentifier = "LiveSearchCollectionViewCell"
    fileprivate let SearchDetailsCollectionViewCellIdentifier = "SearchDetailsCollectionViewCell"
    fileprivate let FilterTableCellIdentifier = "FilterTableCell"
    
    fileprivate let titleWithImageCellIdentifier = "TitleWithImageCell"
    fileprivate let titleWithCenteredContentCellIdentifier = "TitleWithCenteredContentCell"
    fileprivate let TitleWithHeaderCellIdentifier = "TitleWithHeaderCell"
    
    fileprivate let GridTableViewCellIdentifier = "GridTableViewCell"
    
    
    var headerArray = ["POPULAR SEARCHS","RECENT SEARCHS"]
    var arrayOfCollectionView = ["All Results","FAQ's", "Pages","Actions", "Documents", "Files"]
    var arrayOfCollectionViewImagesSelected = ["all results","faq", "pages","actions", "docs","files"]
    var arrayOfCollectionViewImages = ["all results-S","faq-S", "pages-S","actions-S", "docs-S","files-S"]
    var collectionViewSelectedIndex = 0
    var arrayOfResults = [TemplateResultElements]()
    
    var arrayOfFaqResults = [TemplateResultElements]()
    var arrayOfPageResults = [TemplateResultElements]()
    var arrayOfTaskResults = [TemplateResultElements]()
    var arrayOfDocumentsResults = [TemplateResultElements]()
    var arrayOfFilesResults = [TemplateResultElements]()
    
    var arrayOfSearchFacets = [TemplateSearchFacets]()
    var checkboxIndexPath = [IndexPath]() //for Rows checkbox
    var arrayOfSeletedValues : [[String: String]] = []
    
    
    var faqsExpandArray:NSMutableArray = []
    var pagesExpandArray:NSMutableArray = []
    var actionExpandArray:NSMutableArray = []
    var documentExpandArray:NSMutableArray = []
    var filesExpandArray:NSMutableArray = []
    
    var likeAndDislikeArray:NSMutableArray = []
    var arrayOfCollectionViewCount:NSMutableArray = []
    var factsArray:NSMutableArray = []
    var isFilterApply = false
    
    var dataString: String!
    var jsonData : Componentss?
    var viewDelegate: LiveSearchDetailsViewDelegate?
    var kaBotClient = KABotClient()
    var tapToDismissGestureRecognizer: UITapGestureRecognizer!
    
    let yourAttributes : [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.font : UIFont(name: "HelveticaNeue-Bold", size: 15.0) as Any,
        NSAttributedString.Key.foregroundColor : themeColor]
    
    let liveSearchFAQsTemplateType = "listTemplate1" //listTemplate1
    let liveSearchPageTemplateType = "gridTemplate"
    let liveSearchActionTemplateType = "listTemplate3"
    let liveSearchDocumentTemplateType = "listTemplate3"
    let liveSearchFilesTemplateType = "listTemplate3"
    
    let faqLayOutType = "tileWithText"
    let pageLayOutType = "tileWithImage"
    let actionLayOutType = "tileWithText"
    let DocumentLayOutType = "tileWithText"
    let filesLayOutType = "tileWithText"
    
    let isFaqsExpand = false
    let isPagesExpand = true
    let isActionExpand = true
    let isDocumentExpand = true
    let isFilesExpand = true
    
    enum LiveSearchTemplateTypes: String{
        case listTemplate1 = "listTemplate1"
        case listTemplate2 = "listTemplate2"
        case listTemplate3 = "listTemplate3"
    }
    
    
    // MARK: init
    init(dataString: String) {
        super.init(nibName: "LiveSearchDetailsViewController", bundle: nil)
        self.dataString = dataString
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        filterTableView.register(UINib(nibName: FilterTableCellIdentifier, bundle: nil), forCellReuseIdentifier: FilterTableCellIdentifier)
        
        collectionView.backgroundColor = UIColor.init(hexString: "#eaeaea")
        //collectionView.register(UINib(nibName: LiveSearchCollectionViewCellIdentifier, bundle: nil), forCellWithReuseIdentifier: LiveSearchCollectionViewCellIdentifier)
        collectionView.register(UINib(nibName: SearchDetailsCollectionViewCellIdentifier, bundle: nil), forCellWithReuseIdentifier: SearchDetailsCollectionViewCellIdentifier)
        
        self.tableView.register(UINib(nibName: titleWithImageCellIdentifier, bundle: nil), forCellReuseIdentifier: titleWithImageCellIdentifier)
        self.tableView.register(UINib(nibName: titleWithCenteredContentCellIdentifier, bundle: nil), forCellReuseIdentifier: titleWithCenteredContentCellIdentifier)
        self.tableView.register(UINib(nibName: TitleWithHeaderCellIdentifier, bundle: nil), forCellReuseIdentifier: TitleWithHeaderCellIdentifier)
        
        self.tableView.register(UINib(nibName: GridTableViewCellIdentifier, bundle: nil), forCellReuseIdentifier: GridTableViewCellIdentifier)
        
        
        self.tapToDismissGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(LiveSearchDetailsViewController.hidFilterView(_:)))
        self.tapToDismissGestureRecognizer.delegate = self
        self.filterView.addGestureRecognizer(tapToDismissGestureRecognizer)
        
        //getData()
        
        callingSearchApi(filterArray: [])
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
        self.kaBotClient.getSearchResults(query, filterArray ,success: { [weak self] (dictionary) in
            print(dictionary)
            self?.receviceMessage(dictionary: dictionary)
            }, failure: { (error) in
                print(error)
                self.indicatorView.stopAnimating()
                self.indicatorView.isHidden = true
        })
    }
    func receviceMessage(dictionary:[String: Any]){
        let jsonDecoder = JSONDecoder()
        guard let jsonData = try? JSONSerialization.data(withJSONObject: dictionary as Any , options: .prettyPrinted),
            let allItems = try? jsonDecoder.decode(LiveSearchChatItems.self, from: jsonData) else {
                return
        }
        if arrayOfSearchFacets.count == 0{
            arrayOfSearchFacets = allItems.template?.searchFacets! ?? []
        }
        hideFilterView()
        
        self.headerArray = []
        self.faqsExpandArray = []
        pagesExpandArray = []
        actionExpandArray = []
        documentExpandArray = []
        filesExpandArray = []
        
        self.likeAndDislikeArray = []
        let faqs = allItems.template?.results?.faq
        self.arrayOfFaqResults = faqs ?? []
        if self.arrayOfFaqResults.count > 0 {
            self.headerArray.append("FAQS")
        }
        for _ in 0..<self.arrayOfFaqResults.count{
            self.faqsExpandArray.add("close")
            self.likeAndDislikeArray.add("")
        }
        
        let pages = allItems.template?.results?.page
        self.arrayOfPageResults = pages ?? []
        if self.arrayOfPageResults.count > 0 {
            self.headerArray.append("PAGES")
        }
        for _ in 0..<self.arrayOfPageResults.count{
            self.pagesExpandArray.add("close")
        }
        
        let task = allItems.template?.results?.task
        self.arrayOfTaskResults = task ?? []
        if self.arrayOfTaskResults.count > 0 {
            self.headerArray.append("ACTIONS")
        }
        for _ in 0..<self.arrayOfTaskResults.count{
            self.actionExpandArray.add("close")
        }
        
        let document = allItems.template?.results?.document
        self.arrayOfDocumentsResults = document ?? []
        if self.arrayOfDocumentsResults.count > 0 {
            self.headerArray.append("DOCUMENTS")
        }
        for _ in 0..<self.arrayOfDocumentsResults.count{
            self.documentExpandArray.add("close")
        }
        
        let files = allItems.template?.results?.files
        self.arrayOfFilesResults = files ?? []
        if self.arrayOfFilesResults.count > 0 {
            self.headerArray.append("FILES")
        }
        for _ in 0..<self.arrayOfFilesResults.count{
            self.filesExpandArray.add("close")
        }
        
        arrayOfCollectionViewCount = []
        arrayOfCollectionViewCount.add(allItems.template?.facets?.all_results as Any)
        arrayOfCollectionViewCount.add(allItems.template?.facets?.faq as Any)
        arrayOfCollectionViewCount.add(allItems.template?.facets?.page as Any)
        arrayOfCollectionViewCount.add(allItems.template?.facets?.task as Any)
        arrayOfCollectionViewCount.add(allItems.template?.facets?.document as Any)
        arrayOfCollectionViewCount.add(allItems.template?.facets?.files as Any)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.reloadData()
        tableView.reloadData()
        filterTableView.reloadData()
        indicatorView.stopAnimating()
        indicatorView.isHidden = true
        reloadTableViewSilently()
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
        callingSearchApi(filterArray: [])
        arrayOfSeletedValues = []
        badgeLabel.text = "\(arrayOfSeletedValues.count)"
        topBadgeLabel.text = "\(arrayOfSeletedValues.count)"
        checkboxIndexPath = []
        filterTableView.reloadData()
    }
    
    @IBAction func tapsOnSubmitBnAct(_ sender: Any) {
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
}

extension LiveSearchDetailsViewController: UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == filterTableView {
            return UITableView.automaticDimension
        }
        let headerName = headerArray[indexPath.section]
        switch headerName {
        case "FAQS":
            if faqsExpandArray[indexPath.row] as! String == "close"{
                return 120
            }
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
            let headerName = headerArray[indexPath.section]
            switch headerName {
            case "FAQS":
                return   heightForTable(resultExpandArray: faqsExpandArray, layoutType: faqLayOutType, TemplateType: liveSearchFAQsTemplateType, index: indexPath.row)
                
            case "PAGES":
                return   heightForTable(resultExpandArray: pagesExpandArray, layoutType: pageLayOutType, TemplateType: liveSearchPageTemplateType, index: indexPath.row)
                
            case "ACTIONS":
                return   heightForTable(resultExpandArray: actionExpandArray, layoutType: actionLayOutType, TemplateType: liveSearchActionTemplateType, index: indexPath.row)
                
            case "DOCUMENTS":
                return   heightForTable(resultExpandArray: documentExpandArray, layoutType: DocumentLayOutType, TemplateType: liveSearchDocumentTemplateType, index: indexPath.row)
                
            case "FILES":
                return   heightForTable(resultExpandArray: filesExpandArray, layoutType: filesLayOutType, TemplateType: liveSearchFilesTemplateType, index: indexPath.row)
                
            default:
                break
            }
            return UITableView.automaticDimension
        }
    }
    
    func heightForTable(resultExpandArray: NSMutableArray, layoutType: String, TemplateType: String, index: Int) -> CGFloat{
        if TemplateType == "gridTemplate"{
            return UITableView.automaticDimension
        }else{
            let layOutType = layoutType
            switch layOutType {
            case "tileWithText":
                if  resultExpandArray[index] as! String == "close"{
                    return 75
                }
                return UITableView.automaticDimension
                
            case "tileWithImage":
                if  resultExpandArray[index] as! String == "close"{
                    return 75
                }
                return UITableView.automaticDimension
            case "tileWithCenteredContent":
                if  resultExpandArray[index] as! String == "close"{
                    return 75+100
                }
                return UITableView.automaticDimension
            case "tileWithHeader":
                if  resultExpandArray[index] as! String == "close"{
                    return 50
                }
                return UITableView.automaticDimension
            default:
                break
            }
            
            return UITableView.automaticDimension
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == filterTableView {
            return arrayOfSearchFacets.count
        }
        return headerArray.count
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == filterTableView {
            return arrayOfSearchFacets[section].buckets!.count
        }
        let headerName = headerArray[section]
        switch headerName {
        case "FAQS":
            if liveSearchFAQsTemplateType == "gridTemplate"{
                return 1
            }
            return arrayOfFaqResults.count > rowsDataLimit ? rowsDataLimit : arrayOfFaqResults.count
        case "PAGES":
            if liveSearchPageTemplateType == "gridTemplate"{
                return 1
            }
            return arrayOfPageResults.count > rowsDataLimit ? rowsDataLimit : arrayOfPageResults.count
        case "ACTIONS":
            if liveSearchActionTemplateType == "gridTemplate"{
                return 1
            }
            return arrayOfTaskResults.count > rowsDataLimit ? rowsDataLimit : arrayOfTaskResults.count
        case "DOCUMENTS":
            if liveSearchDocumentTemplateType == "gridTemplate"{
                return 1
            }
            return arrayOfDocumentsResults.count > rowsDataLimit ? rowsDataLimit : arrayOfDocumentsResults.count
        case "FILES":
            if liveSearchFilesTemplateType == "gridTemplate"{
                return 1
            }
            return arrayOfFilesResults.count > rowsDataLimit ? rowsDataLimit : arrayOfFilesResults.count
        default:
            break
        }
        return 0
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
            let headerName = headerArray[indexPath.section]
            switch headerName {
            case "FAQS":
                if liveSearchFAQsTemplateType == "gridTemplate"{
                    let cell = tableView.dequeueReusableCell(withIdentifier: GridTableViewCellIdentifier, for: indexPath) as! GridTableViewCell
                    cell.configure(with: arrayOfFaqResults, appearanceType: headerName, layOutType: faqLayOutType)
                    return cell
                }else{
                    let layOutType = faqLayOutType
                    switch layOutType {
                    case "tileWithText":
                        let cell : LiveSearchFaqTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: liveSearchFaqCellIdentifier) as! LiveSearchFaqTableViewCell
                        titleWithTextCellMethod(cell: cell, cellResultArray: arrayOfFaqResults, expandArray: faqsExpandArray, indexPath: indexPath, isExpand: isFaqsExpand, templateType: liveSearchFAQsTemplateType, appearanceType: headerName)
                        return cell
                    case "tileWithImage":
                        let cell : TitleWithImageCell = self.tableView.dequeueReusableCell(withIdentifier: titleWithImageCellIdentifier) as! TitleWithImageCell
                        titleWithImageCellMethod(cell: cell, cellResultArray: arrayOfFaqResults, expandArray: faqsExpandArray, indexPath: indexPath, isExpand: isFaqsExpand, templateType: liveSearchFAQsTemplateType, appearanceType: headerName)
                        return cell
                    case "tileWithCenteredContent":
                        let cell : TitleWithCenteredContentCell = self.tableView.dequeueReusableCell(withIdentifier: titleWithCenteredContentCellIdentifier) as! TitleWithCenteredContentCell
                        titleWithCenteredContentCellMethod(cell: cell, cellResultArray: arrayOfFaqResults, expandArray: faqsExpandArray, indexPath: indexPath, isExpand: isFaqsExpand, templateType: liveSearchFAQsTemplateType, appearanceType: headerName)
                        return cell
                    case "tileWithHeader":
                        let cell : TitleWithHeaderCell = self.tableView.dequeueReusableCell(withIdentifier: TitleWithHeaderCellIdentifier) as! TitleWithHeaderCell
                        TitleWithHeaderCellMethod(cell: cell, cellResultArray: arrayOfFaqResults, expandArray: faqsExpandArray, indexPath: indexPath, isExpand: isFaqsExpand, templateType: liveSearchFAQsTemplateType, appearanceType: headerName)
                        return cell
                    default:
                        break
                    }
                }
            case "PAGES":
                if liveSearchPageTemplateType == "gridTemplate"{
                    let cell = tableView.dequeueReusableCell(withIdentifier: GridTableViewCellIdentifier, for: indexPath) as! GridTableViewCell
                    cell.configure(with: arrayOfPageResults, appearanceType: headerName, layOutType: pageLayOutType)
                    return cell
                }else{
                    let layOutType = pageLayOutType
                    switch layOutType {
                    case "tileWithText":
                        let cell : LiveSearchFaqTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: liveSearchFaqCellIdentifier) as! LiveSearchFaqTableViewCell
                        titleWithTextCellMethod(cell: cell, cellResultArray: arrayOfPageResults, expandArray: pagesExpandArray, indexPath: indexPath, isExpand: isPagesExpand, templateType: liveSearchPageTemplateType, appearanceType: headerName)
                        return cell
                    case "tileWithImage":
                        let cell : TitleWithImageCell = self.tableView.dequeueReusableCell(withIdentifier: titleWithImageCellIdentifier) as! TitleWithImageCell
                        titleWithImageCellMethod(cell: cell, cellResultArray: arrayOfPageResults, expandArray:
                            pagesExpandArray, indexPath: indexPath, isExpand: isPagesExpand, templateType: liveSearchPageTemplateType, appearanceType: headerName)
                        return cell
                    case "tileWithCenteredContent":
                        let cell : TitleWithCenteredContentCell = self.tableView.dequeueReusableCell(withIdentifier: titleWithCenteredContentCellIdentifier) as! TitleWithCenteredContentCell
                        titleWithCenteredContentCellMethod(cell: cell, cellResultArray: arrayOfPageResults, expandArray: pagesExpandArray, indexPath: indexPath, isExpand: isPagesExpand, templateType: liveSearchPageTemplateType, appearanceType: headerName)
                        return cell
                    case "tileWithHeader":
                        let cell : TitleWithHeaderCell = self.tableView.dequeueReusableCell(withIdentifier: TitleWithHeaderCellIdentifier) as! TitleWithHeaderCell
                        TitleWithHeaderCellMethod(cell: cell, cellResultArray: arrayOfPageResults, expandArray: pagesExpandArray, indexPath: indexPath, isExpand: isPagesExpand, templateType: liveSearchPageTemplateType, appearanceType: headerName)
                        return cell
                    default:
                        break
                    }
                }
            case "ACTIONS":
//                let cell : LiveSearchTaskTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: liveSearchTaskCellIdentifier) as! LiveSearchTaskTableViewCell
//                cell.backgroundColor = UIColor.clear
//                cell.selectionStyle = .none
//                cell.titleLabel.textColor = .black
//                let results = arrayOfTaskResults[indexPath.row]
//                cell.titleLabel?.text = results.name
//                if results.imageUrl == nil || results.imageUrl == ""{
//                    cell.profileImageView.image = UIImage(named: "task")
//                }else{
//                    let url = URL(string: results.imageUrl!)
//                    cell.profileImageView.setImageWith(url!, placeholderImage: UIImage(named: "task"))
//                }
//                return cell
                if liveSearchActionTemplateType == "gridTemplate"{
                    let cell = tableView.dequeueReusableCell(withIdentifier: GridTableViewCellIdentifier, for: indexPath) as! GridTableViewCell
                    cell.configure(with: arrayOfTaskResults, appearanceType: headerName, layOutType: actionLayOutType)
                    return cell
                }else{
                    let layOutType = actionLayOutType
                    switch layOutType {
                    case "tileWithText":
                        let cell : LiveSearchFaqTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: liveSearchFaqCellIdentifier) as! LiveSearchFaqTableViewCell
                        titleWithTextCellMethod(cell: cell, cellResultArray: arrayOfTaskResults, expandArray: actionExpandArray, indexPath: indexPath, isExpand: isActionExpand, templateType: liveSearchActionTemplateType, appearanceType: headerName)
                        return cell
                    case "tileWithImage":
                        let cell : TitleWithImageCell = self.tableView.dequeueReusableCell(withIdentifier: titleWithImageCellIdentifier) as! TitleWithImageCell
                        titleWithImageCellMethod(cell: cell, cellResultArray: arrayOfTaskResults, expandArray: actionExpandArray, indexPath: indexPath, isExpand: isActionExpand, templateType: liveSearchActionTemplateType, appearanceType: headerName)
                        return cell
                    case "tileWithCenteredContent":
                        let cell : TitleWithCenteredContentCell = self.tableView.dequeueReusableCell(withIdentifier: titleWithCenteredContentCellIdentifier) as! TitleWithCenteredContentCell
                        titleWithCenteredContentCellMethod(cell: cell, cellResultArray: arrayOfTaskResults, expandArray: actionExpandArray, indexPath: indexPath, isExpand: isActionExpand, templateType: liveSearchActionTemplateType, appearanceType: headerName)
                        return cell
                    case "tileWithHeader":
                        let cell : TitleWithHeaderCell = self.tableView.dequeueReusableCell(withIdentifier: TitleWithHeaderCellIdentifier) as! TitleWithHeaderCell
                        TitleWithHeaderCellMethod(cell: cell, cellResultArray: arrayOfTaskResults, expandArray: actionExpandArray, indexPath: indexPath, isExpand: isActionExpand, templateType: liveSearchActionTemplateType, appearanceType: headerName)
                        return cell
                    default:
                        break
                    }
                }
            case "DOCUMENTS":
//                let cell : LiveSearchPageTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: liveSearchPageCellIdentifier) as! LiveSearchPageTableViewCell
//                cell.backgroundColor = UIColor.clear
//                cell.selectionStyle = .none
//                cell.titleLabel.textColor = .black
//                cell.descriptionLabel.textColor = .dark
//                let results = arrayOfDocumentsResults[indexPath.row]
//                cell.titleLabel?.text = results.title
//                cell.descriptionLabel?.text = results.searchResultPreview
//                if results.imageUrl == nil || results.imageUrl == ""{
//                    cell.profileImageView.image = UIImage(named: "docs")
//                }else{
//                    let urlString = results.imageUrl!.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
//                    let url1 = URL(string: urlString!)
//                    cell.profileImageView.setImageWith(url1!, placeholderImage: UIImage(named: "docs"))
//                }
//                cell.ShareButton.addTarget(self, action: #selector(self.documentShareButtonAction(_:)), for: .touchUpInside)
//                cell.ShareButton.tag = indexPath.row
//                return cell
                if liveSearchDocumentTemplateType == "gridTemplate"{
                    let cell = tableView.dequeueReusableCell(withIdentifier: GridTableViewCellIdentifier, for: indexPath) as! GridTableViewCell
                    cell.configure(with: arrayOfDocumentsResults, appearanceType: headerName, layOutType: DocumentLayOutType)
                    return cell
                }else{
                    let layOutType = DocumentLayOutType
                    switch layOutType {
                    case "tileWithText":
                        let cell : LiveSearchFaqTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: liveSearchFaqCellIdentifier) as! LiveSearchFaqTableViewCell
                        titleWithTextCellMethod(cell: cell, cellResultArray: arrayOfDocumentsResults, expandArray: documentExpandArray, indexPath: indexPath, isExpand: isDocumentExpand, templateType: liveSearchDocumentTemplateType, appearanceType: headerName)
                        return cell
                    case "tileWithImage":
                        let cell : TitleWithImageCell = self.tableView.dequeueReusableCell(withIdentifier: titleWithImageCellIdentifier) as! TitleWithImageCell
                        titleWithImageCellMethod(cell: cell, cellResultArray: arrayOfDocumentsResults, expandArray: documentExpandArray, indexPath: indexPath, isExpand: isDocumentExpand, templateType: liveSearchDocumentTemplateType, appearanceType: headerName)
                        return cell
                    case "tileWithCenteredContent":
                        let cell : TitleWithCenteredContentCell = self.tableView.dequeueReusableCell(withIdentifier: titleWithCenteredContentCellIdentifier) as! TitleWithCenteredContentCell
                        titleWithCenteredContentCellMethod(cell: cell, cellResultArray: arrayOfDocumentsResults, expandArray: documentExpandArray, indexPath: indexPath, isExpand: isDocumentExpand, templateType: liveSearchDocumentTemplateType, appearanceType: headerName)
                        return cell
                    case "tileWithHeader":
                        let cell : TitleWithHeaderCell = self.tableView.dequeueReusableCell(withIdentifier: TitleWithHeaderCellIdentifier) as! TitleWithHeaderCell
                        TitleWithHeaderCellMethod(cell: cell, cellResultArray: arrayOfDocumentsResults, expandArray: documentExpandArray, indexPath: indexPath, isExpand: isDocumentExpand, templateType: liveSearchDocumentTemplateType, appearanceType: headerName)
                        return cell
                    default:
                        break
                    }
                }
            case "FILES":
                if liveSearchFilesTemplateType == "gridTemplate"{
                    let cell = tableView.dequeueReusableCell(withIdentifier: GridTableViewCellIdentifier, for: indexPath) as! GridTableViewCell
                    cell.configure(with: arrayOfFilesResults, appearanceType: headerName, layOutType: filesLayOutType)
                    return cell
                }else{
                    let layOutType = filesLayOutType
                    switch layOutType {
                    case "tileWithText":
                        let cell : LiveSearchFaqTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: liveSearchFaqCellIdentifier) as! LiveSearchFaqTableViewCell
                        titleWithTextCellMethod(cell: cell, cellResultArray: arrayOfFilesResults, expandArray: filesExpandArray, indexPath: indexPath, isExpand: isFilesExpand, templateType: liveSearchFilesTemplateType, appearanceType: headerName)
                        return cell
                    case "tileWithImage":
                        let cell : TitleWithImageCell = self.tableView.dequeueReusableCell(withIdentifier: titleWithImageCellIdentifier) as! TitleWithImageCell
                        titleWithImageCellMethod(cell: cell, cellResultArray: arrayOfFilesResults, expandArray: filesExpandArray, indexPath: indexPath, isExpand: isFilesExpand, templateType: liveSearchFilesTemplateType, appearanceType: headerName)
                        return cell
                    case "tileWithCenteredContent":
                        let cell : TitleWithCenteredContentCell = self.tableView.dequeueReusableCell(withIdentifier: titleWithCenteredContentCellIdentifier) as! TitleWithCenteredContentCell
                        titleWithCenteredContentCellMethod(cell: cell, cellResultArray: arrayOfFilesResults, expandArray: filesExpandArray, indexPath: indexPath, isExpand: isFilesExpand, templateType: liveSearchFilesTemplateType, appearanceType: headerName)
                        return cell
                    case "tileWithHeader":
                        let cell : TitleWithHeaderCell = self.tableView.dequeueReusableCell(withIdentifier: TitleWithHeaderCellIdentifier) as! TitleWithHeaderCell
                        TitleWithHeaderCellMethod(cell: cell, cellResultArray: arrayOfFilesResults, expandArray: filesExpandArray, indexPath: indexPath, isExpand: isFilesExpand, templateType: liveSearchFilesTemplateType, appearanceType: headerName)
                        return cell
                    default:
                        break
                    }
                }
            default:
                break
            }
            return UITableViewCell()
        }
        
    }
    func removeSelectedValues(value:String){
        arrayOfSeletedValues = arrayOfSeletedValues.filter(){$0["value"] != value}
        print(arrayOfSeletedValues)
        
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
            let facts: [String: Any] = ["facetType": "value", "fieldName": index["fieldName"] as! String ,"facetValue": facetValue]
            factsArray.add(facts)
        }
        print(factsArray)
        //filterView.isHidden = true
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == filterTableView {
            let elements = arrayOfSearchFacets[indexPath.section].buckets?[indexPath.row]
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
            let headerName = headerArray[indexPath.section]
            switch headerName {
            case "RECENT SEARCHS":
                break
            case "FAQS":
                //                if faqsExpandArray[indexPath.row] as! String == "close" {
                //                    faqsExpandArray.replaceObject(at: indexPath.row, with: "open")
                //                }else{
                //                    faqsExpandArray.replaceObject(at: indexPath.row, with: "close")
                //                }
                //                tableView.reloadData()
                if isFaqsExpand{
                    if faqsExpandArray[indexPath.row] as! String == "close" {
                        faqsExpandArray.replaceObject(at: indexPath.row, with: "open")
                    }else{
                        faqsExpandArray.replaceObject(at: indexPath.row, with: "close")
                    }
                    tableView.reloadData()
                }
                break
            case "PAGES":
                if isPagesExpand{
                    if pagesExpandArray[indexPath.row] as! String == "close" {
                        pagesExpandArray.replaceObject(at: indexPath.row, with: "open")
                    }else{
                        pagesExpandArray.replaceObject(at: indexPath.row, with: "close")
                    }
                    tableView.reloadData()
                }
                break
            case "ACTIONS":
//                if let payload = arrayOfTaskResults[indexPath.row].payload {
//                    self.viewDelegate?.optionsButtonTapAction(text: payload)
//                    self.dismiss(animated: true, completion: nil)
//                }
                if isActionExpand{
                    if actionExpandArray[indexPath.row] as! String == "close" {
                        actionExpandArray.replaceObject(at: indexPath.row, with: "open")
                    }else{
                        actionExpandArray.replaceObject(at: indexPath.row, with: "close")
                    }
                    tableView.reloadData()
                }
                break
            case "DOCUMENTS":
                if isDocumentExpand{
                    if documentExpandArray[indexPath.row] as! String == "close" {
                        documentExpandArray.replaceObject(at: indexPath.row, with: "open")
                    }else{
                        documentExpandArray.replaceObject(at: indexPath.row, with: "close")
                    }
                    tableView.reloadData()
                }
                break
            case "FILES":
                if isFilesExpand{
                    if filesExpandArray[indexPath.row] as! String == "close" {
                        filesExpandArray.replaceObject(at: indexPath.row, with: "open")
                    }else{
                        filesExpandArray.replaceObject(at: indexPath.row, with: "close")
                    }
                    tableView.reloadData()
                }
                break
            default:
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
        if tableView == filterTableView {
            headerLabel.text =  arrayOfSearchFacets[section].facetName
            
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
        }
        let headerName = headerArray[section]
        switch headerName {
        case "FAQS":
            return arrayOfFaqResults.count > rowsDataLimit ? 35 : 0
        case "PAGES":
            return arrayOfPageResults.count > rowsDataLimit ? 35 : 0
        case "ACTIONS":
            return arrayOfTaskResults.count > rowsDataLimit ? 35 : 0
        case "DOCUMENTS":
            return arrayOfDocumentsResults.count > rowsDataLimit ? 35 : 0
        case "FILES":
            return arrayOfFilesResults.count > rowsDataLimit ? 35 : 0
        default:
            break
        }
        return 0
    }
    
    @objc fileprivate func shareButtonAction(_ sender: AnyObject!) {
        let results = arrayOfPageResults[sender.tag]
        if results.url != nil {
            movetoWebViewController(urlString: results.url!)
        }
    }
    @objc fileprivate func documentShareButtonAction(_ sender: AnyObject!) {
        let results = arrayOfDocumentsResults[sender.tag]
        if results.externalFileUrl != nil {
            movetoWebViewController(urlString: results.externalFileUrl!)
        }
    }
    
    @objc fileprivate func showMoreButtonAction(_ sender: AnyObject!) {
        collectionViewSelectedIndex = sender.tag
        headerArray = []
        if self.arrayOfFaqResults.count > 0 {
            self.headerArray.append("FAQS")
        }
        if self.arrayOfPageResults.count > 0 {
            self.headerArray.append("PAGES")
        }
        if self.arrayOfTaskResults.count > 0 {
            self.headerArray.append("ACTIONS")
        }
        if self.arrayOfDocumentsResults.count > 0 {
            self.headerArray.append("DOCUMENTS")
        }
        if self.arrayOfFilesResults.count > 0 {
            self.headerArray.append("FILES")
        }
        
        rowsDataLimit = 100
        let headerName = headerArray[sender.tag]
        switch headerName {
        case "FAQS":
            collectionViewSelectedIndex = 1
            headerArray = []
            if self.arrayOfFaqResults.count > 0 {
                self.headerArray.append("FAQS")
            }
        case "PAGES":
            collectionViewSelectedIndex = 2
            headerArray = []
            if self.arrayOfPageResults.count > 0 {
                self.headerArray.append("PAGES")
            }
        case "ACTIONS":
            collectionViewSelectedIndex = 3
            headerArray = []
            if self.arrayOfTaskResults.count > 0 {
                self.headerArray.append("ACTIONS")
            }
        case "DOCUMENTS":
            collectionViewSelectedIndex = 4
            headerArray = []
            if self.arrayOfDocumentsResults.count > 0 {
                self.headerArray.append("DOCUMENTS")
            }
        case "FILES":
            collectionViewSelectedIndex = 5
            headerArray = []
            if self.arrayOfFilesResults.count > 0 {
                self.headerArray.append("FILES")
            }
        default:
            break
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
        cell.titleLabel.text = "\(arrayOfCollectionView[indexPath.row]) (\(arrayOfCollectionViewCount[indexPath.row]))"
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
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionViewSelectedIndex = indexPath.item
        headerArray = []
        let headerName = arrayOfCollectionView[indexPath.item]
        rowsDataLimit = 100
        switch headerName {
        case "All Results":
            if self.arrayOfFaqResults.count > 0 {
                self.headerArray.append("FAQS")
            }
            if self.arrayOfPageResults.count > 0 {
                self.headerArray.append("PAGES")
            }
            if self.arrayOfTaskResults.count > 0 {
                self.headerArray.append("ACTIONS")
            }
            if self.arrayOfDocumentsResults.count > 0 {
                self.headerArray.append("DOCUMENTS")
            }
            if self.arrayOfFilesResults.count > 0 {
                self.headerArray.append("FILES")
            }
            rowsDataLimit = 5
        case "FAQ's":
            if self.arrayOfFaqResults.count > 0 {
                self.headerArray.append("FAQS")
            }
        case "Pages":
            if self.arrayOfPageResults.count > 0 {
                self.headerArray.append("PAGES")
            }
        case "Actions":
            if self.arrayOfTaskResults.count > 0 {
                self.headerArray.append("ACTIONS")
            }
        case "Documents":
            if self.arrayOfDocumentsResults.count > 0 {
                self.headerArray.append("DOCUMENTS")
            }
        case "Files":
            if self.arrayOfFilesResults.count > 0 {
                self.headerArray.append("FILES")
            }
        default:
            break
        }
        collectionView.reloadData()
        self.collectionView.scrollToItem(at: IndexPath(row: indexPath.item, section: 0), at: UICollectionView.ScrollPosition.centeredHorizontally, animated: true)
        tableView.reloadData()
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
                self.flotingButtonView.isHidden = false // Here you hide it when animation done
                if self.arrayOfSeletedValues.count > 0{
                    self.badgeView.isHidden = false
                }else{
                    self.badgeView.isHidden = true
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
        //        if likeAndDislikeArray[indexPath.row] as! String == "Like"{
        //            cell.likeButton.tintColor = .blue
        //            cell.dislikeButton.tintColor = .darkGray
        //        }else if likeAndDislikeArray[indexPath.row] as! String == "DisLike"{
        //            cell.likeButton.tintColor = .darkGray
        //            cell.dislikeButton.tintColor = .blue
        //        }
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
