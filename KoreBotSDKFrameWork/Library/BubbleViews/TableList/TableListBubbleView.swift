//
//  TableListBubbleView.swift
//  KoreBotSDKDemo
//
//  Created by Kartheek Pagidimarri on 7/15/20.
//  Copyright © 2020 Kore. All rights reserved.
//

import UIKit

class TableListBubbleView: BubbleView {
    static let elementsLimit: Int = 4
    
    //var tileBgv: UIView!
   // var titleLbl: UILabel!
    var tableView: UITableView!
    var cardView: UIView!
    let kMaxTextWidth: CGFloat = BubbleViewMaxWidth - 20.0
    let kMinTextWidth: CGFloat = 20.0
    fileprivate let listCellIdentifier = "NewListTableViewCell"
    let rowsDataLimit = 4
    
    let yourAttributes : [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.font : UIFont(name: "Gilroy-Bold", size: 15.0) as Any,
        NSAttributedString.Key.foregroundColor : UIColor.blue,
        NSAttributedString.Key.underlineStyle : NSUnderlineStyle.single.rawValue]
 
    var arrayOfComponents = [TableListElements]()
    var arrayOfButtons = [ComponentItemAction]()
    
    var showMore = false
    public var optionsAction: ((_ text: String?, _ payload: String?) -> Void)!
    public var linkAction: ((_ text: String?) -> Void)!
    override func applyBubbleMask() {
        //nothing to put here
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
        self.tableView.backgroundColor = .white
        self.tableView.showsHorizontalScrollIndicator = false
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.bounces = false
        self.tableView.separatorStyle = .none
        self.cardView.addSubview(self.tableView)
        self.tableView.isScrollEnabled = false
        self.tableView.register(UINib(nibName: listCellIdentifier, bundle: frameworkBundle), forCellReuseIdentifier: listCellIdentifier)

        let views: [String: UIView] = ["tableView": tableView]
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[tableView]-10-|", options: [], metrics: nil, views: views))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[tableView]-10-|", options: [], metrics: nil, views: views))

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
        cardView.layer.shouldRasterize = true
        cardView.backgroundColor =  UIColor.white
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
                    let allItems = try? jsonDecoder.decode(TableListData.self, from: jsonData) else {
                        return
                    }
                arrayOfComponents = allItems.elements ?? []
                self.tableView.reloadData()
            }
        }
    }
    
    //MARK: View height calculation
    override var intrinsicContentSize : CGSize {
        var cellHeight : CGFloat = 0.0
        let moreButtonHeight : CGFloat = 00.0
        var headerSectionHeight : CGFloat = 0.0
        var finalHeight: CGFloat = 0.0
        
        let sections = arrayOfComponents.count
        for z in 0..<sections {
             headerSectionHeight += 50.0
            let rows = arrayOfComponents[z].rowItems?.count ?? 0
            for i in 0..<rows {
                let row = tableView.dequeueReusableCell(withIdentifier: listCellIdentifier, for: IndexPath(row: i, section: 0))as! NewListTableViewCell
                        cellHeight = row.bounds.height
                        finalHeight += cellHeight
                }
        }
        return CGSize(width: 0.0, height: finalHeight+moreButtonHeight+15+headerSectionHeight)
    }
    
    @objc fileprivate func showMoreButtonAction(_ sender: AnyObject!) {
        if (arrayOfButtons.count>0) {
            let component: KREComponent = components.firstObject as! KREComponent
            if (component.componentDesc != nil) {
                let jsonString = component.componentDesc
                NotificationCenter.default.post(name: Notification.Name(showListViewTemplateNotification), object: jsonString)
            }
        }
    }
}
extension TableListBubbleView: UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return arrayOfComponents.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return arrayOfComponents[section].rowItems?.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : NewListTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: listCellIdentifier) as! NewListTableViewCell
        cell.backgroundColor = UIColor.clear
        cell.selectionStyle = .none
        let elements = arrayOfComponents[indexPath.section].rowItems?[indexPath.row]
        if elements?.title?.image?.image_src == nil{
            cell.imageViewWidthConstraint.constant = 0.0
        }else{
            cell.imageViewWidthConstraint.constant = 40.0
            cell.imageViewHeightConstraint.constant = 40.0
            let url = URL(string: (elements?.title?.image?.image_src)!)
            cell.imgView.setImageWith(url!, placeholderImage: UIImage(named: "placeholder_image"))
            
            if elements?.title?.image?.radius != nil {
                //cell.imgView.layer.cornerRadius = CGFloat((elements?.title?.image?.radius)!)
                cell.imageViewWidthConstraint.constant = CGFloat((elements?.title?.image?.radius)!) * 2
                cell.imageViewHeightConstraint.constant = CGFloat((elements?.title?.image?.radius)!) * 2
            }
        }
        
        if elements?.bgcolor != nil{
            cell.bgView.backgroundColor = UIColor.init(hexString: (elements?.bgcolor)!)
        }
        cell.bgView.layer.borderColor = UIColor.clear.cgColor
        if elements?.title?.type == "text"{
            cell.titleLabel.text = elements?.title?.text?.title
            cell.subTitleLabel.text = elements?.title?.text?.subtitle
        }else{
            cell.titleLabel.text = elements?.title?.url?.title
            cell.subTitleLabel.text = elements?.title?.url?.subtitle
        }
        
        if elements?.value?.type == "text"{
            cell.priceLbl.text = elements?.value?.text ??  elements?.value?.url?.title
        }else{
            cell.priceLbl.text =  elements?.value?.url?.title
        }
        
        if elements?.title?.rowColor != nil{
        let hexString: String = (elements?.title?.rowColor!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))!
           if (hexString.hasPrefix("#")) {
                 cell.titleLabel.textColor = UIColor.init(hexString: (elements?.title?.rowColor)!)
                 cell.subTitleLabel.textColor = UIColor.init(hexString: (elements?.title?.rowColor)!)
                 cell.priceLbl.textColor =   UIColor.init(hexString: (elements?.title?.rowColor)!)
            }else{
                    let covertColor = UIColor.colorWith(name: (elements?.title?.rowColor) ?? "black")
                    cell.titleLabel.textColor = covertColor
                    cell.subTitleLabel.textColor = covertColor
                    cell.priceLbl.textColor =   covertColor
                }
        }
        
        if elements?.value?.layout?.color != nil{
            let hexString: String = (elements?.value?.layout?.color!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))!
            if (hexString.hasPrefix("#")) {
                cell.priceLbl.textColor =   UIColor.init(hexString: (elements?.value?.layout?.color)!)
            }else{
                let covertColor = UIColor.colorWith(name: (elements?.value?.layout?.color) ?? "black")
                cell.priceLbl.textColor =  covertColor
            }
        }
        
        if elements?.action == nil {
            let underlineString = cell.titleLabel.text ?? ""
            let attributedString = NSMutableAttributedString.init(string: underlineString)
            // Add Underline Style Attribute.
            attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: 1, range:
                               NSRange.init(location: 0, length: attributedString.length));
            cell.titleLabel.attributedText = attributedString
            let tap = UITapGestureRecognizer(target: self, action: #selector(TableListBubbleView.tapFunction))
            cell.titleLabel.isUserInteractionEnabled = true
            cell.titleLabel.tag = indexPath.row
            cell.titleLabel.addGestureRecognizer(tap)
        }else{
            cell.titleLabel.isUserInteractionEnabled = false
        }
        return cell
        
    }
    @objc func tapFunction(sender:UITapGestureRecognizer) {
        let elements = arrayOfComponents[0].rowItems?[sender.view!.tag]
        if elements?.action == nil {
            if elements?.title?.type == "text"{
                self.optionsAction(elements?.title?.text?.title,elements?.title?.text?.payload ?? elements?.title?.text?.title)
            }else{
                self.linkAction(elements?.title?.url?.link)
            }
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let elements = arrayOfComponents[indexPath.section].rowItems?[indexPath.row]
        if elements?.action?.type != nil {
            if elements?.action?.type == "postback"{
                self.optionsAction(elements?.action?.title,elements?.action?.payload ?? elements?.action?.title)
            }else{
                if elements?.action?.url != nil {
                    self.linkAction(elements?.action?.url)
                }
            }
        }
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        
        let subView = UIView()
        subView.backgroundColor = UIColor.init(red: 242.0/255.0, green: 243.0/255.0, blue: 245.0/255.0, alpha: 1.0)
        subView.translatesAutoresizingMaskIntoConstraints = false
        subView.layer.cornerRadius = 5.0
        subView.clipsToBounds = true
        view.addSubview(subView)
        
        let headerLabel = UILabel(frame: .zero)
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.textAlignment = .left
        headerLabel.font = UIFont(name: "Gilroy-Bold", size: 15.0)
        headerLabel.font = headerLabel.font.withSize(15.0)

        headerLabel.textColor = .black
        headerLabel.text =  arrayOfComponents[section].sectionHeader ?? ""
        subView.addSubview(headerLabel)
        
        let headerDescLabel = UILabel(frame: .zero)
        headerDescLabel.translatesAutoresizingMaskIntoConstraints = false
        headerDescLabel.textAlignment = .left
        headerDescLabel.font = UIFont(name: "Gilroy-Bold", size: 15.0)
        headerDescLabel.font = headerDescLabel.font.withSize(15.0)
        headerDescLabel.textColor = .black
        headerDescLabel.text =  arrayOfComponents[section].sectionHeaderDesc ?? ""
        subView.addSubview(headerDescLabel)
        
        let views: [String: UIView] = ["headerLabel": headerLabel, "headerDescLabel":headerDescLabel]
        subView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[headerLabel]-[headerDescLabel]-15-|", options:[], metrics:nil, views:views))
        subView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[headerLabel]-10-|", options:[], metrics:nil, views:views))
        subView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[headerDescLabel]-10-|", options:[], metrics:nil, views:views))
        
        let subViews: [String: UIView] = ["subView": subView]
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[subView]-0-|", options:[], metrics:nil, views:subViews))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[subView]-5-|", options:[], metrics:nil, views:subViews))
    
        return view
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        
        if arrayOfComponents.count > rowsDataLimit {
            let showMoreButton = UIButton(frame: CGRect.zero)
            showMoreButton.backgroundColor = .clear
            showMoreButton.translatesAutoresizingMaskIntoConstraints = false
            showMoreButton.clipsToBounds = true
            showMoreButton.layer.cornerRadius = 5
            showMoreButton.setTitleColor(.blue, for: .normal)
            showMoreButton.setTitleColor(Common.UIColorRGB(0x999999), for: .disabled)
            showMoreButton.titleLabel?.font = UIFont(name: "Gilroy-Bold", size: 14.0)!
            view.addSubview(showMoreButton)
            showMoreButton.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.center
            showMoreButton.addTarget(self, action: #selector(self.showMoreButtonAction(_:)), for: .touchUpInside)
            if arrayOfButtons.count>0{
                let btnTitle: String = arrayOfButtons[0].title!
                let attributeString = NSMutableAttributedString(string: btnTitle,
                                                                attributes: yourAttributes)
                showMoreButton.setAttributedTitle(attributeString, for: .normal)
            }
            let views: [String: UIView] = ["showMoreButton": showMoreButton]
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[showMoreButton(30)]-0-|", options:[], metrics:nil, views:views))
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[showMoreButton]-0-|", options:[], metrics:nil, views:views))
        }
        return view
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return arrayOfComponents.count > rowsDataLimit ? 0 : 0
    }
    
}
extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
    
    static func colorWith(name:String) -> UIColor? {
        let selector = Selector("\(name)Color")
        if UIColor.self.responds(to: selector) {
            let color = UIColor.self.perform(selector).takeUnretainedValue()
            return (color as? UIColor)
        } else {
            return nil
        }
    }
}

