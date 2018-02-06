//
//  TableTemplateViewController.swift
//  KoreBotSDKDemo
//
//  Created by Anoop Dhiman on 16/11/17.
//  Copyright © 2017 Kore. All rights reserved.
//

import UIKit

class TableTemplateViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    var dataString: String!
    var data: Dictionary<String, Any> = Dictionary<String, Any>()
    let customCellIdentifier = "CustomCellIdentifier"
    
    // MARK: init
    init(dataString: String) {
        super.init(nibName: "TableTemplateViewController", bundle: nil)
        self.dataString = dataString
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let customCollectionViewLayout = self.collectionView.collectionViewLayout as! CustomCollectionViewLayout
        customCollectionViewLayout.shouldPinFirstRow = true
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.showsHorizontalScrollIndicator = false
        self.collectionView.alwaysBounceHorizontal = false
        
        self.collectionView.register(UINib(nibName: "CustomCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: customCellIdentifier)
        
        let jsonObject: NSDictionary = Utilities.jsonObjectFromString(jsonString: dataString!) as! NSDictionary
        let data: Dictionary<String, Any> = jsonObject["data"] != nil ? jsonObject["data"] as! Dictionary<String, Any> : [:]
        self.data = data
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: cancel
    @IBAction func closeButtonAction(_ sender: UIButton!) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: collection view delegate methods
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        let rows = self.data["rows"]  as! Array<Array<String>>
        return rows.count + 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            let headers = self.data["headers"]  as! Array<Dictionary<String, Any>>
            return headers.count
        } else if section == 1 {
            return 1
        } else {
            let rows = self.data["rows"]  as! Array<Array<String>>
            let row = rows[section - 2]
            return row.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // swiftlint:disable force_cast
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: customCellIdentifier, for: indexPath) as! CustomCollectionViewCell
        cell.backgroundColor = .white
        cell.textLabel.textColor = Common.UIColorRGB(0x26344A)
        
        let headers = self.data["headers"]  as! Array<Dictionary<String, Any>>
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
            cell.textLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 16.0)!
        } else if indexPath.section == 1 {
            cell.textLabel.text = ""
            cell.backgroundColor = Common.UIColorRGB(0xEDEFF2)
        } else {
            let rows = self.data["rows"]  as! Array<Array<String>>
            let row = rows[indexPath.section - 2]
            let text = row[indexPath.row]
            if text == "---" {
                cell.textLabel.text = ""
                cell.backgroundColor = Common.UIColorRGB(0xEDEFF2)
            } else {
                cell.textLabel.text = row[indexPath.row]
                cell.textLabel.font = UIFont(name: "HelveticaNeue", size: 15.0)!
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let headers = self.data["headers"]  as! Array<Dictionary<String, Any>>
        let header = headers[indexPath.row]
        let percentage = header["percentage"] != nil ? header["percentage"] as! NSNumber : 0
        
        let viewWidth = UIScreen.main.bounds.size.width - 40
        let maxWidth: CGFloat = viewWidth
        let itemWidth = floor((maxWidth*CGFloat(percentage.doubleValue)/100))
        
        if indexPath.section == 0 {
            return CGSize(width: itemWidth, height: 44)
        } else if indexPath.section == 1 {
            return CGSize(width: -1, height: 2)
        } else {
            let rows = self.data["rows"]  as! Array<Array<String>>
            let row = rows[indexPath.section - 2]
            let text = row[indexPath.row]
            if text == "---" {
                return CGSize(width: -1, height: 1)
            }
            return CGSize(width: itemWidth, height: 38)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0.0, left: 20.0, bottom: 0.0, right: 20.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
}
