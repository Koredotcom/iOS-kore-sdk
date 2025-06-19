//
//  ListwidgetCell.swift
//  KoreBotSDK
//
//  Created by Pagidimarri Kartheek on 13/05/25.
//

import UIKit

class ListwidgetCell: UITableViewCell {

    @IBOutlet weak var arrowBtn: UIButton!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var imageV: UIImageView!
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
