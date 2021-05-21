//
//  InlineFormTableViewCell.swift
//  KoreBotSDKDemo
//
//  Created by Kartheek.Pagidimarri on 06/04/21.
//  Copyright © 2021 Kore. All rights reserved.
//

import UIKit

class InlineFormTableViewCell: UITableViewCell {

    @IBOutlet weak var tiltLbl: UILabel!
    @IBOutlet weak var textFeildName: UITextField!
    @IBOutlet weak var titileLblHeightConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        textFeildName.layer.cornerRadius = 5.0
        textFeildName.clipsToBounds = true
        textFeildName.layer.borderWidth = 1.0
        textFeildName.layer.borderColor = UIColor.darkGray.cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
