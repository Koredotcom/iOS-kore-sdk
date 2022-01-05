//
//  KRESegmentButtonCollectionViewCell.swift
//  Pods
//
//  Created by Sukhmeet Singh on 07/03/19.
//

import UIKit

open class KRESegmentButtonsCollectionViewCell: UICollectionViewCell {
    // MARK: - properties
    open var containerView: UIView = UIView(frame: .zero)
    open var nameLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.textFont(ofSize: 15.0, weight: .bold)
        label.textAlignment = NSTextAlignment.center
        label.numberOfLines = 1
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        intialize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        intialize()
    }
    
    func intialize() {
        backgroundColor = UIColor.clear
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(nameLabel)
        addSubview(containerView)
        
        let views: [String: Any] = ["nameLabel": nameLabel, "containerView": containerView]
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[containerView]|", options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[containerView]|", options: [], metrics: nil, views: views))
        
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[nameLabel]|", options: [], metrics: nil, views: views))
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[nameLabel]|", options: [], metrics: nil, views: views))
    }
}
