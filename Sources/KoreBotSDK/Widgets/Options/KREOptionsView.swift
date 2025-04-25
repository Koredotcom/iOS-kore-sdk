//
//  KREOptionsView.swift
//  Widgets
//
//  Created by developer@kore.com on 24/11/16.
//  Copyright © 2016 Kore Inc. All rights reserved.
//

import UIKit
import AlamofireImage

public enum KREActionType : Int {
    case none = 0, webURL = 1, postback = 2, user_intent = 3, postback_disp_payload = 4
}

public class KREAction: NSObject, Decodable, Encodable {
    public var actionType: KREActionType?
    public var type: String?
    public var title: String?
    public var payload: String?
    public var customData: [String: Any]?
    public var action: String?
    public var utterance: String?
    public var url: String?
    public var dial: String?
    public var iconId: String?
    public var elementId = ""
    public var activityInfo: KREActivityInfo?

    // MARK: - init
    public override init() {
        super.init()
    }
    
    public init(actionType: KREActionType, title: String, payload: String) {
        super.init()
        self.actionType = actionType
        self.title = title
        self.payload = payload
    }
    
    public init(actionType: KREActionType, title: String, customData: [String: Any]) {
        super.init()
        self.actionType = actionType
        self.title = title
        self.customData = customData
    }
    
    enum CodingKeys: String, CodingKey {
        case payload, title, type, utterance, url, iconId, activityInfo, dial
    }

    required public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        title = try? values.decode(String.self, forKey: .title)
//        do {
//            let val = try values.decode(Int.self, forKey: .payload)
//            payload = String(val)
//        } catch DecodingError.typeMismatch {
//            payload = try? values.decode(String.self, forKey: .payload)
//        }
        
        
        if let valueInteger = try? values.decodeIfPresent(Int.self, forKey: .payload) {
               payload = String(valueInteger ?? -00)
            if payload == "-00"{
                payload = ""
            }
        } else if let valueString = try? values.decodeIfPresent(String.self, forKey: .payload) {
               payload = valueString
        }
        
        
        type = try? values.decode(String.self, forKey: .type)
        utterance = try? values.decode(String.self, forKey: .utterance)
        url = try? values.decode(String.self, forKey: .url)
        iconId = try? values.decode(String.self, forKey: .iconId)
        activityInfo = try? values.decode(KREActivityInfo.self, forKey: .activityInfo)
        dial = try? values.decode(String.self, forKey: .dial)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: .title)
        try container.encode(payload, forKey: .payload)
        try container.encode(type, forKey: .type)
    }
}

public enum KREOptionType : Int {
    case button = 1, list = 2, menu = 3
}

open class KREOption: NSObject {
    static let titleCharLimit: Int = 80
    static let subtitleCharLimit: Int = 100
    
    // MARK:- properties
    var title: String?
    var subTitle: String?
    var imageURL:String?
    var optionType: KREOptionType?
    
    var defaultAction:KREAction?
    var buttonAction:KREAction?

    // MARK:- init
    public override init() {
        super.init()
    }
    
    public init(title: String, subTitle: String, imageURL: String, optionType: KREOptionType) {
        super.init()
        self.title = truncateString(title, count: KREOption.titleCharLimit)
        self.subTitle = subTitle //truncateString(subTitle, count: KREOption.subtitleCharLimit)
        self.imageURL = imageURL
        self.optionType = optionType
    }
    
    public func setDefaultAction(action: KREAction) {
        self.defaultAction = action
    }
    
    public func setButtonAction(action: KREAction) {
        self.buttonAction = action
    }
    
    func truncateString(_ string: String, count: Int) -> String{
        var tmpString = string
        if(tmpString.count > count){
            tmpString = tmpString.substring(to: tmpString.index(tmpString.startIndex, offsetBy: count))
        }
        return tmpString
    }
}

open class KREOptionsView: UIView, UITableViewDataSource, UITableViewDelegate {
    let bundle = Bundle.sdkModule
    fileprivate let optionCellIdentifier = "KREOptionsTableViewCell"
    fileprivate let listCellIdentifier = "KREListTableViewCell"
    
    let kMaxRowHeight: CGFloat = 44
  
    public var optionsButtonAction: ((_ title: String?, _ payload: String?) -> Void)!
    public var detailLinkAction: ((_ text: String?) -> Void)!
    public var userIntentAction: ((_ title: String?, _ customData: [String: Any]?) -> Void)!

    // MARK:- properites
    public var options: Array<KREOption> = Array<KREOption>() {
        didSet {
            self.optionsTableView.reloadData()
        }
    }

    // MARK:- init
    override init (frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    convenience init () {
        self.init(frame:CGRect.zero)
    }
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("This class does not support NSCoding")
    }
    
    // MARK:- table view
    public let optionsTableView: UITableView = {
        let optionsView = UITableView(frame: CGRect.zero, style: .plain)
        optionsView.translatesAutoresizingMaskIntoConstraints = false
        optionsView.showsVerticalScrollIndicator = false
        optionsView.showsHorizontalScrollIndicator = false
        optionsView.isScrollEnabled = false
        optionsView.estimatedRowHeight = UITableView.automaticDimension
        optionsView.rowHeight = UITableView.automaticDimension
        optionsView.separatorStyle = UITableViewCell.SeparatorStyle.singleLine
        optionsView.separatorInset = .zero
        optionsView.separatorColor = UIColor.paleLilacFour
        optionsView.setNeedsLayout()
        optionsView.layoutIfNeeded()
        optionsView.separatorColor = .white
        return optionsView
    }()
    
    // MARK:- setup collectionView
    public func setup() {
        optionsTableView.register(Bundle.xib(named: "KREListTableViewCell"), forCellReuseIdentifier: "KREListTableViewCell")
        optionsTableView.register(Bundle.xib(named: "KREOptionsTableViewCell"), forCellReuseIdentifier: "KREOptionsTableViewCell")
        addSubview(optionsTableView)
        
        let views = ["tableView": optionsTableView]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[tableView]|", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[tableView]|", options: [], metrics: nil, views: views))
        
        optionsTableView.delegate = self
        optionsTableView.dataSource = self

        optionsTableView.reloadData()
    }
    
    // MARK: - Table view data source
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let option: KREOption = options[indexPath.row]
        
        if(option.optionType == KREOptionType.button){
            let cell = tableView.dequeueReusableCell(withIdentifier: optionCellIdentifier, for: indexPath)
            if let cell = cell as? KREOptionsTableViewCell {
                cell.selectionStyle = UITableViewCell.SelectionStyle.none
                cell.textLabel?.text = option.title
                cell.textLabel?.textAlignment = .center
                cell.textLabel?.textColor = bubbleViewBotChatButtonTextColor
                cell.backgroundColor = bubbleViewBotChatButtonBgColor
                if #available(iOS 8.2, *) {
                    cell.textLabel?.font = UIFont.textFont(ofSize: 16.0, weight: .regular)
                }
            }
            
            return cell
        }else if(option.optionType == KREOptionType.list){
            let cell:KREListTableViewCell = tableView.dequeueReusableCell(withIdentifier: listCellIdentifier, for: indexPath) as! KREListTableViewCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            
            cell.titleLabel.text = option.title
            cell.titleLabel.font  = UIFont(name: mediumCustomFont, size: 15.0)
            //cell.subTitleLabel.text = option.subTitle
            cell.subTitleLabel.setHTMLString(option.subTitle, withWidth: BubbleViewMaxWidth - 20.0)
            cell.subTitleLabel.font  = UIFont(name: mediumCustomFont, size: 14.0)
            cell.subTitleLabel.numberOfLines = 15
            if let urlString = option.imageURL, let url = URL(string: urlString) {
                cell.imgView.af.setImage(withURL: url, placeholderImage: UIImage(named: "placeholder_image"))
                cell.imgViewWidthConstraint.constant = 60.0
            } else {
                cell.imageView?.image = nil
                cell.imgViewWidthConstraint.constant = 0.0
            }
            cell.titleLabel.textColor = BubbleViewBotChatTextColor
            cell.subTitleLabel.textColor = BubbleViewBotChatTextColor
            if(option.buttonAction != nil){
                let buttonAction = option.buttonAction
                cell.actionButtonHeightConstraint.constant = 30.0
                cell.actionButton.setTitle(buttonAction?.title, for: .normal)
                cell.buttonAction = {[weak self] (text) in
                    if (buttonAction?.actionType == .webURL) {
                        if ((self?.detailLinkAction) != nil) {
                            self?.detailLinkAction(buttonAction?.payload)
                        }
                    } else if (buttonAction?.actionType == .postback || buttonAction?.actionType == .postback_disp_payload) {
                        if (self?.optionsButtonAction != nil) {
                            self?.optionsButtonAction(buttonAction?.title, buttonAction?.payload)
                        }
                    }
                }
            }else{
                cell.actionButtonHeightConstraint.constant = 0.0
                cell.actionButton.setTitle(nil, for: .normal)
            }
            
            return cell
        }
        return UITableViewCell.init()
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let option: KREOption = options[indexPath.row]
        if option.title?.lowercased() == "learn more"{
            let defaultAction = option.defaultAction
            if ((self.detailLinkAction) != nil) {
                self.detailLinkAction(defaultAction?.payload)
                return
            }
        } else if option.title?.lowercased() == "request for upgrade" || option.title?.lowercased() == "upgrade"{
            self.userIntentAction(option.title, [:])
            return
        }
        
        if(option.defaultAction != nil){
            let defaultAction = option.defaultAction
            if (defaultAction?.actionType == .webURL) {
                if ((self.detailLinkAction) != nil) {
                    self.detailLinkAction(defaultAction?.payload)
                }
            } else if (defaultAction?.actionType == .postback || defaultAction?.actionType == .postback_disp_payload) {
                if (self.optionsButtonAction != nil) {
                    self.optionsButtonAction(defaultAction?.title, defaultAction?.payload)
                }
            }else if(defaultAction?.actionType == .user_intent ){
                if (self.userIntentAction != nil) {
                    self.userIntentAction(defaultAction?.action, defaultAction?.customData)
                }
            }
        }
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    public func getExpectedHeight(width: CGFloat) -> CGFloat {
        var height: CGFloat = 0.0
        for option in options  {
            if(option.optionType == KREOptionType.button){
                height += kMaxRowHeight
            }else if(option.optionType == KREOptionType.list){
                let cell:KREListTableViewCell = self.tableView(optionsTableView, cellForRowAt: IndexPath(row: options.index(of: option)!, section: 0)) as! KREListTableViewCell
                var fittingSize = UIView.layoutFittingCompressedSize
                fittingSize.width = width
                let size = cell.systemLayoutSizeFitting(fittingSize, withHorizontalFittingPriority: UILayoutPriority(rawValue: 1000), verticalFittingPriority: UILayoutPriority(rawValue: 250))
                height += size.height + 5.0 //kk 
            }
        }
        return height
    }
}

public class KREOptionsViewCell: UITableViewCell {
    // MARK:- init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK:- image view
    let optionsView: KREOptionsView = {
        let optionsView = KREOptionsView()
        optionsView.translatesAutoresizingMaskIntoConstraints = false
        return optionsView
    }()
    
    // MARK:- set up views
    func setupViews() {
        contentView.addSubview(optionsView)
        
        let views = ["optionsView": optionsView]
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[optionsView]|", options: [], metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[optionsView]|", options: [], metrics: nil, views: views))
    }
}

extension UIColor {
    convenience init(withFileType fileType: String) {
        switch fileType.uppercased() {
        case "GIF", "ICO":
            self.init(hex: 0x00C9FD)
        case "DOCX", "DOC", "PAGES", "GDOC", "RTF", "WPD", "JPEG", "MPEG", "PNG":
            self.init(hex: 0x2F7BF1)
        case "XLSX", "XLS", "GSHEET", "NUMBERS":
            self.init(hex: 0x39A341)
        case "PPT", "PPTX", "GSLIDE", "SLIDES":
            self.init(hex: 0xD14219)
        case "PDF":
            self.init(hex: 0xEC0400)
        case "MP3", "WAV", "AIF", "MOV", "MP4", "AVI":
            self.init(hex: 0x9E68BC)
        case "TXT", "HTML", "JS", "DAT", "JAVA", "SQL":
            self.init(hex: 0x8B93A0)
        case "SKETCH":
            self.init(hex: 0x880010)
        default:
            self.init(hex: 0x333D4D)
        }
    }
}

extension UIFont {
    class func font(withFileType fileType: String?) -> UIFont {
        if let count = fileType?.count, count > 0 {
            switch count {
            case 3:
                return systemFont(ofSize: 12.0, weight: .bold)
            case 4:
                return systemFont(ofSize: 10.0, weight: .bold)
            default:
                return systemFont(ofSize: 7.0, weight: .bold)
            }
        } else {
            return systemFont(ofSize: 12.0, weight: .bold)
        }
    }
}

extension DateFormatter {
    static let yyyyMMddTHHmmssZ: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    static let yyyyMMdd: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}
