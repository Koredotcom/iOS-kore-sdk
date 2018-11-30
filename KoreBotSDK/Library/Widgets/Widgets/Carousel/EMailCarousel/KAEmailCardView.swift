//
//  KRECardView.swift
//  Widgets
//
//  Created by developer@kore.com on 24/05/17.
//  Copyright © 2017 Kore Inc. All rights reserved.
//
//

import UIKit
import Foundation

// MARK: - Email object
public struct KAEmailCardInfo {
    var from: String?
    var to: [String]?
    var cc: [String]?
    var subject: String?
    var desc: String?
    var attachments: [String]?
    var date: String?
    var source: String?
    var buttons: [KAButtonInfo] = [KAButtonInfo]()

    enum CodingKeys: String, CodingKey {
        case from, to, cc, subject, desc, date, attachments, buttons, components, source
    }
}

extension KAEmailCardInfo: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(from, forKey: .from)
        try container.encode(to, forKey: .to)
        try container.encode(cc, forKey: .cc)
        try container.encode(subject, forKey: .subject)
        try container.encode(desc, forKey: .desc)
        try container.encode(date, forKey: .date)
        try container.encode(attachments, forKey: .attachments)
        try container.encode(buttons, forKey: .buttons)
        try container.encode(source, forKey: .source)
    }
}

extension KAEmailCardInfo: Decodable {
    public init(from decoder: Decoder) throws {
        if let values = try? decoder.container(keyedBy: CodingKeys.self){
        from = try? values.decode(String.self, forKey: .from)
        to = try? values.decode([String].self, forKey: .to)
        cc = try? values.decode([String].self, forKey: .cc)
        subject = try? values.decode(String.self, forKey: .subject)
        desc = try? values.decode(String.self, forKey: .desc)
        date = try? values.decode(String.self, forKey: .date)
        attachments = try? values.decode([String].self, forKey: .attachments)
        do {
            buttons = try values.decode([KAButtonInfo].self, forKey: .buttons)
        } catch {
            print(error.localizedDescription)
        }
        source = try? values.decode(String.self, forKey: .source)
        }
    }
}

// MARK: - Button object
public struct KAButtonInfo {
    public var action: String?
    public var payload: String?
    public var title: String?
    public var type: String?
    public var dweb: String?
    public var mob: String?
    enum CodingKeys: String, CodingKey {
        case action, payload, title, type, customData
    }
    
    enum CustomData: String, CodingKey {
        case redirectUrl
    }
    
    enum RedirectUrl: String, CodingKey {
        case dweb, mob
    }
}

extension KAButtonInfo: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(action, forKey: .action)
        try container.encode(payload, forKey: .payload)
        try container.encode(title, forKey: .title)
        try container.encode(type, forKey: .type)
        
        var customData = container.nestedContainer(keyedBy: CustomData.self, forKey: .customData)
        var redirectUrl = customData.nestedContainer(keyedBy: RedirectUrl.self, forKey: .redirectUrl)
        try redirectUrl.encode(dweb, forKey: .dweb)
        try redirectUrl.encode(mob, forKey: .mob)
    }
}

extension KAButtonInfo: Decodable {
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        do {
            action = try values.decode(String.self, forKey: .action)
        } catch {
            print(error.localizedDescription)
        }
        do {
            payload = try values.decode(String.self, forKey: .payload)
        } catch {
            print(error.localizedDescription)
        }
        do {
            title = try values.decode(String.self, forKey: .title)
        } catch {
            print(error.localizedDescription)
        }
        do {
            type = try values.decode(String.self, forKey: .type)
        } catch {
            print(error.localizedDescription)
        }
        do {
            let customData = try values.nestedContainer(keyedBy: CustomData.self, forKey: .customData)
            let redirectUrl = try customData.nestedContainer(keyedBy: RedirectUrl.self, forKey: .redirectUrl)
            dweb = try redirectUrl.decode(String.self, forKey: .dweb)
            mob = try redirectUrl.decode(String.self, forKey: .mob)
        } catch {
            print(error.localizedDescription)
        }
    }
}

// MARK:- KAEmailCardView
public class KAEmailCardView: UIView, UIGestureRecognizerDelegate {
    static let kMaxRowHeight: CGFloat = 48.0
    static let kMaxHeight: CGFloat = 232.0
    static let buttonLimit: Int = 1
    var isFirst: Bool = false
    var isLast: Bool = false
    var urlString: String!
    var emailObject: KAEmailCardInfo!
    
    var fromPlaceholder: UILabel!
    var toPlaceholder: UILabel!
    var ccPlaceholder: UILabel!
    var attachmentLabel: UILabel!
    
    var fromLabel: UILabel!
    var toLabel: UILabel!
    var ccLabel: UILabel!
    var subjectLabel: UILabel!
    
    var textView: UITextView!
    var footerView: UIView!
    var button: UIButton!
    
    var typeLabel: UILabel!
    var dateTimeLabel: UILabel!
    
    var maskLayer: CAShapeLayer!
    var borderLayer: CAShapeLayer!
    
    var textViewHeightConstraint: NSLayoutConstraint!
    var buttonHeightConstraint: NSLayoutConstraint!
    
    public var buttonAction: ((_ payload: KAButtonInfo?) -> Void)!
    
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
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setup() {
        fromPlaceholder = UILabel(frame: .zero)
        fromPlaceholder.translatesAutoresizingMaskIntoConstraints = false
        fromPlaceholder.text = "From"
        fromPlaceholder.textAlignment = .right
        fromPlaceholder.font = UIFont(name: "Lato-Regular", size: 14.0)!
        fromPlaceholder.textColor = UIColor(hex: 0x8B93A0)
        fromPlaceholder.sizeToFit()
        self.addSubview(fromPlaceholder)

        fromLabel = UILabel(frame: .zero)
        fromLabel.translatesAutoresizingMaskIntoConstraints = false
        fromLabel.font = UIFont(name: "Lato-Regular", size: 14.0)!
        fromLabel.textColor = UIColor(hex: 0x1A1A1A)
        fromLabel.numberOfLines = 2
        fromLabel.lineBreakMode = .byTruncatingTail
        fromLabel.sizeToFit()
        self.addSubview(fromLabel)
        
        toPlaceholder = UILabel(frame: .zero)
        toPlaceholder.text = "To"
        toPlaceholder.textAlignment = .right
        toPlaceholder.translatesAutoresizingMaskIntoConstraints = false
        toPlaceholder.font = UIFont(name: "Lato-Regular", size: 14.0)!
        toPlaceholder.textColor = UIColor(hex: 0x8B93A0)
        toPlaceholder.sizeToFit()
        self.addSubview(toPlaceholder)

        toLabel = UILabel(frame: .zero)
        toLabel.translatesAutoresizingMaskIntoConstraints = false
        toLabel.font = UIFont(name: "Lato-Regular", size: 14.0)!
        toLabel.textColor = UIColor(hex: 0x1A1A1A)
        toLabel.numberOfLines = 2
        toLabel.lineBreakMode = .byTruncatingTail
        toLabel.sizeToFit()
        self.addSubview(toLabel)

        ccPlaceholder = UILabel(frame: .zero)
        ccPlaceholder.translatesAutoresizingMaskIntoConstraints = false
        ccPlaceholder.text = "Cc"
        ccPlaceholder.textAlignment = .right
        ccPlaceholder.font = UIFont(name: "Lato-Regular", size: 14.0)!
        ccPlaceholder.textColor = UIColor(hex: 0x8B93A0)
        ccPlaceholder.sizeToFit()
        self.addSubview(ccPlaceholder)

        ccLabel = UILabel(frame: .zero)
        ccLabel.translatesAutoresizingMaskIntoConstraints = false
        ccLabel.font = UIFont(name: "Lato-Regular", size: 14.0)!
        ccLabel.textColor = UIColor(hex: 0x1A1A1A)
        ccLabel.numberOfLines = 2
        ccLabel.lineBreakMode = .byTruncatingTail
        ccLabel.sizeToFit()
        self.addSubview(ccLabel)
        
        subjectLabel = UILabel(frame: .zero)
        subjectLabel.translatesAutoresizingMaskIntoConstraints = false
        subjectLabel.font = UIFont(name: "Lato-Bold", size: 14.0)!
        subjectLabel.textColor = UIColor(hex: 0x484848)
        subjectLabel.numberOfLines = 2
        subjectLabel.lineBreakMode = .byTruncatingTail
        subjectLabel.sizeToFit()
        self.addSubview(subjectLabel)
        
        textView = UITextView(frame: .zero)
        textView.backgroundColor = .white
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isUserInteractionEnabled = false
        textView.textAlignment = .justified
        textView.textContainer.lineBreakMode = .byTruncatingTail
        textView.contentInset = UIEdgeInsets.zero
        textView.sizeToFit()
        addSubview(textView)
        
        attachmentLabel = UILabel(frame: CGRect.zero)
        attachmentLabel.font = UIFont(name: "Lato-Regular", size: 12.0)
        attachmentLabel.textColor = UIColor(hex: 0x8B93A0)
        attachmentLabel.numberOfLines = 0
        attachmentLabel.sizeToFit()
        attachmentLabel.textAlignment = .right
        attachmentLabel.isUserInteractionEnabled = true
        attachmentLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(attachmentLabel)

        footerView = UIView(frame: .zero)
        footerView.backgroundColor = .white
        footerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(footerView)
        
        button = UIButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.borderWidth = 0.5
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.setTitleColor(UIColor(hex: 0x6168E7), for: .normal)
        button.titleLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 15.0)
        button.setTitle("View Details", for: .normal)
        button.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
        addSubview(button)

        var views: [String: UIView] = ["fromPlaceholder": fromPlaceholder, "fromLabel": fromLabel, "toPlaceholder": toPlaceholder, "toLabel": toLabel, "ccPlaceholder": ccPlaceholder, "ccLabel": ccLabel, "textView": textView, "footerView": footerView, "button": button, "attachmentLabel":attachmentLabel, "subjectLabel": subjectLabel]
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[fromPlaceholder]", options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[fromLabel]", options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[fromLabel]-3-[toPlaceholder]", options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[fromLabel]-3-[toLabel]", options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[toLabel]-3-[ccPlaceholder]", options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[toLabel]-3-[ccLabel]", options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat:
            "V:[ccLabel]-6-[subjectLabel]-0-[textView]-3-[attachmentLabel]-5-[footerView(15)]-[button]|", options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[fromPlaceholder(32)]-5-[fromLabel]-8-|", options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[toPlaceholder(32)]-5-[toLabel]-8-|", options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[ccPlaceholder(32)]-5-[ccLabel]-8-|", options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-5-[textView]-5-|", options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[subjectLabel]-8-|", options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-6-[attachmentLabel]-6-|", options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[footerView]-10-|", options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[button]|", options: [], metrics: nil, views: views))
        
        self.ccLabel.setContentCompressionResistancePriority(UILayoutPriority.defaultHigh, for: .vertical)
        self.textView.setContentCompressionResistancePriority(UILayoutPriority.defaultLow, for: .vertical)
        
        buttonHeightConstraint = NSLayoutConstraint(item: button, attribute:.height, relatedBy:.equal, toItem:nil, attribute:.notAnAttribute, multiplier:1.0, constant: 48.0)
        button.addConstraint(buttonHeightConstraint)

        typeLabel = UILabel(frame: CGRect.zero)
        typeLabel.font = UIFont(name: "Lato-Regular", size: 12.0)
        typeLabel.textColor = UIColor(hex: 0xA7B0BE)
        typeLabel.numberOfLines = 0
        typeLabel.textAlignment = .left
        typeLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        typeLabel.isUserInteractionEnabled = true
        typeLabel.translatesAutoresizingMaskIntoConstraints = false
        footerView.addSubview(typeLabel)

        dateTimeLabel = UILabel(frame: CGRect.zero)
        dateTimeLabel.font = UIFont(name: "Lato-Regular", size: 12.0)
        dateTimeLabel.textColor = UIColor(hex: 0xA7B0BE)
        dateTimeLabel.numberOfLines = 0
        dateTimeLabel.textAlignment = .right
        dateTimeLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        dateTimeLabel.isUserInteractionEnabled = true
        dateTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        footerView.addSubview(dateTimeLabel)

        views = ["textView": textView, "typeLabel": typeLabel, "dateTimeLabel": dateTimeLabel]
        footerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[typeLabel]|", options: [], metrics: nil, views: views))
        footerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[dateTimeLabel]|", options: [], metrics: nil, views: views))
        footerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[typeLabel]-2-[dateTimeLabel]|", options: [], metrics: nil, views: views))
    }
    
    // MARK: - button action
    @objc func buttonAction(_ sender: UIButton) {
        if (self.buttonAction != nil) {
            if (emailObject.buttons.count > 0) {
                let buttonInfo: KAButtonInfo = emailObject.buttons[0]
                self.buttonAction(buttonInfo)
            }
        }
    }
    
    static func getAttributedString(for emailObject: KAEmailCardInfo) -> NSMutableAttributedString {
//        let subject = emailObject.subject ?? ""
//        let subjectString = formatHTMLEscapedString(subject)
        let subjectAttributes = [NSAttributedStringKey.foregroundColor:UIColor(hex: 0x484848),
                            NSAttributedStringKey.font: UIFont(name: "Lato-Bold", size: 14.0)!]
        let attributedString = NSMutableAttributedString(string: "", attributes: subjectAttributes)

        let desc = emailObject.desc ?? ""
        let descString = formatHTMLEscapedString(desc)
        let descAttributes = [NSAttributedStringKey.foregroundColor:UIColor(hex: 0x777777),
                             NSAttributedStringKey.font: UIFont(name: "Lato-Regular", size: 14.0)!]
        let descAttributedString = NSAttributedString(string: "\(descString)", attributes: descAttributes)
        attributedString.append(descAttributedString)
        return attributedString
    }
    
    static func getExpectedHeight(for object: KAEmailCardInfo, width: CGFloat) -> CGFloat {
        var height: CGFloat = 0.0
        height += width * 0.5
        
        let count: Int = min(object.buttons.count, self.buttonLimit)
        height += kMaxRowHeight * CGFloat(count)
        
        let attrString: NSMutableAttributedString = self.getAttributedString(for: object)
        let limitingSize: CGSize = CGSize(width: width - 20.0, height: kMaxHeight)
        let rect: CGRect = attrString.boundingRect(with: limitingSize, options: NSStringDrawingOptions.usesLineFragmentOrigin, context: nil)
        height += rect.size.height + 20.0
        return height
    }
    
    public func configure(with object: KAEmailCardInfo) {
        let from = object.from ?? "".addingPercentEncoding(withAllowedCharacters: .controlCharacters)
        let fromAttributes = [NSAttributedStringKey.foregroundColor:UIColor(hex: 0x6168E7),
                            NSAttributedStringKey.font: UIFont(name: "Lato-Regular", size: 14.0)!]
        let fromString = KAEmailCardView.formatHTMLEscapedString(from!)
        let fromAttributedString = NSAttributedString(string: "\(fromString)\n", attributes: fromAttributes)
        fromLabel.attributedText = fromAttributedString

        let to = object.to?.joined(separator: ", ")
        var toString = KAEmailCardView.formatHTMLEscapedString(to!)
        if toString.count == 0 {
            toString = "  "
        }
        print(toString)
        
        let toAttributes = [NSAttributedStringKey.foregroundColor:UIColor(hex: 0x1A1A1A),
                                 NSAttributedStringKey.font: UIFont(name: "Lato-Regular", size: 14.0)!]
        let toAttributedString = NSAttributedString(string: toString, attributes: toAttributes)
        toLabel.attributedText = toAttributedString
        
        var cc = " "
        if (object.cc!.count > 0) {
            cc = (object.cc?.joined(separator: ", "))!
        }
        let ccString = KAEmailCardView.formatHTMLEscapedString(cc)
        if ccString.count == 1 || ccString.count == 0 {
            ccLabel.text = ""
            ccPlaceholder.text = ""
            ccLabel.numberOfLines = 0
        }else{
            ccPlaceholder.text = "Cc"
            let ccAttributedString = NSAttributedString(string: ccString, attributes: toAttributes)
            ccLabel.attributedText = ccAttributedString
        }
        
        let iconsSize = CGRect(x: 0, y: -2, width: 14, height: 14)
        let attachment = NSTextAttachment()
        attachment.bounds = iconsSize
        attachment.image = UIImage(named: "inbox_attachment")
        let attachmentAttributedString = NSMutableAttributedString()
        attachmentAttributedString.append(NSAttributedString(attachment: attachment))
        let attachmentsCount = object.attachments?.count ?? 0
        if attachmentsCount == 0 {
            attachmentLabel.text = ""
        }else{
            attachmentAttributedString.append(NSAttributedString(string: String(format: "%d %@",attachmentsCount, attachmentsCount == 1 ? "attachment" : "attachments")))
            attachmentLabel.attributedText = attachmentAttributedString
        }
        
        let subject = emailObject.subject ?? ""
        let subjectString = KAEmailCardView.formatHTMLEscapedString(subject)
        subjectLabel.text = subjectString
        subjectLabel.backgroundColor = UIColor.clear
        
        textView.attributedText = KAEmailCardView.getAttributedString(for: object)
        textView.textContainer.maximumNumberOfLines = textView.numberOfLines()
        
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, d MMM yyyy HH:mm:ss Z"
        var dateString: String = object.date!
        if dateString.contains("(UTC)") {
            let range = dateString.range(of: "(UTC)")!
            dateString = dateString.replacingCharacters(in: range, with: "")
        }
        let date = dateFormatter.date(from: dateString)
        dateTimeLabel.text = date?.formattedAsAgo()
        typeLabel.text = object.source ?? ""
    }
    
    public func updateLayer() {
        applyBubbleMask()
    }
    
    override public func layoutSubviews() {
//        textViewHeightConstraint.constant = 10.0
        super.layoutSubviews()
        applyBubbleMask()
    }
    
    func applyBubbleMask() {
        if(maskLayer == nil){
            maskLayer = CAShapeLayer()
            layer.mask = maskLayer
        }
        maskLayer.path = createBezierPath().cgPath
        maskLayer.position = CGPoint(x:0, y:0)
        
        // Add border
        if(borderLayer == nil){
            borderLayer = CAShapeLayer()
            layer.addSublayer(borderLayer)
        }
        borderLayer.path = maskLayer.path // Reuse the Bezier path
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.strokeColor = UIColor(hex: 0xebebeb).cgColor
        borderLayer.lineWidth = 1.5
        borderLayer.frame = bounds
    }
    
    func createBezierPath() -> UIBezierPath {
        // Drawing code
        let cornerRadius: CGFloat = 5
        let extCornerRadius: CGFloat = 20
        let aPath = UIBezierPath()
        let frame = bounds
        
        if (isLast) {
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
        
        if (isFirst) {
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

public class KAEmailCardCollectionViewCell: UICollectionViewCell {

    public static let cellReuseIdentifier: String = "KAEmailCardCollectionViewCell"
    public var cardView: KAEmailCardView!
    
    // MARK: - init
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
        
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.withAlphaComponent(0.5).cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowRadius = 0.5
        
        cardView = KAEmailCardView(frame: CGRect.init(origin: CGPoint.zero, size: frame.size))
        contentView.addSubview(cardView)
        
        let views: [String: UIView] = ["cardView": cardView]
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[cardView]|", options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[cardView]|", options: [], metrics: nil, views: views))
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class KAEmailCardHeaderView: UICollectionReusableView {
    var label: UILabel!
    
    // MARK: - init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "View Details"
        addSubview(label)
        
        let views: [String: UIView] = ["label": label]
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[label]|", options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[label]|", options: [], metrics: nil, views: views))
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension KAEmailCardView {
    class func formatHTMLEscapedString(_ string: String) -> String {
        if string.count == 0 {
            return string
        }
        var str: String = string
        if let subRange = Range<String.Index>(NSRange(location: 0, length: string.count), in: str) { str = str.replacingOccurrences(of: "&gt;", with: ">", options: .literal, range: subRange) }
        if let subRange = Range<String.Index>(NSRange(location: 0, length: str.count), in: str) { str = str.replacingOccurrences(of: "&lt;", with: "<", options: .literal, range: subRange) }
        return str
    }
}

extension Date {
    public func formattedAsAgo()-> String {
        let calendar = Calendar.current
        let now = NSDate()
        let from = self
        let earliest = now.earlierDate(from as Date)
        let latest = earliest == now as Date ? from : now as Date
        let components = calendar.dateComponents([.year, .weekOfYear, .month, .day, .hour, .minute, .second], from: earliest, to: latest as Date)
        
        var result = ""
        
        if components.year! >= 2 {
            result = formatAsOther(using: from as NSDate)
        } else if components.year! >= 1 {
            result = self.formatAsLastYear(using: from as NSDate)
        } else if components.month! >= 2 {
            result = "\(components.month!) months ago"
        } else if components.month! >= 1 {
            result = formatAsLastMonth(using: from as NSDate)
        } else if components.weekOfYear! >= 2 {
            result = "\(components.weekOfYear!) weeks ago"
        } else if components.weekOfYear! >= 1 {
            result = formatAsLastWeek(using: from as NSDate)
        } else if components.day! >= 2 {
            result = "\(components.day!) days ago"
        } else if components.day! >= 1 {
            result = self.formatAsYesterday(using: from as NSDate)
        } else if components.hour! >= 2 {
            result = "\(components.hour!) hours ago"
        } else if components.hour! >= 1 {
            result = "An hour ago"
        } else if components.minute! >= 2 {
            result = "\(components.minute!) minutes ago"
        } else if components.minute! >= 1 {
            result = "A minute ago"
        } else {
            result = "Just now"
        }
        
        return result
    }
    
    
    // Yesterday = "Yesterday at 1:28 PM"
    func formatAsYesterday(using date: NSDate) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        return "Yesterday at \(dateFormatter.string(from: date as Date))"
    }
    
    // < Last 7 days = "Friday at 1:48 AM"
    func formatAsLastWeek(using date: NSDate) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE 'at' h:mm a"
        return dateFormatter.string(from: date as Date)
    }
    
    // < Last 30 days = "March 30 at 1:14 PM"
    func formatAsLastMonth(using date: NSDate) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d 'at' h:mm a"
        return dateFormatter.string(from: date as Date)
    }
    
    // < 1 year = "September 15"
    func formatAsLastYear(using date: NSDate) -> String {
        //Create date formatter
        let dateFormatter = DateFormatter()
        //Format
        dateFormatter.dateFormat = "MMMM d"
        return dateFormatter.string(from: date as Date)
    }
    
    // Anything else = "September 9, 2011"
    func formatAsOther(using date: NSDate) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "LLLL d, yyyy"
        return dateFormatter.string(from: date as Date)
    }
    
    //Friday, March 30 2018
   public func formatAsDayDate(using date: NSDate) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, LLLL d yyyy"
        return dateFormatter.string(from: date as Date)
    }
    //Fri, Mar 30 2018
    public func formatAsDayShortDate(using date: NSDate) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, LLL d yyyy"
        return dateFormatter.string(from: date as Date)
    }
    //Friday, Mar 30
    public func formatAsDay(using date: NSDate) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, LLL d"
        return dateFormatter.string(from: date as Date)
    }
    //Fri, Mar 30
    public func formatAsDayShort(using date: NSDate) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, LLL d"
        return dateFormatter.string(from: date as Date)
    }
    public func formatAsDateASMMDDYY(using date: NSDate) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        return dateFormatter.string(from: date as Date)
    }
    public func formatAsTime(using date: NSDate) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        dateFormatter.amSymbol = "AM"
        dateFormatter.pmSymbol = "PM"

        return dateFormatter.string(from: date as Date)
    }
}

extension UITextView {
    func numberOfLines() -> Int{
        if let fontUnwrapped = self.font {
            return Int(self.contentSize.height / fontUnwrapped.lineHeight)
        }
        return 0
    }
    
}

