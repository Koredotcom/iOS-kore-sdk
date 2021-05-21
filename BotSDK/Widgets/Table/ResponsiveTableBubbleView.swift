//
//  ResponsiveTableBubbleView.swift
//  KoreBotSDKDemo
//
//  Created by Sowmya Ponangi on 28/03/18.
//  Copyright © 2018 Kore. All rights reserved.
//

import UIKit

open class ResponsiveTableBubbleView: UIView {
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    lazy var showMoreButton: UIButton = {
        let showMoreButton = UIButton.init(frame: CGRect.zero)
        showMoreButton.setTitle("Show More", for: .normal)
        showMoreButton.translatesAutoresizingMaskIntoConstraints = false
        return showMoreButton
    }()
    lazy var cardView : UIView = {
        let cardView = UIView(frame:.zero)
        cardView.translatesAutoresizingMaskIntoConstraints = false
        return cardView
    }()
    
    let cellReuseIdentifier = "CellIdentifier"
    let cellReuseIdentifier1 = "SubTableViewCell"
    var data: TableData = TableData()
    let rowsDataLimit = 3
    
    var selectedRowIndex : Int = -1
    var selectedIndex : IndexPath!
    var selected : Bool = false
    var indexPaths : Array<IndexPath> = []

    var rows: Array<Array<String>> = Array<Array<String>>()
    var showMore = false
    let reloadTableNotification = "reloadTableNotification"
    public var showMoreAction: (() -> Void)?

    // MARK: - init
    override init(frame: CGRect) {
        super.init(frame: .zero)
        initialize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    func intializeCardLayout() {
        cardView.layer.rasterizationScale =  UIScreen.main.scale
        cardView.layer.shadowColor = UIColor(red: 232/255, green: 232/255, blue: 230/255, alpha: 1).cgColor
        cardView.layer.shadowOpacity = 1
        cardView.layer.shadowOffset =  CGSize(width: 0.0, height: -3.0)
        cardView.layer.shadowRadius = 6.0
        cardView.layer.shouldRasterize = true
        cardView.backgroundColor =  UIColor.white
        addSubview(cardView)

        let cardViews: [String: UIView] = ["cardView": cardView]
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-15-[cardView]-15-|", options: [], metrics: nil, views: cardViews))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[cardView]-15-|", options: [], metrics: nil, views: cardViews))
    }
    
    func initialize() {
        intializeCardLayout()
        
        cardView.addSubview(tableView)
        tableView.register(ResponsiveCustomCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        tableView.register(SubTableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier1)
        
        tableView.backgroundColor = UIColor.white
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = false
        tableView.bounces = false
        tableView.tableFooterView = UIView(frame: .zero)
        
        let row = -1
        let section = -1
        selectedIndex = IndexPath(row: row, section: section)
        
        showMoreButton.setTitleColor( UIColor(red: 95/255, green: 107/255, blue: 247/255, alpha: 1)
, for: .normal)
        showMoreButton.titleLabel?.font = UIFont.textFont(ofSize: 14.0, weight: .regular)
        showMoreButton.titleLabel?.font = showMoreButton.titleLabel?.font.withSize(14.0)
     
        showMoreButton.addTarget(self, action: #selector(showMoreButtonAction(_:)), for: .touchUpInside)
        showMoreButton.isHidden = false
        showMoreButton.clipsToBounds = true
        cardView.addSubview(showMoreButton)

        
        let views : [String: Any] = ["tableView": tableView,  "showMoreButton": showMoreButton]
        
        cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[tableView]-15-|", options: [], metrics: nil, views: views))
        cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat:"V:|-15-[tableView]-15-|", options: [], metrics: nil, views: views))
        cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[showMoreButton(44.0)]|", options: [], metrics: nil, views: views))
        cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[showMoreButton]-15-|", options: [], metrics: nil, views: views))
    }
    
    func populateComponents(_ jsonObject: [String: Any]?) {
        guard let dictionary = jsonObject else {
            return
        }
        data = TableData(dictionary)
        showMore = false
        var rowsDataCount = 0
        for _ in data.rows {
            rowsDataCount += 1
            if rowsDataCount == rowsDataLimit {
                showMore = true
                break
            }
        }
        showMoreButton.isHidden = !showMore
        tableView.reloadData()
    }
    
    override open var intrinsicContentSize : CGSize {
        var height: CGFloat = 44.0
        let noOfUnselectedRows = rowsDataLimit - indexPaths.count
        height = (CGFloat(noOfUnselectedRows * 44)) + 36
        for i in  0..<(indexPaths.count) {
            height = height + CGFloat(data.rows[i].count * 44)
        }
        
        if showMore {
            height += 36.0
        }
        
        return CGSize(width: 0.0, height: height)
    }
    
    @objc func showMoreButtonAction(_ sender: AnyObject!) {
        showMoreAction?()
    }

    @objc fileprivate func reloadTable() {
        NotificationCenter.default.post(name: Notification.Name(reloadTableNotification), object: nil)
    }
}

// MARK: - table view delegate methods
extension ResponsiveTableBubbleView: UITableViewDelegate, UITableViewDataSource {
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
        return rowsDataLimit
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        rows = data.rows
        
        //        if(selectedIndex as IndexPath == indexPath && selected == true && indexPath.row != rows.count-1) {
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
                let cell : ResponsiveCustomCell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! ResponsiveCustomCell
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
            let cell : ResponsiveCustomCell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! ResponsiveCustomCell
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
        reloadTable()
        tableView.reloadData()
    }
}

