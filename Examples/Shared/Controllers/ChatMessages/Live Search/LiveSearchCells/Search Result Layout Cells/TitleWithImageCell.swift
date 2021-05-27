//
//  TitleWithImageCell.swift
//  KoreBotSDKDemo
//
//  Created by Kartheek.Pagidimarri on 24/05/21.
//  Copyright © 2021 Kore. All rights reserved.
//

import UIKit

class TitleWithImageCell: UITableViewCell {
    
    @IBOutlet weak var subViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var subViewTopConstaint: NSLayoutConstraint!
    @IBOutlet weak var subViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var subView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dislikeButton: UIButton!
    @IBOutlet weak var likeAndDislikeButtonHeightConstrain: NSLayoutConstraint!
    
    @IBOutlet weak var subViewBottomConstrain: NSLayoutConstraint!
    @IBOutlet weak var underLineLabel: UILabel!
    @IBOutlet weak var topImageV: UIImageView!
    @IBOutlet weak var topImageVWidthConstrain: NSLayoutConstraint!
    @IBOutlet weak var topImageVHeightConstrain: NSLayoutConstraint!
    
    @IBOutlet weak var bottomImageV: UIImageView!
    @IBOutlet weak var bottomImageVWidthConstrain: NSLayoutConstraint!
    @IBOutlet weak var bottomImageVHeightConstrain: NSLayoutConstraint!
    
    
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
