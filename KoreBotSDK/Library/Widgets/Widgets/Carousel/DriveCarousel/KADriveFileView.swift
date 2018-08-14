//
//  KADriveFileView.swift
//  Widgets
//
//  Created by developer@kore.com on 24/05/17.
//  Copyright © 2017 Kore Inc. All rights reserved.
//
//

import UIKit
import Foundation

// MARK: - GDriveFile
public struct KADriveFileInfo {
    var fileId: String?
    var fileName: String?
    var fileSize: String?
    var fileType: String?
    var iconLink: String?
    var sharedBy: String?
    var thumbnailLink: String?
    var lastModified: String?
    var buttons: [KAButtonInfo]?

    enum CodingKeys: String, CodingKey {
        case fileId, fileName, iconLink, sharedBy, thumbnailLink, fileSize, fileType, buttons, lastModified
    }
}

extension KADriveFileInfo: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(fileId, forKey: .fileId)
        try container.encode(fileName, forKey: .fileName)
        try container.encode(iconLink, forKey: .iconLink)
        try container.encode(sharedBy, forKey: .sharedBy)
        try container.encode(thumbnailLink, forKey: .thumbnailLink)
        try container.encode(fileSize, forKey: .fileSize)
        try container.encode(fileType, forKey: .fileType)
        try container.encode(buttons, forKey: .buttons)
        try container.encode(lastModified, forKey: .lastModified)
    }
}

extension KADriveFileInfo: Decodable {
    public init(from decoder: Decoder) throws {
        if let values = try? decoder.container(keyedBy: CodingKeys.self) {
            fileId = try? values.decode(String.self, forKey: .fileId)
            fileName = try? values.decode(String.self, forKey: .fileName)
            iconLink = try? values.decode(String.self, forKey: .iconLink)
            sharedBy = try? values.decode(String.self, forKey: .sharedBy)
            thumbnailLink = try? values.decode(String.self, forKey: .thumbnailLink)
            lastModified = try? values.decode(String.self, forKey: .lastModified)
            fileType = try? values.decode(String.self, forKey: .fileType)
            fileSize = try? values.decode(String.self, forKey: .fileSize)
            buttons = try? values.decode([KAButtonInfo].self, forKey: .buttons)
        }
    }
}

// MARK:- KADriveFileView
public class KADriveFileView: UIView, UIGestureRecognizerDelegate {
    // MARK: - properties
    let kMaxRowHeight: CGFloat = 48.0
    let kMaxHeight: CGFloat = 153.0
    static let buttonLimit: Int = 1
    var isFirst: Bool = false
    var isLast: Bool = false
    var urlString: String!
    var driveFileObject: KADriveFileInfo?
    var titleLabelFont: UIFont? {
        didSet {
            titleLabel.font = titleLabelFont
        }
    }
    var sizeLabelFont: UIFont? {
        didSet {
            sizeLabel.font = sizeLabelFont
        }
    }
    var sharedByLabelFont: UIFont? {
        didSet {
            sharedByLabel.font = sharedByLabelFont
        }
    }
    var buttonFont: UIFont? {
        didSet {
            button.titleLabel?.font = buttonFont
        }
    }
    var dateTimeLabelFont: UIFont? {
        didSet {
            dateTimeLabel.font = dateTimeLabelFont
        }
    }
    let defaultFont: UIFont = UIFont(name: "Lato-Regular", size: 14.0)!

    var titleLabel: UILabel = UILabel(frame: .zero)
    var sizeLabel: UILabel = UILabel(frame: .zero)
    var sharedByPlaceholder: UILabel = UILabel(frame: .zero)
    var extensionButton: UIButton = UIButton(frame: .zero)
    var sharedByLabel: UILabel = UILabel(frame: .zero)
    var dateTimeLabel: UILabel = UILabel(frame: .zero)
    var button: UIButton  = UIButton(frame: .zero)
    
    var maskLayer: CAShapeLayer!
    var borderLayer: CAShapeLayer!
    
    var textViewHeightConstraint: NSLayoutConstraint!
    var buttonHeightConstraint: NSLayoutConstraint!
    
    public var buttonAction: ((_ payload: KAButtonInfo?) -> Void)!
    
    // MARK: - init
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
    
    // MARK: - set up
    public func setup() {
        titleLabelFont = UIFont(name: "Lato-Bold", size: 14.0)
        titleLabel.numberOfLines = 1
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textAlignment = .left
        titleLabel.textColor = UIColor(hex: 0x262626)
        titleLabel.sizeToFit()
        titleLabel.setContentHuggingPriority(UILayoutPriority.defaultLow, for: .horizontal)
        titleLabel.setContentHuggingPriority(UILayoutPriority.defaultLow, for: .vertical)
        self.addSubview(titleLabel)

        sharedByLabelFont = UIFont(name: "Lato-Regular", size: 14.0)
        sharedByLabel.translatesAutoresizingMaskIntoConstraints = false
        sharedByLabel.font = sharedByLabelFont
        sharedByLabel.textColor = UIColor(hex: 0x1A1A1A)
        sharedByLabel.numberOfLines = 2
        sharedByLabel.lineBreakMode = .byTruncatingTail
        sharedByLabel.sizeToFit()
        self.addSubview(sharedByLabel)
        
        sizeLabelFont = UIFont(name: "Lato-Regular", size: 12.0)
        sizeLabel.textAlignment = .left
        sizeLabel.translatesAutoresizingMaskIntoConstraints = false
        sizeLabel.font = sizeLabelFont
        sizeLabel.textColor = UIColor(hex: 0x858585)
        sizeLabel.setContentHuggingPriority(UILayoutPriority.defaultHigh, for: .vertical)
        sizeLabel.sizeToFit()
        self.addSubview(sizeLabel)

        sharedByPlaceholder = UILabel(frame: .zero)
        sharedByPlaceholder.translatesAutoresizingMaskIntoConstraints = false
        sharedByPlaceholder.text = "Shared By"
        sharedByPlaceholder.textAlignment = .left
        sharedByPlaceholder.font = sizeLabelFont
        sharedByPlaceholder.textColor = UIColor(hex: 0x858585)
        sharedByPlaceholder.sizeToFit()
        self.addSubview(sharedByPlaceholder)
        
        extensionButton.setTitleColor(UIColor(hex: 0xD0021B), for: .normal)
        extensionButton.contentEdgeInsets = UIEdgeInsetsMake(0.0, 5.0, 0.0, 5.0)
        extensionButton.layer.cornerRadius = 5
        extensionButton.titleLabel?.textAlignment = .center
        extensionButton.layer.borderWidth = 1.5
        extensionButton.setContentHuggingPriority(UILayoutPriority.defaultHigh, for: .horizontal)
        extensionButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(extensionButton)
        
        dateTimeLabelFont = sizeLabelFont
        dateTimeLabel.font = dateTimeLabelFont
        dateTimeLabel.textColor = UIColor(hex: 0x858585)
        dateTimeLabel.numberOfLines = 0
        dateTimeLabel.textAlignment = .left
        dateTimeLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        dateTimeLabel.isUserInteractionEnabled = true
        dateTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(dateTimeLabel)

        buttonFont = UIFont(name: "HelveticaNeue-Medium", size: 15.0)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.borderWidth = 0.5
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.setTitleColor(UIColor(hex: 0x6168E7), for: .normal)
        button.titleLabel?.font = buttonFont
        button.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
        addSubview(button)

        let views: [String: UIView] = ["titleLabel": titleLabel, "sharedByLabel": sharedByLabel, "sizeLabel": sizeLabel, "dateTimeLabel": dateTimeLabel, "sharedByPlaceholder": sharedByPlaceholder, "button": button, "extensionButton": extensionButton]
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[extensionButton]-10-[titleLabel]-|", options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[extensionButton]-10-[sizeLabel]-|", options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[sharedByPlaceholder]-5-[sharedByLabel]-|", options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[dateTimeLabel]-|", options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[button]|", options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-14-[extensionButton(30)]", options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[titleLabel(19)]-(0)-[sizeLabel]-5-[sharedByPlaceholder]-2-[dateTimeLabel]-13-[button(48)]|", options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[sizeLabel]-5-[sharedByLabel]-3-[dateTimeLabel]-13-[button(48)]|", options: [], metrics: nil, views: views))
    }
    
    // MARK: - button action
    @objc func buttonAction(_ sender: UIButton) {
        if let buttons = driveFileObject?.buttons, buttons.count > 0 {
            let buttonInfo = buttons.first
            self.buttonAction?(buttonInfo)
        }
    }
    
    func getExpectedHeight(for object: KADriveFileInfo, width: CGFloat) -> CGFloat {
        var height: CGFloat = 0.0
        height += 10.0

        var attributedString: NSAttributedString = NSAttributedString(string: object.fileName ?? "", attributes: [NSAttributedStringKey.font: titleLabelFont ?? defaultFont])
        var limitingSize: CGSize = CGSize(width: width - 60.0, height: CGFloat.greatestFiniteMagnitude)
        var rect: CGRect = attributedString.boundingRect(with: limitingSize, options: NSStringDrawingOptions.usesLineFragmentOrigin, context: nil)
        height += rect.height
        
        if let value = object.fileSize, let fileSize = UInt64(value) {
            attributedString = NSAttributedString(string: String(format: "\(getFileSize(with: fileSize))"), attributes: [NSAttributedStringKey.font: sizeLabelFont ?? defaultFont])
        } else {
            attributedString = NSAttributedString(string: " ", attributes: [NSAttributedStringKey.font: sizeLabelFont ?? defaultFont])
        }

        rect = attributedString.boundingRect(with: limitingSize, options: NSStringDrawingOptions.usesLineFragmentOrigin, context: nil)
        height += rect.height
        
        attributedString = NSAttributedString(string: object.sharedBy ?? "", attributes: [NSAttributedStringKey.font: sizeLabelFont ?? defaultFont])
        limitingSize = CGSize(width: width - 87.0, height: CGFloat.greatestFiniteMagnitude)
        rect = attributedString.boundingRect(with: limitingSize, options: NSStringDrawingOptions.usesLineFragmentOrigin, context: nil)
        height += rect.height
        height += 5.0
        
        let formatter = DateFormatter.yyyyMMdd
        if let dateString  = object.lastModified, let date = formatter.date(from: dateString) {
            let text = "Last edited " + date.formattedAsAgo()
            attributedString = NSAttributedString(string: text, attributes: [NSAttributedStringKey.font: sizeLabelFont ?? defaultFont])
            limitingSize = CGSize(width: width - 20.0, height: CGFloat.greatestFiniteMagnitude)
            rect = attributedString.boundingRect(with: limitingSize, options: NSStringDrawingOptions.usesLineFragmentOrigin, context: nil)
            height += rect.height
            height += 16.0
        }

        if let buttonsCount = object.buttons?.count {
            let count: Int = min(buttonsCount, KADriveFileView.buttonLimit)
            height += kMaxRowHeight * CGFloat(count)
        }
        return max(kMaxHeight, height)
    }
    
    public func configure(with object: KADriveFileInfo) {
        titleLabel.text = object.fileName ?? "".addingPercentEncoding(withAllowedCharacters: .controlCharacters)
        sharedByLabel.text = object.sharedBy ?? ""
        var fileType = "***"
        if let fileExtension = object.fileType {
            fileType = fileExtension.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        }
        
        let extensionButtonFont = UIFont(withFileType: fileType)
        extensionButton.setTitle(fileType, for: .normal)
        extensionButton.titleLabel?.font = extensionButtonFont
        
        let extensionButtonColor = UIColor(withFileType: fileType)
        extensionButton.setTitleColor(extensionButtonColor, for: .normal)
        extensionButton.layer.borderColor = extensionButtonColor.cgColor

        if let value = object.fileSize, let fileSize = UInt64(value) {
            sizeLabel.text = getFileSize(with: fileSize)
        } else {
            sizeLabel.text = String(format: " ")
        }
        
        let formatter = DateFormatter.yyyyMMdd
        if let dateString  = object.lastModified, let date = formatter.date(from: dateString) {
            dateTimeLabel.text = "Last edited " + date.formattedAsAgo()
        }
        if let buttons = driveFileObject?.buttons, buttons.count > 0, let title = buttons.first?.title {
            button.setTitle(title, for: .normal)
        }
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
    
    // MARK: -
    func getFileSize(with size: UInt64) -> String {
        return ByteCountFormatter.string(fromByteCount: Int64(size), countStyle: ByteCountFormatter.CountStyle.file)
    }
}

public class KADriveFileCollectionViewCell: UICollectionViewCell {
    // MARK: - properties
    public static let cellReuseIdentifier: String = "KADriveFileCollectionViewCell"
    public var cardView: KADriveFileView!
    
    // MARK: - init
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
        
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.withAlphaComponent(0.5).cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowRadius = 0.5
        
        cardView = KADriveFileView(frame: CGRect.init(origin: CGPoint.zero, size: frame.size))
        contentView.addSubview(cardView)
        
        let views: [String: UIView] = ["cardView": cardView]
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[cardView]|", options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[cardView]|", options: [], metrics: nil, views: views))
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public class KADriveFilesHeaderView: UICollectionReusableView {
    // MARK: - properties
    var label: UILabel = UILabel(frame: .zero)
    
    // MARK: - init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "View"
        addSubview(label)
        
        let views: [String: UIView] = ["label": label]
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[label]|", options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[label]|", options: [], metrics: nil, views: views))
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension KADriveFileView {
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
