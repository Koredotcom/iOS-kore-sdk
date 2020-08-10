//
//  KREMeetingDetailsTableViewCell.swift
//  KoreBotSDK
//
//  Created by Sukhmeet Singh on 15/05/19.
//

import UIKit

class KREMeetingDetailsTableViewCell: UITableViewCell {
    
    var growingTextView: KREGrowingTextView = {
        let growingTextView = KREGrowingTextView(frame: CGRect.zero)
        growingTextView.translatesAutoresizingMaskIntoConstraints = false
        growingTextView.textView.font = UIFont.textFont(ofSize: 34, weight: .medium)
        growingTextView.textView.tintColor = UIColor.lightRoyalBlue
        growingTextView.setContentCompressionResistancePriority(UILayoutPriority.defaultLow, for: .horizontal)
        return growingTextView
    }()
    // MARK: -init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    // MARK: properties with observers
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func initialize() {
        self.selectionStyle = .none
        contentView.addSubview(growingTextView)
        // Setting Constraints
        let views: [String: UIView] = ["growingTextView": growingTextView]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat:
            "H:|[growingTextView]|", options:[], metrics:nil, views:views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat:
            "V:|[growingTextView]|", options:[], metrics:nil, views:views))
    }
    
    // MARK:- deinit
    deinit {
        
    }
}

class KREMeetingSlotAndLocationTableViewCell: UITableViewCell {
    // MARK: -init
    let bundle = Bundle(for: KREMeetingSlotAndLocationTableViewCell.self)
    var parentStackView = UIStackView()
    var meetingSlotView = UIView()
    var meetingSingleSlotStackView = UIStackView()
    var meetingSlotTimerStackView = UIView(frame: .zero)
    var meetingLocationStackView = UIStackView()
    var meeetingKindStackView = UIStackView()
    var meetingSlot: String? {
        didSet {
            self.tableView.reloadData()
        }
    }
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.separatorColor = .clear
        tableView.backgroundColor = .white
        tableView.bounces = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    var clockImageView: UIImageView = {
        var imageView: UIImageView = UIImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = UIView.ContentMode.scaleAspectFit
        imageView.clipsToBounds = true
        imageView.backgroundColor = UIColor.white
        return imageView
    }()
    
    var locationImageView: UIImageView = {
        var imageView: UIImageView = UIImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = UIView.ContentMode.center
        imageView.clipsToBounds = true
        imageView.backgroundColor = UIColor.white
        return imageView
    }()
    
    var dotImageView: UIImageView = {
        var imageView: UIImageView = UIImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = UIView.ContentMode.center
        imageView.clipsToBounds = true
        imageView.backgroundColor = UIColor.red
        return imageView
    }()

    var meetingImageView: UIImageView = {
        var imageView: UIImageView = UIImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = UIView.ContentMode.center
        imageView.clipsToBounds = true
        imageView.backgroundColor = UIColor.white
        return imageView
    }()
    
    var initialsLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.textFont(ofSize: 17.0, weight: .medium)
        label.textColor = UIColor.charcoalGrey
        label.layer.masksToBounds = true
        label.numberOfLines = 0
        label.textAlignment = NSTextAlignment.left
        return label
    }()
    
    var locationLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.textFont(ofSize: 17.0, weight: .medium)
        label.textColor = UIColor.charcoalGrey
        label.layer.masksToBounds = true
        label.numberOfLines = 0
        label.textAlignment = NSTextAlignment.left
        return label
    }()
    
    var linkLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.textFont(ofSize: 17.0, weight: .medium)
        label.textColor = UIColor.charcoalGrey
        label.layer.masksToBounds = true
        label.numberOfLines = 0
        label.textAlignment = NSTextAlignment.left
        return label
    }()
    
    var timerLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.textFont(ofSize: 12.0, weight: .regular)
        label.textColor = UIColor.battleshipGrey
        label.layer.masksToBounds = true
        label.textAlignment = NSTextAlignment.left
        return label
    }()

    var tableviewHeightConstraint: NSLayoutConstraint!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    // MARK: properties with observers
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    override func layoutSubviews() {
    }
    
    func initialize() {
        contentView.addSubview(parentStackView)
        tableView.register(KREMeetingSlotTableViewCell.self, forCellReuseIdentifier: "KREMeetingSlotTableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
        let dateAndTimeImage = UIImage(named: "timer", in: bundle, compatibleWith: nil)
        clockImageView.image = dateAndTimeImage
        
        let assigneeImage = UIImage(named: "location", in: bundle, compatibleWith: nil)
        locationImageView.image = assigneeImage
        
        let meetingImage = UIImage(named: "shape", in: bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        meetingImageView.image = meetingImage
        meetingImageView.tintColor = UIColor.lightGreyBlue
        locationImageView.widthAnchor.constraint(equalToConstant: 20.0).isActive = true
        locationImageView.heightAnchor.constraint(equalToConstant: 20.0).isActive = true
        meetingImageView.widthAnchor.constraint(equalToConstant: 20.0).isActive = true
        meetingImageView.heightAnchor.constraint(equalToConstant: 20.0).isActive = true
        clockImageView.widthAnchor.constraint(equalToConstant: 20.0).isActive = true
        clockImageView.heightAnchor.constraint(equalToConstant: 20.0).isActive = true
        dotImageView.widthAnchor.constraint(equalToConstant: 8.0).isActive = true
        dotImageView.heightAnchor.constraint(equalToConstant: 8.0).isActive = true
        dotImageView.layer.cornerRadius = 4.0
        dotImageView.backgroundColor = UIColor.orangeyRed
        meetingSlotView.addSubview(clockImageView)
        meetingSlotView.addSubview(tableView)
        meetingSlotView.translatesAutoresizingMaskIntoConstraints = false
        
        let views = ["clockImageView": clockImageView, "tableView": tableView]
        meetingSlotView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[clockImageView(55)][tableView]|", options:[], metrics:nil, views: views))
        meetingSlotView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[tableView(>=44)]|", options:[], metrics:nil, views: views))
        
        meetingSlotView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[clockImageView(40)]|", options:[], metrics:nil, views: views))
//        meetingSlotTimerStackView.axis = .horizontal
//        meetingSlotTimerStackView.distribution = UIStackView.Distribution.equalSpacing
//        meetingSlotTimerStackView.alignment = UIStackView.Alignment.fill
//        meetingSlotTimerStackView.spacing   = 0.0
        meetingSlotTimerStackView.addSubview(dotImageView)
        meetingSlotTimerStackView.addSubview(timerLabel)
        meetingSlotTimerStackView.translatesAutoresizingMaskIntoConstraints = false

        let viewTimer = ["dotImageView": dotImageView, "timerLabel": timerLabel]
        meetingSlotTimerStackView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-40-[dotImageView]-4-[timerLabel]|", options:[], metrics:nil, views: viewTimer))
        meetingSlotTimerStackView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[timerLabel(>=14)]|", options:[], metrics:nil, views: viewTimer))
        dotImageView.centerYAnchor.constraint(equalTo: self.timerLabel.centerYAnchor, constant: 0.0).isActive = true

        meetingSingleSlotStackView.axis = .horizontal
        meetingSingleSlotStackView.distribution = UIStackView.Distribution.fill
        meetingSingleSlotStackView.alignment = UIStackView.Alignment.center
        meetingSingleSlotStackView.spacing = 20.0
        meetingSingleSlotStackView.addArrangedSubview(clockImageView)
        meetingSingleSlotStackView.addArrangedSubview(initialsLabel)
        meetingSingleSlotStackView.translatesAutoresizingMaskIntoConstraints = false

        meetingLocationStackView.axis = .horizontal
        meetingLocationStackView.distribution = UIStackView.Distribution.fill
        meetingLocationStackView.alignment = UIStackView.Alignment.center
        meetingLocationStackView.spacing = 20.0
        meetingLocationStackView.addArrangedSubview(locationImageView)
        meetingLocationStackView.addArrangedSubview(locationLabel)
        meetingLocationStackView.translatesAutoresizingMaskIntoConstraints = false
        
        meeetingKindStackView.axis = .horizontal
        meeetingKindStackView.distribution = UIStackView.Distribution.fill
        meeetingKindStackView.alignment = UIStackView.Alignment.center
        meeetingKindStackView.spacing = 20.0
        meeetingKindStackView.addArrangedSubview(meetingImageView)
        meeetingKindStackView.addArrangedSubview(linkLabel)
        meeetingKindStackView.translatesAutoresizingMaskIntoConstraints = false
        
        let viewsParent = ["parentStackView": parentStackView]
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-14-[parentStackView]|", options:[], metrics:nil, views: viewsParent))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-13.5-[parentStackView]-13.5-|", options:[], metrics:nil, views: viewsParent))
        parentStackView.axis = .vertical
        parentStackView.distribution = UIStackView.Distribution.equalSpacing
        parentStackView.alignment = UIStackView.Alignment.fill
        parentStackView.spacing   = 10.0
        parentStackView.addArrangedSubview(meetingSingleSlotStackView)
        parentStackView.addArrangedSubview(meetingSlotTimerStackView)
        parentStackView.addArrangedSubview(meetingLocationStackView)
        parentStackView.addArrangedSubview(meeetingKindStackView)
        parentStackView.translatesAutoresizingMaskIntoConstraints = false
        tableviewHeightConstraint = NSLayoutConstraint.init(item: tableView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 44.0)
        meetingSlotView.addConstraint(tableviewHeightConstraint)
    }
}

extension KREMeetingSlotAndLocationTableViewCell: UITableViewDelegate, UITableViewDataSource
{
    // MARK: UITableViewDatasource
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cellIdentifier = "KREMeetingSlotTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? KREMeetingSlotTableViewCell
        cell?.titleLabel.text = meetingSlot
        cell?.textLabel?.textColor = .charcoalGrey
        cell?.titleLabel.numberOfLines = 1
        cell?.titleLabel.font = UIFont.textFont(ofSize: 17.0, weight: .medium)
        cell?.titleLabelLeadingConstraint.constant = 0
        cell?.layoutSubviews()
        return cell ?? UITableViewCell()
    }
    
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    // MARK: - UITableViewDelegate
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 26
    }
    
    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 26
    }
    
    
}



class KREMeetingSlotTableViewCell: UITableViewCell {
    var titleLabelLeadingConstraint: NSLayoutConstraint!
    var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.textFont(ofSize: 25.0, weight: .medium)
        label.textColor = UIColor.charcoalGrey
        label.textAlignment = NSTextAlignment.left
        label.numberOfLines = 0
        return label
    }()
    // MARK: -init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    // MARK: properties with observers
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func initialize() {
        self.selectionStyle = .none
        contentView.addSubview(titleLabel)
        // Setting Constraints
        let views: [String: UIView] = ["titleLabel": titleLabel]
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat:
            "H:[titleLabel]-14-|", options:[], metrics:nil, views:views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat:
            "V:|-15-[titleLabel]|", options:[], metrics:nil, views:views))
        titleLabelLeadingConstraint = NSLayoutConstraint(item: titleLabel, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1.0, constant: 14.0)
        contentView.addConstraint(titleLabelLeadingConstraint)
        titleLabelLeadingConstraint.isActive = true

    }
    
    // MARK:- deinit
    deinit {
        
    }
}

class KREMeetingGoingOptionTableViewCell: UITableViewCell {
    lazy var buttonTitleAttributes: [NSAttributedString.Key: Any] = {
        return [.font: UIFont.textFont(ofSize: 15.0, weight: .medium), .foregroundColor: UIColor.lightRoyalBlue, .kern: 1.87]
    }()
    var collectionViewIdentifier = "KRESegmentButtonsCollectionViewCell"
    var goingString = ["Yes", "No", "Maybe"]
    var isSelectedButton = false
    let buttonMaxHeight: CGFloat = 41.0
    var selectedButtonIndex = 0
    var yesNoStackView = UIStackView()
   
    lazy var yesButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        button.backgroundColor = .white
        button.layer.borderColor = UIColor.paleLilacTwo.cgColor
        button.layer.borderWidth = 1.0
        button.layer.cornerRadius = 4.0
        button.setTitleColor(UIColor.dark, for: .normal)
        return button
    }()

    lazy var noButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        button.backgroundColor = .white
        button.layer.borderColor = UIColor.paleLilacTwo.cgColor
        button.layer.borderWidth = 1.0
        button.layer.cornerRadius = 4.0
        button.setTitleColor(UIColor.dark, for: .normal)
        return button
    }()
    
    func selectYesButton(flag: Bool) {
        if flag {
            self.yesButton.backgroundColor = UIColor.lightRoyalBlue
            self.yesButton.setTitleColor(UIColor.white, for: .normal)
        } else {
            self.yesButton.backgroundColor = UIColor.white
            self.yesButton.setTitleColor(UIColor.dark, for: .normal)
        }
    }
    
    func selectNoButton(flag: Bool) {
        if flag {
            self.noButton.backgroundColor = UIColor.lightRoyalBlue
            self.noButton.setTitleColor(UIColor.white, for: .normal)
        } else {
            self.noButton.backgroundColor = UIColor.white
            self.noButton.setTitleColor(UIColor.dark, for: .normal)
        }
    }

    func selectMayBeButton(flag: Bool) {
        if flag {
            self.mayBeButton.backgroundColor = UIColor.lightRoyalBlue
            self.mayBeButton.setTitleColor(UIColor.white, for: .normal)
        } else {
            self.mayBeButton.backgroundColor = UIColor.white
            self.mayBeButton.setTitleColor(UIColor.dark, for: .normal)
        }
    }

    
    lazy var mayBeButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        button.backgroundColor = .white
        button.layer.borderColor = UIColor.paleLilacTwo.cgColor
        button.layer.borderWidth = 1.0
        button.layer.cornerRadius = 4.0
        button.setTitleColor(UIColor.dark, for: .normal)
        return button
    }()

    lazy var buttonsCollectionView: UICollectionView = {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 10.0
        layout.minimumLineSpacing = 1.0
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    // MARK: -init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    // MARK: properties with observers
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func initialize() {
        self.selectionStyle = .none
        yesButton.widthAnchor.constraint(equalToConstant: 71).isActive = true
        yesButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        noButton.widthAnchor.constraint(equalToConstant: 71).isActive = true
        noButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        mayBeButton.widthAnchor.constraint(equalToConstant: 71).isActive = true
        mayBeButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        yesNoStackView.axis = .horizontal
        yesNoStackView.backgroundColor = .red
        yesNoStackView.distribution = UIStackView.Distribution.equalSpacing
        yesNoStackView.alignment = UIStackView.Alignment.fill
        yesNoStackView.spacing = 0.0
        yesNoStackView.addArrangedSubview(yesButton)
        yesNoStackView.addArrangedSubview(noButton)
        yesNoStackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(yesNoStackView)
        contentView.addSubview(mayBeButton)
        yesButton.setTitle("Yes", for: .normal)
        noButton.setTitle("No", for: .normal)
        mayBeButton.setTitle("Maybe", for: .normal)

     /*   buttonsCollectionView.register(KRESegmentButtonsCollectionViewCell.self, forCellWithReuseIdentifier: collectionViewIdentifier)
        buttonsCollectionView.alwaysBounceHorizontal = false
        buttonsCollectionView.backgroundColor = .clear
        buttonsCollectionView.delegate = self
        buttonsCollectionView.dataSource = self
        buttonsCollectionView.sizeToFit()
        buttonsCollectionView.isScrollEnabled = false
        buttonsCollectionView.showsHorizontalScrollIndicator = false
        buttonsCollectionView.layer.cornerRadius = 6.0
        buttonsCollectionView.backgroundColor = UIColor.paleGrey
        contentView.addSubview(buttonsCollectionView)*/
        
        // Setting Constraints
        let views: [String: UIView] = ["yesNoStackView": yesNoStackView, "mayBeButton": mayBeButton]
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat:
            "H:|-14-[yesNoStackView]", options:[], metrics:nil, views:views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat:
            "H:[mayBeButton]-14-|", options:[], metrics:nil, views:views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat:
            "V:|-11-[yesNoStackView]-15-|", options:[], metrics:nil, views:views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat:
            "V:|-11-[mayBeButton]-15-|", options:[], metrics:nil, views:views))
    }
    
    // MARK:- deinit
    deinit {
        
    }
}
// MARK: - UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
extension KREMeetingGoingOptionTableViewCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return goingString.count
    }
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let collectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: collectionViewIdentifier, for: indexPath)
        if let cell = collectionViewCell as? KRESegmentButtonsCollectionViewCell  {
            if selectedButtonIndex == indexPath.row {
                cell.nameLabel.textColor = .white
                //                cell.containerView.backgroundColor = themeColor ?? UIColor.coralPink
                cell.containerView.layer.shadowColor = UIColor.gunmetal.cgColor
                cell.containerView.layer.borderColor = UIColor.veryLightBlue.cgColor
                cell.containerView.layer.cornerRadius = 6.0
                cell.containerView.layer.shadowRadius = 7.0
                cell.containerView.layer.masksToBounds = false
                cell.containerView.layer.borderWidth = 0.5
                cell.containerView.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
                cell.containerView.layer.shadowOpacity = 0.1
                cell.containerView.backgroundColor = UIColor.lightRoyalBlue
            } else {
                cell.containerView.layer.shadowColor = UIColor.clear.cgColor
                cell.containerView.layer.borderColor = UIColor.clear.cgColor
                cell.containerView.layer.cornerRadius = 6.0
                cell.containerView.layer.shadowRadius = 7.0
                cell.containerView.layer.masksToBounds = false
                cell.containerView.layer.borderWidth = 0.5
                cell.containerView.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
                cell.containerView.layer.shadowOpacity = 0.1
                cell.containerView.backgroundColor = .clear
                cell.nameLabel.textColor = .black

            }
//            } else {
//            }
//            if let filterTitle = filter.title {
               cell.nameLabel.text = goingString[indexPath.row]
//            }
            cell.nameLabel.font = UIFont.textFont(ofSize: 15, weight: .medium)
            cell.isUserInteractionEnabled = true
        }
        return collectionViewCell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedButtonIndex = indexPath.row
        collectionView.reloadData()
    }
    
    // MARK: - UICollectionViewDelegateContactFlowLayout
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let titleAttributedString = NSMutableAttributedString(string: goingString[indexPath.row], attributes: buttonTitleAttributes)
       let widthForItem = collectionView.frame.size.width/3.0
        return CGSize(width: widthForItem, height: buttonMaxHeight)
    }
    
    func maxContentWidth() -> CGFloat {
        if let collectionViewLayout = buttonsCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let sectionInset: UIEdgeInsets = collectionViewLayout.sectionInset
            return self.frame.size.width - sectionInset.left - sectionInset.right
        }
        return 0.0
    }
}
