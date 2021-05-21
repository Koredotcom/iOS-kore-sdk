//
//  MultiSelectCell.swift
//  KoreBotSDKDemo
//
//  Created by Kartheek Pagidimarri on 8/17/20.
//  Copyright © 2020 Kore. All rights reserved.
//

import UIKit

class MultiSelectCell: UITableViewCell {
    @IBOutlet weak var checkImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
