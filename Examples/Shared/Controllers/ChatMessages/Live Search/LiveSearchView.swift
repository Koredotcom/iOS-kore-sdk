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
    var headerArray = ["POPULAR SEARCHS","RECENT SEARCHS"]
    var kaBotClient = KABotClient()
    var popularSearchArray:NSMutableArray = []
    var arrayOfResults = [TemplateResultElements]()
    
    var arrayOfFaqResults = [TemplateResultElements]()
    var arrayOfPageResults = [TemplateResultElements]()
    var arrayOfTaskResults = [TemplateResultElements]()
    var expandArray:NSMutableArray = []
    var likeAndDislikeArray:NSMutableArray = []
    var headersExpandArray:NSMutableArray = []
    
    var viewDelegate: LiveSearchViewDelegate?
    var isPopularSearch = true
    var liveSearchJsonString:String?
    
    let yourAttributes : [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.font : UIFont(name: "HelveticaNeue-Bold", size: 15.0) as Any,
        NSAttributedString.Key.foregroundColor : themeColor]
    let sectionAndRowsLimit = 2
    
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
            self?.expandArray = []
            self?.headersExpandArray = []
            self?.likeAndDislikeArray = []
            let faqs = allItems.template?.results?.faq
            self?.arrayOfFaqResults = faqs ?? []
            if self!.arrayOfFaqResults.count > 0 {
                self!.headerArray.append("FAQS")
                self!.headersExpandArray.add("open")
            }
            for _ in 0..<self!.arrayOfFaqResults.count{
                self!.expandArray.add("close")
                self?.likeAndDislikeArray.add("")
            }
            
            let pages = allItems.template?.results?.page
            self?.arrayOfPageResults = pages ?? []
            if self!.arrayOfPageResults.count > 0 {
                self!.headerArray.append("PAGES")
                self!.headersExpandArray.add("open")
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
            self?.isPopularSearch = false
            DispatchQueue.main.async {
                self!.tableView.reloadData()
                self?.notifyLabel.isHidden = true
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
                if expandArray[indexPath.row] as! String == "close"{
                    return 120
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
            let headerName = headerArray[indexPath.section]
            switch headerName {
            case "FAQS":
                if  expandArray[indexPath.row] as! String == "close"{
                    return 120
                }
                return UITableView.automaticDimension
            default:
                break
            }
            return UITableView.automaticDimension
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
            let headerName = headerArray[section]
            switch headerName {
            case "FAQS":
                if headersExpandArray [section] as! String == "open"{
                    return arrayOfFaqResults.count > sectionAndRowsLimit ? sectionAndRowsLimit : arrayOfFaqResults.count
                }
                return 0
            case "PAGES":
                if headersExpandArray [section] as! String == "open"{
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
            let headerName = headerArray[indexPath.section]
            switch headerName {
            case "FAQS":
                let cell : LiveSearchFaqTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: liveSearchFaqCellIdentifier) as! LiveSearchFaqTableViewCell
                cell.backgroundColor = UIColor.clear
                cell.selectionStyle = .none
                cell.titleLabel.textColor = .black
                cell.descriptionLabel.textColor = .dark
                cell.titleLabel?.numberOfLines = 2
                cell.descriptionLabel?.numberOfLines = 2
                let results = arrayOfFaqResults[indexPath.row]
                cell.titleLabel?.text = results.question
                cell.descriptionLabel?.text = results.answer
                let buttonsHeight = expandArray[indexPath.row] as! String == "close" ? 0.0: 30.0
                cell.likeAndDislikeButtonHeightConstrain.constant = CGFloat(buttonsHeight)
                
                cell.likeButton.addTarget(self, action: #selector(self.likeButtonAction(_:)), for: .touchUpInside)
                cell.likeButton.tag = indexPath.row
                cell.dislikeButton.addTarget(self, action: #selector(self.disLikeButtonAction(_:)), for: .touchUpInside)
                cell.dislikeButton.tag = indexPath.row
                if likeAndDislikeArray[indexPath.row] as! String == "Like"{
                    cell.likeButton.tintColor = .blue
                    cell.dislikeButton.tintColor = .darkGray
                }else if likeAndDislikeArray[indexPath.row] as! String == "DisLike"{
                    cell.likeButton.tintColor = .darkGray
                    cell.dislikeButton.tintColor = .blue
                }
                return cell
            case "PAGES":
                let cell : LiveSearchPageTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: liveSearchPageCellIdentifier) as! LiveSearchPageTableViewCell
                cell.backgroundColor = UIColor.clear
                cell.selectionStyle = .none
                cell.titleLabel.textColor = .black
                cell.descriptionLabel.textColor = .dark
                let results = arrayOfPageResults[indexPath.row]
                cell.titleLabel?.text = results.pageTitle
                cell.descriptionLabel?.text = results.pageSearchResultPreview
                cell.titleLabel?.numberOfLines = 2
                cell.descriptionLabel?.numberOfLines = 2
                if results.imageUrl == nil || results.imageUrl == ""{
                    cell.profileImageView.image = UIImage(named: "placeholder_image")
                }else{
                    let url = URL(string: results.imageUrl!)
                    cell.profileImageView.setImageWith(url!, placeholderImage: UIImage(named: "placeholder_image"))
                }
                cell.ShareButton.addTarget(self, action: #selector(self.shareButtonAction(_:)), for: .touchUpInside)
                cell.ShareButton.tag = indexPath.row
                return cell
            case "TASKS":
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
                return cell
            default:
                break
            }
        }
        return UITableViewCell()
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let headerName = headerArray[indexPath.section]
        switch headerName {
        case "POPULAR SEARCHS":
            self.viewDelegate?.addTextToTextView(text: ((popularSearchArray.object(at: indexPath.row) as AnyObject).object(forKey: "_id") as! String))
        case "RECENT SEARCHS":
            self.viewDelegate?.addTextToTextView(text: ((recentSearchArray.object(at: indexPath.row) as AnyObject).object(forKey: "_id") as! String))
        case "FAQS":
            if expandArray[indexPath.row] as! String == "close" {
                expandArray.replaceObject(at: indexPath.row, with: "open")
            }else{
                expandArray.replaceObject(at: indexPath.row, with: "close")
            }
            tableView.reloadData()
            break
        case "PAGES":
            let results = arrayOfPageResults[indexPath.row]
            if results.url != nil {
                viewDelegate?.linkButtonTapAction(urlString: results.url!)
            }
            break
        case "TASKS":
            break
        default:
            break
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
        dropDownBtn.contentVerticalAlignment = UIControl.ContentVerticalAlignment.top
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
