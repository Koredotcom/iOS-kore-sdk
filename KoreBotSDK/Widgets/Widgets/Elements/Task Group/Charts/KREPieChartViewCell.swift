//
//  KREPieChartViewCell.swift
//  KoreBotSDK
//
//  Created by Sukhmeet Singh on 26/10/19.
//

import UIKit

public class KREPieChartViewCell: UITableViewCell {
    // MARK: - properties
    let bundle = Bundle.sdkModule
    lazy var templateView: KREPieChartView = {
        let templateView = KREPieChartView(frame: .zero)
        templateView.backgroundColor =  UIColor.white
        templateView.translatesAutoresizingMaskIntoConstraints = false
        return templateView
    }()
    
    public lazy var buttonCollectionView: KREButtonCollectionView = {
        let buttonCollectionView = KREButtonCollectionView(frame: .zero)
        buttonCollectionView.translatesAutoresizingMaskIntoConstraints = false
        return buttonCollectionView
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
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[stackView]-|", options: [], metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[stackView]-|", options: [], metrics: nil, views: views))
        
        stackView.addArrangedSubview(templateView)
        stackView.addArrangedSubview(buttonCollectionView)
        
        buttonCollectionView.heightAnchor.constraint(equalToConstant: 32.0).isActive = true
        buttonCollectionView.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
    }
}
