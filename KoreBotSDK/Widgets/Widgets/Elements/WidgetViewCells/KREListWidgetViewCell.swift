//
//  KREListWidgetViewCell.swift
//  KoreBotSDK
//
//  Created by Srinivas Vasadi on 13/01/2020.
//  Copyright © 2019 Srinivas Vasadi. All rights reserved.
//

import UIKit

// MARK: - KREListWidgetViewCell
public class KREListWidgetViewCell: KREWidgetViewCell {
    // MARK: - properties
    public override var widget: KREWidget? {
        didSet {
            widgetView.widget = widget
        }
    }
    
    lazy public var listWidgetView: KREListWidgetView = {
        let listWidgetView = KREListWidgetView(frame: .zero)
        listWidgetView.translatesAutoresizingMaskIntoConstraints = false
        return listWidgetView
    }()
    
    lazy public var widgetView: KREWidgetContainerView = {
        let widgetContainerView = KREWidgetContainerView(view: listWidgetView)
        widgetContainerView.translatesAutoresizingMaskIntoConstraints = false
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
        listWidgetView.prepareForReuse()
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

        stackView.addArrangedSubview(widgetView)
    }
        
    override public func layoutSubviews() {
        super.layoutSubviews()
    }
}
