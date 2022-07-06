//
//  CustomTableViewCell.swift
//  KoreBotSDKDemo
//
//  Created by Kartheek.Pagidimarri on 05/01/22.
//  Copyright © 2022 Kore. All rights reserved.
//

import UIKit

class CustomTableViewCell: UICollectionViewCell {
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var underLineLbl: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
