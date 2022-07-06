//
//  TaskMenuTablViewCell.swift
//  KoreBotSDKDemo
//
//  Created by MatrixStream_01 on 29/05/20.
//  Copyright © 2020 Kore. All rights reserved.
//

import UIKit

class TaskMenuTablViewCell: UITableViewCell {
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bgView: UIView!
   
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        bgView.layer.cornerRadius = 10
        bgView.layer.borderColor = UIColor.lightGray.cgColor
        
        imgView.clipsToBounds = true
        
        bgView.layer.shadowColor = UIColor.darkGray.cgColor
        bgView.layer.shadowOffset = CGSize(width: 0, height: 0)
        bgView.layer.shadowOpacity = 0.5
        bgView.layer.shadowRadius = 2
        bgView.clipsToBounds = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
