//
//  KREOptionsTableViewCell.swift
//  Widgets
//
//  Created by Phanindra on 12/22/16.
//  Copyright © 2016 Kore. All rights reserved.
//

import UIKit

class KREOptionsTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.sizeToFit()
        self.layoutIfNeeded()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
