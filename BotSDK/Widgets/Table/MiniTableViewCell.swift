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
    lazy var headerLabel: UILabel = {
        let headerLabel = UILabel(frame: .zero)
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.textAlignment = .left
        headerLabel.font = UIFont.textFont(ofSize: 15.0, weight: .regular)
        headerLabel.font = headerLabel.font.withSize(15.0)
        headerLabel.textColor = UIColor.black
        return headerLabel
    }()
    lazy var secondLbl : UILabel = {
        let secondLbl = UILabel(frame: .zero)
        secondLbl.translatesAutoresizingMaskIntoConstraints = false
        secondLbl.textAlignment = .left
        secondLbl.font = UIFont.textFont(ofSize: 15.0, weight: .regular)
        secondLbl.font = secondLbl.font.withSize(15.0)
        secondLbl.textColor = UIColor.black
        return secondLbl
    }()

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
        headerLabel.text = nil
        secondLbl.text = nil
    }
    
    func initialize() {
        selectionStyle = .none
        backgroundColor = .clear
        clipsToBounds = true
        
        contentView.addSubview(headerLabel)
        contentView.addSubview(secondLbl)
        
        let views: [String: UIView] = ["headerLabel": headerLabel, "secondLbl": secondLbl]
         contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[headerLabel]-[secondLbl]-|", options:[], metrics:nil, views:views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-4-[headerLabel]-4-|", options:[], metrics: nil, views:views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-4-[secondLbl]-4-|", options:[], metrics: nil, views:views))
    }
    
    // MARK:- deinit
    deinit {

    }
}
