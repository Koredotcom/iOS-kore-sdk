//
//  KREUtteranceViewCell.swift
//  KoreBotSDK
//
//  Created by Sukhmeet Singh on 06/11/19.
//

import UIKit

class KREHelpUtteranceTableViewCell: UITableViewCell {
    // MARK: - properties
    let kMaxTextWidth: CGFloat = BubbleViewMaxWidth
    let kMinTextWidth: CGFloat = 20.0
    var titleLabel: UILabel = {
        let titleLabel = UILabel(frame: .zero)
        titleLabel.font = UIFont.textFont(ofSize: 13.0, weight: .medium)
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor.lightRoyalBlue
        titleLabel.text = "Meet new way to meetings"
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }()
    
    var titleBgView: UIView = {
        let titleBgView = UIView(frame: .zero)
        titleBgView.backgroundColor = UIColor.paleGrey2
        titleBgView.translatesAutoresizingMaskIntoConstraints = false
        return titleBgView
    }()

    // MARK: - init
    public convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    // MARK: - setup
    func initialize() {
        selectionStyle = .none
        clipsToBounds = true
        contentView.addSubview(titleBgView)
        titleBgView.addSubview(titleLabel)
        let views = ["titleLabel": titleLabel, "titleBgView": titleBgView]
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[titleBgView]-|", options: [], metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-14-[titleBgView]", options: [], metrics: nil, views: views))
        
        let metrics: [String: NSNumber] = ["textLabelMaxWidth": NSNumber(value: Float(kMaxTextWidth)), "textLabelMinWidth": NSNumber(value: Float(kMinTextWidth))]
        titleBgView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-13-[titleLabel(>=textLabelMinWidth,<=textLabelMaxWidth)]-13-|", options: [], metrics: metrics, views: views))
        titleBgView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[titleLabel]-|", options: [], metrics: nil, views: views))
        
        //        textLabelTopConstraint = NSLayoutConstraint(item: textLabel, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 13.0)
        //        textLabelTopConstraint.isActive = true
        //
        //        textLabelBottomConstraint = NSLayoutConstraint(item: textLabel, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: -13.0)
        //        textLabelBottomConstraint.isActive = true
        
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
    }
}
