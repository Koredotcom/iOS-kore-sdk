//
//  KREOptionsTableViewNewCell.swift
//  KoreBotSDK
//
//  Created by Pagidimarri Kartheek on 29/04/25.
//

import UIKit

class KREOptionsTableViewNewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bgView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        bgView.layer.cornerRadius = 5.0
        bgView.backgroundColor = BubbleViewRightTint
        titleLabel.textColor = BubbleViewUserChatTextColor
        titleLabel.font =   UIFont(name: mediumCustomFont, size: 14.0)
        bgView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
