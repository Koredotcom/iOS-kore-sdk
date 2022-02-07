//
//  KRESkillComponentTableViewCell.swift
//  KoreBotSDK
//
//  Created by Sukhmeet Singh on 12/03/20.
//

import UIKit

class KRESkillComponentTableViewCell: UITableViewCell {
    // MARK: - properties
    let bundle = Bundle(for: KRESkillComponentTableViewCell.self)
    lazy var templateView: KRESkillTemplateView = {
        let templateView = KRESkillTemplateView(frame: .zero)
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
        
        let views = ["stackView": stackView]
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[stackView]|", options: [], metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[stackView]|", options: [], metrics: nil, views: views))
        
        stackView.addArrangedSubview(templateView)
    }
}



import UIKit

public class KRESkillTemplateView: UIView {
    // MARK: - properties
    let bundle = Bundle(for: KRESkillTemplateView.self)
    public lazy var titleLabel: UILabel = {
        var titleLabel: UILabel = UILabel(frame: .zero)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.textFont(ofSize: 19.0, weight: .regular)
        titleLabel.textColor = UIColor.battleshipGrey
        titleLabel.numberOfLines = 2
        titleLabel.textAlignment = .left
        titleLabel.lineBreakMode = .byWordWrapping
        return titleLabel
    }()
    
    public lazy var subTitleLabel: UILabel = {
        var titleLabel: UILabel = UILabel(frame: .zero)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.textFont(ofSize: 15.0, weight: .regular)
        titleLabel.textColor = UIColor.battleshipGrey
        titleLabel.numberOfLines = 2
        titleLabel.textAlignment = .left
        titleLabel.lineBreakMode = .byTruncatingTail
        return titleLabel
    }()
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.backgroundColor = .clear
        stackView.distribution = .equalSpacing
        stackView.alignment = .fill
        stackView.spacing = 15.0
        return stackView
    }()
    
    // MARK: - init
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    // MARK: - setup
    public func setup() {
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subTitleLabel)
        addSubview(stackView)
        let views = ["stackView": stackView]
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-13-[stackView]-13-|", options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-13-[stackView]-13-|", options: [], metrics: nil, views: views))
    }
    
    public func populateTemplateView(_ object: Decodable?, totalElementCount: Int) {
        if let object = object as? KRESearchSkillData {
            titleLabel.text = object.title?.trimmingCharacters(in: .whitespacesAndNewlines)
            subTitleLabel.text = object.desc?.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
}
