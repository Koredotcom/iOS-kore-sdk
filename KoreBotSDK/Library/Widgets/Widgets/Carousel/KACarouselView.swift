//
//  KACarouselView.swift
//  Widgets
//
//  Created by Srinivas Vasadi on 30/01/18.
//  Copyright © 2018 Kore. All rights reserved.
//

import UIKit

public class KAOptionsView: KREOptionsView {
    public var userIntentAction: ((_ text: String?) -> Void)!

    fileprivate let optionCellIdentifier = "KAOptionCellIdentifier"
    fileprivate let listCellIdentifier = "KAListTableViewCellIdentifier"

    public override func setup() {
        optionsTableView.register(UITableViewCell.self, forCellReuseIdentifier: optionCellIdentifier)
        optionsTableView.register(KREListTableViewCell.self, forCellReuseIdentifier: listCellIdentifier)
        addSubview(optionsTableView)
        
        let views = ["tableView": optionsTableView]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[tableView]|", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[tableView]|", options: [], metrics: nil, views: views))
        
        optionsTableView.delegate = self
        optionsTableView.dataSource = self
        
        optionsTableView.reloadData()
    }
    
    // MARK: - Table view data source
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let option: KREOption = options[indexPath.row]
        
        if (option.optionType == KREOptionType.button) {
            let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: optionCellIdentifier, for: indexPath)
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            
            cell.textLabel?.text = option.title
            cell.textLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 15.0)
            cell.textLabel?.textColor = Common.UIColorRGB(0x6168E7)
            cell.textLabel?.textAlignment = .center
            return cell
        } else if(option.optionType == KREOptionType.list) {
            let cell: KAListTableViewCell = tableView.dequeueReusableCell(withIdentifier: listCellIdentifier, for: indexPath) as! KAListTableViewCell
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            
            cell.titleLabel.text = option.title
            cell.subTitleLabel.text = option.subTitle
            return cell
        }
        return UITableViewCell.init()
    }
    
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let option: KREOption = options[indexPath.row]
        if (option.defaultAction != nil) {
            let defaultAction = option.defaultAction
            if (defaultAction?.type == .webURL) {
                if ((self.detailLinkAction) != nil) {
                    self.detailLinkAction(defaultAction?.payload)
                }
            } else if (defaultAction?.type == .postback) {
                if (self.optionsButtonAction != nil) {
                    self.optionsButtonAction(defaultAction?.payload)
                }
            } else if (defaultAction?.type == .user_intent) {
                if (self.userIntentAction != nil) {
                    self.userIntentAction(defaultAction?.payload)
                }
            }
        }
    }
    
    public override func getExpectedHeight(width: CGFloat) -> CGFloat {
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

public class KACardView: KRECardView {
    var titleLabel: UILabel!
    var subTitleLabel: UILabel!
    var hashTagsLabel: UILabel!
    var informationLabel: UILabel!
    var statusLabel: UILabel!
    public var userIntentAction: ((_ text: String?) -> Void)!

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        self.layer.masksToBounds = true
        setup()
    }
    
    convenience init () {
        self.init(frame: CGRect.zero)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - setup
    public override func setup() {
        let width = self.frame.size.width
        self.imageView = UIImageView()
        self.imageView.contentMode = .scaleAspectFill
        self.imageView.backgroundColor = UIColor.gray
        self.imageView.clipsToBounds = true
        self.imageView.layer.borderWidth = 0.5
        self.imageView.layer.borderColor = UIColor.lightGray.cgColor
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.imageView.isUserInteractionEnabled = true
        self.addSubview(self.imageView)
        
        self.imageViewHeightConstraint = NSLayoutConstraint(item: self.imageView, attribute:.height, relatedBy:.equal, toItem:nil, attribute:.notAnAttribute, multiplier:1.0, constant:width*0.5)
        self.imageView.addConstraint(self.imageViewHeightConstraint)
        
        self.optionsView = KAOptionsView()
        self.optionsView.translatesAutoresizingMaskIntoConstraints = false
        self.optionsView.isUserInteractionEnabled = true
        self.optionsView.contentMode = UIViewContentMode.topLeft
        self.optionsView.layer.borderWidth = 0.5
        self.optionsView.layer.borderColor = UIColor.lightGray.cgColor
        self.optionsView.optionsTableView.separatorInset = UIEdgeInsets.zero
        self.addSubview(self.optionsView)
        
        self.optionsViewHeightConstraint = NSLayoutConstraint(item: self.optionsView, attribute:.height, relatedBy:.equal, toItem:nil, attribute:.notAnAttribute, multiplier:1.0, constant: KACardView.kMaxRowHeight)
        self.optionsView.addConstraint(self.optionsViewHeightConstraint)
        
        self.optionsView.optionsButtonAction = {[weak self] (text) in
            if ((self?.optionsAction) != nil) {
                self?.optionsAction(text)
            }
        }
        
        self.optionsView.detailLinkAction = {[weak self] (text) in
            if (self?.linkAction != nil) {
                self?.linkAction(text)
            }
        }
        
        if (self.optionsView is KAOptionsView) {
            let ov = self.optionsView as! KAOptionsView
            ov.userIntentAction = {[weak self] (text) in
                if (self?.userIntentAction != nil) {
                    self?.userIntentAction(text)
                }
            }
        }
        
        let containterView: UIView = UIView(frame: .zero)
        containterView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(containterView)

        titleLabel = UILabel(frame: .zero)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textAlignment = .left
        titleLabel.font = UIFont(name: "Lato-Regular", size: 15.0)
        titleLabel.numberOfLines = 2
        titleLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        titleLabel.textColor = UIColor.black
        containterView.addSubview(titleLabel)
        
        subTitleLabel = UILabel(frame: .zero)
        subTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subTitleLabel.textAlignment = .left
        subTitleLabel.font = UIFont(name: "Lato-Regular", size: 14.0)
        subTitleLabel.textColor = UIColor.gray
        subTitleLabel.numberOfLines = 2
        subTitleLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        containterView.addSubview(subTitleLabel)
        
        hashTagsLabel = UILabel(frame: .zero)
        hashTagsLabel.translatesAutoresizingMaskIntoConstraints = false
        hashTagsLabel.textAlignment = .left
        hashTagsLabel.font = UIFont(name: "Lato-Regular", size: 14.0)
        hashTagsLabel.textColor = UIColor.blue
        hashTagsLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        containterView.addSubview(self.hashTagsLabel)
        
        informationLabel = UILabel(frame: .zero)
        informationLabel.translatesAutoresizingMaskIntoConstraints = false
        informationLabel.textAlignment = .left
        informationLabel.font = UIFont(name: "Lato-Regular", size: 12.0)
        informationLabel.textColor = UIColor.gray
        informationLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        containterView.addSubview(informationLabel)
        
        statusLabel = UILabel(frame: .zero)
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.textAlignment = .left
        statusLabel.font = UIFont(name: "Lato-Regular", size: 12.0)
        statusLabel.textColor = UIColor.gray
        statusLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        containterView.addSubview(statusLabel)
        
        let views = ["imageView": self.imageView, "containterView": containterView, "optionsView": self.optionsView, "titleLabel": titleLabel, "subTitleLabel": subTitleLabel, "hashTagsLabel":hashTagsLabel, "informationLabel": informationLabel, "statusLabel": statusLabel] as [String : Any]
        
        containterView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[titleLabel]-10-|", options: [], metrics: nil, views: views))
        containterView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[subTitleLabel]-10-|", options: [], metrics: nil, views: views))
        containterView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[hashTagsLabel]-10-|", options: [], metrics: nil, views: views))
        containterView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[informationLabel]", options: [], metrics: nil, views: views))
        containterView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[statusLabel]-10-|", options: [], metrics: nil, views: views))
        containterView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[titleLabel]-2-[subTitleLabel]-5-[hashTagsLabel]-5-[informationLabel]-|", options: [], metrics: nil, views: views))
        containterView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[statusLabel]-10-|", options: [], metrics: nil, views: views))

        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[imageView]-[containterView]-(>=10@1)-[optionsView]|", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[imageView]|", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[containterView]|", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[optionsView]|", options: [], metrics: nil, views: views))
    }
    
    public override func configureForCardInfo(cardInfo: KRECardInfo) {
        self.imageView.setImageWith(NSURL(string: cardInfo.imageURL!) as URL!, placeholderImage: UIImage.init(named: "placeholder_image"))
        self.optionsView.options.removeAll()
        self.optionsView.options = cardInfo.options!
        
        titleLabel.text = cardInfo.title
        subTitleLabel.text = cardInfo.subTitle
        hashTagsLabel.text = "#welcome   #newemployee"
        informationLabel.text = "Link: News Article"
        statusLabel.text = "Private"

        let count: Int = min(cardInfo.options!.count, KACardView.buttonLimit)
        self.optionsViewHeightConstraint.constant = KACardView.kMaxRowHeight*CGFloat(count)
    }
}

public class KAListTableViewCell: UITableViewCell {
    var titleLabel: UILabel!
    var subTitleLabel: UILabel!
    var hashTagsLabel: UILabel!
    var informationLabel: UILabel!
    var statusLabel: UILabel!
    
    // MARK:- init
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK:- init
    func setupViews() {
        titleLabel = UILabel(frame: .zero)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textAlignment = .left
        titleLabel.font = UIFont(name: "Lato-Regular", size: 15.0)
        titleLabel.numberOfLines = 2
        titleLabel.textColor = UIColor.black
        titleLabel.text = "Six Simple Steps To Mastering Marketing Automation"
        contentView.addSubview(titleLabel)
        
        subTitleLabel = UILabel(frame: .zero)
        subTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subTitleLabel.textAlignment = .left
        subTitleLabel.font = UIFont(name: "Lato-Regular", size: 14.0)
        subTitleLabel.textColor = UIColor.gray
        subTitleLabel.numberOfLines = 2
        subTitleLabel.text = "When choosing a marketing automation solution, remember that the tool itself i…"
        contentView.addSubview(subTitleLabel)
        
        hashTagsLabel = UILabel(frame: .zero)
        hashTagsLabel.translatesAutoresizingMaskIntoConstraints = false
        hashTagsLabel.textAlignment = .left
        hashTagsLabel.font = UIFont(name: "Lato-Regular", size: 14.0)
        hashTagsLabel.textColor = UIColor.blue
        hashTagsLabel.text = "#welcome   #newemployee"
        contentView.addSubview(self.hashTagsLabel)
        
        informationLabel = UILabel(frame: .zero)
        informationLabel.translatesAutoresizingMaskIntoConstraints = false
        informationLabel.textAlignment = .left
        informationLabel.font = UIFont(name: "Lato-Regular", size: 12.0)
        informationLabel.textColor = UIColor.gray
        informationLabel.text = "Link: News Article"
        contentView.addSubview(informationLabel)
        
        statusLabel = UILabel(frame: .zero)
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.textAlignment = .left
        statusLabel.font = UIFont(name: "Lato-Regular", size: 12.0)
        statusLabel.textColor = UIColor.gray
        statusLabel.text = "Private"
        contentView.addSubview(statusLabel)
        
        let views: [String: UIView] = ["titleLabel": titleLabel, "subTitleLabel": subTitleLabel, "hashTagsLabel":hashTagsLabel, "informationLabel": informationLabel, "statusLabel": statusLabel]
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[titleLabel]-[subTitleLabel]-5-[hashTagsLabel]-5-[informationLabel]-|", options: [], metrics: nil, views: views))

        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[titleLabel]-10-|", options: [], metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[subTitleLabel]-10-|", options: [], metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[hashTagsLabel]-10-|", options: [], metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[informationLabel]", options: [], metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[statusLabel]-10-|", options: [], metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[statusLabel]-10-|", options: [], metrics: nil, views: views))
    }
}

public class KACardCollectionViewCell: UICollectionViewCell {
    public static let cellReuseIdentifier: String = "KACardCollectionViewCell"
    public var cardView: KACardView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.withAlphaComponent(0.5).cgColor
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowRadius = 0.5
        
        self.cardView = KACardView(frame: CGRect.init(origin: CGPoint.zero, size: frame.size))
        self.contentView.addSubview(self.cardView)
        
        let views: [String: UIView] = ["cardView": cardView]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[cardView]|", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[cardView]|", options: [], metrics: nil, views: views))
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public class KACarouselView: KRECarouselView {
    public var userIntentAction: ((_ text: String?) -> Void)!

    public override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: KACardCollectionViewCell.cellReuseIdentifier, for: indexPath) as! KACardCollectionViewCell
        let cardInfo = cards[indexPath.row]
        cell.cardView.configureForCardInfo(cardInfo: cardInfo)
        
        if (indexPath.row == 0) {
            cell.cardView.isFirst = true
        } else {
            cell.cardView.isFirst = false
        }
        if (indexPath.row == self.numberOfItems - 1) {
            cell.cardView.isLast = true
        } else {
            cell.cardView.isLast = false
        }
        
        cell.cardView.optionsAction = { [weak self] (text) in
            if ((self?.optionsAction) != nil) {
                self?.optionsAction(text)
            }
        }
        
        cell.cardView.linkAction = { [weak self] (text) in
            if(self?.linkAction != nil){
                self?.linkAction(text)
            }
        }
        
        cell.cardView.userIntentAction = { [weak self] (text) in
            if (self?.userIntentAction != nil) {
                self?.userIntentAction(text)
            }
        }
        
        return cell
    }
    
    public override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let cardCell = cell as! KACardCollectionViewCell
        cardCell.cardView.updateLayer()
    }
    
    // MARK: - expected height of KRECard
    public override func getExpectedHeight(cardInfo: KRECardInfo, width: CGFloat) -> CGFloat {
        var height: CGFloat = 0.0
        
        let count: Int = min(cardInfo.options!.count, KRECardView.buttonLimit)
        height += KRECardView.kMaxRowHeight * CGFloat(count)
        height += 307.0
        return height
    }
}
