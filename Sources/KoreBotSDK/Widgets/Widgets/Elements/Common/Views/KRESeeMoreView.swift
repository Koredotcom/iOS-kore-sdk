//
//  KRESeeMoreView.swift
//  KoreBotSDK
//
//  Created by Srinivas Vasadi on 13/01/2020.
//  Copyright © 2019 Srinivas Vasadi. All rights reserved.
//

import UIKit

public class KRESeeMoreView: UIView {
    // MARK: - properties
    let bundle = Bundle.sdkModule
    public lazy var titleLabel: UILabel = {
        let titleLabel = UILabel(frame: .zero)
        titleLabel.backgroundColor = UIColor.white
        titleLabel.textColor = UIColor.lightRoyalBlue
        titleLabel.numberOfLines = 0
        titleLabel.font = UIFont.textFont(ofSize: 14.0, weight: .regular)
        titleLabel.textAlignment = .left
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }()
    
    public lazy var navigationImageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    public lazy var lineView: UIView = {
        let lineView = UIView(frame: .zero)
        lineView.translatesAutoresizingMaskIntoConstraints = false
        lineView.backgroundColor = UIColor.lightRoyalBlue.withAlphaComponent(0.2)
        return lineView
    }()
    
    public var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    
    public override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: 54.0)
    }
    
    // MARK: - init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - setup
    func setup() {
        addSubview(titleLabel)
        backgroundColor = UIColor.white
        
        addSubview(navigationImageView)
        addSubview(lineView)
        navigationImageView.isUserInteractionEnabled = true
        navigationImageView.contentMode = .scaleAspectFit
        navigationImageView.image = UIImage(named: "disclose", in: bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        navigationImageView.tintColor = UIColor.lightRoyalBlue
        navigationImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let views: [String: Any] = ["titleLabel": titleLabel, "navigationImageView": navigationImageView, "lineView": lineView]
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[titleLabel]-[navigationImageView]-10-|", options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat:"V:[titleLabel]-1-[lineView]", options: [], metrics: nil, views: views))
        
        lineView.heightAnchor.constraint(equalToConstant: 1.0).isActive = true
        lineView.widthAnchor.constraint(equalTo: titleLabel.widthAnchor).isActive = true
        lineView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor).isActive = true
        
        titleLabel.centerYAnchor.constraint(equalTo: navigationImageView.centerYAnchor).isActive = true
        navigationImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
}
