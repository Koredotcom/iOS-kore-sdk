//
//  MessageBubbleCell.swift
//  KoreBotSDKDemo
//
//  Created by Srinivas Vasadi on 09/05/16.
//  Copyright © 2016 Kore. All rights reserved.
//

import UIKit
import AFNetworking

class MessageBubbleCell : UITableViewCell {
    var bubbleContainerView: UIView!
    var senderImageView: UIImageView!
    var dateLabel: UILabel!

    var bubbleLeadingConstraint: NSLayoutConstraint!
    var bubbleTrailingConstraint: NSLayoutConstraint!
    var bubbleBottomConstraint: NSLayoutConstraint!
    
    var dateLabelLeadingConstraint: NSLayoutConstraint!
    var dateLabelTrailingConstraint: NSLayoutConstraint!
    var dateLabelTopConstraint: NSLayoutConstraint!
    
    var bubbleView: BubbleView!

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
            if (tailPosition == .Left) {
                self.bubbleLeadingConstraint.priority = 999
                self.bubbleTrailingConstraint.priority = 1
                
                self.dateLabelLeadingConstraint.priority = 999
                self.dateLabelTrailingConstraint.priority = 1
                self.senderImageView.hidden = false

            } else {
                self.bubbleLeadingConstraint.priority = 1
                self.bubbleTrailingConstraint.priority = 999
                
                self.dateLabelLeadingConstraint.priority = 1
                self.dateLabelTrailingConstraint.priority = 999
                self.senderImageView.hidden = true
            }
            
            self.bubbleView.tailPosition = tailPosition
            
            self.setNeedsUpdateConstraints()
        }
    }
    
    var maskType: BubbleMaskType = .Full {
        didSet {
            self.bubbleView.maskType = self.maskType
            switch (maskType) {
            case .Top:
                self.bubbleBottomConstraint.constant = 1
                break
                
            case .Middle:
                self.bubbleBottomConstraint.constant = 1
                break
                
            case .Bottom:
                self.bubbleBottomConstraint.constant = 8
                break
                
            case .Full:
                self.bubbleBottomConstraint.constant = 8
                break
            }
        }
    }
    
    var didSelectComponentAtIndex: ((sender: MessageBubbleCell, index: NSInteger) -> Void)! {
        didSet {
            // pass the selection on to the TableView controller
            self.bubbleView.didSelectComponentAtIndex = { [weak self] (index: Int) in
                if ((self!.didSelectComponentAtIndex) != nil) {
                    self!.didSelectComponentAtIndex(sender: self!, index: index)
                }
            }
        }
    }
    override func prepareForReuse() {
        self.textLabel?.text = nil
    }
    // MARK:

    func initialize() {
        self.selectionStyle = .None
        
        self.dateLabel = UILabel()
        self.dateLabel.numberOfLines = 0
        self.dateLabel.translatesAutoresizingMaskIntoConstraints = false
        self.dateLabel.font = UIFont(name: "HelveticaNeue", size: 13)
        self.dateLabel.textColor = .lightGrayColor()
        
        // Create the sender imageView
        self.senderImageView = UIImageView()
        self.senderImageView.contentMode = .ScaleAspectFit
        self.senderImageView.clipsToBounds = true
        self.senderImageView.layer.cornerRadius = 15
        self.senderImageView.translatesAutoresizingMaskIntoConstraints = false
        
        self.senderImageView.setContentHuggingPriority(251, forAxis:.Horizontal)
        self.senderImageView.setContentHuggingPriority(251, forAxis:.Vertical)
        self.senderImageView.setContentCompressionResistancePriority(750, forAxis:.Horizontal)
        self.senderImageView.setContentCompressionResistancePriority(750, forAxis:.Vertical)
        
        self.contentView.addSubview(self.senderImageView)
        self.contentView.addSubview(self.dateLabel)
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-8-[senderImageView(30)]", options:[], metrics:nil, views:["senderImageView":self.senderImageView!]))
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[senderImageView(30)]-8-|", options:[], metrics:nil, views:["senderImageView":self.senderImageView!]))
        
        self.dateLabelLeadingConstraint = NSLayoutConstraint(item: self.dateLabel, attribute:.Leading, relatedBy:.Equal, toItem:self.contentView, attribute:.Leading, multiplier:1.0, constant:40.0)
        self.dateLabelLeadingConstraint.priority = 999

        self.dateLabelTrailingConstraint = NSLayoutConstraint(item: self.dateLabel, attribute:.Trailing, relatedBy:.Equal, toItem:self.contentView, attribute:.Trailing, multiplier:1.0, constant:-20)
        self.dateLabelTrailingConstraint.priority = 1

        self.dateLabelTopConstraint = NSLayoutConstraint(item: self.dateLabel, attribute:.Top, relatedBy:.Equal, toItem:self.contentView, attribute:.Top, multiplier:1.0, constant:0.0)
        self.dateLabelTopConstraint.priority = 999

        
        // Create the container view
        /*
         The bubble container view has fixed top and bottom constraints
         The left and right constraints have opposite priorities 1-999 or 999-1
         This sets the container position horizontally in the cell based on the tail position
         The bubbleView that is contained within the bubbleViewContainer has a fixed top,bottom,left,right constraint of 0
         so it will force the cell to resize dynamically based on the intrinsicContentSize of the bubbleView
         */

        self.bubbleContainerView = UIView()
        self.bubbleContainerView.backgroundColor = UIColor.clearColor()
        self.bubbleContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        self.bubbleContainerView.setContentHuggingPriority(250, forAxis:.Horizontal)
        self.bubbleContainerView.setContentHuggingPriority(250, forAxis:.Vertical)
        self.bubbleContainerView.setContentCompressionResistancePriority(750, forAxis:.Horizontal)
        self.bubbleContainerView.setContentCompressionResistancePriority(750, forAxis:.Vertical)
        
        self.contentView.addSubview(self.bubbleContainerView)
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[dateLabel]-4-[bubbleContainerView]", options:[], metrics:nil, views:["dateLabel":self.dateLabel!, "bubbleContainerView": self.bubbleContainerView]))

        self.bubbleBottomConstraint = NSLayoutConstraint(item:self.contentView, attribute:.Bottom, relatedBy:.Equal, toItem:self.bubbleContainerView, attribute:.Bottom, multiplier:1.0, constant:16.0)
        self.bubbleBottomConstraint.priority = 999

        self.bubbleLeadingConstraint = NSLayoutConstraint(item:self.bubbleContainerView, attribute:.Leading, relatedBy:.Equal, toItem:self.contentView, attribute:.Leading, multiplier:1.0, constant:35.0)
        self.bubbleLeadingConstraint.priority = 999
        
        self.bubbleTrailingConstraint = NSLayoutConstraint(item:self.contentView, attribute:.Trailing, relatedBy:.Equal, toItem:self.bubbleContainerView, attribute:.Trailing, multiplier:1.0, constant:16.0)
        self.bubbleTrailingConstraint.priority = 1
        
        self.contentView.addConstraints([self.bubbleTrailingConstraint, self.bubbleLeadingConstraint, self.bubbleBottomConstraint, self.dateLabelTopConstraint, self.dateLabelLeadingConstraint, self.dateLabelTrailingConstraint])
    }

    func bubbleType() -> BubbleType {
        return BubbleType.View
    }

    static func bubbleViewForComponentGroup(componentGroup: ComponentGroup) -> BubbleView {
        var bubbleView: BubbleView!
        
        switch (componentGroup.componentKind()) {
        case .Text:
            bubbleView = BubbleView.bubbleWithType(.Text)
            break
            
        case .Image:
            bubbleView = BubbleView.bubbleWithType(.Image)
            break
            
        case .Unknown:
            bubbleView = BubbleView.bubbleWithType(.Text)
            break
        }
        return bubbleView
    }

    static func setComponentGroup(componentGroup: ComponentGroup, bubbleView: BubbleView) {
        
        if (componentGroup.message().messageType == .Default) {
            bubbleView.tailPosition = .Right
        } else {
            bubbleView.tailPosition = .Left
        }
        
        bubbleView.components = componentGroup.components
        bubbleView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func configureWithComponentGroup(componentGroup: ComponentGroup, maskType: BubbleMaskType) {
        if (self.bubbleView == nil) {
            self.bubbleView = MessageBubbleCell.bubbleViewForComponentGroup(componentGroup)
        }
        
        MessageBubbleCell.setComponentGroup(componentGroup, bubbleView:self.bubbleView)
        
        self.tailPosition = self.bubbleView.tailPosition
        self.maskType = maskType
        
        let message: Message = componentGroup.message()
        if (message.messageType == .Default) {
            
        }
        
        if (message.sentDate != nil) {
            let dateFormatter: NSDateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "EEE, MMM d, h:mm a"
            self.dateLabel.text = dateFormatter.stringFromDate(message.sentDate)
        }
        
        let placeHolderIcon : UIImage = UIImage(named:"kora")!
        self.senderImageView.image = placeHolderIcon;
        
        if (message.iconUrl != nil) {
            if (message.iconUrl != nil) {
                let fileUrl = NSURL(string: message.iconUrl)
                self.senderImageView.setImageWithURL(fileUrl, placeholderImage: placeHolderIcon)
            }
        }
        
        let bubbleView: BubbleView  = self.bubbleView
        self.bubbleContainerView.addSubview(bubbleView)
        
        let horizontal: Array<NSLayoutConstraint> = NSLayoutConstraint.constraintsWithVisualFormat("H:|[bubbleView]|", options:[], metrics:nil, views:["bubbleView": bubbleView])
        let vertical: Array<NSLayoutConstraint> = NSLayoutConstraint.constraintsWithVisualFormat("V:|[bubbleView]|", options:[], metrics:nil, views:["bubbleView": bubbleView])
        
        self.bubbleContainerView.addConstraints(horizontal)
        self.bubbleContainerView.addConstraints(vertical)
    }

    func components() -> NSArray {
        return self.bubbleView.components
    }

}

class TextBubbleCell : MessageBubbleCell {
    override func bubbleType() -> BubbleType {
        return BubbleType.Text
    }
}

class ImageBubbleCell : MessageBubbleCell {
    override func bubbleType() -> BubbleType {
        return BubbleType.Image
    }
}
