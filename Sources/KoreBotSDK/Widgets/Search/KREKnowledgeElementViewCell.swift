//
//  KREKnowledgeElementViewCell.swift
//  KoreBotSDK
//
//  Created by Srinivas Vasadi on 08/01/2020.
//  Copyright © 2019 Srinivas Vasadi. All rights reserved.
//

import UIKit

public class KREKnowledgeElementViewCell: UITableViewCell {
    // MARK: - properties
    let bundle = Bundle.sdkModule
    public lazy var templateView: KREKnowledgeTemplateView = {
        let templateView = KREKnowledgeTemplateView(frame: .zero)
        templateView.translatesAutoresizingMaskIntoConstraints = false
        return templateView
    }()
    
    public lazy var knowledgeFooterView: KREKnowledgeFooterView = {
        let knowledgeFooterView = KREKnowledgeFooterView(frame: .zero)
    knowledgeFooterView.translatesAutoresizingMaskIntoConstraints = false
        return knowledgeFooterView
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
        
        let views = ["stackView": stackView]
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[stackView]|", options: [], metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[stackView]|", options: [], metrics: nil, views: views))
        
        stackView.addArrangedSubview(templateView)
        stackView.addArrangedSubview(knowledgeFooterView)
    }
    
    func loadingDataState() {
        templateView.loadingDataState()
    }
    
    func loadedDataState() {
        templateView.loadedDataState()
    }
}
