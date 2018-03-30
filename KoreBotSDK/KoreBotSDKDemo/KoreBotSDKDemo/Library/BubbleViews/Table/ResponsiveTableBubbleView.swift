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
    
    let cellReuseIdentifier = "CellIdentifier"
    let cellReuseIdentifier1 = "SubTableViewCell"
    var data: TableData = TableData()
    let rowsDataLimit = 2
    
    var selectedRowIndex : Int = -1
    var selectedIndex : IndexPath!
    var selected : Bool = false

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
        
        tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(tableView)
        tableView.register(ResponsiveCustonCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        tableView.register(SubTableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier1)
        
        tableView.backgroundColor = UIColor.white
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.showsHorizontalScrollIndicator = false
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.bounces = false
        self.tableView.separatorStyle = .singleLineEtched
        self.tableView.tableFooterView = UIView(frame: .zero)
        
        let row = 0
        let section = 0
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
        self.addSubview(self.showMoreButton)

        
        let views : [String: Any] = ["tableView": tableView,  "showMoreButton": showMoreButton]
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[tableView]-15-|", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat:"V:|-[tableView]-|", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[showMoreButton(44.0)]|", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[showMoreButton]-15-|", options: [], metrics: nil, views: views))
        
    }
    
    //MARK: table view delegate methods
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(selectedIndex as IndexPath == indexPath && selected == true) {
            return CGFloat((data.headers.count)*44)
        }
        return UITableViewAutomaticDimension
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        
        return data.rows.count
    }
    
    
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        rows = data.rows

        if(selectedIndex as IndexPath == indexPath && selected == true && indexPath.row != rows.count-1) {
            let subtableViewCell = SubTableViewCell(style: .default, reuseIdentifier: cellReuseIdentifier1)
            subtableViewCell.backgroundColor = UIColor.white
            subtableViewCell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
            subtableViewCell.rows = data.rows
            subtableViewCell.headers = data.headers
            subtableViewCell.section = indexPath.section
            
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
            cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
           
            
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
            selected = true
        }
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
                self.showMoreButton.isHidden = !self.showMore
                self.tableView.reloadData()
                
            }
        }
    }
    
    override var intrinsicContentSize : CGSize {
        let rows = self.data.rows
        var height: CGFloat = 44.0
        for i in 0..<rows.count {
            let row = rows[i]
            let text = row[0]
            if text == "---" {
                height += 1.0
            } else {
                if(selected == false){
                    height += 40
                }
                else{
                    height += CGFloat((data.headers.count)*44)
                }
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

