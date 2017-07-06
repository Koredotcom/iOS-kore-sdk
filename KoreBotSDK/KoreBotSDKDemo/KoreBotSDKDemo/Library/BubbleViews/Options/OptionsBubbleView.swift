//
//  OptionsBubbleView.swift
//  KoreBotSDKDemo
//
//  Created by developer@kore.com on 09/05/16.
//  Copyright © 2016 Kore Inc. All rights reserved.
//

import UIKit
import KoreTextParser
import KoreWidgets

class OptionsBubbleView: BubbleView {
    
    func kTextColor() -> UIColor {
        return (self.tailPosition == BubbleMaskTailPosition.left ? Common.UIColorRGB(0x484848) : Common.UIColorRGB(0xFFFFFF))
    }
    
    func kLeftMargin() -> CGFloat {
        return (self.tailPosition == BubbleMaskTailPosition.left ? 20.0 : 13.0)
    }
    
    func kRightMargin() -> CGFloat {
        return (self.tailPosition == BubbleMaskTailPosition.left ? 10.0 : 17.0)
    }
    
    let kVerticalMargin: CGFloat = 10.0
    let kMaxTextWidth: CGFloat = (BubbleViewMaxWidth)
    let kMaxRowHeight: CGFloat = 44
    let markdownParser: MarkdownParser = MarkdownParser()

    var optionsView: KREOptionsView!
    var textLabel: KREAttributedLabel!

    var options: Array<KREOption> = Array<KREOption>()
    
    public var optionsAction: ((_ text: String?) -> Void)!

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
        self.optionsView.optionsViewType = 1
        self.optionsView.translatesAutoresizingMaskIntoConstraints = false
        self.optionsView.isUserInteractionEnabled = true
        self.optionsView.contentMode = UIViewContentMode.topLeft
        self.addSubview(self.optionsView)
        let views: [String: UIView] = ["optionsView": optionsView]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[optionsView]|", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[optionsView]|", options: [], metrics: nil, views: views))
        
        self.optionsView.optionsButtonAction = {[weak self] (text) in
            if((self?.optionsAction) != nil){
                self?.optionsAction(text)
            }
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        let textSize: CGSize = self.textSizeThatFits()
        self.textLabel.frame = CGRect(x: self.kLeftMargin(), y: self.kVerticalMargin - 4, width: textSize.width, height: textSize.height + 16 + self.kVerticalMargin-5)
        self.textLabel.edgeInset = UIEdgeInsetsMake(5, 15, 5, 5)

    }
    
    override var components: NSArray! {
        didSet {
            if (components.count > 0) {
                let component: KREComponent = components.firstObject as! KREComponent
                if (component.componentDesc != nil) {
                    let jsonString = component.componentDesc
                    options.removeAll()
                    let jsonObject: NSDictionary = Utilities.jsonObjectFromString(jsonString: jsonString!) as! NSDictionary
                    let buttons: Array<Dictionary<String, Any>> = jsonObject["buttons"] as! Array<Dictionary<String, Any>>
                    let index: Int = 0
                    for dictionary in buttons  {
                        let title: String = dictionary["title"] != nil ? dictionary["title"] as! String : ""
                        let type: String = dictionary["type"] != nil ? dictionary["type"] as! String : ""
                        
                        let option: KREOption = KREOption(name: title, desc: title, type: type, index: index)
                        option.setButtonInfo(info: dictionary as! Dictionary<String, String>)
                        options.append(option)
                    }
                    self.optionsView.options = options
                    
                    var headerText: String = jsonObject["text"] != nil ? jsonObject["text"] as! String : ""
                    headerText = KREUtilities.formatHTMLEscapedString(headerText);
                    self.textLabel.setHTMLString(headerText, withWidth: self.textSizeThatFitsWithString(headerText as NSString).width)
//                    self.textLabel.attributedText = markdownParser.attributedString(from: headerText)
                    optionsView.optionsTableView.tableHeaderView = self.textLabel
                }
            }
        }
    }

    override var intrinsicContentSize : CGSize {
        let textSize: CGSize  = self.textSizeThatFits()
        self.textLabel.frame = CGRect(x: 0.0, y: 0.0, width: kMaxTextWidth, height: textSize.height+16)
        let maxRows = min(options.count, 4)
        return CGSize(width: kMaxTextWidth + 2.0, height: textSize.height + 16 + CGFloat(maxRows)*kMaxRowHeight + 2.0)
        
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
