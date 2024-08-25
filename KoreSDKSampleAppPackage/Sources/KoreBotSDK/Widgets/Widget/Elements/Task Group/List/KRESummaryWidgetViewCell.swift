//
//  KREDriveWidgetViewCell.swift
//  KoreBotSDK
//
//  Created by Srinivas Vasadi on 27/01/2020.
//  Copyright © 2019 Srinivas Vasadi. All rights reserved.
//

import UIKit

// MARK: - KRESummaryWidgetViewCell
public class KRESummaryWidgetViewCell: KREWidgetViewCell {
    // MARK: - properties
    public override var widget: KREWidget? {
        didSet {
            weatherBubbleView.widget = widget
        }
    }
    var actionHandler:((KREAction) -> Void)? {
        didSet {
            weatherBubbleView.actionHandler = actionHandler
        }
    }
    
    lazy var weatherBubbleView: KREWeatherBubbleView = {
        let weatherBubbleView = KREWeatherBubbleView()
        weatherBubbleView.translatesAutoresizingMaskIntoConstraints = false
        return weatherBubbleView
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
    
    // MARK: - setup
    public override func setup() {
        super.setup()
        contentView.addSubview(cardView)
        cardView.addSubview(stackView)

        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(top)-[cardView]-(bottom)-|", options: [], metrics: metrics, views: ["cardView": cardView]))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(left)-[cardView]-(right)-|", options: [], metrics: metrics, views: ["cardView": cardView]))

        cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[stackView]|", options: [], metrics: metrics, views: ["stackView": stackView]))
        cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[stackView]|", options: [], metrics: metrics, views: ["stackView": stackView]))

        stackView.addArrangedSubview(weatherBubbleView)
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
    }
}
