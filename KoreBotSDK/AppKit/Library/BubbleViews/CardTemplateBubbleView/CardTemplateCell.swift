//
//  CardTemplateCell.swift
//  KoreBotSDKFrameWork
//
//  Created by Kartheek Pagidimarri on 31/07/23.
//  Copyright © 2023 Kartheek.Pagidimarri. All rights reserved.
//

import UIKit

class CardTemplateCell: UITableViewCell {
    @IBOutlet weak var imagV: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    
    @IBOutlet weak var underlineLbl: UILabel!
    
    @IBOutlet weak var rightLineLbl: UILabel!
    @IBOutlet weak var leftLineLbl: UILabel!
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
