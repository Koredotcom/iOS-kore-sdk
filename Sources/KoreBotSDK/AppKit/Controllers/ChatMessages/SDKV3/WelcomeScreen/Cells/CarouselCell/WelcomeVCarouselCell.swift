//
//  WelcomeVCarouselCell.swift
//  KoreBotSDKDemo
//
//  Created by Kartheek Pagidimarri on 11/09/23.
//  Copyright © 2023 Kore. All rights reserved.
//

import UIKit

class WelcomeVCarouselCell: UICollectionViewCell {
    let bundle = Bundle.sdkModule
    @IBOutlet weak var imagV: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var descLbl: UILabel!
    @IBOutlet weak var arrowImgv: UIImageView!
    @IBOutlet weak var bgV: UIView!
    let borderColor = UIColor(hexString: "#E4E5E7")
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        titleLbl.font = UIFont(name: "HelveticaNeue-Bold", size: 16.0)
        titleLbl.textColor = UIColor(hexString: "#202124")
        descLbl.textColor = UIColor(hexString: "#4B5565")
        descLbl.font = UIFont(name: "HelveticaNeue", size: 14.0)
        bgV.layer.cornerRadius = 4.0
        bgV.layer.borderWidth = 1.0
        bgV.layer.borderColor = borderColor.cgColor
        bgV.clipsToBounds = true
        
        let arrowImage = UIImage(named: "leftarrow", in: bundle, compatibleWith: nil)
        let tintedarrowImage = arrowImage?.withRenderingMode(.alwaysTemplate)
        arrowImgv.image = tintedarrowImage
        arrowImgv.tintColor = UIColor(hexString: "#4B5565")
    }

}
