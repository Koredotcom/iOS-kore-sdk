//
//  ButtonLinkNCell.swift
//  KoreBotSDKFrameWork
//
//  Created by Kartheek.Pagidimarri on 16/08/22.
//  Copyright © 2022 Kartheek.Pagidimarri. All rights reserved.
//

import UIKit

class ButtonLinkNCell: UITableViewCell {
    @IBOutlet var bgV: UIView!
    @IBOutlet weak var underLineLbl: UILabel!
    @IBOutlet weak var titleBtn: UIButton!
    @IBOutlet var imagV: UIImageView!
    let bundle = KREResourceLoader.shared.resourceBundle()
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        titleBtn.titleLabel?.font = UIFont(name: mediumCustomFont, size: 14.0)
        
        
        let chatHisImg = UIImage.init(named: "buttonLink", in: bundle, compatibleWith: nil)
        imagV.image = chatHisImg?.withRenderingMode(.alwaysTemplate)
        imagV.tintColor = themeColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
