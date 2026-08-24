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
public class KADriveFileInfo: NSObject, Decodable, Encodable {
    var fileId: String?
    var fileName: String?
    var fileSize: String?
   public var fileType: String?
    var iconLink: String?
    var sharedBy: String?
    var thumbnailLink: String?
    var lastModified: String?
    public var buttons: [KAButtonInfo]?

    enum CodingKeys: String, CodingKey {
        case fileId, fileName, iconLink, sharedBy, thumbnailLink, fileSize, fileType, buttons, lastModified
    }

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

    required public init(from decoder: Decoder) throws {
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
@available(iOS 8.2, *)
public class KADriveFileView: UIView, UIGestureRecognizerDelegate {
    // MARK: - properties
    let bundle = Bundle.sdkModule
    let kMaxRowHeight: CGFloat = 48.0
    let kMaxHeight: CGFloat = 153.0
    static let buttonLimit: Int = 1
    var isFirst: Bool = false
    var isLast: Bool = false
    var urlString: String!
    open var driveFileObject: KADriveFileInfo?
    public var userIntent:((_ action: Any?) -> Void)?
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
    let defaultFont: UIFont = UIFont.textFont(ofSize: 14.0, weight: .regular)

    var titleLabel: UILabel = UILabel(frame: .zero)
    var sizeLabel: UILabel = UILabel(frame: .zero)
    var fileImageView: UIImageView = UIImageView(frame: .zero)
    var sharedByPlaceholder: UILabel = UILabel(frame: .zero)
    var extensionButton: UIButton = UIButton(frame: .zero)
    var sharedByLabel: UILabel = UILabel(frame: .zero)
    var dateTimeLabel: UILabel = UILabel(frame: .zero)
    var button: UIButton = UIButton(frame: .zero)
    
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
        setupVertical()
    }
    
    convenience init () {
        self.init(frame: CGRect.zero)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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

        var attributedString: NSAttributedString = NSAttributedString(string: object.fileName ?? "", attributes: [NSAttributedString.Key.font: titleLabelFont ?? defaultFont])
        var limitingSize: CGSize = CGSize(width: width - 60.0, height: CGFloat.greatestFiniteMagnitude)
        var rect: CGRect = attributedString.boundingRect(with: limitingSize, options: NSStringDrawingOptions.usesLineFragmentOrigin, context: nil)
        height += rect.height
        
        if let value = object.fileSize, let fileSize = UInt64(value) {
            attributedString = NSAttributedString(string: String(format: "\(getFileSize(with: fileSize))"), attributes: [NSAttributedString.Key.font: sizeLabelFont ?? defaultFont])
        } else {
            attributedString = NSAttributedString(string: " ", attributes: [NSAttributedString.Key.font: sizeLabelFont ?? defaultFont])
        }

        rect = attributedString.boundingRect(with: limitingSize, options: NSStringDrawingOptions.usesLineFragmentOrigin, context: nil)
        height += rect.height
        
        attributedString = NSAttributedString(string: object.sharedBy ?? "", attributes: [NSAttributedString.Key.font: sizeLabelFont ?? defaultFont])
        limitingSize = CGSize(width: width - 87.0, height: CGFloat.greatestFiniteMagnitude)
        rect = attributedString.boundingRect(with: limitingSize, options: NSStringDrawingOptions.usesLineFragmentOrigin, context: nil)
        height += rect.height
        height += 5.0
        
        let formatter = DateFormatter.yyyyMMdd
        if let dateString  = object.lastModified, let date = formatter.date(from: dateString) {
            let text = "Last edited " + date.formattedAsAgo()
            attributedString = NSAttributedString(string: text, attributes: [NSAttributedString.Key.font: sizeLabelFont ?? defaultFont])
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
        var fileType = "***"
        if let fileExtension = object.fileType {
            fileType = fileExtension.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        }
        
        fileImageView.image = getFileImage(fileType: fileType)

        let extensionButtonFont = UIFont.font(withFileType: fileType)
        let extensionButtonColor = UIColor(withFileType: fileType)
        if let sharedBy = object.sharedBy {
            sizeLabel.text = "Shared by \(sharedBy)"
        }

        let subheader = NSLocalizedString("Last edited ", comment: "Last edited ")
        if let dateString = object.lastModified, let date = DateFormatter.yyyyMMdd.date(from: dateString) {
            dateTimeLabel.text =  subheader + date.formatAsDayDate(using: date)
        } else if let dateString = object.lastModified, let date = DateFormatter.yyyyMMddTHHmmssZ.date(from: dateString) {
            dateTimeLabel.text = subheader + date.formatAsDayDate(using: date)
        }
    }
    
    func getFileImage(fileType: String) -> UIImage? {
        switch fileType.uppercased() {
        case "GIF", "ICO", "DDS", "HEIC", "JPG", "PNG", "PSD", "PSPIMAGE","TGA","THM","TIF","TIFF","BMP","YUV":// Raster Image Files
            return UIImage(named: "raster_image", in: bundle, compatibleWith: nil)
        case "PAGES", "LOG", "MSG", "ODT", "RTF", "TEX", "TXT", "WPD", "WPS", "GDOCS", "GDOC"://Text Files
            return UIImage(named: "documents", in: bundle, compatibleWith: nil)
        case "DOCX", "DOC":
            return UIImage(named: "word", in: bundle, compatibleWith: nil)
        case "XLR", "CSV", "ODS","GSHEET"://SpreadSheeet Files
            return UIImage(named: "sheet", in: bundle, compatibleWith: nil)
        case "XLSX", "XLS"://SpreadSheeet Files
                return UIImage(named: "excel", in: bundle, compatibleWith: nil)
        case "PPS", "KEY", "GED", "ODP", "GSLIDE"://Presentation Files
            return UIImage(named: "slides", in: bundle, compatibleWith: nil)
        case "PPT", "PPTX":
            return UIImage(named: "powerPoint", in: bundle, compatibleWith: nil)
        case "PDF":
            return UIImage(named: "pdf", in: bundle, compatibleWith: nil)
        case "MP3", "WAV", "AIF", "IFF", "M3U", "M4A", "MID", "WMA", "MPA":// Audio Files
            return UIImage(named: "music", in: bundle, compatibleWith: nil)
        case "3G2", "3GP", "ASF", "AVI", "FLV", "M4V", "MOV", "MP4", "MPG", "RM", "SRT", "SWF", "VOB", "WMV": //Video Files
            return UIImage(named: "video", in: bundle, compatibleWith: nil)
        case "3DM", "3DS", "MAX", "OBJ": //3d image files
            return UIImage(named: "3dobject", in: bundle, compatibleWith: nil)
        case "AI", "EPS", "PS", "SVG": //Vector image files
            return UIImage(named: "file_general", in: bundle, compatibleWith: nil)
        case "SKETCH":
            return UIImage(named: "sketch", in: bundle, compatibleWith: nil)
        case "ZIP":
            return UIImage(named: "zip", in: bundle, compatibleWith: nil)
        default:
            return UIImage(named: "file_general", in: bundle, compatibleWith: nil)
        }
    }
    
    public func updateLayer() {

    }
    
    override public func layoutSubviews() {
//        textViewHeightConstraint.constant = 10.0
        super.layoutSubviews()
    }
        
    public func prepareForReuse() {
        
    }
    
    // MARK: -
    func getFileSize(with size: UInt64) -> String {
        return ByteCountFormatter.string(fromByteCount: Int64(size), countStyle: ByteCountFormatter.CountStyle.file)
    }
    
    func setupVertical() {
        titleLabel.textColor = UIColor(hex: 0x485260)
        titleLabel.backgroundColor = .clear
        titleLabel.font = UIFont.textFont(ofSize: 16.0, weight: .medium)
        titleLabel.textAlignment = .left
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        
        sizeLabel.textColor = UIColor(hex: 0xa7b0be)
        sizeLabel.backgroundColor = .clear
        sizeLabel.font = UIFont.textFont(ofSize: 13.0, weight: .medium)
        sizeLabel.textAlignment = .left
        sizeLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(sizeLabel)
        
        dateTimeLabel.textColor = UIColor(hex: 0xa7b0be)
        dateTimeLabel.backgroundColor = .clear
        dateTimeLabel.font = UIFont.textFont(ofSize: 13.0, weight: .medium)
        dateTimeLabel.textAlignment = .left
        dateTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(dateTimeLabel)

        fileImageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(fileImageView)
        
        
        
        let views: [String: Any] = ["titleLabel": titleLabel, "sizeLabel": sizeLabel, "dateTimeLabel": dateTimeLabel, "fileImageView": fileImageView]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-8-[titleLabel]-8-[sizeLabel]-5-[dateTimeLabel]-15-|", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-14-[fileImageView(42)]", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[fileImageView(36)]", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-66-[titleLabel]-16-|", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-66-[sizeLabel]-16-|", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-66-[dateTimeLabel]-16-|", options: [], metrics: nil, views: views))
    }
    
}

@available(iOS 8.2, *)
public class KADriveFileCollectionViewCell: UICollectionViewCell {
    // MARK: - properties
    public static let cellReuseIdentifier: String = "KADriveFileCollectionViewCell"
    public var cardView: KADriveFileView!
    
    // MARK: - init
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
        
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

@available(iOS 8.2, *)
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
