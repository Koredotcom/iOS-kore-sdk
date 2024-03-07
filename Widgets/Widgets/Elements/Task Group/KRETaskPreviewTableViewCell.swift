//import KoreBotSDK

open class KRETaskPreviewTableViewCell: UITableViewCell {
    // MARK: - properties
    let bundle = Bundle(for: KRETaskPreviewTableViewCell.self)
  public var itemSelectionHandler:((KRETaskPreviewTableViewCell) -> Void)?
    public var selectionViewWidthConstraint: NSLayoutConstraint!
    public var selectionViewLeadingConstraint: NSLayoutConstraint!
    
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
        titleLabel.textColor = UIColor.gunmetal
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.lineBreakMode = .byTruncatingTail
        return titleLabel
    }()

    public lazy var dateTimeLabel: UILabel = {
        let dateTimeLabel = UILabel(frame: .zero)
        dateTimeLabel.backgroundColor = UIColor.clear
        //dateTimeLabel.textColor = UIColor.gunmetal
        dateTimeLabel.font = UIFont.textFont(ofSize: 13, weight: UIFont.Weight.medium)
        dateTimeLabel.numberOfLines = 1
        dateTimeLabel.isUserInteractionEnabled = true
        dateTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        return dateTimeLabel
    }()
    public var assigneeLabel: UILabel = {
        let assigneeLabel = UILabel(frame: CGRect.zero)
        assigneeLabel.backgroundColor = UIColor.clear
        assigneeLabel.textColor = UIColor.gunmetal
        if #available(iOS 8.2, *) {
            assigneeLabel.font = UIFont.textFont(ofSize: 13.0, weight: UIFont.Weight.medium)
        } else {
            // Fallback on earlier versions
        }
        if #available(iOS 8.2, *) {
            assigneeLabel.font = UIFont.textFont(ofSize: 13.0, weight: UIFont.Weight.medium)
        } else {
            // Fallback on earlier versions
        }
        assigneeLabel.numberOfLines = 1
        assigneeLabel.isUserInteractionEnabled = true
        assigneeLabel.translatesAutoresizingMaskIntoConstraints = false
        assigneeLabel.sizeToFit()
        return assigneeLabel
    }()

    public lazy var ownerLabel: UILabel = {
        let ownerLabel = UILabel(frame: CGRect.zero)
        ownerLabel.backgroundColor = UIColor.clear
        ownerLabel.textColor = UIColor.gunmetal
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
    
    // MARK: -
    override open func prepareForReuse() {
        super.prepareForReuse()
        isUserInteractionEnabled = true
        selectionViewWidthConstraint.constant = 0.0
        selectionViewLeadingConstraint.constant = 0.0
        selectionView.isSelected = false
        if #available(iOS 8.2, *) {
            titleLabel.text = ""
        } else {
            // Fallback on earlier versions
        }
        if #available(iOS 8.2, *) {
            dateTimeLabel.text = ""
        } else {
            // Fallback on earlier versions
        }
        assigneeLabel.text = ""
            ownerLabel.text = ""
       
    }
    
    // MARK: - initialize
    func initialize() {
        selectionStyle = .none
        clipsToBounds = true
        backgroundColor = .clear
        
        let dateAndTimeImage = UIImage(named: "timer", in: bundle, compatibleWith: nil)
        dateAndTimeImageView.image = dateAndTimeImage
        containerView.addSubview(dateAndTimeImageView)
        
        let assigneeImage = UIImage(named: "assignee", in: bundle, compatibleWith: nil)
        assigneeImageView.image = assigneeImage
        containerView.addSubview(assigneeImageView)
        
        
        containerView.addSubview(triangle)
        if #available(iOS 8.2, *) {
            containerView.addSubview(titleLabel)
        } else {
            // Fallback on earlier versions
        }
        if #available(iOS 8.2, *) {
            containerView.addSubview(dateTimeLabel)
        } else {
            // Fallback on earlier versions
        }
        containerView.addSubview(assigneeLabel)
        if #available(iOS 8.2, *) {
            containerView.addSubview(ownerLabel)
        } else {
            // Fallback on earlier versions
        }
        
        selectionView.setImage(UIImage(named: "radio_on", in: bundle, compatibleWith: nil), for: .selected)
        selectionView.setImage(UIImage(named: "radio_off_btn", in: bundle, compatibleWith: nil), for: .normal)
        selectionView.addTarget(self, action: #selector(selectionChanged(_:)), for: UIControl.Event.touchUpInside)
        containerView.addSubview(selectionView)
        
//        if #available(iOS 8.2, *) {
            let views: [String: Any] = ["dateTimeLabel": dateTimeLabel, "assigneeLabel": assigneeLabel, "triangle": triangle, "titleLabel": titleLabel, "ownerLabel": ownerLabel, "selectionView": selectionView, "dateAndTimeImageView": dateAndTimeImageView, "assigneeImageView": assigneeImageView]
//        } else {
//            // Fallback on earlier versions
//        }
        if #available(iOS 8.2, *) {
            let views: [String: Any] = ["dateTimeLabel": dateTimeLabel, "assigneeLabel": assigneeLabel, "triangle": triangle, "titleLabel": titleLabel, "ownerLabel": ownerLabel, "selectionView": selectionView, "dateAndTimeImageView": dateAndTimeImageView, "assigneeImageView": assigneeImageView]
        } else {
            // Fallback on earlier versions
        }
        if #available(iOS 8.2, *) {
            let views: [String: Any] = ["dateTimeLabel": dateTimeLabel, "assigneeLabel": assigneeLabel, "triangle": triangle, "titleLabel": titleLabel, "ownerLabel": ownerLabel, "selectionView": selectionView, "dateAndTimeImageView": dateAndTimeImageView, "assigneeImageView": assigneeImageView]
        } else {
            // Fallback on earlier versions
        }
        
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[titleLabel]-10-[dateTimeLabel]-10-[assigneeLabel]-12-|", options: [], metrics: nil, views: views))
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[titleLabel]-10-[dateAndTimeImageView]-10-[assigneeImageView]-12-|", options: [], metrics: nil, views: views))
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[dateTimeLabel]-10-[ownerLabel]-12-|", options: [], metrics: nil, views: views))
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[dateTimeLabel]-16-[triangle(8)]", options: [], metrics: nil, views: views))
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[selectionView]-15-[assigneeImageView]-[ownerLabel]-7-[triangle(11)]-7-[assigneeLabel]|", options: [], metrics: nil, views: views))
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[selectionView]-15-[titleLabel]|", options: [], metrics: nil, views: views))
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[selectionView]-15-[dateAndTimeImageView]-[dateTimeLabel]|", options: [.alignAllBottom], metrics: nil, views: views))
        
        if #available(iOS 9.0, *) {
            selectionView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor, constant: 0.0).isActive = true
        } else {
            // Fallback on earlier versions
        }
        if #available(iOS 9.0, *) {
            selectionView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor, constant: 0.0).isActive = true
        } else {
            // Fallback on earlier versions
        }
        if #available(iOS 9.0, *) {
            selectionView.heightAnchor.constraint(equalToConstant: 22.0).isActive = true
        } else {
            // Fallback on earlier versions
        }
        
        selectionViewWidthConstraint = NSLayoutConstraint(item: selectionView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 22.0)
        containerView.addConstraint(selectionViewWidthConstraint)
        selectionViewWidthConstraint.isActive = true
        
        selectionViewLeadingConstraint = NSLayoutConstraint(item: selectionView, attribute: .leading, relatedBy: .equal, toItem: containerView, attribute: .leading, multiplier: 1.0, constant: 15.0)
        containerView.addConstraint(selectionViewLeadingConstraint)
        selectionViewLeadingConstraint.isActive = true
        
        if #available(iOS 8.2, *) {
            ownerLabel.setContentHuggingPriority(UILayoutPriority.defaultHigh, for: .horizontal)
        } else {
            // Fallback on earlier versions
        }
        assigneeLabel.setContentHuggingPriority(UILayoutPriority.defaultLow, for: .horizontal)
        if #available(iOS 8.2, *) {
            ownerLabel.setContentCompressionResistancePriority(UILayoutPriority.defaultLow, for: .horizontal)
        } else {
            // Fallback on earlier versions
        }
        assigneeLabel.setContentCompressionResistancePriority(UILayoutPriority.defaultHigh, for: .horizontal)
        
        if #available(iOS 9.0, *) {
            dateAndTimeImageView.widthAnchor.constraint(equalToConstant: 15.0).isActive = true
        } else {
            // Fallback on earlier versions
        }
        if #available(iOS 9.0, *) {
            dateAndTimeImageView.heightAnchor.constraint(equalToConstant: 15.0).isActive = true
        } else {
            // Fallback on earlier versions
        }
        if #available(iOS 9.0, *) {
            assigneeImageView.widthAnchor.constraint(equalToConstant: 19.0).isActive = true
        } else {
            // Fallback on earlier versions
        }
        if #available(iOS 9.0, *) {
            assigneeImageView.heightAnchor.constraint(equalToConstant: 19.0).isActive = true
        } else {
            // Fallback on earlier versions
        }
        contentView.addSubview(containerView)
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-4-[containerView]-4-|", options: [], metrics: nil, views: ["containerView": containerView]))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[containerView]|", options: [], metrics: nil, views: ["containerView": containerView]))
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
    
    // MARK:- deinit
    deinit {
        
    }
}
