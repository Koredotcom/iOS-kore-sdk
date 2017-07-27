//
//  KRETextViewInternal.swift
//  Pods
//
//  Created by Anoop Dhiman on 27/07/17.
//
//

import UIKit
import Foundation

internal class KRETextViewInternal: UITextView {

    // MARK: - Internal
    var textDidChange: () -> Void = {}
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        NotificationCenter.default.addObserver(self, selector: #selector(KRETextViewInternal.textDidChangeNotification(_ :)), name: NSNotification.Name.UITextViewTextDidChange, object: self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override var text: String! {
        didSet {
            textDidChange()
            updatePlaceholder()
        }
    }
    
    override var attributedText: NSAttributedString! {
        didSet {
            textDidChange()
            updatePlaceholder()
        }
    }
    
    var placeholderAttributedText: NSAttributedString? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard displayPlaceholder else { return }
        
        let paragraphStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = textAlignment
        
        let targetRect = CGRect(
            x: 5 + textContainerInset.left,
            y: textContainerInset.top,
            width: frame.size.width - (textContainerInset.left + textContainerInset.right),
            height: frame.size.height - (textContainerInset.top + textContainerInset.bottom)
        )
        
        let attributedString = placeholderAttributedText
        attributedString?.draw(in: targetRect)
    }
    
    // MARK: Private
    
    private var displayPlaceholder: Bool = true {
        didSet {
            if oldValue != displayPlaceholder {
                setNeedsDisplay()
            }
        }
    }
    
    private dynamic func textDidChangeNotification(_ notification: Notification) {
        updatePlaceholder()
        textDidChange()
    }
    
    private func updatePlaceholder() {
        displayPlaceholder = text.characters.count == 0
    }
}
