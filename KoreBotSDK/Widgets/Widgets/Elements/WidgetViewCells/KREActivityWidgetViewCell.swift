//
//  KREActivityWidgetViewCell.swift
//  KoreBotSDK
//
//  Created by Srinivas Vasadi on 13/01/2020.
//  Copyright © 2019 Srinivas Vasadi. All rights reserved.
//

import UIKit

// MARK: - KREActivityWidgetViewCell
public class KREActivityWidgetViewCell: KREWidgetViewCell {
    // MARK: - properties
    public override var widget: KREWidget? {
        didSet {
            widgetView.widget = widget
        }
    }
        
    lazy public var activityWidgetView: KREActivityWidgetView = {
        let activityWidgetView = KREActivityWidgetView(frame: .zero)
        activityWidgetView.translatesAutoresizingMaskIntoConstraints = false
        return activityWidgetView
    }()
    
    lazy public var widgetView: KREWidgetContainerView = {
        let widgetContainerView = KREWidgetContainerView(view: activityWidgetView)
        widgetContainerView.translatesAutoresizingMaskIntoConstraints = false
        widgetContainerView.showPinOrUnPinButton = true
        return widgetContainerView
    }()

    // MARK: - init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        activityWidgetView.prepareForReuse()
    }

    // MARK: - setup
    public override func setup() {
        super.setup()
        contentView.addSubview(cardView)
        cardView.addSubview(stackView)

        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(top)-[cardView]-(bottom)-|", options: [], metrics: metrics, views: ["cardView": cardView]))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(left)-[cardView]-(right)-|", options: [], metrics: metrics, views: ["cardView": cardView]))

        cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-2-[stackView]-2-|", options: [], metrics: metrics, views: ["stackView": stackView]))
        cardView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-2-[stackView]-2-|", options: [], metrics: metrics, views: ["stackView": stackView]))

        stackView.addArrangedSubview(widgetView)
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
    }
}
