//
//  TableBubbleView.swift
//  KoreBotSDKDemo
//
//  Created by Anoop Dhiman on 09/10/17.
//  Copyright © 2017 Kore. All rights reserved.
//

import UIKit

struct Header {
    var title: String = ""
    var alignment: NSTextAlignment = .left
    var percentage: Int = 0
}

class TableData {
    var headers: Array<Header> = Array<Header>()
    var rows: Array<Array<String>> = Array<Array<String>>()
    var columns: Array<Array<String>> = Array<Array<String>>()
    var elements:Array<Dictionary<String, Any>> = Array<Dictionary<String, Any>>()
    var elementsStyle: Array<String> = Array<String>()
    var tableDesign:String!
    
    convenience init(_ data: Dictionary<String, Any>){
        self.init()
        guard let columns = data["columns"] as? Array<Array<String>> else { return }
        guard let locelements = data["elements"] as? Array<Dictionary<String, Any>> else { return }
        elements = locelements
        self.columns = columns
        
        tableDesign = data["table_design"] != nil ? data["table_design"] as? String : "responsive"
        var percentage: Int = Int(floor(Double(100/columns.count)))
        for column in columns {
            let title = column[0]
            var alignment: NSTextAlignment = .left
            if column.count > 1, let align = column[1] as String? {
                if align == "right" {
                    alignment = .right
                } else if align == "center" {
                    alignment = .center
                }
            }
            if column.count > 2, let perc = column[2] as String? {
                percentage = Int(perc)!
            }
            headers.append(Header(title: title.uppercased(), alignment: alignment, percentage: percentage))
        }
        for element in elements {
            let values = element["Values"] as! Array<Any>
            let elementStyles = element["elementStyles"] as? Dictionary<String, Any>
            let elementBgColor = elementStyles?["background"] as? String
            var row = Array<String>()
            for value in values {
                //                let val = value as? String ?? ""
                //                row.append(val)
                if let val = value as? String {
                    row.append(val)
                } else if let val = value as? NSNumber {
                    row.append(val.stringValue)
                } else {
                    row.append("")
                }
            }
            elementsStyle.append(elementBgColor ?? "#FFFFFF")
            rows.append(row)
        }
        print(rows)
        print(headers)
        print(elementsStyle)
    }
}

extension String {
    var isInt: Bool {
        return Int(self) != nil
    }
}

class TableBubbleView: BubbleView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    var collectionView: UICollectionView!
    var showMoreButton: UIButton!
    var cardView: UIView!
    var uunderLineLbl: UILabel!
    
    let customCellIdentifier = "CustomCellIdentifier"
    var data: TableData = TableData()
    var rowsDataLimit = 5
    var rows: Array<Array<String>> = Array<Array<String>>()
    var itemWidth:CGFloat = 0.0
    var count = 0
    
    var tileBgv: UIView!
    var CollectionVBgv: UIView!
    var titleLbl: UILabel!
    let kMaxTextWidth: CGFloat = BubbleViewMaxWidth - 32.0
    var isExpandTableview = false
    
    var showMore = false
    
    override func applyBubbleMask() {
        //nothing to put here
    }
    
    override var tailPosition: BubbleMaskTailPosition! {
        didSet {
            self.backgroundColor = .clear
        }
    }
    func intializeCardLayout(){
        self.cardView = UIView(frame:.zero)
        self.cardView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.cardView)
        cardView.layer.rasterizationScale =  UIScreen.main.scale
        cardView.layer.shadowColor = UIColor.clear.cgColor//UIColor(red: 232/255, green: 232/255, blue: 230/255, alpha: 1).cgColor
        cardView.layer.shadowOpacity = 1
        cardView.layer.shadowOffset =  CGSize(width: 0.0, height: -3.0)
        cardView.layer.shadowRadius = 6.0
        cardView.layer.shouldRasterize = true
        cardView.layer.cornerRadius = 10.0
        cardView.backgroundColor =  .clear //BubbleViewLeftTint
        let cardViews: [String: UIView] = ["cardView": cardView]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[cardView]-0-|", options: [], metrics: nil, views: cardViews))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[cardView]-15-|", options: [], metrics: nil, views: cardViews))
    }
    
    override func initialize() {
        super.initialize()
        isExpandTableview = false
        
        intializeCardLayout()
        
        self.tileBgv = UIView(frame:.zero)
        self.tileBgv.translatesAutoresizingMaskIntoConstraints = false
        self.tileBgv.layer.rasterizationScale =  UIScreen.main.scale
        self.tileBgv.layer.shouldRasterize = true
        self.tileBgv.layer.cornerRadius = 10.0
        self.tileBgv.layer.borderColor = UIColor.lightGray.cgColor
        self.tileBgv.clipsToBounds = true
        self.tileBgv.layer.borderWidth = 0.0
        self.cardView.addSubview(self.tileBgv)
        self.tileBgv.backgroundColor = BubbleViewLeftTint
        
        self.CollectionVBgv = UIView(frame:.zero)
        self.CollectionVBgv.translatesAutoresizingMaskIntoConstraints = false
        self.CollectionVBgv.layer.rasterizationScale =  UIScreen.main.scale
        self.CollectionVBgv.layer.shouldRasterize = true
        self.CollectionVBgv.layer.cornerRadius = 10.0
        self.CollectionVBgv.layer.borderColor = UIColor.lightGray.cgColor
        self.CollectionVBgv.clipsToBounds = true
        self.CollectionVBgv.layer.borderWidth = 0.0
        self.cardView.addSubview(self.CollectionVBgv)
        self.CollectionVBgv.backgroundColor = BubbleViewLeftTint
        
        let views: [String: UIView] = ["tileBgv": tileBgv, "CollectionVBgv": CollectionVBgv]
        
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[tileBgv]-5-[CollectionVBgv]-0-|", options: [], metrics: nil, views: views))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[CollectionVBgv]-0-|", options: [], metrics: nil, views: views))
        
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[tileBgv]-0-|", options: [], metrics: nil, views: views))
        
        let collectionViewLayout = CustomCollectionViewLayout()
        self.collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: collectionViewLayout)
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.backgroundColor = .clear
        self.collectionView.showsHorizontalScrollIndicator = false
        self.collectionView.showsVerticalScrollIndicator = false
        self.collectionView.bounces = false
        self.collectionView.isScrollEnabled = true
        self.CollectionVBgv.addSubview(self.collectionView)
        if let xib = Bundle.xib(named: "CustomCollectionViewCell") {
            self.collectionView.register(xib, forCellWithReuseIdentifier: customCellIdentifier)
        }
        
        self.uunderLineLbl = UILabel(frame: CGRect.zero)
        self.uunderLineLbl.textColor = .black
        self.uunderLineLbl.font = UIFont(name: "HelveticaNeue-Regular", size: 12.0)
        self.uunderLineLbl.numberOfLines = 1
        self.uunderLineLbl.lineBreakMode = NSLineBreakMode.byWordWrapping
        self.uunderLineLbl.isUserInteractionEnabled = true
        self.uunderLineLbl.contentMode = UIView.ContentMode.topLeft
        self.uunderLineLbl.translatesAutoresizingMaskIntoConstraints = false
        self.CollectionVBgv.addSubview(self.uunderLineLbl)
        self.uunderLineLbl.adjustsFontSizeToFitWidth = true
        self.uunderLineLbl.backgroundColor = .black
        self.uunderLineLbl.layer.cornerRadius = 6.0
        self.uunderLineLbl.clipsToBounds = true
        self.uunderLineLbl.sizeToFit()
        
        self.showMoreButton = UIButton.init(frame: CGRect.zero)
        self.showMoreButton.setTitle("Show More", for: .normal)
        self.showMoreButton.translatesAutoresizingMaskIntoConstraints = false
        self.showMoreButton.setTitleColor(themeColor, for: .normal)
        self.showMoreButton.titleLabel?.font = UIFont(name: boldCustomFont, size: 12.0)
        self.showMoreButton.addTarget(self, action: #selector(self.showMoreButtonAction(_:)), for: .touchUpInside)
        self.showMoreButton.isHidden = false
        self.showMoreButton.clipsToBounds = true
        self.CollectionVBgv.addSubview(self.showMoreButton)
        showMoreButton.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.right
        
        let collectionViews: [String: UIView] = ["collectionView": collectionView,"uunderLineLbl": uunderLineLbl,"showMoreButton": showMoreButton]
        
        self.CollectionVBgv.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-50-[uunderLineLbl(1)]", options: [], metrics: nil, views: collectionViews))
        self.CollectionVBgv.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[uunderLineLbl]-15-|", options: [], metrics: nil, views: collectionViews))
        
        self.CollectionVBgv.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[collectionView]-0-|", options: [], metrics: nil, views: collectionViews))
        self.CollectionVBgv.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[collectionView]-15-|", options: [], metrics: nil, views: collectionViews))
        
        self.CollectionVBgv.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[showMoreButton(0.0)]-5-|", options: [], metrics: nil, views: collectionViews))
        self.CollectionVBgv.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[showMoreButton(130)]-25-|", options: [], metrics: nil, views: collectionViews))
        
        
        
        self.titleLbl = UILabel(frame: CGRect.zero)
        self.titleLbl.textColor = BubbleViewBotChatTextColor
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
        
        self.tileBgv.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[titleLbl]-16-|", options:[], metrics:nil, views:subView))
        setCornerRadiousToTitleView()
    }
    
    func setCornerRadiousToTitleView(){
        let bubbleStyle = brandingShared.bubbleShape
        var radius = 10.0
        let borderWidth = 0.0
        let borderColor = UIColor.clear
        if #available(iOS 11.0, *) {
            if bubbleStyle == "balloon"{
                self.tileBgv.roundCorners([.layerMaxXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMaxYCorner], radius: radius, borderColor: borderColor, borderWidth: borderWidth)
            }else if bubbleStyle == "rounded" || bubbleStyle == "circle"{
                radius = 15.0
                self.tileBgv.roundCorners([.layerMaxXMinYCorner, .layerMinXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMaxYCorner], radius: radius, borderColor: borderColor, borderWidth: borderWidth)
            }else if bubbleStyle == "rectangle"{
                radius = 8.0
                self.tileBgv.roundCorners([.layerMaxXMinYCorner, .layerMinXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMaxYCorner], radius: radius, borderColor: borderColor, borderWidth: borderWidth)
            }else if bubbleStyle == "square"{
                self.tileBgv.roundCorners([ .layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner], radius: radius, borderColor: borderColor, borderWidth: borderWidth)
            }else{
                self.tileBgv.roundCorners([ .layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner], radius: 20.0, borderColor: UIColor.lightGray, borderWidth: 0.0)
            }
        }
    }
    
    //MARK: collection view delegate methods
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        //let rows = self.rows
        print("tableRowsss: \(self.rows.count)")
        return rowsDataLimit + 2  //rows.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            let headers = self.data.headers
            return headers.count
        } else if section == 1 {
            return 1
        } else {
            //            let row = rows[section - 2]
            //            return row.count
            let headers = self.data.headers
            return headers.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // swiftlint:disable force_cast
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: customCellIdentifier, for: indexPath) as! CustomCollectionViewCell
        cell.backgroundColor = .clear
        cell.bgView.backgroundColor = .white
        cell.textLabel.textColor = .black
        let headers = self.data.headers
        let header = headers[indexPath.row]
        cell.bgView.layer.cornerRadius = 0.0
        
        cell.underLineLbl.backgroundColor = .white
        
        //let bgColor = self.data.elementsStyle[indexPath.row]
        //cell.bgView.backgroundColor = UIColor.init(hexString: bgColor)
        if indexPath.section == 0 {
            cell.textLabel.numberOfLines = 2
            cell.textLabel.text = header.title
            cell.textLabel.font = UIFont(name: boldCustomFont, size: 10.0)
            cell.textLabel.textAlignment = header.alignment
            cell.bgView.backgroundColor = .clear
            cell.textLabel.textColor = .black
        } else if indexPath.section == 1 {
            cell.textLabel.text = ""
            cell.backgroundColor = .clear
            cell.textLabel.textAlignment = header.alignment
        } else {
            let rows = self.data.rows
            let sec = indexPath.section - 2
            let row = rows[sec]
            let text = row[indexPath.row]
            cell.bgView.backgroundColor = UIColor.init(hexString: self.data.elementsStyle[sec])
            cell.underLineLbl.backgroundColor = UIColor.init(hexString: self.data.elementsStyle[sec])
            if text == "---" {
                cell.textLabel.text = ""
                cell.backgroundColor = .white
            } else {
                cell.textLabel.text = row[indexPath.row]
                cell.textLabel.numberOfLines = 2
                cell.textLabel.font = UIFont(name: regularCustomFont, size: 14.0)
                cell.textLabel.textAlignment = header.alignment
                
                //Set Corner Radious
                if indexPath.row == 0 {
                    if #available(iOS 11.0, *) {
                        cell.bgView.roundCorners([ .layerMinXMinYCorner, .layerMinXMaxYCorner], radius: 6.0, borderColor: UIColor.clear, borderWidth: 1.5)
                    }
                }
                if indexPath.row == row.count - 1 {
                    if #available(iOS 11.0, *) {
                        cell.bgView.roundCorners([ .layerMaxXMinYCorner, .layerMaxXMaxYCorner], radius: 6.0, borderColor: UIColor.clear, borderWidth: 1.5)
                    }
                }
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let headers = self.data.headers
        let header = headers[indexPath.row]
        let percentage = header.percentage
        let count = CGFloat(headers.count)
        
        let viewWidth = UIScreen.main.bounds.size.width - 66
        let maxWidth: CGFloat = viewWidth //- 5*(count-1)
        if(data.headers.count<5){
            itemWidth = floor((maxWidth/count)) //floor((maxWidth*CGFloat(percentage)/100))
        }
        else{
            let width : CGFloat = (header.title as NSString).size(withAttributes: [NSAttributedString.Key.font : UIFont(name: boldCustomFont, size: 10.0) as Any]).width //*2.0
//            if width > 85.0{
                itemWidth = 85.0
//            }else{
//                itemWidth = width
//            }
        }
        
        if indexPath.section == 0 {
            return CGSize(width: itemWidth - 2, height: 60)
        } else if indexPath.section == 1 {
            return CGSize(width: -1, height: 1)
        } else {
            let rows = self.data.rows
            let row = rows[indexPath.section - 2]
            let text = row[indexPath.row]
            if text == "---" {
                return CGSize(width: 0, height: 1)
            }
            return CGSize(width: itemWidth - 2, height: 50)//kk 4 6
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        if(data.columns.count > 0){
            return 0.0//(CGFloat(100/data.columns.count))
        }
        else{
            return 100.0
        }
    }
    
    override func populateComponents() {
        
        if (components.count > 0) {
            let component: KREComponent = components.firstObject as! KREComponent
            if (component.componentDesc != nil) {
                let jsonString = component.componentDesc
                let jsonObject: NSDictionary = Utilities.jsonObjectFromString(jsonString: jsonString!) as! NSDictionary
                let data: Dictionary<String, Any> = jsonObject as! Dictionary<String, Any>
                self.data = TableData(data)
                let rowsData = self.data.rows
                self.showMore = false
                var rowsDataCount = 0
                var index = 0
                for row in self.data.rows {
                    index += 1
                    let text = row[0]
                    if text != "---" {
                        rowsDataCount += 1
                    }
                }
                rowsDataLimit = self.data.rows.count
                self.rows = Array(rowsData.dropLast(rowsData.count - index))
                if self.showMore && self.data.rows[self.data.rows.count-1][0] != "---" {
                }
                self.titleLbl.text = jsonObject["text"] as? String
                self.showMoreButton.isHidden = self.showMore
                self.collectionView.reloadData()
            }
        }
    }
    
    override var intrinsicContentSize : CGSize {
        
        let limitingSize: CGSize  = CGSize(width: kMaxTextWidth, height: CGFloat.greatestFiniteMagnitude)
        var textSize: CGSize = self.titleLbl.sizeThatFits(limitingSize)
        if textSize.height < self.titleLbl.font.pointSize {
            textSize.height = self.titleLbl.font.pointSize
        }
        
        let rows = self.data.rows
        var height: CGFloat = 50.0
        
        if showMore{
            let  rowLimit = self.data.rows.count > 5 ? 5 : self.data.rows.count
            rowsDataLimit = rowLimit
        }else{
            rowsDataLimit = self.data.rows.count
        }
        for i in 0..<rowsDataLimit  {
            let row = rows[i]
            let text = row[0]
            if text == "---" {
                height += 1.0
            } else {
                height += 50.0
            }
        }
        if self.showMore {
            height += 0.0
        }
        return CGSize(width: 0.0, height: textSize.height  + height + 32)
    }
    
    @objc fileprivate func showMoreButtonAction(_ sender: AnyObject!) {
        if (components.count > 0) {
            let component: KREComponent = components.firstObject as! KREComponent
            if (component.componentDesc != nil) {
                let jsonString = component.componentDesc
                NotificationCenter.default.post(name: Notification.Name(showTableTemplateNotification), object: jsonString)
            }
        }
    }
}

