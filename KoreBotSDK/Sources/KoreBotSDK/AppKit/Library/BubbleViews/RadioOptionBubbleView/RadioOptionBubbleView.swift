//
//  RadioOptionBubbleView.swift
//  KoreBotSDKDemo
//
//  Created by Kartheek Pagidimarri on 17/10/23.
//  Copyright © 2023 Kore. All rights reserved.
//

import UIKit

class RadioOptionBubbleView : BubbleView {
    var tileBgv: UIView!
    var titleLbl: UILabel!
    let bundle = Bundle.sdkModule
    var tableView: UITableView!
    var cardView: UIView!
    let kMaxTextWidth: CGFloat = BubbleViewMaxWidth - 20.0
    let kMinTextWidth: CGFloat = 20.0
    fileprivate let cellIdentifier = "RadioOptionCell"
    let rowsDataLimit = 4
    var seletedValue = ""
    var seletedTitle = ""
    var seletedRow = 100
    let checkBtn = UIButton(frame: CGRect.zero)
    
    let yourAttributes : [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.font : UIFont(name: boldCustomFont, size: 12.0) as Any,
        NSAttributedString.Key.foregroundColor : UIColor.white]
    
    var arrayOfElements = [RadioOptions]()
    var arrayOfButtons = [ComponentItemAction]()
    var arrayOfHeaderCheck = [String]()
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
    
//    override func prepareForReuse() {
//        checkboxIndexPath = [IndexPath]()
//         arrayOfSeletedValues = [String]()
//    }
    
    override func initialize() {
        super.initialize()
        intializeCardLayout()
        self.tileBgv = UIView(frame:.zero)
        self.tileBgv.translatesAutoresizingMaskIntoConstraints = false
        self.tileBgv.layer.rasterizationScale =  UIScreen.main.scale
        self.tileBgv.layer.shouldRasterize = true
        self.tileBgv.layer.cornerRadius = 10.0
        self.cardView.addSubview(self.tileBgv)
        self.tileBgv.backgroundColor = BubbleViewLeftTint
        
        self.tableView = UITableView(frame: CGRect.zero,style:.plain)
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.backgroundColor = .clear
        self.tableView.showsHorizontalScrollIndicator = false
        self.tableView.showsVerticalScrollIndicator = true
        self.tableView.bounces = false
        self.tableView.separatorStyle = .none
        self.cardView.addSubview(self.tableView)
        self.tableView.isScrollEnabled = true
        
        self.tableView.register(Bundle.xib(named: cellIdentifier), forCellReuseIdentifier: cellIdentifier)
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        let views: [String: UIView] = ["tileBgv": tileBgv, "tableView": tableView]
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-5-[tileBgv]-5-[tableView]-0-|", options: [], metrics: nil, views: views))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[tableView]-0-|", options: [], metrics: nil, views: views))
        
        self.titleLbl = UILabel(frame: CGRect.zero)
        self.titleLbl.textColor = Common.UIColorRGB(0x484848)
        self.titleLbl.font = UIFont(name: mediumCustomFont, size: 16.0)
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
        
        let subView: [String: UIView] = ["titleLbl": titleLbl]
        self.tileBgv.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-5-[titleLbl(>=31)]-5-|", options: [], metrics: nil, views: subView))
        self.tileBgv.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[titleLbl]-10-|", options: [], metrics: nil, views: subView))
        setCornerRadiousToTitleView()
        
    }
    func setCornerRadiousToTitleView(){
        let bubbleStyle = brandingBodyDic.bubble_style
        let radius = 10.0
        let borderWidth = 0.0
        let borderColor = UIColor.clear
        if #available(iOS 11.0, *) {
            if bubbleStyle == "balloon"{
                self.tileBgv.roundCorners([.layerMaxXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMaxYCorner], radius: radius, borderColor: borderColor, borderWidth: borderWidth)
            }else if bubbleStyle == "rounded"{
                self.tileBgv.roundCorners([.layerMaxXMinYCorner, .layerMinXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMaxYCorner], radius: radius, borderColor: borderColor, borderWidth: borderWidth)
                
        }else if bubbleStyle == "rectangle"{
                self.tileBgv.roundCorners([ .layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner], radius: radius, borderColor: borderColor, borderWidth: borderWidth)
            }
        }
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
        if (components.count > 0) {
            let component: KREComponent = components.firstObject as! KREComponent
            if (component.message != nil) {
                let jsonString = component.message?.messageId
                print(jsonString!)
                
            }
            if (component.componentDesc != nil) {
                let jsonString = component.componentDesc
                let jsonObject: NSDictionary = Utilities.jsonObjectFromString(jsonString: jsonString!) as! NSDictionary
                let jsonDecoder = JSONDecoder()
                 guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject as Any , options: .prettyPrinted),
                let allItems = try? jsonDecoder.decode(Componentss.self, from: jsonData) else {
                    return
                }
                self.titleLbl.text = allItems.heading
                arrayOfElements = allItems.radioOptions ?? []
                arrayOfHeaderCheck.append("uncheck")
                arrayOfButtons = allItems.buttons ?? []
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
        
        var cellHeight : CGFloat = 0.0
        let topSpace = 30.0
        let rows = arrayOfElements.count //> rowsDataLimit ? rowsDataLimit : arrayOfElements.count
        var finalHeight: CGFloat = 0.0
        let FooterHeight = 40.0
        for i in 0..<rows {
            let row = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: IndexPath(row: i, section: 0))as! RadioOptionCell
            cellHeight = row.bounds.height
            finalHeight += cellHeight
        }
        return CGSize(width: 0.0, height: topSpace+textSize.height+finalHeight+FooterHeight)
    }
    
    
}
extension RadioOptionBubbleView: UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return arrayOfElements.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : RadioOptionCell = self.tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! RadioOptionCell
        cell.backgroundColor = UIColor.white
        cell.selectionStyle = .none
        let elements = arrayOfElements[indexPath.row]
        cell.titleLabel.text = elements.title
        
        if seletedRow == indexPath.row {
            let imgV = UIImage.init(named: "radio_check", in: bundle, compatibleWith: nil)
            cell.checkImage.image = imgV?.withRenderingMode(.alwaysTemplate)
            cell.checkImage.tintColor = themeColor
        }else{
            let imgV = UIImage.init(named: "radio_uncheck", in: bundle, compatibleWith: nil)
            cell.checkImage.image = imgV?.withRenderingMode(.alwaysTemplate)
            cell.checkImage.tintColor = themeColor
        }
        cell.bgV.layer.cornerRadius = 5.0
        cell.bgV.layer.borderWidth = 0.0
        cell.bgV.layer.borderColor = UIColor.lightGray.cgColor
        cell.bgV.clipsToBounds = true
        return cell
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let elements = arrayOfElements[indexPath.row]
        let title = "\(elements.title ?? "")"
        seletedTitle = title
        let value = "\(elements.value ?? "")"
        seletedRow = indexPath.row
        seletedValue = value
        tableView.reloadData()
        
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
           return 40
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
            let footerBtn = UIButton(frame: CGRect.zero)
        footerBtn.backgroundColor = themeColor
        footerBtn.translatesAutoresizingMaskIntoConstraints = false
        footerBtn.clipsToBounds = true
        footerBtn.layer.cornerRadius = 5
        footerBtn.layer.borderColor = themeColor.cgColor
        footerBtn.layer.borderWidth = 1
        footerBtn.setTitleColor(.white, for: .normal)
        footerBtn.setTitleColor(Common.UIColorRGB(0x999999), for: .disabled)
        footerBtn.titleLabel?.font = UIFont(name: boldCustomFont, size: 12.0)
        view.addSubview(footerBtn)
        footerBtn.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.center
        footerBtn.addTarget(self, action: #selector(self.footerBtnAction(_:)), for: .touchUpInside)
        footerBtn.setTitle("Confirm", for: .normal)
        
        let views: [String: UIView] = ["footerBtn": footerBtn]
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[footerBtn(35)]-0-|", options:[], metrics:nil, views:views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-5-[footerBtn]-5-|", options:[], metrics:nil, views:views))
        return view
    }
    @objc fileprivate func footerBtnAction(_ sender: AnyObject!) {
        if seletedValue != ""{
            self.optionsAction(seletedTitle,seletedValue)
        }
    }
}

