//
//  KREDriveWidgetViewCell.swift
//  KoreBotSDK
//
//  Created by Srinivas Vasadi on 13/01/2020.
//  Copyright © 2019 Srinivas Vasadi. All rights reserved.
//

import UIKit

public class KREUtterancesListWidgetViewCell: KREWidgetViewCell {
    // MARK: - properties
    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    var utterances: [KREAction]? {
        didSet {
            if let count = utterances?.count {
                let actions = utterances?.chunked(by: count / 2)
                
                topUtteranceCollectionView.utterances = actions?.first
                bottomUtteranceCollectionView.utterances = actions?.last
            }
        }
    }
    
    lazy var titleLabel: UILabel = {
        let textLabel = UILabel(frame: .zero)
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.textColor = UIColor.dark
        textLabel.font = UIFont.textFont(ofSize: 17.0, weight: .semibold)
        textLabel.clipsToBounds = true
        return textLabel
    }()
    
    lazy var button: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("SEE ALL", for: .normal)
        button.titleLabel?.font = UIFont.textFont(ofSize: 13.0, weight: .bold)
        button.setTitleColor(UIColor.lightRoyalBlue, for: .normal)
        button.isUserInteractionEnabled = false
        button.isHidden = true
        return button
    }()

    lazy var topUtteranceCollectionView: KREUtteranceCollectionView = {
        let utteranceCollectionView = KREUtteranceCollectionView(frame: .zero)
        utteranceCollectionView.translatesAutoresizingMaskIntoConstraints = false
        return utteranceCollectionView
    }()
    
    lazy var bottomUtteranceCollectionView: KREUtteranceCollectionView = {
        let utteranceCollectionView = KREUtteranceCollectionView(frame: .zero)
        utteranceCollectionView.translatesAutoresizingMaskIntoConstraints = false
        return utteranceCollectionView
    }()
    
    var buttonActionHandler:(() -> Void)?
    var actionHandler:((KREAction) -> Void)? {
        didSet {
            topUtteranceCollectionView.actionHandler = actionHandler
            bottomUtteranceCollectionView.actionHandler = actionHandler
        }
    }
    // MARK: - init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    // MARK: - setup
    public override func setup() {
        super.setup()
        contentView.addSubview(cardView)
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(top)-[cardView]-(bottom)-|", options: [], metrics: metrics, views: ["cardView": cardView]))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(left)-[cardView]-(right)-|", options: [], metrics: metrics, views: ["cardView": cardView]))

        cardView.addSubview(titleLabel)
        
        button.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
        cardView.addSubview(button)
        cardView.addSubview(topUtteranceCollectionView)
        cardView.addSubview(bottomUtteranceCollectionView)

        let views = ["titleLabel": titleLabel, "topUtteranceCollectionView": topUtteranceCollectionView, "bottomUtteranceCollectionView": bottomUtteranceCollectionView, "button": button]
        cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-12-[titleLabel]-15-[topUtteranceCollectionView]-10-[bottomUtteranceCollectionView]-18-|", options: [], metrics: nil, views: views))
        cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[button]-15-[topUtteranceCollectionView]", options: [], metrics: nil, views: views))
        cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-13-[titleLabel]-[button]-15-|", options: [], metrics: nil, views: views))
        cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[topUtteranceCollectionView]|", options: [], metrics: nil, views: views))
        cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[bottomUtteranceCollectionView]|", options: [], metrics: nil, views: views))
        
        titleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        button.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        button.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    }
    
    // MARK: -
    @objc func buttonAction(_ sender: UIButton) {
        buttonActionHandler?()
    }
}

// MARK: - Collection+Chunk
extension Collection {
    func chunked(by distance: Int) -> [[Element]] {
        var result: [[Element]] = []
        var batch: [Element] = []

        for element in self {
            batch.append(element)
            if batch.count == distance {
                result.append(batch)
                batch = []
            }
        }

        if !batch.isEmpty {
            result.append(batch)
        }

        return result
    }
}
