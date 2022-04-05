//
//  RecentSearchCell.swift
//  KoreBotSDKDemo
//
//  Created by Kartheek.Pagidimarri on 25/02/22.
//  Copyright © 2022 Kore. All rights reserved.
//

import UIKit

class RecentSearchCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subView: UIView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var closeButtonWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var subVTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var subVLeadingConstraint: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        subView.layer.cornerRadius = 10
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
