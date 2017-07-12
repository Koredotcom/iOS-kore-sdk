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
    
    var maskType: BubbleMaskType = .full {
        didSet {
            self.bubbleView.maskType = self.maskType
            switch (maskType) {
            case .top:
                self.bubbleBottomConstraint.constant = 1
                break
                
            case .middle:
                self.bubbleBottomConstraint.constant = 1
                break
                
            case .bottom:
                self.bubbleBottomConstraint.constant = 8
                break
                
            case .full:
                self.bubbleBottomConstraint.constant = 8
                break
            }
        }
    }
    
    var didSelectComponentAtIndex: ((_ sender: MessageBubbleCell, _ index: NSInteger) -> Void)! {
        didSet {
            // pass the selection on to the TableView controller
            self.bubbleView.didSelectComponentAtIndex = { [weak self] (index: Int) in
                if ((self!.didSelectComponentAtIndex) != nil) {
                    self?.didSelectComponentAtIndex(self!, index)
                }
            }
        }
    }
    
    override func prepareForReuse() {
        self.textLabel?.text = nil
        self.bubbleContainerView.layoutSubviews()
        self.bubbleContainerView.invalidateIntrinsicContentSize()
        self.bubbleContainerView.layoutIfNeeded()
        self.bubbleContainerView.setNeedsDisplay()
        self.senderImageView.image = nil;
        self.dateLabel.text = nil;
        self.bubbleView.layoutSubviews();
        self.bubbleView.invalidateIntrinsicContentSize()
        self.bubbleView.layoutIfNeeded()
        self.bubbleView.setNeedsDisplay()
    }

    func initialize() {
        self.selectionStyle = .none
        
        self.dateLabel = UILabel()
        self.dateLabel.numberOfLines = 0
        self.dateLabel.translatesAutoresizingMaskIntoConstraints = false
        self.dateLabel.font = UIFont(name: "HelveticaNeue", size: 13)
        self.dateLabel.textColor = .lightGray
        
        // Create the sender imageView
        self.senderImageView = UIImageView()
        self.senderImageView.contentMode = .scaleAspectFit
        self.senderImageView.clipsToBounds = true
        self.senderImageView.layer.cornerRadius = 15
        self.senderImageView.translatesAutoresizingMaskIntoConstraints = false
        
        self.senderImageView.setContentHuggingPriority(251, for:.horizontal)
        self.senderImageView.setContentHuggingPriority(251, for:.vertical)
        self.senderImageView.setContentCompressionResistancePriority(750, for:.horizontal)
        self.senderImageView.setContentCompressionResistancePriority(750, for:.vertical)
        
        self.contentView.addSubview(self.senderImageView)
        self.contentView.addSubview(self.dateLabel)
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-8-[senderImageView(30)]", options:[], metrics:nil, views:["senderImageView":self.senderImageView!]))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[senderImageView(30)]-8-|", options:[], metrics:nil, views:["senderImageView":self.senderImageView!]))
        
        self.dateLabelLeadingConstraint = NSLayoutConstraint(item: self.dateLabel, attribute:.leading, relatedBy:.equal, toItem:self.contentView, attribute:.leading, multiplier:1.0, constant:40.0)
        self.dateLabelLeadingConstraint.priority = 999

        self.dateLabelTrailingConstraint = NSLayoutConstraint(item: self.dateLabel, attribute:.trailing, relatedBy:.equal, toItem:self.contentView, attribute:.trailing, multiplier:1.0, constant:-20)
        self.dateLabelTrailingConstraint.priority = 1

        self.dateLabelTopConstraint = NSLayoutConstraint(item: self.dateLabel, attribute:.top, relatedBy:.equal, toItem:self.contentView, attribute:.top, multiplier:1.0, constant:0.0)
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
        self.bubbleContainerView.backgroundColor = UIColor.clear
        self.bubbleContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        self.bubbleContainerView.setContentHuggingPriority(250, for:.horizontal)
        self.bubbleContainerView.setContentHuggingPriority(250, for:.vertical)
        self.bubbleContainerView.setContentCompressionResistancePriority(750, for:.horizontal)
        self.bubbleContainerView.setContentCompressionResistancePriority(750, for:.vertical)
        
        self.contentView.addSubview(self.bubbleContainerView)
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[dateLabel]-4-[bubbleContainerView]", options:[], metrics:nil, views:["dateLabel":self.dateLabel!, "bubbleContainerView": self.bubbleContainerView]))

        self.bubbleBottomConstraint = NSLayoutConstraint(item:self.contentView, attribute:.bottom, relatedBy:.equal, toItem:self.bubbleContainerView, attribute:.bottom, multiplier:1.0, constant:16.0)
        self.bubbleBottomConstraint.priority = 999

        self.bubbleLeadingConstraint = NSLayoutConstraint(item:self.bubbleContainerView, attribute:.leading, relatedBy:.equal, toItem:self.contentView, attribute:.leading, multiplier:1.0, constant:35.0)
        self.bubbleLeadingConstraint.priority = 999
        
        self.bubbleTrailingConstraint = NSLayoutConstraint(item:self.contentView, attribute:.trailing, relatedBy:.equal, toItem:self.bubbleContainerView, attribute:.trailing, multiplier:1.0, constant:16.0)
        self.bubbleTrailingConstraint.priority = 1
        
        self.contentView.addConstraints([self.bubbleTrailingConstraint, self.bubbleLeadingConstraint, self.bubbleBottomConstraint, self.dateLabelTopConstraint, self.dateLabelLeadingConstraint, self.dateLabelTrailingConstraint])
    }

    func bubbleType() -> BubbleType {
        return BubbleType.view
    }

    static func bubbleViewForComponent(_ component: Component) -> BubbleView {
        var bubbleView: BubbleView!
        
        switch (component.componentType) {
            case .text:
                bubbleView = BubbleView.bubbleWithType(.text)
                break
            case .image:
                bubbleView = BubbleView.bubbleWithType(.image)
                break
            case .options:
                bubbleView = BubbleView.bubbleWithType(.options)
                break
            case .quickReply:
                bubbleView = BubbleView.bubbleWithType(.options)
                break
            case .list:
                bubbleView = BubbleView.bubbleWithType(.list)
                break
            case .carousel:
                bubbleView = BubbleView.bubbleWithType(.carousel)
                break
            case .unknown:
                bubbleView = BubbleView.bubbleWithType(.text)
                break
        }
        return bubbleView
    }
    
    static func bubbleViewForComponents(_ components: Array<KREComponent>, templateType: ComponentType) -> BubbleView {
        var bubbleView: BubbleView!
        
        switch (templateType) {
            case .image:
                bubbleView = BubbleView.bubbleWithType(.image)
                break
            case .options:
                bubbleView = BubbleView.bubbleWithType(.options)
                break
            case .list:
                bubbleView = BubbleView.bubbleWithType(.list)
                break
            case .carousel:
                bubbleView = BubbleView.bubbleWithType(.carousel)
                break
            default:
                bubbleView = BubbleView.bubbleWithType(.text)
                break
        }
        return bubbleView
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
    
    static func setComponent(_ component: Component, bubbleView: BubbleView) {
        
        if (component.message.messageType == .default) {
            bubbleView.tailPosition = .right
        } else {
            bubbleView.tailPosition = .left
        }
        
        bubbleView.components = component.message.components
        bubbleView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func configureWithComponentGroup(_ component: Component, maskType: BubbleMaskType) {
        let bubbleView: BubbleView!
        if (self.bubbleView == nil) {
            self.bubbleView = MessageBubbleCell.bubbleViewForComponent(component)
            
        }else{
            self.bubbleView = nil;
            self.bubbleView = MessageBubbleCell.bubbleViewForComponent(component)
        }
        bubbleView = self.bubbleView
        bubbleView.removeFromSuperview()
        self.bubbleContainerView.addSubview(bubbleView!)


        MessageBubbleCell.setComponent(component, bubbleView:self.bubbleView)
        
        self.tailPosition = self.bubbleView.tailPosition
        self.maskType = maskType
        
        let message: Message = component.message
        if (message.messageType == .default) {
            
        }
        
        if (message.sentDate != nil) {
            let dateFormatter: DateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEE, MMM d, h:mm a"
            self.dateLabel.text = dateFormatter.string(from: message.sentDate as Date)
        }
        
        let placeHolderIcon : UIImage = UIImage(named:"kora")!
        self.senderImageView.image = placeHolderIcon;
        
        if (message.iconUrl != nil) {
            if (message.iconUrl != nil) {
                let fileUrl = URL(string: message.iconUrl)
                self.senderImageView.setImageWith(fileUrl, placeholderImage: placeHolderIcon)
            }
        }
        
        let horizontal: Array<NSLayoutConstraint> = NSLayoutConstraint.constraints(withVisualFormat: "H:|[bubbleView]|", options:[], metrics:nil, views:["bubbleView": bubbleView])
        let vertical: Array<NSLayoutConstraint> = NSLayoutConstraint.constraints(withVisualFormat: "V:|[bubbleView]|", options:[], metrics:nil, views:["bubbleView": bubbleView])
        
        self.bubbleContainerView.addConstraints(horizontal)
        self.bubbleContainerView.addConstraints(vertical)
    }
    
    func configureWithComponents(_ components: Array<KREComponent>, maskType: BubbleMaskType, templateType: ComponentType) {
        if (self.bubbleView == nil) {
            self.bubbleView = MessageBubbleCell.bubbleViewForComponents(components, templateType: templateType)
        }
        
        MessageBubbleCell.setComponents(components, bubbleView:self.bubbleView)
        
        self.tailPosition = self.bubbleView.tailPosition
        self.maskType = maskType
        
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
            if (message.iconUrl != nil) {
                let fileUrl = URL(string: message.iconUrl!)
                self.senderImageView.setImageWith(fileUrl, placeholderImage: placeHolderIcon)
            }
        }
        
        let bubbleView: BubbleView  = self.bubbleView
        self.bubbleContainerView.addSubview(bubbleView)
        
        let horizontal: Array<NSLayoutConstraint> = NSLayoutConstraint.constraints(withVisualFormat: "H:|[bubbleView]|", options:[], metrics:nil, views:["bubbleView": bubbleView])
        let vertical: Array<NSLayoutConstraint> = NSLayoutConstraint.constraints(withVisualFormat: "V:|[bubbleView]|", options:[], metrics:nil, views:["bubbleView": bubbleView])
        
        self.bubbleContainerView.addConstraints(horizontal)
        self.bubbleContainerView.addConstraints(vertical)
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
        self.dateLabelTopConstraint = nil
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

class ImageBubbleCell : MessageBubbleCell {
    override func bubbleType() -> BubbleType {
        return BubbleType.image
    }
}

class OptionsBubbleCell : MessageBubbleCell {
    override func bubbleType() -> BubbleType {
        return BubbleType.options
    }
}
class ListBubbleCell : MessageBubbleCell {
    override func bubbleType() -> BubbleType {
        return BubbleType.list
    }
}

class CarouselBubbleCell : MessageBubbleCell {
    override func bubbleType() -> BubbleType {
        return BubbleType.carousel
    }
    
    override var tailPosition: BubbleMaskTailPosition {
        didSet {
            self.bubbleTrailingConstraint.constant = 35
            self.bubbleTrailingConstraint.priority = 999
        }
    }
}
