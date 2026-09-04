//
//  CustomCollectionViewCell.swift
//  KoreBotSDKDemo
//
//  Created by Anoop Dhiman on 09/10/17.
//  Copyright © 2017 Kore. All rights reserved.
//

import UIKit

class CustomCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var bgV: UIView!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var underLineLbl: UILabel!

    private var bgViewContainerConstraints: [NSLayoutConstraint] = []

    override func awakeFromNib() {
        super.awakeFromNib()
        // These constraints pin bgView to the collection cell. The table uses
        // a one-point spacer cell, where those constraints cannot fit.
        bgViewContainerConstraints = (constraints + contentView.constraints).filter {
            ($0.firstItem as? UIView) === bgView || ($0.secondItem as? UIView) === bgView
        }
    }

    func setSpacerCell(_ isSpacer: Bool) {
        bgViewContainerConstraints.forEach { $0.isActive = !isSpacer }
        bgView.isHidden = isSpacer
    }

}
