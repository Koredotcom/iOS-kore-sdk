//
//  KRECalendarListViewController.swift
//  KoreBotSDK
//
//  Created by Srinivas Vasadi on 11/04/20.
//  Copyright © 2019 Srinivas Vasadi. All rights reserved.
//

import UIKit

public class KRECalendarListViewController: UIViewController {
    // MARK: - properites
    let bundle = Bundle.sdkModule
    weak var timer: Timer?
    var isScrolling: Bool = false

    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = UIColor.clear
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = false
        tableView.alwaysBounceHorizontal = false
        tableView.bounces = false
        tableView.isScrollEnabled = true
        tableView.tableFooterView = UIView(frame: .zero)
        return tableView
    }()
    
    public weak var delegate: KREGenericWidgetViewDelegate?
    public var panelItem: KREPanelItem?
    
    private let calendarEventCellIdentifier = "KRECalendarEventCell"
    private let noDataCellIdentifier = "KREWidgetNoDataTableViewCell"
    private let widgetViewCellIdentifier = "KRECalendarWidgetViewCell"
    private let widgetHeaderViewIdentifier = "KREWidgetHeaderView"
    private let widgetFooterViewIdentifier = "KREWidgetFooterView"
    private let buttonTemplateCellIdentifier = "KREButtonTemplateCellIdentifier"
    
    private let meetingDataSource = KREMeetingDataSource()
    
    // MARK: - init
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        tableView.register(KRECalendarEventCell.self, forCellReuseIdentifier: calendarEventCellIdentifier)
        tableView.register(KREButtonTemplateCell.self, forCellReuseIdentifier: buttonTemplateCellIdentifier)
        tableView.register(KREWidgetHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: widgetHeaderViewIdentifier)
        tableView.register(KREWidgetHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: widgetFooterViewIdentifier)
        tableView.register(KREWidgetNoDataTableViewCell.self, forCellReuseIdentifier: noDataCellIdentifier)
        view.addSubview(tableView)

        let views = ["tableView": tableView]
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[tableView]|", options: [], metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[tableView]|", options: [], metrics: nil, views: views))
        
        tableView.dataSource = self
        tableView.delegate = self

        setupNavigationBar()
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
    
    func setupNavigationBar() {
        let image = UIImage(named: "backIcon", in: bundle, compatibleWith: nil)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(closeButtonAction))
        navigationItem.leftBarButtonItem?.tintColor = UIColor.gunmetal
        navigationController?.navigationBar.barTintColor = UIColor.white
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = false
    }

    // MARK: -
    @objc func closeButtonAction() {
        if isModal {
            dismiss(animated: true, completion: nil)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    // MARK:- deinit
    deinit {
        stopTimer()
    }
    
    // MARK: - KREWidgetView methods
    public var widget: KREWidget? {
        didSet {

        }
    }
    
    public var widgetComponent: KREWidgetComponent? {
        didSet {
            populateWidget()
            startTimer()
        }
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource methods
extension KRECalendarListViewController: UITableViewDelegate, UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        let numberOfSection = meetingDataSource.numberOfSection
        switch widget?.widgetState {
        case .loading?:
            return 1
            break
        case .loaded?, .refreshed?:
            if meetingDataSource.conditionForNoData() {
                return 1
            } else {
                return numberOfSection
            }
            break
        default:
            break
        }
        return numberOfSection
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch widget?.widgetState {
        case .loading?:
            return 4
        case .loaded?, .refreshed?:
            if meetingDataSource.conditionForNoData() {
                return 1
            }
            break
        default:
            break
        }
        return meetingDataSource.numberOfRows(in: section)
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
                cell.separatorInset = UIEdgeInsets(top: 0.0, left: view.bounds.size.width ?? 0, bottom: 0.0, right: 0.0)
                cell.layoutSubviews()
                return cell
            } else {
                let element = meetingDataSource.calendarEvent(for: indexPath)
                let cellIdentifier = calendarEventCellIdentifier
                let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
                var templateType = KRETemplateType.none

                if let cell = cell as? KRECalendarEventCell, let calendarEvent = element as? KRECalendarEvent {
                    cell.loadedDataState()
                    configureMeetingCell(cell, at: indexPath, calendarEvent: calendarEvent)
                    cell.layoutSubviews()
                }
                cell.selectionStyle = .none
                cell.setNeedsUpdateConstraints()
                cell.updateConstraintsIfNeeded()
                cell.isHidden = false
                return cell
            }
        default:
            return UITableViewCell(style: .value1, reuseIdentifier: widgetViewCellIdentifier)
        }
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let calendarEvent = meetingDataSource.calendarEvent(for: indexPath) as? KRECalendarEvent {
            delegate?.didSelectElement(calendarEvent, in: widget, in: panelItem)
        }
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
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
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 84.0
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch widget?.widgetState {
        case .loading?:
            break
        case .loaded?, .refreshed?:
            if meetingDataSource.conditionForNoData() {
                return 0
            }
        default:
            break
        }

        return UITableView.automaticDimension
    }
    
    public func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 44.0
    }
}

// MARK: - Configure KRECalendarEventCell
extension KRECalendarListViewController {
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
                self?.delegate?.elementAction(for: calendarEvent, in: self?.widget, in: self?.panelItem)
            }
            cell.participantsLabel.text = attendeeText
        }
        cell.meetingNotesActionButtons = { [weak self] (cell) in
            guard let indexPath = self?.tableView.indexPath(for: cell) else {
                return
            }
            calendarEvent.actionType = "notes"
            self?.delegate?.elementAction(for: calendarEvent, in: self?.widget, in: self?.panelItem)
        }
        cell.meetingJoinActionButtons = { [weak self] (action) in
            self?.delegate?.elementAction(for: action, in: self?.widget, in: self?.panelItem)
        }
        cell.meetingDialInButtons = { [weak self] (action) in
            self?.delegate?.elementAction(for: action, in: self?.widget, in: self?.panelItem)
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
                cell.dialInButton.isHidden = false
            } else {
                cell.dialInButton.isHidden = true
            }
            let joinIn = actions.filter{$0.title == "Join Meeting"}
            if joinIn.count > 0 && shouldShowInfo {
                cell.joinInButton.isHidden = false
            } else {
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
