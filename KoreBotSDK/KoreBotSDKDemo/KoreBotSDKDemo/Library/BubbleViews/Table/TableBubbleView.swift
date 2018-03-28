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
    
    convenience init(_ data: Dictionary<String, Any>){
        self.init()
        guard let columns = data["columns"] as? Array<Array<String>> else { return }
        guard let elements = data["elements"] as? Array<Dictionary<String, Any>> else { return }
        
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
            headers.append(Header(title: title, alignment: alignment, percentage: percentage))
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
    }
}

class TableBubbleView: BubbleView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    var collectionView: UICollectionView!
    let customCellIdentifier = "CustomCellIdentifier"
    
    var data: TableData = TableData()
    
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
        
        let collectionViewLayout = UICollectionViewFlowLayout()
        self.collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: collectionViewLayout)
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.backgroundColor = .clear
        self.addSubview(self.collectionView)
        
        self.collectionView.register(UINib(nibName: "CustomCollectionViewCell", bundle: nil),
                                     forCellWithReuseIdentifier: customCellIdentifier)
        
        let views: [String: UIView] = ["collectionView": collectionView]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[collectionView]-0-|", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[collectionView]-0-|", options: [], metrics: nil, views: views))
    }
    
    //MARK: collection view delegate methods
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        let rows = self.data.rows
        return rows.count + 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            let headers = self.data.headers
            return headers.count
        } else if section == 1 {
            return 1
        } else {
            let rows = self.data.rows
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
        cell.textLabel.textAlignment = header.alignment
        if indexPath.section == 0 {
            cell.textLabel.text = header.title
            cell.textLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 15.0)!
        } else if indexPath.section == 1 {
            cell.textLabel.text = ""
            cell.backgroundColor = Common.UIColorRGB(0x233842)
        } else {
            let rows = self.data.rows
            let row = rows[indexPath.section - 2]
            let text = row[indexPath.row]
            if text == "---" {
                cell.textLabel.text = ""
                cell.backgroundColor = Common.UIColorRGB(0x233842)
            } else {
                cell.textLabel.text = row[indexPath.row]
                cell.textLabel.font = UIFont(name: "HelveticaNeue", size: 14.0)!
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
        let itemWidth = floor((maxWidth*CGFloat(percentage)/100))
        
        if indexPath.section == 0 {
            return CGSize(width: itemWidth, height: 36)
        } else if indexPath.section == 1 {
            return CGSize(width: viewWidth, height: 1)
        } else {
            let rows = self.data.rows
            let row = rows[indexPath.section - 2]
            let text = row[indexPath.row]
            if text == "---" {
                return CGSize(width: viewWidth, height: 1)
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
        return 5.0
    }
    
    override func populateComponents() {
        if (components.count > 0) {
            let component: KREComponent = components.firstObject as! KREComponent
            if (component.componentDesc != nil) {
                let jsonString = component.componentDesc
                let jsonObject: NSDictionary = Utilities.jsonObjectFromString(jsonString: jsonString!) as! NSDictionary
                let data: Dictionary<String, Any> = jsonObject as! Dictionary<String, Any>
                self.data = TableData(data)
                self.collectionView.reloadData()
            }
        }
    }
    
    override var intrinsicContentSize : CGSize {
        let rows = self.data.rows
        var height: CGFloat = 38.0
        for i in 0..<rows.count {
            let row = rows[i]
            let text = row[0]
            if text == "---" {
                height += 1.0
            } else {
                height += 36.0
            }
        }
        return CGSize(width: 0.0, height: height)
    }
}

