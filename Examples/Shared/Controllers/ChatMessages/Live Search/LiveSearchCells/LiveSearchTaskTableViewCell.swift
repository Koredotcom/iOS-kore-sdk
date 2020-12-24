//
//  LiveSearchTaskTableViewCell.swift
//  KoreBotSDKDemo
//
//  Created by Kartheek.Pagidimarri on 14/10/20.
//  Copyright © 2020 Kore. All rights reserved.
//

import UIKit

class LiveSearchTaskTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var subView: UIView!
    @IBOutlet weak var subViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var subViewTopConstaint: NSLayoutConstraint!
    @IBOutlet weak var subViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        subView.layer.cornerRadius = 10
        subView.backgroundColor = UIColor.init(red: 245/255, green: 248/255, blue: 250/255, alpha: 1.0)
        
        subView.layer.shadowColor = UIColor.darkGray.cgColor
        subView.layer.shadowOffset = CGSize(width: 0, height: 0)
        subView.layer.shadowOpacity = 0.5
        subView.layer.shadowRadius = 2
        subView.clipsToBounds = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
