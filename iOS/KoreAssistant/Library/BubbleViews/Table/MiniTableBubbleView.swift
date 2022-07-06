//
//  ResponsiveTableBubbleView.swift
//  KoreBotSDKDemo
//
//  Created by Sowmya Ponangi on 23/03/18.
//  Copyright © 2018 Kore. All rights reserved.
//




import UIKit

struct MiniHeader {
    var title: String = ""
    var alignment: NSTextAlignment = .left
    var percentage: Int = 0
    
}

class MiniTableData {
    var headers: Array<Header> = Array<Header>()
    var rows: Array<Array<String>> = Array<Array<String>>()
    
    var primaryHeads: Array<Array<String>> = Array<Array<String>>()
    var additional: Array<Array<String>> = Array<Array<String>>()
    var elements:Array<Dictionary<String, Any>> = Array<Dictionary<String, Any>>()
    
    convenience init(_ data: Dictionary<String, Any>){
        self.init()
        guard let locElements = data["elements"] as? Array<Dictionary<String, Any>> else { return }
        elements = locElements
        
        var percentage: Int = 50//Int(floor(Double(100/columns.count)))
        for element in elements {
            guard let columns = element["primary"] as? Array<Array<String>> else { return }
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
            print(headers)
            let values = element["additional"] as! Array<Any>
            var row = Array<String>()
            for value in values {
                for v in value as! [Any] {
                    let val = v as? String ?? ""
                    row.append(val)
                }
            }
            rows.append(row)
            print(rows)
        }
    }
}

class MiniTableBubbleView: BubbleView, UITableViewDelegate, UITableViewDataSource {
    var tableView: UITableView!
    var titleLbl: UILabel!
    var cardView: UIView!
    let customCellIdentifier = "CustomCellIdentifier"
    var data: MiniTableData = MiniTableData()
    let rowsDataLimit = 6
    var align0:NSTextAlignment = .left
    var align1:NSTextAlignment = .left
    
    let kMaxTextWidth: CGFloat = BubbleViewMaxWidth - 20.0
    let kMinTextWidth: CGFloat = 20.0
    
    var tileBgv: UIView!
    
    override func applyBubbleMask() {
        //nothing to put here
        if(self.maskLayer == nil){
            self.maskLayer = CAShapeLayer()
            self.tileBgv.layer.mask = self.maskLayer
        }
        self.maskLayer.path = self.createBezierPath().cgPath
        self.maskLayer.position = CGPoint(x:0, y:0)
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
        NotificationCenter.default.post(name: Notification.Name(reloadTableNotification), object: nil)

    }
    
    override func initialize() {
        super.initialize()
        intializeCardLayout()
        
        
        self.tileBgv = UIView(frame:.zero)
        self.tileBgv.translatesAutoresizingMaskIntoConstraints = false
        self.cardView.addSubview(self.tileBgv)
        self.tileBgv.layer.rasterizationScale =  UIScreen.main.scale
        self.tileBgv.layer.shouldRasterize = true
        self.tileBgv.layer.cornerRadius = 2.0
        self.tileBgv.clipsToBounds = true
        self.tileBgv.backgroundColor =  Common.UIColorRGB(0xEDEFF2)
        
        
        self.tableView = UITableView(frame: CGRect.zero,style:.grouped)
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.backgroundColor = .white
        self.tableView.showsHorizontalScrollIndicator = false
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.bounces = false
        self.tableView.separatorStyle = .none
        self.cardView.addSubview(self.tableView)
        self.tableView.isScrollEnabled = false
        tableView.register(MiniTableViewCell.self, forCellReuseIdentifier: customCellIdentifier)
        
        let views: [String: UIView] = ["tileBgv": tileBgv, "tableView": tableView]
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-15-[tileBgv]-[tableView]-20-|", options: [], metrics: nil, views: views))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-25-[tileBgv]-25-|", options: [], metrics: nil, views: views))
        self.cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[tableView]-15-|", options: [], metrics: nil, views: views))
        
        self.titleLbl = UILabel(frame: CGRect.zero)
        self.titleLbl.textColor = Common.UIColorRGB(0x484848)
        self.titleLbl.font = UIFont(name: "HelveticaNeue-Medium", size: 16.0)
        self.titleLbl.numberOfLines = 0
        self.titleLbl.lineBreakMode = NSLineBreakMode.byWordWrapping
        self.titleLbl.isUserInteractionEnabled = true
        self.titleLbl.contentMode = UIView.ContentMode.topLeft
        self.titleLbl.translatesAutoresizingMaskIntoConstraints = false
        self.tileBgv.addSubview(self.titleLbl)
        self.titleLbl.adjustsFontSizeToFitWidth = true
        self.titleLbl.backgroundColor = .clear
        self.titleLbl.layer.cornerRadius = 6.0
        self.titleLbl.clipsToBounds = true
        self.titleLbl.sizeToFit()
        
        let subView: [String: UIView] = ["titleLbl": titleLbl]
        self.tileBgv.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-5-[titleLbl(>=31)]-5-|", options: [], metrics: nil, views: subView))
        self.tileBgv.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[titleLbl]-10-|", options: [], metrics: nil, views: subView))
    }
    
    override func populateComponents() {
        if (components.count > 0) {
            let component: KREComponent = components.firstObject as! KREComponent
            if (component.componentDesc != nil) {
                let jsonString = component.componentDesc
                let jsonObject: NSDictionary = Utilities.jsonObjectFromString(jsonString: jsonString!) as! NSDictionary
                let data: Dictionary<String, Any> = jsonObject as! Dictionary<String, Any>
                self.data = MiniTableData(data)
                var rowsDataCount = 0
                var index = 0
                for row in self.data.rows {
                    index += 1
                    let text = row[0]
                    if text != "---" {
                        rowsDataCount += 1
                    }
                    
                    if  self.data.rows[self.data.rows.count-1][0] != "---" {
                        self.data.rows.append(["---"])
                    }
                    self.titleLbl.text = "\(data["text"] ?? "")"
                    self.tableView.reloadData()
                }
                
            }
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return data.rows[section].count/2
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return data.elements.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : MiniTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: customCellIdentifier) as! MiniTableViewCell
        let rows = data.rows[indexPath.section]
        if (rows.count > (indexPath.row * 2)){
            cell.headerLabel.text = rows[indexPath.row*2]
            cell.headerLabel.numberOfLines = 0
            cell.headerLabel.font = UIFont(name: "Lato-Regular", size: 15.0)
            cell.headerLabel.font = cell.headerLabel.font.withSize(15.0)
            cell.headerLabel.textColor = UIColor(red: 138/255, green: 149/255, blue: 159/255, alpha: 1)
        }
        if (rows.count > (indexPath.row * 2+1)){
            cell.secondLbl.text = rows[indexPath.row*2+1]
            cell.secondLbl.textAlignment = .right
            cell.secondLbl.font = UIFont(name: "Lato-Regular", size: 15.0)
            cell.secondLbl.font = cell.headerLabel.font.withSize(15.0)
            
            cell.secondLbl.textColor = UIColor(red: 138/255, green: 149/255, blue: 159/255, alpha: 1)
        }
        cell.backgroundColor = UIColor.white
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        
        let headerLabel = UILabel(frame: .zero)
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.textAlignment = .left
        headerLabel.font = UIFont(name: "Lato-Bold", size: 15.0)
        headerLabel.font = headerLabel.font.withSize(15.0)
        
        headerLabel.textColor = UIColor(red: 38/255, green: 52/255, blue: 74/255, alpha: 1)
        headerLabel.text =  data.headers[section*2].title
        view.addSubview(headerLabel)
        
        let secondLbl = UILabel(frame: .zero)
        secondLbl.translatesAutoresizingMaskIntoConstraints = false
        secondLbl.textAlignment = .left
        secondLbl.font = UIFont(name: "Lato-Bold", size: 15.0)
        secondLbl.font = secondLbl.font.withSize(15.0)
        secondLbl.textColor = UIColor(red: 38/255, green: 52/255, blue: 74/255, alpha: 1)
        secondLbl.text =  data.headers[section*2+1].title
        view.addSubview(secondLbl)
        
        let views: [String: UIView] = ["headerLabel": headerLabel, "secondLbl":secondLbl]
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[headerLabel]-[secondLbl]-15-|", options:[], metrics:nil, views:views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-15-[headerLabel]-15-|", options:[], metrics:nil, views:views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-15-[secondLbl]-15-|", options:[], metrics:nil, views:views))
        
        return view
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.layer.shadowColor = UIColor.lightGray.cgColor
        view.layer.shadowOffset = CGSize(width:1.0, height:1.0);
        view.layer.shadowRadius = 1.0
        view.layer.shadowOpacity = 1.0
        return view
    }
    
    override var intrinsicContentSize : CGSize {
        
        let limitingSize: CGSize  = CGSize(width: kMaxTextWidth, height: CGFloat.greatestFiniteMagnitude)
        var textSize: CGSize = self.titleLbl.sizeThatFits(limitingSize)
        if textSize.height < self.titleLbl.font.pointSize {
            textSize.height = self.titleLbl.font.pointSize
        }
        
        var cellHeight : CGFloat = 0.0
        let rows = self.data.rows
        var finalHeight: CGFloat = 0.0
        for i in 0..<rows.count {
            let row = rows[i]
            var j: Int = 0
            for text in row {
                if text == "---" {
                    finalHeight += 1.0
                } else {
                    let row = tableView.dequeueReusableCell(withIdentifier: customCellIdentifier, for: IndexPath(row: j, section: i))as! MiniTableViewCell
                    cellHeight = row.bounds.height
                    finalHeight += cellHeight
                    j += 1
                }
            }
        }
        
        return CGSize(width: 0.0, height: finalHeight + textSize.height)
    }
    
}

