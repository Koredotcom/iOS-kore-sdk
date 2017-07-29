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
        }
    }
    
    override var attributedText: NSAttributedString! {
        didSet {
            textDidChange()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setNeedsDisplay()
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
        textDidChange()
    }
}
