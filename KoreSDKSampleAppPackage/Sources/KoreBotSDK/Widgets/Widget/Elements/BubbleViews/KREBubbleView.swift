//
//  KREBubbleView.swift
//  Pods
//
//  Created by Sukhmeet Singh on 07/03/19.
//

import UIKit

//let BubbleViewMaxWidth: CGFloat = (UIScreen.main.bounds.size.width - 90.0)

open class KREBubbleView: UIView {
    // MARK: - properties
    let bundle = Bundle(for: KREBubbleView.self)
    var maskLayer: CAShapeLayer!
    var borderLayer: CAShapeLayer!
    var drawBorder: Bool = false
    
    var widget: KREWidget? {
        didSet {
            populateBubbleView()
        }
    }

    // MARK: init
    public init() {
        super.init(frame: CGRect.zero)
        initialize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    open func initialize() {
        clipsToBounds = true
    }
    
    // MARK: - populate bubbleView
    open func populateBubbleView() {
        
    }
    
    open func populateBubbleContainerView() {
        
    }
    
    // MARK: - Method to be overridden
    open func prepareForReuse() {
        
    }
        
    override open func layoutSubviews() {
        super.layoutSubviews()
    }

    // MARK:- deinit
    deinit {

    }
}
