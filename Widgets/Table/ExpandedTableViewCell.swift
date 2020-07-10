//
//  KREInformationViewCell.swift
//  KoreApp
//
//  Created by Srinivas Vasadi on 10/01/18.
//  Copyright © 2018 Kore Inc. All rights reserved.
//

import UIKit

class ExpandedTableViewCell: UITableViewCell {
    // MARK: - properties
    var titleLbl: UILabel!
    var valueLbl : UILabel!
    var titleLbl1: UILabel!
    var valueLbl1 : UILabel!
    var headers: Array<Header> = Array<Header>()
    
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
        titleLbl.text = ""
        valueLbl.text = ""
        titleLbl1.text = ""
        valueLbl1.text = ""
    }
    
    func initialize() {
        selectionStyle = .default
        clipsToBounds = true
        
        titleLbl = UILabel(frame: .zero)
        titleLbl.translatesAutoresizingMaskIntoConstraints = false
        titleLbl.textAlignment = .left
        titleLbl.textColor = UIColor(red: 179/255, green: 186/255, blue: 200/255, alpha: 1)
        contentView.addSubview(titleLbl)
        
        valueLbl = UILabel(frame: .zero)
        valueLbl.translatesAutoresizingMaskIntoConstraints = false
        valueLbl.textAlignment = .left
        valueLbl.font = UIFont.textFont(ofSize: 16.0, weight: .regular)
        valueLbl.font = valueLbl.font.withSize(16.0)
        valueLbl.textColor =  UIColor(red: 38/255, green: 52/255, blue: 74/255, alpha: 1)
        contentView.addSubview(valueLbl)
        
        titleLbl1 = UILabel(frame: .zero)
        titleLbl1.translatesAutoresizingMaskIntoConstraints = false
        titleLbl1.textAlignment = .left
        titleLbl1.textColor =  UIColor(red: 179/255, green: 186/255, blue: 200/255, alpha: 1)
        contentView.addSubview(titleLbl1)
        
        valueLbl1 = UILabel(frame: .zero)
        valueLbl1.translatesAutoresizingMaskIntoConstraints = false
        valueLbl1.textAlignment = .left
        valueLbl1.font = UIFont.textFont(ofSize: 16.0, weight: .regular)
        valueLbl1.font = valueLbl.font.withSize(16.0)
        valueLbl1.textColor =  UIColor(red: 38/255, green: 52/255, blue: 74/255, alpha: 1)
        contentView.addSubview(valueLbl1)
        
        let views: [String: UIView] = ["titleLbl": titleLbl, "valueLbl":valueLbl,"titleLbl1": titleLbl1, "valueLbl1":valueLbl1]
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[titleLbl]", options:[], metrics:nil, views:views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[valueLbl]", options:[], metrics:nil, views:views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[titleLbl1]-40-|", options:[], metrics:nil, views:views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[valueLbl1]-40-|", options:[], metrics:nil, views:views))
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-15-[titleLbl]-[valueLbl]-15-|", options:[], metrics:nil, views:views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-15-[titleLbl1]-[valueLbl1]-15-|", options:[], metrics:nil, views:views))
    }
    
    // MARK: - deinit
    deinit {
        titleLbl = nil
        valueLbl = nil
        titleLbl1 = nil
        valueLbl1 = nil
    }
}

