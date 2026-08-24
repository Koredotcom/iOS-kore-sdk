//
//  KRESeparatorView.swift.swift
//  KoreBotSDK
//
//  Created by Srinivas Vasadi on 13/03/19.
//  Copyright © 2019 Srinivas Vasadi. All rights reserved.
//

import UIKit

public class KREStackViewCell: UIView {
    // MARK: - properties
    private let separatorView = KRESeparatorView()
    private let tapGestureRecognizer = UITapGestureRecognizer()
    
    private var separatorTopConstraint: NSLayoutConstraint?
    private var separatorBottomConstraint: NSLayoutConstraint?
    private var separatorLeadingConstraint: NSLayoutConstraint?
    private var separatorTrailingConstraint: NSLayoutConstraint?

    // MARK: - init
    public init(contentView: UIView) {
        self.contentView = contentView
        
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 11.0, *) {
            insetsLayoutMarginsFromSafeArea = false
        }
        
        setUpViews()
        setUpConstraints()
        setUpTapGestureRecognizer()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        self.contentView = UIView(frame: .zero)

        super.init(coder: aDecoder)
        setUpViews()
        setUpConstraints()
        setUpTapGestureRecognizer()
    }
    
    // MARK: -
    public override var isHidden: Bool {
        didSet {
            guard isHidden != oldValue else { return }
            separatorView.alpha = isHidden ? 0 : 1
        }
    }
    
    public var rowHighlightColor = UIColor.paleLilacFour
    
    public var rowBackgroundColor = UIColor.clear {
        didSet { backgroundColor = rowBackgroundColor }
    }
    
    public var rowInset: UIEdgeInsets {
        get { return layoutMargins }
        set { layoutMargins = newValue }
    }
    
    public var separatorAxis: NSLayoutConstraint.Axis = .horizontal {
        didSet {
            updateSeparatorAxisConstraints()
            updateSeparatorInset()
        }
    }
    
    public var separatorColor: UIColor {
        get { return separatorView.color }
        set { separatorView.color = newValue }
    }
    
    public var separatorWidth: CGFloat {
        get { return separatorView.width }
        set { separatorView.width = newValue }
    }
    
    public var separatorHeight: CGFloat {
        get { return separatorWidth }
        set { separatorWidth = newValue }
    }
    
    public var separatorInset: UIEdgeInsets = .zero {
        didSet { updateSeparatorInset() }
    }
    
    public var isSeparatorHidden: Bool {
        get { return separatorView.isHidden }
        set { separatorView.isHidden = newValue }
    }
    
    public let contentView: UIView
    public var tapHandler: ((UIView) -> Void)? {
        didSet { updateTapGestureRecognizerEnabled() }
    }
    
    public var shouldHideSeparator = false
    
    // MARK: -
    
    private func setUpViews() {
        setUpSelf()
        setUpContentView()
        setUpSeparatorView()
    }
    
    private func setUpSelf() {
        clipsToBounds = true
    }
    
    private func setUpContentView() {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentView)
    }
    
    private func setUpSeparatorView() {
        addSubview(separatorView)
    }
    
    private func setUpConstraints() {
        setUpContentViewConstraints()
        setUpSeparatorViewConstraints()
        updateSeparatorAxisConstraints()
    }
    
    private func setUpContentViewConstraints() {
        let bottomConstraint = contentView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor)
        bottomConstraint.priority = UILayoutPriority(rawValue: UILayoutPriority.required.rawValue - 1)
        
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            bottomConstraint
        ])
    }
    
    private func setUpSeparatorViewConstraints() {
        separatorTopConstraint = separatorView.topAnchor.constraint(equalTo: topAnchor)
        separatorBottomConstraint = separatorView.bottomAnchor.constraint(equalTo: bottomAnchor)
        separatorLeadingConstraint = separatorView.leadingAnchor.constraint(equalTo: leadingAnchor)
        separatorTrailingConstraint = separatorView.trailingAnchor.constraint(equalTo: trailingAnchor)
    }
    
    private func setUpTapGestureRecognizer() {
        tapGestureRecognizer.addTarget(self, action: #selector(handleTap(_:)))
        tapGestureRecognizer.delegate = self
        addGestureRecognizer(tapGestureRecognizer)
        updateTapGestureRecognizerEnabled()
    }
    
    @objc private func handleTap(_ tapGestureRecognizer: UITapGestureRecognizer) {
        guard contentView.isUserInteractionEnabled else { return }
        (contentView as? KRETappable)?.didTapView()
        tapHandler?(contentView)
    }
    
    private func updateSeparatorAxisConstraints() {
        separatorTopConstraint?.isActive = separatorAxis == .vertical
        separatorBottomConstraint?.isActive = true
        separatorLeadingConstraint?.isActive = separatorAxis == .horizontal
        separatorTrailingConstraint?.isActive = true
    }
    
    private func updateSeparatorInset() {
        separatorTopConstraint?.constant = separatorInset.top
        separatorBottomConstraint?.constant = separatorAxis == .horizontal ? 0 : -separatorInset.bottom
        separatorLeadingConstraint?.constant = separatorInset.left
        separatorTrailingConstraint?.constant = separatorAxis == .vertical ? 0 : -separatorInset.right
    }
    
    private func updateTapGestureRecognizerEnabled() {
        tapGestureRecognizer.isEnabled = contentView is KRETappable || tapHandler != nil
    }
    
}

// MARK: - UIGestureRecognizerDelegate methods
extension KREStackViewCell: UIGestureRecognizerDelegate {
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard let view = gestureRecognizer.view else {
            return false
        }
        
        let location = touch.location(in: view)
        var hitView = view.hitTest(location, with: nil)
        
        while hitView != view && hitView != nil {
            if hitView is UIControl {
                return false
            }
            hitView = hitView?.superview
        }
        return true
    }
    
}
