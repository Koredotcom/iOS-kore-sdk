//
//  KAKnowledgeTableViewCell.swift
//  KoreBotSDK
//
//  Created by Sukhmeet Singh on 26/10/19.
//

import UIKit

public class KAKnowledgeTableViewCell: UITableViewCell {
    // MARK: - properties
    let bundle = Bundle(for: KAKnowledgeTableViewCell.self)
    lazy var templateView: KREKnowledgeTemplateView = {
        let templateView = KREKnowledgeTemplateView(frame: .zero)
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
        templateView.prepareForReuse()
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
    }

    func loadingDataState() {
        templateView.loadingDataState()
    }
    
    func loadedDataState() {
        templateView.loadedDataState()
    }
}

// MARK: - KREHashtagTableViewCell
class KRETrendingHashtagTableViewCell: UITableViewCell {
    // MARK: - properties
    var titleLabel: UILabel!
    var viewLabel : UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.initialize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: properties with observers
    override open func prepareForReuse() {
        titleLabel.text = ""
        viewLabel.text = ""
    }
    
    override open func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func initialize() {
        self.selectionStyle = .none
        self.clipsToBounds = true
        titleLabel = UILabel(frame: .zero)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textAlignment = .left
        titleLabel.numberOfLines = 0
        titleLabel.font = UIFont.systemFont(ofSize: 14.0, weight: .medium)
        titleLabel.textColor = UIColor.lightRoyalBlue
        contentView.addSubview(titleLabel)
        
        viewLabel = UILabel(frame: .zero)
        viewLabel.translatesAutoresizingMaskIntoConstraints = false
        viewLabel.textAlignment = .left
        viewLabel.numberOfLines = 0
        viewLabel.font = UIFont.systemFont(ofSize: 14.0, weight: .regular)
        viewLabel.textColor = UIColor.battleshipGrey
        contentView.addSubview(viewLabel)
        
        // setting Constraints
        let views: [String: UIView] = ["titleLabel": titleLabel,"viewLabel": viewLabel]
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[titleLabel]-15-[viewLabel]-10-|", options:[], metrics:nil, views:views))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-13-[titleLabel]-13-|", options:[], metrics:nil, views:views))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-13-[viewLabel]-13-|", options:[], metrics:nil, views:views))
        
        titleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        viewLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        viewLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        
    }
    
    // MARK:- deinit
    deinit {
        
    }
}
