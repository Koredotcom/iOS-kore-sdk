//
//  LeftMenuCell.swift
//  KoreBotSDKFrameWork
//
//  Created by Kartheek.Pagidimarri on 29/09/22.
//  Copyright © 2022 Kartheek.Pagidimarri. All rights reserved.
//

import UIKit

class LeftMenuCell: UITableViewCell {
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet var iconImageV: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        self.titleLabel.font = UIFont(name: mediumCustomFont, size: 14.0)
    }
    
}
