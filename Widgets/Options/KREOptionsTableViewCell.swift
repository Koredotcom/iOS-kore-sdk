//
//  KREOptionsTableViewCell.swift
//  Widgets
//
//  Created by developer@kore.com on 12/22/16.
//  Copyright © 2016 Kore Inc. All rights reserved.
//

import UIKit

class KREOptionsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var viweMoreLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        viweMoreLabel.font = UIFont.textFont(ofSize: 15.0, weight: .bold)
    }
}
