//
//  KREInformationViewCell.swift
//  KoreApp
//
//  Created by Srinivas Vasadi on 10/01/18.
//  Copyright © 2018 Kore Inc. All rights reserved.
//

import UIKit

class ResponsiveCustonCell: UITableViewCell {
    // MARK: - properties
    
    var headerLabel: UILabel!
    var secondLbl : UILabel!
   
   
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: properties with observers
    override func prepareForReuse() {
        headerLabel.text = ""
        secondLbl.text = ""
    
    }
    
    func initialize() {
        self.selectionStyle = .default
        self.clipsToBounds = true
        
        headerLabel = UILabel(frame: .zero)
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.textAlignment = .left
        headerLabel.font = UIFont(name: "Gilroy-Regular", size: 16.0)
        headerLabel.textColor = UIColor(red: 38/255, green: 52/255, blue: 74/255, alpha: 1)

        contentView.addSubview(headerLabel)
        
        secondLbl = UILabel(frame: .zero)
        secondLbl.translatesAutoresizingMaskIntoConstraints = false
        secondLbl.textAlignment = .left
        secondLbl.font = UIFont(name: "Gilroy-Regular", size: 16.0)
        secondLbl.textColor = UIColor(red: 38/255, green: 52/255, blue: 74/255, alpha: 1)
        contentView.addSubview(secondLbl)
        
        let views: [String: UIView] = ["headerLabel": headerLabel, "secondLbl":secondLbl]
         self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[headerLabel]-[secondLbl]-40-|", options:[], metrics:nil, views:views))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[headerLabel]-|", options:[], metrics:nil, views:views))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[secondLbl]|", options:[], metrics:nil, views:views))
    }
    
   
    // MARK:- deinit
    deinit {
        
        headerLabel = nil
        secondLbl = nil
    
    }
}
