//
//  KREDriveFile.swift
//  KoreBotSDK
//
//  Created by Srinivas Vasadi on 13/03/19.
//  Copyright © 2019 Srinivas Vasadi. All rights reserved.
//

import UIKit
import AlamofireImage

public class KREDriveFileInfo: NSObject, Decodable {
    public var fileId: String?
    public var fileExtn: String?
    public var title: String?
    public var fileType: String?
    public var fileSize: String?
    public var icon: String?
    public var iconLink: String?
    public var sharedBy: String?
    public var name: String?
    public var lastModified: String?
    public var webViewLink: String?
    public var fileName: String?
    public var defaultAction: KREAction?
    public var owners: [KREDriveFilePermission]?
    
    enum DriveFileInfoKeys: String, CodingKey {
        case fileId = "fileId"
        case data = "data"
        case iconId = "iconId"
        case icon = "icon"
        case sharedBy = "sub_title"
        case defaultAction = "default_action"
        case fileName = "title"
    }
    
    enum DataKeys: String, CodingKey {
        case fileId = "fileId"
        case iconLink = "iconLink"
        case icon = "icon"
        case fileSize = "size"
        case fileType = "ext"
        case defaultAction = "default_action"
        case lastModified = "modifiedTime"
        case name = "displayName"
        case owners = "owners"
        case webViewLink = "webViewLink"
    }

    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DriveFileInfoKeys.self)
        fileId = try? container.decode(String.self, forKey: .fileId)
        sharedBy = try? container.decode(String.self, forKey: .sharedBy)
        icon = try? container.decode(String.self, forKey: .icon)
        defaultAction = try? container.decode(KREAction.self, forKey: .defaultAction)
        fileName = try? container.decode(String.self, forKey: .fileName)
        
        if let dataContainer = try? container.nestedContainer(keyedBy: DataKeys.self, forKey: .data) {
            iconLink = try? dataContainer.decode(String.self, forKey: .iconLink)
            fileSize = try? dataContainer.decode(String.self, forKey: .fileSize)
            fileType = try? dataContainer.decode(String.self, forKey: .fileType)
            lastModified = try? dataContainer.decode(String.self, forKey: .lastModified)
            name = try? dataContainer.decode(String.self, forKey: .name)
            owners = try? dataContainer.decode([KREDriveFilePermission].self, forKey: .owners)
            webViewLink = try? dataContainer.decode(String.self, forKey: .webViewLink)
        }
    }
}

// MARK: - KREDriveFilePermission
public class KREDriveFilePermission: NSObject, Decodable {
    public var displayName: String?
    public var emailAddress: String?
    public var kind: String?
    public var me: Int?
    public var permissionId: String?
    
    public enum ActionKeys: String, CodingKey {
        case displayName = "displayName"
        case emailAddress = "emailAddress"
        case kind = "kind"
        case me = "me"
        case permissionId = "permissionId"
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ActionKeys.self)
        displayName = try? container.decode(String.self, forKey: .displayName)
        emailAddress = try? container.decode(String.self, forKey: .emailAddress)
        kind = try? container.decode(String.self, forKey: .kind)
        me = try? container.decode(Int.self, forKey: .me)
        permissionId = try? container.decode(String.self, forKey: .permissionId)
    }
}


// MARK:- KADriveFileView
@available(iOS 8.2, *)
public class KREDriveFileView: UIView, UIGestureRecognizerDelegate {
    // MARK: - properties
    let bundle = Bundle(for: KREDriveFileView.self)
    let kMaxRowHeight: CGFloat = 48.0
    let kMaxHeight: CGFloat = 153.0
    static let buttonLimit: Int = 1
    var isFirst: Bool = false
    var isLast: Bool = false
    var urlString: String!
    open var driveFileObject: KREDriveFileInfo?
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
    lazy var stackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.axis = .vertical
        stackView.backgroundColor = .clear
        stackView.distribution = UIStackView.Distribution.equalCentering
        stackView.alignment = UIStackView.Alignment.fill
        stackView.spacing = 8.0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    lazy var titleLabel: UILabel = {
        let titleLabel = UILabel(frame: .zero)
        titleLabel.textColor = UIColor(hex: 0x485260)
        titleLabel.backgroundColor = .clear
        titleLabel.font = UIFont.textFont(ofSize: 16.0, weight: .medium)
        titleLabel.textAlignment = .left
        return titleLabel
    }()
    lazy var sizeLabel: UILabel = {
        let sizeLabel = UILabel(frame: .zero)
        sizeLabel.translatesAutoresizingMaskIntoConstraints = false
        sizeLabel.textColor = UIColor(hex: 0xa7b0be)
        sizeLabel.backgroundColor = .clear
        sizeLabel.font = UIFont.textFont(ofSize: 13.0, weight: .medium)
        sizeLabel.textAlignment = .left
        return sizeLabel
    }()
    lazy var fileImageView: UIImageView = {
        let fileImageView = UIImageView(frame: .zero)
        fileImageView.translatesAutoresizingMaskIntoConstraints = false
        return fileImageView
    }()
    lazy var sharedByPlaceholder: UILabel = {
        let sharedByPlaceholder = UILabel(frame: .zero)
        sharedByPlaceholder.translatesAutoresizingMaskIntoConstraints = false
        return sharedByPlaceholder
    }()
    lazy var extensionButton: UIButton = {
        let extensionButton  = UIButton(frame: .zero)
        extensionButton.translatesAutoresizingMaskIntoConstraints = false
        return extensionButton
    }()
    lazy var sharedByLabel: UILabel = {
        let sharedByLabel = UILabel(frame: .zero)
        sharedByLabel.translatesAutoresizingMaskIntoConstraints = false
        return sharedByLabel
    }()
    lazy var dateTimeLabel: UILabel = {
        let dateTimeLabel = UILabel(frame: .zero)
        dateTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        dateTimeLabel.textColor = UIColor(hex: 0xa7b0be)
        dateTimeLabel.backgroundColor = .clear
        dateTimeLabel.font = UIFont.textFont(ofSize: 13.0, weight: .medium)
        dateTimeLabel.textAlignment = .left
        return dateTimeLabel
    }()
    lazy var button: UIButton = {
        let button  = UIButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
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
//        if let buttons = driveFileObject?.buttons, buttons.count > 0 {
//            let buttonInfo = buttons.first
//            self.buttonAction?(buttonInfo)
//        }
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
        
        var text: String?
        let formatter = DateFormatter.yyyyMMdd
        let subheader = NSLocalizedString("Last edited ", comment: "Last edited ")
        if let dateString = object.lastModified, let date = DateFormatter.yyyyMMdd.date(from: dateString) {
            text = subheader + date.formatAsDayDate(using: date)
        } else if let dateString = object.lastModified, let date = DateFormatter.yyyyMMddTHHmmssZ.date(from: dateString) {
            dateTimeLabel.text = subheader + date.formatAsDayDate(using: date)
        }

        if let text = text {
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
    
    public func configure(with object: KREDriveFileInfo) {
        titleLabel.text = object.fileName ?? "".addingPercentEncoding(withAllowedCharacters: .controlCharacters)
        var fileType = "***"
        if let urlString = object.fileType, let url = URL(string: urlString) {
            fileImageView.af.setImage(withURL: url, placeholderImage: UIImage(named: "file_general"))
        }
        if let fileExtension = object.fileType {
            fileType = fileExtension.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
            fileImageView.image = getFileImage(fileType: fileType)
        }
        
        let extensionButtonFont = UIFont.font(withFileType: fileType)
        let extensionButtonColor = UIColor(withFileType: fileType)
        if let sharedBy = object.sharedBy?.trimmingCharacters(in: .whitespacesAndNewlines), sharedBy.count > 0 {
            sizeLabel.text = sharedBy
        }
        
        let subheader = NSLocalizedString("Last edited ", comment: "Last edited ")
        if let dateString = object.lastModified, let date = DateFormatter.yyyyMMdd.date(from: dateString) {
            dateTimeLabel.text = subheader + date.formatAsDayDate(using: date)
        } else if let dateString = object.lastModified, let date = DateFormatter.yyyyMMddTHHmmssZ.date(from: dateString) {
            dateTimeLabel.text = subheader + date.formatAsDayDate(using: date)
        }
    }
  
    func convertUTCtoDateStr(_ dateTime: Date) -> String {
        let dateStr = dateTime.formatAsDayShortDate(using: dateTime)
        let dateTomorrowStr = Date().formatAsDayShortDate(using: Date().tomorrow)
        let dateYesterdayStr = Date().formatAsDayShortDate(using: Date().yesterday)
        let dateTodayStr = Date().formatAsDayShortDate(using: Date())
        if dateStr == dateTomorrowStr {
            return "Tomorrow"
        } else if dateStr == dateTodayStr {
            return "Today"
        }
        else if dateStr == dateYesterdayStr {
            return "Yesterday"
        }
        return dateStr
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
        super.layoutSubviews()
    }
    
    public func prepareForReuse() {
        titleLabel.text = nil
        sizeLabel.text = nil
        fileImageView.image = nil
        sharedByPlaceholder.text = nil
        sharedByLabel.text = nil
        dateTimeLabel.text = nil
    }
    
    // MARK: -
    func getFileSize(with size: UInt64) -> String {
        return ByteCountFormatter.string(fromByteCount: Int64(size), countStyle: ByteCountFormatter.CountStyle.file)
    }
    
    func setupVertical() {
        addSubview(stackView)
        addSubview(fileImageView)
        
        let views: [String: Any] = ["stackView": stackView, "fileImageView": fileImageView]
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-8-[stackView(>=42)]-15-|", options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[fileImageView(36)]-15-[stackView]-16-|", options: [], metrics: nil, views: views))
        fileImageView.heightAnchor.constraint(equalToConstant: 42.0).isActive = true
        fileImageView.centerYAnchor.constraint(equalTo: stackView.centerYAnchor).isActive = true
        
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(sizeLabel)
        stackView.addArrangedSubview(dateTimeLabel)
        
        if #available(iOS 11.0, *) {
            stackView.setCustomSpacing(8.0, after: titleLabel)
            stackView.setCustomSpacing(5.0, after: sizeLabel)
        } else {
            stackView.spacing = 5.0
        }
    }
}
