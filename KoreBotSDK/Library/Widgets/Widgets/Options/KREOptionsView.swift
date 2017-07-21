//
//  KREOptionsView.swift
//  Widgets
//
//  Created by developer@kore.com on 24/11/16.
//  Copyright © 2016 Kore Inc. All rights reserved.
//

import UIKit
import AFNetworking

public enum KREOptionType : Int {
    case button = 1, list = 2
}

public class KREOption: NSObject {
    static let titleCharLimit: Int = 80
    static let subtitleCharLimit: Int = 100
    
    // MARK:- properties
    var title: String?
    var subTitle: String?
    var imageURL:String?
    var optionType: KREOptionType?
    
    var defaultActionInfo:Dictionary<String,String>?
    var actionButtonInfo:Dictionary<String,String>?

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
    
    public func setOptionData(title: String, subTitle: String, imageURL: String, optionType: KREOptionType) {
        self.title = truncateString(title, count: KREOption.titleCharLimit)
        self.subTitle = truncateString(subTitle, count: KREOption.subtitleCharLimit)
        self.imageURL = imageURL
        self.optionType = optionType
    }

    public func setDefaultActionInfo(info:Dictionary<String, String>) {
        defaultActionInfo = info
    }
    
    public func setButtonActionInfo(info:Dictionary<String, String>) {
        actionButtonInfo = info
    }
    
    func truncateString(_ string: String, count: Int) -> String{
        var tmpString = string
        if(tmpString.characters.count > count){
            tmpString = tmpString.substring(to: tmpString.index(tmpString.startIndex, offsetBy: count))
        }
        return tmpString
    }
}

public class KREOptionsView: UIView, UITableViewDataSource, UITableViewDelegate {
    
    fileprivate let optionCellIdentifier = "KREOptionsTableViewCell"
    fileprivate let listCellIdentifier = "KREListTableViewCell"
    
    let kMaxRowHeight: CGFloat = 44
  
    public var optionsButtonAction: ((_ text: String?) -> Void)!
    public var detailLinkAction: ((_ text: String?) -> Void)!

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
        optionsView.setNeedsLayout()
        optionsView.layoutIfNeeded()

        return optionsView
    }()
    
    // MARK:- setup collectionView
    func setup() {
        let podBundle = Bundle(for: self.classForCoder)
        if let bundleURL = podBundle.url(forResource: "KoreWidgets", withExtension: "bundle") {
            if let bundle = Bundle(url: bundleURL) {
                
                let optionsCellNib = UINib(nibName: optionCellIdentifier, bundle: bundle)
                let listCellNib = UINib(nibName: listCellIdentifier, bundle: bundle)

                optionsTableView.register(optionsCellNib, forCellReuseIdentifier: optionCellIdentifier)
                optionsTableView.register(listCellNib, forCellReuseIdentifier: listCellIdentifier)
                
            }else {
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
            
            return cell
        }else if(option.optionType == KREOptionType.list){
            let cell:KREListTableViewCell = tableView.dequeueReusableCell(withIdentifier: listCellIdentifier, for: indexPath) as! KREListTableViewCell
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            
            cell.titleLabel.text = option.title
            cell.subTitleLabel.text = option.subTitle
            cell.imgView.setImageWith(NSURL(string: option.imageURL!) as URL!,placeholderImage: UIImage.init(named: "placeholder_image"))
            
            if(option.actionButtonInfo != nil){
                cell.actionButton.setTitle(option.actionButtonInfo?["title"] as String!, for: .normal)
                cell.buttonAction = {[weak self] (text) in
                    let buttonInfo:Dictionary<String,String>? = option.actionButtonInfo
                    if (buttonInfo?["type"] == "web_url") {
                        if ((self?.detailLinkAction) != nil) {
                            self?.detailLinkAction(buttonInfo?["url"])
                        }
                    } else if (buttonInfo?["type"] == "postback") {
                        if (self?.optionsButtonAction != nil) {
                            self?.optionsButtonAction(buttonInfo?["payload"])
                        }
                    }
                }
            }
            
            return cell
        }
        return UITableViewCell.init()
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let option: KREOption = options[indexPath.row]
        if(option.defaultActionInfo != nil){
            let buttonInfo:Dictionary<String,String>? = option.defaultActionInfo
            if (buttonInfo?["type"] == "web_url") {
                if ((self.detailLinkAction) != nil) {
                    self.detailLinkAction(buttonInfo?["url"])
                }
            } else if (buttonInfo?["type"] == "postback") {
                if (self.optionsButtonAction != nil) {
                    self.optionsButtonAction(buttonInfo?["payload"])
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
        let cell:KREListTableViewCell = self.optionsTableView.dequeueReusableCell(withIdentifier: listCellIdentifier) as! KREListTableViewCell
        cell.selectionStyle = UITableViewCellSelectionStyle.none

        var height: CGFloat = 0.0
        var maxHeight: CGFloat = UIScreen.main.bounds.size.height
        for option in options  {
            if(option.optionType == KREOptionType.button){
                height += kMaxRowHeight
            }else if(option.optionType == KREOptionType.list){
                cell.titleLabel.text = option.title
                cell.subTitleLabel.text = option.subTitle
                
                let limitingSize: CGSize = CGSize(width: width - 93.0, height: CGFloat.greatestFiniteMagnitude)
                height += cell.titleLabel.sizeThatFits(limitingSize).height + cell.subTitleLabel.sizeThatFits(limitingSize).height + 51.0
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

open class Common : NSObject {
    open static func UIColorRGB(_ rgb: Int) -> UIColor {
        let blue = CGFloat(rgb & 0xFF)
        let green = CGFloat((rgb >> 8) & 0xFF)
        let red = CGFloat((rgb >> 16) & 0xFF)
        return UIColor(red: red / 255.0, green: green / 255.0, blue: blue / 255.0, alpha: 1)
    }
}
