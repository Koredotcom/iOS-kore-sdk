//
//  AdvancedListDefaultCell.swift
//  KoreBotSDKFrameWork
//
//  Created by Kartheek Pagidimarri on 24/07/23.
//  Copyright © 2023 Kartheek.Pagidimarri. All rights reserved.
//

import UIKit

class AdvancedListDefaultCell: UITableViewCell {

    @IBOutlet weak var imagV: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
