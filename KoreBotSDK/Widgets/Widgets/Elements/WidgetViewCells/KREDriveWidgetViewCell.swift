//
//  KREDriveWidgetViewCell.swift
//  KoreBotSDK
//
//  Created by Srinivas Vasadi on 13/01/2020.
//  Copyright © 2019 Srinivas Vasadi. All rights reserved.
//

import UIKit

public class KREWidgetViewCell: UICollectionViewCell {
    // MARK: - properties
    public var cornerRadius: CGFloat = 8.0
    public var borderColor: CGColor = UIColor.paleLilacThree.cgColor
    public var borderWidth: CGFloat = 0.5
    
    public lazy var cardView: UIView = {
        let cardView = UIView(frame: .zero)
        cardView.backgroundColor = .white
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.layer.cornerRadius = cornerRadius
        cardView.layer.borderColor = borderColor
        cardView.layer.borderWidth = borderWidth
        cardView.layer.masksToBounds = false
        cardView.layer.cornerRadius = 10.0
        cardView.layer.shadowRadius = 7.0
        cardView.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        cardView.layer.shadowOpacity = 0.2
        cardView.layer.shadowColor = UIColor.charcoalGrey30.cgColor
        return cardView
    }()
    
    public lazy var stackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.backgroundColor = .clear
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 0.0
        return stackView
    }()

    public let metrics: [String: CGFloat] = ["left": 10.0, "right": 10.0, "top": 5.0, "bottom": 5.0]
    public var widget: KREWidget?
    
    // MARK: -
    public func setup() {
        backgroundColor = .clear
        clipsToBounds = true
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override public func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let size = contentView.systemLayoutSizeFitting(layoutAttributes.size)
        var frame = layoutAttributes.frame
        frame.size.height = ceil(size.height)
        layoutAttributes.frame = frame
        return layoutAttributes
    }
    
    public override func systemLayoutSizeFitting(_ targetSize: CGSize) -> CGSize {
        super.systemLayoutSizeFitting(targetSize)
    }
}

// MARK: - KREDriveWidgetViewCell
public class KREDriveWidgetViewCell: KREWidgetViewCell {
    // MARK: - properties
    public override var widget: KREWidget? {
        didSet {
            widgetView.widget = widget
            invalidateIntrinsicContentSize()
        }
    }
    lazy public var driveWidgetView: KREDriveWidgetView = {
        let driveWidgetView = KREDriveWidgetView(frame: .zero)
        driveWidgetView.translatesAutoresizingMaskIntoConstraints = false
        return driveWidgetView
    }()
    
    lazy public var widgetView: KREWidgetContainerView = {
        let widgetContainerView = KREWidgetContainerView(view: driveWidgetView)
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
        driveWidgetView.prepareForReuse()
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
