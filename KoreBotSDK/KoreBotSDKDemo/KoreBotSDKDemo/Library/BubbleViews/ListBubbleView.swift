//
//  ListBubbleView.swift
//  KoreBotSDKDemo
//
//  Created by Phanindra on 12/23/16.
//  Copyright © 2016 Kore. All rights reserved.
//

import UIKit
import KoreTextParser
import KoreWidgets



class ListBubbleView: BubbleView {

    
    let kLabelPadding:CGFloat =  16.0
    let kVerticalMargin: CGFloat = 10.0
    let kMaxTextWidth: CGFloat = (BubbleViewMaxWidth)
    let kMaxRowHeight: CGFloat = 73
    let markdownParser: MarkdownParser = MarkdownParser()
    let minimumRowsToShow:Int = 3

    var showMore:Bool = false;
    var minElementsToShow:Int = 3
    var optionsView: KREOptionsView!
    var textLabel: KREAttributedLabel!
    var options: Array<KREOption> = Array<KREOption>()
    
    public var optionsAction: ((_ text: String?) -> Void)!
    public var linkAction: ((_ text: String?) -> Void)!

    
    
    
    func kTextColor() -> UIColor {
        return (self.tailPosition == BubbleMaskTailPosition.left ? Common.UIColorRGB(0x484848) : Common.UIColorRGB(0xFFFFFF))
    }
    
    func kLeftMargin() -> CGFloat {
        return (self.tailPosition == BubbleMaskTailPosition.left ? 20.0 : 13.0)
    }
    
    func kRightMargin() -> CGFloat {
        return (self.tailPosition == BubbleMaskTailPosition.left ? 10.0 : 17.0)
    }
    
    
    override var tailPosition: BubbleMaskTailPosition! {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    override init() {
        super.init()
        self.initialize()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func initialize() {
        super.initialize()
        
        self.textLabel = KREAttributedLabel(frame: CGRect.zero)
        self.textLabel.textColor = Common.UIColorRGB(0x444444)
        self.textLabel.mentionTextColor = Common.UIColorRGB(0x8ac85a)
        self.textLabel.hashtagTextColor = Common.UIColorRGB(0x8ac85a)
        self.textLabel.linkTextColor = Common.UIColorRGB(0x0076FF)
        self.textLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 16.0)
        self.textLabel.numberOfLines = 0
        self.textLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        self.textLabel.isUserInteractionEnabled = true
        self.textLabel.contentMode = UIViewContentMode.topLeft
        
        self.addSubview(self.textLabel)
        
        self.optionsView = KREOptionsView()
        self.optionsView.optionsViewType = 2
        self.optionsView.translatesAutoresizingMaskIntoConstraints = false
        self.optionsView.isUserInteractionEnabled = true
        self.optionsView.contentMode = UIViewContentMode.topLeft
        self.addSubview(self.optionsView)
        let views: [String: UIView] = ["optionsView": optionsView]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[optionsView]|", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[optionsView]|", options: [], metrics: nil, views: views))
        
        // property blocks
        self.optionsView.optionsButtonAction = {[weak self] (text) in
            if(text == "Show more"){
                self?.showMore = true
                self?.optionsAction(text)
            }else if((self?.optionsAction) != nil){
                self?.optionsAction(text)
            }
        }
        self.optionsView.detailLinkAction = {[weak self] (text) in
            if(self?.linkAction != nil){
                self?.linkAction(text)
            }
        }
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let textSize: CGSize = self.textSizeThatFits()
        self.textLabel.frame = CGRect(x: self.kLeftMargin(), y: self.kVerticalMargin - 4, width: textSize.width, height: textSize.height + kLabelPadding + self.kVerticalMargin - 5)
        self.textLabel.edgeInset = UIEdgeInsetsMake(5, 15, 5, 0)
    }
    
    override var components: NSArray! {
        didSet {
            if (components.count > 0) {
                let component: KREComponent = components.firstObject as! KREComponent
                if (component.componentDesc != nil) {
                    let jsonString = component.componentDesc
                    options.removeAll()
                    let jsonObject: NSDictionary = Utilities.jsonObjectFromString(jsonString: jsonString!) as! NSDictionary
                    let elements: Array<Dictionary<String, Any>> = jsonObject["elements"] as! Array<Dictionary<String, Any>>

                    var index: Int = 0
                    for dictionary in elements  {
                        let option: KREOption = KREOption.init()
                        
                        option.setOptionData(name: dictionary["title"] as! String, subTitle: dictionary["subtitle"] as! String, imgURL: dictionary["image_url"] as! String, index: index)
                        
                        let buttons: Array<Dictionary<String, Any>> = dictionary["buttons"] as! Array<Dictionary<String, Any>>
                        if(buttons.count > 0){
                            let buttonElement: NSDictionary = buttons.first! as NSDictionary
                            option.setButtonDesc(info: [
                                "title":buttonElement["title"] as! String,
                                "url":buttonElement["url"] as! String
                                ])
                        }
                        options.append(option)

                        index += 1
                        
                    }
                    
                    let message: KREMessage = component.message!

                    if(options.count > self.minimumRowsToShow && message.showMore == false){
                        self.optionsView.showMore = true

                        self.optionsView.options.removeAll()
                        for index in 0...(self.minimumRowsToShow-1) {
                            self.optionsView.options.append(options[index]);
                        }
                    }else{
                        self.optionsView.options.removeAll()
                        self.optionsView.showMore = false
                        self.optionsView.options = options
                    }
                    
                    if((jsonObject["text"]) != nil){
                        var headerText: String = jsonObject["text"] as! String
                        headerText = KREUtilities.formatHTMLEscapedString(headerText);
                        self.textLabel.setHTMLString(headerText, withWidth: self.textSizeThatFitsWithString(headerText as NSString).width)
                        optionsView.optionsTableView.tableHeaderView = self.textLabel
                    }else{
                        optionsView.optionsTableView.tableHeaderView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: optionsView.optionsTableView.bounds.size.width, height: 0.01))

                    }
                }
            }
        }
    }
    
//    MARK: View height calculation
    override var intrinsicContentSize : CGSize {
        
        // header text height
        let textSize: CGSize  = self.textSizeThatFits()
        self.textLabel.frame = CGRect(x: 0.0, y: 0.0, width: kMaxTextWidth, height: textSize.height+kLabelPadding)
        let textLabelHieght = ((self.textLabel.text?.characters.count)! > 0) ? (textSize.height + kLabelPadding) : 0

        // showmore button height
        let showMoreHeight:CGFloat = (self.optionsView.showMore) ? 44.0 : 0.0
        
        // internal cell content height
        let detailsArr = (((self.optionsView.options as NSArray).value(forKeyPath: "optionWithButtonDesc.title")) as! NSArray)
        let moreDetailsCount = (detailsArr.filtered(using: NSPredicate.init(format: "self.length > 0"))).count
        let moreDetailsHeight:CGFloat = CGFloat(moreDetailsCount) * 33;
        
        // total rows height
        let maxRows = self.optionsView.options.count//min(options.count, 4)
        
        let viewSize:CGSize = CGSize(width: kMaxTextWidth + 2.0, height: CGFloat(maxRows)*kMaxRowHeight + 0.0 + showMoreHeight + moreDetailsHeight + textLabelHieght )
       
        return viewSize;
    }
    
    func textSizeThatFits() -> CGSize {
        let limitingSize: CGSize  = CGSize(width: kMaxTextWidth , height: CGFloat.greatestFiniteMagnitude)
        let rect: CGRect = self.textLabel.text!.boundingRect(with: limitingSize,
                                                             options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                                             attributes: [NSFontAttributeName: self.textLabel.font],
                                                             context: nil)
        return rect.size;
    }
    
    func textSizeThatFitsWithString(_ string:NSString) -> CGSize {
        let limitingSize: CGSize  = CGSize(width: kMaxTextWidth , height: CGFloat.greatestFiniteMagnitude)
        let rect: CGRect = string.boundingRect(with: limitingSize,
                                               options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                               attributes: [NSFontAttributeName: self.textLabel.font],
                                               context: nil)
        return rect.size;
    }

    
}
