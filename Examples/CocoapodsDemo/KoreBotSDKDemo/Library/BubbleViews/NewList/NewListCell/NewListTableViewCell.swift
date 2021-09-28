//
//  NewListTableViewCell.swift
//  KoreBotSDKDemo
//
//  Created by MatrixStream_01 on 13/05/20.
//  Copyright © 2020 Kore. All rights reserved.
//

import UIKit

class NewListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var subTitleLabel2: UILabel!
    @IBOutlet weak var tagBtn: UIButton!
    @IBOutlet weak var underlineLbl: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var imageViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    
    
    @IBOutlet weak var valueLabelWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var imageVLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var titlaLblTopConstriant: NSLayoutConstraint!
    
    @IBOutlet weak var subTitleHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var subTitle2HeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var priceLblTopConstraint: NSLayoutConstraint!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bgView.layer.cornerRadius = 5
//        bgView.layer.borderWidth = 1
//        bgView.layer.borderColor = UIColor.lightGray.cgColor
        
//        bgView.layer.shadowColor = UIColor.darkGray.cgColor
//        bgView.layer.shadowOffset = CGSize(width: 0, height: 0)
//        bgView.layer.shadowOpacity = 0.5
//        bgView.layer.shadowRadius = 2
//        bgView.clipsToBounds = true
        
        underlineLbl.isHidden = true
        bgView.layer.masksToBounds = false
        bgView?.layer.shadowColor = UIColor.lightGray.cgColor
        bgView?.layer.shadowOffset =  CGSize.zero
        bgView?.layer.shadowOpacity = 0.5
        bgView?.layer.shadowRadius = 4
        
        titleLabel.font =  UIFont(name: "Gilroy-Regular", size: 14.0)!
        subTitleLabel.font = UIFont(name: "Gilroy-Regular", size: 12.0)!
        subTitleLabel2.font = UIFont(name: "Gilroy-Semibold", size: 17.0)!
        priceLbl.font = UIFont(name: "Gilroy-Regular", size: 14.0)!
        
//        titleLabel.textColor = UIColor.init(hexString:"#313131")
//        subTitleLabel.textColor = UIColor.init(hexString:"#313131")
//        subTitleLabel2.textColor = UIColor.init(hexString:"#313131")
//        priceLbl.textColor = UIColor.init(hexString:"#313131")
//        priceLbl.alpha = 0.7
        
        titleLabel.textColor = BubbleViewBotChatTextColor
        subTitleLabel.textColor = BubbleViewBotChatTextColor
        subTitleLabel2.textColor = BubbleViewBotChatTextColor
        priceLbl.textColor = BubbleViewBotChatTextColor
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
