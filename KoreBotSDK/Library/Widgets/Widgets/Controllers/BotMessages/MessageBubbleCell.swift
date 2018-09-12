//
//  MessageBubbleCell.swift
//  KoreBotSDKDemo
//
//  Created by developer@kore.com on 09/05/16.
//  Copyright © 2016 Kore Inc. All rights reserved.
//

import UIKit
import AFNetworking

class MessageBubbleCell : UITableViewCell {
    var bubbleContainerView: UIView!
    var senderImageView: UIImageView!
    var userImageView: UIImageView!
    var bubbleView: BubbleView!
    var showUserImageView: Bool = false
    var showSenderImageView: Bool = false
    var bubbleLeadingConstraint: NSLayoutConstraint!
    var bubbleTrailingConstraint: NSLayoutConstraint!
    var bubbleBottomConstraint: NSLayoutConstraint!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: properties with observers
    var tailPosition: BubbleMaskTailPosition {
        get {
            return self.bubbleView.tailPosition
        }
        set {
            if (tailPosition == .left) {
                self.bubbleLeadingConstraint.priority = UILayoutPriority.defaultHigh
                self.bubbleTrailingConstraint.priority = UILayoutPriority.defaultLow
                self.senderImageView.isHidden = !showSenderImageView
                self.userImageView.isHidden = true
            } else {
                self.bubbleLeadingConstraint.priority = UILayoutPriority.defaultLow
                self.bubbleTrailingConstraint.priority = UILayoutPriority.defaultHigh
                self.senderImageView.isHidden = true
                self.userImageView.isHidden = !showUserImageView
            }
            
            self.bubbleView.tailPosition = tailPosition
            self.setNeedsUpdateConstraints()
        }
    }
    
    override func prepareForReuse() {
        self.senderImageView.image = nil;
        self.userImageView.image = nil
        self.bubbleView.prepareForReuse();
        self.bubbleView.invalidateIntrinsicContentSize()
    }

    func initialize() {
        self.selectionStyle = .none
        self.clipsToBounds = true
        self.contentView.transform = CGAffineTransform(scaleX: 1, y: -1)

        // Create the sender imageView
        self.senderImageView = UIImageView()
        self.senderImageView.contentMode = .scaleAspectFit
        self.senderImageView.clipsToBounds = true
        self.senderImageView.layer.cornerRadius = 15
        self.senderImageView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(self.senderImageView)
        
        self.userImageView = UIImageView()
        self.userImageView.contentMode = .scaleAspectFit
        self.userImageView.clipsToBounds = true
        self.userImageView.layer.cornerRadius = 15
        self.userImageView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(self.userImageView)
        
        // Create the container view
        /*
         The bubble container view has fixed top and bottom constraints
         The left and right constraints have opposite priorities 1-999 or 999-1
         This sets the container position horizontally in the cell based on the tail position
         The bubbleView that is contained within the bubbleViewContainer has a fixed top,bottom,left,right constraint of 0
         so it will force the cell to resize dynamically based on the intrinsicContentSize of the bubbleView
         */

        self.bubbleContainerView = UIView()
        self.bubbleContainerView.backgroundColor = UIColor.clear
        self.bubbleContainerView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(self.bubbleContainerView)
        
        // Setting Constraints
        let views: [String: UIView] = ["senderImageView": senderImageView, "bubbleContainerView": bubbleContainerView, "userImageView": userImageView]
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-8-[senderImageView(30)]", options:[], metrics:nil, views:views))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[senderImageView(30)]-4-|", options:[], metrics:nil, views:views))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[userImageView(30)]-8-|", options:[], metrics:nil, views:views))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[userImageView(30)]-4-|", options:[], metrics:nil, views:views))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[bubbleContainerView]", options:[], metrics:nil, views:views))

        self.bubbleBottomConstraint = NSLayoutConstraint(item:self.contentView, attribute:.bottom, relatedBy:.equal, toItem:self.bubbleContainerView, attribute:.bottom, multiplier:1.0, constant:4.0)
        self.bubbleBottomConstraint.priority = UILayoutPriority.defaultHigh
        self.bubbleLeadingConstraint = NSLayoutConstraint(item:self.bubbleContainerView, attribute:.leading, relatedBy:.equal, toItem:self.contentView, attribute:.leading, multiplier: 1.0, constant: showSenderImageView ? 45.0 : 12.0)
        self.bubbleLeadingConstraint.priority = UILayoutPriority.defaultHigh
        self.bubbleTrailingConstraint = NSLayoutConstraint(item:self.contentView, attribute:.trailing, relatedBy:.equal, toItem:self.bubbleContainerView, attribute:.trailing, multiplier:1.0, constant: showUserImageView ? 45.0 : 12.0)
        self.bubbleTrailingConstraint.priority = UILayoutPriority.defaultLow
        
        self.contentView.addConstraints([self.bubbleTrailingConstraint, self.bubbleLeadingConstraint, self.bubbleBottomConstraint])
    }

    func bubbleType() -> ComponentType {
        return .text
    }

    static func setComponents(_ components: [KREComponent], bubbleView: BubbleView) {
        let component: KREComponent = components.first!
        if (component.message?.isSender == true) {
            bubbleView.tailPosition = .right
        } else {
            bubbleView.tailPosition = .left
        }
    
        bubbleView.components = components
        bubbleView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func configureWithComponents(_ components: Array<KREComponent>) {
        if (self.bubbleView == nil) {
            self.bubbleView = BubbleView.bubbleWithType(bubbleType())
            self.bubbleContainerView.addSubview(self.bubbleView)
            
            self.bubbleContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[bubbleView]|", options:[], metrics:nil, views:["bubbleView": self.bubbleView]))
            self.bubbleContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[bubbleView]|", options:[], metrics:nil, views:["bubbleView": self.bubbleView]))
        }
        
        MessageBubbleCell.setComponents(components, bubbleView:self.bubbleView)
        self.tailPosition = self.bubbleView.tailPosition
        
        let component: KREComponent = components.first!
        let message: KREMessage = component.message!

        let bundle = Bundle(for: MessageBubbleCell.self)
        if let placeHolderIcon = UIImage(named: "kora", in: bundle, compatibleWith: nil) {
            self.senderImageView.image = placeHolderIcon
        }
        
        if self.userImageView.image == nil, let image = UIImage(named: KoreBotUIKit.User.BubbleView.imageName) {
            self.userImageView.image = image
        } else if let image = UIImage(named: "faceIcon", in: Bundle(for: MessageBubbleCell.self), compatibleWith: nil) {
            self.userImageView.image = image
        }
        
        if let image = UIImage(named: KoreBotUIKit.Bot.BubbleView.imageName) {
            self.senderImageView.image = image
        } else if let iconUrl = message.iconUrl, let fileUrl = URL(string: iconUrl), let placeHolderIcon = UIImage(named: "kora", in: Bundle(for: MessageBubbleCell.self), compatibleWith: nil) {
            self.senderImageView.setImageWith(fileUrl, placeholderImage: placeHolderIcon)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(MessageBubbleCell.updateImageNotification(_:)), name: NSNotification.Name(rawValue: updateUserImageNotification), object: nil)
    }

    func components() -> [KREComponent]? {
        return self.bubbleView.components
    }
    
    func getEstimatedHeightForComponents(_ components: Array<KREComponent>, bubbleType:ComponentType) -> CGFloat {
        let bubbleView = BubbleView.bubbleWithType(bubbleType)
        bubbleView.components = components
        let height = bubbleView.intrinsicContentSize.height
        
        return height + 12.0
    }
    
    @objc func updateImageNotification(_ notification: Notification) {
        
    }
    
    // MARK:- deinit
    deinit {
        self.bubbleContainerView = nil
        self.senderImageView = nil
        self.userImageView = nil
        self.bubbleLeadingConstraint = nil
        self.bubbleTrailingConstraint = nil
        self.bubbleBottomConstraint = nil
        self.bubbleView = nil
    }
}

class TextBubbleCell : MessageBubbleCell {
    override func bubbleType() -> ComponentType {
        return .text
    }
}

class QuickReplyBubbleCell : MessageBubbleCell {
    override func bubbleType() -> ComponentType {
        return .quickReply
    }
}
class PickerBubbleCell : MessageBubbleCell {
    override func bubbleType() -> ComponentType {
        return .picker
    }
}
class SessionEndBubbleCell : MessageBubbleCell {
    override func bubbleType() -> ComponentType {
        return .sessionend
    }
}
class ErrorBubbleCell : MessageBubbleCell {
    override func bubbleType() -> ComponentType {
        return .error
    }
}

class ImageBubbleCell : MessageBubbleCell {
    override func bubbleType() -> ComponentType {
        return .image
    }
}

class OptionsBubbleCell : MessageBubbleCell {
    override func bubbleType() -> ComponentType {
        return .options
    }
    
    override var tailPosition: BubbleMaskTailPosition {
        didSet {
            self.bubbleTrailingConstraint.constant = showUserImageView ? 45.0 : 12.0
            self.bubbleTrailingConstraint.priority = UILayoutPriority.defaultHigh
        }
    }
}

class ListBubbleCell : MessageBubbleCell {
    override func bubbleType() -> ComponentType {
        return .list
    }
    
    override var tailPosition: BubbleMaskTailPosition {
        didSet {
            self.bubbleTrailingConstraint.constant = showUserImageView ? 45.0 : 12.0
            self.bubbleTrailingConstraint.priority = UILayoutPriority.defaultHigh
        }
    }
}

class CarouselBubbleCell : MessageBubbleCell {
    override func bubbleType() -> ComponentType {
        return .carousel
    }
    
    override var tailPosition: BubbleMaskTailPosition {
        didSet {
            self.bubbleLeadingConstraint.constant = 0
            self.bubbleTrailingConstraint.constant = 0
            self.bubbleTrailingConstraint.priority = UILayoutPriority.defaultHigh
        }
    }
}

class PiechartBubbleCell : MessageBubbleCell {
    override func bubbleType() -> ComponentType {
        return .chart
    }
    
    override var tailPosition: BubbleMaskTailPosition {
        didSet {
            self.bubbleLeadingConstraint.constant = 0
            self.bubbleTrailingConstraint.constant = 0
            self.bubbleTrailingConstraint.priority = UILayoutPriority.defaultHigh
        }
    }
    
    override func configureWithComponents(_ components: Array<KREComponent>) {
        super.configureWithComponents(components)
        self.senderImageView.isHidden = true
    }
}

class TableBubbleCell : MessageBubbleCell {
    override func bubbleType() -> ComponentType {
        return .table
    }
    
    override var tailPosition: BubbleMaskTailPosition {
        didSet {
            self.bubbleLeadingConstraint.constant = 0
            self.bubbleTrailingConstraint.constant = 0
            self.bubbleTrailingConstraint.priority = UILayoutPriority.defaultHigh
        }
    }
    
    override func configureWithComponents(_ components: Array<KREComponent>) {
        super.configureWithComponents(components)
        self.senderImageView.isHidden = true
    }
}

class MiniTableBubbleCell : MessageBubbleCell {
    override func bubbleType() -> ComponentType {
        return .minitable
    }
    
    override var tailPosition: BubbleMaskTailPosition {
        didSet {
            self.bubbleLeadingConstraint.constant = 0
            self.bubbleTrailingConstraint.constant = 0
            self.bubbleTrailingConstraint.priority = UILayoutPriority.defaultHigh
        }
    }
    
    override func configureWithComponents(_ components: Array<KREComponent>) {
        super.configureWithComponents(components)
        self.senderImageView.isHidden = true
    }
}
class MenuBubbleCell : MessageBubbleCell {
    override func bubbleType() -> ComponentType {
        return .menu
    }
    
    override var tailPosition: BubbleMaskTailPosition {
        didSet {
            self.bubbleLeadingConstraint.constant = showSenderImageView ? 45.0 : 12.0
            self.bubbleTrailingConstraint.priority = UILayoutPriority.defaultHigh
        }
    }
    
   
}
class ResponsiveTableBubbleCell : MessageBubbleCell {
    override func bubbleType() -> ComponentType {
        return .responsiveTable
    }
    
    override var tailPosition: BubbleMaskTailPosition {
        didSet {
            self.bubbleLeadingConstraint.constant = 0
            self.bubbleTrailingConstraint.constant = 0
            self.bubbleTrailingConstraint.priority = UILayoutPriority.defaultHigh
        }
    }
    
    override func configureWithComponents(_ components: Array<KREComponent>) {
        super.configureWithComponents(components)
        self.senderImageView.isHidden = true
    }
    
}
