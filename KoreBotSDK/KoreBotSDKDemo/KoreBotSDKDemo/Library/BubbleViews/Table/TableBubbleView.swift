//
//  TableBubbleView.swift
//  KoreBotSDKDemo
//
//  Created by Anoop Dhiman on 09/10/17.
//  Copyright © 2017 Kore. All rights reserved.
//

import UIKit

class HeaderView: UIView {
    var textLabel: UILabel!
    var detailTextLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.textLabel = UILabel()
        self.textLabel.translatesAutoresizingMaskIntoConstraints = false
        self.textLabel.textColor = UIColor(red: 0.556863, green: 0.556863, blue: 0.576471, alpha: 1)
        self.textLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 17.0)!
        self.addSubview(self.textLabel)
        
        self.detailTextLabel = UILabel()
        self.detailTextLabel.translatesAutoresizingMaskIntoConstraints = false
        self.detailTextLabel.textColor = UIColor(red: 0.556863, green: 0.556863, blue: 0.576471, alpha: 1)
        self.detailTextLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 17.0)!
        self.addSubview(self.detailTextLabel)
        
        let views: [String : Any] = ["textLabel": self.textLabel, "detailTextLabel": self.detailTextLabel]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[textLabel]->=8-[detailTextLabel]-15-|", options:[], metrics:nil, views:views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[textLabel]|", options:[], metrics:nil, views:views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[detailTextLabel]|", options:[], metrics:nil, views:views))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class TableBubbleView: BubbleView, UITableViewDataSource, UITableViewDelegate {
    var tableView: UITableView!
    var dataArray: Array<Dictionary<String, Any>> = Array<Dictionary<String, Any>>()
    
    public var optionsAction: ((_ text: String?) -> Void)!
    public var linkAction: ((_ text: String?) -> Void)!
    
    override func applyBubbleMask() {
        //nothing to put here
    }
    
    override var tailPosition: BubbleMaskTailPosition! {
        didSet {
            self.backgroundColor = Common.UIColorRGB(0xEFEFF4)
        }
    }
    
    override func initialize() {
        super.initialize()
        self.needDateLabel = false
        
        self.tableView = UITableView(frame: CGRect.zero, style: .grouped)
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.addSubview(self.tableView)
        
        let views: [String: UIView] = ["tableView": tableView]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-15-[tableView]-0-|", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[tableView]-10-|", options: [], metrics: nil, views: views))
    }
    
    override func borderColor() -> UIColor {
        return UIColor.clear
    }
    
    //MARK: TableView datasource/delegate methods
    public func numberOfSections(in tableView: UITableView) -> Int {
        return dataArray.count
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let element = dataArray[section]
        let rows: Array<Dictionary<String, Any>> = element["rows"] as! Array<Dictionary<String, Any>>
        return rows.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: "tableViewCell")
        if cell == nil {
            cell = UITableViewCell(style: .value1, reuseIdentifier: "tableViewCell")
            cell?.selectionStyle = .none
            cell?.textLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 14.0)!
            cell?.detailTextLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 14.0)!
            cell?.textLabel?.textColor = cell?.detailTextLabel?.textColor
        }
        let element = dataArray[indexPath.section]
        let rows: Array<Dictionary<String, Any>> = element["rows"] as! Array<Dictionary<String, Any>>
        let row = rows[indexPath.row]
        let title: String = row["title"] != nil ? row["title"] as! String: ""
        let value: String = row["value"] != nil ? row["value"] as! String: ""
        cell?.textLabel?.text = title
        cell?.detailTextLabel?.text = value
        return cell!
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let element = dataArray[section]
        let header = element["header"] as! Dictionary<String, Any>
        let title: String = header["title"] != nil ? header["title"] as! String: ""
        let value: String = header["value"] != nil ? header["value"] as! String: ""
        
        let headerView = HeaderView(frame: CGRect.zero)
        headerView.textLabel.text = title
        headerView.detailTextLabel.text = value
        headerView.backgroundColor = .white
        return headerView
    }
    
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView(frame: CGRect.zero)
    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 38.0
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44.0
    }
    
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 15.0
    }
    
    // MARK: populate components
    override func populateComponents() {
        if (components.count > 0) {
            let component: KREComponent = components.firstObject as! KREComponent
            if (component.componentDesc != nil) {
                let jsonString = component.componentDesc
                let jsonObject: NSDictionary = Utilities.jsonObjectFromString(jsonString: jsonString!) as! NSDictionary
                let elements: Array<Dictionary<String, Any>> = jsonObject["elements"] != nil ? jsonObject["elements"] as! Array<Dictionary<String, Any>> : []
                self.dataArray = elements
                self.tableView.reloadData()
            }
        }
    }
    
    override var intrinsicContentSize : CGSize {
        var height: Double = 15.0
        for i in 0..<dataArray.count {
            let element = dataArray[i]
            let rows: Array<Dictionary<String, Any>> = element["rows"] as! Array<Dictionary<String, Any>>
            height += 44.0 + Double(rows.count) * 38.0 + 15.0
        }
        return CGSize(width: 0.0, height: height)
    }
    
    override func prepareForReuse() {
        self.dataArray = Array<Dictionary<String, Any>>()
        self.tableView.reloadData()
    }
}
