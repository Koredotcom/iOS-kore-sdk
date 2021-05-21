//
//  KREListItemViewCell.swift
//  KoreBotSDK
//
//  Created by Srinivas Vasadi on 24/01/2020.
//  Copyright © 2019 Srinivas Vasadi. All rights reserved.
//

import UIKit

public class KREListItemViewCell: UITableViewCell {
    // MARK: - properties
    let bundle = Bundle(for: KREListItemViewCell.self)
   public lazy var templateView: KREListItemView = {
        let templateView = KREListItemView(frame: .zero)
        templateView.backgroundColor =  UIColor.white
        templateView.translatesAutoresizingMaskIntoConstraints = false
        return templateView
    }()
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.backgroundColor = .clear
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 0.0
        return stackView
    }()
    
    let metrics: [String: CGFloat] = ["value": 4.0]
    
    // MARK: - init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override public func prepareForReuse() {
        super.prepareForReuse()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        templateView.layoutSubviews()
    }

    // MARK: - setup
    func setup() {
        selectionStyle = .none
        contentView.addSubview(stackView)
        
        let views = ["stackView": stackView]
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-4-[stackView]-4-|", options: [], metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-4-[stackView]-4-|", options: [], metrics: nil, views: views))
        
        stackView.addArrangedSubview(templateView)
    }
}
