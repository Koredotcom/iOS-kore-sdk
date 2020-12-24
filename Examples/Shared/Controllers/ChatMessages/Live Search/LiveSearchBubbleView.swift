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
    
    var rowsDataLimit = 2
    var isShowMore = false
    
    let yourAttributes : [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.font : UIFont(name: "HelveticaNeue-Bold", size: 15.0) as Any,
        NSAttributedString.Key.foregroundColor : themeColor]
    
    var arrayOfResults = [TemplateResultElements]()
    var arrayOfFaqResults = [TemplateResultElements]()
    var arrayOfPageResults = [TemplateResultElements]()
    var arrayOfTaskResults = [TemplateResultElements]()
    var headerArray = ["POPULAR SEARCHS","RECENT SEARCHS"]
    var expandArray:NSMutableArray = []
    var likeAndDislikeArray:NSMutableArray = []
    var checkboxIndexPath = [IndexPath]()
    
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
                self.expandArray = []
                self.likeAndDislikeArray = []
                let faqs = allItems.template?.results?.faq
                self.arrayOfFaqResults = faqs ?? []
                if self.arrayOfFaqResults.count > 0 {
                    self.headerArray.append("SUGGESTED FAQS")
                }
                for _ in 0..<self.arrayOfFaqResults.count{
                    self.expandArray.add("close")
                     self.likeAndDislikeArray.add("")
                }
                
                let pages = allItems.template?.results?.page
                self.arrayOfPageResults = pages ?? []
                if self.arrayOfPageResults.count > 0 {
                    self.headerArray.append("SUGGESTED PAGES")
                }
                let task = allItems.template?.results?.task
                self.arrayOfTaskResults = task ?? []
                if self.arrayOfTaskResults.count > 0 {
                    self.headerArray.append("SUGGESTED TASKS")
                }
                self.titleLbl.text = "Sure, please find the matched results below"
                self.tableView.reloadData()
                
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
        let headerName = headerArray[indexPath.section]
        switch headerName {
        case "SUGGESTED FAQS":
            if checkboxIndexPath.contains(indexPath) {
                return UITableView.automaticDimension
            }
            return 120
        default:
            break
        }
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let headerName = headerArray[indexPath.section]
        switch headerName {
        case "SUGGESTED FAQS":
             if checkboxIndexPath.contains(indexPath) {
                return UITableView.automaticDimension
             }
            return 120
        default:
            break
        }
        return UITableView.automaticDimension
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return headerArray.count > rowsDataLimit ? rowsDataLimit : headerArray.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let headerName = headerArray[section]
        switch headerName {
        case "SUGGESTED FAQS":
            return arrayOfFaqResults.count > rowsDataLimit ? rowsDataLimit : arrayOfFaqResults.count
        case "SUGGESTED PAGES":
            return arrayOfPageResults.count > rowsDataLimit ? rowsDataLimit : arrayOfPageResults.count
        case "SUGGESTED TASKS":
            return arrayOfTaskResults.count > rowsDataLimit ? rowsDataLimit : arrayOfTaskResults.count
        default:
            break
        }
        return 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let headerName = headerArray[indexPath.section]
        switch headerName {
        case "SUGGESTED FAQS":
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
            
            if checkboxIndexPath.contains(indexPath) {
                cell.likeAndDislikeButtonHeightConstrain.constant = CGFloat(30.0)
            }else{
                cell.likeAndDislikeButtonHeightConstrain.constant = CGFloat(0.0)
            }
            
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
            
            cell.subViewLeadingConstraint.constant = 5.0
            cell.subViewTopConstaint.constant = 5.0
            cell.subViewTrailingConstraint.constant = 5.0
            
            cell.subView.layer.shadowOpacity = 0.7
            cell.subView.layer.shadowOffset = CGSize(width: 2, height: 2)
            cell.subView.layer.shadowRadius = 8.0
            cell.subView.clipsToBounds = false
            cell.subView.layer.shadowColor = UIColor.init(red: 209/255, green: 217/255, blue: 224/255, alpha: 1.0).cgColor
            return cell
        case "SUGGESTED PAGES":
            let cell : LiveSearchPageTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: liveSearchPageCellIdentifier) as! LiveSearchPageTableViewCell
            cell.backgroundColor = UIColor.clear
            cell.selectionStyle = .none
            cell.titleLabel.textColor = .black
            cell.descriptionLabel.textColor = .dark
            cell.titleLabel?.numberOfLines = 2
            cell.descriptionLabel?.numberOfLines = 2
            let results = arrayOfPageResults[indexPath.row]
            cell.titleLabel?.text = results.title
            cell.descriptionLabel?.text = results.searchResultPreview
            if results.imageUrl == nil || results.imageUrl == ""{
                cell.profileImageView.image = UIImage(named: "placeholder_image")
            }else{
                let url = URL(string: results.imageUrl!)
                cell.profileImageView.setImageWith(url!, placeholderImage: UIImage(named: "placeholder_image"))
            }
            cell.ShareButton.addTarget(self, action: #selector(self.shareButtonAction(_:)), for: .touchUpInside)
            cell.ShareButton.tag = indexPath.row
            
            cell.subViewLeadingConstraint.constant = 5.0
            cell.subViewTopConstaint.constant = 5.0
            cell.subViewTrailingConstraint.constant = 5.0
            
            cell.subView.layer.shadowOpacity = 0.7
            cell.subView.layer.shadowOffset = CGSize(width: 2, height: 2)
            cell.subView.layer.shadowRadius = 8.0
            cell.subView.clipsToBounds = false
            cell.subView.layer.shadowColor = UIColor.init(red: 209/255, green: 217/255, blue: 224/255, alpha: 1.0).cgColor
            
            return cell
        case "SUGGESTED TASKS":
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
        case "SUGGESTED FAQS":
            if checkboxIndexPath.contains(indexPath) {
                
                checkboxIndexPath.remove(at: checkboxIndexPath.firstIndex(of: indexPath)!)
            }else{
                checkboxIndexPath.append(indexPath)
            }
            tableView.reloadData()
            NotificationCenter.default.post(name: Notification.Name(reloadTableNotification), object: nil)
        case "SUGGESTED PAGES":
            break
        case "SUGGESTED TASKS":
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
        view.backgroundColor = UIColor.init(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0)
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
        let attributeString = NSMutableAttributedString(string: "See all results",
                                                        attributes: yourAttributes)
        showMoreButton.setAttributedTitle(attributeString, for: .normal)
        
        let boolValue = section == 0 ? false : true
        showMoreButton.isHidden = boolValue
        
        let views: [String: UIView] = ["headerLabel": headerLabel, "showMoreButton": showMoreButton]
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-5-[headerLabel]-5-[showMoreButton(100)]-0-|", options:[], metrics:nil, views:views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[headerLabel]-5-|", options:[], metrics:nil, views:views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[showMoreButton]-5-|", options:[], metrics:nil, views:views))
        
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
}
