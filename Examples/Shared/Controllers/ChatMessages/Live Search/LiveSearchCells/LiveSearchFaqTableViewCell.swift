//
//  LiveSearchFaqTableViewCell.swift
//  KoreBotSDKDemo
//
//  Created by Kartheek.Pagidimarri on 14/10/20.
//  Copyright © 2020 Kore. All rights reserved.
//

import UIKit

class LiveSearchFaqTableViewCell: UITableViewCell {

    @IBOutlet weak var subViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var subViewTopConstaint: NSLayoutConstraint!
    @IBOutlet weak var subViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var subView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dislikeButton: UIButton!
    @IBOutlet weak var likeAndDislikeButtonHeightConstrain: NSLayoutConstraint!
    
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
