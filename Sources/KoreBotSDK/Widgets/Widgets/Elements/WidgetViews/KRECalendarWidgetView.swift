//
//  KRECalendarWidgetView.swift
//  KoreBotSDK
//
//  Created by Srinivas Vasadi on 20/03/19.
//  Copyright © 2019 Srinivas Vasadi. All rights reserved.
//

import UIKit

public class KRECalendarWidgetView: KREWidgetView {
    // MARK: - properites
    let bundle = Bundle.sdkModule
    weak var timer: Timer?
    var isScrolling: Bool = false
    
    public lazy var tableView: KRETableView = {
        let tableView = KRETableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = UIColor.clear
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = false
        tableView.alwaysBounceHorizontal = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.bounces = false
        tableView.isScrollEnabled = true
        tableView.tableFooterView = UIView(frame: .zero)
        return tableView
    }()
    
    private let calendarEventCellIdentifier = "KRECalendarEventCell"
    private let noDataCellIdentifier = "KREWidgetNoDataTableViewCell"
    private let widgetViewCellIdentifier = "KRECalendarWidgetViewCell"
    private let widgetHeaderViewIdentifier = "KREWidgetHeaderView"
    private let widgetFooterViewIdentifier = "KREWidgetFooterView"
    private let buttonTemplateCellIdentifier = "KREButtonTemplateCellIdentifier"
    private let meetingDataSource = KREMeetingDataSource()
    
    // MARK: - init
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        tableView.register(KRECalendarEventCell.self, forCellReuseIdentifier: calendarEventCellIdentifier)
        tableView.register(KREButtonTemplateCell.self, forCellReuseIdentifier: buttonTemplateCellIdentifier)
        tableView.register(KREWidgetHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: widgetHeaderViewIdentifier)
        tableView.register(KREWidgetHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: widgetFooterViewIdentifier)
        tableView.register(KREWidgetNoDataTableViewCell.self, forCellReuseIdentifier: noDataCellIdentifier)
        addSubview(tableView)
        
        let views = ["tableView": tableView]
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[tableView]|", options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[tableView]|", options: [], metrics: nil, views: views))
    }
    
    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { [weak self] _ in
            self?.tableView.reloadData()
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
    }
    
    func populateWidget() {
        let widgetFilter = widget?.filters?.first
        let widgetComponent = widgetFilter?.component
        if let objects = widgetComponent?.elements as? [KRECalendarEvent], objects.count > 0 {
            meetingDataSource.cursor = widgetComponent?.cursor
            _ = meetingDataSource.parseDataMeeting(objects: objects)
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    // MARK: -
    open override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return subviews.contains {
            !$0.isHidden && $0.point(inside: convert(point, to: $0), with: event)
        }
    }
    
    func getWidgets(forceReload: Bool = false, completion block: ((Bool) -> Void)? = nil) {
        guard let widget = widget else {
            return
        }
        
        KREWidgetManager.shared.fetchWidget(widget, forceReload: forceReload) { [weak self] (success) in
            self?.reloadWidget(widget)
            self?.startTimer()
            
            block?(success)
        }
    }
    
    func reloadWidget(_ widget: KREWidget?) {
        guard let widget = widget else {
            return
        }
        
        switch widget.widgetState {
        case .refreshing, .loading:
            populateWidget()
        case .loaded, .refreshed:
            populateWidget()
        case .noData:
            break
        case .requestFailed:
            break
        case .noNetwork:
            break
        case .none:
            break
        }
    }
    
    func scrollToTop() {
        let indexPath = IndexPath(row: 0, section: 0)
        guard indexPath.section < tableView.numberOfSections,
            indexPath.row < tableView.numberOfRows(inSection: indexPath.section) else {
                return
        }
        
        tableView.scrollToRow(at: indexPath, at: .top, animated: false)
    }
    
    // MARK:- deinit
    deinit {
        stopTimer()
    }
    
    // MARK: - KREWidgetView methods
    override public var widget: KREWidget? {
        didSet {

        }
    }
    
    override public var widgetComponent: KREWidgetComponent? {
        didSet {
            populateWidget()
            startTimer()

            tableView.reloadData()
            tableView.layoutIfNeeded()
        }
    }
    
    override public func startShimmering() {
        
    }
    
    override public func stopShimmering() {
        
    }
    
    override public func prepareForReuse() {
        super.prepareForReuse()
        widgetComponent = nil
        widget = nil
        tableView.reloadData()
        tableView.layoutIfNeeded()
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource methods
extension KRECalendarWidgetView: UITableViewDelegate, UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        let numberOfSection = meetingDataSource.numberOfSection
        switch widget?.widgetState {
        case .loading?:
            return 1
        case .loaded?, .refreshed?, .refreshing?:
            if meetingDataSource.conditionForNoData() {
                return 1
            }

            switch widgetViewType {
            case .trim:
                let dateTimeKeys = meetingDataSource.dateTimeKeys
                return min(dateTimeKeys.count, MAX_ELEMENTS) + 1
            case .full:
                return numberOfSection
            }
        default:
            return 0
        }
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch widget?.widgetState {
        case .loading?:
            return 3
        case .loaded?, .refreshed?, .refreshing?:
            switch widgetViewType {
            case .trim:
                let eventsDict = meetingDataSource.allevntsDictDateStr
                let dateTimeKeys = meetingDataSource.dateTimeKeys
                
                var eventsCount = 0
                var events = [KRECalendarEvent]()
                let dateTimeKeysCount = dateTimeKeys.count
                for index in 0..<section {
                    if index < dateTimeKeys.count {
                        eventsCount += eventsDict?[dateTimeKeys[index]]?.count ?? 0
                    }
                }
                
                switch section {
                case 0...2:
                    let count = min(dateTimeKeys.count, MAX_ELEMENTS)
                    if section < count {
                        events = eventsDict?[dateTimeKeys[section]] ?? []
                    }
                    
                    let remaining = max(MAX_ELEMENTS - eventsCount, 0)
                    return min(remaining, events.count)
                default:
                    if eventsCount > MAX_ELEMENTS {
                        return 1
                    }
                    return 0
                }
            case .full:
                return meetingDataSource.numberOfRows(in: section)
            }
        case .noData?:
            return 1
        default:
            return 0
        }
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch widget?.widgetState {
        case .loading?:
            var cellIdentifier = calendarEventCellIdentifier
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
            if let cell = cell as? KRECalendarEventCell {
                cell.loadingDataState()
            }
            cell.layoutSubviews()
            return cell
            break
        case .loaded?, .refreshed?, .refreshing?:
            if meetingDataSource.conditionForNoData() {
                var cellIdentifier = noDataCellIdentifier
                let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
                if let cell = cell as? KREWidgetNoDataTableViewCell {
                    cell.noDataView.noDataLabel.text = "No Meeting Data"
                }
                cell.separatorInset = UIEdgeInsets(top: 0.0, left: bounds.size.width ?? 0, bottom: 0.0, right: 0.0)
                cell.layoutSubviews()
                return cell
            }
            
            switch widgetViewType {
            case .trim:
                let dateTimeKeys = meetingDataSource.dateTimeKeys
                let count = min(dateTimeKeys.count, MAX_ELEMENTS)
                if indexPath.section < count {
                    return calendarEventCell(at: indexPath)
                } else {
                    return buttonTemplateCell(at: indexPath)
                }
            case .full:
                return calendarEventCell(at: indexPath)
            }
        default:
            return UITableViewCell(style: .value1, reuseIdentifier: widgetViewCellIdentifier)
        }
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch widgetViewType {
        case .trim:
            switch indexPath.section {
            case 0..<MAX_ELEMENTS:
                if let calendarEvent = meetingDataSource.calendarEvent(for: indexPath) as? KRECalendarEvent {
                    viewDelegate?.didSelectElement(calendarEvent, in: widget)
                }
            default:
                viewDelegate?.viewMoreElements(for: widgetComponent, in: widget)
            }
        case .full:
            if let calendarEvent = meetingDataSource.calendarEvent(for: indexPath) as? KRECalendarEvent {
                viewDelegate?.didSelectElement(calendarEvent, in: widget)
            }
        }
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch widgetViewType {
        case .trim:
            let dateTimeKeys = meetingDataSource.dateTimeKeys
            let count = min(dateTimeKeys.count, MAX_ELEMENTS)
            guard section < count else {
                return nil
            }
            
            fallthrough
        case .full:
            let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: widgetHeaderViewIdentifier)
            if let headerFooterView = headerView as? KREWidgetHeaderFooterView {
                headerFooterView.bubbleView.moveButton.isHidden = true
                headerFooterView.sepratorLine.isHidden = false
                var title = ""
                if meetingDataSource.dateTimeKeys.count > 0, section < meetingDataSource.dateTimeKeys.count {
                    title = meetingDataSource.dateTimeKeys[section]
                }
                if let date = KRECalendarEvent.getDateFromString(title) {
                    if Date().isTomorow(as: date) {
                        title = "Tomorrow"
                    } else {
                        let df = DateFormatter()
                        df.dateFormat = "EEE, d MMM, yyyy"
                        let now = df.string(from: date)
                        title = now
                    }
                }
                let attributedString = NSMutableAttributedString(string: title, attributes: [.font: UIFont.textFont(ofSize: 17.0, weight: .semibold), .foregroundColor: UIColor.dark, .kern: 1.0])
                headerFooterView.bubbleView.titleLabel.attributedText = attributedString
                headerFooterView.bubbleView.buttonsContainerView.isHidden = true
            }
            return headerView
        }
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 84.0
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch widget?.widgetState {
        case .loaded?, .refreshed?, .refreshing?:
            switch widgetViewType {
            case .trim:
                if meetingDataSource.conditionForNoData() {
                    return CGFloat.leastNormalMagnitude
                }
                
                switch section {
                case 0..<MAX_ELEMENTS:
                    let count = tableView.numberOfRows(inSection: section)
                    if count == 0 {
                        return CGFloat.leastNormalMagnitude
                    }
                    return UITableView.automaticDimension
                default:
                    return CGFloat.leastNormalMagnitude
                }
            case .full:
                return UITableView.automaticDimension
            }
        default:
            return UITableView.automaticDimension
        }
    }
    
    public func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        let eventsDict = meetingDataSource.allevntsDictDateStr
        let dateTimeKeys = meetingDataSource.dateTimeKeys
        
        var eventsCount = 0
        var events = [KRECalendarEvent]()
        let dateTimeKeysCount = dateTimeKeys.count
        for index in 0..<section {
            if index < dateTimeKeys.count {
                eventsCount += eventsDict?[dateTimeKeys[index]]?.count ?? 0
            }
        }
        
        switch section {
        case 0..<MAX_ELEMENTS:
            let count = min(dateTimeKeys.count, MAX_ELEMENTS)
            if section < count {
                events = eventsDict?[dateTimeKeys[section]] ?? []
            }
            
            let remaining = max(MAX_ELEMENTS - eventsCount, 0)
            if remaining > 0 {
                return UITableView.automaticDimension
            }
            return CGFloat.leastNormalMagnitude
        default:
            if eventsCount > MAX_ELEMENTS {
                return UITableView.automaticDimension
            }
            return CGFloat.leastNormalMagnitude
        }
    }
}

// MARK: - Configure KRECalendarEventCell
extension KRECalendarWidgetView {
    func calendarEventCell(at indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = calendarEventCellIdentifier
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        var templateType = KRETemplateType.none
        if let cell = cell as? KRECalendarEventCell,
            let calendarEvent = meetingDataSource.calendarEvent(for: indexPath) as? KRECalendarEvent {
            cell.loadedDataState()
            configureMeetingCell(cell, at: indexPath, calendarEvent: calendarEvent)
            cell.layoutSubviews()
        }
        cell.selectionStyle = .none
        cell.setNeedsUpdateConstraints()
        cell.updateConstraintsIfNeeded()
        return cell
    }
    
    func buttonTemplateCell(at indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = buttonTemplateCellIdentifier
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        if let cell = cell as? KREButtonTemplateCell {
            cell.title = NSLocalizedString("View more", comment: "View more")
        }
        cell.layoutSubviews()
        return cell
    }

    func configureMeetingCell(_ cell: KRECalendarEventCell, at indexPath: IndexPath, calendarEvent: KRECalendarEvent) {
        cell.titleLabel.text = calendarEvent.title
        cell.locaLabel.text = calendarEvent.location
        cell.verticalLineLeadingConstraint.constant = 74.0
        cell.contentView.backgroundColor = UIColor.white
        cell.selectionViewWidthConstraint.constant = 0
        cell.selectionViewLeadingConstraint.isActive = false
        if calendarEvent.location?.count ?? 0 > 0 {
            cell.locationView.isHidden = false
            if #available(iOS 11.0, *) {
                cell.titleTimerStackView.setCustomSpacing(9.0, after: cell.meetingSlotTimerStackView)
                cell.titleTimerStackView.setCustomSpacing(9.0, after: cell.locationView)
            } else {
                // Fallback on earlier versions
            }
        } else {
            cell.locationView.isHidden = true
            if #available(iOS 11.0, *) {
                cell.titleTimerStackView.setCustomSpacing(9.0, after: cell.meetingSlotTimerStackView)
                cell.titleTimerStackView.setCustomSpacing(9.0, after: cell.locationView)
            } else {
                // Fallback on earlier versions
            }
        }
        var todayCellDate:Date?
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
            cell.moreSelectionHandler = { [weak self] (cell) in
                guard let indexPath = self?.tableView.indexPath(for: cell) else {
                    return
                }
                calendarEvent.actionType = "moreAction"
                if todayCellDate != nil {
                    calendarEvent.today = todayCellDate
                }
                self?.viewDelegate?.elementAction(for: calendarEvent, in: self?.widget)
            }
            cell.participantsLabel.text = attendeeText
        }
        cell.meetingNotesActionButtons = { [weak self] (cell) in
            guard let indexPath = self?.tableView.indexPath(for: cell) else {
                return
            }
            calendarEvent.actionType = "notes"
            self?.viewDelegate?.elementAction(for: calendarEvent, in: self?.widget)
        }
        cell.meetingJoinActionButtons = { [weak self] (action) in
            self?.viewDelegate?.elementAction(for: action, in: self?.widget)
        }
        cell.meetingDialInButtons = { [weak self] (action) in
            self?.viewDelegate?.elementAction(for: action, in: self?.widget)
        }
        var calEventTupple = calendarEvent.getNewTimeFormatForDay(Date())
        
        let title = meetingDataSource.dateTimeKeys[indexPath.section]
        if let date = KRECalendarEvent.getDateFromString(title) {
            calEventTupple = calendarEvent.getNewTimeFormatForDay(date)
        }
        
        if calEventTupple.0 == "" && calEventTupple.1 == ""{
            cell.fromLabel.text = calendarEvent.startTimeString()
            cell.toLabel.text = calendarEvent.endTimeString()
        } else {
            cell.fromLabel.text = calEventTupple.0
            if calEventTupple.1 == "" {
                cell.viaLabel.text = calEventTupple.2
                cell.toLabel.text = calEventTupple.1
            } else {
                cell.viaLabel.text = calEventTupple.1
                cell.toLabel.text = calEventTupple.2
            }
        }
        
        cell.verticalLine.backgroundColor = UIColor(hexString: calendarEvent.color ?? "#6168e7")
        if meetingDataSource.numberOfRows(in: indexPath.section) - 1 == indexPath.row {
            cell.addSeparatorLine()
        } else {
            cell.removeSeprator()
        }
        var shouldShowInfo = false
        
        let dateCount = meetingDataSource.dateTimeKeys.count
        if indexPath.section < dateCount {
            let title = meetingDataSource.dateTimeKeys[indexPath.section]
            if title == "Next Inline..." {
                shouldShowInfo = true
                todayCellDate = Date()
            } else if title == "Later Today" {
                todayCellDate = Date()
            } else if let date = KRECalendarEvent.getDateFromString(title) {
                todayCellDate = date
            }
        }
        
        if let actions = calendarEvent.actions {
            let takeNotesAction = actions.filter{$0.title == "Take Notes"}
            if takeNotesAction.count > 0 && shouldShowInfo {
                cell.notesButton.isHidden = false
            } else {
                cell.notesButton.isHidden = true
            }
            let dialInAction = actions.filter{$0.title == "Dial-In"}
            if dialInAction.count > 0 && shouldShowInfo {
                cell.dialInButton.action = dialInAction.first
                cell.dialInButton.isHidden = false
            } else {
                cell.dialInButton.action = nil
                cell.dialInButton.isHidden = true
            }
            let joinIn = actions.filter{$0.title == "Join Meeting"}
            if joinIn.count > 0 && shouldShowInfo {
                cell.joinInButton.action = joinIn.first
                cell.joinInButton.isHidden = false
            } else {
                cell.joinInButton.action = nil
                cell.joinInButton.isHidden = true
            }
            
            if joinIn.count == 0 && dialInAction.count == 0 && takeNotesAction.count == 0 {
                shouldShowInfo = false
                cell.titleTimerStackBottom.constant = 15.5
                cell.meetingButtonsStackView.isHidden = true
            } else {
                shouldShowInfo = true
                cell.titleTimerStackBottom.constant = 61.0
                cell.meetingButtonsStackView.isHidden = false
            }
        }
        let startTime = Double((calendarEvent.startTime ?? 0) / 1000)
        let startDate = Date(timeIntervalSince1970: TimeInterval(NSNumber(value: startTime ?? 0)))
        let endTime = Double((calendarEvent.endTime ?? 0) / 1000)
        let endDate = Date(timeIntervalSince1970: TimeInterval(NSNumber(value: endTime ?? 0)))
        let timerText = timerLogic(startDate: startDate, endDate: endDate, cell, cellDate: todayCellDate, calEvent: calendarEvent)
        if timerText == "" {
            cell.timerLabel.text = timerText
            cell.meetingSlotTimerStackView.isHidden = true
        } else {
            let timerAttributedText = NSAttributedString(string: timerText, attributes: [.font: UIFont.textFont(ofSize: 10.0, weight: .regular), .foregroundColor: UIColor.charcoalGrey, .kern: 0.5])
            cell.timerLabel.attributedText = timerAttributedText
            cell.meetingSlotTimerStackView.isHidden = false
        }
        if !shouldShowInfo {
            hideMeetingButtons(cell, flag: true)
        }
    }
    
    func timerLogic(startDate: Date, endDate: Date,_ cell: KRECalendarEventCell, cellDate:Date?, calEvent: KRECalendarEvent?) -> String {
        var today = Date()
        
        var timerText = ""
        let timeDifference = meetingDataSource.calculateTimeDifference(date1: today, date2: startDate)
        let (h,m,s) = meetingDataSource.secondsToHoursMinutesSeconds(seconds: timeDifference) ?? (0,0,0)
        
        if cellDate != nil {
            today = cellDate!
        }
        let startOfGivenDate = Calendar.current.startOfDay(for: today)
        let startOfToday = Calendar.current.startOfDay(for: Date())
        let startOfEvent = Calendar.current.startOfDay(for: startDate)
        let tomorrowFromToday = Calendar.current.date(byAdding: .day, value: 1, to: startOfToday)
        let dayAfterTomorrow = Calendar.current.date(byAdding: .day, value: 2, to: startOfToday)
        let diffInDays = Calendar.current.dateComponents([.day], from: startOfToday, to: startOfGivenDate).day
        
        var isAllDay = false
        if let calEvent = calEvent {
            isAllDay = calEvent.isAllDay ?? false
            if cellDate != nil {
                if startOfToday == startOfGivenDate {
                    if isAllDay {
                        timerText = "Now"
                        hideMeetingButtons(cell, flag: false)
                        cell.contentView.backgroundColor = UIColor.paleGrey
                        return timerText
                    } else if startDate > Date() && h > 0 {
                        timerText = "In \(h) hrs \(m) mins"
                        hideMeetingButtons(cell, flag: true)
                    } else if startDate > Date() && h <= 0 && m > 0 {
                        timerText = "In \(m) mins"
                        hideMeetingButtons(cell, flag: false)
                        if m < 4 && m > 0 {
                            cell.contentView.backgroundColor = UIColor.paleGrey
                        }
                        return timerText
                    } else {
                        timerText = "Now"
                        hideMeetingButtons(cell, flag: false)
                        cell.contentView.backgroundColor = UIColor.paleGrey
                    }
                } else if startOfGivenDate >= tomorrowFromToday! && startOfGivenDate < dayAfterTomorrow! {
                    hideMeetingButtons(cell, flag: true)
                    timerText = "Tomorrow"
                    return timerText
                } else if let diffInDays = diffInDays {
                    if diffInDays > 0 {
                        hideMeetingButtons(cell, flag: true)
                        timerText = "In \(diffInDays) days"
                        return timerText
                    }
                }
            }
        }
        return timerText
    }
    
    func hideMeetingButtons(_ cell: KRECalendarEventCell, flag: Bool) {
        cell.meetingButtonsStackView.isHidden = flag
        cell.dotImageView.isHidden = flag
        if flag {
            cell.titleTimerStackBottom.constant = 15.5
        } else {
            cell.titleTimerStackBottom.constant = 61.0
        }
    }
}

// MARK: - KRECalendarEventHeaderView
class KRECalendarEventHeaderView: UITableViewHeaderFooterView {
    // MARK: - properties
    var characterSpacing: CGFloat = 5
    let titleLabel = UILabel(frame: .zero)
    let lineView = UIView(frame: .zero)
    let topLineView = UIView(frame: .zero)
    
    var title: String? {
        didSet {
            if let title = title {
                let attributedString = NSMutableAttributedString(string: title, attributes: [.font: UIFont.textFont(ofSize: 14.0, weight: .semibold), .foregroundColor: UIColor.charcoalGrey, .kern: 0.9])
                titleLabel.attributedText = attributedString
            }
        }
    }
    
    // MARK: -
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
    }
    
    // MARK: -
    func setup() {
        backgroundColor = .white
        
        // title label
        contentView.addSubview(titleLabel)
        titleLabel.numberOfLines = 0
        titleLabel.backgroundColor = .clear
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        
        contentView.addSubview(lineView)
        lineView.backgroundColor = UIColor.init(red: 226.0/255.0, green: 226.0/255.0, blue: 233.0/255.0, alpha: 1.0)
        lineView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(topLineView)
        topLineView.backgroundColor = UIColor.init(red: 226.0/255.0, green: 226.0/255.0, blue: 233.0/255.0, alpha: 1.0)
        topLineView.translatesAutoresizingMaskIntoConstraints = false
        
        
        let views: [String: Any] = ["titleLabel": titleLabel, "lineView": lineView, "topLineView":topLineView]
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[titleLabel]-10-|", options: [], metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[lineView]|", options: [], metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[topLineView]|", options: [], metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[topLineView(0.5)]-10-[titleLabel]-10-[lineView(0.5)]|", options: [], metrics: nil, views: views))
    }
}
