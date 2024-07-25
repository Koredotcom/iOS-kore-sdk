//
//  KREAnnouncementsTableViewCell.swift
//  KoraSDK
//
//  Created by Sukhmeet Singh on 15/04/19.
//  Copyright © 2019 Srinivas Vasadi. All rights reserved.
//

import UIKit

public class KAAnnouncementsTableViewCell: UITableViewCell {
    // MARK: -
    let bundle = Bundle.sdkModule
    var actionContainerHeightConstraint: NSLayoutConstraint!
    lazy var dateLabel: UILabel = {
        let dateLabel = UILabel(frame: CGRect.zero)
        dateLabel.font = UIFont.textFont(ofSize: 13.0, weight: .regular)
        dateLabel.textColor = UIColor(hex: 0xA7A9BE)
        dateLabel.isUserInteractionEnabled = true
        dateLabel.textAlignment = .right
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        return dateLabel
    }()
    lazy var kaTitleLabel: UILabel = {
        let kaTitleLabel = UILabel(frame: CGRect.zero)
        kaTitleLabel.font = UIFont.textFont(ofSize: 17.0, weight: .bold)
        kaTitleLabel.textColor = UIColor.charcoalGrey
        kaTitleLabel.isUserInteractionEnabled = true
        kaTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        kaTitleLabel.numberOfLines = 1
        return kaTitleLabel
    }()
    lazy var kaSharedListLabel: UILabel = {
        let kaSharedListLabel = UILabel(frame: CGRect.zero)
        kaSharedListLabel.font = UIFont.textFont(ofSize: 13.0, weight: .regular)
        kaSharedListLabel.textColor = UIColor.battleshipGrey
        kaSharedListLabel.sizeToFit()
        kaSharedListLabel.isUserInteractionEnabled = true
        kaSharedListLabel.textAlignment = .left
        kaSharedListLabel.translatesAutoresizingMaskIntoConstraints = false
        return kaSharedListLabel
    }()
    lazy var kaNameLabel: UILabel = {
        let kaNameLabel = UILabel(frame: CGRect.zero)
        kaNameLabel.font = UIFont.textFont(ofSize: 15.0, weight: .semibold)
        kaNameLabel.textColor = UIColor.charcoalGrey
        kaNameLabel.sizeToFit()
        kaNameLabel.isUserInteractionEnabled = true
        kaNameLabel.textAlignment = .left
        kaNameLabel.translatesAutoresizingMaskIntoConstraints = false
        return kaNameLabel
    }()
    lazy var kaSubTitleLabel: UILabel = {
        let kaSubTitleLabel = UILabel(frame: CGRect.zero)
        kaSubTitleLabel.font = UIFont.textFont(ofSize: 17.0, weight: .regular)
        kaSubTitleLabel.textColor = UIColor.charcoalGrey
        kaSubTitleLabel.isUserInteractionEnabled = true
        kaSubTitleLabel.numberOfLines = 2
        kaSubTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        return kaSubTitleLabel
    }()
    lazy var kaCommentImageView: UILabel = {
        let kaCommentImageView = UILabel(frame: .zero)
        kaCommentImageView.text = "\u{e941}"
        kaCommentImageView.textColor = UIColor(hex: 0xA7A9BE)
        kaCommentImageView.font = UIFont.systemSymbolFont(ofSize: 17)
        kaCommentImageView.backgroundColor = UIColor.white
        kaCommentImageView.clipsToBounds = true
        kaCommentImageView.translatesAutoresizingMaskIntoConstraints = false
        kaCommentImageView.isUserInteractionEnabled = true
        return kaCommentImageView
    }()
    lazy var kaCommentLabel: UILabel = {
        let kaCommentLabel = UILabel(frame: CGRect.zero)
        kaCommentLabel.font = UIFont.textFont(ofSize: 15.0, weight: .regular)
        kaCommentLabel.textColor = UIColor(hex: 0x333D4D)
        kaCommentLabel.isUserInteractionEnabled = true
        kaCommentLabel.textAlignment = .left
        kaCommentLabel.translatesAutoresizingMaskIntoConstraints = false
        return kaCommentLabel
    }()
    var kaSpectatorImageView = UIImageView(frame: .zero)
    lazy var kaSpectatorLabel: UILabel = {
        let kaSpectatorLabel = UILabel(frame: CGRect.zero)
        kaSpectatorLabel.font = UIFont.textFont(ofSize: 15.0, weight: .regular)
        kaSpectatorLabel.textColor = UIColor(hex: 0x333D4D)
        kaSpectatorLabel.isUserInteractionEnabled = true
        kaSpectatorLabel.textAlignment = .left
        kaSpectatorLabel.translatesAutoresizingMaskIntoConstraints = false
        return kaSpectatorLabel
    }()
    lazy var kaLikeImageView: UIImageView = {
        let kaLikeImageView = UIImageView(frame: .zero)
        kaLikeImageView.contentMode = .scaleAspectFit
        let favouriteImage = UIImage(named: "upvote", in: bundle, compatibleWith: nil)
        let favouriteTemplateImage = favouriteImage?.withRenderingMode(.alwaysTemplate)
        kaLikeImageView.image = favouriteTemplateImage
        kaLikeImageView.tintColor = UIColor(hex: 0xA7A9BE)
        kaLikeImageView.backgroundColor = UIColor.white
        kaLikeImageView.clipsToBounds = true
        kaLikeImageView.translatesAutoresizingMaskIntoConstraints = false
        kaLikeImageView.isUserInteractionEnabled = true
        return kaLikeImageView
    }()
    lazy var kaLikeLabel: UILabel = {
        let kaLikeLabel = UILabel(frame: CGRect.zero)
        kaLikeLabel.font = UIFont.textFont(ofSize: 15.0, weight: .regular)
        kaLikeLabel.textColor = UIColor(hex: 0x333D4D)
        kaLikeLabel.sizeToFit()
        kaLikeLabel.isUserInteractionEnabled = true
        kaLikeLabel.textAlignment = .left
        kaLikeLabel.translatesAutoresizingMaskIntoConstraints = false
        return kaLikeLabel
    }()
    lazy var kaProfileImageView: KREIdentityImageView = {
        let profileImageView = KREIdentityImageView(frame: .zero)
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        return profileImageView
    }()
    lazy var kaActionContainerView: UIView = {
        let kaActionContainerView = UIView(frame: .zero)
        kaActionContainerView.translatesAutoresizingMaskIntoConstraints = false
        return kaActionContainerView
    }()
        
    // MARK: -
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override public func prepareForReuse() {
        super.prepareForReuse()
        dateLabel.text = nil
        kaTitleLabel.text = nil
        kaSubTitleLabel.text = nil
        kaCommentLabel.text = nil
        kaSpectatorLabel.text = nil
        kaLikeLabel.text = nil
        kaSharedListLabel.text = nil
    }
    
    func setup() {
        selectionStyle = .none

        contentView.addSubview(kaActionContainerView)
        contentView.addSubview(kaProfileImageView)
        contentView.addSubview(dateLabel)
        contentView.addSubview(kaTitleLabel)
        contentView.addSubview(kaSubTitleLabel)
        contentView.addSubview(kaSharedListLabel)
        contentView.addSubview(kaNameLabel)
        
        kaActionContainerView.addSubview(kaCommentImageView)
        kaActionContainerView.addSubview(kaLikeImageView)
        kaActionContainerView.addSubview(kaCommentLabel)
        kaActionContainerView.addSubview(kaSpectatorLabel)
        kaActionContainerView.addSubview(kaLikeLabel)
                
        let views = ["dateLabel": dateLabel, "kaTitleLabel": kaTitleLabel, "kaSubTitleLabel": kaSubTitleLabel, "kaActionContainerView": kaActionContainerView, "kaProfileImageView": kaProfileImageView, "kaSharedListLabel": kaSharedListLabel, "kaNameLabel": kaNameLabel]
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-11-[kaNameLabel]-3-[kaSharedListLabel]-5-[kaTitleLabel]-4-[kaSubTitleLabel]-7-[kaActionContainerView]-|", options: [], metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-11-[kaProfileImageView(26)]", options: [], metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-11-[dateLabel]", options: [], metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[kaProfileImageView(26)]-7-[kaNameLabel]-20-[dateLabel]-10-|", options: [], metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-43-[kaSharedListLabel]-13-|", options: [], metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-43-[kaTitleLabel]-13-|", options: [], metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-43-[kaSubTitleLabel]-13-|", options: [], metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-42-[kaActionContainerView]-13-|", options: [], metrics: nil, views: views))

        kaTitleLabel.setContentHuggingPriority(UILayoutPriority.defaultHigh, for: .horizontal)
        dateLabel.setContentHuggingPriority(UILayoutPriority.defaultLow, for: .horizontal)
        kaTitleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        dateLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        
        actionContainerHeightConstraint = NSLayoutConstraint(item: kaActionContainerView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 16.0)
        actionContainerHeightConstraint.isActive = true
        contentView.addConstraint(actionContainerHeightConstraint)
        
        addActionContainerView()
    }
    
    func addActionContainerView() {
        let views = ["kaCommentImageView": kaCommentImageView, "kaCommentLabel": kaCommentLabel, "kaSpectatorImageView": kaSpectatorImageView, "kaSpectatorLabel": kaSpectatorLabel, "kaLikeLabel": kaLikeLabel, "kaLikeImageView": kaLikeImageView, "kaActionContainerView": kaActionContainerView]
        kaActionContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[kaLikeImageView]|", options: [], metrics: nil, views: views))
        kaActionContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[kaLikeLabel]|", options: [], metrics: nil, views: views))
        kaActionContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[kaCommentImageView]|", options: [], metrics: nil, views: views))
        kaActionContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[kaCommentLabel]|", options: [], metrics: nil, views: views))
        kaActionContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[kaCommentImageView(16)]-8-[kaCommentLabel]-20-[kaLikeImageView(16)]-8-[kaLikeLabel]", options: [], metrics: nil, views: views))
    }
    
    func loadingDataState() {
        kaTitleLabel.text = "Test"
        kaSubTitleLabel.text = "Test"
        dateLabel.text = "Test"
        kaTitleLabel.textColor = UIColor.paleGrey
        kaTitleLabel.backgroundColor = .paleGrey
        kaSubTitleLabel.textColor = UIColor.paleGrey
        kaSubTitleLabel.backgroundColor = .paleGrey
        dateLabel.textColor = UIColor.paleGrey
        dateLabel.backgroundColor = .paleGrey
        kaActionContainerView.isHidden = true
    }
    
    func loadedDataState() {
        kaTitleLabel.textColor = UIColor.charcoalGrey
        kaTitleLabel.backgroundColor = .clear
        kaSubTitleLabel.textColor = UIColor.charcoalGrey
        kaSubTitleLabel.backgroundColor = .clear
        dateLabel.textColor = UIColor.lightGreyBlue
        dateLabel.backgroundColor = .clear
        kaActionContainerView.isHidden = false
    }
}
