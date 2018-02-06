//
//  KRECardView.swift
//  Widgets
//
//  Created by developer@kore.com on 24/05/17.
//  Copyright © 2017 Kore Inc. All rights reserved.
//
//

import UIKit
import KoreBotSDK

public class KRECardInfo: NSObject {
    
    static public let buttonLimit: Int = 3
    static public let titleCharLimit: Int = 80
    static public let subtitleCharLimit: Int = 100
    
    // MARK:- properties
    var title: String?
    var subTitle: String?
    var imageURL:String?
    
    var options: Array<KREOption>?
    var defaultAction: KREAction?
    
    // MARK:- init
    public override init() {
        super.init()
    }
    
    public init(title: String, subTitle: String, imageURL: String) {
        super.init()
        self.title = truncateString(title, count: KRECardInfo.titleCharLimit)
        self.subTitle = truncateString(subTitle, count: KRECardInfo.subtitleCharLimit)
        self.imageURL = imageURL
    }
    
    public func setOptionData(title: String, subTitle: String, imageURL: String) {
        self.title = truncateString(title, count: KRECardInfo.titleCharLimit)
        self.subTitle = truncateString(subTitle, count: KRECardInfo.subtitleCharLimit)
        self.imageURL = imageURL
    }
    
    public func setDefaultAction(action: KREAction) {
        self.defaultAction = action
    }
    
    public func setOptions(options: Array<KREOption>) {
        self.options = options
    }
    
    func truncateString(_ string: String, count: Int) -> String{
        var tmpString = string
        if(tmpString.characters.count > count){
            tmpString = tmpString.substring(to: tmpString.index(tmpString.startIndex, offsetBy: count-3)) + "..."
        }
        return tmpString
    }
}

public class KRECardView: UIView, UIGestureRecognizerDelegate {
    
    static let kMaxRowHeight: CGFloat = 44
    static let buttonLimit: Int = 3
    var isFirst: Bool = false
    var isLast: Bool = false
    var urlString: String!
    
    var imageView: UIImageView!
    var optionsView: KREOptionsView!
    var textLabel: UILabel!
    
    var maskLayer: CAShapeLayer!
    var borderLayer: CAShapeLayer!
    
    var imageViewHeightConstraint: NSLayoutConstraint!
    var optionsViewHeightConstraint: NSLayoutConstraint!
    
    public var optionsAction: ((_ text: String?) -> Void)!
    public var linkAction: ((_ text: String?) -> Void)!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        self.layer.masksToBounds = true
        setup()
    }
    
    convenience init () {
        self.init(frame: CGRect.zero)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        let width = self.frame.size.width
        self.imageView = UIImageView()
        self.imageView.contentMode = .scaleAspectFill
        self.imageView.backgroundColor = UIColor.gray
        self.imageView.clipsToBounds = true
        self.imageView.layer.borderWidth = 0.5
        self.imageView.layer.borderColor = UIColor.lightGray.cgColor
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.imageView.isUserInteractionEnabled = true
        self.addSubview(self.imageView)
        
        var views: [String: UIView] = ["imageView": self.imageView]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[imageView]", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[imageView]|", options: [], metrics: nil, views: views))
        
        self.imageViewHeightConstraint = NSLayoutConstraint(item: self.imageView, attribute:.height, relatedBy:.equal, toItem:nil, attribute:.notAnAttribute, multiplier:1.0, constant:width*0.5)
        self.imageView.addConstraint(self.imageViewHeightConstraint)
        
        self.optionsView = KREOptionsView()
        self.optionsView.translatesAutoresizingMaskIntoConstraints = false
        self.optionsView.isUserInteractionEnabled = true
        self.optionsView.contentMode = UIViewContentMode.topLeft
        self.optionsView.layer.borderWidth = 0.5
        self.optionsView.layer.borderColor = UIColor.lightGray.cgColor
        self.optionsView.optionsTableView.separatorInset = UIEdgeInsets.zero
        self.addSubview(self.optionsView)
        views = ["optionsView": self.optionsView]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[optionsView]|", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[optionsView]|", options: [], metrics: nil, views: views))
        
        self.optionsViewHeightConstraint = NSLayoutConstraint(item: self.optionsView, attribute:.height, relatedBy:.equal, toItem:nil, attribute:.notAnAttribute, multiplier:1.0, constant:KRECardView.kMaxRowHeight)
        self.optionsView.addConstraint(self.optionsViewHeightConstraint)
        
        self.optionsView.optionsButtonAction = {[weak self] (text) in
            if((self?.optionsAction) != nil){
                self?.optionsAction(text)
            }
        }
        self.optionsView.detailLinkAction = {[weak self] (text) in
            if(self?.linkAction != nil){
                self?.linkAction(text)
            }
        }
        
        self.textLabel = UILabel(frame: CGRect.zero)
        self.textLabel.font = UIFont(name: "HelveticaNeue", size: 16.0)
        self.textLabel.textColor = Common.UIColorRGB(0x484848)
        self.textLabel.numberOfLines = 0
        self.textLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        self.textLabel.isUserInteractionEnabled = true
        self.textLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.textLabel)
        
        views = ["imageView": self.imageView, "textLabel": self.textLabel, "optionsView": self.optionsView]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[imageView]-[textLabel]-(>=10@1)-[optionsView]", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[textLabel]-10-|", options: [], metrics: nil, views: views))
    }
    
    static func getAttributedString(cardInfo: KRECardInfo) -> NSMutableAttributedString {
        var title = cardInfo.title! as String
        var subtitle = cardInfo.subTitle! as String
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.paragraphSpacing = 0.25 * 16.0
        let myAttributes = [NSAttributedStringKey.foregroundColor:Common.UIColorRGB(0x484848),
                            NSAttributedStringKey.font: UIFont(name: "HelveticaNeue-Medium", size: 16.0)!,
                            NSAttributedStringKey.paragraphStyle:paragraphStyle ]
        let mutableAttrString = NSMutableAttributedString(string: title, attributes: myAttributes)
        let myAttributes2 = [NSAttributedStringKey.foregroundColor:Common.UIColorRGB(0x777777),
                             NSAttributedStringKey.font: UIFont(name: "HelveticaNeue", size: 15.0)! ]
        let mutableAttrString2 = NSMutableAttributedString(string: "\n\(subtitle)", attributes: myAttributes2)
        mutableAttrString.append(mutableAttrString2)
        return mutableAttrString
    }
    
    static func getExpectedHeight(cardInfo: KRECardInfo, width: CGFloat) -> CGFloat {
        var height: CGFloat = 0.0
        
        //imageViw height
        height += width*0.5
        
        let count: Int = min(cardInfo.options!.count, KRECardView.buttonLimit)
        height += KRECardView.kMaxRowHeight*CGFloat(count)
        
        let attrString: NSMutableAttributedString = KRECardView.getAttributedString(cardInfo: cardInfo)
        let limitingSize: CGSize = CGSize(width: width-20.0, height: CGFloat.greatestFiniteMagnitude)
        let rect: CGRect = attrString.boundingRect(with: limitingSize, options: NSStringDrawingOptions.usesLineFragmentOrigin, context: nil)
        height += rect.size.height + 20.0
        
        return height
    }
    
    public func configureForCardInfo(cardInfo: KRECardInfo) {
        self.imageView.setImageWith(NSURL(string: cardInfo.imageURL!) as URL!, placeholderImage: UIImage.init(named: "placeholder_image"))
        self.textLabel.attributedText = KRECardView.getAttributedString(cardInfo: cardInfo)
        self.optionsView.options.removeAll()
        self.optionsView.options = cardInfo.options!
        
        let count: Int = min(cardInfo.options!.count, KRECardView.buttonLimit)
        self.optionsViewHeightConstraint.constant = KRECardView.kMaxRowHeight*CGFloat(count)
    }
    
    public func updateLayer() {
        self.applyBubbleMask()
    }
    
    override public func layoutSubviews() {
        self.imageViewHeightConstraint.constant = self.frame.size.width*0.5
        super.layoutSubviews()
        self.applyBubbleMask()
    }
    
    func applyBubbleMask() {
        if(self.maskLayer == nil){
            self.maskLayer = CAShapeLayer()
            self.layer.mask = self.maskLayer
        }
        self.maskLayer.path = self.createBezierPath().cgPath
        self.maskLayer.position = CGPoint(x:0, y:0)
        
        // Add border
        if(self.borderLayer == nil){
            self.borderLayer = CAShapeLayer()
            self.layer.addSublayer(self.borderLayer)
        }
        self.borderLayer.path = self.maskLayer.path // Reuse the Bezier path
        self.borderLayer.fillColor = UIColor.clear.cgColor
        self.borderLayer.strokeColor = Common.UIColorRGB(0xebebeb).cgColor
        self.borderLayer.lineWidth = 1.5
        self.borderLayer.frame = self.bounds
    }
    
    func createBezierPath() -> UIBezierPath {
        // Drawing code
        let cornerRadius: CGFloat = 5
        let extCornerRadius: CGFloat = 20
        let aPath = UIBezierPath()
        let frame = self.bounds
        
        if(self.isLast){
            aPath.move(to: CGPoint(x: CGFloat(frame.maxX - extCornerRadius), y: CGFloat(frame.origin.y)))
            aPath.addQuadCurve(to: CGPoint(x: CGFloat(frame.maxX), y: CGFloat(frame.origin.y + extCornerRadius)), controlPoint: CGPoint(x: CGFloat(frame.maxX), y: CGFloat(frame.origin.y)))
            aPath.addLine(to: CGPoint(x: CGFloat(frame.maxX), y: CGFloat(frame.maxY - extCornerRadius)))
            aPath.addQuadCurve(to: CGPoint(x: CGFloat(frame.maxX - extCornerRadius), y: CGFloat(frame.maxY)), controlPoint: CGPoint(x: CGFloat(frame.maxX), y: CGFloat(frame.maxY)))
        }else{
            aPath.move(to: CGPoint(x: CGFloat(frame.maxX - cornerRadius), y: CGFloat(frame.origin.y)))
            aPath.addQuadCurve(to: CGPoint(x: CGFloat(frame.maxX), y: CGFloat(frame.origin.y + cornerRadius)), controlPoint: CGPoint(x: CGFloat(frame.maxX), y: CGFloat(frame.origin.y)))
            aPath.addLine(to: CGPoint(x: CGFloat(frame.maxX), y: CGFloat(frame.maxY - cornerRadius)))
            aPath.addQuadCurve(to: CGPoint(x: CGFloat(frame.maxX - cornerRadius), y: CGFloat(frame.maxY)), controlPoint: CGPoint(x: CGFloat(frame.maxX), y: CGFloat(frame.maxY)))
        }
        
        if(self.isFirst){
            aPath.addLine(to: CGPoint(x: CGFloat(frame.origin.x), y: CGFloat(frame.maxY)))
            aPath.addQuadCurve(to: CGPoint(x: CGFloat(frame.origin.x), y: CGFloat(frame.maxY)), controlPoint: CGPoint(x: CGFloat(frame.origin.x), y: CGFloat(frame.maxY)))
            aPath.addLine(to: CGPoint(x: CGFloat(frame.origin.x), y: CGFloat(frame.origin.y + extCornerRadius)))
            aPath.addQuadCurve(to: CGPoint(x: CGFloat(frame.origin.x + extCornerRadius), y: CGFloat(frame.origin.y)), controlPoint: CGPoint(x: CGFloat(frame.origin.x), y: CGFloat(frame.origin.y)))
            aPath.addLine(to: CGPoint(x: CGFloat(frame.maxX - extCornerRadius), y: CGFloat(frame.origin.y)))
        }else{
            aPath.addLine(to: CGPoint(x: CGFloat(frame.origin.x + cornerRadius), y: CGFloat(frame.maxY)))
            aPath.addQuadCurve(to: CGPoint(x: CGFloat(frame.origin.x), y: CGFloat(frame.maxY - cornerRadius)), controlPoint: CGPoint(x: CGFloat(frame.origin.x), y: CGFloat(frame.maxY)))
            aPath.addLine(to: CGPoint(x: CGFloat(frame.origin.x), y: CGFloat(frame.origin.y + cornerRadius)))
            aPath.addQuadCurve(to: CGPoint(x: CGFloat(frame.origin.x + cornerRadius), y: CGFloat(frame.origin.y)), controlPoint: CGPoint(x: CGFloat(frame.origin.x), y: CGFloat(frame.origin.y)))
            aPath.addLine(to: CGPoint(x: CGFloat(frame.maxX - cornerRadius), y: CGFloat(frame.origin.y)))
        }
        
        aPath.close()
        return aPath
    }
}

public class KRECardCollectionViewCell: UICollectionViewCell {

    public static let cellReuseIdentifier: String = "KRECardCollectionViewCell"
    public var cardView: KRECardView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.withAlphaComponent(0.5).cgColor
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowRadius = 0.5
        
        self.cardView = KRECardView(frame: CGRect.init(origin: CGPoint.zero, size: frame.size))
        self.contentView.addSubview(self.cardView)
        
        let views: [String: UIView] = ["cardView": cardView]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[cardView]|", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[cardView]|", options: [], metrics: nil, views: views))
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
