//
//  KREBarChartViewCell.swift
//  KoreBotSDK
//
//  Created by Sukhmeet Singh on 26/10/19.
//

import UIKit

public class KREBarChartViewCell: UITableViewCell {
    // MARK: - properties
    let bundle = Bundle(for: KREBarChartViewCell.self)
    lazy var cardView: UIView = {
        let cardView = UIView(frame: .zero)
        cardView.backgroundColor =  UIColor.white
        cardView.layer.cornerRadius = 10.0
        cardView.layer.borderColor = UIColor.lightGreyBlue.cgColor
        cardView.layer.borderWidth = 1.0
        cardView.translatesAutoresizingMaskIntoConstraints = false
        return cardView
    }()
    
    lazy var templateView: KREBarChartView = {
        let templateView = KREBarChartView(frame: .zero)
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
        contentView.addSubview(cardView)
        cardView.addSubview(stackView)

        let cardViews = ["cardView": cardView]
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(value)-[cardView]-(value)-|", options: [], metrics: metrics, views: cardViews))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(value)-[cardView]-(value)-|", options: [], metrics: metrics, views: cardViews))
        
        let views = ["stackView": stackView]
        cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[stackView]-|", options: [], metrics: nil, views: views))
        cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[stackView]-|", options: [], metrics: nil, views: views))
        
        stackView.addArrangedSubview(templateView)
    }
}
