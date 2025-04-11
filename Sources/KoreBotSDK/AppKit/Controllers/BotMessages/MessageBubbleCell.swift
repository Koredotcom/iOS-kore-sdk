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
    var userImageViewTrialing = 45.0
    lazy var dateLabel: UILabel = {
        let dateLabel = UILabel(frame: .zero)
        dateLabel.numberOfLines = 0
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.font = UIFont(name: regularCustomFont, size: 10.0)
        dateLabel.textColor = .lightGray
        dateLabel.isHidden = false
        return dateLabel
    }()
    
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
            if (tailPosition == .left) {
                self.bubbleLeadingConstraint.priority = UILayoutPriority.defaultHigh
                self.bubbleTrailingConstraint.priority = UILayoutPriority.defaultLow
                self.senderImageView.isHidden = false
                self.userImageView.isHidden = true

            } else {
                self.bubbleLeadingConstraint.priority = UILayoutPriority.defaultLow
                self.bubbleTrailingConstraint.priority = UILayoutPriority.defaultHigh
                self.senderImageView.isHidden = true
                self.userImageView.isHidden = false
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
        self.senderImageView.layer.cornerRadius = 0 //15
        self.senderImageView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(self.senderImageView)
        
        self.userImageView = UIImageView()
        self.userImageView.contentMode = .scaleAspectFit
        self.userImageView.clipsToBounds = true
        self.userImageView.layer.cornerRadius = 0
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
        
        var userImageViewWidth = 28
        if isShowUserIcon{
            userImageViewTrialing = 45
            userImageViewWidth = 28
        }else{
            userImageViewTrialing = 15
            userImageViewWidth = 0
        }
        
        // Setting Constraints
        let views: [String: UIView] = ["senderImageView": senderImageView, "bubbleContainerView": bubbleContainerView, "userImageView": userImageView, "dateLabel":dateLabel]
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-45-[dateLabel]-\(userImageViewTrialing + 2)-|", options:[], metrics:nil, views:views))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-8-[senderImageView(28)]", options:[], metrics:nil, views:views))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[userImageView(\(userImageViewWidth))]-8-|", options:[], metrics:nil, views:views))
        if isShowBotIconTop{
            self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-35-[userImageView(28)]", options:[], metrics:nil, views:views))
            self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-35-[senderImageView(28)]", options:[], metrics:nil, views:views))
        }else{
            self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[userImageView(28)]-4-|", options:[], metrics:nil, views:views))
            self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[senderImageView(28)]-4-|", options:[], metrics:nil, views:views))
        }
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[dateLabel(21)]-0-[bubbleContainerView]", options:[], metrics:nil, views:views))

        self.bubbleBottomConstraint = NSLayoutConstraint(item:self.contentView, attribute:.bottom, relatedBy:.equal, toItem:self.bubbleContainerView, attribute:.bottom, multiplier:1.0, constant:4.0)
        self.bubbleBottomConstraint.priority = UILayoutPriority.defaultHigh
        self.bubbleLeadingConstraint = NSLayoutConstraint(item:self.bubbleContainerView as Any, attribute:.leading, relatedBy:.equal, toItem:self.contentView, attribute:.leading, multiplier:1.0, constant:45.0)
        self.bubbleLeadingConstraint.priority = UILayoutPriority.defaultHigh
        self.bubbleTrailingConstraint = NSLayoutConstraint(item:self.contentView, attribute:.trailing, relatedBy:.equal, toItem:self.bubbleContainerView, attribute:.trailing, multiplier:1.0, constant:16.0)
        self.bubbleTrailingConstraint.priority = UILayoutPriority.defaultLow
        
        self.contentView.addConstraints([self.bubbleTrailingConstraint, self.bubbleLeadingConstraint, self.bubbleBottomConstraint])
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
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "EE, MMM dd yyyy 'at' hh:mm:ss a"
                dateLabel.text = dateFormatter.string(from: sentOn)
        }
        if self.tailPosition == .left{
            dateLabel.textAlignment = .left
        }else{
            dateLabel.textAlignment = .right
        }
        
        let placeHolderIcon = UIImage(named: "kore", in: bundle, compatibleWith: nil)
        self.senderImageView.image = placeHolderIcon
        if(self.userImageView.image == nil){
            
            self.userImageView.image = UIImage(named: "faceIcon", in: bundle, compatibleWith: nil)
        }
        
        if let iconurl = message.iconUrl {
            if let fileUrl = URL(string: iconurl) {
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
    }
}

class TextBubbleCell : MessageBubbleCell {
    override func bubbleType() -> ComponentType {
        return .text
    }
    override var tailPosition: BubbleMaskTailPosition {
        didSet {
            self.bubbleTrailingConstraint.constant = userImageViewTrialing
            if (tailPosition == .left) {
                self.bubbleLeadingConstraint.priority = UILayoutPriority.defaultHigh
                self.bubbleTrailingConstraint.priority = UILayoutPriority.defaultLow
            } else {
                self.bubbleLeadingConstraint.priority = UILayoutPriority.defaultLow
                self.bubbleTrailingConstraint.priority = UILayoutPriority.defaultHigh
                
            }
        }
    }
}

class QuickReplyBubbleCell : MessageBubbleCell {
    override func bubbleType() -> ComponentType {
        return .quickReply
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

class AudioBubbleCell : MessageBubbleCell {
    override func bubbleType() -> ComponentType {
        return .audio
    }
}



class OptionsBubbleCell : MessageBubbleCell {
    override func bubbleType() -> ComponentType {
        return .options
    }
    
    override var tailPosition: BubbleMaskTailPosition {
        didSet {
            self.bubbleTrailingConstraint.constant = 45
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
            self.bubbleTrailingConstraint.constant = 45
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
class MiniTableHorizontalBubbleCell : MessageBubbleCell {
    override func bubbleType() -> ComponentType {
        return .minitable_Horizontal
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
            self.bubbleLeadingConstraint.constant = 45
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

class NewListBubbleCell : MessageBubbleCell {
    override func bubbleType() -> ComponentType {
        return .newList
    }
    
    override var tailPosition: BubbleMaskTailPosition {
        didSet {
            self.bubbleTrailingConstraint.constant = 45
            self.bubbleTrailingConstraint.priority = UILayoutPriority.defaultHigh
        }
    }
}
class TableListBubbleCell : MessageBubbleCell {
    override func bubbleType() -> ComponentType {
        return .tableList
    }
    
    override var tailPosition: BubbleMaskTailPosition {
        didSet {
            self.bubbleTrailingConstraint.constant = 45
            self.bubbleTrailingConstraint.priority = UILayoutPriority.defaultHigh
        }
    }
}

class CalendarBubbleCell : MessageBubbleCell {
    override func bubbleType() -> ComponentType {
        return .calendarView
    }
    
    override var tailPosition: BubbleMaskTailPosition {
        didSet {
            self.bubbleTrailingConstraint.constant = 45
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
            self.bubbleTrailingConstraint.constant = 45
            self.bubbleTrailingConstraint.priority = UILayoutPriority.defaultHigh
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
            self.bubbleTrailingConstraint.constant = 45
            self.bubbleTrailingConstraint.priority = UILayoutPriority.defaultHigh
        }
    }
}

class ListWidgetBubbleCell : MessageBubbleCell {
    override func bubbleType() -> ComponentType {
        return .list_widget
    }
    
    override var tailPosition: BubbleMaskTailPosition {
        didSet {
            self.bubbleTrailingConstraint.constant = 45
            self.bubbleTrailingConstraint.priority = UILayoutPriority.defaultHigh
        }
    }
}
class FeedbackBubbleCell : MessageBubbleCell {
    override func bubbleType() -> ComponentType {
        return .feedbackTemplate
    }
    
    override var tailPosition: BubbleMaskTailPosition {
        didSet {
            self.bubbleTrailingConstraint.constant = 45
            self.bubbleTrailingConstraint.priority = UILayoutPriority.defaultHigh
        }
    }
}

class InLineFormCell : MessageBubbleCell {
    override func bubbleType() -> ComponentType {
        return .inlineForm
    }
    
    override var tailPosition: BubbleMaskTailPosition {
        didSet {
            self.bubbleTrailingConstraint.constant = 45
            self.bubbleTrailingConstraint.priority = UILayoutPriority.defaultHigh
        }
    }
}

class DropDownell : MessageBubbleCell {
    override func bubbleType() -> ComponentType {
        return .dropdown_template
    }
    
    override var tailPosition: BubbleMaskTailPosition {
        didSet {
            self.bubbleTrailingConstraint.constant = 45
            self.bubbleTrailingConstraint.priority = UILayoutPriority.defaultHigh
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
            self.bubbleTrailingConstraint.constant = 20
            self.bubbleTrailingConstraint.priority = UILayoutPriority.defaultHigh
        }
    }
}
class CardTemplateBubbleCell : MessageBubbleCell {
    override func bubbleType() -> ComponentType {
        return .cardTemplate
    }
    
    override var tailPosition: BubbleMaskTailPosition {
        didSet {
            self.bubbleTrailingConstraint.constant = 20
            self.bubbleTrailingConstraint.priority = UILayoutPriority.defaultHigh
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
