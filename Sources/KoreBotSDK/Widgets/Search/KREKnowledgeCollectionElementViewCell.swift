//
//  KREKnowledgeCollectionElementViewCell.swift
//  KoreBotSDK
//
//  Created by Srinivas Vasadi on 08/01/2020.
//  Copyright © 2019 Srinivas Vasadi. All rights reserved.
//

import UIKit

public class KREKnowledgeCollectionElementViewCell: UITableViewCell {
    // MARK: - properties
    let bundle = Bundle.sdkModule
    lazy var templateView: KREKnowledgeCollectionTemplateView = {
        let templateView = KREKnowledgeCollectionTemplateView(frame: .zero)
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
        stackView.addArrangedSubview(templateView)
        
        let views = ["stackView": stackView]
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[stackView]|", options: [], metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[stackView]|", options: [], metrics: nil, views: views))
        
        stackView.addArrangedSubview(templateView)
    }
}
