//
//  KRECalendarEventCell.swift.swift
//  KoreBotSDK
//
//  Created by Srinivas Vasadi on 13/03/19.
//  Copyright © 2019 Srinivas Vasadi. All rights reserved.
//

import UIKit

// MARK: - KRECustomWidgetTableViewCell
public class KRECustomWidgetTableViewCell: UITableViewCell {
    // MARK: - properties
    let bundle = Bundle.sdkModule
    public var widgetView: KRECustomWidgetView = {
        let widgetView = KRECustomWidgetView(frame: .zero)
        widgetView.translatesAutoresizingMaskIntoConstraints = false
        return widgetView
    }()
    
    // MARK: - init
    public convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    // MARK: - setup
    func setup() {
        selectionStyle = .none
        clipsToBounds = true
        contentView.addSubview(widgetView)
        
        let views: [String: Any] = ["widgetView": widgetView]
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[widgetView]|", options: [], metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[widgetView]|", options: [], metrics: nil, views: views))
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
    }
}

// MARK: - KRECustomWidgetView
public class KRECustomWidgetView: UIView {
    let bundle = Bundle.sdkModule
    public var moreSelectionHandler:((KRECustomWidgetView) -> Void)?
    public var yesButtonAction:((KRECustomWidgetView) -> Void)?
    public var noButtonAction:((KRECustomWidgetView) -> Void)?
    public var mayBeButtonAction:((KRECustomWidgetView) -> Void)?
    
    // MARK: - properties
    public lazy var headingLabel: UILabel = {
        var headingLabel: UILabel = UILabel(frame: .zero)
        headingLabel.translatesAutoresizingMaskIntoConstraints = false
        headingLabel.font = UIFont.textFont(ofSize: 16.0, weight: .bold)
        headingLabel.textColor = UIColor.gunmetal
        headingLabel.textAlignment = .left
        headingLabel.lineBreakMode = .byWordWrapping
        headingLabel.numberOfLines = 0
        return headingLabel
    }()
    
    public lazy var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.textFont(ofSize: 14.0, weight: .semibold)
        label.textColor = UIColor.charcoalGrey
        label.text = "Starting in 5 mins"
        label.layer.masksToBounds = true
        label.textAlignment = NSTextAlignment.left
        label.numberOfLines = 0
        return label
    }()
    
    public lazy var descriptionLabel: UILabel = {
        var label: UILabel = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.textFont(ofSize: 12.0, weight: .regular)
        label.textColor = UIColor.gunmetal
        label.textAlignment = .left
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        return label
    }()
    
    public lazy var utterancesView: KREButonActionsCollectionView = {
        let utterancesView = KREButonActionsCollectionView(frame: .zero)
        utterancesView.backgroundColor = UIColor.clear
        utterancesView.translatesAutoresizingMaskIntoConstraints = false
        return utterancesView
    }()
    
    public let profileImageView: UIImageView = {
      let imageView = UIImageView(frame: .zero)
      imageView.contentMode = .scaleAspectFit
      imageView.clipsToBounds = true
      imageView.translatesAutoresizingMaskIntoConstraints = false
      return imageView
    }()
    
    public var moreButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.whiteTwo
        button.setImage(UIImage(named: "meetingAction"), for: .normal)
        return button
    }()

    public var titleTimerStackBottom: NSLayoutConstraint!
    public lazy var meetingSlotTimerStackView: UIStackView = {
        let meetingSlotTimerStackView = UIStackView()
        meetingSlotTimerStackView.axis = .horizontal
        meetingSlotTimerStackView.distribution = UIStackView.Distribution.fill
        meetingSlotTimerStackView.alignment = UIStackView.Alignment.center
        meetingSlotTimerStackView.spacing = 4.0
        meetingSlotTimerStackView.translatesAutoresizingMaskIntoConstraints = false
        return meetingSlotTimerStackView
    }()
    
    public lazy var parentStackView: UIStackView = {
        let parentStackView = UIStackView()
        parentStackView.axis = .horizontal
        parentStackView.distribution = UIStackView.Distribution.fill
        parentStackView.alignment = UIStackView.Alignment.leading
        parentStackView.spacing = 10.0
        parentStackView.translatesAutoresizingMaskIntoConstraints = false
        return parentStackView
    }()

    public lazy var titleTimerStackView: UIStackView = {
        let titleTimerStackView = UIStackView()
        titleTimerStackView.axis = .vertical
        titleTimerStackView.distribution = UIStackView.Distribution.fill
        titleTimerStackView.alignment = UIStackView.Alignment.top
        titleTimerStackView.spacing = 4.0
        titleTimerStackView.translatesAutoresizingMaskIntoConstraints = false
        return titleTimerStackView
    }()
    
    // MARK: - init
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    // MARK: properties with observers
    public func prepareForReuse() {
        titleLabel.text = ""
        descriptionLabel.text = ""
        headingLabel.text = ""
        titleTimerStackView.spacing = 4.0
        parentStackView.spacing = 10.0
        profileImageView.image = nil
        utterancesView.prepareForReuse()
    }
    
    func setup() {
        clipsToBounds = true
        addSubview(parentStackView)
        addSubview(profileImageView)
        addSubview(moreButton)
        addSubview(titleTimerStackView)
        utterancesView.heightAnchor.constraint(equalToConstant: 32.0).isActive = true
        titleTimerStackView.addArrangedSubview(headingLabel)
        titleTimerStackView.addArrangedSubview(titleLabel)
        titleTimerStackView.addArrangedSubview(descriptionLabel)
        if #available(iOS 11.0, *) {
            titleTimerStackView.setCustomSpacing(8.0, after: descriptionLabel)
        } else {
            // Fallback on earlier versions
        }
        titleTimerStackView.addArrangedSubview(utterancesView)
        self.utterancesView.isHidden = false
        let views: [String: UIView] = ["profileImageView": profileImageView, "titleTimerStackView": titleTimerStackView, "moreButton": moreButton, "utterancesView": utterancesView, "parentStackView": parentStackView]
        titleTimerStackView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[utterancesView]-|", options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[moreButton(30)]-10-|", options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[moreButton(30)]", options: [], metrics: nil, views: views))
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[parentStackView]-|", options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[parentStackView]-|", options: [], metrics: nil, views: views))
        
        profileImageView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 80).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        moreButton.addTarget(self, action: #selector(meetingsMoreButtonAction(_:)), for: .touchUpInside)
        parentStackView.addArrangedSubview(profileImageView)
        parentStackView.addArrangedSubview(titleTimerStackView)
    }
    
    @objc func meetingsMoreButtonAction(_ sender: UIButton) {
        moreSelectionHandler?(self)
    }
    
    @objc func meetingsNotesButtonAction(_ sender: UIButton) {
        
    }
    
    @objc func meetingsDialInButtonAction(_ sender: UIButton) {
        
    }
    
    @objc func meetingsJoinInButtonAction(_ sender: UIButton) {
        
    }
    
    func loadingDataState() {
        headingLabel.text = "Testfdrererererererere"
        titleLabel.text = "Testfdrererererererere"
        descriptionLabel.text = "Testfdrererererererere"
        headingLabel.textColor = UIColor.paleGrey
        headingLabel.backgroundColor = .paleGrey
        titleLabel.textColor = .paleGrey
        titleLabel.backgroundColor = .paleGrey
        descriptionLabel.textColor = UIColor.paleGrey
        descriptionLabel.backgroundColor = .paleGrey
        profileImageView.backgroundColor = .paleGrey
        moreButton.isHidden = true
    }
    
    func loadedDataState() {
        titleLabel.textColor = UIColor.charcoalGrey
        titleLabel.backgroundColor = .clear
        headingLabel.textColor = .gunmetal
        headingLabel.backgroundColor = .clear
        descriptionLabel.textColor = .gunmetal
        descriptionLabel.backgroundColor = .clear
        profileImageView.backgroundColor = .clear
        moreButton.isHidden = false
    }
    
    // MARK:- deinit
    deinit {
        
    }
}

public class KREButonActionsCollectionView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    public var actions: [KREButtonTemplate]? {
        didSet {
            collectionView.reloadData()
        }
    }
    var widget: KREWidget?
    var collectionView: UICollectionView!
    public var titleLabel: UILabel = {
        let textLabel = UILabel(frame: .zero)
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.textColor = UIColor.lightGreyBlue
        textLabel.font = UIFont.textFont(ofSize: 14.0, weight: .medium)
        textLabel.clipsToBounds = true
        return textLabel
    }()
    var prototypeCell = KREUtteranceCollectionViewCell()
   public var utteranceClickAction: ((KREButtonTemplate?) -> Void)?
    var collectionViewHeightConstraint: NSLayoutConstraint!
    
    let cellHeight: CGFloat = 36.0
    
    // MARK:- init
    override public init (frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    convenience public init () {
        self.init(frame: .zero)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    //MARK:- removing refernces to elements
    public func prepareForReuse() {
        titleLabel.text = nil
        actions = nil
    }
    
    // MARK:- setup collectionView
    func setup() {
        backgroundColor = UIColor.clear
        addSubview(titleLabel)
        
        // configure layout
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = UICollectionView.ScrollDirection.horizontal
        flowLayout.minimumInteritemSpacing = 10.0
        flowLayout.minimumLineSpacing = 1
        
        // collectionView initialization
        collectionView = UICollectionView(frame: bounds, collectionViewLayout: flowLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = UIColor.clear
        collectionView.bounces = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        addSubview(collectionView)
        
        collectionView.semanticContentAttribute = .unspecified
        
        // register
        collectionView.register(KREUtteranceCollectionViewCell.self, forCellWithReuseIdentifier: "KREUtteranceCollectionViewCell")
        
        let views: [String: Any] = ["collectionView": collectionView, "titleLabel": titleLabel]
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-5-[collectionView]-5-|", options:[], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[titleLabel]|", options:[], metrics: nil, views: views))
        let yConstraint = NSLayoutConstraint(item: collectionView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0.0)
        addConstraint(yConstraint)
        collectionView.semanticContentAttribute = .forceLeftToRight
        
        collectionViewHeightConstraint = NSLayoutConstraint.init(item: collectionView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: cellHeight)
        collectionViewHeightConstraint.isActive = true
        addConstraint(collectionViewHeightConstraint)
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
    }
    
    // MARK: -
    public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return actions?.count ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "KREUtteranceCollectionViewCell", for: indexPath)
        if let collectionViewCell = cell as? KREUtteranceCollectionViewCell, let action = actions?[indexPath.row] {
            collectionViewCell.textLabel.text = action.title
            if let themeColor = action.theme {
                collectionViewCell.textLabel.textColor = UIColor(hexString: themeColor)
            }
            collectionViewCell.contentView.layer.shadowColor = UIColor.gunmetal.cgColor
            collectionViewCell.contentView.layer.borderColor = UIColor.purpleishBlue.cgColor
            collectionViewCell.contentView.layer.cornerRadius = 4.0
            collectionViewCell.contentView.layer.shadowRadius = 7.0
            collectionViewCell.contentView.layer.masksToBounds = false
            collectionViewCell.contentView.layer.borderWidth = 1.0
            collectionViewCell.contentView.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
            collectionViewCell.contentView.layer.shadowOpacity = 0.1
        }
        cell.layoutIfNeeded()
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? KREUtteranceCollectionViewCell, let action = actions?[indexPath.row] {
            utteranceClickAction?(action)
        }
    }
    
    // MARK: - UICollectionViewDelegateContactFlowLayout
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var width: CGFloat = 0.0
        if let utterance = actions?[indexPath.row].title {
            width = prototypeCell.widthForCell(string: utterance, height: cellHeight)
        }
        return CGSize(width: width, height: cellHeight)
    }
    
    // MARK: - deinit
    deinit {
        actions = nil
    }
}

public class KRECustomSepratorTableViewCell: UITableViewCell {
    // MARK: - init
   var sepratorView = UIImageView(frame: .zero)
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initialize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    // MARK: properties with observers
    override public func prepareForReuse() {
    }
    
    func initialize() {
        sepratorView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(sepratorView)
        sepratorView.backgroundColor = .paleLilac
        let views = ["sepratorView": sepratorView]
        sepratorView.heightAnchor.constraint(equalToConstant: 8.0).isActive = true
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[sepratorView]|", options: [], metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[sepratorView(8.0)]|", options: [], metrics: nil, views: views))

    }
}
