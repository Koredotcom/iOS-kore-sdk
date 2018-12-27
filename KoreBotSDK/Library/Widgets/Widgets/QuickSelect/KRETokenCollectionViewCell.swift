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
                self.label.textColor = UIColor.white
                self.label.backgroundColor = tintColor
            } else {
                self.label.textColor = UIColor(red: 97/255, green: 104/255, blue: 231/255, alpha: 1)//self.tintColor
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
    
    var imageURL : String? {
        didSet{
            imageView.setImageWith(NSURL(string: self.imageURL!) as URL!, placeholderImage: UIImage.init(named: "placeholder_image"))
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
        if #available(iOS 8.2, *) {
            label.font = UIFont.systemFont(ofSize: 14.0, weight: .medium)
        } else {
            // Fallback on earlier versions
        }
        label.clipsToBounds = true
        contentView.addSubview(label)
        
        label.setContentHuggingPriority(UILayoutPriority.defaultHigh, for: NSLayoutConstraint.Axis.horizontal)
        label.setContentCompressionResistancePriority(UILayoutPriority.defaultHigh, for: NSLayoutConstraint.Axis.horizontal)
        
        let layer:CALayer = self.layer
        layer.masksToBounds = true
        layer.cornerRadius = 19
        layer.borderColor  = UIColor(red: 97/255, green: 104/255, blue: 231/255, alpha: 1).cgColor//UIColor(hex: 0x0578FE).cgColor
        layer.borderWidth = 1
        
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
    func widthForCell(string: String, withImage: Bool, height: CGFloat) -> CGFloat {
        self.label.text = string
        let width = self.label.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: height)).width
        return width + 24.0 + (withImage ? 32.0 : 0.0)
    }
}
