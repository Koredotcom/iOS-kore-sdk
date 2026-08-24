//
//  AdvancedTextCell.swift
//  KoreBotSDKFrameWork
//
//  Created by Kartheek Pagidimarri on 19/07/23.
//  Copyright © 2023 Kartheek.Pagidimarri. All rights reserved.
//

import UIKit

class AdvancedTextCell: UITableViewCell {

    @IBOutlet weak var bgV: UIView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var descLbl: UILabel!
    @IBOutlet weak var imagV: UIImageView!
    @IBOutlet weak var btn: UIButton!
    @IBOutlet weak var desciptionIcon: UIImageView!
    @IBOutlet weak var descLblLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var descriptionRightIcon: UIImageView!
    @IBOutlet weak var titlLblLedingConstraint: NSLayoutConstraint!
    @IBOutlet weak var descIconWidthConstaint: NSLayoutConstraint!
    @IBOutlet weak var imagVwidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var btnWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var arrowImag: UIImageView!
    @IBOutlet weak var arrowImgwidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var underlineLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        titleLbl.textColor = .black
        descLbl.textColor = .lightGray
        
        titleLbl.font = UIFont(name: mediumCustomFont, size: 15.0)
        descLbl.font = UIFont(name: mediumCustomFont, size: 12.0)
        btn.titleLabel?.font = UIFont(name: mediumCustomFont, size: 14.0)
        btn.layer.cornerRadius = 4.0
        btn.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
