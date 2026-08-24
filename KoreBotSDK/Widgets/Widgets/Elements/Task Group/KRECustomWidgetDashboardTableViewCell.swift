//
//  KRECustomWidgetDashboardTableViewCell.swift
//  KoreBotSDK
//
//  Created by Sukhmeet Singh on 20/11/19.
//

import UIKit

open class KRECustomWidgetDashboardTableViewCell: UITableViewCell {
   
   public let bubbleView = KADashBordBubble()
    // MARK: - init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initialize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    // MARK: properties with observers
    override open func prepareForReuse() {
    }
    
    func initialize() {
        bubbleView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(bubbleView)
        let views = ["bubbleView": bubbleView]
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[bubbleView]|", options: [], metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[bubbleView]|", options: [], metrics: nil, views: views))
    }
}


