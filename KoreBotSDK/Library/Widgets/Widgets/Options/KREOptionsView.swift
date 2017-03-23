//
//  KREOptionsView.swift
//  Widgets
//
//  Created by developer@kore.com on 24/11/16.
//  Copyright © 2016 Kore Inc. All rights reserved.
//

import UIKit
import AFNetworking

enum KREOptionType : Int {
    case button = 1, list = 2
}

public class KREOption: NSObject {
    
    // MARK:- properties
    var optionName: String?
    var optionIndex: Int = -1
    var optionDescription: String?
    var optionWithButtonDesc:Dictionary<String,String>?
    var optionWithButtonInfo:Dictionary<String,String>?

    var imageURL:String?
    var subTitle:String?
    var optionType: String?
    // MARK:- init
    public override init() {
        super.init()
    }
    
    public init(name: String, desc: String, type: String, index: Int) {
        super.init()
        optionName = name
        optionDescription = desc
        optionIndex = index
    }
    
    public func setOptionData(name: String, subTitle:String, imgURL:String, index: Int) {
        optionName = name
        self.subTitle = subTitle
        imageURL = imgURL
        optionIndex = index
    }

    public func setButtonDesc(info:Dictionary<String, String>) {
        optionWithButtonDesc = info;
    }
    
    public func setButtonInfo(info:Dictionary<String, String>) {
        optionWithButtonInfo = info;
    }

    
}



public class KREOptionsView: UIView, UITableViewDataSource, UITableViewDelegate {
    
//    fileprivate let cellIdentifier = "UITableViewCell"
    fileprivate let cellIdentifier = "KREOptionsTableViewCell"
    fileprivate let listCellIdentifier = "KREListTableViewCell"
    public var showMore:Bool = false
  
    public var optionsButtonAction: ((_ text: String?) -> Void)!
    public var detailLinkAction: ((_ text: String?) -> Void)!

//    public var showMoreButtonAction: () -> ()!

    // MARK:- properites
    public var options: Array<KREOption> = Array<KREOption>() {
        didSet {
            self.optionsTableView.reloadData()
//            self.optionsTableView.layoutSubviews()
        }
    }
    var optionIndex: Int = -1
    public var optionsViewType: Int = 1

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
        let optionsView = UITableView(frame: CGRect.zero, style: .grouped)
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
                
                let optionsCellNib = UINib(nibName: "KREOptionsTableViewCell", bundle: bundle)
                let listCellNib = UINib(nibName: "KREListTableViewCell", bundle: bundle)

                optionsTableView.register(optionsCellNib, forCellReuseIdentifier: cellIdentifier)
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
        if(self.showMore){
            return options.count + 1
        }
        return options.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(self.showMore && indexPath.row == options.count){
            let cell:KREOptionsTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! KREOptionsTableViewCell
            cell.textLabel?.textAlignment = .center
            cell.nameLabel?.text = "Show more"
            
            return cell
        }else if(self.optionsViewType == KREOptionType.button.rawValue){
            let cell:KREOptionsTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! KREOptionsTableViewCell
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            let option: KREOption = options[indexPath.row]
            cell.nameLabel?.text = option.optionName
            cell.layoutIfNeeded()
            cell.setNeedsLayout()
            return cell
        } else {
            let cell:KREListTableViewCell = tableView.dequeueReusableCell(withIdentifier: listCellIdentifier, for: indexPath) as! KREListTableViewCell
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            let option: KREOption = options[indexPath.row]
            cell.nameLabel.text = option.optionName
            cell.infoLabel.text =  option.subTitle
            cell.infoLabel.numberOfLines = 2
            cell.imgView.setImageWith(NSURL(string: option.imageURL!) as URL!,placeholderImage: UIImage.init(named: "placeholder_image"))
            cell.moreDetailsLabel.layer.borderColor = Common.UIColorRGB(0x0076ff).cgColor
            if(option.optionWithButtonDesc != nil){
                cell.moreDetailsText = option.optionWithButtonDesc?["title"] as NSString!
            }
            
            cell.labelAction = {[weak self] (text) in
                if((self?.detailLinkAction) != nil){
                    self?.detailLinkAction(option.optionWithButtonDesc?["url"])
                }
            }
            
            return cell
        }
        return UITableViewCell.init()

    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(self.showMore && indexPath.row == options.count){
            if(self.optionsButtonAction != nil){
                self.optionsButtonAction("Show more")
            }
        }else if(self.optionsViewType == KREOptionType.button.rawValue){
            let cell:KREOptionsTableViewCell = tableView.cellForRow(at: indexPath) as! KREOptionsTableViewCell
            
            if(self.optionsButtonAction != nil){
                let option: KREOption = options[indexPath.row]

                var optionWithButtonInfo:Dictionary<String,String>?

                let buttonInfo:Dictionary<String,String>? = option.optionWithButtonInfo
                
                if(buttonInfo?["type"] == "web_url"){
                    if((self.detailLinkAction) != nil){
                        self.detailLinkAction(buttonInfo?["url"])
                    }
                }else if(buttonInfo?["type"] == "postback"){
                    if(self.optionsButtonAction != nil){
                        self.optionsButtonAction(buttonInfo?["payload"])
                    }
                }else{
                    if(self.optionsButtonAction != nil){
                        self.optionsButtonAction(cell.nameLabel.text)
                    }
                }
            }
        }else{
          
        }
    }
     public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
     public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
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
