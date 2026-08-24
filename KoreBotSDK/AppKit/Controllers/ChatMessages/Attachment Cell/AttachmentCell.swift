//
//  AttachmentCell.swift
//  KoreBotSDKDemo
//
//  Created by Kartheek.Pagidimarri on 04/11/20.
//  Copyright © 2020 Kore. All rights reserved.
//

import UIKit

class AttachmentCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var closeButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 3
        imageView.clipsToBounds = true
        closeButton.layer.cornerRadius = 10
        closeButton.clipsToBounds = true
        closeButton.backgroundColor = UIColor(red: 71/255, green: 65/255, blue: 250/255, alpha: 1)
    }

}
