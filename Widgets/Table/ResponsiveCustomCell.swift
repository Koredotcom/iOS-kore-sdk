//
//  ResponsiveCustomCell.swift
//  KoreApp
//
//  Created by Srinivas Vasadi on 10/01/18.
//  Copyright © 2018 Kore Inc. All rights reserved.
//

import UIKit

class ResponsiveCustomCell: UITableViewCell {
    // MARK: - properties
    lazy var headerLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    lazy var secondLbl: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: properties with observers
    override func prepareForReuse() {
        headerLabel.text = ""
        secondLbl.text = ""
    }
    
    func initialize() {
        selectionStyle = .default
        clipsToBounds = true
        
        headerLabel.textAlignment = .left
        headerLabel.font = UIFont.textFont(ofSize: 16.0, weight: .regular)
        headerLabel.textColor = UIColor(red: 38/255, green: 52/255, blue: 74/255, alpha: 1)
        contentView.addSubview(headerLabel)
        
        secondLbl.textAlignment = .left
        secondLbl.font = UIFont.textFont(ofSize: 16.0, weight: .regular)
        secondLbl.textColor = UIColor(red: 38/255, green: 52/255, blue: 74/255, alpha: 1)
        contentView.addSubview(secondLbl)
        
        let views: [String: UIView] = ["headerLabel": headerLabel, "secondLbl":secondLbl]
         contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[headerLabel]-[secondLbl]-40-|", options:[], metrics:nil, views:views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[headerLabel]-|", options:[], metrics:nil, views:views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[secondLbl]|", options:[], metrics:nil, views:views))
    }
    
    // MARK:- deinit
    deinit {

    }
}
