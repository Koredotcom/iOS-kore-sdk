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
            var row = Array<String>()
            for value in values {
                let val = value as? String ?? ""
                row.append(val)
            }
            rows.append(row)
        }
        print(rows)
        print(headers)
    }
}
class TableBubbleView: BubbleView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    var collectionView: UICollectionView!
    var showMoreButton: UIButton!
    var cardView: UIView!
    
    let customCellIdentifier = "CustomCellIdentifier"
    var data: TableData = TableData()
    let rowsDataLimit = 3
    var rows: Array<Array<String>> = Array<Array<String>>()
    var itemWidth:CGFloat = 0.0
    var count = 0

    
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
        cardView.layer.shadowColor = UIColor(red: 232/255, green: 232/255, blue: 230/255, alpha: 1).cgColor
        cardView.layer.shadowOpacity = 1
        cardView.layer.shadowOffset =  CGSize(width: 0.0, height: -3.0)
        cardView.layer.shadowRadius = 6.0
        cardView.layer.shouldRasterize = true
        cardView.backgroundColor =  UIColor.white
        let cardViews: [String: UIView] = ["cardView": cardView]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-15-[cardView]-15-|", options: [], metrics: nil, views: cardViews))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[cardView]-15-|", options: [], metrics: nil, views: cardViews))
    }
    
    override func initialize() {
        super.initialize()
        intializeCardLayout()
        let collectionViewLayout = CustomCollectionViewLayout()
        self.collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: collectionViewLayout)
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.backgroundColor = .clear
        self.collectionView.showsHorizontalScrollIndicator = false
        self.collectionView.showsVerticalScrollIndicator = false
        self.collectionView.bounces = false
        self.cardView.addSubview(self.collectionView)
        
        self.collectionView.register(UINib(nibName: "CustomCollectionViewCell", bundle: nil),
                                     forCellWithReuseIdentifier: customCellIdentifier)
        
        self.showMoreButton = UIButton.init(frame: CGRect.zero)
        self.showMoreButton.setTitle("Show More", for: .normal)
        self.showMoreButton.translatesAutoresizingMaskIntoConstraints = false
        self.showMoreButton.setTitleColor(UIColor(red: 95/255, green: 107/255, blue: 247/255, alpha: 1), for: .normal)
        self.showMoreButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 14.0)!
        self.showMoreButton.addTarget(self, action: #selector(self.showMoreButtonAction(_:)), for: .touchUpInside)
        self.showMoreButton.isHidden = true
        self.showMoreButton.clipsToBounds = true
        self.cardView.addSubview(self.showMoreButton)
        
        let views: [String: UIView] = ["collectionView": collectionView, "showMoreButton": showMoreButton]
        
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-15-[collectionView]-15-|", options: [], metrics: nil, views: views))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[collectionView]-15-|", options: [], metrics: nil, views: views))
        
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[showMoreButton(36.0)]|", options: [], metrics: nil, views: views))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[showMoreButton]-15-|", options: [], metrics: nil, views: views))
    }
    
    //MARK: collection view delegate methods
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        let rows = self.rows
        return rows.count + 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            let headers = self.data.headers
            return headers.count
        } else if section == 1 {
            return 1
        } else {
            let row = rows[section - 2]
            return row.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // swiftlint:disable force_cast
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: customCellIdentifier, for: indexPath) as! CustomCollectionViewCell
        cell.backgroundColor = .clear
        
        let headers = self.data.headers
        let header = headers[indexPath.row]
        if indexPath.section == 0 {
            cell.textLabel.text = header.title
            cell.textLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 14.0)!
            cell.textLabel.textAlignment = header.alignment

        } else if indexPath.section == 1 {
            cell.textLabel.text = ""
            cell.backgroundColor = .white
            cell.textLabel.textAlignment = header.alignment

        } else {
            let rows = self.data.rows
            let sec = indexPath.section - 2
            let row = rows[sec]
            let text = row[indexPath.row]
            if text == "---" {
                cell.textLabel.text = ""
                cell.backgroundColor = .white
            } else {
                cell.textLabel.text = row[indexPath.row]
                cell.textLabel.font = UIFont(name: "HelveticaNeue", size: 14.0)!
                cell.textLabel.textAlignment = header.alignment

            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let headers = self.data.headers
        let header = headers[indexPath.row]
        let percentage = header.percentage
        let count = CGFloat(headers.count)
        
        let viewWidth = UIScreen.main.bounds.size.width - 40
        let maxWidth: CGFloat = viewWidth - 5*(count-1)
        if(data.headers.count<5){
            itemWidth = floor((maxWidth*CGFloat(percentage)/100))
        }
        else{
            let width : CGFloat = (header.title as NSString).size(withAttributes: [NSAttributedString.Key.font : UIFont(name: "HelveticaNeue-Bold", size: 14.0)!]).width*2.0
            itemWidth = width
        }
        
        if indexPath.section == 0 {
            return CGSize(width: itemWidth, height: 36)
        } else if indexPath.section == 1 {
            return CGSize(width: -1, height: 1)
        } else {
            let rows = self.data.rows
            let row = rows[indexPath.section - 2]
            let text = row[indexPath.row]
            if text == "---" {
                return CGSize(width: 0, height: 1)
            }
            return CGSize(width: itemWidth, height: 36)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0.0, left: 20.0, bottom: 0.0, right: 20.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        if(data.columns.count > 0){
            return (CGFloat(100/data.columns.count))
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
                    if rowsDataCount == rowsDataLimit {
                        self.showMore = true
                        break
                    }
                }
                self.rows = Array(rowsData.dropLast(rowsData.count - index))
                if self.showMore && self.data.rows[self.data.rows.count-1][0] != "---" {
//                    self.data.rows.append(["---"])
                }
                self.collectionView.collectionViewLayout.invalidateLayout()
                self.collectionView.reloadData()
                self.showMoreButton.isHidden = !self.showMore
            }
        }
    }
    
    override var intrinsicContentSize : CGSize {
        let rows = self.data.rows
        var height: CGFloat = 38.0
        for i in 0..<rowsDataLimit {
            let row = rows[i]
            let text = row[0]
            if text == "---" {
                height += 1.0
            } else {
                height += 44.0
            }
        }
        if self.showMore {
            height += 44.0
        }
        
        return CGSize(width: 0.0, height: height)
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

