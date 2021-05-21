//
//  KRETaskListItemView.swift
//  KoreBotSDK
//
//  Created by Srinivas Vasadi on 04/02/2020.
//  Copyright © 2019 Srinivas Vasadi. All rights reserved.
//

import UIKit

public class KRETaskListItemView: UIView {
    // MARK: - properties
    let bundle = Bundle(for: KRETaskPreviewCell.self)
    public var itemSelectionHandler:((KRETaskListItemView) -> Void)?
    public var moreSelectionHandler:((KRETaskListItemView) -> Void)?
    public var selectionViewWidthConstraint: NSLayoutConstraint!
    public var selectionViewLeadingConstraint: NSLayoutConstraint!
    public var containerViewLeadingConstraint: NSLayoutConstraint!
    public var containerViewTrailingConstraint: NSLayoutConstraint!
    public var isLoadingData = false
    
    public lazy var containerView: UIView = {
        let containerView = UIView(frame: .zero)
        containerView.isUserInteractionEnabled = true
        containerView.translatesAutoresizingMaskIntoConstraints = false
        return containerView
    }()
    public lazy var dateAndTimeImageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    public lazy var assigneeImageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    public lazy var titleLabel: UILabel = {
        let titleLabel = UILabel(frame: .zero)
        titleLabel.backgroundColor = UIColor.clear
        titleLabel.font = UIFont.textFont(ofSize: 16.0, weight: UIFont.Weight.medium)
        titleLabel.numberOfLines = 2
        titleLabel.textColor = UIColor.dark
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.lineBreakMode = .byTruncatingTail
        return titleLabel
    }()
    public lazy var dateTimeLabel: UILabel = {
        let dateTimeLabel = UILabel(frame: .zero)
        dateTimeLabel.backgroundColor = UIColor.clear
        dateTimeLabel.textColor = UIColor.dark
        dateTimeLabel.font = UIFont.textFont(ofSize: 13, weight: UIFont.Weight.medium)
        dateTimeLabel.numberOfLines = 1
        dateTimeLabel.isUserInteractionEnabled = true
        dateTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        return dateTimeLabel
    }()
    public var assigneeLabel: UILabel = {
        let assigneeLabel = UILabel(frame: CGRect.zero)
        assigneeLabel.backgroundColor = UIColor.clear
        assigneeLabel.textColor = UIColor.dark
        assigneeLabel.font = UIFont.textFont(ofSize: 13.0, weight: UIFont.Weight.medium)
        assigneeLabel.numberOfLines = 1
        assigneeLabel.isUserInteractionEnabled = true
        assigneeLabel.translatesAutoresizingMaskIntoConstraints = false
        assigneeLabel.sizeToFit()
        return assigneeLabel
    }()
    public lazy var ownerLabel: UILabel = {
        let ownerLabel = UILabel(frame: CGRect.zero)
        ownerLabel.backgroundColor = UIColor.clear
        ownerLabel.textColor = UIColor.dark
        ownerLabel.font = UIFont.textFont(ofSize: 13.0, weight: UIFont.Weight.medium)
        ownerLabel.numberOfLines = 1
        ownerLabel.isUserInteractionEnabled = true
        ownerLabel.translatesAutoresizingMaskIntoConstraints = false
        ownerLabel.sizeToFit()
        return ownerLabel
    }()
    lazy var triangle: KRETriangleView = {
        let triangle = KRETriangleView(frame: .zero)
        triangle.backgroundColor = UIColor.clear
        triangle.translatesAutoresizingMaskIntoConstraints = false
        triangle.isUserInteractionEnabled = true
        let degrees: CGFloat = 90.0
        let radians: CGFloat = degrees * (.pi / 180)
        triangle.transform = CGAffineTransform(rotationAngle: radians)
        return triangle
    }()
    
    var moreButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.whiteTwo
        button.setImage(UIImage(named: "meetingAction"), for: .normal)
        return button
    }()
    
    public lazy var selectionView: UIButton = {
        var selectionView = UIButton(frame: .zero)
        selectionView.imageView?.contentMode = .scaleAspectFit
        selectionView.translatesAutoresizingMaskIntoConstraints = false
        return selectionView
    }()
    
    // MARK: - init
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    // MARK: -
    public func prepareForReuse() {
        isUserInteractionEnabled = true
        selectionViewWidthConstraint.constant = 0.0
        selectionViewLeadingConstraint.constant = 0.0
        selectionView.isSelected = false
        titleLabel.text = ""
        dateTimeLabel.text = ""
        assigneeLabel.text = ""
        ownerLabel.text = ""
    }
    
    // MARK: - initialize
    func initialize() {
        clipsToBounds = true
        backgroundColor = .clear
        
        containerView.addSubview(dateAndTimeImageView)
        containerView.addSubview(assigneeImageView)
        
        containerView.addSubview(triangle)
        containerView.addSubview(titleLabel)
        containerView.addSubview(dateTimeLabel)
        containerView.addSubview(assigneeLabel)
        containerView.addSubview(ownerLabel)
        containerView.addSubview(moreButton)
        
        selectionView.setImage(UIImage(named: "radio_on", in: bundle, compatibleWith: nil), for: .selected)
        selectionView.setImage(UIImage(named: "radio_off_btn", in: bundle, compatibleWith: nil), for: .normal)
        selectionView.addTarget(self, action: #selector(selectionChanged(_:)), for: UIControl.Event.touchUpInside)
        containerView.addSubview(selectionView)
        
        let views: [String: Any] = ["dateTimeLabel": dateTimeLabel, "assigneeLabel": assigneeLabel, "triangle": triangle, "titleLabel": titleLabel, "ownerLabel": ownerLabel, "selectionView": selectionView, "dateAndTimeImageView": dateAndTimeImageView, "assigneeImageView": assigneeImageView, "moreButton": moreButton]
        moreButton.layer.cornerRadius = 15.0
        //  containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[titleLabel]-10-[dateTimeLabel]-10-[assigneeLabel]-12-|", options: [], metrics: nil, views: views))
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[titleLabel]-10-[dateAndTimeImageView]-10-[assigneeImageView]-12-|", options: [], metrics: nil, views: views))
        
        // containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[dateTimeLabel]-10-[ownerLabel]-12-|", options: [], metrics: nil, views: views))
        //  containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[dateTimeLabel]-16-[triangle(8)]", options: [], metrics: nil, views: views))
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[selectionView]-10-[assigneeImageView]-[ownerLabel]-7-[triangle(11)]-7-[assigneeLabel]-10-|", options: [], metrics: nil, views: views))
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[selectionView]-10-[titleLabel]-40-|", options: [], metrics: nil, views: views))
        
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[moreButton(30)]-10-|", options: [], metrics: nil, views: views))
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[moreButton(30)]", options: [], metrics: nil, views: views))
        
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[selectionView]-10-[dateAndTimeImageView]-[dateTimeLabel]-10-|", options: [.alignAllBottom], metrics: nil, views: views))
        self.assigneeLabel.centerYAnchor.constraint(equalTo: assigneeImageView.centerYAnchor).isActive = true
        self.dateTimeLabel.centerYAnchor.constraint(equalTo: dateAndTimeImageView.centerYAnchor).isActive = true
        self.ownerLabel.centerYAnchor.constraint(equalTo: assigneeImageView.centerYAnchor).isActive = true
        self.triangle.centerYAnchor.constraint(equalTo: assigneeImageView.centerYAnchor).isActive = true
        self.assigneeLabel.centerYAnchor.constraint(equalTo: assigneeImageView.centerYAnchor).isActive = true
        self.triangle.heightAnchor.constraint(greaterThanOrEqualToConstant: 8).isActive = true
        selectionView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor, constant: 0.0).isActive = true
        selectionView.heightAnchor.constraint(equalToConstant: 22.0).isActive = true
        
        selectionViewWidthConstraint = NSLayoutConstraint(item: selectionView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 22.0)
        containerView.addConstraint(selectionViewWidthConstraint)
        selectionViewWidthConstraint.isActive = true
        
        selectionViewLeadingConstraint = NSLayoutConstraint(item: selectionView, attribute: .leading, relatedBy: .equal, toItem: containerView, attribute: .leading, multiplier: 1.0, constant: 15.0)
        containerView.addConstraint(selectionViewLeadingConstraint)
        selectionViewLeadingConstraint.isActive = true
        
        ownerLabel.setContentHuggingPriority(UILayoutPriority.defaultHigh, for: .horizontal)
        assigneeLabel.setContentHuggingPriority(UILayoutPriority.defaultLow, for: .horizontal)
        ownerLabel.setContentCompressionResistancePriority(UILayoutPriority.defaultLow, for: .horizontal)
        assigneeLabel.setContentCompressionResistancePriority(UILayoutPriority.defaultHigh, for: .horizontal)
        
        dateAndTimeImageView.widthAnchor.constraint(equalToConstant: 15.0).isActive = true
        dateAndTimeImageView.heightAnchor.constraint(equalToConstant: 15.0).isActive = true
        assigneeImageView.widthAnchor.constraint(equalToConstant: 19.0).isActive = true
        assigneeImageView.heightAnchor.constraint(equalToConstant: 19.0).isActive = true
        addSubview(containerView)
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-4-[containerView]-4-|", options: [], metrics: nil, views: ["containerView": containerView]))
        containerViewLeadingConstraint = NSLayoutConstraint(item:containerView, attribute:.leading, relatedBy:.equal, toItem: self, attribute:.leading, multiplier:1.0, constant: 0.0)
        addConstraint(containerViewLeadingConstraint)
        containerViewTrailingConstraint = NSLayoutConstraint(item: self, attribute:.trailing, relatedBy:.equal, toItem: containerView, attribute:.trailing, multiplier:1.0, constant: 0.0)
        addConstraint(containerViewTrailingConstraint)
        moreButton.addTarget(self, action: #selector(taskMoreButtonAction(_:)), for: .touchUpInside)
        
    }
    
    func showSelectionView(_ show: Bool) {
        if show {
            selectionViewWidthConstraint.constant = 22.0
            selectionViewLeadingConstraint.constant = 15.0
        } else {
            selectionViewWidthConstraint.constant = 0.0
            selectionViewLeadingConstraint.constant = 0.0
        }
        layoutSubviews()
    }
    
    // MARK: -
    @objc func selectionChanged(_ sender: UIButton) {
        itemSelectionHandler?(self)
    }
    
    @objc func taskMoreButtonAction(_ sender: UIButton) {
        moreSelectionHandler?(self)
    }
    
    func loadingDataState() {
        titleLabel.text = "Test"
        dateTimeLabel.text = "Test"
        assigneeLabel.text = "Test"
        titleLabel.textColor = UIColor.paleGrey
        titleLabel.backgroundColor = .paleGrey
        dateTimeLabel.textColor = UIColor.paleGrey
        dateTimeLabel.backgroundColor = .paleGrey
        assigneeLabel.textColor = UIColor.paleGrey
        assigneeLabel.backgroundColor = .paleGrey
        selectionView.isHidden = true
        selectionViewWidthConstraint.constant = 0.0
        selectionViewLeadingConstraint.constant = 0.0
        moreButton.isHidden = true
        triangle.isHidden = true
        
        assigneeImageView.image = nil
        assigneeImageView.backgroundColor = .paleGrey
        
        dateAndTimeImageView.image = nil
        dateAndTimeImageView.backgroundColor = .paleGrey
    }
    
    func loadedDataState() {
        titleLabel.textColor = UIColor.dark
        titleLabel.backgroundColor = .clear
        dateTimeLabel.textColor = UIColor.dark
        dateTimeLabel.backgroundColor = .clear
        assigneeLabel.textColor = UIColor.dark
        assigneeLabel.backgroundColor = .clear
        moreButton.isHidden = false
        triangle.isHidden = false
        
        let dateAndTimeImage = UIImage(named: "timer", in: bundle, compatibleWith: nil)
        dateAndTimeImageView.image = dateAndTimeImage
        dateAndTimeImageView.backgroundColor = .clear
        
        let assigneeImage = UIImage(named: "assignee", in: bundle, compatibleWith: nil)
        assigneeImageView.image = assigneeImage
        assigneeImageView.backgroundColor = .clear
    }
    
    // MARK:- deinit
    deinit {
        
    }
}
