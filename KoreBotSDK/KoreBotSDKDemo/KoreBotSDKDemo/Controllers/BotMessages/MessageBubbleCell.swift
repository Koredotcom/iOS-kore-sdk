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
    var dateLabel: UILabel!
    var bubbleView: BubbleView!

    var bubbleLeadingConstraint: NSLayoutConstraint!
    var bubbleTrailingConstraint: NSLayoutConstraint!
    var bubbleBottomConstraint: NSLayoutConstraint!
    
    var dateLabelLeadingConstraint: NSLayoutConstraint!
    var dateLabelTrailingConstraint: NSLayoutConstraint!

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
                self.bubbleLeadingConstraint.priority = 999
                self.bubbleTrailingConstraint.priority = 1
                
                self.dateLabelLeadingConstraint.priority = 999
                self.dateLabelTrailingConstraint.priority = 1
                self.senderImageView.isHidden = false

            } else {
                self.bubbleLeadingConstraint.priority = 1
                self.bubbleTrailingConstraint.priority = 999
                
                self.dateLabelLeadingConstraint.priority = 1
                self.dateLabelTrailingConstraint.priority = 999
                self.senderImageView.isHidden = true
            }
            
            self.bubbleView.tailPosition = tailPosition
            self.setNeedsUpdateConstraints()
        }
    }
    
    override func prepareForReuse() {
        self.dateLabel.text = nil;
        self.senderImageView.image = nil;
        self.bubbleView.prepareForReuse();
        self.bubbleView.invalidateIntrinsicContentSize()
    }

    func initialize() {
        self.selectionStyle = .none
        
        self.dateLabel = UILabel()
        self.dateLabel.numberOfLines = 0
        self.dateLabel.translatesAutoresizingMaskIntoConstraints = false
        self.dateLabel.font = UIFont(name: "HelveticaNeue", size: 13)
        self.dateLabel.textColor = .lightGray
        self.contentView.addSubview(self.dateLabel)

        // Create the sender imageView
        self.senderImageView = UIImageView()
        self.senderImageView.contentMode = .scaleAspectFit
        self.senderImageView.clipsToBounds = true
        self.senderImageView.layer.cornerRadius = 15
        self.senderImageView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(self.senderImageView)
        
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
        
        // Setting content Priorities
        self.senderImageView.setContentHuggingPriority(251, for:.horizontal)
        self.senderImageView.setContentCompressionResistancePriority(751, for:.horizontal)
        
        self.bubbleContainerView.setContentHuggingPriority(250, for:.horizontal)
        self.bubbleContainerView.setContentCompressionResistancePriority(750, for:.horizontal)
        
        // Setting Constraints
        let views: [String: UIView] = ["dateLabel": dateLabel, "senderImageView": senderImageView, "bubbleContainerView": bubbleContainerView]
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[dateLabel]", options:[], metrics:nil, views:views))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-8-[senderImageView(30)]", options:[], metrics:nil, views:views))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[senderImageView(30)]-8-|", options:[], metrics:nil, views:views))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[dateLabel]-4-[bubbleContainerView]", options:[], metrics:nil, views:views))
        
        self.dateLabelLeadingConstraint = NSLayoutConstraint(item: self.dateLabel, attribute:.leading, relatedBy:.equal, toItem:self.contentView, attribute:.leading, multiplier:1.0, constant:45.0)
        self.dateLabelLeadingConstraint.priority = 999
        self.dateLabelTrailingConstraint = NSLayoutConstraint(item: self.contentView, attribute:.trailing, relatedBy:.equal, toItem:self.dateLabel, attribute:.trailing, multiplier:1.0, constant:16.0)
        self.dateLabelTrailingConstraint.priority = 1

        self.bubbleBottomConstraint = NSLayoutConstraint(item:self.contentView, attribute:.bottom, relatedBy:.equal, toItem:self.bubbleContainerView, attribute:.bottom, multiplier:1.0, constant:8.0)
        self.bubbleBottomConstraint.priority = 999
        self.bubbleLeadingConstraint = NSLayoutConstraint(item:self.bubbleContainerView, attribute:.leading, relatedBy:.equal, toItem:self.contentView, attribute:.leading, multiplier:1.0, constant:45.0)
        self.bubbleLeadingConstraint.priority = 999
        self.bubbleTrailingConstraint = NSLayoutConstraint(item:self.contentView, attribute:.trailing, relatedBy:.equal, toItem:self.bubbleContainerView, attribute:.trailing, multiplier:1.0, constant:16.0)
        self.bubbleTrailingConstraint.priority = 1
        
        self.contentView.addConstraints([self.bubbleTrailingConstraint, self.bubbleLeadingConstraint, self.bubbleBottomConstraint, self.dateLabelLeadingConstraint, self.dateLabelTrailingConstraint])
    }

    func bubbleType() -> BubbleType {
        return BubbleType.view
    }

    static func setComponents(_ components: Array<KREComponent>, bubbleView: BubbleView) {
        let component: KREComponent = components.first!
        if (component.message?.isSender == true) {
            bubbleView.tailPosition = .right
        } else {
            bubbleView.tailPosition = .left
        }
    
        bubbleView.components = components as NSArray!
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
        
        if (message.sentOn != nil) {
            let dateFormatter: DateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEE, MMM d, h:mm a"
            self.dateLabel.text = dateFormatter.string(from: message.sentOn! as Date)
        }
        
        let placeHolderIcon : UIImage = UIImage(named:"kora")!
        self.senderImageView.image = placeHolderIcon;
        
        if (message.iconUrl != nil) {
            let fileUrl = URL(string: message.iconUrl!)
            self.senderImageView.setImageWith(fileUrl, placeholderImage: placeHolderIcon)
        }
    }

    func components() -> NSArray {
        return self.bubbleView.components
    }
    
    // MARK:- deinit
    deinit {
        self.bubbleContainerView = nil
        self.senderImageView = nil
        self.dateLabel = nil
        self.bubbleLeadingConstraint = nil
        self.bubbleTrailingConstraint = nil
        self.bubbleBottomConstraint = nil
        self.dateLabelLeadingConstraint = nil
        self.dateLabelTrailingConstraint = nil
        self.bubbleView = nil
    }
}

class TextBubbleCell : MessageBubbleCell {
    override func bubbleType() -> BubbleType {
        return BubbleType.text
    }
}

class QuickReplyBubbleCell : MessageBubbleCell {
    override func bubbleType() -> BubbleType {
        return BubbleType.quickReply
    }
}

class ErrorBubbleCell : MessageBubbleCell {
    override func bubbleType() -> BubbleType {
        return BubbleType.error
    }
}

class ImageBubbleCell : MessageBubbleCell {
    override func bubbleType() -> BubbleType {
        return BubbleType.image
    }
}

class OptionsBubbleCell : MessageBubbleCell {
    override func bubbleType() -> BubbleType {
        return BubbleType.options
    }
    
    override var tailPosition: BubbleMaskTailPosition {
        didSet {
            self.bubbleTrailingConstraint.constant = 45
            self.bubbleTrailingConstraint.priority = 999
        }
    }
}

class ListBubbleCell : MessageBubbleCell {
    override func bubbleType() -> BubbleType {
        return BubbleType.list
    }
    
    override var tailPosition: BubbleMaskTailPosition {
        didSet {
            self.bubbleTrailingConstraint.constant = 45
            self.bubbleTrailingConstraint.priority = 999
        }
    }
}

class CarouselBubbleCell : MessageBubbleCell {
    override func bubbleType() -> BubbleType {
        return BubbleType.carousel
    }
    
    override var tailPosition: BubbleMaskTailPosition {
        didSet {
            self.bubbleLeadingConstraint.constant = 0
            self.bubbleTrailingConstraint.constant = 0
            self.bubbleTrailingConstraint.priority = 999
        }
    }
}
