//
//  AdvancedMultiSelectCell.swift
//  KoreBotSDKDemo
//
//  Created by Kartheek Pagidimarri on 11/10/23.
//  Copyright © 2023 Kore. All rights reserved.
//

import UIKit

class AdvancedMultiSelectCell: UITableViewCell {
    @IBOutlet weak var checkImage: UIImageView!
    @IBOutlet weak var bgV: UIView!
    @IBOutlet weak var imagV: UIImageView!
    @IBOutlet weak var descLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var imgVWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var imgVLeadingConstraint: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        titleLbl.font = UIFont(name: "HelveticaNeue-Bold", size: 15.0)
        descLbl.font = UIFont(name: "HelveticaNeue", size: 12.0)
        bgV.layer.cornerRadius = 5.0
        bgV.layer.borderWidth = 1.0
        bgV.layer.borderColor = UIColor.lightGray.cgColor
        bgV.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
