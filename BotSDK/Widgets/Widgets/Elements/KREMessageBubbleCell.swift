//
//  KREMessageBubbleCell.swift
//  AFNetworking
//
//  Created by Sukhmeet Singh on 07/03/19.
//

import UIKit

open class KREMessageBubbleCell: UITableViewCell {
    // MARK: - properties
    let bundle = Bundle(for: KREMessageBubbleCell.self)
    public var bubbleContainerView = UIView(frame: .zero)
    public var bubbleLeadingConstraint: NSLayoutConstraint!
    public var bubbleTrailingConstraint: NSLayoutConstraint!
    public var bubbleTopConstraint: NSLayoutConstraint!
    public var bubbleBottomConstraint: NSLayoutConstraint!

    public var bubbleView: KREBubbleView?
    
    // MARK: - init
    override public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initialize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    override open func prepareForReuse() {
        super.prepareForReuse()
        bubbleView?.prepareForReuse()
        bubbleView?.invalidateIntrinsicContentSize()
    }
    
    // MARK: -
    func initialize() {
        selectionStyle = .none
        clipsToBounds = true
        
        bubbleContainerView.backgroundColor = UIColor.clear
        bubbleContainerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(bubbleContainerView)
        
        // Setting Constraints
        let views: [String: UIView] = ["bubbleContainerView": bubbleContainerView]
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[bubbleContainerView]|", options:[], metrics:nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[bubbleContainerView]|", options:[], metrics:nil, views:views))
    }
    
    open func configureWidget(_ widget: Any?) {

    }
    
    // MARK:- deinit
    deinit {

    }
}

// MARK: - KREWeatherBubbleCell
public class KREWeatherBubbleCell: KREMessageBubbleCell {

}

// MARK: - KREWidgetBubbleCell
public class KREWidgetBubbleCell: KREMessageBubbleCell {

}
