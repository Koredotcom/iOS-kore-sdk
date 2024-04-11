//
//  BannersCell.swift
//  KoreBotSDKDemo
//
//  Created by Kartheek Pagidimarri on 11/09/23.
//  Copyright © 2023 Kore. All rights reserved.
//

import UIKit

class BannersCell: UITableViewCell {
    @IBOutlet weak var bgV: UIView!
    @IBOutlet weak var bannerImagV: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        bannerImagV.layer.cornerRadius = 4.0
        bannerImagV.clipsToBounds = true
        bannerImagV.contentMode = .scaleToFill
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
