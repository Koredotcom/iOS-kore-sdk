//
//  NewListTableViewCell.swift
//  KoreBotSDKDemo
//
//  Created by MatrixStream_01 on 13/05/20.
//  Copyright © 2020 Kore. All rights reserved.
//

import UIKit

class NewListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var imageViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bgView.layer.cornerRadius = 10
        bgView.layer.borderWidth = 1
        bgView.layer.borderColor = BubbleViewLeftTint.cgColor
        
        titleLabel.textColor = BubbleViewBotChatTextColor
        subTitleLabel.textColor = BubbleViewBotChatTextColor
        priceLbl.textColor = UIColor.init(hexString: "#16A34A")
        
//        titleLabel.font =  UIFont(name: semiBoldCustomFont, size: 14.0)
//        subTitleLabel.font = UIFont(name: regularCustomFont, size: 12.0)
//        priceLbl.font = UIFont(name: semiBoldCustomFont, size: 14.0)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
