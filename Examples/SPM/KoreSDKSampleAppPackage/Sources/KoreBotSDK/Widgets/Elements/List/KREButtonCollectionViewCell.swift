//
//  KREButtonCollectionViewCell.swift
//  KoreBotSDK
//
//  Created by Srinivas Vasadi on 05/01/2020.
//  Copyright © 2019 Srinivas Vasadi. All rights reserved.
//

import UIKit

public class KREButtonCollectionViewCell: UICollectionViewCell {
    // MARK: - properties
    public lazy var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.textFont(ofSize: 15.0, weight: .bold)
        label.textColor = UIColor.lightRoyalBlue
        label.textAlignment = NSTextAlignment.center
        label.numberOfLines = 1
        return label
    }()
    
    public lazy var imageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "approve")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    public lazy var horizontalStackView: UIStackView = {
        let horizontalStackView = UIStackView(frame: .zero)
        horizontalStackView.translatesAutoresizingMaskIntoConstraints = false
        horizontalStackView.axis = .horizontal
        horizontalStackView.distribution = .fillProportionally
        horizontalStackView.alignment = .leading
        horizontalStackView.spacing = 8.0
        return horizontalStackView
    }()
    
    // MARK: - init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        imageView.isHidden = false
    }
    
    // MARK: - setup
    func setup() {
        backgroundColor = .iceBlue
        contentView.addSubview(horizontalStackView)
        horizontalStackView.addArrangedSubview(imageView)
        horizontalStackView.addArrangedSubview(titleLabel)

        let views: [String: Any] = ["horizontalStackView": horizontalStackView]
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[horizontalStackView]-|", options: [], metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[horizontalStackView]|", options: [], metrics: nil, views: views))

        titleLabel.centerYAnchor.constraint(equalTo: horizontalStackView.centerYAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: horizontalStackView.centerYAnchor).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 12.0).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 12.0).isActive = true
    }
    
    // MARK: -
    func widthForCell(string: NSAttributedString, hasImage: Bool, height: CGFloat) -> CGFloat {
        titleLabel.attributedText = string
        let width = titleLabel.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: height)).width
        return width + (hasImage ? 20.0 : 0.0) + 16.0
    }
}
