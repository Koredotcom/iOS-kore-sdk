//
//  TableTemplateViewController.swift
//  KoreBotSDKDemo
//
//  Created by Anoop Dhiman on 16/11/17.
//  Copyright © 2017 Kore. All rights reserved.
//

import UIKit

class TableTemplateViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    var selectedRowIndex : Int = -1
    var selectedIndex : IndexPath!
    var selected : Bool = false
    var indexPaths : Array<IndexPath> = []
    
    let cellReuseIdentifier = "CellIdentifier"
    let cellReuseIdentifier1 = "SubTableViewCell"
    var rows: Array<Array<String>> = Array<Array<String>>()
    
    var dataString: String!
    var data: TableData = TableData()
    let customCellIdentifier = "CustomCellIdentifier"
     var itemWidth : CGFloat = 0.0
    
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
        let jsonObject: NSDictionary = Utilities.jsonObjectFromString(jsonString: dataString!) as! NSDictionary
        let data: Dictionary<String, Any> = jsonObject as! Dictionary<String, Any>
        self.data = TableData(data)
        
        if(self.data.tableDesign == "regular"){
            self.collectionView.isHidden = false
            self.tableView.isHidden = true
            self.collectionView.dataSource = self
            self.collectionView.delegate = self
            self.collectionView.showsHorizontalScrollIndicator = false
            self.collectionView.alwaysBounceHorizontal = false
            
            self.collectionView.register(UINib(nibName: "CustomCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: customCellIdentifier)
            
            self.collectionView.register(UINib(nibName: "CustomCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: customCellIdentifier)
        }else{
            self.collectionView.isHidden = true
            self.tableView.isHidden = false
            self.tableView.dataSource = self
            self.tableView.delegate = self
            self.tableView.showsHorizontalScrollIndicator = false
            self.tableView.alwaysBounceHorizontal = false
            tableView.register(ResponsiveCustonCell.self, forCellReuseIdentifier: cellReuseIdentifier)
            tableView.register(SubTableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier1)
            let row = 0
            let section = 0
            selectedIndex = IndexPath(row: row, section: section)
            tableView.tableFooterView = UIView(frame: .zero)

        }
    }

    override func viewWillLayoutSubviews() {
        collectionView.reloadData()
        
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
        cell.backgroundColor = .white
        cell.textLabel.textColor = Common.UIColorRGB(0x26344A)
        
         let headers = self.data.headers
        let header = headers[indexPath.row]
//        let alignment = header.alignment != nil ? header.alignment as! String : ""
//        if alignment == "right" {
//            cell.textLabel.textAlignment = .right
//        }else if alignment == "center" {
//            cell.textLabel.textAlignment = .center
//        }else {
//            cell.textLabel.textAlignment = .left
//        }
        if indexPath.section == 0 {
            cell.textLabel.text = header.title
            cell.textLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 15.0)!
        } else if indexPath.section == 1 {
            cell.textLabel.text = ""
            cell.backgroundColor = Common.UIColorRGB(0xEDEFF2)
        } else {
            let rows = self.data.rows
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
        cell.textLabel.textAlignment = header.alignment
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let headers = self.data.headers
        let header = headers[indexPath.row]
        let percentage = header.percentage
        
        let viewWidth = UIScreen.main.bounds.size.width - 40
        let maxWidth: CGFloat = viewWidth
        if(data.headers.count<5){
            itemWidth = floor((maxWidth*CGFloat(percentage)/100))
        }
        else{
            let width : CGFloat = (header.title as NSString).size(withAttributes: [NSAttributedString.Key.font : UIFont(name: "HelveticaNeue-Bold", size: 14.0)!]).width*2.0
            itemWidth = width
        }
        
        if indexPath.section == 0 {
            return CGSize(width: itemWidth, height: 44)
        } else if indexPath.section == 1 {
            return CGSize(width: -1, height: 2)
        } else {
             let rows = self.data.rows
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
//        if section == 0 {
//            return (CGFloat(100/data.columns.count)-10.0)
//        }
        if(data.columns.count > 0){
            return (CGFloat(100/data.columns.count))
        }
        else{
            return 100.0
        }
    }
    
    //MARK: table view delegate methods
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPaths.count>0 {
            if indexPaths.contains(indexPath){
                return CGFloat((data.rows[indexPath.section].count)*44)
            }
            else {
                return UITableView.automaticDimension
            }
        }
        return UITableView.automaticDimension
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        
        return data.rows.count
    }
    
    
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        rows = data.rows
        
        if indexPaths.count>0 {
            if indexPaths.contains(indexPath){
                let subtableViewCell = SubTableViewCell(style: .default, reuseIdentifier: cellReuseIdentifier1)
                subtableViewCell.backgroundColor = UIColor.white
                subtableViewCell.accessoryView = UIImageView(image: UIImage(named: "arrowSelected"))
                subtableViewCell.rows = data.rows
                subtableViewCell.headers = data.headers
                subtableViewCell.sec = indexPath.section
                
                return subtableViewCell
            }
            else{
                let cell : ResponsiveCustonCell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! ResponsiveCustonCell
                print(rows[indexPath.section][indexPath.row])
                let row = rows[indexPath.section]
                if(row.count > indexPath.row*2){
                    cell.headerLabel.text = row[indexPath.row*2]
                }
                if(row.count > indexPath.row*2+1){
                    cell.secondLbl.text = row[indexPath.row*2+1]
                }
                cell.accessoryView = UIImageView(image: UIImage(named: "arrowUnselected"))
                cell.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 22)

                return cell
                
            }
        }else{
            let cell : ResponsiveCustonCell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! ResponsiveCustonCell
            print(rows[indexPath.section][indexPath.row])
            let row = rows[indexPath.section]
            if(row.count > indexPath.row*2){
                cell.headerLabel.text = row[indexPath.row*2]
            }
            if(row.count > indexPath.row*2+1){
                cell.secondLbl.text = row[indexPath.row*2+1]
            }
            cell.accessoryView = UIImageView(image: UIImage(named: "arrowUnselected"))
            cell.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 22)

            return cell
            
        }
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selected == false {
            selected = true
        }
        else{
            selected = false
        }
        
        if indexPath == selectedIndex {
            selectedIndex = NSIndexPath(row: -1, section: -1) as IndexPath
            selected = false
        } else {
            selectedIndex = indexPath
            selectedIndex = indexPath
            if !indexPaths.contains(selectedIndex!){
                indexPaths += [selectedIndex!]
            }
            else {
                let index = indexPaths.index(of: selectedIndex!)
                indexPaths.remove(at: index!)
            }
            selected = true
        }
        tableView.reloadData()
    }
}
