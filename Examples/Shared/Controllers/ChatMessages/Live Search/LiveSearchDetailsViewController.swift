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

class LiveSearchDetailsViewController: UIViewController {
    var rowsDataLimit = 5
    @IBOutlet weak var subView: UIView!
    @IBOutlet weak var headingLebel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    fileprivate let liveSearchFaqCellIdentifier = "LiveSearchFaqTableViewCell"
    fileprivate let liveSearchPageCellIdentifier = "LiveSearchPageTableViewCell"
    fileprivate let liveSearchTaskCellIdentifier = "LiveSearchTaskTableViewCell"
    fileprivate let LiveSearchCollectionViewCellIdentifier = "LiveSearchCollectionViewCell"
    
    var headerArray = ["POPULAR SEARCHS","RECENT SEARCHS"]
    var arrayOfCollectionView = ["All Results","FAQ's", "Pages","Actions"]
    var collectionViewSelectedIndex = 0
    var arrayOfResults = [TemplateResultElements]()
    
    var arrayOfFaqResults = [TemplateResultElements]()
    var arrayOfPageResults = [TemplateResultElements]()
    var arrayOfTaskResults = [TemplateResultElements]()
    var expandArray:NSMutableArray = []
    var arrayOfCollectionViewCount:NSMutableArray = []
    
    var dataString: String!
    var jsonData : Componentss?
    var viewDelegate: LiveSearchDetailsViewDelegate?
    
    let yourAttributes : [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.font : UIFont(name: "HelveticaNeue-Bold", size: 15.0) as Any,
        NSAttributedString.Key.foregroundColor : themeColor]
    
    
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
        
        self.subView.backgroundColor = UIColor.init(red: 240/255, green: 242/255, blue: 244/255, alpha: 1.0)
        subView.layer.masksToBounds = false
        //subView?.layer.shadowColor = UIColor.lightGray.cgColor
        subView?.layer.shadowOffset =  CGSize.zero
        subView?.layer.shadowOpacity = 0.5
        subView?.layer.shadowRadius = 4
        
        // Do any additional setup after loading the view.
        tableview.register(UINib(nibName: liveSearchFaqCellIdentifier, bundle: nil), forCellReuseIdentifier: liveSearchFaqCellIdentifier)
        tableview.register(UINib(nibName: liveSearchPageCellIdentifier, bundle: nil), forCellReuseIdentifier: liveSearchPageCellIdentifier)
        tableview.register(UINib(nibName: liveSearchTaskCellIdentifier, bundle: nil), forCellReuseIdentifier: liveSearchTaskCellIdentifier)
        collectionView.backgroundColor = UIColor.init(hexString: "#eaeaea")
        collectionView.register(UINib(nibName: LiveSearchCollectionViewCellIdentifier, bundle: nil),
                                forCellWithReuseIdentifier: LiveSearchCollectionViewCellIdentifier)
        getData()
    }
    
    
    func getData(){
        let jsonObject: NSDictionary = Utilities.jsonObjectFromString(jsonString: dataString!) as! NSDictionary
        let jsonDecoder = JSONDecoder()
        guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject as Any , options: .prettyPrinted),
            let allItems = try? jsonDecoder.decode(LiveSearchItems.self, from: jsonData) else {
                return
        }
        self.arrayOfResults = allItems.template?.results ?? []
        self.headerArray = []
        self.expandArray = []
        let faqs = self.arrayOfResults.filter({ $0.contentType == "faq" })
        self.arrayOfFaqResults = faqs 
        if self.arrayOfFaqResults.count > 0 {
            self.headerArray.append("MATCHED FAQS")
        }
        for _ in 0..<self.arrayOfFaqResults.count{
            self.expandArray.add("close")
        }
        
        let pages = self.arrayOfResults.filter({ $0.contentType == "page" })
        self.arrayOfPageResults = pages 
        if self.arrayOfPageResults.count > 0 {
            self.headerArray.append("MATCHED PAGES")
        }
        let task = self.arrayOfResults.filter({ $0.contentType == "task" })
        self.arrayOfTaskResults = task 
        if self.arrayOfTaskResults.count > 0 {
            self.headerArray.append("MATCHED ACTIONS")
        }
        
        arrayOfCollectionViewCount = []
        arrayOfCollectionViewCount.add(allItems.template?.facets?.all_results as Any)
        arrayOfCollectionViewCount.add(allItems.template?.facets?.faq as Any)
        arrayOfCollectionViewCount.add(allItems.template?.facets?.page as Any)
        arrayOfCollectionViewCount.add(allItems.template?.facets?.task as Any)
        self.tableview.reloadData()
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
}

extension LiveSearchDetailsViewController: UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let headerName = headerArray[indexPath.section]
        switch headerName {
        case "MATCHED FAQS":
            if expandArray[indexPath.row] as! String == "close"{
                return 120
            }
            return UITableView.automaticDimension
        default:
            break
        }
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let headerName = headerArray[indexPath.section]
        switch headerName {
        case "MATCHED FAQS":
            if expandArray[indexPath.row] as! String == "close"{
                return 120
            }
            return UITableView.automaticDimension
        default:
            break
        }
        return UITableView.automaticDimension
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return headerArray.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let headerName = headerArray[section]
        switch headerName {
        case "MATCHED FAQS":
            return arrayOfFaqResults.count > rowsDataLimit ? rowsDataLimit : arrayOfFaqResults.count
        case "MATCHED PAGES":
            return arrayOfPageResults.count > rowsDataLimit ? rowsDataLimit : arrayOfPageResults.count
        case "MATCHED ACTIONS":
            return arrayOfTaskResults.count > rowsDataLimit ? rowsDataLimit : arrayOfTaskResults.count
        default:
            break
        }
        return 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let headerName = headerArray[indexPath.section]
        switch headerName {
        case "MATCHED FAQS":
            let cell : LiveSearchFaqTableViewCell = self.tableview.dequeueReusableCell(withIdentifier: liveSearchFaqCellIdentifier) as! LiveSearchFaqTableViewCell
            cell.backgroundColor = UIColor.clear
            cell.selectionStyle = .none
            cell.titleLabel.textColor = .black
            cell.descriptionLabel.textColor = .dark
            let results = arrayOfFaqResults[indexPath.row]
            cell.titleLabel?.text = results.question
            cell.descriptionLabel?.text = results.answer
            let buttonsHeight = expandArray[indexPath.row] as! String == "close" ? 0.0: 30.0
            cell.likeAndDislikeButtonHeightConstrain.constant = CGFloat(buttonsHeight)
            return cell
        case "MATCHED PAGES":
            let cell : LiveSearchPageTableViewCell = self.tableview.dequeueReusableCell(withIdentifier: liveSearchPageCellIdentifier) as! LiveSearchPageTableViewCell
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
        case "MATCHED ACTIONS":
            let cell : LiveSearchTaskTableViewCell = self.tableview.dequeueReusableCell(withIdentifier: liveSearchTaskCellIdentifier) as! LiveSearchTaskTableViewCell
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
        return UITableViewCell()
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let headerName = headerArray[indexPath.section]
        switch headerName {
        case "RECENT SEARCHS":
            break
        case "MATCHED FAQS":
            if expandArray[indexPath.row] as! String == "close" {
                expandArray.replaceObject(at: indexPath.row, with: "open")
            }else{
                expandArray.replaceObject(at: indexPath.row, with: "close")
            }
            tableView.reloadData()
            break
        case "MATCHED PAGES":
            break
        case "MATCHED ACTIONS":
            if let payload = arrayOfTaskResults[indexPath.row].postBackPayload?.payload {
                self.viewDelegate?.optionsButtonTapAction(text: payload)
                self.dismiss(animated: true, completion: nil)
            }
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
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[headerLabel]-5-|", options:[], metrics:nil, views:views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[showMoreButton]-5-|", options:[], metrics:nil, views:views))
        
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
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[showMoreButton(30)]-0-|", options:[], metrics:nil, views:views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[showMoreButton]-0-|", options:[], metrics:nil, views:views))
        
        return view
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let headerName = headerArray[section]
        switch headerName {
        case "MATCHED FAQS":
            return arrayOfFaqResults.count > rowsDataLimit ? 35 : 0
        case "MATCHED PAGES":
            return arrayOfPageResults.count > rowsDataLimit ? 35 : 0
        case "MATCHED ACTIONS":
            return arrayOfTaskResults.count > rowsDataLimit ? 35 : 0
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
    
    @objc fileprivate func showMoreButtonAction(_ sender: AnyObject!) {
        collectionViewSelectedIndex = sender.tag
        headerArray = []
        if self.arrayOfFaqResults.count > 0 {
            self.headerArray.append("MATCHED FAQS")
        }
        if self.arrayOfPageResults.count > 0 {
            self.headerArray.append("MATCHED PAGES")
        }
        if self.arrayOfTaskResults.count > 0 {
            self.headerArray.append("MATCHED ACTIONS")
        }
        
        rowsDataLimit = 100
        let headerName = headerArray[sender.tag]
        switch headerName {
        case "MATCHED FAQS":
            collectionViewSelectedIndex = 1
            headerArray = []
            if self.arrayOfFaqResults.count > 0 {
                self.headerArray.append("MATCHED FAQS")
            }
        case "MATCHED PAGES":
            collectionViewSelectedIndex = 2
            headerArray = []
            if self.arrayOfPageResults.count > 0 {
                self.headerArray.append("MATCHED PAGES")
            }
        case "MATCHED ACTIONS":
            collectionViewSelectedIndex = 3
            headerArray = []
            if self.arrayOfTaskResults.count > 0 {
                self.headerArray.append("MATCHED ACTIONS")
            }
        default:
            break
        }
        collectionView.reloadData()
         self.collectionView.scrollToItem(at: IndexPath(row: collectionViewSelectedIndex, section: 0), at: UICollectionView.ScrollPosition.centeredHorizontally, animated: true)
        tableview.reloadData()
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LiveSearchCollectionViewCellIdentifier, for: indexPath) as! LiveSearchCollectionViewCell
        cell.backgroundColor = .clear
        cell.titleLabel.text = "\(arrayOfCollectionView[indexPath.row]) (\(arrayOfCollectionViewCount[indexPath.row]))"
        cell.layer.cornerRadius = 5
        if collectionViewSelectedIndex == indexPath.item {
            cell.backgroundColor = .white
            cell.titleLabel.textColor = .black
        }else{
            cell.backgroundColor = .clear
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
                self.headerArray.append("MATCHED FAQS")
            }
            if self.arrayOfPageResults.count > 0 {
                self.headerArray.append("MATCHED PAGES")
            }
            if self.arrayOfTaskResults.count > 0 {
                self.headerArray.append("MATCHED ACTIONS")
            }
            rowsDataLimit = 5
        case "FAQ's":
            if self.arrayOfFaqResults.count > 0 {
                self.headerArray.append("MATCHED FAQS")
            }
        case "Pages":
            if self.arrayOfPageResults.count > 0 {
                self.headerArray.append("MATCHED PAGES")
            }
        case "Actions":
            if self.arrayOfTaskResults.count > 0 {
                self.headerArray.append("MATCHED ACTIONS")
            }
        default:
            break
        }
        collectionView.reloadData()
        self.collectionView.scrollToItem(at: IndexPath(row: indexPath.item, section: 0), at: UICollectionView.ScrollPosition.centeredHorizontally, animated: true)
        tableview.reloadData()
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5.0, left: 10.0, bottom: 5.0, right: 10.0)
    }
    
}
