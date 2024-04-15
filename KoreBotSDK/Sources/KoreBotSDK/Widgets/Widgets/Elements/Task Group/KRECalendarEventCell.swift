//
//  KRECalendarEventCell.swift.swift
//  KoreBotSDK
//
//  Created by Srinivas Vasadi on 13/03/19.
//  Copyright © 2019 Srinivas Vasadi. All rights reserved.
//

import UIKit
protocol KRECalendarEventCellDelegate : class {
    func meetingCellDidTapCheckMark(_ sender: KRECalendarEventCell)
    func meetingCellLongPressEvent(_ sender: KRECalendarEventCell)
}

open class KRECalendarEventCell: UITableViewCell {
    let bundle = Bundle.sdkModule
    public var moreSelectionHandler:((KRECalendarEventCell) -> Void)?
    public var meetingNotesActionButtons:((KRECalendarEventCell) -> Void)?
    public var meetingJoinActionButtons:((KREAction?) -> Void)?
    public var meetingDialInButtons:((KREAction?) -> Void)?
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
   public lazy var dotImageView: UIImageView = {
        var imageView: UIImageView = UIImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = UIView.ContentMode.center
        imageView.clipsToBounds = true
        imageView.backgroundColor = UIColor.red
        return imageView
    }()

    public lazy var timerLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.textFont(ofSize: 12.0, weight: .regular)
        label.textColor = UIColor.charcoalGrey
        label.text = "Starting in 5 mins"
        label.layer.masksToBounds = true
        label.textAlignment = NSTextAlignment.left
        return label
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
        titleLabel.textAlignment = .left
        titleLabel.lineBreakMode = .byTruncatingTail
        return titleLabel
    }()
    var moreButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.whiteTwo
        button.setImage(UIImage(named: "meetingAction"), for: .normal)
        return button
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

    public lazy var locationView = UIView(frame: .zero)
    public lazy var participantView = UIView(frame: .zero)
    public lazy var dialInButton: KREActionButton = {
        var dialInButton = KREActionButton(frame: .zero)
        dialInButton.imageView?.contentMode = .scaleAspectFit
        dialInButton.translatesAutoresizingMaskIntoConstraints = false
        dialInButton.titleLabel?.textColor = UIColor.lightRoyalBlue
        let attributedText = NSAttributedString(string: "DIAL IN", attributes: [NSAttributedString.Key.font: UIFont.textFont(ofSize: 12.0, weight: .bold), .kern: 1.33, .foregroundColor: UIColor.lightRoyalBlue])
        dialInButton.layer.borderColor = UIColor.lightRoyalBlue.cgColor
        dialInButton.layer.borderWidth = 1.5
        dialInButton.layer.cornerRadius = 5.3
        if let dialInImage = UIImage(named: "dialInMeeting") {
            dialInButton.tintColor = UIColor.lightRoyalBlue
            dialInButton.setImage(dialInImage.withRenderingMode(.alwaysTemplate), for: .normal)
            dialInButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
            dialInButton.contentHorizontalAlignment = .center
            dialInButton.imageView?.contentMode = .scaleAspectFit
        }
        dialInButton.setAttributedTitle(attributedText, for: .normal)
        dialInButton.addTarget(self, action: #selector(meetingsDialInButtonAction(_:)), for: .touchUpInside)
        return dialInButton
    }()

    public lazy var joinInButton: KREActionButton = {
        var joinInButton = KREActionButton(frame: .zero)
        joinInButton.imageView?.contentMode = .scaleAspectFit
        joinInButton.translatesAutoresizingMaskIntoConstraints = false
        joinInButton.titleLabel?.textColor = UIColor.lightRoyalBlue
        let attributedText = NSAttributedString(string: "JOIN", attributes: [NSAttributedString.Key.font: UIFont.textFont(ofSize: 12.0, weight: .bold), .kern: 1.33, .foregroundColor: UIColor.lightRoyalBlue])
        joinInButton.layer.borderColor = UIColor.lightRoyalBlue.cgColor
        joinInButton.layer.borderWidth = 1.5
        joinInButton.layer.cornerRadius = 5.3
        if let dialInImage = UIImage(named: "joinInMeeting") {
            joinInButton.tintColor = UIColor.lightRoyalBlue
            joinInButton.setImage(dialInImage.withRenderingMode(.alwaysTemplate), for: .normal)
            joinInButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
            joinInButton.contentHorizontalAlignment = .center
            joinInButton.imageView?.contentMode = .scaleAspectFit
        }
        joinInButton.setAttributedTitle(attributedText, for: .normal)
        joinInButton.addTarget(self, action: #selector(meetingsJoinInButtonAction(_:)), for: .touchUpInside)
        return joinInButton
    }()

    public lazy var notesButton: UIButton = {
        var notesButton = UIButton(frame: .zero)
        notesButton.imageView?.contentMode = .scaleAspectFit
        notesButton.translatesAutoresizingMaskIntoConstraints = false
        notesButton.titleLabel?.textColor = UIColor.lightRoyalBlue
        let attributedText = NSAttributedString(string: "NOTES", attributes: [NSAttributedString.Key.font: UIFont.textFont(ofSize: 12.0, weight: .bold), .kern: 1.33, .foregroundColor: UIColor.lightRoyalBlue])
        notesButton.layer.borderColor = UIColor.lightRoyalBlue.cgColor
        notesButton.layer.borderWidth = 1.5
        notesButton.layer.cornerRadius = 5.3
        if let dialInImage = UIImage(named: "notesMeeting") {
            notesButton.tintColor = UIColor.lightRoyalBlue
            notesButton.setImage(dialInImage.withRenderingMode(.alwaysTemplate), for: .normal)
            notesButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
            notesButton.contentHorizontalAlignment = .center
            notesButton.imageView?.contentMode = .scaleAspectFit
        }
        notesButton.setAttributedTitle(attributedText, for: .normal)
        notesButton.addTarget(self, action: #selector(meetingsNotesButtonAction(_:)), for: .touchUpInside)
        return notesButton
    }()
    
    public lazy var meetingButtonsStackView: UIStackView = {
        let meetingStackView = UIStackView()
        meetingStackView.axis = .horizontal
        meetingStackView.distribution = UIStackView.Distribution.fill
        meetingStackView.alignment = UIStackView.Alignment.leading
        meetingStackView.spacing = 18.0
        meetingStackView.translatesAutoresizingMaskIntoConstraints = false
        return meetingStackView
    }()
    
    public lazy var titleTimerStackView: UIStackView = {
        let titleTimerStackView = UIStackView()
        titleTimerStackView.axis = .vertical
        titleTimerStackView.distribution = UIStackView.Distribution.fill
        titleTimerStackView.alignment = UIStackView.Alignment.leading
        titleTimerStackView.spacing = 4.0
        titleTimerStackView.translatesAutoresizingMaskIntoConstraints = false
        return titleTimerStackView
    }()
    
    public lazy var participantLocationStackView: UIStackView = {
        let participantLocationStackView = UIStackView()
        participantLocationStackView.axis = .vertical
        participantLocationStackView.distribution = UIStackView.Distribution.fill
        participantLocationStackView.alignment = UIStackView.Alignment.leading
        participantLocationStackView.spacing = 5.0
        participantLocationStackView.translatesAutoresizingMaskIntoConstraints = false
        return participantLocationStackView
    }()


    public var locaionImageHeightConstraint : NSLayoutConstraint!
    public var locaionImageTopConstraint : NSLayoutConstraint!
    public var locaionLabelTopConstraint : NSLayoutConstraint!
    public var verticalLineLeadingConstraint : NSLayoutConstraint!
    public var selectionViewWidthConstraint: NSLayoutConstraint!
    public var selectionViewLeadingConstraint: NSLayoutConstraint!
    weak var delegate: KRECalendarEventCellDelegate?
    
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
        selectionViewWidthConstraint.constant = 0
        selectionViewLeadingConstraint.constant = 0
        titleLabel.text = ""
        locaLabel.text = ""
        participantsLabel.text = ""
        fromLabel.text = ""
        toLabel.text = ""
        viaLabel.text = ""
    }
    
    func initialize() {
        selectionStyle = .none
        clipsToBounds = true
        selectionView.isSelected = false
        
        selectionView.setImage(UIImage(named: "checkBoxOn", in: bundle, compatibleWith: nil), for: .selected)
        selectionView.setImage(UIImage(named: "checkBoxOff", in: bundle, compatibleWith: nil), for: .normal)
        selectionView.addTarget(self, action: #selector(selectionChanged(_:)), for: UIControl.Event.touchUpInside)
        
        contentView.addSubview(selectionView)
        contentView.addSubview(fromLabel)
        contentView.addSubview(viaLabel)
        contentView.addSubview(toLabel)
        contentView.addSubview(titleLabel)
        contentView.addSubview(verticalLine)
        contentView.addSubview(moreButton)
        //contentView.addSubview(participantsLabel)
//        contentView.addSubview(locaLabel)
//        contentView.addSubview(locImageView)
       // contentView.addSubview(participantsImageView)
        contentView.addSubview(titleTimerStackView)
        contentView.addSubview(participantLocationStackView)
        contentView.addSubview(meetingButtonsStackView)
        setupUIOfMeetingTimer()
        setupUIOFLocationView()
        setupUIOParticipantView()
        dialInButton.heightAnchor.constraint(equalToConstant: 32.0).isActive = true
        dialInButton.widthAnchor.constraint(equalToConstant: 97.0).isActive = true
        joinInButton.heightAnchor.constraint(equalToConstant: 32.0).isActive = true
        joinInButton.widthAnchor.constraint(equalToConstant: 79.0).isActive = true
        notesButton.heightAnchor.constraint(equalToConstant: 32.0).isActive = true
        notesButton.widthAnchor.constraint(equalToConstant: 91.0).isActive = true
        meetingButtonsStackView.addArrangedSubview(dialInButton)
        meetingButtonsStackView.addArrangedSubview(joinInButton)
        meetingButtonsStackView.addArrangedSubview(notesButton)
        separatorInset = UIEdgeInsets.zero
        contentView.backgroundColor = .clear
        let views: [String: UIView] = ["fromLabel": fromLabel,"viaLabel":viaLabel ,"toLabel": toLabel, "verticalLine": verticalLine, "titleLabel":titleLabel, "locaLabel": locaLabel, "participantsLabel": participantsLabel, "locImageView": locImageView, "participantsImageView": participantsImageView, "selectionView": selectionView, "meetingButtonsStackView": meetingButtonsStackView, "meetingSlotTimerStackView": meetingSlotTimerStackView, "titleTimerStackView": titleTimerStackView, "moreButton": moreButton, "participantLocationStackView": participantLocationStackView]
        titleTimerStackView.addArrangedSubview(titleLabel)
        titleTimerStackView.addArrangedSubview(meetingSlotTimerStackView)
        participantLocationStackView.addArrangedSubview(participantView)
        participantLocationStackView.addArrangedSubview(locationView)
        moreButton.layer.cornerRadius = 15.0
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[moreButton(30)]-10-|", options: [], metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[moreButton(30)]", options: [], metrics: nil, views: views))
        

        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[selectionView]-10-[fromLabel]-[verticalLine(2)]-8-[titleTimerStackView]-40-|", options:[], metrics:nil, views:views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[selectionView]-10-[fromLabel]-[verticalLine(2)]-8-[participantLocationStackView]-40-|", options:[], metrics:nil, views:views))

        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-34-[meetingButtonsStackView]", options:[], metrics:nil, views:views))

        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[selectionView]-10-[viaLabel]-[verticalLine(2)]-8-[titleTimerStackView]-|", options:[], metrics:nil, views:views))

        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[selectionView]-10-[toLabel]-[verticalLine(2)]-8-[titleTimerStackView]-|", options:[], metrics:nil, views:views))
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[selectionView]-10-[toLabel]-[verticalLine(2)]-8-[meetingSlotTimerStackView]", options:[], metrics:nil, views:views))

        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[verticalLine(2)]", options:[], metrics:nil, views:views))
        //contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[verticalLine]-6-[locImageView(20)]-[locaLabel]-|", options:[], metrics:nil, views:views))
        //contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[verticalLine]-6-[participantsImageView(20)]-8-[participantsLabel]-|", options:[], metrics:nil, views:views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[verticalLine]|", options:[], metrics:nil, views:views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-15-[fromLabel]-4-[viaLabel]-4-[toLabel]", options:[], metrics:nil, views:views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-16-[verticalLine(20)]", options:[], metrics:nil, views:views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-15-[titleTimerStackView]-9-[participantLocationStackView]", options:[], metrics:nil, views:views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[meetingButtonsStackView(32)]-17-|", options:[], metrics:nil, views:views))
        titleTimerStackBottom = NSLayoutConstraint(item: contentView, attribute: .bottom, relatedBy: .equal, toItem: participantLocationStackView, attribute: .bottom, multiplier: 1.0, constant: 61.0)
        titleTimerStackBottom.isActive = true
        contentView.addConstraint(titleTimerStackBottom)

        //contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[titleLabel]-[locImageView]-[participantsImageView(20)]", options:[], metrics:nil, views:views))
        
        //titleLabel.setContentCompressionResistancePriority(UILayoutPriority.defaultHigh, for: .vertical)
     //   participantsLabel.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        
     //   locaionImageHeightConstraint = NSLayoutConstraint(item: locImageView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 1.0)
//        contentView.addConstraint(locaionImageHeightConstraint)
//        locaionImageHeightConstraint.isActive = true
        
        verticalLineLeadingConstraint = NSLayoutConstraint(item: verticalLine, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1.0, constant: 1.0)
        contentView.addConstraint(verticalLineLeadingConstraint)
        verticalLineLeadingConstraint.isActive = true
      //  self.participantsImageView.centerYAnchor.constraint(equalTo: participantsLabel.centerYAnchor).isActive = true
        //self.participantsImageView.heightAnchor.constraint(greaterThanOrEqualToConstant: 20).isActive = true
//        self.locImageView.centerYAnchor.constraint(equalTo: locaLabel.centerYAnchor).isActive = true

        selectionView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 0.0).isActive = true
        selectionView.heightAnchor.constraint(equalToConstant: 22.0).isActive = true
        
        selectionViewWidthConstraint = NSLayoutConstraint(item: selectionView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 22.0)
        contentView.addConstraint(selectionViewWidthConstraint)
        selectionViewWidthConstraint.isActive = true
        
        selectionViewLeadingConstraint = NSLayoutConstraint(item: selectionView, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1.0, constant: 15.0)
        contentView.addConstraint(selectionViewLeadingConstraint)
        selectionViewLeadingConstraint.isActive = true
        fromLabel.textAlignment = NSTextAlignment.right
        toLabel.textAlignment = NSTextAlignment.right
        viaLabel.textAlignment = NSTextAlignment.right
        separatorInset = UIEdgeInsets(top: 0, left: 88, bottom: 0, right: 0)
        let longtapGesture : UILongPressGestureRecognizer = UILongPressGestureRecognizer.init(target: self, action: #selector(handleLongTapGesture(_:)))
        longtapGesture.minimumPressDuration = 0.5
        contentView.addGestureRecognizer(longtapGesture)
        moreButton.addTarget(self, action: #selector(meetingsMoreButtonAction(_:)), for: .touchUpInside)
    }
    
    @objc func meetingsMoreButtonAction(_ sender: UIButton) {
        moreSelectionHandler?(self)
    }

    @objc func meetingsNotesButtonAction(_ sender: UIButton) {
        meetingNotesActionButtons?(self)
    }

    @objc func meetingsDialInButtonAction(_ sender: KREActionButton?) {
        meetingDialInButtons?(sender?.action)
    }

    @objc func meetingsJoinInButtonAction(_ sender: KREActionButton?) {
        meetingJoinActionButtons?(sender?.action)
    }

    func loadingDataState() {
        titleLabel.text = "Test"
        toLabel.text = "Test"
        fromLabel.text = "Test"
        viaLabel.text = "Test"
        titleLabel.textColor = UIColor.paleGrey
        titleLabel.backgroundColor = .paleGrey
        toLabel.textColor = UIColor.paleGrey
        toLabel.backgroundColor = .paleGrey
        fromLabel.textColor = UIColor.paleGrey
        fromLabel.backgroundColor = .paleGrey
        viaLabel.textColor = UIColor.paleGrey
        viaLabel.backgroundColor = .paleGrey
    }
    
    func loadedDataState() {
        titleLabel.textColor = UIColor.gunmetal
        titleLabel.backgroundColor = .clear
        toLabel.textColor = UIColor.gunmetal
        toLabel.backgroundColor = .clear
        fromLabel.textColor = UIColor.gunmetal
        fromLabel.backgroundColor = .clear
        viaLabel.textColor = UIColor.gunmetal
        viaLabel.backgroundColor = .clear
    }
    
    func setupUIOfMeetingTimer() {
        dotImageView.widthAnchor.constraint(equalToConstant: 6.0).isActive = true
        dotImageView.heightAnchor.constraint(equalToConstant: 6.0).isActive = true
        dotImageView.layer.cornerRadius = 3.0
        dotImageView.backgroundColor = UIColor.waterMelon
       // contentView.addSubview(meetingSlotTimerStackView)
        meetingSlotTimerStackView.addArrangedSubview(dotImageView)
        meetingSlotTimerStackView.addArrangedSubview(timerLabel)
        meetingSlotTimerStackView.translatesAutoresizingMaskIntoConstraints = false
//        let viewTimer = ["dotImageView": dotImageView, "timerLabel": timerLabel]
//        meetingSlotTimerStackView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[dotImageView]-4-[timerLabel]|", options:[], metrics:nil, views: viewTimer))
//        meetingSlotTimerStackView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[timerLabel(>=14)]|", options:[], metrics:nil, views: viewTimer))
    }
    
    func setupUIOFLocationView() {
        locImageView.widthAnchor.constraint(equalToConstant: 19.0).isActive = true
        locImageView.heightAnchor.constraint(equalToConstant: 19.0).isActive = true
        locationView.addSubview(locImageView)
        locationView.addSubview(locaLabel)
        locationView.translatesAutoresizingMaskIntoConstraints = false
        
        let viewTimer = ["locImageView": locImageView, "locaLabel": locaLabel]
        locationView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[locImageView]-4-[locaLabel]|", options:[], metrics:nil, views: viewTimer))
        locationView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[locaLabel(>=14)]|", options:[], metrics:nil, views: viewTimer))
        locImageView.centerYAnchor.constraint(equalTo: self.locaLabel.centerYAnchor, constant: 0.0).isActive = true
    }

    func setupUIOParticipantView() {
        participantsImageView.widthAnchor.constraint(equalToConstant: 19.0).isActive = true
        participantsImageView.heightAnchor.constraint(equalToConstant: 19.0).isActive = true
        participantView.addSubview(participantsImageView)
        participantView.addSubview(participantsLabel)
        participantView.translatesAutoresizingMaskIntoConstraints = false
        
        let viewTimer = ["participantsImageView": participantsImageView, "participantsLabel": participantsLabel]
        participantView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[participantsImageView]-4-[participantsLabel]|", options:[], metrics:nil, views: viewTimer))
        participantView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[participantsLabel]|", options:[], metrics:nil, views: viewTimer))
        participantsImageView.centerYAnchor.constraint(equalTo: self.participantsLabel.centerYAnchor, constant: 0.0).isActive = true
    }

    func handleParticipantsPosition(){
        if locaLabel.text == "" {
        //    participantsLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10).isActive = true
        }
    }
    func addSeparatorLine(){
        lineView.isHidden = false
        contentView.addSubview(lineView)
        contentView.clipsToBounds = false
        lineView.backgroundColor = UIColor.init(red: 226.0/255.0, green: 226.0/255.0, blue: 233.0/255.0, alpha: 1.0)
        lineView.translatesAutoresizingMaskIntoConstraints = false
        lineView.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        lineView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0.0).isActive = true
       lineView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 0.0).isActive = true
        lineView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
    }
    
    func removeSeprator() {
        lineView.isHidden = true
    }
    
    @objc func handleLongTapGesture(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            delegate?.meetingCellLongPressEvent(self)
        }
    }
    
    @objc func selectionChanged(_ sender: UIButton) {
        delegate?.meetingCellDidTapCheckMark(self)
    }
    
    // MARK:- deinit
    deinit {
        
    }
}

// MARK: - KREButtonTemplateCell
class KREButtonTemplateCell: UITableViewCell {
    // MARK: - properties
    let bundle = Bundle.sdkModule
    lazy var titleLabel: UILabel = {
        let titleLabel = UILabel(frame: .zero)
        titleLabel.backgroundColor = UIColor.white
        titleLabel.textColor = UIColor(hex: 0xA7A9BE)
        titleLabel.numberOfLines = 0
        titleLabel.font = UIFont.textFont(ofSize: 12.0, weight: .medium)
        titleLabel.textAlignment = .left
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }()
    
    lazy var navigationImageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    
    // MARK: - init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    // MARK: - setup
    func setup() {
        contentView.addSubview(titleLabel)
        contentView.backgroundColor = UIColor.white
        
        contentView.addSubview(navigationImageView)
        navigationImageView.isUserInteractionEnabled = true
        navigationImageView.contentMode = .scaleAspectFit
        navigationImageView.image = UIImage(named: "disclose", in: bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        navigationImageView.tintColor = UIColor.steelGrey
        navigationImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let views: [String: Any] = ["titleLabel": titleLabel, "navigationImageView": navigationImageView]
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[titleLabel]-[navigationImageView]-10-|", options: [], metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat:"V:|-12-[titleLabel]-13-|", options: [], metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat:"V:|-[navigationImageView]-|", options: .alignAllCenterX, metrics: nil, views: views))
        
        titleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        navigationImageView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        navigationImageView.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        separatorInset = UIEdgeInsets(top: 0.0, left: bounds.size.width, bottom: 0.0, right: 0.0)
    }
}

extension UIButton {

    func rightImage(image: UIImage, renderMode: UIImage.RenderingMode){
        self.setImage(image.withRenderingMode(renderMode), for: .normal)
        self.imageEdgeInsets = UIEdgeInsets(top: 0, left:image.size.width / 2, bottom: 0, right: 0)
        self.contentHorizontalAlignment = .right
        self.imageView?.contentMode = .scaleAspectFit
    }
}

// MARK: - KREButtonView
public class KREButtonView: UIView {
    // MARK: - properties
    let bundle = Bundle.sdkModule
    public lazy var titleLabel: UILabel = {
        let titleLabel = UILabel(frame: .zero)
        titleLabel.backgroundColor = UIColor.white
        titleLabel.textColor = UIColor(hex: 0xA7A9BE)
        titleLabel.numberOfLines = 0
        titleLabel.font = UIFont.textFont(ofSize: 12.0, weight: .medium)
        titleLabel.textAlignment = .left
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }()
    
    public lazy var navigationImageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    
    // MARK: - init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - setup
    func setup() {
        addSubview(titleLabel)
        backgroundColor = UIColor.white
        
        addSubview(navigationImageView)
        navigationImageView.isUserInteractionEnabled = true
        navigationImageView.contentMode = .scaleAspectFit
        navigationImageView.image = UIImage(named: "disclose", in: bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        navigationImageView.tintColor = UIColor.steelGrey
        navigationImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let views: [String: Any] = ["titleLabel": titleLabel, "navigationImageView": navigationImageView]
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[titleLabel]-[navigationImageView]-10-|", options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat:"V:|-12-[titleLabel]-13-|", options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat:"V:|-[navigationImageView]-|", options: .alignAllCenterX, metrics: nil, views: views))
        
        titleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        navigationImageView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        navigationImageView.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    }
}

// MARK: - KREActionButton
public class KREActionButton: UIButton {
    public var action: KREAction?
}
