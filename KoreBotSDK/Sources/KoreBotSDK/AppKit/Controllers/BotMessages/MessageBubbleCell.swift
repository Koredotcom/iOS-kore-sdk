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
    
    let defaultSpacing = 20.0
    let defaultDateSpacing = 23.0
    lazy var dateLabel: UILabel = {
        let dateLabel = UILabel(frame: .zero)
        dateLabel.numberOfLines = 0
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.font = UIFont(name: regularCustomFont, size: 10.0)
        dateLabel.textColor = .lightGray
        dateLabel.isHidden = true
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
        //dateLabel
        self.contentView.addSubview(dateLabel)
        
        // Setting Constraints
        let views: [String: UIView] = ["senderImageView": senderImageView, "bubbleContainerView": bubbleContainerView, "userImageView": userImageView, "dateLabel":dateLabel]
        
//        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[senderImageView(30)]-22-|", options:[], metrics:nil, views:views))
//        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[userImageView(30)]-22-|", options:[], metrics:nil, views:views))
        
        var senderImageViewWidth = 00
        bubbleLeadingConstant = 20.0
        var userImageViewWidth = 00
        bubbleTrailingConstant = 20.0
        if let icons = brandingBodyDic.icon{
            if let userIcon = icons.user_icon, userIcon == true{
                userImageViewWidth = 30
                bubbleTrailingConstant = 45.0
            }
            if let botIcon = icons.bot_icon, botIcon == true{
                senderImageViewWidth = 30
                bubbleLeadingConstant = 45.0
            }
           
        }
        
        //self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-\(bubbleLeadingConstant + 3.0)-[dateLabel]-\(bubbleTrailingConstant + 3.0)-|", options:[], metrics:nil, views:views))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-8-[senderImageView(\(senderImageViewWidth))]", options:[], metrics:nil, views:views))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[userImageView(\(userImageViewWidth))]-8-|", options:[], metrics:nil, views:views))
        
        var senderOrUserimageViewBottomVal = 4.0
        
        if let timestamp = brandingBodyDic.time_stamp{
            if let timeStampShow = timestamp.show, timeStampShow == true{
                dateLabel.isHidden = false
                dateLblTextColor = UIColor(hexString: timestamp.color ?? "#4B4EDE")
                dateLabel.textColor = dateLblTextColor
                
                if let position = timestamp.position, position == "top"{
                    self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[dateLabel(21)]-0-[bubbleContainerView]", options:[], metrics:nil, views:views))
                    
                }else{
                    self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[bubbleContainerView]-0-[dateLabel(21)]|", options:[], metrics:nil, views:views))
                    senderOrUserimageViewBottomVal = 22.0
                }
                
            }else{
                self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[dateLabel(0)]-0-[bubbleContainerView]", options:[], metrics:nil, views:views))
            }
        }else{
            self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[dateLabel(0)]-0-[bubbleContainerView]", options:[], metrics:nil, views:views))
        }
        
//        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[senderImageView(30)]-\(senderOrUserimageViewBottomVal)-|", options:[], metrics:nil, views:views))
//        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[userImageView(30)]-\(senderOrUserimageViewBottomVal)-|", options:[], metrics:nil, views:views))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-\(30)-[senderImageView(30)]", options:[], metrics:nil, views:views))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-\(30)-[userImageView(30)]", options:[], metrics:nil, views:views))

        self.bubbleBottomConstraint = NSLayoutConstraint(item:self.contentView, attribute:.bottom, relatedBy:.equal, toItem:self.bubbleContainerView, attribute:.bottom, multiplier:1.0, constant:4.0)
        self.bubbleBottomConstraint.priority = UILayoutPriority.defaultHigh
        self.bubbleLeadingConstraint = NSLayoutConstraint(item:self.bubbleContainerView as Any, attribute:.leading, relatedBy:.equal, toItem:self.contentView, attribute:.leading, multiplier:1.0, constant:bubbleLeadingConstant)
        self.bubbleLeadingConstraint.priority = UILayoutPriority.defaultHigh
        
        self.bubbleTrailingConstraint = NSLayoutConstraint(item:self.contentView, attribute:.trailing, relatedBy:.equal, toItem:self.bubbleContainerView, attribute:.trailing, multiplier:1.0, constant:16.0)
        self.bubbleTrailingConstraint.priority = UILayoutPriority.defaultLow
        
        self.dateLabelLeadingConstraint = NSLayoutConstraint(item:self.dateLabel as Any, attribute:.leading, relatedBy:.equal, toItem:self.contentView, attribute:.leading, multiplier:1.0, constant:bubbleLeadingConstant + 3.0) //change here
        self.dateLabelLeadingConstraint.priority = UILayoutPriority.defaultHigh
        
        
        self.dateLabelTrailingConstraint = NSLayoutConstraint(item:self.contentView as Any, attribute:.trailing, relatedBy:.equal, toItem:self.dateLabel, attribute:.trailing, multiplier:1.0, constant:(bubbleTrailingConstant + 3.0)) //change here
        self.dateLabelTrailingConstraint.priority = UILayoutPriority.defaultHigh
        
        self.contentView.addConstraints([self.bubbleTrailingConstraint, self.bubbleLeadingConstraint, self.bubbleBottomConstraint, self.dateLabelLeadingConstraint, self.dateLabelTrailingConstraint])
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
            
            var time = getTimeformater(sentOn: sentOn)
            if self.tailPosition == .left{
                let finalStr = "\(headerTxt) \(time)"
                let attrStri = NSMutableAttributedString.init(string: finalStr)
                let nsRange = NSString(string: finalStr)
                        .range(of: "\(headerTxt)", options: String.CompareOptions.caseInsensitive)
                attrStri.addAttributes([
                    NSAttributedString.Key.foregroundColor : dateLblTextColor,
                    NSAttributedString.Key.font: UIFont.init(name: boldCustomFont, size: 10.0) as Any
                ], range: nsRange)
                dateLabel.attributedText = attrStri
            }else{
                let finalStr = "\(time) You"
                let attrStri = NSMutableAttributedString.init(string: finalStr)
                let nsRange = NSString(string: finalStr)
                        .range(of: "You", options: String.CompareOptions.caseInsensitive)
                attrStri.addAttributes([
                    NSAttributedString.Key.foregroundColor : dateLblTextColor,
                    NSAttributedString.Key.font: UIFont.init(name: boldCustomFont, size: 10.0) as Any
                ], range: nsRange)
                dateLabel.attributedText = attrStri
            }
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
        
        if (message.iconUrl != nil) {
            if let fileUrl = URL(string: message.iconUrl!) {
                self.senderImageView.af.setImage(withURL: fileUrl, placeholderImage: placeHolderIcon)
            }
        }
        NotificationCenter.default.addObserver(self, selector: #selector(MessageBubbleCell.updateImage(notification:)), name: NSNotification.Name(rawValue: updateUserImageNotification), object: nil)
    }
    
    func getTimeformater(sentOn: Date) -> String{
        var time = ""
        let today = Date()
        let yesterday = Date().yesterday
        let dateFormt = DateFormatter()
        dateFormt.dateFormat = "MMM dd yyyy"
        
        var todayOrYesterDay = Date()
        var is12or24Format = false
        if dateFormt.string(from: sentOn) == dateFormt.string(from: today){
            todayOrYesterDay = today
            is12or24Format = true
        }else if dateFormt.string(from: sentOn) == dateFormt.string(from: yesterday){
            todayOrYesterDay = yesterday
            is12or24Format = true
        }else{
            is12or24Format = false
            let dateFormatter = DateFormatter()
            
            var formatterStr = "\(brandingBodyDic.time_stamp?.date_format ?? "")"
            if "dd/mm/yyyy" == formatterStr.lowercased(){
                formatterStr = "dd/MM/yyyy"
            }else if "mm/dd/yyyy" == formatterStr.lowercased(){
                formatterStr = "MM/dd/yyyy"
            }else if "mmm/dd/yyyy" == formatterStr.lowercased(){
                formatterStr = "MMM/dd/yyyy"
            }
            
            var formte = ""
            formte = formatterStr.replacingOccurrences(of: "D", with: "d")
            formte = formte.replacingOccurrences(of: "Y", with: "y")
            dateFormatter.dateFormat = formte
            let timeFormatter = DateFormatter()
            if brandingBodyDic.time_stamp?.timeformat == "24"{
                timeFormatter.dateFormat = "HH:mm"
            }else{
                timeFormatter.dateFormat = "h:mm a"
            }
            let date = dateFormatter.string(from: sentOn)
            let timee = timeFormatter.string(from: sentOn)
            time = "\(timee), \(date)"
        }
        
        if is12or24Format{
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.doesRelativeDateFormatting = true
            
            if let time_format = brandingBodyDic.time_stamp?.timeformat, time_format == "24"{
                let timeFormatter24 = DateFormatter()
                timeFormatter24.dateFormat = "HH:mm"
                time = "\(timeFormatter24.string(from: sentOn)), \(dateFormatter.string(from: todayOrYesterDay))"
                
            }else if let time_format = brandingBodyDic.time_stamp?.timeformat, time_format == "12"{
                let timeFormatter12 = DateFormatter()
                timeFormatter12.dateFormat = "h:mm a"
                
                time = "\(timeFormatter12.string(from: sentOn)), \(dateFormatter.string(from: todayOrYesterDay))"
                
            }
        }
        
        return time
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
    }
}

class TextBubbleCell : MessageBubbleCell {
    override func bubbleType() -> ComponentType {
        return .text
    }
    override var tailPosition: BubbleMaskTailPosition {
        didSet {
            self.bubbleTrailingConstraint.constant = bubbleTrailingConstant
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
            
        }
    }
}

class AudioBubbleCell : MessageBubbleCell {
    override func bubbleType() -> ComponentType {
        return .audio
    }
    
    override var tailPosition: BubbleMaskTailPosition {
        didSet {
            
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
            self.bubbleTrailingConstraint.constant = bubbleTrailingConstant
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
            self.dateLabelLeadingConstraint.constant = defaultDateSpacing
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
class TableListBubbleCell : MessageBubbleCell {
    override func bubbleType() -> ComponentType {
        return .tableList
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
            self.bubbleTrailingConstraint.constant = bubbleTrailingConstant
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
            self.bubbleTrailingConstraint.constant = bubbleTrailingConstant
            self.bubbleTrailingConstraint.priority = UILayoutPriority.defaultHigh
            
//            self.bubbleTrailingConstraint.constant = 10
//            self.bubbleLeadingConstraint.constant = 10
//            self.senderImageView.isHidden = true
//            self.bubbleTrailingConstraint.priority = UILayoutPriority.defaultHigh
        }
    }
}

class ListWidgetBubbleCell : MessageBubbleCell {
    override func bubbleType() -> ComponentType {
        return .list_widget
    }
    
    override var tailPosition: BubbleMaskTailPosition {
        didSet {
            self.bubbleTrailingConstraint.constant = bubbleTrailingConstant
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
            self.bubbleTrailingConstraint.constant = bubbleTrailingConstant
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
            self.bubbleTrailingConstraint.constant = bubbleTrailingConstant
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
            self.bubbleTrailingConstraint.constant = bubbleTrailingConstant
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
class CardTemplateBubbleCell : MessageBubbleCell {
    override func bubbleType() -> ComponentType {
        return .cardTemplate
    }
    
    override var tailPosition: BubbleMaskTailPosition {
        didSet {
            self.bubbleTrailingConstraint.constant = bubbleTrailingConstant
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


class StackedCarosuelCell : MessageBubbleCell {
    override func bubbleType() -> ComponentType {
        return .stackedCarousel
    }
    
    override var tailPosition: BubbleMaskTailPosition {
        didSet {
            self.bubbleLeadingConstraint.constant = bubbleLeadingConstant
            self.bubbleTrailingConstraint.constant = bubbleTrailingConstant
            self.bubbleTrailingConstraint.priority = UILayoutPriority.defaultHigh
            
        }
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
            self.bubbleLeadingConstraint.constant = bubbleLeadingConstant
            self.bubbleTrailingConstraint.constant = bubbleTrailingConstant
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
