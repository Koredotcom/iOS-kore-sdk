//
//  KREListItemView.swift
//  KoreBotSDK
//
//  Created by Srinivas Vasadi on 05/01/2020.
//  Copyright © 2019 Srinivas Vasadi. All rights reserved.
//

import UIKit

public class KREListItemDetailView: UIView {
    // MARK: - properties
    let bundle = Bundle(for: KREListItemDetailView.self)
    public lazy var descLabel: UILabel = {
        let descLabel = UILabel(frame: .zero)
        descLabel.translatesAutoresizingMaskIntoConstraints = false
        descLabel.font = UIFont.textFont(ofSize: 13.0, weight: .medium)
        descLabel.textColor = UIColor.darkGreyBlue
        descLabel.numberOfLines = 0
        return descLabel
    }()
    
    public lazy var iconImageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "approve", in: bundle, compatibleWith: nil)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    // MARK: - init
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    public func prepareForReuse() {
        iconImageView.isHidden = false
        descLabel.text = nil
    }
    
    // MARK: - setup
    func setup() {
        backgroundColor = .clear
        addSubview(iconImageView)
        addSubview(descLabel)
        
        let views: [String: Any] = ["iconImageView": iconImageView, "descLabel": descLabel]
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[iconImageView]-14-[descLabel]|", options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[descLabel]|", options: [], metrics: nil, views: views))
        
        iconImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        iconImageView.heightAnchor.constraint(equalToConstant: 18.0).isActive = true
        iconImageView.widthAnchor.constraint(equalToConstant: 18.0).isActive = true
    }
}
