//
//  TableBubbleView.swift
//  KoreBotSDKDemo
//
//  Created by Anoop Dhiman on 09/10/17.
//  Copyright © 2017 Kore. All rights reserved.
//

import UIKit

class TableBubbleView: BubbleView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    var collectionView: UICollectionView!
    var showMoreButton: UIButton!
    
    let customCellIdentifier = "CustomCellIdentifier"
    let rowsDataLimit = 6
    
    var headers: Array<Dictionary<String, Any>> = Array<Dictionary<String, Any>>()
    var rows: Array<Array<String>> = Array<Array<String>>()
    var showMore = false
    
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
        
        let collectionViewLayout = CustomCollectionViewLayout()
        self.collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: collectionViewLayout)
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.backgroundColor = .clear
        self.collectionView.showsHorizontalScrollIndicator = false
        self.collectionView.showsVerticalScrollIndicator = false
        self.collectionView.bounces = false
        self.addSubview(self.collectionView)
        
        self.collectionView.register(UINib(nibName: "CustomCollectionViewCell", bundle: nil),
                                     forCellWithReuseIdentifier: customCellIdentifier)
        
        self.showMoreButton = UIButton.init(frame: CGRect.zero)
        self.showMoreButton.setTitle("Show More", for: .normal)
        self.showMoreButton.translatesAutoresizingMaskIntoConstraints = false
        self.showMoreButton.setTitleColor(Common.UIColorRGB(0xFFFFFF), for: .normal)
        self.showMoreButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 14.0)!
        self.showMoreButton.addTarget(self, action: #selector(self.showMoreButtonAction(_:)), for: .touchUpInside)
        self.showMoreButton.isHidden = true
        self.showMoreButton.clipsToBounds = true
        self.addSubview(self.showMoreButton)
        
        let views: [String: UIView] = ["collectionView": collectionView, "showMoreButton": showMoreButton]
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[collectionView]|", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[collectionView]|", options: [], metrics: nil, views: views))
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[showMoreButton(36.0)]|", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[showMoreButton]|", options: [], metrics: nil, views: views))
    }
    
    //MARK: collection view delegate methods
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return rows.count + 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return headers.count
        } else if section == 1 {
            return 1
        } else {
            let sec = section - 2
            let row = rows[sec]
            return row.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // swiftlint:disable force_cast
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: customCellIdentifier, for: indexPath) as! CustomCollectionViewCell
        cell.backgroundColor = .clear
        
        let header = headers[indexPath.row]
        let alignment = header["alignment"] != nil ? header["alignment"] as! String : ""
        if alignment == "right" {
            cell.textLabel.textAlignment = .right
        }else if alignment == "center" {
            cell.textLabel.textAlignment = .center
        }else {
            cell.textLabel.textAlignment = .left
        }
        if indexPath.section == 0 {
            let title = header["title"] != nil ? header["title"] as! String : ""
            cell.textLabel.text = title
            cell.textLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 15.0)!
        } else if indexPath.section == 1 {
            cell.textLabel.text = ""
            cell.backgroundColor = .white
        } else {
            let sec = indexPath.section - 2
            let row = rows[sec]
            let text = row[indexPath.row]
            if text == "---" {
                cell.textLabel.text = ""
                cell.backgroundColor = .white
            } else {
                cell.textLabel.text = row[indexPath.row]
                cell.textLabel.font = UIFont(name: "HelveticaNeue", size: 14.0)!
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let header = headers[indexPath.row]
        let percentage = header["percentage"] != nil ? header["percentage"] as! NSNumber : 0
        let count = CGFloat(headers.count)
        
        let viewWidth = UIScreen.main.bounds.size.width - 40
        let maxWidth: CGFloat = viewWidth - 5*(count-1)
        let itemWidth = floor((maxWidth*CGFloat(percentage.doubleValue)/100))
        
        if indexPath.section == 0 {
            return CGSize(width: itemWidth, height: 36)
        } else if indexPath.section == 1 {
            return CGSize(width: -1, height: 1)
        } else {
            let sec = indexPath.section - 2
            let row = rows[sec]
            let text = row[indexPath.row]
            if text == "---" {
                return CGSize(width: -1, height: 1)
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
                let data: Dictionary<String, Any> = jsonObject["data"] != nil ? jsonObject["data"] as! Dictionary<String, Any> : [:]
                
                self.headers = data["headers"] as! Array<Dictionary<String, Any>>
                let rowsData = data["rows"] as! Array<Array<String>>
                
                self.showMore = false
                var rowsDataCount = 0
                var index = 0
                for row in rowsData {
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
                if self.showMore && self.rows[self.rows.count-1][0] != "---" {
                    self.rows.append(["---"])
                }
                self.collectionView.collectionViewLayout.invalidateLayout()
                self.collectionView.reloadData()
                self.showMoreButton.isHidden = !self.showMore
            }
        }
    }
    
    override var intrinsicContentSize : CGSize {
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
        if self.showMore {
            height += 36.0
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
