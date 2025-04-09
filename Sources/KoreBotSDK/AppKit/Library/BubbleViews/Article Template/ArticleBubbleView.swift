//
//  ArticleBubbleView.swift
//  KoreBotSDK
//
//  Created by Pagidimarri Kartheek on 24/02/25.
//

import UIKit

class ArticleBubbleView: BubbleView {

    let bundle = Bundle.sdkModule
    var tableView: UITableView!
    var cardView: UIView!
    let kMaxTextWidth: CGFloat = BubbleViewMaxWidth - 20.0
    let kMinTextWidth: CGFloat = 20.0
    fileprivate let listCellIdentifier = "ArticleCell"
    var rowsDataLimit = 4
    var arrayOfComponents = [ComponentElements]()
    var arrayOfButtons = [ComponentItemAction]()
    var isShowMore = false
    var showMore = false
    let yourAttributes : [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.font : UIFont(name: mediumCustomFont, size: 12.0) as Any,
        NSAttributedString.Key.foregroundColor : themeColor]
    let rowHeight = 162.0
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
        self.tableView.isScrollEnabled = false
        self.tableView.register(Bundle.xib(named: listCellIdentifier), forCellReuseIdentifier: listCellIdentifier)
        if #available(iOS 15.0, *){
            self.tableView.sectionHeaderTopPadding = 0.0
        }

        let views: [String: UIView] = ["tableView": tableView]
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-5-[tableView]-0-|", options: [], metrics: nil, views: views))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[tableView]-0-|", options: [], metrics: nil, views: views))

    }
    
    
    
    func intializeCardLayout(){
        self.cardView = UIView(frame:.zero)
        self.cardView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.cardView)
        cardView.backgroundColor =  UIColor.clear
        cardView.layer.cornerRadius = 4.0
        cardView.layer.borderWidth = 0.0
        cardView.layer.borderColor = UIColor.init(hexString: templateBoarderColor).cgColor
        cardView.clipsToBounds = true
        let cardViews: [String: UIView] = ["cardView": cardView]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[cardView]-0-|", options: [], metrics: nil, views: cardViews))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[cardView]-0-|", options: [], metrics: nil, views: cardViews))
        
    }
    
    // MARK: populate components
    override func populateComponents() {
        if (components.count > 0) {
            let component: KREComponent = components.firstObject as! KREComponent
            if (component.componentDesc != nil) {
                let jsonString = component.componentDesc
                let jsonObject: NSDictionary = Utilities.jsonObjectFromString(jsonString: jsonString!) as! NSDictionary
                let jsonDecoder = JSONDecoder()
                guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject as Any , options: .prettyPrinted),
                    let allItems = try? jsonDecoder.decode(Componentss.self, from: jsonData) else {
                                                return
                                        }
                arrayOfComponents = allItems.elements ?? []
                arrayOfButtons = allItems.buttons ?? []
                self.rowsDataLimit = (allItems.displayLimit != nil ? allItems.displayLimit : arrayOfComponents.count)!
                isShowMore = ((allItems.showmore != nil ? allItems.showmore : false) ?? false)
            }
        }
    }
    
    //MARK: View height calculation
    override var intrinsicContentSize : CGSize {
        var cellHeight : CGFloat = 0.0
        var moreButtonHeight : CGFloat = 30.0
        let rows = arrayOfComponents.count > rowsDataLimit ? rowsDataLimit : arrayOfComponents.count
        var finalHeight: CGFloat = 0.0
        finalHeight = rowHeight * Double(rows)
        
        if isShowMore{
            moreButtonHeight = 40.0
        }else{
             moreButtonHeight = 0.0
        }
        return CGSize(width: 0.0, height: finalHeight+moreButtonHeight)
    }

    @objc fileprivate func showMoreButtonAction(_ sender: AnyObject!) {
        if (isShowMore) {
            let component: KREComponent = components.firstObject as! KREComponent
            if (component.componentDesc != nil) {
                let jsonString = component.componentDesc
                NotificationCenter.default.post(name: Notification.Name(showArticleTemplateNotification), object: jsonString)
            }
        }
    }
    
    @objc fileprivate func showArticleBtnAction (_ sender: UIButton!) {
        let elements = arrayOfComponents[sender.tag]
        if elements.elementButton?.type != nil {
            if elements.elementButton?.type == "postback"{
                self.optionsAction?(elements.elementButton?.title,elements.elementButton?.payload ?? elements.elementButton?.title)
            }else{
                if elements.elementButton?.url != nil {
                    self.linkAction?(elements.elementButton?.url)
                }
            }
        }
    }
}

extension ArticleBubbleView: UITableViewDelegate, UITableViewDataSource{
    //ArticleCell
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return rowHeight
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return rowHeight
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return arrayOfComponents.count > rowsDataLimit ? rowsDataLimit : arrayOfComponents.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : ArticleCell = self.tableView.dequeueReusableCell(withIdentifier: listCellIdentifier) as! ArticleCell
        cell.backgroundColor = UIColor.clear
        cell.selectionStyle = .none
        cell.bgView.backgroundColor = .white
        cell.bgView.layer.cornerRadius = 2.0
        cell.bgView.layer.borderWidth = 1.0
        cell.bgView.layer.borderColor = UIColor.lightGray.cgColor
        cell.bgView.clipsToBounds = true
        
        let elements = arrayOfComponents[indexPath.row]
        cell.titleLbl.text = elements.title
        cell.descLbl.text = elements.descr
        cell.createdLbl.text = elements.createdOn
        cell.updatedLbl.text = elements.updatedOn
        if let iconImg = elements.iconStr{
            if iconImg.contains("base64") || iconImg.contains("data:image"){
                let image = Utilities.base64ToImage(base64String: iconImg)
                cell.imageV.image = image
            }else{
                if let url = URL(string: iconImg){
                    cell.imageV.af.setImage(withURL: url, placeholderImage: UIImage.init(named: "placeholder_image", in: bundle, compatibleWith: nil))
                }
            }
        }
        
        cell.showArticleBtn.setTitle(elements.elementButton?.title, for: .normal)
        cell.showArticleBtn.titleLabel?.font = UIFont(name: mediumCustomFont, size: 12.0)
        cell.showArticleBtn.setTitleColor(themeColor, for: .normal)
        cell.showArticleBtn.addTarget(self, action: #selector(self.showArticleBtnAction(_:)), for: .touchUpInside)
        cell.showArticleBtn.tag = indexPath.row
        
        let article = UIImage(named: "article", in: bundle, compatibleWith: nil)
        let tintedarticleImage = article?.withRenderingMode(.alwaysTemplate)
        cell.showArticleBtn.setImage(tintedarticleImage, for: .normal)
        cell.showArticleBtn.tintColor = themeColor
        return cell
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        
        if arrayOfComponents.count > rowsDataLimit {
            let showMoreButton = UIButton(frame: CGRect.zero)
            showMoreButton.backgroundColor = .clear
            showMoreButton.translatesAutoresizingMaskIntoConstraints = false
            showMoreButton.setTitleColor(Common.UIColorRGB(0x999999), for: .disabled)
            view.addSubview(showMoreButton)
            showMoreButton.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.center
            showMoreButton.addTarget(self, action: #selector(self.showMoreButtonAction(_:)), for: .touchUpInside)
             var btnTitle: String?
            if self.isShowMore{
                if arrayOfButtons.count>0{
                  btnTitle = arrayOfButtons[0].title!
                }else{
                     btnTitle = "Show More"
                }
            }
            let attributeString = NSMutableAttributedString(string: btnTitle ?? "See More",
                                                             attributes: yourAttributes)
            showMoreButton.setAttributedTitle(attributeString, for: .normal)
            showMoreButton.layer.cornerRadius = 5
            showMoreButton.layer.borderWidth = 1
            showMoreButton.layer.borderColor = themeColor.cgColor
            showMoreButton.clipsToBounds = true
            
            let views: [String: UIView] = ["showMoreButton": showMoreButton]
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[showMoreButton(30)]-0-|", options:[], metrics:nil, views:views))
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[showMoreButton(100)]-0-|", options:[], metrics:nil, views:views))
        }
        return view
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return self.isShowMore ? 40 : 0
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let elements = arrayOfComponents[indexPath.row]
//        if elements.elementButton?.type != nil {
//            if elements.elementButton?.type == "postback"{
//                self.optionsAction?(elements.elementButton?.title,elements.elementButton?.payload ?? elements.elementButton?.title)
//            }else{
//                if elements.elementButton?.url != nil {
//                    self.linkAction?(elements.elementButton?.url)
//                }
//            }
//        }
    }

}
