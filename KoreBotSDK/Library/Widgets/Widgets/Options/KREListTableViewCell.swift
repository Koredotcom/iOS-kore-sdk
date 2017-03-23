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
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var moreDetailsLabel: UILabel!
    @IBOutlet weak var detailsLabelTopConstraint: NSLayoutConstraint!

    var moreDetailsText: NSString! {
        didSet {
            moreDetailsLabel.layer.borderWidth = 1.0
            moreDetailsLabel.layer.cornerRadius = 5
            self.moreDetailsLabel.text = moreDetailsText as String?;
            self.detailsLabelTopConstraint.constant = 70;
        }
    }
    var labelAction: ((_ text: String?) -> Void)!

    var tapGesture:UITapGestureRecognizer?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        infoLabel.sizeToFit()
        self.tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(tappedOnLabel));
        self.moreDetailsLabel.addGestureRecognizer(self.tapGesture!)
        self.moreDetailsLabel.isUserInteractionEnabled = true
        self.detailsLabelTopConstraint.constant = 37;
        // Initialization code
        
    }
    override func layoutSubviews() {
        super.layoutSubviews()
//        infoLabel.sizeToFit()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func tappedOnLabel() {
        if(self.labelAction != nil){
            self.labelAction("cell")
        }
    }
    
    
    
}
