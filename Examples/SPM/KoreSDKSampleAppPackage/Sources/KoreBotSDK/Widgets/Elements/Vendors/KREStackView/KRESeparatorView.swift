//
//  KRESeparatorView.swift.swift
//  KoreBotSDK
//
//  Created by Srinivas Vasadi on 13/03/19.
//  Copyright © 2019 Srinivas Vasadi. All rights reserved.
//

import UIKit

public class KRESeparatorView: UIView {
    // MARK: - properties
    public override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        setUp()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: -
    public override var intrinsicContentSize: CGSize {
        return CGSize(width: width, height: width)
    }
    
    public var color: UIColor {
        get {
            return backgroundColor ?? .clear
        }
        set {
            backgroundColor = newValue
        }
    }
    
    public var width: CGFloat = 1.0 {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    // MARK: -
    private func setUp() {
        setContentHuggingPriority(.defaultLow, for: .horizontal)
        setContentHuggingPriority(.defaultLow, for: .vertical)
        setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        setContentCompressionResistancePriority(.defaultLow, for: .vertical)
    }
}
