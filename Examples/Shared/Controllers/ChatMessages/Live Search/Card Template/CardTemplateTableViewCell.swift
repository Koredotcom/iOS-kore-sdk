//
//  CardTemplateTableViewCell.swift
//  KoreBotSDKDemo
//
//  Created by Kartheek.Pagidimarri on 30/10/20.
//  Copyright © 2020 Kore. All rights reserved.
//

import UIKit

class CardTemplateTableViewCell: UITableViewCell {

    @IBOutlet weak var subView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var cardNumberLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var PayNowButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        subView.layer.cornerRadius = 10
        PayNowButton.layer.cornerRadius = 5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
