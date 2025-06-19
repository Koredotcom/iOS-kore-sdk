//
//  StackedButtonCell.swift
//  KoreBotSDKDemo
//
//  Created by Kartheek Pagidimarri on 09/10/23.
//  Copyright © 2023 Kore. All rights reserved.
//

import UIKit

class StackedButtonCell: UITableViewCell {

    @IBOutlet weak var bgV: UIView!
    @IBOutlet weak var textLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        bgV.layer.cornerRadius = 5.0
        bgV.clipsToBounds = true
        // Configure the view for the selected state
    }
    
}
