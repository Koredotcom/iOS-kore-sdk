//
//  KREListTableViewCell.swift
//  Widgets
//
//  Created by developer@kore.com on 12/23/16.
//  Copyright © 2016 Kore Inc. All rights reserved.
//

import UIKit

class KREListTableViewCell: UITableViewCell {

    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var actionButtonHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var imgViewWidthConstraint: NSLayoutConstraint!
    
    var buttonAction: ((_ sender: Any) -> Void)!
    var minCellHeight: CGFloat = 80.0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        actionButton.layer.cornerRadius = 5
        actionButton.layer.borderWidth = 1.0
        actionButton.layer.borderColor = UIColor(hex: 0x0076ff).cgColor
        actionButton.titleLabel?.font = UIFont.textFont(ofSize: 15.0, weight: .medium)

        titleLabel.font = UIFont.textFont(ofSize: 14.0, weight: .medium)
        subTitleLabel.font = UIFont.textFont(ofSize: 15.0, weight: .medium)
    }
    
    @IBAction func btnAction(_ sender: Any) {
        if(self.buttonAction != nil){
            self.buttonAction(sender)
        }
    }
}
