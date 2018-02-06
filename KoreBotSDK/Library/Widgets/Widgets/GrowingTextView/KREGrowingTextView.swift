//
//  KREGrowingTextView.swift
//  Pods
//
//  Created by developer@kore.com on 27/07/17.
//  Copyright © 2017 Kore Inc. All rights reserved.
//
//

import UIKit

public protocol KREGrowingTextViewDelegate {
    func growingTextView(_: KREGrowingTextView, willChangeHeight height: CGFloat)
    func growingTextView(_: KREGrowingTextView, changingHeight height: CGFloat, animate: Bool)
    func growingTextView(_: KREGrowingTextView, didChangeHeight height: CGFloat)
}

open class KREGrowingTextView: UIScrollView {
    // MARK: - Properties
    
    private let _textView: KRETextViewInternal
    private let _placeholderLabel: UILabel
    private var _maxNumberOfLines: Int = 0
    private var _minNumberOfLines: Int = 0
    private var _maxHeight: CGFloat = 0
    private var _minHeight: CGFloat = 0
    private var _previousFrame: CGRect = CGRect.zero
    
    open var viewDelegate: KREGrowingTextViewDelegate?
    
    open var textView: UITextView {
        return _textView
    }
    
    open var font: UIFont {
        get {
            return _textView.font!
        }
        set {
            _textView.font = newValue
            updateMinimumAndMaximumHeight()
        }
    }
    
    open var textContainerInset: UIEdgeInsets {
        get {
            return _textView.textContainerInset
        }
        set {
            _textView.textContainerInset = newValue
            updateMinimumAndMaximumHeight()
            resetPlaceholderLabelFrame()
        }
    }
    
    open var minNumberOfLines: Int {
        get {
            return _minNumberOfLines
        }
        set {
            guard newValue > 1 else {
                _minHeight = 1
                return
            }
            
            _minHeight = simulateHeight(newValue)
            _minNumberOfLines = newValue
        }
    }
    
    open var maxNumberOfLines: Int {
        get {
            return _maxNumberOfLines
        }
        set {
            guard newValue > 1 else {
                _maxHeight = 1
                return
            }
            
            _maxHeight = simulateHeight(newValue)
            _maxNumberOfLines = newValue
        }
    }
    
    open var placeholderAttributedText: NSAttributedString? {
        get {
            return _placeholderLabel.attributedText
        }
        set {
            _placeholderLabel.attributedText = newValue
            resetPlaceholderLabelFrame()
        }
    }
    
    public var animateHeightChange: Bool = false
    
    // MARK: UIResponder

    open override var inputView: UIView? {
        get {
            return _textView.inputView
        }
        set {
            _textView.inputView = newValue
        }
    }
    
    open override var isFirstResponder: Bool {
        return _textView.isFirstResponder
    }
    
    open override func becomeFirstResponder() -> Bool {
        return _textView.becomeFirstResponder()
    }
    
    open override func resignFirstResponder() -> Bool {
        return _textView.resignFirstResponder()
    }
    
    // MARK: - Initializers
    
    public override init(frame: CGRect) {
        _textView = KRETextViewInternal(frame: CGRect(origin: CGPoint.zero, size: frame.size))
        _placeholderLabel = UILabel(frame: CGRect(origin: CGPoint.zero, size: frame.size))
        _previousFrame = frame
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        _textView = KRETextViewInternal(frame: CGRect.zero)
        _placeholderLabel = UILabel(frame: CGRect.zero)
        super.init(coder: aDecoder)
        _textView.frame = bounds
        _previousFrame = frame
        setup()
    }
    
    // MARK: - Functions
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        guard _previousFrame.width != bounds.width else { return }
        _previousFrame = frame
        fitToScrollView()
    }
    
    open override func reloadInputViews() {
        super.reloadInputViews()
        _textView.reloadInputViews()
    }
    
    open override var intrinsicContentSize: CGSize {
        return measureFrame(measureTextViewSize()).size
    }
    
    // MARK: - Private Functions
    
    private func setup() {
        _textView.isScrollEnabled = false
        _textView.backgroundColor = UIColor.clear
        addSubview(_placeholderLabel)
        addSubview(_textView)
        _minHeight = simulateHeight(1)
        maxNumberOfLines = 3
        _textView.textDidChange = { [weak self] in
            self?._placeholderLabel.isHidden = self?._textView.text.characters.count != 0
            self?.fitToScrollView()
        }
    }
    
    private func resetPlaceholderLabelFrame() {
        var placeholderSize = _placeholderLabel.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
        _placeholderLabel.frame = CGRect(origin: CGPoint(x: _textView.textContainerInset.left + 5, y: _textView.textContainerInset.top), size: placeholderSize)
    }
    
    private func measureTextViewSize() -> CGSize {
        return _textView.sizeThatFits(CGSize(width: self.bounds.width, height: CGFloat.infinity))
    }
    
    private func measureFrame(_ contentSize: CGSize) -> CGRect {
        
        let selfSize: CGSize
        
        if contentSize.height < _minHeight || !_textView.hasText {
            selfSize = CGSize(width: contentSize.width, height: _minHeight)
        } else if _maxHeight > 0 && contentSize.height > _maxHeight {
            selfSize = CGSize(width: contentSize.width, height: _maxHeight)
        } else {
            selfSize = contentSize
        }
        
        var _frame = frame
        _frame.size.height = selfSize.height
        return _frame
    }
    
    private func fitToScrollView() {
        
        let actualTextViewSize = measureTextViewSize()
        
        var _frame = bounds
        _frame.origin = CGPoint.zero
        _frame.size.height = actualTextViewSize.height
        _textView.frame = _frame
        contentSize = _frame.size
        
        let oldScrollViewFrame = frame
        let newScrollViewFrame = measureFrame(actualTextViewSize)
        
        if newScrollViewFrame.equalTo(oldScrollViewFrame) {
            return
        }
        let heightDiff = newScrollViewFrame.height - oldScrollViewFrame.height
        self.viewDelegate?.growingTextView(self, willChangeHeight: newScrollViewFrame.height)
        UIView.animate(withDuration: animateHeightChange ? 0.25 : 0.0, animations: {
            self.frame = newScrollViewFrame
            self.invalidateIntrinsicContentSize()
            self.viewDelegate?.growingTextView(self, changingHeight: heightDiff, animate: self.animateHeightChange)
        }, completion: { (complete) in
            self.viewDelegate?.growingTextView(self, didChangeHeight: self.frame.height)
        })
    }
    
    private func updateMinimumAndMaximumHeight() {
        _minHeight = simulateHeight(1)
        _maxHeight = simulateHeight(maxNumberOfLines)
        fitToScrollView()
    }
    
    private func simulateHeight(_ line: Int) -> CGFloat {
        let saveText = _textView.text
        var newText = "-"
        
        _textView.isHidden = true
        
        for _ in 0..<line-1 {
            newText += "\n|W|"
        }
        
        _textView.text = newText
        
        let height = measureTextViewSize().height
        
        _textView.text = saveText
        _textView.isHidden = false
        
        return height
    }
}
