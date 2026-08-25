//
//  KREGrowingTextView.swift
//  Pods
//
//  Created by developer@kore.com on 27/07/17.
//  Copyright © 2017 Kore Inc. All rights reserved.
//
//

import UIKit

public protocol KREGrowingTextViewDelegate: class {
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

    open var minimumHeight: CGFloat = 0 {
        didSet {
            updateMinimumAndMaximumHeight()
            invalidateIntrinsicContentSize()
        }
    }
    
    open weak var viewDelegate: KREGrowingTextViewDelegate?
    
    open var textView: UITextView {
        return _textView
    }
    open var placeholderLabel: UILabel {
        return _placeholderLabel
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
        resetPlaceholderLabelFrame()
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
        // Height growth is driven by ComposeBar constraints; content scrolls in the inner text view.
        isScrollEnabled = false
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        _textView.isScrollEnabled = false
        _textView.backgroundColor = UIColor.clear
        addSubview(_placeholderLabel)
        addSubview(_textView)
        _minHeight = simulateHeight(1)
        maxNumberOfLines = 20
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.heightAnchor.constraint(equalTo: _textView.heightAnchor).isActive = true
        
        _textView.textDidChange = { [weak self] in
            self?._placeholderLabel.isHidden = self?._textView.text.count != 0
            self?.fitToScrollView()
        }
    }
    
    private func resetPlaceholderLabelFrame() {
        let placeholderSize = _placeholderLabel.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
        let isRTL = effectiveUserInterfaceLayoutDirection == .rightToLeft
        let xPosition = isRTL
            ? bounds.width - _textView.textContainerInset.right - 5 - placeholderSize.width
            : _textView.textContainerInset.left + 5
        _placeholderLabel.frame = CGRect(origin: CGPoint(x: xPosition, y: _textView.textContainerInset.top), size: placeholderSize)
    }
    
    private func measureTextViewSize() -> CGSize {
        var rect = self.bounds
        let size = _textView.sizeThatFits(CGSize(width: rect.size.width, height: CGFloat.greatestFiniteMagnitude))
        return size
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
    
    /// Recalculate height after programmatic text changes (clear / setText).
    open func refreshHeight() {
        fitToScrollView()
    }

    private func fitToScrollView() {
        let actualTextViewSize = measureTextViewSize()
        let shouldScroll =
            _maxHeight > 0 && actualTextViewSize.height > _maxHeight + 0.5

        // Keep the text view at the visible height once max lines are reached so UITextView can scroll.
        var textViewFrame = bounds
        textViewFrame.origin = .zero
        textViewFrame.size.height = shouldScroll
            ? _maxHeight
            : max(actualTextViewSize.height, _minHeight)
        if !_textView.frame.equalTo(textViewFrame) {
            _textView.frame = textViewFrame
        }

        contentSize = textViewFrame.size

        let oldScrollViewFrame = frame
        let newScrollViewFrame = measureFrame(actualTextViewSize)

        if _textView.isScrollEnabled != shouldScroll {
            _textView.isScrollEnabled = shouldScroll
        }

        if !newScrollViewFrame.equalTo(oldScrollViewFrame) {
            viewDelegate?.growingTextView(self, didChangeHeight: newScrollViewFrame.height)
        }

        if shouldScroll {
            scrollToCaret()
        }
    }

    private func scrollToCaret() {
        let selectedRange = _textView.selectedRange
        guard selectedRange.location != NSNotFound else { return }
        // Layout must be current before scrolling the caret into view.
        _textView.layoutManager.ensureLayout(for: _textView.textContainer)
        _textView.scrollRangeToVisible(selectedRange)
    }
    private func updateMinimumAndMaximumHeight() {
        _minHeight = max(simulateHeight(1), minimumHeight)
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
