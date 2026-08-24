//
//  MessageBubbleCell.swift
//  KoreBotSDKDemo
//
//  Created by developer@kore.com on 09/05/16.
//  Copyright © 2016 Kore Inc. All rights reserved.
//

import UIKit
import AlamofireImage

class MessageBubbleCell : UITableViewCell {
    let bundle = Bundle.sdkModule
    var bubbleContainerView: UIView!
    var senderImageView: UIImageView!
    var userImageView: UIImageView!
    var bubbleView: BubbleView!

    var bubbleLeadingConstraint: NSLayoutConstraint!
    var bubbleTrailingConstraint: NSLayoutConstraint!
    var bubbleBottomConstraint: NSLayoutConstraint!
    var bubbleTrailingConstant = 45.0
    var bubbleLeadingConstant = 45.0
    var dateLblTextColor = UIColor(hexString: "#4B4EDE")
    var dateLabelLeadingConstraint: NSLayoutConstraint!
    var dateLabelTrailingConstraint: NSLayoutConstraint!
    
    let defaultSpacing = 10.0
    let defaultDateSpacing = 13.0
    lazy var dateLabel: UILabel = {
        let dateLabel = UILabel(frame: .zero)
        dateLabel.numberOfLines = 0
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.font = UIFont(name: regularCustomFont, size: 10.0)
        dateLabel.textColor = .lightGray
        dateLabel.isHidden = true
        return dateLabel
    }()
    var dateLabelHeightConstraint: NSLayoutConstraint!
    var isHideBotIcon = true
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
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
            self.applyHorizontalAlignment(for: newValue)
            self.bubbleView.tailPosition = newValue
            self.setNeedsUpdateConstraints()
        }
    }

    func physicalTailPosition(for logicalTailPosition: BubbleMaskTailPosition) -> BubbleMaskTailPosition {
        guard isKoreSDKRTL else {
            return logicalTailPosition
        }
        return logicalTailPosition == .left ? .right : .left
    }

    func applyHorizontalAlignment(for logicalTailPosition: BubbleMaskTailPosition) {
        let physicalTailPosition = self.physicalTailPosition(for: logicalTailPosition)
        let alignsLeft = physicalTailPosition == .left

        // In RTL the user occupies the physical left side and the bot occupies
        // the physical right side, so their icon clearances must swap as well.
        if isKoreSDKRTL {
            self.bubbleLeadingConstraint.constant = bubbleTrailingConstant
            self.bubbleTrailingConstraint.constant = bubbleLeadingConstant
            self.dateLabelLeadingConstraint.constant = bubbleTrailingConstant + 3.0
            self.dateLabelTrailingConstraint.constant = bubbleLeadingConstant + 3.0
        } else {
            self.bubbleLeadingConstraint.constant = bubbleLeadingConstant
            self.bubbleTrailingConstraint.constant = bubbleTrailingConstant
            self.dateLabelLeadingConstraint.constant = bubbleLeadingConstant + 3.0
            self.dateLabelTrailingConstraint.constant = bubbleTrailingConstant + 3.0
        }

        self.bubbleLeadingConstraint.priority = alignsLeft ? UILayoutPriority.defaultHigh : UILayoutPriority.defaultLow
        self.bubbleTrailingConstraint.priority = alignsLeft ? UILayoutPriority.defaultLow : UILayoutPriority.defaultHigh
        self.dateLabelLeadingConstraint.priority = alignsLeft ? UILayoutPriority.defaultHigh : UILayoutPriority.defaultLow
        self.dateLabelTrailingConstraint.priority = alignsLeft ? UILayoutPriority.defaultLow : UILayoutPriority.defaultHigh

        // Visibility and colors follow message ownership, not physical direction.
        self.senderImageView.isHidden = isHideBotIcon || logicalTailPosition != .left
        self.userImageView.isHidden = logicalTailPosition == .left
    }

    // Templates that span the whole cell need both physical edges pinned. Only the
    // edge the bubble hugs keeps a high priority in applyHorizontalAlignment(for:),
    // and for a bot bubble that edge is the trailing one in RTL, so the leading
    // constraint has to be promoted again or the bubble grows to fit its content.
    func pinBubbleToBothEdges(spacing: CGFloat) {
        self.bubbleLeadingConstraint.constant = spacing
        self.bubbleTrailingConstraint.constant = spacing
        self.bubbleTrailingConstraint.priority = UILayoutPriority.defaultHigh
        if self.tailPosition == .left {
            self.bubbleLeadingConstraint.priority = UILayoutPriority.defaultHigh
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
        //self.senderImageView.layer.cornerRadius = 15
        self.senderImageView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(self.senderImageView)
        
        self.userImageView = UIImageView()
        self.userImageView.contentMode = .scaleAspectFit
        self.userImageView.clipsToBounds = true
        //self.userImageView.layer.cornerRadius = 15
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
        //dateLabel
        self.contentView.addSubview(dateLabel)
        
        // Setting Constraints
        let views: [String: UIView] = ["senderImageView": senderImageView, "bubbleContainerView": bubbleContainerView, "userImageView": userImageView, "dateLabel":dateLabel]
        
//        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[senderImageView(30)]-22-|", options:[], metrics:nil, views:views))
//        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[userImageView(30)]-22-|", options:[], metrics:nil, views:views))
        
        var senderImageViewWidth = 00
        bubbleLeadingConstant = 10.0
        var userImageViewWidth = 00
        bubbleTrailingConstant = 10.0
        if let icons = brandingBodyDic.icon{
            if let userIcon = icons.user_icon, userIcon == true{
                userImageViewWidth = 30
                bubbleTrailingConstant = 45.0
            }
            if !isHideBotIcon, let botIcon = icons.bot_icon, botIcon == true{
                senderImageViewWidth = 30
                bubbleLeadingConstant = 45.0
            }
           
        }
        
        //self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-\(bubbleLeadingConstant + 3.0)-[dateLabel]-\(bubbleTrailingConstant + 3.0)-|", options:[], metrics:nil, views:views))
        let senderIconFormat = isKoreSDKRTL
            ? "H:[senderImageView(\(senderImageViewWidth))]-8-|"
            : "H:|-8-[senderImageView(\(senderImageViewWidth))]"
        let userIconFormat = isKoreSDKRTL
            ? "H:|-8-[userImageView(\(userImageViewWidth))]"
            : "H:[userImageView(\(userImageViewWidth))]-8-|"
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: senderIconFormat, options:[.directionLeftToRight], metrics:nil, views:views))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: userIconFormat, options:[.directionLeftToRight], metrics:nil, views:views))
        
        var senderOrUserimageViewBottomVal = 4.0
        var dateLblHeight = 21.0
        if let timestamp = brandingBodyDic.time_stamp{
            if SDKConfiguration.botConfig.showMessageTimeStamps,
               let timeStampShow = timestamp.show,
               timeStampShow == true {
                dateLabel.isHidden = false
                dateLblTextColor = UIColor(hexString: timestamp.color ?? "#4B4EDE")
                dateLabel.textColor = dateLblTextColor
                
                if let position = timestamp.position, position == "top"{
                    dateLblHeight = 21.0
                    self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[dateLabel(21)]-0-[bubbleContainerView]", options:[], metrics:nil, views:views))
                    
                }else{
                    dateLblHeight = 21.0
                    self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[bubbleContainerView]-0-[dateLabel(21)]|", options:[], metrics:nil, views:views))
                    senderOrUserimageViewBottomVal = 22.0
                }
                
            }else{
                dateLblHeight = 0.0
                dateLabel.isHidden = true
                self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[dateLabel(0)]-0-[bubbleContainerView]", options:[], metrics:nil, views:views))
            }
        }else{
            dateLblHeight = 0.0
            dateLabel.isHidden = true
            self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[dateLabel(0)]-0-[bubbleContainerView]", options:[], metrics:nil, views:views))
        }
        
//        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[senderImageView(30)]-\(senderOrUserimageViewBottomVal)-|", options:[], metrics:nil, views:views))
//        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[userImageView(30)]-\(senderOrUserimageViewBottomVal)-|", options:[], metrics:nil, views:views))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-\(30)-[senderImageView(30)]", options:[], metrics:nil, views:views))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-\(30)-[userImageView(30)]", options:[], metrics:nil, views:views))

        self.bubbleBottomConstraint = NSLayoutConstraint(item:self.contentView, attribute:.bottom, relatedBy:.equal, toItem:self.bubbleContainerView, attribute:.bottom, multiplier:1.0, constant:4.0)
        self.bubbleBottomConstraint.priority = UILayoutPriority.defaultHigh
        self.bubbleLeadingConstraint = NSLayoutConstraint(item:self.bubbleContainerView as Any, attribute:.left, relatedBy:.equal, toItem:self.contentView, attribute:.left, multiplier:1.0, constant:bubbleLeadingConstant)
        self.bubbleLeadingConstraint.priority = UILayoutPriority.defaultHigh
        
        self.bubbleTrailingConstraint = NSLayoutConstraint(item:self.contentView, attribute:.right, relatedBy:.equal, toItem:self.bubbleContainerView, attribute:.right, multiplier:1.0, constant:10.0)
        self.bubbleTrailingConstraint.priority = UILayoutPriority.defaultLow
        
        self.dateLabelLeadingConstraint = NSLayoutConstraint(item:self.dateLabel as Any, attribute:.left, relatedBy:.equal, toItem:self.contentView, attribute:.left, multiplier:1.0, constant:bubbleLeadingConstant + 3.0) //change here
        self.dateLabelLeadingConstraint.priority = UILayoutPriority.defaultHigh
        
        
        self.dateLabelTrailingConstraint = NSLayoutConstraint(item:self.contentView as Any, attribute:.right, relatedBy:.equal, toItem:self.dateLabel, attribute:.right, multiplier:1.0, constant:(bubbleTrailingConstant + 3.0)) //change here
        self.dateLabelTrailingConstraint.priority = UILayoutPriority.defaultHigh
        
        self.dateLabelHeightConstraint =  NSLayoutConstraint.init(item: self.dateLabel as Any, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: dateLblHeight)
        
        self.contentView.addConstraints([self.bubbleTrailingConstraint, self.bubbleLeadingConstraint, self.bubbleBottomConstraint, self.dateLabelLeadingConstraint, self.dateLabelTrailingConstraint, self.dateLabelHeightConstraint])
    }

    func bubbleType() -> ComponentType {
        return .text
    }

    static func setComponents(_ components: Array<KREComponent>, bubbleView: BubbleView) {
        let component: KREComponent = components.first!
        if (component.message?.isSender == true) {
            bubbleView.tailPosition = .right
        } else {
            bubbleView.tailPosition = .left
        }
    
        bubbleView.components = components as NSArray?
        bubbleView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func configureWithComponents(_ components: Array<KREComponent>) {
        if (self.bubbleView == nil) {
            self.bubbleView = BubbleView.bubbleWithType(bubbleType())
            self.bubbleContainerView.addSubview(self.bubbleView)
            
            self.bubbleContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[bubbleView]|", options:[], metrics:nil, views:["bubbleView": self.bubbleView as Any]))
            self.bubbleContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[bubbleView]|", options:[], metrics:nil, views:["bubbleView": self.bubbleView as Any]))
        }
        
        MessageBubbleCell.setComponents(components, bubbleView:self.bubbleView)
        self.tailPosition = self.bubbleView.tailPosition
        
        let component: KREComponent = components.first!
        let message: KREMessage = component.message!
        
       
       //DateLabel
        if let sentOn = message.sentOn as Date? {
//                let dateFormatter = DateFormatter()
//                dateFormatter.dateFormat = "EE, MMM dd yyyy 'at' hh:mm:ss a"
//            dateLabel.text = "\(SDKConfiguration.botConfig.chatBotName) \(dateFormatter.string(from: sentOn))"
            
            dateLabel.text = Utilities.getTimeformater(sentOn: sentOn)
        }
        let physicalTailPosition: BubbleMaskTailPosition
        if isKoreSDKRTL {
            physicalTailPosition = self.tailPosition == .left ? .right : .left
        } else {
            physicalTailPosition = self.tailPosition
        }
        if physicalTailPosition == .left {
            dateLabel.textAlignment = .left
        }else{
            dateLabel.textAlignment = .right
        }
        
        
        let placeHolderIcon = UIImage(named: "kore", in: bundle, compatibleWith: nil)
        self.senderImageView.image = isHideBotIcon ? nil : placeHolderIcon
        self.senderImageView.isHidden = isHideBotIcon
               if(self.userImageView.image == nil){
                   
                   self.userImageView.image = UIImage(named: "faceIcon", in: bundle, compatibleWith: nil)
               }
        
        if !isHideBotIcon, message.iconUrl != nil {
            if let fileUrl = URL(string: message.iconUrl!) {
                self.senderImageView.af.setImage(withURL: fileUrl, placeholderImage: placeHolderIcon)
            }
        }
        NotificationCenter.default.addObserver(self, selector: #selector(MessageBubbleCell.updateImage(notification:)), name: NSNotification.Name(rawValue: updateUserImageNotification), object: nil)
    }
    
    func components() -> NSArray {
        return self.bubbleView.components
    }
    
    func getEstimatedHeightForComponents(_ components: Array<KREComponent>, bubbleType:ComponentType) -> CGFloat {
        let bubbleView = BubbleView.bubbleWithType(bubbleType)
        bubbleView.components = components as NSArray?
        let height = bubbleView.intrinsicContentSize.height
        
        return height + 12.0
    }
    @objc func updateImage(notification:Notification){
        self.userImageView.image = UIImage(named:"john")
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
        self.dateLabelTrailingConstraint = nil
        self.dateLabelLeadingConstraint = nil
        self.dateLabelHeightConstraint = nil
    }
}

class TextBubbleCell : MessageBubbleCell {
    override func bubbleType() -> ComponentType {
        return .text
    }
    override var tailPosition: BubbleMaskTailPosition {
        didSet {
            self.applyHorizontalAlignment(for: tailPosition)
        }
    }
}

class QuickReplyBubbleCell : MessageBubbleCell {
    override func bubbleType() -> ComponentType {
        return .quickReply
    }
    override var tailPosition: BubbleMaskTailPosition {
        didSet {
            
        }
    }
}

class ErrorBubbleCell : MessageBubbleCell {
    override func bubbleType() -> ComponentType {
        return .error
    }
    override var tailPosition: BubbleMaskTailPosition {
        didSet {
            
        }
    }
}

class ImageBubbleCell : MessageBubbleCell {
    override func bubbleType() -> ComponentType {
        return .image
    }
    override var tailPosition: BubbleMaskTailPosition {
        didSet {
            if isHideBotIcon{
                self.bubbleLeadingConstraint.constant = defaultSpacing
                self.bubbleTrailingConstraint.constant = defaultSpacing
                self.bubbleTrailingConstraint.priority = UILayoutPriority.defaultHigh
                
                self.dateLabelLeadingConstraint.constant = defaultDateSpacing
            }else{
                
            }
        }
    }
    override func configureWithComponents(_ components: Array<KREComponent>) {
        super.configureWithComponents(components)
        if isHideBotIcon{
            self.senderImageView.isHidden = true
        }
    }
}

class AudioBubbleCell : MessageBubbleCell {
    override func bubbleType() -> ComponentType {
        return .audio
    }
    
    override var tailPosition: BubbleMaskTailPosition {
        didSet {
            if isHideBotIcon{
                self.bubbleLeadingConstraint.constant = defaultSpacing
                self.bubbleTrailingConstraint.constant = defaultSpacing
                self.bubbleTrailingConstraint.priority = UILayoutPriority.defaultHigh
                
                self.dateLabelLeadingConstraint.constant = defaultDateSpacing
            }else{
                
            }
        }
    }
    override func configureWithComponents(_ components: Array<KREComponent>) {
        super.configureWithComponents(components)
        if isHideBotIcon{
            self.senderImageView.isHidden = true
        }
    }
}

class OptionsBubbleCell : MessageBubbleCell {
    override func bubbleType() -> ComponentType {
        return .options
    }
    
    override var tailPosition: BubbleMaskTailPosition {
        didSet {
            self.bubbleTrailingConstraint.constant = bubbleTrailingConstant
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
            if isHideBotIcon{
                self.bubbleLeadingConstraint.constant = defaultSpacing
                self.bubbleTrailingConstraint.constant = defaultSpacing
                self.bubbleTrailingConstraint.priority = UILayoutPriority.defaultHigh
                
                self.dateLabelLeadingConstraint.constant = defaultDateSpacing
            }else{
                self.bubbleTrailingConstraint.constant = bubbleTrailingConstant
                self.bubbleTrailingConstraint.priority = UILayoutPriority.defaultHigh
            }
        }
    }
    override func configureWithComponents(_ components: Array<KREComponent>) {
        super.configureWithComponents(components)
        if isHideBotIcon{
            self.senderImageView.isHidden = true
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
                self.dateLabelLeadingConstraint.constant = defaultDateSpacing
            }
            
        }
        override func configureWithComponents(_ components: Array<KREComponent>) {
            super.configureWithComponents(components)
            self.senderImageView.isHidden = true
        }
}

class PiechartBubbleCell : MessageBubbleCell {
    override func bubbleType() -> ComponentType {
        return .chart
    }
    override var tailPosition: BubbleMaskTailPosition {
        didSet {
            if isHideBotIcon{
                self.bubbleLeadingConstraint.constant = defaultSpacing
                self.bubbleTrailingConstraint.constant = defaultSpacing
                self.bubbleTrailingConstraint.priority = UILayoutPriority.defaultHigh
                
                self.dateLabelLeadingConstraint.constant = defaultDateSpacing
            }else{
                self.bubbleTrailingConstraint.constant = bubbleTrailingConstant
                self.bubbleTrailingConstraint.priority = UILayoutPriority.defaultHigh
            }
        }
    }
    
    override func configureWithComponents(_ components: Array<KREComponent>) {
        super.configureWithComponents(components)
        if isHideBotIcon{
            self.senderImageView.isHidden = true
        }
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
            self.dateLabelLeadingConstraint.constant = defaultDateSpacing - 5
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
            self.dateLabelLeadingConstraint.constant = defaultDateSpacing
            if defaultDateSpacing == 13.0{
                 self.dateLabelLeadingConstraint.constant = defaultDateSpacing + 22.0
            }
        }
    }
    
    override func configureWithComponents(_ components: Array<KREComponent>) {
        super.configureWithComponents(components)
        self.senderImageView.isHidden = true
    }
}
class MiniTableHorizontalBubbleCell : MessageBubbleCell {
    override func bubbleType() -> ComponentType {
        return .minitable_Horizontal
    }
    
    override var tailPosition: BubbleMaskTailPosition {
        didSet {
            self.bubbleLeadingConstraint.constant = 0
            self.bubbleTrailingConstraint.constant = 0
            self.bubbleTrailingConstraint.priority = UILayoutPriority.defaultHigh
            self.dateLabelLeadingConstraint.constant = defaultDateSpacing
            if defaultDateSpacing == 13.0{
                self.dateLabelLeadingConstraint.constant = defaultDateSpacing + 22.0
            }
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
            self.bubbleLeadingConstraint.constant = bubbleLeadingConstant
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
            
            self.dateLabelLeadingConstraint.constant = defaultDateSpacing
            if defaultDateSpacing == 13.0{
                           self.dateLabelLeadingConstraint.constant = defaultDateSpacing + 22.0
            }
        }
    }
    
    override func configureWithComponents(_ components: Array<KREComponent>) {
        super.configureWithComponents(components)
        self.senderImageView.isHidden = true
    }
    
}

class NewListBubbleCell : MessageBubbleCell {
    override func bubbleType() -> ComponentType {
        return .newList
    }
    
    override var tailPosition: BubbleMaskTailPosition {
        didSet {
            if isHideBotIcon{
                self.bubbleLeadingConstraint.constant = defaultSpacing
                self.bubbleTrailingConstraint.constant = defaultSpacing
                self.bubbleTrailingConstraint.priority = UILayoutPriority.defaultHigh
                
                self.dateLabelLeadingConstraint.constant = defaultDateSpacing
            }else{
                self.bubbleTrailingConstraint.constant = bubbleTrailingConstant
                self.bubbleTrailingConstraint.priority = UILayoutPriority.defaultHigh
            }
        }
    }
    override func configureWithComponents(_ components: Array<KREComponent>) {
        super.configureWithComponents(components)
        if isHideBotIcon{
            self.senderImageView.isHidden = true
        }
    }
}
class TableListBubbleCell : MessageBubbleCell {
    override func bubbleType() -> ComponentType {
        return .tableList
    }
    override var tailPosition: BubbleMaskTailPosition {
        didSet {
            if isHideBotIcon{
                self.bubbleLeadingConstraint.constant = defaultSpacing
                self.bubbleTrailingConstraint.constant = defaultSpacing
                self.bubbleTrailingConstraint.priority = UILayoutPriority.defaultHigh
                self.dateLabelLeadingConstraint.constant = defaultDateSpacing
            }else{
                self.bubbleTrailingConstraint.constant = bubbleTrailingConstant
                self.bubbleTrailingConstraint.priority = UILayoutPriority.defaultHigh
            }
            
        }
    }
    override func configureWithComponents(_ components: Array<KREComponent>) {
        super.configureWithComponents(components)
        if isHideBotIcon{
            self.senderImageView.isHidden = true
        }
    }
}

class CalendarBubbleCell : MessageBubbleCell {
    override func bubbleType() -> ComponentType {
        return .calendarView
    }
    
    override var tailPosition: BubbleMaskTailPosition {
        didSet {
            self.bubbleTrailingConstraint.constant = bubbleTrailingConstant
            self.bubbleTrailingConstraint.priority = UILayoutPriority.defaultHigh
        }
    }
}

class QuickRepliesWelcomeCell : MessageBubbleCell {
    override func bubbleType() -> ComponentType {
        return .quick_replies_welcome
    }
    
    override var tailPosition: BubbleMaskTailPosition {
        didSet {
            // Full-width pin so RTL does not collapse the bubble to a trailing
            // sliver (intrinsic width is 0; only trailing was previously high).
            self.pinBubbleToBothEdges(spacing: defaultSpacing)
        }
    }
}

class NotificationBubbleCell : MessageBubbleCell {
    override func bubbleType() -> ComponentType {
        return .notification
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

class MultiSelectBubbleCell : MessageBubbleCell {
    override func bubbleType() -> ComponentType {
        return .multiSelect
    }
    override var tailPosition: BubbleMaskTailPosition {
        didSet {
            if isHideBotIcon{
                self.bubbleLeadingConstraint.constant = defaultSpacing
                self.bubbleTrailingConstraint.constant = defaultSpacing
                self.bubbleTrailingConstraint.priority = UILayoutPriority.defaultHigh
                
                self.dateLabelLeadingConstraint.constant = defaultDateSpacing
            }else{
                self.bubbleTrailingConstraint.constant = bubbleTrailingConstant
                self.bubbleTrailingConstraint.priority = UILayoutPriority.defaultHigh
            }
        }
    }
    
    override func configureWithComponents(_ components: Array<KREComponent>) {
        super.configureWithComponents(components)
        if isHideBotIcon{
            self.senderImageView.isHidden = true
        }
    }
}

class ListWidgetBubbleCell : MessageBubbleCell {
    override func bubbleType() -> ComponentType {
        return .list_widget
    }
    
    override var tailPosition: BubbleMaskTailPosition {
        didSet {
            if isHideBotIcon{
                self.bubbleLeadingConstraint.constant = defaultSpacing
                self.bubbleTrailingConstraint.constant = defaultSpacing
                self.bubbleTrailingConstraint.priority = UILayoutPriority.defaultHigh
                
                self.dateLabelLeadingConstraint.constant = defaultDateSpacing
            }else{
                self.bubbleTrailingConstraint.constant = bubbleTrailingConstant
                self.bubbleTrailingConstraint.priority = UILayoutPriority.defaultHigh
            }
        }
    }
    override func configureWithComponents(_ components: Array<KREComponent>) {
        super.configureWithComponents(components)
        if isHideBotIcon{
            self.senderImageView.isHidden = true
        }
    }
}
class FeedbackBubbleCell : MessageBubbleCell {
    override func bubbleType() -> ComponentType {
        return .feedbackTemplate
    }
    
    override var tailPosition: BubbleMaskTailPosition {
        didSet {
            if isHideBotIcon{
                self.bubbleLeadingConstraint.constant = defaultSpacing
                self.bubbleTrailingConstraint.constant = defaultSpacing
                self.bubbleTrailingConstraint.priority = UILayoutPriority.defaultHigh
                
                self.dateLabelLeadingConstraint.constant = defaultDateSpacing
            }else{
                self.bubbleTrailingConstraint.constant = bubbleTrailingConstant
                self.bubbleTrailingConstraint.priority = UILayoutPriority.defaultHigh
            }
        }
    }
    override func configureWithComponents(_ components: Array<KREComponent>) {
        super.configureWithComponents(components)
        if isHideBotIcon{
            self.senderImageView.isHidden = true
        }
    }
}

class InLineFormCell : MessageBubbleCell {
    override func bubbleType() -> ComponentType {
        return .inlineForm
    }
    
    override var tailPosition: BubbleMaskTailPosition {
        didSet {
            if isHideBotIcon{
                self.bubbleLeadingConstraint.constant = defaultSpacing
                self.bubbleTrailingConstraint.constant = defaultSpacing
                self.bubbleTrailingConstraint.priority = UILayoutPriority.defaultHigh
                
                self.dateLabelLeadingConstraint.constant = defaultDateSpacing
            }else{
                self.bubbleTrailingConstraint.constant = bubbleTrailingConstant
                self.bubbleTrailingConstraint.priority = UILayoutPriority.defaultHigh
            }
        }
    }
    override func configureWithComponents(_ components: Array<KREComponent>) {
        super.configureWithComponents(components)
        if isHideBotIcon{
            self.senderImageView.isHidden = true
        }
    }
}

class DropDownell : MessageBubbleCell {
    override func bubbleType() -> ComponentType {
        return .dropdown_template
    }
    
    override var tailPosition: BubbleMaskTailPosition {
        didSet {
            if isHideBotIcon{
                self.bubbleLeadingConstraint.constant = defaultSpacing
                self.bubbleTrailingConstraint.constant = defaultSpacing
                self.bubbleTrailingConstraint.priority = UILayoutPriority.defaultHigh
                
                self.dateLabelLeadingConstraint.constant = defaultDateSpacing
            }else{
                self.bubbleTrailingConstraint.constant = bubbleTrailingConstant
                self.bubbleTrailingConstraint.priority = UILayoutPriority.defaultHigh
            }
            
        }
    }
    override func configureWithComponents(_ components: Array<KREComponent>) {
        super.configureWithComponents(components)
        if isHideBotIcon{
            self.senderImageView.isHidden = true
        }
    }
}

class CustomTableCell : MessageBubbleCell {
    override func bubbleType() -> ComponentType {
        return .custom_table
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


class AdvancedListTemplateCell : MessageBubbleCell {
    override func bubbleType() -> ComponentType {
        return .advancedListTemplate
    }
    
    override var tailPosition: BubbleMaskTailPosition {
        didSet {
            if isHideBotIcon{
                self.bubbleLeadingConstraint.constant = defaultSpacing
                self.bubbleTrailingConstraint.constant = defaultSpacing
                self.bubbleTrailingConstraint.priority = UILayoutPriority.defaultHigh
                self.dateLabelLeadingConstraint.constant = defaultDateSpacing
            }else{
                self.bubbleTrailingConstraint.constant = bubbleTrailingConstant
                self.bubbleTrailingConstraint.priority = UILayoutPriority.defaultHigh
            }
        }
    }
    
    override func configureWithComponents(_ components: Array<KREComponent>) {
        super.configureWithComponents(components)
        if isHideBotIcon{
            self.senderImageView.isHidden = true
        }
    }
}
class CardTemplateBubbleCell : MessageBubbleCell {
    override func bubbleType() -> ComponentType {
        return .cardTemplate
    }
    override var tailPosition: BubbleMaskTailPosition {
        didSet {
            if isHideBotIcon{
                self.bubbleLeadingConstraint.constant = defaultSpacing
                self.bubbleTrailingConstraint.constant = defaultSpacing
                self.bubbleTrailingConstraint.priority = UILayoutPriority.defaultHigh
                
                self.dateLabelLeadingConstraint.constant = defaultDateSpacing
            }else{
                self.bubbleTrailingConstraint.constant = bubbleTrailingConstant
                self.bubbleTrailingConstraint.priority = UILayoutPriority.defaultHigh
            }
        }
    }
    override func configureWithComponents(_ components: Array<KREComponent>) {
        super.configureWithComponents(components)
        if isHideBotIcon{
            self.senderImageView.isHidden = true
        }
    }
}

class PDFDownloadCell : MessageBubbleCell {
    override func bubbleType() -> ComponentType {
        return .linkDownload
    }
    
    override var tailPosition: BubbleMaskTailPosition {
        didSet {
            self.bubbleTrailingConstraint.constant = 150
            self.bubbleTrailingConstraint.priority = UILayoutPriority.defaultHigh
        }
    }
}


class StackedCarosuelCell : MessageBubbleCell {
    override func bubbleType() -> ComponentType {
        return .stackedCarousel
    }
    
    override var tailPosition: BubbleMaskTailPosition {
        didSet {
//            self.bubbleLeadingConstraint.constant = bubbleLeadingConstant
//            self.bubbleTrailingConstraint.constant = bubbleTrailingConstant
//            self.bubbleTrailingConstraint.priority = UILayoutPriority.defaultHigh

            self.bubbleLeadingConstraint.constant = defaultSpacing
            self.bubbleTrailingConstraint.constant = defaultSpacing
            self.bubbleTrailingConstraint.priority = UILayoutPriority.defaultHigh
            
            self.dateLabelLeadingConstraint.constant = defaultDateSpacing
        }
        
    }
    override func configureWithComponents(_ components: Array<KREComponent>) {
        super.configureWithComponents(components)
        self.senderImageView.isHidden = true
    }
}
class AdvancedMultiCell : MessageBubbleCell {
    override func bubbleType() -> ComponentType {
        return .advanced_multi_select
    }
    
    override var tailPosition: BubbleMaskTailPosition {
        didSet {
            self.bubbleLeadingConstraint.constant = bubbleLeadingConstant
            self.bubbleTrailingConstraint.constant = bubbleTrailingConstant
            self.bubbleTrailingConstraint.priority = UILayoutPriority.defaultHigh
            

//                self.bubbleTrailingConstraint.constant = 10
//                self.bubbleLeadingConstraint.constant = 10
//                self.senderImageView.isHidden = true
//                self.bubbleTrailingConstraint.priority = UILayoutPriority.defaultHigh
        }
    }
}
class RadioOptionTemplateCell : MessageBubbleCell {
    override func bubbleType() -> ComponentType {
        return .radioOptionTemplate
    }
    
    override var tailPosition: BubbleMaskTailPosition {
        didSet {
            if isHideBotIcon{
                self.bubbleLeadingConstraint.constant = defaultSpacing
                self.bubbleTrailingConstraint.constant = defaultSpacing
                self.bubbleTrailingConstraint.priority = UILayoutPriority.defaultHigh
                
                self.dateLabelLeadingConstraint.constant = defaultDateSpacing
            }else{
                self.bubbleTrailingConstraint.constant = bubbleTrailingConstant
                self.bubbleTrailingConstraint.priority = UILayoutPriority.defaultHigh
            }
        }
    }
    
    override func configureWithComponents(_ components: Array<KREComponent>) {
        super.configureWithComponents(components)
        if isHideBotIcon{
            self.senderImageView.isHidden = true
        }
    }
}

class EmptyBubbleViewCell : MessageBubbleCell {
    override func bubbleType() -> ComponentType {
        return .noTemplate
    }
    
    override var tailPosition: BubbleMaskTailPosition {
        didSet {
            self.bubbleTrailingConstraint.constant = 45
            self.bubbleTrailingConstraint.priority = UILayoutPriority.defaultHigh
        }
    }
}
class QuickReplyTopBubbleCell: MessageBubbleCell{
    override func bubbleType() -> ComponentType {
        return .quick_replies_top
    }
    
    override var tailPosition: BubbleMaskTailPosition {
        didSet {
            self.bubbleTrailingConstraint.constant = 45
            self.bubbleTrailingConstraint.priority = UILayoutPriority.defaultHigh
        }
    }
}

class ArticleBubbleCell : MessageBubbleCell {
    override func bubbleType() -> ComponentType {
        return .articleTemplate
    }
    
    override var tailPosition: BubbleMaskTailPosition {
        didSet {
            self.bubbleLeadingConstraint.constant = defaultSpacing
            self.bubbleTrailingConstraint.constant = defaultSpacing
            self.bubbleTrailingConstraint.priority = UILayoutPriority.defaultHigh
            
            self.dateLabelLeadingConstraint.constant = defaultDateSpacing
        }
    }
    
    override func configureWithComponents(_ components: Array<KREComponent>) {
        super.configureWithComponents(components)
        self.senderImageView.isHidden = true
    }
}

class AnswerBubbleCell : MessageBubbleCell {
    override func bubbleType() -> ComponentType {
        return .answerTemplate
    }
    override var tailPosition: BubbleMaskTailPosition {
        didSet {
            self.pinBubbleToBothEdges(spacing: defaultSpacing)

            self.dateLabelLeadingConstraint.constant = defaultDateSpacing
        }
    }

    override func configureWithComponents(_ components: Array<KREComponent>) {
        super.configureWithComponents(components)
        self.senderImageView.isHidden = true
    }
}
class OTPorResetBubbleCell : MessageBubbleCell {
    override func bubbleType() -> ComponentType {
        return .OtpOrResetTemplate
    }
    
    override var tailPosition: BubbleMaskTailPosition {
        didSet {
            self.bubbleTrailingConstraint.constant = bubbleTrailingConstant
            self.bubbleTrailingConstraint.priority = UILayoutPriority.defaultHigh
        }
    }
}
class DigitalFormBubbleCel : MessageBubbleCell {
    override func bubbleType() -> ComponentType {
        return .digital_form
    }
    
    override var tailPosition: BubbleMaskTailPosition {
        didSet {
            self.bubbleLeadingConstraint.constant = defaultSpacing
            self.bubbleTrailingConstraint.constant = defaultSpacing
            self.dateLabelLeadingConstraint.constant = defaultDateSpacing
            self.bubbleTrailingConstraint.priority = UILayoutPriority.defaultHigh
        }
    }
    
    override func configureWithComponents(_ components: Array<KREComponent>) {
        super.configureWithComponents(components)
        self.senderImageView.isHidden = true
    }
}
