//
//  AdvancedListOptionsCell.swift
//  KoreBotSDKFrameWork
//
//  Created by Kartheek Pagidimarri on 21/07/23.
//  Copyright © 2023 Kartheek.Pagidimarri. All rights reserved.
//

import UIKit

class AdvancedListOptionsCell: UITableViewCell {

    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var checkBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
