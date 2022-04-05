//
//  GridCollectionViewCell.swift
//  KoreBotSDKDemo
//
//  Created by Kartheek.Pagidimarri on 01/06/21.
//  Copyright © 2021 Kore. All rights reserved.
//

import UIKit

class GridCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var leftImagV: UIImageView!
    @IBOutlet weak var topImgV: UIImageView!
    
    @IBOutlet weak var topImavHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleLblLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftImgVWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var descriptionLblTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var descriptionLblHeightConstaraint: NSLayoutConstraint!
    
    
    @IBOutlet weak var titleLblHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var priceLblHeightConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 5.0
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOffset =  CGSize.zero
        self.layer.shadowOpacity = 0.5
        self.layer.shadowRadius = 4
        // Initialization code
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
    }

}
