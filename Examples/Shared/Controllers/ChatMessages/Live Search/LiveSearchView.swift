//
//  LiveSearchView.swift
//  KoreBotSDKDemo
//
//  Created by Kartheek.Pagidimarri on 14/10/20.
//  Copyright © 2020 Kore. All rights reserved.
//

import UIKit

class LiveSearchView: UIView {
    
    var tableView: UITableView!
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
    
    var isPopularSearch = true
    
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
            self.roundCorners([ .layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner], radius: 20.0, borderColor: UIColor.lightGray, borderWidth: 0)
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

        let views: [String: UIView] = ["tableView": tableView]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-15-[tableView]-0-|", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[tableView]-0-|", options: [], metrics: nil, views: views))
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
            print(arrayOfResults)
            self?.popularSearchArray = arrayOfResults.mutableCopy() as! NSMutableArray
            self?.isPopularSearch = true
            self?.headerArray = ["POPULAR SEARCHS","RECENT SEARCHS"]
            self!.tableView.reloadData()
        }, failure: { (error) in
                print(error)
        })
    }
    
    func callingLiveSearchApi(searchText: String){
        kaBotClient.getLiveSearchResults(searchText ,success: { [weak self] (dictionary) in
            print(dictionary)
            let jsonDecoder = JSONDecoder()
            guard let jsonData = try? JSONSerialization.data(withJSONObject: dictionary as Any , options: .prettyPrinted),
                let allItems = try? jsonDecoder.decode(LiveSearchItems.self, from: jsonData) else {
                                            return
                }
            self?.arrayOfResults = allItems.template?.results ?? []
            self?.headerArray = []
            let faqs = self?.arrayOfResults.filter({ $0.contentType == "faq" })
            self?.arrayOfFaqResults = faqs ?? []
            if self!.arrayOfFaqResults.count > 0 {
                self!.headerArray.append("SUGGESTED FAQS")
            }
            let pages = self?.arrayOfResults.filter({ $0.contentType == "page" })
            self?.arrayOfPageResults = pages ?? []
            if self!.arrayOfPageResults.count > 0 {
                self!.headerArray.append("SUGGESTED PAGES")
            }
            let task = self?.arrayOfResults.filter({ $0.contentType == "task" })
            self?.arrayOfTaskResults = task ?? []
            if self!.arrayOfTaskResults.count > 0 {
                self!.headerArray.append("SUGGESTED TASKS")
            }
            self?.isPopularSearch = false
            self!.tableView.reloadData()
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
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return headerArray.count
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
            case "SUGGESTED FAQS":
                return arrayOfFaqResults.count
            case "SUGGESTED PAGES":
                 return arrayOfPageResults.count
            case "SUGGESTED TASKS":
                 return arrayOfTaskResults.count
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
            let width = headerArray[indexPath.section] == "RECENT SEARCHS" ? 30.0 : 0.0
            cell.closeButtonWidthConstraint.constant = CGFloat(width)
            return cell
         }else{
            let headerName = headerArray[indexPath.section]
            switch headerName {
            case "SUGGESTED FAQS":
                let cell : LiveSearchFaqTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: liveSearchFaqCellIdentifier) as! LiveSearchFaqTableViewCell
                cell.backgroundColor = UIColor.clear
                cell.selectionStyle = .none
                cell.titleLabel.textColor = .black
                cell.descriptionLabel.textColor = .dark
                let results = arrayOfFaqResults[indexPath.row]
                cell.titleLabel?.text = results.question
                cell.descriptionLabel?.text = results.answer
                return cell
            case "SUGGESTED PAGES":
                let cell : LiveSearchPageTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: liveSearchPageCellIdentifier) as! LiveSearchPageTableViewCell
                cell.backgroundColor = UIColor.clear
                cell.selectionStyle = .none
                cell.titleLabel.textColor = .black
                cell.descriptionLabel.textColor = .dark
                let results = arrayOfPageResults[indexPath.row]
                cell.titleLabel?.text = results.title
                cell.descriptionLabel?.text = results.searchResultPreview
                let url = URL(string: results.imageUrl!)
                cell.profileImageView.setImageWith(url!, placeholderImage: UIImage(named: "placeholder_image"))
                cell.ShareButton.addTarget(self, action: #selector(self.shareButtonAction(_:)), for: .touchUpInside)
                cell.ShareButton.tag = indexPath.row
                return cell
            case "SUGGESTED TASKS":
               let cell : LiveSearchTaskTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: liveSearchTaskCellIdentifier) as! LiveSearchTaskTableViewCell
                cell.backgroundColor = UIColor.clear
                cell.selectionStyle = .none
                cell.titleLabel.textColor = .black
                let results = arrayOfTaskResults[indexPath.row]
                cell.titleLabel?.text = results.taskName
               if results.imageUrl == nil || results.imageUrl == ""{
                cell.profileImageView.image = UIImage(named: "placeholder_image")
               }else{
                let url = URL(string: results.imageUrl!)
                cell.profileImageView.setImageWith(url!, placeholderImage: UIImage(named: "placeholder_image"))
                }
                return cell
            default:
                break
            }
        }
        return UITableViewCell()
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if headerArray[indexPath.section] == "RECENT SEARCHS"{
           
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
           
           let views: [String: UIView] = ["headerLabel": headerLabel]
           view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[headerLabel]-0-|", options:[], metrics:nil, views:views))
           view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-5-[headerLabel]-5-|", options:[], metrics:nil, views:views))
           
           return view
       }
       func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
           return 30
       }
    
    @objc fileprivate func closeButtonAction(_ sender: AnyObject!) {
        recentSearchArray.removeObject(at: sender.tag)
        tableView.reloadData()
    }
    @objc fileprivate func shareButtonAction(_ sender: AnyObject!) {
        
    }
}

