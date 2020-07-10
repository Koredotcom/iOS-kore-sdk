//
//  KREWidgetComponentView.swift
//  KoreBotSDK
//
//  Created by Srinivas Vasadi on 16/09/19.
//  Copyright © 2019 Srinivas Vasadi. All rights reserved.
//

import UIKit

open class KREWidgetComponentView: UIView {
    // MARK: - properites
    let tableView = UITableView(frame: .zero, style: .plain)
    public var widgetElementAction:((_ action: Any?, _ component: WidgetComponent?) -> Void)?
    public var widgetComponent: WidgetComponent?
    public var viewMoreAction:((_ action: [Any]?) -> Void)?
    public var viewMoreActionTask:((_ action: [Any]?,_ component: WidgetComponent?) -> Void)?
    var elements: [Any]? {
        didSet {
            tableView.reloadData()
            layoutIfNeeded()
        }
    }
    var MAX_ELEMENTS = 3
    let calendarEventCellIdentifier = "KRECalendarEventCell"
    let documentInformationCellIdentifier = "KREDocumentInformationCell"
    let widgetViewCellIdentifier = "KREWidgetViewCell"
    let taskPreviewCellIdentifier = "KRETaskPreviewCell"
    let buttonTemplateCellIdentifier = "KREButtonTemplateCellIdentifier"
    
    lazy var titleStrikeThroughAttributes: [NSAttributedString.Key: Any] = {
        return [.font: UIFont.textFont(ofSize: 14.0, weight: .bold), .foregroundColor: UIColor.blueyGrey]
    }()
    
    lazy var taskTitleAttributes: [NSAttributedString.Key: Any] = {
        return [.font: UIFont.textFont(ofSize: 14.0, weight: .bold), .foregroundColor: UIColor.gunmetal]
    }()
    
    // MARK: - init
    convenience init() {
        self.init(frame: .zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        tableView.register(KREDocumentInformationCell.self, forCellReuseIdentifier: documentInformationCellIdentifier)
        tableView.register(KRECalendarEventCell.self, forCellReuseIdentifier: calendarEventCellIdentifier)
        tableView.register(KRETaskPreviewCell.self, forCellReuseIdentifier: taskPreviewCellIdentifier)
        tableView.register(KREButtonTemplateCell.self, forCellReuseIdentifier: buttonTemplateCellIdentifier)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: widgetViewCellIdentifier)
        
        tableView.backgroundColor = UIColor.clear
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.alwaysBounceHorizontal = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isScrollEnabled = false
        tableView.layer.cornerRadius = 8.0
        addSubview(tableView)
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[tableView]|", options:[], metrics: nil, views: ["tableView": tableView]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[tableView]|", options:[], metrics: nil, views: ["tableView": tableView]))
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override open var intrinsicContentSize: CGSize {
        tableView.layoutIfNeeded()
        return tableView.contentSize
    }
    
    // MARK: -
    func prepareForReuse() {
        elements = nil
        tableView.reloadData()
    }
    
    // MARK: - helpers
    func compareDates(_ lastSeenDate : Date?, _ updateDate: Date?) -> ComparisonResult {
        // Compare them
        guard let updateDate = updateDate else {
            return .orderedSame
        }
        
        switch lastSeenDate?.compare(updateDate) {
        case .orderedAscending?:
            return .orderedAscending
        case .orderedDescending?:
            return .orderedDescending
        case .orderedSame?:
            return .orderedSame
        case .none:
            return .orderedSame
        }
    }
    
    public func formatAsDateWithTime(using date: NSDate) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, LLL d', 'h:mm a"
        dateFormatter.amSymbol = "AM"
        dateFormatter.pmSymbol = "PM"
        return dateFormatter.string(from: date as Date)
    }
    
    func convertUTCToDate(_ utcDate: Int64) -> String {
        let timeInSeconds = Double(truncating: NSNumber(value: utcDate)) / 1000
        let dateTime = Date(timeIntervalSince1970: timeInSeconds)
        let dateStr = formatAsDateWithTime(using: dateTime as NSDate)
        return dateStr
    }
    
    // MARK: - helpers
    public func getExpectedSize() -> CGSize {
        tableView.layoutIfNeeded()
        return tableView.contentSize
    }
    
    // MARK:- deinit
    deinit {
        
    }
}

extension KREWidgetComponentView: UITableViewDelegate, UITableViewDataSource {
    // MARK: - UITableViewDataSource
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return min(MAX_ELEMENTS, elements?.count ?? 0)
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var element = elements?[indexPath.row]
        var cellIdentifier = widgetViewCellIdentifier
        var templateType = KRETemplateType.none
        if let _ = element as? KRECalendarEvent {
            templateType = .calendarEvent
            cellIdentifier = calendarEventCellIdentifier
        } else if let _ = element as? KREDriveFileInfo {
            templateType = .fileSearch
            cellIdentifier = documentInformationCellIdentifier
        } else if let _ = element as? KRETaskListItem {
            templateType = .taskList
            cellIdentifier = taskPreviewCellIdentifier
        } else if let _ = element as? KREButtonTemplate {
            templateType = .button
            cellIdentifier = buttonTemplateCellIdentifier
        }
        if indexPath.row == 3 {
            element = widgetComponent?.buttons?.first as? KREButtonTemplate
            templateType = .button
            cellIdentifier = buttonTemplateCellIdentifier
        }
        let tableViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        switch templateType {
        case .calendarEvent:
            if let cell = tableViewCell as? KRECalendarEventCell, let calendarEvent = element as? KRECalendarEvent {
                cell.titleLabel.text = calendarEvent.title
                cell.locaLabel.text = calendarEvent.location
                if calendarEvent.location?.count ?? 0 > 0 {
                    cell.locaionImageHeightConstraint.constant = 20
                } else {
                    cell.locaionImageHeightConstraint.constant = 0
                }
                var attendeeText = String()
                if let attendeesCount = calendarEvent.attendees?.count, attendeesCount > 0 {
                    if let firstAttendee = calendarEvent.attendees?.first {
                        if let name = firstAttendee.name {
                            attendeeText = name
                            cell.participantsImageView.isHidden = false
                        } else if let email = firstAttendee.email {
                            attendeeText = email.lowercased()
                            cell.participantsImageView.isHidden = false
                        } else {
                            cell.participantsImageView.isHidden = true
                        }
                        if (attendeesCount - 1 > 0) {
                            let attendeeCountStr = "\(String(describing: attendeesCount - 1))"
                            if attendeesCount <= 2 {
                                attendeeText = attendeeText + " and " + attendeeCountStr + " other"
                            } else {
                                attendeeText = attendeeText + " and " + attendeeCountStr + " others"
                            }
                        }
                    }
                    
                    cell.participantsLabel.text = attendeeText
                }
                cell.fromLabel.text = calendarEvent.startTimeString()
                cell.toLabel.text = calendarEvent.endTimeString()
                cell.verticalLine.backgroundColor = UIColor(hexString: calendarEvent.color ?? "#6168e7")
            }
        case .fileSearch:
            if let cell = tableViewCell as? KREDocumentInformationCell, let driveFileInfo = element as? KREDriveFileInfo {
                cell.contentView.layoutSubviews()
                cell.cardView.driveFileObject = driveFileInfo
                cell.cardView.configure(with: driveFileInfo)
                cell.selectionStyle = .none
            }
        case .taskList:
            if let cell = tableViewCell as? KRETaskPreviewCell, let taskListItem = element as? KRETaskListItem {
                var utcDate: Date?
                cell.selectionStyle = .none
                if let dueDate = taskListItem.dueDate {
                    cell.dateTimeLabel.text = convertUTCToDate(dueDate)
                    utcDate = Date(milliseconds: Int64(truncating: NSNumber(value: dueDate)))
                }
                cell.itemSelectionHandler = { [weak self] (taskListItemCell) in
                    
                }
                let assigneeMatching = KREWidgetManager.shared.user?.userId == taskListItem.assignee?.id
                let ownerMatching = KREWidgetManager.shared.user?.userId == taskListItem.owner?.id
                
                if assigneeMatching {
                    cell.assigneeLabel.text = "You"
                } else {
                    cell.assigneeLabel.text = taskListItem.assignee?.fullName
                }
                if ownerMatching {
                    cell.ownerLabel.text = "You"
                } else {
                    cell.ownerLabel.text = taskListItem.owner?.fullName
                }
                if ownerMatching && assigneeMatching {
                    cell.ownerLabel.text = "You"
                    cell.assigneeLabel.isHidden = true
                    cell.triangle.isHidden = true
                } else {
                    cell.assigneeLabel.isHidden = false
                    cell.triangle.isHidden = false
                }
                cell.selectionView.isHidden = true
                cell.selectionViewWidthConstraint.constant = 0.0
                cell.selectionViewLeadingConstraint.constant = 0.0
                let status = taskListItem.status ?? "open"
                if let taskTitle = taskListItem.title {
                    switch status.lowercased() {
                    case "close":
                        let attributeString =  NSMutableAttributedString(string: taskTitle, attributes: titleStrikeThroughAttributes)
                        attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: NSMakeRange(0, attributeString.length))
                        cell.titleLabel.attributedText = attributeString
                        cell.ownerLabel.textColor = UIColor.blueyGrey
                        cell.assigneeLabel.textColor = UIColor.blueyGrey
                        cell.dateTimeLabel.textColor = UIColor.blueyGrey
                        cell.selectionView.isSelected = taskListItem.isSelected
                        if taskListItem.isSelected {
                            cell.contentView.backgroundColor = UIColor(red: 252/255, green: 234/255, blue: 236/255, alpha: 1)
                        } else {
                            cell.contentView.backgroundColor = UIColor.white
                        }
                    default:
                        cell.titleLabel.attributedText = NSAttributedString(string: taskTitle, attributes: taskTitleAttributes)
                        cell.ownerLabel.textColor = UIColor.gunmetal
                        cell.assigneeLabel.textColor = UIColor.gunmetal
                        let comparasionResult = self.compareDates(Date(), utcDate)
                        
                        if comparasionResult == .orderedAscending {
                            cell.dateTimeLabel.textColor = UIColor.gunmetal
                        } else {
                            cell.dateTimeLabel.textColor = UIColor.red
                        }
                        
                        cell.selectionView.isSelected = taskListItem.isSelected
                        if taskListItem.isSelected {
                            cell.contentView.backgroundColor = UIColor(red: 252/255, green: 234/255, blue: 236/255, alpha: 1)
                        } else {
                            cell.contentView.backgroundColor = UIColor.white
                        }
                    }
                }
            }
        case .button:
            if let cell = tableViewCell as? KREButtonTemplateCell, let buttonTemplate = element as? KREButtonTemplate {
                cell.title = buttonTemplate.title
            }
        default:
            UITableViewCell(style: .value1, reuseIdentifier: widgetViewCellIdentifier)
        }
        
        tableViewCell.selectionStyle = .none
        tableViewCell.setNeedsUpdateConstraints()
        tableViewCell.updateConstraintsIfNeeded()
        return tableViewCell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 3 {
            let elementCheck = self.elements?[indexPath.row - 1]
            if let fileData = elementCheck as? KREDriveFileInfo {
                self.viewMoreAction?(self.widgetComponent?.buttons)
            } else if let calendarData = elementCheck as? KRECalendarEvent {
                self.viewMoreAction?(self.elements)
            } else if let taskListItem = elementCheck as? KRETaskListItem {
                self.viewMoreActionTask?(self.elements, self.widgetComponent)
            }
        } else {
            let element = self.elements?[indexPath.row]
            if let buttonTemplate = element as? KREButtonTemplate {
                let elementCheck = self.elements?[indexPath.row - 1]
                if let fileData = elementCheck as? KREDriveFileInfo {
                    self.viewMoreAction?(self.elements)
                } else if let calendarData = elementCheck as? KRECalendarEvent {
                    self.viewMoreAction?(self.elements)
                } else if let taskListItem = elementCheck as? KRETaskListItem {
                    self.viewMoreActionTask?(self.elements, self.widgetComponent)
                }
            } else {
                self.widgetElementAction?(element, self.widgetComponent)
            }
        }
    }
    
    // MARK: - UITableViewDelegateSource
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}


