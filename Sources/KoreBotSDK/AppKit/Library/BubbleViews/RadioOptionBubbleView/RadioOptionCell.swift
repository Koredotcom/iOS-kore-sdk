//
//  RadioOptionCell.swift
//  KoreBotSDKDemo
//
//  Created by Kartheek Pagidimarri on 17/10/23.
//  Copyright © 2023 Kore. All rights reserved.
//

import UIKit

class RadioOptionCell: UITableViewCell {
    @IBOutlet weak var checkImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var bgV: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
