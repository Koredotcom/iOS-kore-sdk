//
//  KREOptionsView.swift
//  Widgets
//
//  Created by developer@kore.com on 24/11/16.
//  Copyright © 2016 Kore Inc. All rights reserved.
//

import UIKit
import AFNetworking

public enum KREActionType : Int {
    case none = 0, webURL = 1, postback = 2, user_intent = 3, postback_disp_payload = 4
}

public class KREAction: NSObject {
    public var type: KREActionType?
    public var title: String?
    public var payload:String?
    public var customData: [String: Any]?
    public var action: String?

    public init(type: KREActionType, title: String, payload: String) {
        super.init()
        self.type = type
        self.title = title
        self.payload = payload
    }
    
    public init(type: KREActionType, title: String, customData: [String: Any]) {
        super.init()
        self.type = type
        self.title = title
        self.customData = customData
    }
}

public enum KREOptionType : Int {
    case button = 1, list = 2
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
        self.subTitle = truncateString(subTitle, count: KREOption.subtitleCharLimit)
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
        if(tmpString.characters.count > count){
            tmpString = tmpString.substring(to: tmpString.index(tmpString.startIndex, offsetBy: count))
        }
        return tmpString
    }
}

open class KREOptionsView: UIView, UITableViewDataSource, UITableViewDelegate {
    
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
        optionsView.estimatedRowHeight = UITableViewAutomaticDimension
        optionsView.rowHeight = UITableViewAutomaticDimension
        optionsView.separatorStyle = UITableViewCellSeparatorStyle.singleLine
        optionsView.separatorInset = .zero
        optionsView.setNeedsLayout()
        optionsView.layoutIfNeeded()

        return optionsView
    }()
    
    // MARK:- setup collectionView
    public func setup() {
        let podBundle = Bundle(for: self.classForCoder)
        if let bundleURL = podBundle.url(forResource: "Widgets", withExtension: "bundle") {
            if let bundle = Bundle(url: bundleURL) {
                
                let optionsCellNib = UINib(nibName: optionCellIdentifier, bundle: bundle)
                let listCellNib = UINib(nibName: listCellIdentifier, bundle: bundle)

                optionsTableView.register(optionsCellNib, forCellReuseIdentifier: optionCellIdentifier)
                optionsTableView.register(listCellNib, forCellReuseIdentifier: listCellIdentifier)
                
                optionsTableView.register(KREOptionsTableViewCell.self, forCellReuseIdentifier: optionCellIdentifier)
                optionsTableView.register(KREListTableViewCell.self, forCellReuseIdentifier: listCellIdentifier)
            } else {
                assertionFailure("Could not load the bundle")
            }
        }else {
            assertionFailure("Could not create a path to the bundle")
        }

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
            let cell:KREOptionsTableViewCell = tableView.dequeueReusableCell(withIdentifier: optionCellIdentifier, for: indexPath) as! KREOptionsTableViewCell
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            
            cell.textLabel?.text = option.title
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.textColor = UIColor(hex: 0x6168E7)
            cell.textLabel?.font = UIFont(name: "Lato-Medium", size: 15.0)
            
            return cell
        }else if(option.optionType == KREOptionType.list){
            let cell:KREListTableViewCell = tableView.dequeueReusableCell(withIdentifier: listCellIdentifier, for: indexPath) as! KREListTableViewCell
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            
            cell.titleLabel.text = option.title
            cell.subTitleLabel.text = option.subTitle
            
            if option.imageURL != "" {
                cell.imgView.setImageWith(NSURL(string: option.imageURL!) as URL!,placeholderImage: UIImage.init(named: "placeholder_image"))
                cell.imgViewWidthConstraint.constant = 60.0
            } else {
                cell.imageView?.image = nil
                cell.imgViewWidthConstraint.constant = 0.0
            }
            
            if(option.buttonAction != nil){
                let buttonAction = option.buttonAction
                cell.actionButtonHeightConstraint.constant = 30.0
                cell.actionButton.setTitle(buttonAction?.title, for: .normal)
                cell.buttonAction = {[weak self] (text) in
                    if (buttonAction?.type == .webURL) {
                        if ((self?.detailLinkAction) != nil) {
                            self?.detailLinkAction(buttonAction?.payload)
                        }
                    } else if (buttonAction?.type == .postback || buttonAction?.type == .postback_disp_payload) {
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
        if(option.defaultAction != nil){
            let defaultAction = option.defaultAction
            if (defaultAction?.type == .webURL) {
                if ((self.detailLinkAction) != nil) {
                    self.detailLinkAction(defaultAction?.payload)
                }
            } else if (defaultAction?.type == .postback || defaultAction?.type == .postback_disp_payload) {
                if (self.optionsButtonAction != nil) {
                    self.optionsButtonAction(defaultAction?.title, defaultAction?.payload)
                }
            }else if(defaultAction?.type == .user_intent ){
                if (self.userIntentAction != nil) {
                    self.userIntentAction(defaultAction?.action, defaultAction?.customData)
                }
            }
        }
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    public func getExpectedHeight(width: CGFloat) -> CGFloat {
        var height: CGFloat = 0.0
        for option in options  {
            if(option.optionType == KREOptionType.button){
                height += kMaxRowHeight
            }else if(option.optionType == KREOptionType.list){
                let cell:KREListTableViewCell = self.tableView(optionsTableView, cellForRowAt: IndexPath(row: options.index(of: option)!, section: 0)) as! KREListTableViewCell
                var fittingSize = UILayoutFittingCompressedSize
                fittingSize.width = width
                let size = cell.systemLayoutSizeFitting(fittingSize, withHorizontalFittingPriority: UILayoutPriority(rawValue: 1000), verticalFittingPriority: UILayoutPriority(rawValue: 250))
                height += size.height
            }
        }
        return height
    }
}

public class KREOptionsViewCell: UITableViewCell {
    // MARK:- init
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
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
    convenience init(hex: Int, alpha: CGFloat = 1.0) {
        self.init(
            red: CGFloat((hex & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((hex & 0x00FF00) >> 8)  / 255.0,
            blue: CGFloat((hex & 0x0000FF) >> 0)  / 255.0,
            alpha: alpha
        )
    }
}

extension DateFormatter {
    static let iso8601Full: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
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
