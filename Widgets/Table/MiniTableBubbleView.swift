//
//  ResponsiveTableBubbleView.swift
//  KoreBotSDKDemo
//
//  Created by Sowmya Ponangi on 23/03/18.
//  Copyright © 2018 Kore. All rights reserved.
//

import UIKit

class MiniTableElement: NSObject {
    var header: Header?
    var rows: Array<[String]>?
}

class MiniTableData: NSObject {
    var elements: [MiniTableElement] = [MiniTableElement]()
    
    // MARK: - init
    override init() {
        super.init()
    }
    
    convenience init(_ data: [String: Any]) {
        self.init()
        guard let dataElements = data["elements"] as? Array<[String: Any]> else {
            return
        }

        var percentage: Int = 50
        for dataElement in dataElements {
            guard let columns = dataElement["primary"] as? Array<[String]> else {
                return
            }
            
            let element = MiniTableElement()
            var title: String = ""
            if columns.count > 0, let titles = columns[0] as? [String] {
                title = titles[0]
            }
            
            var alignment: NSTextAlignment = .left
            if columns.count > 1, let column = columns[1] as? [String] {
                let align = column[1]
                if align == "right" {
                    alignment = .right
                } else if align == "center" {
                    alignment = .center
                }
                if column.count > 2, let perc = column[2] as String? {
                    percentage = Int(perc)!
                }
            }
            
            element.header = Header(title: title, alignment: alignment, percentage: percentage)

            if let values = dataElement["additional"] as? Array<[String]> {
                element.rows = values
            }
            elements.append(element)
        }
    }
}

// MARK: - MiniTableBubbleView
open class MiniTableBubbleView: UIView {
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .white
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = false
        tableView.bounces = false
        tableView.separatorStyle = .none
        tableView.clipsToBounds = true
        return tableView
    }()
    lazy var cardView: UIView = {
        let cardView = UIView(frame:.zero)
        cardView.translatesAutoresizingMaskIntoConstraints = false
        return cardView
    }()
    let customCellIdentifier = "CustomCellIdentifier"
    var data: MiniTableData?
    var align0: NSTextAlignment = .left
    var align1: NSTextAlignment = .left
    
    let rowHeight: CGFloat = 40.0
    let headerHeight: CGFloat = 34.0
    
    // MARK: - init
    public override init(frame: CGRect) {
        super.init(frame: .zero)
        initialize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    func intializeCardLayout() {
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
        addSubview(cardView)

        let cardViews: [String: UIView] = ["cardView": cardView]
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-8-[cardView]-8-|", options: [], metrics: nil, views: cardViews))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-8-[cardView]-8-|", options: [], metrics: nil, views: cardViews))
    }
    
    func initialize() {
        intializeCardLayout()
        
        cardView.addSubview(tableView)
        
        tableView.register(MiniTableViewCell.self, forCellReuseIdentifier: customCellIdentifier)
        tableView.register(KREMiniTableHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "KREMiniTableHeaderFooterView")
        
        let views: [String: UIView] = ["tableView": tableView]
        cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[tableView]|", options: [], metrics: nil, views: views))
        cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[tableView]|", options: [], metrics: nil, views: views))
    }
    
    public func populateComponents(_ jsonObject: [String: Any]? = nil) {
        guard let dictionary = jsonObject else {
            data = nil
            tableView.reloadData()
            invalidateIntrinsicContentSize()
            return
        }
        
        data = MiniTableData(dictionary)
        if data?.elements.count ?? 0 > 0 {
            tableView.reloadData()
        }
    }
    
    public func getExpectedHeight() -> CGFloat {
        var height: CGFloat = 0.0
        for section in 0..<tableView.numberOfSections {
            var fittingSize = UIView.layoutFittingCompressedSize
            for row in 0..<tableView.numberOfRows(inSection: section) {
                let cell = tableView(tableView, cellForRowAt: IndexPath(row: row, section: section))
                let size = cell.systemLayoutSizeFitting(fittingSize)
                height += size.height
            }
            if let headerView = tableView(tableView, viewForHeaderInSection: section) {
                let size = headerView.systemLayoutSizeFitting(fittingSize)
                height += size.height
            }
            if let footerView = tableView(tableView, viewForFooterInSection: section) {
                let size = footerView.systemLayoutSizeFitting(fittingSize)
                height += size.height
            }
        }
        return height + 16.0
    }
    
    override open var intrinsicContentSize : CGSize {
        var height = getExpectedHeight()
        return CGSize(width: 0.0, height: height)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension MiniTableBubbleView: UITableViewDelegate, UITableViewDataSource {
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let data = data else {
            return 0
        }
        
        let element = data.elements[section]
        return element.rows?.count ?? 0
    }
    
    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return rowHeight
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        guard let elements = data?.elements else {
            return 0
        }

        return elements.count ?? 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tableViewCell = tableView.dequeueReusableCell(withIdentifier: customCellIdentifier, for: indexPath)
        let element = data?.elements[indexPath.section]
        if let cell = tableViewCell as? MiniTableViewCell, let row = element?.rows?[indexPath.row] {
            let count = row.count
            if count > 0 {
                cell.headerLabel.text = row.first
                cell.headerLabel.font = UIFont.textFont(ofSize: 15.0, weight: .regular)
                cell.headerLabel.font = cell.headerLabel.font.withSize(15.0)
                cell.headerLabel.textColor = UIColor(red: 138/255, green: 149/255, blue: 159/255, alpha: 1)
            }
            if count > 1 {
                cell.secondLbl.text = row.last
                cell.secondLbl.font = UIFont.textFont(ofSize: 15.0, weight: .regular)
                cell.secondLbl.font = cell.headerLabel.font.withSize(15.0)
                
                cell.secondLbl.textColor = UIColor(red: 138/255, green: 149/255, blue: 159/255, alpha: 1)
            }
            cell.backgroundColor = UIColor.white
        }
        return tableViewCell
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "KREMiniTableHeaderFooterView")
        if let view = headerView as? KREMiniTableHeaderFooterView, let data = data {
            let header = data.elements[section].header
            view.headerTitle = header?.title
            view.subHeaderTitle = header?.title
        }
            
        return headerView
    }
    
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView(frame: .zero)
        if section == tableView.numberOfSections - 1 {
            view.backgroundColor = UIColor.clear
        } else {
            view.backgroundColor = UIColor.paleLilacFour
        }
        return view
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    public func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return headerHeight
    }
    
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1.0
    }
}

// MARK: - KREMiniTableHeaderFooterView
class KREMiniTableHeaderFooterView: UITableViewHeaderFooterView {
    // MARK: - properties
    lazy var headerLabel: UILabel = {
        let headerLabel = UILabel(frame: .zero)
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.textAlignment = .left
        headerLabel.font = UIFont.textFont(ofSize: 15.0, weight: .bold)
        headerLabel.font = headerLabel.font.withSize(15.0)
        headerLabel.textColor = UIColor(red: 38/255, green: 52/255, blue: 74/255, alpha: 1)
        return headerLabel
    }()
    
    lazy var secondaryLabel: UILabel = {
        let secondaryLabel = UILabel(frame: .zero)
        secondaryLabel.translatesAutoresizingMaskIntoConstraints = false
        secondaryLabel.textAlignment = .left
        secondaryLabel.font = UIFont.textFont(ofSize: 15.0, weight: .bold)
        secondaryLabel.font = secondaryLabel.font.withSize(15.0)
        secondaryLabel.textColor = UIColor(red: 38/255, green: 52/255, blue: 74/255, alpha: 1)
        return secondaryLabel
    }()

    var headerTitle: String? {
        didSet {
            headerLabel.text = headerTitle
        }
    }
    
    var subHeaderTitle: String? {
        didSet {
            headerLabel.text = subHeaderTitle
        }
    }
    
    // MARK: -
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    // MARK: - setup
    func setup() {
        contentView.addSubview(headerLabel)
        contentView.addSubview(secondaryLabel)

        let views: [String: UIView] = ["headerLabel": headerLabel, "secondaryLabel": secondaryLabel]
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[headerLabel]-[secondaryLabel]-|", options:[], metrics:nil, views:views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-8-[headerLabel]-4-|", options:[], metrics:nil, views:views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-8-[secondaryLabel]-4-|", options:[], metrics:nil, views:views))
    }
}
