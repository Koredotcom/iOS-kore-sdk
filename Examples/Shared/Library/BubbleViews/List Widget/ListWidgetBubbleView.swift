//
//  ListWidgetBubbleView.swift
//  KoreBotSDKDemo
//
//  Created by Kartheek Pagidimarri on 9/10/20.
//  Copyright © 2020 Kore. All rights reserved.
//

import UIKit
import KoreBotSDK

class ListWidgetBubbleView: BubbleView {
    static let elementsLimit: Int = 4
    
    var titleLbl: UILabel!
    var tableView: UITableView!
    var cardView: UIView!
    let kMaxTextWidth: CGFloat = BubbleViewMaxWidth - 20.0
    let kMinTextWidth: CGFloat = 20.0
    let rowsDataLimit = 3
    var showMoreButton: UIButton!
    
    var headerTitle: String?
    var headerDescription: String?
    var headertype: String?
    var headerUrl: String?
    
    let yourAttributes : [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.font : UIFont(name: "HelveticaNeue-Bold", size: 15.0) as Any,
        NSAttributedString.Key.foregroundColor : UIColor.blue,
        NSAttributedString.Key.underlineStyle : NSUnderlineStyle.single.rawValue]
    
    var arrayOfElements = [KREListItem]()
    let listItemViewCellIdentifier = "KREListItemViewCell"
    
    var urlLabel: KREAttributedLabel!
    var onChange: ((_ reload: Bool) -> ())!
    
    var showMore = false
    public var optionsAction: ((_ text: String?, _ payload: String?) -> Void)!
    public var linkAction: ((_ text: String?) -> Void)!
    
    override func applyBubbleMask() {
        //nothing to put here
        if(self.maskLayer == nil){
            self.maskLayer = CAShapeLayer()
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
        
        self.tableView = UITableView(frame: CGRect.zero,style:.plain)
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.backgroundColor = .clear
        self.tableView.showsHorizontalScrollIndicator = false
        self.tableView.showsVerticalScrollIndicator = true
        self.tableView.bounces = false
        self.tableView.separatorStyle = .singleLine
        self.cardView.addSubview(self.tableView)
        self.tableView.isScrollEnabled = true
        self.tableView.register(KREListItemViewCell.self, forCellReuseIdentifier: listItemViewCellIdentifier)
        
        let views: [String: UIView] = ["tableView": tableView]
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-5-[tableView]-5-|", options: [], metrics: nil, views: views))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[tableView]-0-|", options: [], metrics: nil, views: views))
        NotificationCenter.default.post(name: Notification.Name(reloadTableNotification), object: nil)
        
    }
    
    func intializeCardLayout(){
        self.cardView = UIView(frame:.zero)
        self.cardView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.cardView)
        cardView.layer.rasterizationScale =  UIScreen.main.scale
        cardView.layer.shadowColor = UIColor(red: 232/255, green: 232/255, blue: 230/255, alpha: 1).cgColor
        cardView.layer.shadowOpacity = 1
        cardView.layer.shadowOffset =  CGSize(width: 0.0, height: -3.0)
        cardView.layer.shadowRadius = 6.0
        cardView.layer.cornerRadius = 5.0
        cardView.layer.shouldRasterize = true
        cardView.backgroundColor =  UIColor.white
        
        
        showMoreButton = UIButton(frame: CGRect.zero)
        showMoreButton.backgroundColor = .clear
        showMoreButton.translatesAutoresizingMaskIntoConstraints = false
        showMoreButton.clipsToBounds = true
        showMoreButton.layer.cornerRadius = 5
        showMoreButton.setTitleColor(.blue, for: .normal)
        showMoreButton.setTitleColor(Common.UIColorRGB(0x999999), for: .disabled)
        showMoreButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 14.0)!
        self.addSubview(showMoreButton)
        showMoreButton.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.right
        showMoreButton.addTarget(self, action: #selector(self.showMoreButtonAction(_:)), for: .touchUpInside)
        let btnTitle: String = "Show More"
        let attributeString = NSMutableAttributedString(string: btnTitle,
                                                        attributes: yourAttributes)
        showMoreButton.setAttributedTitle(attributeString, for: .normal)
        
        
        let cardViews: [String: UIView] = ["cardView": cardView, "showMoreButton":showMoreButton]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[cardView]-0-[showMoreButton(30)]-0-|", options: [], metrics: nil, views: cardViews))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[cardView]-0-|", options: [], metrics: nil, views: cardViews))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[showMoreButton]-0-|", options: [], metrics: nil, views: cardViews))
        
    }
    
    // MARK: populate components
    override func populateComponents() {
        if (components.count > 0) {
            let component: KREComponent = components.firstObject as! KREComponent
            if (component.componentDesc != nil) {
                let jsonString = component.componentDesc
                let jsonObject: NSDictionary = Utilities.jsonObjectFromString(jsonString: jsonString!) as! NSDictionary
                let jsonDecoder = JSONDecoder()
                guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject["elements"] as Any , options: .prettyPrinted),
                    let allItems = try? jsonDecoder.decode([KREListItem].self, from: jsonData) else {
                        return
                }
                 headerTitle = jsonObject["title"] as? String
                 headerDescription = jsonObject["description"] as? String
                 //headertype = ((jsonObject["headerOptions"] as AnyObject) .object(forKey: "type") as? String)
                 //headerUrl = (((jsonObject["headerOptions"] as AnyObject) .object(forKey: "url") as AnyObject) .object(forKey: "link") as? String)
                
                arrayOfElements = allItems
                self.tableView.reloadData()
            }
        }
    }
    
    //MARK: View height calculation
    override var intrinsicContentSize : CGSize {
        var cellHeight : CGFloat = 0.0
        let rows =  arrayOfElements.count > rowsDataLimit ? rowsDataLimit : arrayOfElements.count
        var moreButtonHeight : CGFloat = 30
        var finalHeight: CGFloat = 0.0
        let headerHeight: CGFloat = 50.0
        for i in 0..<rows {
            let row = tableView.dequeueReusableCell(withIdentifier: listItemViewCellIdentifier, for: IndexPath(row: i, section: 0))as! KREListItemViewCell
            cellHeight = row.bounds.height
            finalHeight += cellHeight
        }
        moreButtonHeight = arrayOfElements.count > rowsDataLimit ? 30 : 0
        return CGSize(width: 0.0, height: 10+tableView.contentSize.height+moreButtonHeight+headerHeight)
    }
    
    // MARK: -
    func updateSubviews() {
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
}
// MARK: - UITableViewDataSource, UITableViewDelegate
extension ListWidgetBubbleView: UITableViewDataSource, UITableViewDelegate {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayOfElements.count > rowsDataLimit ? rowsDataLimit : arrayOfElements.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = listItemViewCellIdentifier
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        if let cell = cell as? KREListItemViewCell, let listItem = arrayOfElements[indexPath.row] as? KREListItem {
            let listView = cell.templateView
            listView.populateListItemView(listItem)
            listView.buttonActionHandler = { [weak self] (action) in
                self?.optionsAction(action?.title, action?.payload)
            }
//            listView.menuActionHandler = { [weak self] (actions) in
//               // self?.delegate?.populateActions(actions, in: self?.widget, in: self?.panelItem)
//            }
            listView.revealActionHandler = { [weak self] in
                self?.updateSubviews()
            }
        }
        return cell
    }
   
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        
        let subView = UIView()
        subView.backgroundColor = .clear
        subView.translatesAutoresizingMaskIntoConstraints = false
        subView.layer.cornerRadius = 5.0
        subView.clipsToBounds = true
        view.addSubview(subView)
        
        let headerLabel = UILabel(frame: .zero)
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.textAlignment = .left
        headerLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 15.0)
        headerLabel.font = headerLabel.font.withSize(15.0)

        headerLabel.textColor = .black
        headerLabel.text = headerTitle
        subView.addSubview(headerLabel)
        
        let headerDescLabel = UILabel(frame: .zero)
        headerDescLabel.translatesAutoresizingMaskIntoConstraints = false
        headerDescLabel.textAlignment = .left
        headerDescLabel.font = UIFont(name: "HelveticaNeue", size: 15.0)
        headerDescLabel.font = headerDescLabel.font.withSize(12.0)
        headerDescLabel.textColor = .black
        headerDescLabel.text = headerDescription
        subView.addSubview(headerDescLabel)
        
        urlLabel = KREAttributedLabel(frame: CGRect.zero)
        urlLabel.textColor = Common.UIColorRGB(0x484848)
        urlLabel.mentionTextColor = Common.UIColorRGB(0x8ac85a)
        urlLabel.hashtagTextColor = Common.UIColorRGB(0x8ac85a)
        urlLabel.linkTextColor = Common.UIColorRGB(0x0076FF)
        urlLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 16.0)
        urlLabel.numberOfLines = 0
        urlLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        urlLabel.isUserInteractionEnabled = true
        urlLabel.contentMode = UIView.ContentMode.topLeft
        
        var urltext = ""
        if headertype == "url" {
            urltext = headerUrl ?? ""
        }
        let htmlStrippedString = KREUtilities.getHTMLStrippedString(from: urltext)
        let parsedString:String = KREUtilities.formatHTMLEscapedString(htmlStrippedString);
        self.urlLabel.setHTMLString(parsedString, withWidth: kMaxTextWidth)
        urlLabel.translatesAutoresizingMaskIntoConstraints = false
        subView.addSubview(urlLabel)
        urlLabel.imageDetectionBlock = {[weak self] (reload) in
            self?.onChange(reload)
        }
        self.textLinkDetection(textLabel: urlLabel)
        
       let underlineLabel = UILabel(frame: CGRect.zero)
        underlineLabel.translatesAutoresizingMaskIntoConstraints = false
        underlineLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 16.0)
        underlineLabel.backgroundColor = .lightGreyBlue
        underlineLabel.numberOfLines = 0
        underlineLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        underlineLabel.isUserInteractionEnabled = true
        underlineLabel.contentMode = UIView.ContentMode.topLeft
        subView.addSubview(underlineLabel)
       
        
        let views: [String: UIView] = ["headerLabel": headerLabel, "headerDescLabel":headerDescLabel, "urlLabel":urlLabel, "underlineLabel": underlineLabel]
        subView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[headerLabel]", options:[], metrics:nil, views:views))
        subView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[headerDescLabel]", options:[], metrics:nil, views:views))
         subView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[underlineLabel]-0-|", options:[], metrics:nil, views:views))
        subView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-5-[headerLabel]-0-[headerDescLabel]-5-|", options:[], metrics:nil, views:views))
        subView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[underlineLabel(1)]-0-|", options:[], metrics:nil, views:views))
        
        
        subView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[urlLabel]-10-|", options:[], metrics:nil, views:views))
        subView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-5-[urlLabel]-5-|", options:[], metrics:nil, views:views))
        
        
        let subViews: [String: UIView] = ["subView": subView]
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[subView]-0-|", options:[], metrics:nil, views:subViews))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[subView]-0-|", options:[], metrics:nil, views:subViews))
    
        return view
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let listItem = arrayOfElements[indexPath.row] as? KREListItem else {
            return
        }

        if let action = listItem.defaultAction {
            if action.payload != nil{
                self.optionsAction(action.title ?? action.payload, action.payload)
            }
             
        }
    }
    
    @objc fileprivate func showMoreButtonAction(_ sender: AnyObject!) {
        let component: KREComponent = components.firstObject as! KREComponent
            if (component.componentDesc != nil) {
                let jsonString = component.componentDesc
                NotificationCenter.default.post(name: Notification.Name(showListWidgetViewTemplateNotification), object: jsonString)
            }
    }
    
    func textLinkDetection(textLabel:KREAttributedLabel) {
        textLabel.detectionBlock = {(hotword, string) in
            switch hotword {
            case KREAttributedHotWordLink:
                self.linkAction(string!)
                break
            default:
                break
            }
        }
    }
}
