//
//  TaskMenuTablViewCell.swift
//  KoreBotSDKDemo
//
//  Created by Pagidimarri Kartheek on 29/05/20.
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
        bgView.layer.borderWidth = 1
        bgView.layer.borderColor = BubbleViewLeftTint.cgColor
        
        imgView.layer.cornerRadius = imgView.frame.size.height/2
        imgView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
