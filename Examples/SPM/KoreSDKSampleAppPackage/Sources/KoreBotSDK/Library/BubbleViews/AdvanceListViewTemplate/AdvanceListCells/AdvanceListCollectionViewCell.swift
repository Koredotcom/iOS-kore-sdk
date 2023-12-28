//
//  AdvanceListCollectionViewCell.swift
//  KoreBotSDKFrameWork
//
//  Created by Kartheek Pagidimarri on 26/07/23.
//  Copyright © 2023 Kartheek.Pagidimarri. All rights reserved.
//

import UIKit

class AdvanceListCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imagV: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var valueLbl: UILabel!
    @IBOutlet weak var imagVwidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var imagVHeightConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
