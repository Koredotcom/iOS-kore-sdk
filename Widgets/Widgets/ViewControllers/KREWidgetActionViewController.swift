//
//  KREWidgetActionViewController.swift
//  Pods
//
//  Created by Sukhmeet Singh on 15/03/19.
//

import UIKit

open class KREWidgetActionViewController: UIViewController {
    // MARK: - properties
    public var dismissParent:(() -> Void)?
    let widgetCellIdentifier = "KREWidgetBubbleCell"
    let taskPreviewCellIdentifier = "KRETaskPreviewCell"
    let bundle = Bundle(for: KREWidgetActionViewController.self)
    let containerViewHeight = UIScreen.main.bounds.height / 2.0
    public var widget: KREWidget?
    var counter = 0
    var timer = Timer()
    lazy var blurEffectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.regular)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return blurEffectView
    }()
    
    lazy var containerView: UIView = {
        let containerView = UIView(frame: .zero)
        containerView.backgroundColor = .clear
        containerView.translatesAutoresizingMaskIntoConstraints = false
        return containerView
    }()
    
    public var element: Any? {
        didSet {
            tableView.reloadData()
            tableView.layoutIfNeeded()
        }
    }
    
    var buttonsData: [String]?
    let prototypeCell = KREButtonTemplateCell()
    
    lazy var utterancesView: KREActionCollectionView = {
        let utteranceCollectionView = KREActionCollectionView(frame: .zero)
        utteranceCollectionView.translatesAutoresizingMaskIntoConstraints = false
        utteranceCollectionView.widget = widget
        return utteranceCollectionView
    }()
    
    lazy var titleStrikeThroughAttributes: [NSAttributedString.Key: Any] = {
        return [.font: UIFont.textFont(ofSize: 14.0, weight: .bold), .foregroundColor: UIColor.blueyGrey]
    }()
    
    lazy var taskTitleAttributes: [NSAttributedString.Key: Any] = {
        return [.font: UIFont.textFont(ofSize: 14.0, weight: .bold), .foregroundColor: UIColor.gunmetal]
    }()
    
    lazy private var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.separatorColor = UIColor.lightGreyBlue
        tableView.backgroundColor = .clear
        tableView.layer.cornerRadius = 8.0
        tableView.bounces = false
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        tableView.isScrollEnabled = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    lazy private var titleLabel: UILabel = {
        let titleLabel = UILabel(frame: .zero)
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .left
        titleLabel.font = UIFont.textFont(ofSize: 19.0, weight: .medium)
        titleLabel.textColor = UIColor.charcoalGrey
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }()
    
    var closeButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.contentMode = .scaleAspectFit
        button.tintColor = UIColor.charcoalGrey
        button.addTarget(self, action: #selector(closeButtonAction(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    
    
    // MARK: - init
    public init() {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .custom
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        modalPresentationStyle = .custom
    }
    
    // MARK: -
    override open func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .clear
        view.addSubview(blurEffectView)
        view.addSubview(containerView)
        
        let metrics: [String: Any] = ["containerViewHeight": containerViewHeight]
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[containerView]|", options:[], metrics: nil, views: ["containerView": containerView]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[containerView(containerViewHeight)]", options:[], metrics: metrics, views: ["containerView": containerView]))
        if #available(iOS 11, *) {
            let guide = view.safeAreaLayoutGuide
            containerView.bottomAnchor.constraint(equalTo: guide.bottomAnchor).isActive = true
        } else {
            let standardSpacing: CGFloat = 0.0
            containerView.bottomAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: standardSpacing).isActive = true
        }
        
        let image = UIImage(named: "close_icon", in: bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        closeButton.contentMode = .scaleAspectFit
        closeButton.setImage(image, for: .normal)
        containerView.addSubview(tableView)
        containerView.addSubview(utterancesView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(closeButton)
        
        titleLabel.text = NSLocalizedString("What would you like to do?", comment: "What would you like to do?")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(KREWidgetBubbleCell.self, forCellReuseIdentifier: widgetCellIdentifier)
        tableView.register(KRECalendarEventCell.self, forCellReuseIdentifier: "KRECalendarEventCell")
        tableView.register(KRETaskPreviewCell.self, forCellReuseIdentifier: taskPreviewCellIdentifier)
        
        let views = ["tableView": tableView, "utterancesView": utterancesView, "titleLabel": titleLabel, "closeButton": closeButton]
        
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[titleLabel]-40-[closeButton(44)]-19-|", options:[], metrics: nil, views: views))
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[tableView]-16-|", options:[], metrics: nil, views: views))
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[titleLabel]-40-[tableView]-[utterancesView(64)]|", options:[], metrics:nil, views: views))
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[closeButton(44)]", options:[], metrics: nil, views: views))
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[utterancesView]|", options:[], metrics: nil, views: views))
        utterancesView.backgroundColor = .white
        let yConstraint = NSLayoutConstraint(item: titleLabel, attribute: .centerY, relatedBy: .equal, toItem: closeButton, attribute: .centerY, multiplier: 1.0, constant: 0.0)
        containerView.addConstraint(yConstraint)
        
        if let taskListItem = element as? KRETaskListItem {
       //     utterancesView.actions = taskListItem.actions
        } else if let calendarEvent = element as? KRECalendarEvent {
//            let startTime = Double((element?.startTime ?? 0) / 1000)
//            let startDate = Date(timeIntervalSince1970: TimeInterval(NSNumber(value: startTime ?? 0)))
//            calculateTimeDifference(date1: Date(), date2: startDate)
            var actionFinalMeetingStarted = [KREAction]()
            var actionFinalMeetingNotes = [KREAction]()

            //
            for action in calendarEvent.actions ?? [] {
                if action.type == "url" && action.title != "View in Calendar" {
                    actionFinalMeetingNotes.append(action)

                } else if action.type == "dial" {
                    actionFinalMeetingNotes.append(action)

                } else if action.type == "open_form" {
                    actionFinalMeetingNotes.append(action)
                }
                else {
                    actionFinalMeetingStarted.append(action)
                    actionFinalMeetingNotes.append(action)

                }
            }
            if checkIfMeetingIsstarted() != true {
          //      utterancesView.actions = actionFinalMeetingStarted
            } else {
        //        utterancesView.actions = actionFinalMeetingNotes
            }
        }
        
        utterancesView.utteranceClickAction = { [weak self] (action) in
            var params: [String: Any] =  [String: Any]()
            if let utterance = action?.utterance {
                params["utterance"] = utterance
            }
            if let taskListItem = self?.element as? KRETaskListItem {
                params["options"] = ["params": ["ids": [taskListItem.taskId]]] as? [String: Any]
            } else if let calendarEvent = self?.element as? KRECalendarEvent{
    
                params["options"] = ["params":["ids": [calendarEvent.eventId]]] as? [String: Any]
                
                if action?.type == "url" {
          //          self?.openCalendarEventUrl(urlString: action?.url ?? "")
                    return
                } else if action?.type == "dial" {
                    guard let phone = calendarEvent.meetJoin?.dialIn else{
                        return
                    }
                    let phoneUrl = URL(string: "telprompt://\(phone)")
                    let phoneFallbackUrl = URL(string: "tel://\(phone)")
                    if let url = phoneUrl, UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: { (success) in
                            if (!success) {
                                debugPrint("Error message: Failed to open the url")
                            }
                        })
                    } else if let url = phoneFallbackUrl, UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: { (success) in
                            if (!success) {
                                debugPrint("Error message: Failed to open the url")
                            }
                        })
                    } else {
                        let alertController = UIAlertController(title: "Error message:", message: "Your device can not do phone calls", preferredStyle: .alert)
                        let noAction = UIAlertAction(title: "Ok", style: .cancel, handler: {
                            UIAlertAction  in
                        })
                        alertController.addAction(noAction)
                        self?.present(alertController, animated: true, completion: nil)
                        debugPrint("Error message: Your device can not do phone calls")
                    }
                    return
                }
            }
            
            if action?.type == "open_form" && action?.title == "Take Notes"{
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "onTakeNotesButtonClick"), object: ["meetingData" : (self?.element as? KRECalendarEvent), "controller": self])
            } else if action?.type == "view_details" {
                let widgetActionController = KREMeetingDetailViewController()
                widgetActionController.eventId = (self?.element as? KRECalendarEvent)?.eventId

                widgetActionController.element = self?.element as? KRECalendarEvent
                if let action = self {
                    let navController = UINavigationController(rootViewController: widgetActionController)
                    navController.navigationBar.tintColor = UIColor.white
                    navController.modalPresentationStyle = .fullScreen
                    self?.present(navController, animated: false, completion: nil)
                }
            } else {
                self?.dismiss(animated: true) {
                    NotificationCenter.default.post(name: KREMessageAction.utteranceHandler.notification, object: params)
                }
                self?.dismissParent?()
            }
        }
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        blurEffectView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func openCalendarEventUrl(urlString: String) {
        guard let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) else {
            return
        }
        
        UIApplication.shared.open(url, options: [:]) { (success) in
            
        }
    }
    
    func startTimer() {
        timer.invalidate() // just in case this button is tapped multiple times
        // start the timer
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
    }
    
    func stopTimer() {
        timer.invalidate()
    }
    
    func checkIfMeetingIsstarted() -> Bool {
        if let calendarEvent = element as? KRECalendarEvent {
            let startTime = Double((calendarEvent.startTime ?? 0) / 1000)
            let startDate = Date(timeIntervalSince1970: TimeInterval(NSNumber(value: startTime ?? 0)))
            let endTime = Double((calendarEvent.endTime ?? 0) / 1000)
            let endDate = Date(timeIntervalSince1970: TimeInterval(NSNumber(value: endTime ?? 0)))
            if Date() < startDate {
                let (h,m,s) = secondsToHoursMinutesSeconds(seconds: calculateTimeDifference(date1: Date(), date2: startDate))
                if h == 0 {
                    if m <= 5 && m >= 0 {
                        return true
                    }
            }
            }
            else if Date() <= endDate && Date() >= startDate {
                return true
            } else if Date() > endDate {
                return false
            } else {
                return false
            }
        } else {
            return false
        }
        return false
    }

    @objc func timerAction() {
        //  counter -= 1
            //start time condition for 5 minutes
        if let calendarEvent = element as? KRECalendarEvent {
            

            let startTime = Double((calendarEvent.startTime ?? 0) / 1000)
            let startDate = Date(timeIntervalSince1970: TimeInterval(NSNumber(value: startTime ?? 0)))
            let (h,m,s) = secondsToHoursMinutesSeconds(seconds: calculateTimeDifference(date1: Date(), date2: startDate))
            if h == 0 {
                if m <= 5 && m >= 0 {
                } else {
                }
            }
            
        
            let endTime = Double((calendarEvent.endTime ?? 0) / 1000)
        let endDate = Date(timeIntervalSince1970: TimeInterval(NSNumber(value: endTime ?? 0)))
        if Date() < endDate && Date() > startDate {
            
        } else if Date() > endDate {
            
        }
        }

        // label.text = "\(counter)"
    }

    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }

    
    public func calculateTimeDifference(date1: Date, date2: Date) -> Int {
        let cal = Calendar.current
        let components = cal.dateComponents([.second], from: date1, to: date2)
        if let diffSeconds = components.second {
            // counter = diffSeconds
            return diffSeconds
        } else {
            return 0
        }
    }

    
    func checkMeetingStatingCondition() {
    }

    // MARK: -
    @objc func closeButtonAction(_ sender: UIButton) {
        dismiss(animated: false, completion: nil)
    }
    
    @objc func handleTapGesture(_ sender: UITapGestureRecognizer) {
        dismiss(animated: false, completion: nil)
    }
    
    // MARK: - deinit
    deinit {
        
    }
}

extension KREWidgetActionViewController: UITableViewDataSource, UITableViewDelegate {
    // MARK: UITableViewDatasource
    open func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cellIdentifier = "KREMessageBubbleCell"
        cellIdentifier = widgetCellIdentifier
        let cell = tableView.dequeueReusableCell(withIdentifier: taskPreviewCellIdentifier, for: indexPath) as? KRETaskPreviewCell
        cell?.contentView.backgroundColor = .clear
        cell?.backgroundColor = .clear
        if let taskListItem = element as? KRETaskListItem {
            var utcDate: Date?
            cell?.selectionStyle = .none
            if let dueDate = taskListItem.dueDate {
                cell?.dateTimeLabel.text = convertUTCToDate(dueDate)
                utcDate = Date(milliseconds: Int64(truncating: NSNumber(value: dueDate)))
            }
            cell?.itemSelectionHandler = { [weak self] (taskListItemCell) in
                
            }
            let assigneeMatching = KREWidgetManager.shared.user?.userId == taskListItem.assignee?.id
            let ownerMatching = KREWidgetManager.shared.user?.userId == taskListItem.owner?.id
            
            if assigneeMatching {
                cell?.assigneeLabel.text = "You"
            } else {
                cell?.assigneeLabel.text = taskListItem.assignee?.fullName
            }
            if ownerMatching {
                cell?.ownerLabel.text = "You"
            } else {
                cell?.ownerLabel.text = taskListItem.owner?.fullName
            }
            if ownerMatching && assigneeMatching {
                cell?.ownerLabel.text = "You"
                cell?.assigneeLabel.isHidden = true
                cell?.triangle.isHidden = true
            } else {
                cell?.assigneeLabel.isHidden = false
                cell?.triangle.isHidden = false
            }
            cell?.selectionView.isHidden = true
            cell?.selectionViewWidthConstraint.constant = 0.0
            cell?.selectionViewLeadingConstraint.constant = 0.0
            
            let status = taskListItem.status ?? "open"
            if let taskTitle = taskListItem.title {
                switch status.lowercased() {
                case "close":
                    let attributeString =  NSMutableAttributedString(string: taskTitle, attributes: titleStrikeThroughAttributes)
                    attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: NSMakeRange(0, attributeString.length))
                    cell?.titleLabel.attributedText = attributeString
                    cell?.ownerLabel.textColor = UIColor.blueyGrey
                    cell?.assigneeLabel.textColor = UIColor.blueyGrey
                    cell?.dateTimeLabel.textColor = UIColor.blueyGrey
                    cell?.selectionView.isSelected = taskListItem.isSelected
                    if taskListItem.isSelected {
                        cell?.contentView.backgroundColor = UIColor(red: 252/255, green: 234/255, blue: 236/255, alpha: 1)
                    } else {
                        cell?.contentView.backgroundColor = UIColor.clear
                    }
                default:
                    cell?.titleLabel.attributedText = NSAttributedString(string: taskTitle, attributes: taskTitleAttributes)
                    cell?.ownerLabel.textColor = UIColor.gunmetal
                    cell?.assigneeLabel.textColor = UIColor.gunmetal
                    let comparasionResult = self.compareDates(Date(), utcDate)
                    
                    if comparasionResult == .orderedAscending {
                        cell?.dateTimeLabel.textColor = UIColor.gunmetal
                    } else {
                        cell?.dateTimeLabel.textColor = UIColor.red
                    }
                    
                    cell?.selectionView.isSelected = taskListItem.isSelected
                    if taskListItem.isSelected {
                        cell?.contentView.backgroundColor = UIColor(red: 252/255, green: 234/255, blue: 236/255, alpha: 1)
                    } else {
                        cell?.contentView.backgroundColor = UIColor.clear
                        cell?.containerView.backgroundColor = .white
                    }
                }
            }
            cell?.containerView.layer.shadowColor = UIColor.gunmetal.cgColor
            cell?.containerView.layer.borderColor = UIColor.veryLightBlue.cgColor
            cell?.containerView.layer.cornerRadius = 8.0
            cell?.containerView.layer.shadowRadius = 7.0
            cell?.containerView.layer.masksToBounds = false
            cell?.containerView.layer.borderWidth = 0.5
            cell?.containerView.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
            cell?.containerView.layer.shadowOpacity = 0.1
            cell?.containerView.clipsToBounds = true
            cell?.containerViewLeadingConstraint.constant = 0
            cell?.containerViewTrailingConstraint.constant = 0
            cell?.layoutSubviews()
            return cell ?? UITableViewCell()
            
        } else if let calendarEvent = element as? KRECalendarEvent {
            let calendarCell =  tableView.dequeueReusableCell(withIdentifier: "KRECalendarEventCell", for: indexPath) as? KRECalendarEventCell
            calendarCell?.titleLabel.text = calendarEvent.title
            calendarCell?.locaLabel.text = calendarEvent.location
            calendarCell?.verticalLineLeadingConstraint.constant = 74.0
            calendarCell?.selectionViewLeadingConstraint.isActive = false
            calendarCell?.selectionViewWidthConstraint.constant = 0
            if calendarEvent.location?.count ?? 0 > 0 {
                calendarCell?.locationView.isHidden = false
            } else {
                calendarCell?.locationView.isHidden = true
                calendarCell?.handleParticipantsPosition()
            }
            var attendeeText = String()
            if let attendeesCount = calendarEvent.attendees?.count, attendeesCount > 0 {
                if let firstAttendee = calendarEvent.attendees?.first {
                    if let name = firstAttendee.name {
                        attendeeText = name
                        calendarCell?.participantsImageView.isHidden = false
                    } else if let email = firstAttendee.email {
                        attendeeText = email.lowercased()
                        calendarCell?.participantsImageView.isHidden = false
                    } else {
                        calendarCell?.participantsImageView.isHidden = true
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
                calendarCell?.participantsLabel.text = attendeeText
            }
            calendarCell?.fromLabel.text = calendarEvent.startTimeString()
            calendarCell?.toLabel.text = calendarEvent.endTimeString()
            calendarCell?.verticalLine.backgroundColor = UIColor(hexString: calendarEvent.color ?? "#6168e7")
            calendarCell?.layer.shadowColor = UIColor.gunmetal.cgColor
            calendarCell?.layer.borderColor = UIColor.veryLightBlue.cgColor
            calendarCell?.layer.cornerRadius = 8.0
            calendarCell?.layer.shadowRadius = 7.0
            calendarCell?.layer.masksToBounds = false
            calendarCell?.layer.borderWidth = 0.5
            calendarCell?.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
            calendarCell?.layer.shadowOpacity = 0.1
            calendarCell?.layoutSubviews()
            return calendarCell ?? UITableViewCell()
        }
        return UITableViewCell()
    }
    
    
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    // MARK: - UITableViewDelegate
    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    open func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    
    func convertUTCToDate(_ utcDate: Int64) -> String {
        let timeInSeconds = Double(truncating: NSNumber(value: utcDate)) / 1000
        let dateTime = Date(timeIntervalSince1970: timeInSeconds)
        let dateStr = formatAsDateWithTime(using: dateTime as NSDate)
        return dateStr
    }
    
    public func formatAsDateWithTime(using date: NSDate) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, LLL d', 'h:mm a"
        dateFormatter.amSymbol = "AM"
        dateFormatter.pmSymbol = "PM"
        return dateFormatter.string(from: date as Date)
    }
    
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
    
}
