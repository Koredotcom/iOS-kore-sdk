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

// MARK:- KAEmailCardView
public class KAEmailCardView: UIView, UIGestureRecognizerDelegate {
    // MARK: -
    static let kMaxRowHeight: CGFloat = 48.0
    static let kMaxHeight: CGFloat = 232.0
    static let buttonLimit: Int = 1
    var isFirst: Bool = false
    var isLast: Bool = false
    public var emailObject: KAEmailCardInfo?
    
    lazy var mailMessageLabel: UILabel = {
        let mailMessageLabel = UILabel(frame: .zero)
        mailMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        mailMessageLabel.font = UIFont.textFont(ofSize: 15.0, weight: .regular)
        mailMessageLabel.textColor = UIColor(hex: 0x485260)
        mailMessageLabel.sizeToFit()
        mailMessageLabel.textAlignment = .left
        mailMessageLabel.isUserInteractionEnabled = true
        return mailMessageLabel
    }()
    lazy var fromLabel: UILabel = {
        let fromLabel = UILabel(frame: .zero)
        fromLabel.translatesAutoresizingMaskIntoConstraints = false
        fromLabel.textAlignment = .left
        fromLabel.font = UIFont.textFont(ofSize: 17.0, weight: .bold)
        fromLabel.textColor = UIColor(hex: 0x485260)
        return fromLabel
    }()
    lazy var subjectLabel: UILabel = {
        let subjectLabel = UILabel(frame: .zero)
        subjectLabel.translatesAutoresizingMaskIntoConstraints = false
        subjectLabel.textAlignment = .left
        subjectLabel.font = UIFont.textFont(ofSize: 15.0, weight: .medium)
        subjectLabel.textColor = UIColor(hex: 0x485260)
        return subjectLabel
    }()
    lazy var dateTimeLabel: UILabel = {
        let dateTimeLabel = UILabel(frame: .zero)
        dateTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        dateTimeLabel.font = UIFont.textFont(ofSize: 15.0, weight: .regular)
        dateTimeLabel.textColor = UIColor(hex: 0xa7a9be)
        dateTimeLabel.sizeToFit()
        dateTimeLabel.textAlignment = .right
        dateTimeLabel.isUserInteractionEnabled = true
        return dateTimeLabel
    }()
    lazy var attachmentImageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = UIColor(hex: 0xa7b0be)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    public var buttonAction: ((_ payload: KAButtonInfo?) -> Void)?
    public var userIntent:((_ action: Any?) -> Void)?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.white
        layer.masksToBounds = true
        setup()
        setupVertical()
    }
    
    convenience init () {
        self.init(frame: .zero)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    public func setup() {
        addSubview(fromLabel)
        addSubview(subjectLabel)
        addSubview(mailMessageLabel)
        addSubview(dateTimeLabel)
        addSubview(attachmentImageView)
        
        var views: [String: UIView] = ["fromLabel": fromLabel,"mailMessageLabel": mailMessageLabel, "subjectLabel": subjectLabel, "dateTimeLabel": dateTimeLabel, "attachmentImageView": attachmentImageView]
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat:
            "V:|-40-[attachmentImageView(10)]", options: .alignAllCenterX, metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[attachmentImageView(10)]-14-|", options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat:
            "V:|-14-[fromLabel]-6-[subjectLabel]-3-[mailMessageLabel]-13.5-|", options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat:
            "V:|-14-[dateTimeLabel]", options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-14-[fromLabel]-52-[dateTimeLabel]-14-|", options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-14-[mailMessageLabel]-14-|", options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-14-[subjectLabel]-80-|", options: [], metrics: nil, views: views))
       
        fromLabel.setContentHuggingPriority(UILayoutPriority.defaultLow, for: .horizontal)
        dateTimeLabel.setContentHuggingPriority(UILayoutPriority.defaultHigh, for: .horizontal)
        fromLabel.setContentCompressionResistancePriority(UILayoutPriority.defaultLow, for: .horizontal)
        dateTimeLabel.setContentCompressionResistancePriority(UILayoutPriority.defaultHigh, for: .horizontal)
    }
    
    func setupVertical() {
        
    }
    
    // MARK: - button action
    @objc func buttonAction(_ sender: UIButton) {
        if let count = emailObject?.buttons.count, count > 0 {
            let buttonInfo = emailObject?.buttons[0]
            buttonAction?(buttonInfo)
        }
    }
    
    static func getAttributedString(for emailObject: KAEmailCardInfo) -> NSMutableAttributedString {
        var subjectAttributes : [NSAttributedString.Key: NSObject]?
        
        if #available(iOS 8.2, *) {
            subjectAttributes = [NSAttributedString.Key.foregroundColor:UIColor(hex: 0x484848),
                                 NSAttributedString.Key.font: UIFont.textFont(ofSize: 14.0, weight: .bold)]
            
        }
        let attributedString = NSMutableAttributedString(string: "", attributes: subjectAttributes)
        
        let desc = emailObject.desc ?? ""
        let descString = formatHTMLEscapedString(desc)
        var descAttributes : [NSAttributedString.Key: NSObject]?
        if #available(iOS 8.2, *) {
            descAttributes = [NSAttributedString.Key.foregroundColor:UIColor(hex: 0x777777),
                              NSAttributedString.Key.font: UIFont.textFont(ofSize: 14.0, weight: .regular)]
        }
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
    
    public func configure(with object: KAEmailCardInfo?) {
        var titleString = ""
        let from = object?.from ?? "".addingPercentEncoding(withAllowedCharacters: .controlCharacters)
        if let from = from, from.count > 0 {
            let fromString = KAEmailCardView.formatHTMLEscapedString(from)
            let fromAttributedString = NSAttributedString(string: "\(fromString)\n")
            fromLabel.attributedText = fromAttributedString
            
            titleString = fromString
        }

        if object?.attachments?.count ?? 0 > 0 {
            attachmentImageView.image = UIImage(named: "attach")
        }

        if object?.subject?.count == 0 {
            fromLabel.text = NSLocalizedString("no subject", comment: "no subject")
        } else {
            fromLabel.text = object?.subject
        }
        subjectLabel.text = titleString
        if object?.desc?.count == 0 {
            mailMessageLabel.text = NSLocalizedString("no body", comment: "no body")
        } else {
            mailMessageLabel.text = object?.desc
        }
        
        if var dateString = object?.date {
            let formatter = DateFormatter.yyyyMMdd
            if let date = formatter.date(from: dateString) {
                dateTimeLabel.text = date.formatAsDateASMMDDYYWithYesterday(using: date)
            }
            if dateString.contains("(UTC)"), let range = dateString.range(of: "(UTC)") {
                dateString = dateString.replacingCharacters(in: range, with: "")
            }
            
            let dateFormatter: DateFormatter = DateFormatter()
            dateFormatter.dateFormat = "E, d MMM yyyy HH:mm:ss Z"
            if let date = dateFormatter.date(from: dateString) {
                dateTimeLabel.text = date.formatAsDateASMMDDYYWithYesterday(using: date)
            }
        }
    }
    
    public func updateLayer() {
        
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
    }
    
    public func prepareForReuse() {
        self.dateTimeLabel.text = ""
        self.subjectLabel.text = ""
        self.fromLabel.text = ""
        self.mailMessageLabel.text = ""
    }
}

public class KAEmailCardCollectionViewCell: UICollectionViewCell {

    public static let cellReuseIdentifier: String = "KAEmailCardCollectionViewCell"
    public lazy var cardView: KAEmailCardView = {
        let cardView = KAEmailCardView(frame: .zero)
        cardView.translatesAutoresizingMaskIntoConstraints = false
        return cardView
    }()
    
    // MARK: - init
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
        
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.withAlphaComponent(0.5).cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowRadius = 0.5
        
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
    lazy var label: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "View Details"
        return label
    }()
    
    // MARK: - init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
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

extension UITextView {
    func numberOfLines() -> Int{
        if let fontUnwrapped = self.font {
            return Int(self.contentSize.height / fontUnwrapped.lineHeight)
        }
        return 0
    }
    
}

