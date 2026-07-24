//
//  KRECarouselCardView.swift
//  KoreBotSDK
//
//  Created by Srinivas Vasadi on 25/02/19.
//  Copyright © 2019 Srinivas Vasadi. All rights reserved.
//

import UIKit

public class KRECarouselCardView: UIView, UIGestureRecognizerDelegate {
    let bundle = Bundle.sdkModule
    static let kMaxRowHeight: CGFloat = 44
    static let buttonLimit: Int = 3
    /// Matches `V:[imageView]-[textLabel]-(>=10)-[optionsView]` spacing in `setup()`.
    static let sectionSpacing: CGFloat = 10
    static let cardVerticalPadding: CGFloat = 8
    var isFirst: Bool = false
    var isLast: Bool = false
    var urlString: String!
    
    var imageView: UIImageView = UIImageView()
    var optionsView: KREOptionsView = KREOptionsView()
    var textLabel: UILabel = UILabel(frame: CGRect.zero)
    /// Absorbs extra vertical space so short titles stay top-aligned in tall cards.
    private let textBottomSpacer = UIView(frame: .zero)
    
    var maskLayer: CAShapeLayer!
    var borderLayer: CAShapeLayer!
    
    var imageViewHeightConstraint: NSLayoutConstraint!
    var optionsViewHeightConstraint: NSLayoutConstraint!
    
    public var optionsAction: ((_ title: String?, _ payload: String?) -> Void)?
    public var linkAction: ((_ text: String?) -> Void)?
    public var userIntent: ((_ object: Any?) -> Void)?
    public var userIntentAction: ((_ title: String?, _ customData: [String: Any]?) -> Void)?
    var isImagePresent : Bool = true
    private var configuredCardInfo: KRECardInfo?
    
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
        super.init(coder: aDecoder)
    }
    
    public func setup() {
        let width = self.frame.size.width
        self.imageView.contentMode = .scaleAspectFit
        self.imageView.backgroundColor = UIColor.white
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
        
        self.optionsView.translatesAutoresizingMaskIntoConstraints = false
        self.optionsView.isUserInteractionEnabled = true
        self.optionsView.contentMode = UIView.ContentMode.topLeft
        self.optionsView.layer.borderWidth = 0.5
        self.optionsView.layer.borderColor = UIColor.lightGray.cgColor
        self.optionsView.optionsTableView.separatorInset = UIEdgeInsets.zero
        self.addSubview(self.optionsView)
        views = ["optionsView": self.optionsView]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[optionsView]|", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[optionsView]|", options: [], metrics: nil, views: views))
        
        self.optionsViewHeightConstraint = NSLayoutConstraint(item: self.optionsView, attribute:.height, relatedBy:.equal, toItem:nil, attribute:.notAnAttribute, multiplier:1.0, constant:KRECardView.kMaxRowHeight)
        self.optionsView.addConstraint(self.optionsViewHeightConstraint)
        
        self.optionsView.optionsButtonAction = { [weak self] (title, payload) in
            self?.optionsAction?(title, payload)
        }
        self.optionsView.detailLinkAction = {[weak self] (text) in
            self?.linkAction?(text)
        }
        self.optionsView.userIntentAction = { [weak self] (title, customData) in
            self?.userIntentAction?(title, customData)
        }
        
        if #available(iOS 8.2, *) {
            self.textLabel.font = UIFont.textFont(ofSize: 16.0, weight: .regular)
        } else {
            // Fallback on earlier versions
        }
        self.textLabel.textColor = UIColor(hex: 0x484848)
        self.textLabel.numberOfLines = 0
        self.textLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        self.textLabel.textAlignment = .left
        self.textLabel.isUserInteractionEnabled = true
        self.textLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.textLabel)
        
        textBottomSpacer.translatesAutoresizingMaskIntoConstraints = false
        textBottomSpacer.isUserInteractionEnabled = false
        textBottomSpacer.setContentHuggingPriority(.defaultLow, for: .vertical)
        textBottomSpacer.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        addSubview(textBottomSpacer)
        
        views = ["imageView": self.imageView, "textLabel": self.textLabel, "spacer": textBottomSpacer, "optionsView": self.optionsView]
        // image - text - flexible spacer - buttons. Spacer keeps short text top-aligned
        // without stretching the UILabel (which vertically centers glyphs).
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[imageView]-spacing-[textLabel]-spacing-[spacer(>=0)]-[optionsView]", options: [], metrics: ["spacing": KRECarouselCardView.sectionSpacing], views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[textLabel]-10-|", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[spacer]|", options: [], metrics: nil, views: views))
        
        textLabel.setContentCompressionResistancePriority(UILayoutPriority(999), for: .vertical)
        textLabel.setContentHuggingPriority(.required, for: .vertical)
        optionsView.setContentCompressionResistancePriority(.required, for: .vertical)
    }
    
    static func optionsHeight(for cardInfo: KRECardInfo, cardWidth: CGFloat) -> CGFloat {
        guard let options = cardInfo.options, !options.isEmpty else { return 0 }
        let count = min(options.count, buttonLimit)
        var height = kMaxRowHeight * CGFloat(count)
        if count > 1 {
            height += CGFloat(count - 1)
        }
        return height
    }
    
    /// Shared height used by the carousel collection view and table auto-layout.
    public static func expectedCardHeight(cardInfo: KRECardInfo, width: CGFloat) -> CGFloat {
        let layoutWidth = max(width, 1)
        // Matches live constraints: image (optional) -10- text -10- options (pinned to bottom).
        var height: CGFloat = 0
        
        if cardInfo.isImagePresent {
            height += layoutWidth * 0.5
        }
        height += sectionSpacing
        height += textHeight(for: cardInfo, textWidth: layoutWidth - 20.0)
        height += sectionSpacing
        height += optionsHeight(for: cardInfo, cardWidth: layoutWidth)
        // Buffer for emoji line-height / rounding so the last subtitle lines are not clipped.
        return ceil(height) + 12.0
    }
    
    /// Prefer UILabel sizing so multi-line subtitles match on-screen layout (boundingRect can under-measure).
    static func textHeight(for cardInfo: KRECardInfo, textWidth: CGFloat) -> CGFloat {
        let width = max(textWidth, 1)
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: 0))
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .left
        label.preferredMaxLayoutWidth = width
        label.attributedText = getAttributedString(cardInfo: cardInfo)
        let size = label.sizeThatFits(CGSize(width: width, height: .greatestFiniteMagnitude))
        return ceil(size.height)
    }
    
    func updateOptionsViewHeight(for cardWidth: CGFloat) {
        guard let cardInfo = configuredCardInfo else { return }
        optionsViewHeightConstraint.constant = KRECarouselCardView.optionsHeight(for: cardInfo, cardWidth: cardWidth)
    }
    
    static func getAttributedString(cardInfo: KRECardInfo) -> NSMutableAttributedString {
        let title = cardInfo.title ?? ""
        let subtitle = cardInfo.subTitle ?? ""
        
        let titleParagraphStyle = NSMutableParagraphStyle()
        titleParagraphStyle.paragraphSpacing = 0.25 * 16.0
        titleParagraphStyle.lineBreakMode = .byWordWrapping
        titleParagraphStyle.alignment = .left
        let myAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(hex: 0x484848),
            .font: UIFont.textFont(ofSize: 16.0, weight: .regular),
            .paragraphStyle: titleParagraphStyle
        ]
        let mutableAttrString = NSMutableAttributedString(string: title, attributes: myAttributes)
        
        let subtitleParagraphStyle = NSMutableParagraphStyle()
        subtitleParagraphStyle.lineBreakMode = .byWordWrapping
        subtitleParagraphStyle.alignment = .left
        let myAttributes2: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(hex: 0x777777),
            .font: UIFont.textFont(ofSize: 15.0, weight: .regular),
            .paragraphStyle: subtitleParagraphStyle
        ]
        let mutableAttrString2 = NSMutableAttributedString(string: "\n\(subtitle)", attributes: myAttributes2)
        mutableAttrString.append(mutableAttrString2)
        return mutableAttrString
    }
    
    static func getExpectedHeight(cardInfo: KRECardInfo, width: CGFloat) -> CGFloat {
        return expectedCardHeight(cardInfo: cardInfo, width: width)
    }
    
    public func configureForCardInfo(cardInfo: KRECardInfo) {
        configuredCardInfo = cardInfo
        isImagePresent = cardInfo.isImagePresent
        imageView.isHidden = !isImagePresent
        if isImagePresent, let imageUrlString = cardInfo.imageURL, !imageUrlString.isEmpty, let url = URL(string: imageUrlString) {
            imageView.af.setImage(withURL: url, placeholderImage: UIImage(named: "placeholder_image", in: bundle, compatibleWith: nil))
        } else {
            imageView.image = nil
            imageViewHeightConstraint.constant = 0
        }
        let width = bounds.width > 0 ? bounds.width : UIScreen.main.bounds.width
        textLabel.preferredMaxLayoutWidth = max(width - 20.0, 1)
        textLabel.attributedText = KRECarouselCardView.getAttributedString(cardInfo: cardInfo)
        optionsView.options.removeAll()
        optionsView.options = cardInfo.options ?? []
        updateOptionsViewHeight(for: width)
        invalidateIntrinsicContentSize()
    }
    
    public func updateLayer() {
        self.applyBubbleMask()
    }
    
    override public func layoutSubviews() {
        let cardWidth = max(frame.size.width, 1)
        if isImagePresent {
            imageView.isHidden = false
            imageViewHeightConstraint.constant = cardWidth * 0.5
        } else {
            imageView.isHidden = true
            imageViewHeightConstraint.constant = 0
        }
        textLabel.preferredMaxLayoutWidth = max(cardWidth - 20.0, 1)
        textLabel.invalidateIntrinsicContentSize()
        if frame.size.width > 0 {
            updateOptionsViewHeight(for: frame.size.width)
        }
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
        self.borderLayer.strokeColor = UIColor(hex: 0xebebeb).cgColor
        self.borderLayer.lineWidth = 1.5
        self.borderLayer.frame = self.bounds
    }
    
    func createBezierPath() -> UIBezierPath {
        // Drawing code
        let cornerRadius: CGFloat = 5
        let extCornerRadius: CGFloat = 20
        let aPath = UIBezierPath()
        let frame = self.bounds
        
        if self.isLast {
            aPath.move(to: CGPoint(x: CGFloat(frame.maxX - extCornerRadius), y: CGFloat(frame.origin.y)))
            aPath.addQuadCurve(to: CGPoint(x: CGFloat(frame.maxX), y: CGFloat(frame.origin.y + extCornerRadius)), controlPoint: CGPoint(x: CGFloat(frame.maxX), y: CGFloat(frame.origin.y)))
            aPath.addLine(to: CGPoint(x: CGFloat(frame.maxX), y: CGFloat(frame.maxY - extCornerRadius)))
            aPath.addQuadCurve(to: CGPoint(x: CGFloat(frame.maxX - extCornerRadius), y: CGFloat(frame.maxY)), controlPoint: CGPoint(x: CGFloat(frame.maxX), y: CGFloat(frame.maxY)))
        } else {
            aPath.move(to: CGPoint(x: CGFloat(frame.maxX - cornerRadius), y: CGFloat(frame.origin.y)))
            aPath.addQuadCurve(to: CGPoint(x: CGFloat(frame.maxX), y: CGFloat(frame.origin.y + cornerRadius)), controlPoint: CGPoint(x: CGFloat(frame.maxX), y: CGFloat(frame.origin.y)))
            aPath.addLine(to: CGPoint(x: CGFloat(frame.maxX), y: CGFloat(frame.maxY - cornerRadius)))
            aPath.addQuadCurve(to: CGPoint(x: CGFloat(frame.maxX - cornerRadius), y: CGFloat(frame.maxY)), controlPoint: CGPoint(x: CGFloat(frame.maxX), y: CGFloat(frame.maxY)))
        }
        
        if self.isFirst {
            aPath.addLine(to: CGPoint(x: CGFloat(frame.origin.x), y: CGFloat(frame.maxY)))
            aPath.addQuadCurve(to: CGPoint(x: CGFloat(frame.origin.x), y: CGFloat(frame.maxY)), controlPoint: CGPoint(x: CGFloat(frame.origin.x), y: CGFloat(frame.maxY)))
            aPath.addLine(to: CGPoint(x: CGFloat(frame.origin.x), y: CGFloat(frame.origin.y + extCornerRadius)))
            aPath.addQuadCurve(to: CGPoint(x: CGFloat(frame.origin.x + extCornerRadius), y: CGFloat(frame.origin.y)), controlPoint: CGPoint(x: CGFloat(frame.origin.x), y: CGFloat(frame.origin.y)))
            aPath.addLine(to: CGPoint(x: CGFloat(frame.maxX - extCornerRadius), y: CGFloat(frame.origin.y)))
        } else {
            aPath.addLine(to: CGPoint(x: CGFloat(frame.origin.x + cornerRadius), y: CGFloat(frame.maxY)))
            aPath.addQuadCurve(to: CGPoint(x: CGFloat(frame.origin.x), y: CGFloat(frame.maxY - cornerRadius)), controlPoint: CGPoint(x: CGFloat(frame.origin.x), y: CGFloat(frame.maxY)))
            aPath.addLine(to: CGPoint(x: CGFloat(frame.origin.x), y: CGFloat(frame.origin.y + cornerRadius)))
            aPath.addQuadCurve(to: CGPoint(x: CGFloat(frame.origin.x + cornerRadius), y: CGFloat(frame.origin.y)), controlPoint: CGPoint(x: CGFloat(frame.origin.x), y: CGFloat(frame.origin.y)))
            aPath.addLine(to: CGPoint(x: CGFloat(frame.maxX - cornerRadius), y: CGFloat(frame.origin.y)))
        }
        
        aPath.close()
        return aPath
    }
    
    public func prepareForReuse() {
        
    }
}

public class KRECardCollectionViewCell: UICollectionViewCell {
    // MARK: - properties
    public static let cellReuseIdentifier: String = "KRECardCollectionViewCell"
    public var cardView: KRECarouselCardView = KRECarouselCardView(frame: .zero)
    
    // MARK: - init
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.withAlphaComponent(0.5).cgColor
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowRadius = 0.5
        
        self.cardView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(self.cardView)
        
        let views: [String: UIView] = ["cardView": cardView]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[cardView]|", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[cardView]|", options: [], metrics: nil, views: views))
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
