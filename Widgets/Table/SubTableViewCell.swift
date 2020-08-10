//
//  SubTableViewCell.swift
//  KoreApp
//
//  Created by Srinivas Vasadi on 10/01/18.
//  Copyright © 2018 Kore Inc. All rights reserved.
//

import UIKit

class SubTableViewCell: UITableViewCell, UITableViewDelegate, UITableViewDataSource {
    // MARK: - properties
    var subTableView: UITableView = {
        let tableView = UITableView(frame:.zero)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    let cellReuseIdentifier = "Cell"
    var rows: Array<Array<String>> = Array<Array<String>>()
    var headers: Array<Header> = Array<Header>()
    var sec: Int = Int()
    
    var count = 0
    
    // MARK: - init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func initialize() {
        self.selectionStyle = .none
        self.clipsToBounds = true
        
        subTableView.delegate = self
        subTableView.dataSource = self
        
        self.subTableView.showsHorizontalScrollIndicator = false
        self.subTableView.showsVerticalScrollIndicator = false
        self.subTableView.bounces = false
        self.subTableView.separatorStyle = .none
        self.subTableView.allowsSelection = false
        
        subTableView.register(ExpandedTableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        
        contentView.addSubview(subTableView)
        
        let views: [String: UIView] = ["subTableView": subTableView]
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[subTableView]|", options:[], metrics:nil, views:views))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-15-[subTableView]-15-|", options:[], metrics:nil, views:views))
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if headers.count<rows[sec].count {
            if headers.count % 2 == 0 {
                count = headers.count/2
            } else {
                count = (headers.count+1)/2
            }
        } else {
            if rows[sec].count % 2 == 0 {
                count = rows[sec].count/2
            } else {
                count = (rows[sec].count+1)/2
            }
        }
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ExpandedTableViewCell = self.subTableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! ExpandedTableViewCell
        cell.headers = headers
        
        if (headers.count > (indexPath.row * 2)){
            let dict = headers[indexPath.row*2]
            cell.titleLbl?.text = dict.title
            cell.titleLbl.textAlignment = dict.alignment
            cell.titleLbl.font = UIFont.textFont(ofSize: 1.0, weight: .bold)
            cell.titleLbl.font = cell.titleLbl.font.withSize(10.0)
        }
        
        
        if (headers.count > (indexPath.row * 2+1)){
            let dict = headers[indexPath.row*2+1]
            cell.titleLbl1?.text = dict.title
            cell.titleLbl1.textAlignment = .left
            cell.titleLbl1.font = UIFont.textFont(ofSize: 1.0, weight: .semibold)
            cell.titleLbl1.font = cell.titleLbl.font.withSize(10.0)
        }
        let row = rows[sec]
        if(row.count > indexPath.row*2  && headers.count > indexPath.row*2){
            cell.valueLbl.text = row[indexPath.row*2]
        }
        cell.valueLbl.textAlignment = cell.titleLbl.textAlignment
        if(row.count > indexPath.row*2+1 && headers.count > indexPath.row*2+1) {
            cell.valueLbl1.text = row[indexPath.row*2+1]
        }
        cell.valueLbl1.textAlignment = cell.titleLbl1.textAlignment
        
        
        cell.backgroundColor = UIColor.white
        return cell
    }
    
    override var intrinsicContentSize: CGSize {
        let height: Double = Double(44 * count)
        return CGSize(width: 0.0, height: height)
    }
    
    // MARK: - deinit
    deinit {

    }
}

