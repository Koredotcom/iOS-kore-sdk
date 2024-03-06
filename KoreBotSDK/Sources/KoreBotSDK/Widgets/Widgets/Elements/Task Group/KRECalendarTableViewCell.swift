//
//  KRECalendarTableViewCell.swift
//  KoreBotSDK
//
//  Created by Sukhmeet Singh on 29/10/19.
//

import UIKit

class KRECalendarTableViewCell: UITableViewCell {
    
    let bundle = Bundle.sdkModule
    // MARK: - properties
    public lazy var fromLabel: UILabel = {
        var fromLabel: UILabel = UILabel(frame: .zero)
        fromLabel.translatesAutoresizingMaskIntoConstraints = false
        fromLabel.font = UIFont.textFont(ofSize: 12.0, weight: .semibold)
        fromLabel.textColor = UIColor.gunmetal
        fromLabel.textAlignment = .right
        fromLabel.lineBreakMode = .byWordWrapping
        fromLabel.numberOfLines = 0
        return fromLabel
    }()
    public lazy var viaLabel: UILabel = {
        var viaLabel: UILabel = UILabel(frame: .zero)
        viaLabel.translatesAutoresizingMaskIntoConstraints = false
        viaLabel.font = UIFont.textFont(ofSize: 12.0, weight: .semibold)
        viaLabel.textColor = UIColor.gunmetal
        viaLabel.textAlignment = .right
        viaLabel.lineBreakMode = .byWordWrapping
        viaLabel.numberOfLines = 0
        return viaLabel
    }()
    public lazy var toLabel: UILabel = {
        var toLabel: UILabel = UILabel(frame: .zero)
        toLabel.translatesAutoresizingMaskIntoConstraints = false
        toLabel.font = UIFont.textFont(ofSize: 12.0, weight: .semibold)
        toLabel.textColor = UIColor.gunmetal
        toLabel.numberOfLines = 1
        toLabel.lineBreakMode = .byWordWrapping
        toLabel.textAlignment = .right
        return toLabel
    }()
    public lazy var verticalLine: UILabel = {
        var verticalLine: UILabel = UILabel(frame: .zero)
        verticalLine.translatesAutoresizingMaskIntoConstraints = false
        verticalLine.font = UIFont.textFont(ofSize: 12.0, weight: .semibold)
        verticalLine.backgroundColor = UIColor.lightRoyalBlue
        verticalLine.numberOfLines = 0
        return verticalLine
    }()
    public lazy var lineView: UIView = {
        var lineView = UIView(frame: .zero)
        lineView.translatesAutoresizingMaskIntoConstraints = false
        lineView.backgroundColor = UIColor.lightGreyBlue
        return lineView
    }()
    public lazy var titleLabel: UILabel = {
        var titleLabel: UILabel = UILabel(frame: .zero)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.textFont(ofSize: 16.0, weight: .semibold)
        titleLabel.textColor = UIColor.gunmetal
        titleLabel.numberOfLines = 1
        titleLabel.lineBreakMode = .byTruncatingTail
        return titleLabel
    }()
    public lazy var locaLabel: UILabel = {
        var locaLabel: UILabel = UILabel(frame: .zero)
        locaLabel.translatesAutoresizingMaskIntoConstraints = false
        locaLabel.font = UIFont.textFont(ofSize: 13.0, weight: .medium)
        locaLabel.textColor = UIColor.gunmetal
        return locaLabel
    }()
    public lazy var participantsLabel: UILabel = {
        var participantsLabel: UILabel = UILabel(frame: .zero)
        participantsLabel.translatesAutoresizingMaskIntoConstraints = false
        participantsLabel.font = UIFont.textFont(ofSize: 13.0, weight: .medium)
        participantsLabel.textColor = UIColor.gunmetal
        return participantsLabel
    }()
    public lazy var locImageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "location")
        return imageView
    }()
    public lazy var participantsImageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "attendee")
        return imageView
    }()
    public lazy var selectionView: UIButton = {
        var selectionView = UIButton(frame: .zero)
        selectionView.imageView?.contentMode = .scaleAspectFit
        selectionView.translatesAutoresizingMaskIntoConstraints = false
        return selectionView
    }()
    
    // MARK: - init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initialize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    // MARK: properties with observers
    override open func prepareForReuse() {
        titleLabel.text = ""
        locaLabel.text = ""
        participantsLabel.text = ""
        fromLabel.text = ""
        toLabel.text = ""
        viaLabel.text = ""
    }
    
    func initialize() {
        contentView.addSubview(fromLabel)
        contentView.addSubview(viaLabel)
        contentView.addSubview(toLabel)
        contentView.addSubview(titleLabel)
        contentView.addSubview(verticalLine)
        contentView.addSubview(participantsLabel)
        contentView.addSubview(locaLabel)
        contentView.addSubview(locImageView)
        contentView.addSubview(participantsImageView)
        
        separatorInset = UIEdgeInsets.zero
        contentView.backgroundColor = .clear
        
        let views: [String: UIView] = ["fromLabel": fromLabel,"viaLabel":viaLabel ,"toLabel": toLabel, "verticalLine": verticalLine, "titleLabel":titleLabel, "locaLabel": locaLabel, "participantsLabel": participantsLabel, "locImageView": locImageView, "participantsImageView": participantsImageView, "selectionView": selectionView]
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[selectionView]-10-[fromLabel]-[verticalLine(2)]-8-[titleLabel]-|", options:[], metrics:nil, views:views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[selectionView]-10-[viaLabel]-[verticalLine(2)]-8-[titleLabel]-|", options:[], metrics:nil, views:views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[selectionView]-10-[toLabel]-[verticalLine(2)]-8-[titleLabel]-|", options:[], metrics:nil, views:views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[verticalLine(2)]", options:[], metrics:nil, views:views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[verticalLine]-6-[locImageView(20)]-[locaLabel]-|", options:[], metrics:nil, views:views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[verticalLine]-6-[participantsImageView(20)]-8-[participantsLabel]-|", options:[], metrics:nil, views:views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[verticalLine]|", options:[], metrics:nil, views:views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-15-[fromLabel]-4-[viaLabel]-4-[toLabel]", options:[], metrics:nil, views:views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-16-[verticalLine(20)]", options:[], metrics:nil, views:views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-15-[titleLabel]-10-[locaLabel]-12-[participantsLabel]-12-|", options:[], metrics:nil, views:views))

        
    }
}
