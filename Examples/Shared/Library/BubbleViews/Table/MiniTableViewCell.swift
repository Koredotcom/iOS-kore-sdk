//
//  ResponsiveTableBubbleView.swift
//  KoreBotSDKDemo
//
//  Created by Sowmya Ponangi on 23/03/18.
//  Copyright © 2018 Kore. All rights reserved.
//


import UIKit

class MiniTableViewCell: UITableViewCell {
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
        headerLabel.font = UIFont(name: "Lato-Regular", size: 15.0)
        headerLabel.font = headerLabel.font.withSize(15.0)

        headerLabel.textColor = UIColor.black
        contentView.addSubview(headerLabel)
        
        secondLbl = UILabel(frame: .zero)
        secondLbl.translatesAutoresizingMaskIntoConstraints = false
        secondLbl.textAlignment = .left
        secondLbl.font = UIFont(name: "Lato-Regular", size: 15.0)
        secondLbl.font = secondLbl.font.withSize(15.0)

        secondLbl.textColor = UIColor.black
        contentView.addSubview(secondLbl)
        
        let views: [String: UIView] = ["headerLabel": headerLabel, "secondLbl":secondLbl]
         self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[headerLabel]-[secondLbl]-15-|", options:[], metrics:nil, views:views))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-15-[headerLabel]-15-|", options:[], metrics:nil, views:views))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-15-[secondLbl]-15-|", options:[], metrics:nil, views:views))
        
        

    }
    
    // MARK:- deinit
    deinit {
        
        headerLabel = nil
        secondLbl = nil
    
    }
}
