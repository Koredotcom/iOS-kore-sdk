//
//  KREWidgetEditFooter.swift
//  KoreBotSDK
//
//  Created by Sukhmeet Singh on 13/01/20.
//

import UIKit


class KREWidgetEditFooterTableViewCell: UITableViewCell {
    // MARK: - init
    
    let footerLabel: UIButton = {
        let footerLabel = UIButton(frame: .zero)
        footerLabel.translatesAutoresizingMaskIntoConstraints = false
        footerLabel.setTitle("Edit", for: .normal)
        footerLabel.titleLabel?.font = UIFont.textFont(ofSize: 13, weight: .bold)
        footerLabel.setTitleColor(UIColor.lightRoyalBlue, for: .normal)
        return footerLabel
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        intialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        intialize()
    }
    
    // MARK: - intialize
    func intialize() {
        contentView.addSubview(footerLabel)
        let bubbleViews: [String: UIView] = ["footerLabel": footerLabel]
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[footerLabel(40)]|", options: [], metrics: nil, views: bubbleViews))
        
        footerLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        footerLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
    }
}
