//
//  KREKnowledgeCollectionTemplateView.swift
//  KoreBotSDK
//
//  Created by Srinivas Vasadi on 07/01/2020.
//  Copyright © 2019 Srinivas Vasadi. All rights reserved.
//

import UIKit

public class KREDriveFileTemplateView: UIView {
    // MARK: - properties
    let bundle = Bundle.sdkModule
    public lazy var titleLabel: UILabel = {
        let titleLabel = UILabel(frame: .zero)
        titleLabel.textColor = UIColor(hex: 0x485260)
        titleLabel.backgroundColor = .clear
        titleLabel.font = UIFont.textFont(ofSize: 16.0, weight: .medium)
        titleLabel.textAlignment = .left
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }()
    
    public lazy var sizeLabel: UILabel = {
        let sizeLabel = UILabel(frame: .zero)
        sizeLabel.textColor = UIColor(hex: 0xa7b0be)
        sizeLabel.backgroundColor = .clear
        sizeLabel.font = UIFont.textFont(ofSize: 13.0, weight: .medium)
        sizeLabel.textAlignment = .left
        sizeLabel.translatesAutoresizingMaskIntoConstraints = false
        return sizeLabel
    }()
    
    public lazy var fileImageView: UIImageView = {
        let fileImageView = UIImageView(frame: .zero)
        fileImageView.translatesAutoresizingMaskIntoConstraints = false
        return fileImageView
    }()
    
    public lazy var dateTimeLabel: UILabel = {
        let dateTimeLabel = UILabel(frame: .zero)
        dateTimeLabel.textColor = UIColor(hex: 0xa7b0be)
        dateTimeLabel.backgroundColor = .clear
        dateTimeLabel.font = UIFont.textFont(ofSize: 13.0, weight: .medium)
        dateTimeLabel.textAlignment = .left
        dateTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        return dateTimeLabel
    }()
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.backgroundColor = .clear
        stackView.distribution = .equalSpacing
        stackView.alignment = .fill
        stackView.spacing = 0.0
        return stackView
    }()
    
    lazy var horizontalStackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .top
        stackView.distribution = .fillProportionally
        stackView.spacing = 15.0
        return stackView
    }()
    
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
    
    var dateTimeLabelFont: UIFont? {
        didSet {
            dateTimeLabel.font = dateTimeLabelFont
        }
    }
            
    // MARK: - init
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    // MARK: - setup
    public func setup() {
        fileImageView.heightAnchor.constraint(equalToConstant: 42.0).isActive = true
        fileImageView.widthAnchor.constraint(equalToConstant: 36.0).isActive = true
        horizontalStackView.addArrangedSubview(fileImageView)

        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(sizeLabel)
        stackView.addArrangedSubview(dateTimeLabel)
        horizontalStackView.addArrangedSubview(stackView)
        addSubview(horizontalStackView)
        
        if #available(iOS 11.0, *) {
            stackView.setCustomSpacing(8.0, after: titleLabel)
            stackView.setCustomSpacing(5.0, after: sizeLabel)
            stackView.setCustomSpacing(7.0, after: dateTimeLabel)
        }
        
        let views = ["stackView": horizontalStackView]
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-13-[stackView]-13-|", options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[stackView]-|", options: [], metrics: nil, views: views))
    }
    
    // MARK: -
    func populateTemplateView(_ knowledgeCollectionItem: Decodable?) {
        guard let driveFileInfo = knowledgeCollectionItem as? KADriveFileInfo else {
            return
        }
    }
    
    // MARK: - button action
    public func populateTemplateView(_ object: KADriveFileInfo) {
        titleLabel.text = object.fileName ?? "".addingPercentEncoding(withAllowedCharacters: .controlCharacters)
        var fileType = "***"
        if let fileExtension = object.fileType {
            fileType = fileExtension.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        }
        
        let image = getFileImage(fileType: fileType)
        fileImageView.image = image
        if let sharedBy = object.sharedBy {
            sizeLabel.text = "Shared by \(sharedBy)"
        }

        let formatter = DateFormatter.yyyyMMdd
        let isoFormatter = DateFormatter.yyyyMMddTHHmmssZ
        if let dateString = object.lastModified, let date = formatter.date(from: dateString) {
            dateTimeLabel.text = "Last edited " + date.formatAsDayDate(using: date)
        } else if let dateString = object.lastModified, let date = isoFormatter.date(from: dateString) {
            dateTimeLabel.text = "Last edited " + date.formatAsDayDate(using: date)
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
    
    // MARK: -
    func getFileSize(with size: UInt64) -> String {
        return ByteCountFormatter.string(fromByteCount: Int64(size), countStyle: ByteCountFormatter.CountStyle.file)
    }
}
