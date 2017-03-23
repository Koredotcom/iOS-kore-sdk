//
//  KRETokenCollectionViewCell.swift
//  Widgets
//
//  Created by developer@kore.com on 16/11/16.
//  Copyright © 2016 Kore Inc. All rights reserved.
//

import UIKit
import QuartzCore

public class KRETokenCollectionViewCell: UICollectionViewCell {
    var label: UILabel!
    var krefocused: Bool = false {
        didSet {
            if (krefocused) {
                self.label.textColor = UIColor.white
                self.label.backgroundColor = tintColor
            } else {
                self.label.textColor = self.tintColor
                self.label.backgroundColor = UIColor.clear
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var labelText : String? {
        set (newText) {
            label.text = newText
        }
        get {
            return label.text
        }
    }
    
    func setup() {
        label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.blue
        label.textAlignment = NSTextAlignment.center
        label.clipsToBounds = true
        contentView.addSubview(label)

        let layer:CALayer = label.layer
        layer.masksToBounds = true
        layer.cornerRadius = 15
        layer.borderColor  = Common.UIColorRGB(0x0578FE).cgColor
        layer.borderWidth = 1
        
        let views = ["label":label!]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(2)-[label]-(2)-|", options:[], metrics:nil, views:views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[label]|", options:[], metrics:nil, views:views))
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
    }
    
    // MARK: - 
    override public func tintColorDidChange() {

    }
    
    // MARK: -
    func widthForCell(string: String) -> CGFloat {
        let font: UIFont = self.label.font
        let attributes = [NSFontAttributeName : font]

        let rect = string.boundingRect(with: CGSize(width: frame.size.width, height: CGFloat.greatestFiniteMagnitude), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: attributes, context: nil)
        return CGFloat(ceilf(Float(rect.size.width)) + 15.0)
    }
}
