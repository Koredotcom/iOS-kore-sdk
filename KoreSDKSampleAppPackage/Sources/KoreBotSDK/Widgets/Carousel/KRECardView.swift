 //
//  KRECardView.swift
//  Widgets
//
//  Created by developer@kore.com on 24/05/17.
//  Copyright © 2017 Kore Inc. All rights reserved.
//
//

import UIKit

open class KRECardInfo: NSObject {
    
    static public let buttonLimit: Int = 3
    static public let titleCharLimit: Int = 80
    static public let subtitleCharLimit: Int = 100
    
    // MARK:- properties
    public var title: String?
    public var subTitle: String?
    public var imageURL:String?
    public var resourceId: String?
    public var options: Array<KREOption>?
    open var defaultAction: KREAction?
    public var payload: [String: Any]?
    public var isImagePresent: Bool = true
    
    // MARK:- init
    public override init() {
        super.init()
    }
    
    public init(title: String, subTitle: String, imageURL: String) {
        super.init()
        self.title = title
        self.subTitle = subTitle
        self.imageURL = imageURL
        if imageURL == "" || imageURL == nil {
            isImagePresent = false
        }
    }
    
    public func setOptionData(title: String, subTitle: String, imageURL: String) {
        self.title = title
        self.subTitle = subTitle
        self.imageURL = imageURL
    }
    
    public func setDefaultAction(action: KREAction) {
        defaultAction = action
    }
    
    public func setOptions(options: Array<KREOption>) {
        self.options = options
    }
    
    func truncateString(_ string: String, count: Int) -> String{
        var tmpString = string
        if tmpString.count > count {
            tmpString = tmpString.substring(to: tmpString.index(tmpString.startIndex, offsetBy: count-3)) + "..."
        }
        return tmpString
    }
    
    public func prepareForReuse() {
        
    }
}

public class KRECardView: UIView, UIGestureRecognizerDelegate {
    let bundle = Bundle(for: KRECardView.self)
    static let kMaxRowHeight: CGFloat = 44
    static let buttonLimit: Int = 3
    var isFirst: Bool = false
    var isLast: Bool = false
    var urlString: String!
    open var kreInfo: KRECardInfo?
    var actionContainerHeightConstraint: NSLayoutConstraint!
    var optionsView: KREOptionsView = KREOptionsView()
    var textLabel: UILabel = UILabel(frame: CGRect.zero)
    var dateLabel: UILabel = UILabel(frame: CGRect.zero)
    var kaTitleLabel: UILabel = UILabel(frame: CGRect.zero)
    var kaSubTitleLabel: UILabel = UILabel(frame: CGRect.zero)
    var kaCommentImageView: UILabel = UILabel(frame: .zero)
    var kaCommentLabel: UILabel = UILabel(frame: CGRect.zero)
    var kaSpectatorImageView: UIImageView = UIImageView(frame: .zero)
    var kaSpectatorLabel: UILabel = UILabel(frame: CGRect.zero)
    var kaLikeImageView: UIImageView = UIImageView(frame: .zero)
    var kaDislikeImageView: UIImageView = UIImageView(frame: .zero)
    var kaLikeLabel: UILabel = UILabel(frame: CGRect.zero)
    var kaDislikeLabel: UILabel = UILabel(frame: CGRect.zero)
    var kaActionContainerView: UIView = UIView(frame: .zero)
    var maskLayer: CAShapeLayer!
    var borderLayer: CAShapeLayer!
    public var userIntent:((_ action: Any?) -> Void)?
    var imageViewHeightConstraint: NSLayoutConstraint!
    var optionsViewHeightConstraint: NSLayoutConstraint!
    
    public var optionsAction: ((_ title: String?, _ payload: String?) -> Void)?
    public var linkAction: ((_ text: String?) -> Void)?
    public var userIntentAction: ((_ title: String?, _ customData: [String: Any]?) -> Void)?
    var isImagePresent : Bool = true
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.white
        layer.masksToBounds = true
        setup()
    }
    
    convenience init () {
        self.init(frame: CGRect.zero)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public func setup() {
        let width = frame.size.width

        optionsViewHeightConstraint = NSLayoutConstraint(item: optionsView, attribute:.height, relatedBy:.equal, toItem:nil, attribute:.notAnAttribute, multiplier:1.0, constant:KRECardView.kMaxRowHeight)
        optionsView.addConstraint(optionsViewHeightConstraint)
        
        optionsView.optionsButtonAction = { [weak self] (title, payload) in
            self?.optionsAction?(title, payload)
        }
        optionsView.detailLinkAction = {[weak self] (text) in
            self?.linkAction?(text)
        }
        optionsView.userIntentAction = { [weak self] (title, customData) in
            self?.userIntentAction?(title, customData)
        }
        
        
        textLabel.font = UIFont.textFont(ofSize: 16.0, weight: .regular)
        textLabel.textColor = UIColor(hex: 0x484848)
        textLabel.numberOfLines = 1
        textLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        textLabel.isUserInteractionEnabled = true
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(kaActionContainerView)
        
        dateLabel.font = UIFont.textFont(ofSize: 13.0, weight: .regular)
        dateLabel.textColor = UIColor(hex: 0xA7A9BE)
        dateLabel.isUserInteractionEnabled = true
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(dateLabel)
        
        kaTitleLabel.font = UIFont.textFont(ofSize: 19.0, weight: .medium)
        kaTitleLabel.numberOfLines = 1
        kaTitleLabel.textColor = UIColor(hex: 0x3E3E51)
        kaTitleLabel.isUserInteractionEnabled = true
        kaTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(kaTitleLabel)
        
        kaSubTitleLabel.font = UIFont.textFont(ofSize: 15.0, weight: .regular)
        kaSubTitleLabel.numberOfLines = 2
        kaSubTitleLabel.textColor = UIColor(hex: 0x3E3E51)
        kaSubTitleLabel.isUserInteractionEnabled = true
        kaSubTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(kaSubTitleLabel)
        
        kaCommentImageView.text = "\u{e941}"
        kaCommentImageView.font = UIFont.systemSymbolFont(ofSize: 17)
        kaCommentImageView.backgroundColor = UIColor.white
        kaCommentImageView.textColor = UIColor(hex: 0xA7A9BE)
        kaCommentImageView.tintColor = UIColor(hex: 0xA7A9BE)
        kaCommentImageView.clipsToBounds = true
        kaCommentImageView.translatesAutoresizingMaskIntoConstraints = false
        kaCommentImageView.isUserInteractionEnabled = true
        kaActionContainerView.addSubview(kaCommentImageView)
        
        kaSpectatorImageView.contentMode = .scaleAspectFit
        kaSpectatorImageView.tintColor = UIColor(hex: 0xA7A9BE)
        let viewImage = UIImage(named: "viewImage", in: bundle, compatibleWith: nil)
        let viewTemplateImage = viewImage?.withRenderingMode(.alwaysTemplate)
        kaSpectatorImageView.image = viewTemplateImage
        kaSpectatorImageView.backgroundColor = UIColor.white
        kaSpectatorImageView.clipsToBounds = true
        kaSpectatorImageView.translatesAutoresizingMaskIntoConstraints = false
        kaSpectatorImageView.isUserInteractionEnabled = true
        kaActionContainerView.addSubview(kaSpectatorImageView)
        
        kaLikeImageView.contentMode = .scaleAspectFit
        let favouriteImage = UIImage(named: "yes", in: bundle, compatibleWith: nil)
        let favouriteTemplateImage = favouriteImage?.withRenderingMode(.alwaysTemplate)
        kaLikeImageView.image = favouriteTemplateImage
        kaLikeImageView.tintColor = UIColor(hex: 0xA7A9BE)
        kaLikeImageView.backgroundColor = UIColor.white
        kaLikeImageView.clipsToBounds = true
        kaLikeImageView.translatesAutoresizingMaskIntoConstraints = false
        kaLikeImageView.isUserInteractionEnabled = true
        kaActionContainerView.addSubview(kaLikeImageView)
        
        kaDislikeImageView.contentMode = .scaleAspectFit
        let disLikeImage = UIImage(named: "no", in: bundle, compatibleWith: nil)
        let disLikeTemplateImage = disLikeImage?.withRenderingMode(.alwaysTemplate)
        kaDislikeImageView.image = disLikeTemplateImage
        kaDislikeImageView.tintColor = UIColor(hex: 0xA7A9BE)
        kaDislikeImageView.backgroundColor = UIColor.white
        kaDislikeImageView.clipsToBounds = true
        kaDislikeImageView.translatesAutoresizingMaskIntoConstraints = false
        kaDislikeImageView.isUserInteractionEnabled = true
        kaActionContainerView.addSubview(kaDislikeImageView)
        
        kaCommentLabel.font = UIFont.textFont(ofSize: 15.0, weight: .regular)
        kaCommentLabel.textColor = UIColor(hex: 0x333D4D)
        kaCommentLabel.isUserInteractionEnabled = true
        kaCommentLabel.textAlignment = .left
        kaCommentLabel.translatesAutoresizingMaskIntoConstraints = false
        kaActionContainerView.addSubview(kaCommentLabel)
        
        kaSpectatorLabel.font = UIFont.textFont(ofSize: 15.0, weight: .regular)
        kaSpectatorLabel.textColor = UIColor(hex: 0x333D4D)
        kaSpectatorLabel.isUserInteractionEnabled = true
        kaSpectatorLabel.textAlignment = .left
        kaSpectatorLabel.sizeToFit()
        kaSpectatorLabel.translatesAutoresizingMaskIntoConstraints = false
        kaActionContainerView.addSubview(kaSpectatorLabel)
        
        kaLikeLabel.font = UIFont.textFont(ofSize: 15.0, weight: .regular)
        kaLikeLabel.textColor = UIColor(hex: 0x333D4D)
        kaLikeLabel.sizeToFit()
        kaLikeLabel.isUserInteractionEnabled = true
        kaLikeLabel.textAlignment = .left
        kaLikeLabel.translatesAutoresizingMaskIntoConstraints = false
        kaActionContainerView.addSubview(kaLikeLabel)
        
        kaDislikeLabel.font = UIFont.textFont(ofSize: 15.0, weight: .regular)
        kaDislikeLabel.textColor = UIColor(hex: 0x333D4D)
        kaDislikeLabel.sizeToFit()
        kaDislikeLabel.isUserInteractionEnabled = true
        kaDislikeLabel.textAlignment = .left
        kaDislikeLabel.translatesAutoresizingMaskIntoConstraints = false
        kaActionContainerView.addSubview(kaDislikeLabel)

        kaActionContainerView.translatesAutoresizingMaskIntoConstraints = false
        let views = ["kaCommentImageView": kaCommentImageView, "kaCommentLabel": kaCommentLabel ,"kaSpectatorImageView": kaSpectatorImageView,"kaSpectatorLabel": kaSpectatorLabel,"kaLikeLabel": kaLikeLabel, "kaLikeImageView":kaLikeImageView,"dateLabel": dateLabel, "kaTitleLabel": kaTitleLabel, "kaSubTitleLabel":kaSubTitleLabel, "kaActionContainerView": kaActionContainerView, "kaDislikeLabel": kaDislikeLabel,"kaDislikeImageView": kaDislikeImageView]
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[kaTitleLabel]-5-[dateLabel]-11-[kaSubTitleLabel]-18-[kaActionContainerView]-|", options: [], metrics: nil, views: views))
        actionContainerHeightConstraint = NSLayoutConstraint(item: kaActionContainerView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 18.0)
        addConstraint(actionContainerHeightConstraint)
        actionContainerHeightConstraint.isActive = true
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-13-[kaActionContainerView]-13-|", options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-13-[dateLabel]-13-|", options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-13-[kaTitleLabel]-13-|", options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-13-[kaSubTitleLabel]-13-|", options: [], metrics: nil, views: views))
        addActionContainerView()
    }
    
    func addActionContainerView() {
        let views = ["kaCommentImageView": kaCommentImageView, "kaCommentLabel": kaCommentLabel ,"kaSpectatorImageView": kaSpectatorImageView,"kaSpectatorLabel": kaSpectatorLabel,"kaLikeLabel": kaLikeLabel, "kaLikeImageView":kaLikeImageView, "kaActionContainerView": kaActionContainerView, "kaDislikeLabel": kaDislikeLabel,"kaDislikeImageView": kaDislikeImageView]
        kaActionContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[kaSpectatorImageView(18)]|", options: [], metrics: nil, views: views))
        kaActionContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[kaSpectatorLabel]|", options: [], metrics: nil, views: views))
        kaActionContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[kaLikeImageView(18)]|", options: [], metrics: nil, views: views))
        kaActionContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[kaLikeLabel]|", options: [], metrics: nil, views: views))
        kaActionContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[kaDislikeLabel]|", options: [], metrics: nil, views: views))
        kaActionContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[kaCommentImageView(18)]|", options: [], metrics: nil, views: views))
        kaActionContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[kaCommentLabel]|", options: [], metrics: nil, views: views))
        kaActionContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[kaDislikeImageView(18)]|", options: [], metrics: nil, views: views))
        kaActionContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[kaSpectatorImageView(18)]-7-[kaSpectatorLabel(30)]-25-[kaCommentImageView(18)]-7-[kaCommentLabel(30)]-33-[kaLikeImageView(18)]-7-[kaLikeLabel(30)]-33-[kaDislikeImageView(18)]-5-[kaDislikeLabel(30)]", options: [], metrics: nil, views: views))
    }

    static func getAttributedString(cardInfo: KRECardInfo) -> NSMutableAttributedString {
        let title = cardInfo.title ?? ""
        let subtitle = cardInfo.subTitle ?? ""
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.paragraphSpacing = 0.25 * 16.0
        let myAttributes = [NSAttributedString.Key.foregroundColor:UIColor(hex: 0x484848),
                            NSAttributedString.Key.font: UIFont.textFont(ofSize: 16.0, weight: .regular),
                            NSAttributedString.Key.paragraphStyle:paragraphStyle]
        let mutableAttrString = NSMutableAttributedString(string: title, attributes: myAttributes)
        let myAttributes2 = [NSAttributedString.Key.foregroundColor:UIColor(hex: 0x777777),
                             NSAttributedString.Key.font: UIFont.textFont(ofSize: 15.0, weight: .regular)]
        let mutableAttrString2 = NSMutableAttributedString(string: "\n\(subtitle)", attributes: myAttributes2)
        mutableAttrString.append(mutableAttrString2)
        return mutableAttrString
    }
    
    static func getExpectedHeight(cardInfo: KRECardInfo, width: CGFloat) -> CGFloat {
        var height: CGFloat = 0.0
        
        // imageView height
        if cardInfo.isImagePresent {
            height += width * 0.5
        }
        
        if let count = cardInfo.options?.count {
            height += KRECardView.kMaxRowHeight * CGFloat(min(count, KRECardView.buttonLimit))
        }
        
        let attrString: NSMutableAttributedString = KRECardView.getAttributedString(cardInfo: cardInfo)
        let limitingSize: CGSize = CGSize(width: width - 20.0, height: CGFloat.greatestFiniteMagnitude)
        let rect: CGRect = attrString.boundingRect(with: limitingSize, options: NSStringDrawingOptions.usesLineFragmentOrigin, context: nil)
        height += rect.size.height + 32.0
        
        return height
    }
    
    public func configureForCardInfo(cardInfo: KRECardInfo) {
        isImagePresent = cardInfo.isImagePresent
        //        textLabel.attributedText = KRECardView.getAttributedString(cardInfo: cardInfo)
        optionsView.options.removeAll()
        optionsView.options = cardInfo.options!
        let count: Int = min(cardInfo.options!.count, KRECardView.buttonLimit)
        optionsViewHeightConstraint.constant = KRECardView.kMaxRowHeight*CGFloat(count)
        let payload = cardInfo.payload
        
        let nameDetails = payload?["owner"] as? [String: Any]
        if let createdOn = payload?["createdOn"] as? TimeInterval, let lastMod = payload?["lastMod"] as? TimeInterval {
            if lastMod == createdOn {
                let createdDate = createdOn/1000
                let dateTime = Date(timeIntervalSince1970: createdDate)
                if let dateStr = dateTime.format(date: dateTime) {
                    dateLabel.text = "Created: " + dateStr
                }
            } else {
                let lastModifiedDate = lastMod/1000
                let dateTime = Date(timeIntervalSince1970: lastModifiedDate)
                if let dateStr = dateTime.format(date: dateTime) {
                    dateLabel.text = "Modified: " + dateStr
                }
            }
        }
        
        if let count = cardInfo.title?.count, count > 0 {
            kaTitleLabel.text = cardInfo.title
        } else {
            kaTitleLabel.text = NSLocalizedString("[Untitled Article]", comment: "Article")
        }
        
        if let count = cardInfo.subTitle?.trimmingCharacters(in: .whitespacesAndNewlines).count, count > 0 {
            let removeNewLine = cardInfo.subTitle?.trimmingCharacters(in: .whitespacesAndNewlines)
            kaSubTitleLabel.text = removeNewLine
        } else {
            kaSubTitleLabel.text = NSLocalizedString("[No description added]", comment: "Article")
            kaSubTitleLabel.font = UIFont.textItalicFont(ofSize: 15)
        }
        
        let firstName = nameDetails?["fN"] as? String ?? ""
        let lastName = nameDetails?["lN"] as? String ?? ""
        let color = nameDetails?["color"] as? String
        if let nComments = payload?["nComments"] as? Int, nComments > 0 {
            kaCommentLabel.text = "\(nComments)"
        }
        if let nLikes = payload?["nLikes"] as? Int, nLikes > 0 {
            kaLikeLabel.text = "\(nLikes)"
        }
        if let nSpectators = payload?["nViews"] as? Int, nSpectators > 0 {
            kaSpectatorLabel.text = "\(nSpectators)"
        }
    }
    
    func getInitialsFromNameOne(name1: String, name2: String) -> String {
        let firstName = name1.first ?? Character(" ")
        let lastName = name2.first ?? Character(" ")
        return "\(firstName)\(lastName)".trimmingCharacters(in: .whitespaces)
    }

    
    
    public func updateLayer() {

    }
    
    override public func layoutSubviews() {
        
    }

    public func prepareForReuse() {
        textLabel.text = ""
        dateLabel.text = ""
        kaTitleLabel.text = ""
        kaSubTitleLabel.text = ""
        kaCommentLabel.text = ""
        kaSpectatorLabel.text = ""
        kaLikeLabel.text = ""
    }
}
