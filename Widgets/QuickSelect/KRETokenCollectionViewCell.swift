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
    var imageView: UIImageView!
    var label: UILabel!
    var krefocused: Bool = false {
        didSet {
            if (krefocused) {
                self.label.textColor = UIColor(hex: 0x485260)
                self.label.backgroundColor = UIColor(hex: 0x485260)
            } else {
                let textColor =  UserDefaults.standard.value(forKey: "ButtonTextColor") as? String
                self.label.textColor = UIColor.init(hexString: textColor!)
                self.label.backgroundColor = UIColor(hex: 0xEDEDEF)
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
    
    var imageURL: String? {
        didSet {
            if let urlString = imageURL, let url = URL(string: urlString) {
                imageView.setImageWith(url, placeholderImage: UIImage(named: "placeholder_image"))
            }
        }
    }
    
    func setup() {
        self.backgroundColor = UIColor.white
        
        imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 16
        imageView.contentMode = UIView.ContentMode.scaleAspectFill
        contentView.addSubview(imageView)
        
        imageView.setContentHuggingPriority(UILayoutPriority.defaultLow, for: NSLayoutConstraint.Axis.horizontal)
        imageView.setContentCompressionResistancePriority(UILayoutPriority.defaultLow, for: NSLayoutConstraint.Axis.horizontal)
        
        label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor(red: 97/255, green: 104/255, blue: 231/255, alpha: 1)
        label.textAlignment = NSTextAlignment.center
        label.font = UIFont.textFont(ofSize: 14.0, weight: .regular)
        label.clipsToBounds = true
        contentView.addSubview(label)
        
        label.setContentHuggingPriority(UILayoutPriority.defaultHigh, for: NSLayoutConstraint.Axis.horizontal)
        label.setContentCompressionResistancePriority(UILayoutPriority.defaultHigh, for: NSLayoutConstraint.Axis.horizontal)
        
        let layer:CALayer = self.layer
        layer.masksToBounds = true
        layer.cornerRadius = 4
        layer.borderColor  = UIColor(hex: 0xEDEDEF).cgColor
        layer.borderWidth = 1
        self.backgroundColor = UIColor(hex: 0xEDEDEF)
        
        let views = ["label":label!, "image":imageView!] as [String : Any]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-4-[image]-(8)-[label]-(12)-|", options:[], metrics:nil, views:views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-4-[image]-4-|", options:[], metrics:nil, views:views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[label]-2-|", options:[], metrics:nil, views:views))
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
    func widthForCell(string: String?, withImage: Bool, height: CGFloat) -> CGFloat {
        self.label.text = string
        let width = self.label.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: height)).width
        return width + 24.0 + (withImage ? 32.0 : 0.0)
    }
}
