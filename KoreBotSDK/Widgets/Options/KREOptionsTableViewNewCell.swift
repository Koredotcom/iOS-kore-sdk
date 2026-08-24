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
    private var bgHeightConstraint: NSLayoutConstraint?
    private var bottomSpacingConstraint: NSLayoutConstraint?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        bgView.layer.cornerRadius = 4.0
        bgView.backgroundColor = BubbleViewRightTint
        titleLabel.textColor = BubbleViewUserChatTextColor
        titleLabel.font =   UIFont(name: mediumCustomFont, size: 16.0)
        bgView.clipsToBounds = true
        bgHeightConstraint = bgView.constraints.first(where: { $0.firstAttribute == .height })
        bottomSpacingConstraint = contentView.constraints.first(where: {
            $0.firstItem as? UIView == contentView &&
            $0.firstAttribute == .bottom &&
            $0.secondItem as? UIView == bgView
        })
    }

    func applyButtonHeight(_ height: CGFloat, spacing: CGFloat = 0) {
        if let bgHeightConstraint = bgHeightConstraint {
            bgHeightConstraint.constant = height
        } else {
            let constraint = bgView.heightAnchor.constraint(equalToConstant: height)
            constraint.isActive = true
            bgHeightConstraint = constraint
        }
        bottomSpacingConstraint?.constant = spacing
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
