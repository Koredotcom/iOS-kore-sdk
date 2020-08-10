//
//  TableBubbleView.swift
//  KoreBotSDKDemo
//
//  Created by Anoop Dhiman on 09/10/17.
//  Copyright © 2017 Kore. All rights reserved.
//

import UIKit

public struct Header {
    public var title: String = ""
    public var alignment: NSTextAlignment = .left
    public var percentage: Int = 0
}

public class TableData {
    public var headers: Array<Header> = Array<Header>()
    public var rows: Array<Array<String>> = Array<Array<String>>()
    public var columns: Array<Array<String>> = Array<Array<String>>()
    public var elements:Array<Dictionary<String, Any>> = Array<Dictionary<String, Any>>()
    public var tableDesign:String!
    
    convenience init(_ data: Dictionary<String, Any>){
        self.init()
        guard let columns = data["columns"] as? Array<Array<String>> else { return }
        guard let locelements = data["elements"] as? Array<Dictionary<String, Any>> else { return }
        elements = locelements
        self.columns = columns
        
        tableDesign = data["table_design"] != nil ? data["table_design"] as? String : "responsive"
        var percentage: Int = Int(floor(Double(80/columns.count)))
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
            guard let values = element["Values"] as? Array<Any> else {
                continue
            }
            
            var row = Array<String>()
            for value in values {
                if let val = value as? String {
                    row.append(val)
                } else if let val = value as? NSNumber {
                    row.append(val.stringValue)
                } else {
                    row.append("")
                }
            }
            rows.append(row)
        }
        print(rows)
        print(headers)
    }
}

public class TableBubbleView: UIView {
    // MARK: - properties
    let bundle = Bundle(for: TableBubbleView.self)
    var collectionView: UICollectionView!
    var showMoreButton: UIButton!
    public lazy var cardView: UIView = {
        let cardView = UIView(frame:.zero)
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.layer.rasterizationScale = UIScreen.main.scale
        cardView.backgroundColor = UIColor.white
        cardView.layer.cornerRadius = 10.0
        cardView.layer.shadowRadius = 3.0
        cardView.layer.masksToBounds = false
        cardView.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        cardView.layer.shadowOpacity = 1.0
        cardView.layer.shadowColor = UIColor.dividerColor.cgColor
        cardView.layer.borderColor = UIColor.lightGreyBlue.cgColor
        cardView.layer.borderWidth = 0.5
        cardView.clipsToBounds = true
        return cardView
    }()
    let showTableTemplateNotification = "ShowTableTemplateNotificationName"
    let customCellIdentifier = "CustomCellIdentifier"
    var data: TableData = TableData()
    let rowsDataLimit = 3
    var rows: Array<Array<String>> = Array<Array<String>>()
    var itemWidth:CGFloat = 0.0
    var count = 0
    var showMore = false
    public var showMoreAction: (() -> Void)?

    public override init(frame: CGRect) {
        super.init(frame: .zero)
        initialize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    func intializeCardLayout() {
        addSubview(cardView)

        let cardViews: [String: UIView] = ["cardView": cardView]
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[cardView]|", options: [], metrics: nil, views: cardViews))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[cardView]|", options: [], metrics: nil, views: cardViews))
    }
    
    func initialize() {
        intializeCardLayout()
        let collectionViewLayout = CustomCollectionViewLayout()
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: collectionViewLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.bounces = false
        cardView.addSubview(collectionView)
        
        collectionView.register(UINib(nibName: "CustomCollectionViewCell", bundle: bundle),
                                     forCellWithReuseIdentifier: customCellIdentifier)
        
        showMoreButton = UIButton.init(frame: CGRect.zero)
        showMoreButton.setTitle("Show More", for: .normal)
        showMoreButton.translatesAutoresizingMaskIntoConstraints = false
        showMoreButton.setTitleColor(UIColor(red: 95/255, green: 107/255, blue: 247/255, alpha: 1), for: .normal)
        showMoreButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 14.0)!
        showMoreButton.addTarget(self, action: #selector(showMoreButtonAction(_:)), for: .touchUpInside)
        showMoreButton.isHidden = true
        showMoreButton.clipsToBounds = true
        cardView.addSubview(showMoreButton)
        
        let views: [String: UIView] = ["collectionView": collectionView, "showMoreButton": showMoreButton]
        
        cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[collectionView][showMoreButton(36.0)]|", options: [], metrics: nil, views: views))
        cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[collectionView]|", options: [], metrics: nil, views: views))
        cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[showMoreButton]|", options: [], metrics: nil, views: views))
    }
    
    // MARK: -
    public func populateComponents(_ jsonObject: [String: Any]?) {
        guard let data = jsonObject else {
            return
        }
        
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
            //            self.data.rows.append(["---"])
        }
        self.collectionView.collectionViewLayout.invalidateLayout()
        self.collectionView.reloadData()
        self.showMoreButton.isHidden = !self.showMore
        
    }
    
    public func getExpectedHeight() -> CGFloat {
        let rows = data.rows
        var height: CGFloat = 0.0
        if data.headers.count > 0 {
            height += 36.0
        }
        for i in 0..<rowsDataLimit {
            guard i < rows.count else {
                continue
            }
            let row = rows[i]
            let text = row[0]
            if text == "---" {
                height += 1.0
            } else {
                height += 36.0
            }
        }
        if showMore {
            height += 36.0
        }
        return height
    }
    
    @objc func showMoreButtonAction(_ sender: Any?) {
        showMoreAction?()
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension TableBubbleView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        let rows = self.rows
        return rows.count + 2
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
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
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
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
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
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
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0.0, left: 20.0, bottom: 0.0, right: 20.0)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if data.columns.count > 0 {
            return (CGFloat(100/data.columns.count))
        } else {
            return 100.0
        }
    }
}

