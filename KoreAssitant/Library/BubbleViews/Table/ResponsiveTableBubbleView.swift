//
//  ResponsiveTableBubbleView.swift
//  KoreBotSDKDemo
//
//  Created by Sowmya Ponangi on 28/03/18.
//  Copyright © 2018 Kore. All rights reserved.
//



import UIKit


class ResponsiveTableBubbleView: BubbleView, UITableViewDelegate, UITableViewDataSource {
    var tableView: UITableView!
    var showMoreButton: UIButton!
    var cardView : UIView!
    
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
        
        tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        self.cardView.addSubview(tableView)
        tableView.register(ResponsiveCustonCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        tableView.register(SubTableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier1)
        
        tableView.backgroundColor = UIColor.white
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.showsHorizontalScrollIndicator = false
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.bounces = false
        self.tableView.tableFooterView = UIView(frame: .zero)
        
        let row = -1
        let section = -1
        selectedIndex = IndexPath(row: row, section: section)
        
        self.showMoreButton = UIButton.init(frame: CGRect.zero)
        self.showMoreButton.setTitle("Show More", for: .normal)
        self.showMoreButton.translatesAutoresizingMaskIntoConstraints = false
        self.showMoreButton.setTitleColor( UIColor(red: 95/255, green: 107/255, blue: 247/255, alpha: 1)
, for: .normal)
        self.showMoreButton.titleLabel?.font = UIFont(name: "Lato-Regular", size: 14.0)
        self.showMoreButton.titleLabel?.font = self.showMoreButton.titleLabel?.font.withSize(14.0)
     
        self.showMoreButton.addTarget(self, action: #selector(self.showMoreButtonAction(_:)), for: .touchUpInside)
        self.showMoreButton.isHidden = false
        self.showMoreButton.clipsToBounds = true
        self.cardView.addSubview(self.showMoreButton)

        
        let views : [String: Any] = ["tableView": tableView,  "showMoreButton": showMoreButton]
        
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[tableView]-15-|", options: [], metrics: nil, views: views))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat:"V:|-15-[tableView]-15-|", options: [], metrics: nil, views: views))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[showMoreButton(44.0)]|", options: [], metrics: nil, views: views))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[showMoreButton]-15-|", options: [], metrics: nil, views: views))
        
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
        reloadTable()
        tableView.reloadData()
    }
    
    override func populateComponents() {
        if (components.count > 0) {
            let component: KREComponent = components.firstObject as! KREComponent
            if (component.componentDesc != nil) {
                let jsonString = component.componentDesc
                let jsonObject: NSDictionary = Utilities.jsonObjectFromString(jsonString: jsonString!) as! NSDictionary
                let data: Dictionary<String, Any> = jsonObject as! Dictionary<String, Any>
                self.data = TableData(data)
                self.showMore = false
                var rowsDataCount = 0
                for _ in self.data.rows {
                    rowsDataCount += 1
                    if rowsDataCount == rowsDataLimit {
                        self.showMore = true
                        break
                    }
                }
                self.showMoreButton.isHidden = !self.showMore
                self.tableView.reloadData()
                
            }
        }
    }
    
    override var intrinsicContentSize : CGSize {
        var height: CGFloat = 44.0
        let noOfUnselectedRows = rowsDataLimit - indexPaths.count   
        height = (CGFloat(noOfUnselectedRows * 44)) + 36
        for i in  0..<(indexPaths.count) {
            height = height + CGFloat(data.rows[i].count * 44)
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
    @objc fileprivate func reloadTable() {
        NotificationCenter.default.post(name: Notification.Name(reloadTableNotification), object: nil)
    }
}

