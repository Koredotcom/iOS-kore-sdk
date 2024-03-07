//
//  KREMeetingDetailViewController.swift
//  Pods
//
//  Created by Sukhmeet Singh on 15/05/19.
//

import UIKit
//import KoreBotSDK
import Mantle

public enum KREMeetingStatus: String {
    case accepted = "accepted", declined = "declined", tentative = "tentative", needsAction = "needsAction"
}

struct BottomSheetData {
    var icon: UIImage?
    var title: String?
    var color: UIColor?
    
    init(icon: UIImage, title: String, color: UIColor) {
        self.icon = icon
        self.title = title
        self.color = color
    }
}
public class KREMeetingDetailViewController: UIViewController {
    let bundle = Bundle(for: KREMeetingDetailViewController.self)
    var collectionViewIdentifier = "KREMeetingButtonsCollectionViewCell"
    let joinMeetingBottomSheet = UIView(frame: .zero)
    var indexOfTakeNotes = 0
    var bottomSheetData = [BottomSheetData]()
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.white
        return tableView
    }()
    private lazy var rectangularView: UIView = {
        let rectangularView = UIView(frame: .zero)
        rectangularView.translatesAutoresizingMaskIntoConstraints = false
        return rectangularView
    }()
    lazy var bottomSheetCollectionView: UICollectionView = {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 10.0
        layout.minimumLineSpacing = 1.0
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    var heightOfBottomSheet = 160
    var bottomLayoutTable: NSLayoutConstraint!
    var counter = 0
    var timer = Timer()
    var participantList = 3
    var status = ""
    public var eventId: String?
    public var element: KRECalendarEvent? {
        didSet {
            prepareBottomSheetValues()
            setOldStatus()
            checkMeetingStartCondition()
            bringOrganizerToTop()
            tableView.reloadData()
            tableView.layoutIfNeeded()
        }
    }
    public var activityHandler:((KREActivityInfo?)->Void)?
    
    // MARK: -
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(tableView)
        self.view.backgroundColor = UIColor.white
        tableView.delegate = self
        tableView.dataSource = self
        let views = ["tableView" : tableView]
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat:"H:|[tableView]|", options: [], metrics: nil, views: views))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat:"V:|-10-[tableView]", options: [], metrics: nil, views: views))
        addRegisterCell()
        // Do any additional setup after loading the view.
        tableView.tableFooterView = UIView(frame: .zero)
                let dummyViewHeight = CGFloat(40)
                self.tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width, height: dummyViewHeight))
                self.tableView.contentInset = UIEdgeInsets(top: -dummyViewHeight, left: 0, bottom: 0, right: 0)
        setupNavigationItems()
        bottomSheetCollectionView.register(KREMeetingButtonsCollectionViewCell.self, forCellWithReuseIdentifier: "KREMeetingButtonsCollectionViewCell")
        if #available(iOS 11, *) {
            let guide = view.safeAreaLayoutGuide
            tableView.bottomAnchor.constraint(equalTo: guide.bottomAnchor).isActive = true
        } else {
            let standardSpacing: CGFloat = 0.0
            tableView.bottomAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: standardSpacing).isActive = true
        }
        addBottomSheet()
        removeBottomSheet()
    }
    
    func bringOrganizerToTop() {
        if let attendees = self.element?.attendees {
            for (index,everyAttendee) in attendees.enumerated(){
                if let isOrganizer = everyAttendee.organizer, isOrganizer {
                    if index != 0 {
                        if let attendee = self.element?.attendees?.remove(at: index) {
                            self.element?.attendees?.insert(attendee, at: 0)
                            break
                        }
                    }
                }
            }
        }
    }
    
    func getMeetingDetails() {
        let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView.init(style: UIActivityIndicatorView.Style.gray)
        if element == nil {
            activityIndicator.alpha = 1.0
            self.view.addSubview(activityIndicator)
            activityIndicator.center = CGPoint(x: UIScreen.main.bounds.size.width/2, y: UIScreen.main.bounds.size.height/2)
            activityIndicator.startAnimating()
        } else {
            
        }
        let driveManager = KREDriveListManager()
        
        var eventIdFetch = ""
        if let eventIdFromElement = self.element?.eventId {
            eventIdFetch = eventIdFromElement
        } else if let eventIdFromId = self.eventId {
            eventIdFetch = eventIdFromId
        }
        driveManager.getMeetingDetails(eventId: eventIdFetch , with: { [weak self] (status, componentElements) in
            DispatchQueue.main.async {
                if let meetingArray = componentElements as? [[String:Any]],
                    let meeting = meetingArray.first {
                    
                    if let jsonData = try? JSONSerialization.data(withJSONObject: meeting, options: .prettyPrinted) {
                        let jsonDecoder = JSONDecoder()
                        if var allEvents = try? jsonDecoder.decode(KRECalendarEvent.self, from: jsonData) {
                            DispatchQueue.main.async {
                                activityIndicator.stopAnimating()
                                self?.element = allEvents
                            }
                        }
                    }
                }
            }
        })
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationItems()
        getMeetingDetails()
    }
    
    // MARK: -
    func checkMeetingStartCondition() {
        stopTimer()
        let startTime = Double((element?.startTime ?? 0) / 1000)
        let startDate = Date(timeIntervalSince1970: TimeInterval(NSNumber(value: startTime ?? 0)))
        calculateTimeDifference(date1: Date(), date2: startDate)
        startTimer()
    }
    
    
    func setOldStatus() {
        for attendee in element?.attendees ?? [] {
            if let status = attendee.status, attendee.selfUser == true {
                self.status = status
            }

        }
    }
    
    func uploadStatus(statusPosted: String) {
        let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView.init(style: UIActivityIndicatorView.Style.gray)
        activityIndicator.alpha = 1.0
        self.view.addSubview(activityIndicator)
        activityIndicator.center = CGPoint(x: UIScreen.main.bounds.size.width/2, y: UIScreen.main.bounds.size.height/2)
        
        if let eventId = element?.eventId,let email = KREWidgetManager.shared.user?.userEmail {
            let parameters = ["eventId": eventId, "user": ["email": email, "status": statusPosted]] as [String : Any]
            activityIndicator.startAnimating()
            let driveManager = KREDriveListManager()
            driveManager.stautusUpdateApi(parameters: parameters, with: { [weak self] (status, componentElements) in
                DispatchQueue.main.async {
                    self?.status = statusPosted
                    self?.tableView.reloadData()
                    activityIndicator.stopAnimating()
                }
            })
        }
    }
    
    
    
    func addRegisterCell() {
        tableView.register(KREMeetingSlotAndLocationTableViewCell.self, forCellReuseIdentifier: "KREMeetingSlotAndLocationTableViewCell")
        tableView.register(KREMeetingDetailsTableViewCell.self, forCellReuseIdentifier: "KREMeetingDetailsTableViewCell")
        tableView.register(KREMeetingSlotTableViewCell.self, forCellReuseIdentifier: "KREMeetingSlotTableViewCell")
        tableView.register(KREMeetingGoingOptionTableViewCell.self, forCellReuseIdentifier: "KREMeetingGoingOptionTableViewCell")
        tableView.register(KAMeetingSelectionTableViewCell.self, forCellReuseIdentifier: "KAMeetingSelectionTableViewCell")
        tableView.register(KAMeetingDetailHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "KAMeetingDetailHeaderFooterView")
        tableView.register(KREGrowingTextViewCell.self, forCellReuseIdentifier: "KREGrowingTextViewCell")
    }
    
    func removeBottomSheet() {
        joinMeetingBottomSheet.isHidden = true
        tableView.contentInset.bottom = 0.0
    }
    
    func unHideBottomSheet() {
        joinMeetingBottomSheet.isHidden = false
        tableView.contentInset.bottom = CGFloat(heightOfBottomSheet)
    }
    
    func addBottomSheet() {
        rectangularView.backgroundColor = UIColor.paleLilac
        rectangularView.layer.cornerRadius = 4.5
        joinMeetingBottomSheet.addSubview(rectangularView)
        self.view.addSubview(joinMeetingBottomSheet)
        joinMeetingBottomSheet.backgroundColor = .white
        joinMeetingBottomSheet.translatesAutoresizingMaskIntoConstraints = false
        joinMeetingBottomSheet.addSubview(bottomSheetCollectionView)
        bottomSheetCollectionView.delegate = self
        bottomSheetCollectionView.dataSource = self

        rectangularView.centerXAnchor.constraint(equalTo: joinMeetingBottomSheet.centerXAnchor).isActive = true
        rectangularView.widthAnchor.constraint(equalToConstant: 54.0).isActive = true
        let views = ["joinMeetingBottomSheet" : joinMeetingBottomSheet, "bottomSheetCollectionView": bottomSheetCollectionView, "rectangularView": rectangularView]
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat:"H:|[joinMeetingBottomSheet]|", options: [], metrics: nil, views: views))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat:"V:[joinMeetingBottomSheet(160)]|", options: [], metrics: nil, views: views))
        self.joinMeetingBottomSheet.addConstraints(NSLayoutConstraint.constraints(withVisualFormat:"H:|-20-[bottomSheetCollectionView]-20-|", options: [], metrics: nil, views: views))
        self.joinMeetingBottomSheet.addConstraints(NSLayoutConstraint.constraints(withVisualFormat:"V:|-4-[rectangularView(6)]-[bottomSheetCollectionView]|", options: [], metrics: nil, views: views))
        bottomSheetCollectionView.backgroundColor = UIColor.white
        addShadow()
    }
    
    func addShadow() {
        joinMeetingBottomSheet.layer.shadowColor = UIColor.gunmetal20.cgColor
        joinMeetingBottomSheet.layer.borderColor = UIColor.veryLightBlue.cgColor
        joinMeetingBottomSheet.layer.cornerRadius = 8.0
        joinMeetingBottomSheet.layer.shadowRadius = 7.0
        joinMeetingBottomSheet.layer.masksToBounds = false
        joinMeetingBottomSheet.layer.borderWidth = 0.5
        joinMeetingBottomSheet.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        joinMeetingBottomSheet.layer.shadowOpacity = 1.0
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appWillEnterForeground),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
    }
    
    override public func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        stopTimer()
    }
    
    @objc func appWillEnterForeground() {
//        let startTime = Double((element?.startTime ?? 0) / 1000)
//        let startDate = Date(timeIntervalSince1970: TimeInterval(NSNumber(value: startTime ?? 0)))
//        calculateTimeDifference(date1: Date(), date2: startDate)
//        startTimer()
    }
    
    func startTimer() {
        timer.invalidate() // just in case this button is tapped multiple times
        // start the timer
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
    }
    
    func stopTimer() {
        timer.invalidate()
    }
    
    @objc func timerAction() {
      //  counter -= 1
        if let cell: KREMeetingSlotAndLocationTableViewCell = (self.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? KREMeetingSlotAndLocationTableViewCell) {
            //start time condition for 5 minutes
            let startTime = Double((element?.startTime ?? 0) / 1000)
            let startDate = Date(timeIntervalSince1970: TimeInterval(NSNumber(value: startTime ?? 0)))
            let (h,m,s) = secondsToHoursMinutesSeconds(seconds: calculateTimeDifference(date1: Date(), date2: startDate))
            if h == 0 {
                if m <= 5 && m >= 0 && s >= 0 {
                    let timeString = String(format: "%02d:%02d", m, s)
                    cell.timerLabel.text = "Starting in \(timeString)"
                    if checkMeetingJoinIsPresent() {
                        unHideBottomSheet()
                    }
                } else {
                    cell.meetingSlotTimerStackView.isHidden = true
                    //removeBottomSheet()
                }
            }
            
//            if counter <= 0 {
//                timer.invalidate()
//                cell.meetingSlotTimerStackView.isHidden = true
//                return
//            }
        }
        let startTime = Double((element?.startTime ?? 0) / 1000)
        let startDate = Date(timeIntervalSince1970: TimeInterval(NSNumber(value: startTime ?? 0)))

        let endTime = Double((element?.endTime ?? 0) / 1000)
        let endDate = Date(timeIntervalSince1970: TimeInterval(NSNumber(value: endTime ?? 0)))
        if Date() <= endDate && Date() >= startDate && checkMeetingJoinIsPresent() {
            unHideBottomSheet()
        } else if Date() > endDate {
            removeBottomSheet()
        }
        // label.text = "\(counter)"
    }
    
    func checkMeetingJoinIsPresent() -> Bool {
        if element?.meetJoin?.dialIn == nil && element?.meetJoin?.meetingUrl == nil {
            return true
        } else {
            return true
        }
    }
    
    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    func setupNavigationItems() {
        //        let image = UIImage(named: "backIcon", in: bundle, compatibleWith: nil)
        //        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(closeButtonAction))
        //        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.gunmetal
        //        self.navigationController?.navigationBar.barTintColor = UIColor.white
        ////        self.navigationController?.navigationBar.backgroundColor = UIColor.white
        //        self.navigationController?.navigationBar.isTranslucent = true
        let rightBarImage = UIImage(named: "calendar", in: bundle, compatibleWith: nil)
        let image = UIImage(named: "backIcon", in: bundle, compatibleWith: nil)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(closeButtonAction))
        navigationItem.leftBarButtonItem?.tintColor = UIColor.gunmetal
        navigationController?.navigationBar.barTintColor = UIColor.white
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: rightBarImage, style: .plain, target: self, action: #selector(calendarButtonAction))
        navigationItem.rightBarButtonItem?.tintColor = UIColor.gunmetal
    }
    
    // MARK: - button action
    @objc func closeButtonAction() {
        if isModal {
            dismiss(animated: true, completion: nil)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    
    @objc func calendarButtonAction() {
        let timeInSeconds = Double(integerLiteral: element?.startTime ?? 0) / 1000
        let dateTime = Date(timeIntervalSince1970: timeInSeconds)
            publicCalendarEventUrl(urlString: "calshow:\(dateTime.timeIntervalSinceReferenceDate)")
    }
    
    // MARK: -
    func publicCalendarEventUrl(urlString: String) {
        guard let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) else {
            return
        }
        
        UIApplication.shared.open(url, options: [:]) { (success) in
            
        }
    }

    
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension KREMeetingDetailViewController: UITableViewDelegate, UITableViewDataSource {
    // MARK: UITableViewDatasource
    public func numberOfSections(in tableView: UITableView) -> Int {
        if element != nil {
            return 5
        } else {
            return 0
        }
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 3:
            return element?.attendees?.count ?? 0 > participantList ? participantList : element?.attendees?.count ?? 0
        default:
            return 1
        }
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cellIdentifier = "KREMeetingSlotAndLocationTableViewCell"
        switch indexPath.section {
        case 0:
            cellIdentifier = "KREMeetingSlotTableViewCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? KREMeetingSlotTableViewCell
            cell?.selectionStyle = .none
            cell?.titleLabel.text = element?.title
            cell?.titleLabel.numberOfLines = 0
            cell?.separatorInset = UIEdgeInsets(top: 0.0, left: self.view?.bounds.size.width ?? 0, bottom: 0.0, right: 0.0);
            cell?.titleLabelLeadingConstraint.constant = 14
            cell?.layoutSubviews()
            return cell ?? UITableViewCell()
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? KREMeetingSlotAndLocationTableViewCell
            if let location = element?.location, location.count > 0 {
                cell?.locationLabel.text = location
            } else {
                cell?.meetingLocationStackView.isHidden = true
            }
            cell?.selectionStyle = .none
            cell?.meeetingKindStackView.isHidden = true
            cell?.initialsLabel.text = slotTimeConversion()
            cell?.tableviewHeightConstraint.constant = cell?.tableView.contentSize.height ?? 0.0
            let startTime = Double((element?.startTime ?? 0) / 1000)
            let startDate = Date(timeIntervalSince1970: TimeInterval(NSNumber(value: startTime ?? 0)))
            let (h,m,s) = secondsToHoursMinutesSeconds(seconds: calculateTimeDifference(date1: Date(), date2: startDate))
            if m <= 5 && m >= 0 && h == 0 && s > 0 {
                let timeString = String(format: "%02d:%02d", m, s)
                cell?.timerLabel.text = "Starting in \(timeString)"
                if checkMeetingJoinIsPresent() {
                    unHideBottomSheet()
                }
            } else {
                cell?.meetingSlotTimerStackView.isHidden = true
                //removeBottomSheet()
            }
            cell?.layoutSubviews()
            return cell ?? UITableViewCell()
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "KAMeetingSelectionTableViewCell", for: indexPath) as? KAMeetingSelectionTableViewCell
            if let attendee = element?.attendees?[indexPath.row] as? KRECalendarAttendee {
                if attendee.optional == true {
                    cell?.kaOptionalLabel.text = "Optional"
                }
                if true == attendee.organizer {
                    cell?.kaOptionalLabel.text = "Organiser"
                }
                if let name = attendee.name {
                    cell?.kaNameLabel.text = name
                } else {
                    cell?.kaNameLabel.isHidden = true
                }
                
                switch attendee.status {
                case KREMeetingStatus.accepted.rawValue:
                    cell?.kaProfileImageView.image = UIImage(named: "acceptedIcon")
                    cell?.kaMeetingStatusImageView.isHidden = true
                case KREMeetingStatus.declined.rawValue:
                    cell?.kaProfileImageView.image = UIImage(named: "declineIcon")
                    cell?.kaMeetingStatusImageView.isHidden = true
                case KREMeetingStatus.needsAction.rawValue:
                    cell?.kaProfileImageView.image = UIImage(named: "emptyIcon")
                    cell?.kaMeetingStatusImageView.isHidden = true
                case KREMeetingStatus.tentative.rawValue:
                    cell?.kaProfileImageView.image = UIImage(named: "maybeIcon")
                    cell?.kaMeetingStatusImageView.isHidden = true
                default:
                    cell?.kaProfileImageView.image = UIImage(named: "emptyIcon")
                    cell?.kaMeetingStatusImageView.isHidden = true
                }
                cell?.selectionStyle = .none
                cell?.kaOwnerEmailLabel.text = attendee.email
            }
            return cell ?? UITableViewCell()
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "KREGrowingTextViewCell", for: indexPath) as? KREGrowingTextViewCell
            cell?.selectionStyle = .none
            let attributedString = NSMutableAttributedString(string: "DESCRIPTION", attributes: [.font: UIFont.textFont(ofSize: 13.0, weight: .semibold), .foregroundColor: UIColor.battleshipGrey, .kern: 1.0])
            cell?.titleLabel.attributedText = attributedString
            cell?.titleLabel.textColor = UIColor.battleshipGrey
            cell?.authorLabel.attributedText = element?.desc?.getHTMLString(UIColor(red: 62.0 / 255.0, green: 62.0 / 255.0, blue: 81.0 / 255.0, alpha: 1.0), UIFont.textFont(ofSize: 15, weight: .regular))
            cell?.authorLabel.dataDetectorTypes = .all
            cell?.authorLabel.textContainerInset = UIEdgeInsets.zero
            cell?.authorLabel.textContainer.lineFragmentPadding = 0
            if element?.desc == nil || element?.desc?.count == 0 {
                cell?.titleLabel.isHidden = true
            } else {
                cell?.titleLabel.isHidden = false
            }
            // let numLines = Double(cell?.authorLabel.contentSize.height ?? 0.0) / Double(cell?.authorLabel.font?.lineHeight ?? 0.0)
            
            cell?.authorLabel.textAlignment = .left
            //            cell?.authorLabel.textContainer.maximumNumberOfLines = 0
            //            cell?.authorLabel.textContainer.lineBreakMode = .byWordWrapping
            cell?.authorLabel.isEditable = false
            cell?.separatorInset = UIEdgeInsets(top: 0.0, left: self.view?.bounds.size.width ?? 0, bottom: 0.0, right: 0.0);
            return cell ?? UITableViewCell()
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "KREMeetingGoingOptionTableViewCell", for: indexPath) as? KREMeetingGoingOptionTableViewCell
            
            switch self.status {
            case KREMeetingStatus.accepted.rawValue:
                cell?.selectYesButton(flag: true)
                cell?.selectNoButton(flag: false)
                cell?.selectMayBeButton(flag: false)
            case KREMeetingStatus.declined.rawValue:
                cell?.selectYesButton(flag: false)
                cell?.selectNoButton(flag: true)
                cell?.selectMayBeButton(flag: false)
            case KREMeetingStatus.needsAction.rawValue:
                cell?.selectYesButton(flag: false)
                cell?.selectNoButton(flag: false)
                cell?.selectMayBeButton(flag: false)
            case KREMeetingStatus.tentative.rawValue:
                cell?.selectYesButton(flag: false)
                cell?.selectNoButton(flag: false)
                cell?.selectMayBeButton(flag: true)
            default:
                cell?.selectYesButton(flag: false)
                cell?.selectNoButton(flag: false)
                cell?.selectMayBeButton(flag: false)
            }
            cell?.yesButton.addTarget(self, action: #selector(yesButtonAction(_:)), for: .touchUpInside)
            cell?.noButton.addTarget(self, action: #selector(noButtonAction(_:)), for: .touchUpInside)
            cell?.mayBeButton.addTarget(self, action: #selector(mayBeButtonAction(_:)), for: .touchUpInside)
            cell?.separatorInset = UIEdgeInsets(top: 0.0, left: self.view?.bounds.size.width ?? 0, bottom: 0.0, right: 0.0);
            return cell ?? UITableViewCell()
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
            cell.layoutSubviews()
            return cell
        }
        return UITableViewCell()
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    // MARK: - UITableViewDelegate
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 2, 3:
            return UITableView.automaticDimension
        default:
            return 0.0
        }
    }
    
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        switch section {
        case 3:
            if element?.attendees?.count ?? 0 > 3 {
                return UITableView.automaticDimension
            }
            else {
                return 0.0
            }
        default:
            return 0.0
        }
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch (section) {
        case 3:
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "KAMeetingDetailHeaderFooterView") as? KAMeetingDetailHeaderFooterView
            header?.contentView.backgroundColor = UIColor.white
            let attributedString = NSMutableAttributedString(string: "PARTICIPANTS", attributes: [.font: UIFont.textFont(ofSize: 13.0, weight: .semibold), .foregroundColor: UIColor.battleshipGrey, .kern: 1.0])
            header?.titleLabel.attributedText = attributedString
            header?.titleLabel.textColor = .battleshipGrey
            header?.titleLabel.font = UIFont.textFont(ofSize: 13, weight: .semibold)
            return header
        case 2:
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "KAMeetingDetailHeaderFooterView") as? KAMeetingDetailHeaderFooterView
            header?.contentView.backgroundColor = UIColor.white
            let attributedString = NSMutableAttributedString(string: "GOING?", attributes: [.font: UIFont.textFont(ofSize: 13.0, weight: .semibold), .foregroundColor: UIColor.battleshipGrey, .kern: 1.0])
            header?.titleLabel.attributedText = attributedString
            header?.titleLabel.textColor = .battleshipGrey
            header?.titleLabel.font = UIFont.textFont(ofSize: 13, weight: .semibold)
            return header
        default:
            return UIView()
        }
    }
    
    
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        switch (section) {
        case 3:
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "KAMeetingDetailHeaderFooterView") as? KAMeetingDetailHeaderFooterView
            header?.contentView.backgroundColor = UIColor.white
            var titileText = ""
            if element?.attendees?.count ?? 0 > participantList {
                titileText = "SEE MORE"
            } else {
                titileText = "SEE LESS"
            }
            header?.isUserInteractionEnabled = true
            let attributedString = NSMutableAttributedString(string: titileText, attributes: [.font: UIFont.textFont(ofSize: 14.0, weight: .bold), .foregroundColor: UIColor.lightRoyalBlue, .kern: 1.0])
            
            header?.titleLabel.attributedText = attributedString
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
            header?.addGestureRecognizer(tapGestureRecognizer)
            return header
        default:
            return UIView()
        }
    }
    
    func getInitialsFromNameOne(name1: String, name2: String) -> String {
        let firstName = name1.first ?? Character(" ")
        let lastName = name2.first ?? Character(" ")
        return "\(firstName)\(lastName)".trimmingCharacters(in: .whitespaces)
    }
    
    func slotTimeConversion() -> String {
        if let calendarEvent = element as? KRECalendarEvent{
            guard let startTimeInWords = calendarEvent.startTime?.convertUTCDayInWords() else{
                return ""
            }
            guard let startTimeStamp = calendarEvent.startTime?.convertUTCtoDateHourString() else {
                return ""
            }
            guard let endTimeInWords = calendarEvent.endTime?.convertUTCDayInWords() else {
                return ""
            }
            guard let endTimeStamp = calendarEvent.endTime?.convertUTCtoDateHourString() else {
                return ""
            }

            if let allDay = calendarEvent.isAllDay {
                if allDay{
                    return startTimeInWords
                }
            }
            
            if KRECalendarEvent.isTimeEqualToWholeDay(calendarEvent.startTime!, calendarEvent.endTime!) {
                return "\(startTimeInWords) - \(endTimeInWords)"
            }
            let milliSecondsof_23_59_59:Int64 = 86399000
            let milliSecondsof_23_59_00:Int64 = 86240000
            let difftime:Int64 = Int64((calendarEvent.endTime! - calendarEvent.startTime!) % milliSecondsof_23_59_59)
            
            if difftime > milliSecondsof_23_59_00 && difftime < milliSecondsof_23_59_59 {
                return "\(startTimeInWords) - \(endTimeInWords)"
            }
            if calendarEvent.multiDay {
                return "\(startTimeInWords), \(startTimeStamp) - \(endTimeInWords), \(endTimeStamp)"
            }

            if Int64(calendarEvent.endTime! - calendarEvent.startTime!) < milliSecondsof_23_59_59 {
                return "\(startTimeInWords), \(startTimeStamp) to \(endTimeStamp)"
            }

        }
        return ""
    }
    
    @objc func handleTap() {
        if participantList == element?.attendees?.count ?? 0 {
            participantList = 3
        } else {
            participantList = element?.attendees?.count ?? 0
        }
        tableView.reloadData()
    }
    
    @objc func handleTextTap() {
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
    
    @objc func yesButtonAction(_ sender: UIButton) {
        if status != KREMeetingStatus.accepted.rawValue {
            uploadStatus(statusPosted: KREMeetingStatus.accepted.rawValue)
        } else {
            uploadStatus(statusPosted: KREMeetingStatus.needsAction.rawValue)
        }
    }
    
    @objc func noButtonAction(_ sender: UIButton) {
        if status != KREMeetingStatus.declined.rawValue {
            uploadStatus(statusPosted: KREMeetingStatus.declined.rawValue)
        } else {
            uploadStatus(statusPosted: KREMeetingStatus.needsAction.rawValue)
        }
    }
    
    @objc func mayBeButtonAction(_ sender: UIButton) {
        if status != KREMeetingStatus.tentative.rawValue {
            uploadStatus(statusPosted: KREMeetingStatus.tentative.rawValue)
        } else {
            uploadStatus(statusPosted: KREMeetingStatus.needsAction.rawValue)
        }
    }
}

class KAMeetingDetailHeaderFooterView: UITableViewHeaderFooterView {
    // MARK: - properties
    let titleLabel = UILabel()
    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    // MARK: -
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        // title label
        contentView.addSubview(titleLabel)
        titleLabel.backgroundColor = UIColor.white
        titleLabel.textColor = UIColor.battleshipGrey
        titleLabel.numberOfLines = 0
        titleLabel.font = UIFont.textFont(ofSize: 11.0, weight: .medium)
        titleLabel.textAlignment = .left
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let views : [String: Any] = ["titleLabel": titleLabel]
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[titleLabel]-15-|", options: [], metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat:"V:|-[titleLabel]-|", options: [], metrics: nil, views: views))
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}


class KAMeetingSelectionTableViewCell: UITableViewCell {
    // MARK: -
    
    var parentStackView = UIStackView()
    var imageStackView = UIView(frame: .zero)
    var detailStackView = UIStackView()
    var seprator = UIView(frame: .zero)
    var kaProfileImageView: UIImageView = {
        let profileImageView = UIImageView(frame: .zero)
        profileImageView.contentMode = .scaleAspectFit
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        return profileImageView
    }()
    
    var kaAssigneeImageView: KREIdentityImageView = {
        let assigneeImageView = KREIdentityImageView(frame: .zero)
        assigneeImageView.translatesAutoresizingMaskIntoConstraints = false
        return assigneeImageView
    }()
    
    var kaMeetingStatusImageView : UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    var kaAssigneeLabel = UILabel(frame: CGRect.zero)
    var kaNameLabel = UILabel(frame: CGRect.zero)
    var kaOwnerEmailLabel = UILabel(frame: CGRect.zero)
    var kaAssigneeEmailLabel = UILabel(frame: CGRect.zero)
    var kaOptionalLabel = UILabel(frame: CGRect.zero)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func setup() {
        kaNameLabel.font = UIFont.textFont(ofSize: 15.0, weight: .regular)
        kaNameLabel.textColor = UIColor.init(red: CGFloat(62.0/255.0), green: CGFloat(62.0/255.0), blue: CGFloat(81.0/255.0), alpha: 1.0)
        kaNameLabel.sizeToFit()
        kaNameLabel.isUserInteractionEnabled = true
        kaNameLabel.textAlignment = .left
        kaNameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        kaOptionalLabel.font = UIFont.textFont(ofSize: 13.0, weight: .regular)
        kaOptionalLabel.textColor = UIColor.init(red: CGFloat(118.0/255.0), green: CGFloat(118.0/255.0), blue: CGFloat(136.0/255.0), alpha: 1.0)
        kaOptionalLabel.sizeToFit()
        kaOptionalLabel.text = "Required"
        kaOptionalLabel.isUserInteractionEnabled = true
        kaOptionalLabel.textAlignment = .left
        kaOptionalLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(kaOptionalLabel)
        
        kaOwnerEmailLabel.font = UIFont.textFont(ofSize: 13.0, weight: .semibold)
        kaOwnerEmailLabel.textColor = UIColor.init(red: CGFloat(167.0/255.0), green: CGFloat(169.0/255.0), blue: CGFloat(190.0/255.0), alpha: 1.0)
        kaOwnerEmailLabel.sizeToFit()
        kaOwnerEmailLabel.numberOfLines = 0
        kaOwnerEmailLabel.lineBreakMode = .byWordWrapping
        kaOwnerEmailLabel.isUserInteractionEnabled = true
        kaOwnerEmailLabel.textAlignment = .left
        kaOwnerEmailLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(parentStackView)
        kaProfileImageView.widthAnchor.constraint(equalToConstant: 40.0).isActive = true
        kaProfileImageView.heightAnchor.constraint(equalToConstant: 40.0).isActive = true
        kaMeetingStatusImageView.image = UIImage(named: "checkMark")?.withRenderingMode(.alwaysTemplate)
        kaMeetingStatusImageView.tintColor = UIColor.algaeGreen
        kaMeetingStatusImageView.backgroundColor = UIColor.eggshellBlue
        let viewProfile = ["kaMeetingStatusImageView": kaMeetingStatusImageView, "kaProfileImageView" : kaProfileImageView]
        kaMeetingStatusImageView.widthAnchor.constraint(equalToConstant: 10.0).isActive = true
        kaMeetingStatusImageView.heightAnchor.constraint(equalToConstant: 10.0).isActive = true
        kaMeetingStatusImageView.layer.cornerRadius = 5.0
        kaMeetingStatusImageView.clipsToBounds = true
        imageStackView.addSubview(kaProfileImageView)
        imageStackView.addSubview(kaMeetingStatusImageView)
        imageStackView.translatesAutoresizingMaskIntoConstraints = false
        imageStackView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[kaProfileImageView]|", options:[], metrics:nil, views: viewProfile))
        imageStackView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[kaProfileImageView]|", options:[], metrics:nil, views: viewProfile))
        imageStackView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[kaMeetingStatusImageView]|", options:[], metrics:nil, views: viewProfile))
        imageStackView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[kaMeetingStatusImageView]|", options:[], metrics:nil, views: viewProfile))
        
        detailStackView.axis = .vertical
        detailStackView.distribution = UIStackView.Distribution.equalSpacing
        detailStackView.alignment = UIStackView.Alignment.fill
        detailStackView.spacing   = 2.0
        detailStackView.addArrangedSubview(kaNameLabel)
        detailStackView.addArrangedSubview(kaOwnerEmailLabel)
        detailStackView.translatesAutoresizingMaskIntoConstraints = false
        
        parentStackView.axis = .horizontal
        parentStackView.backgroundColor = .red
        parentStackView.distribution = UIStackView.Distribution.fillProportionally
        parentStackView.alignment = UIStackView.Alignment.fill
        parentStackView.spacing   = 7.0
        parentStackView.addArrangedSubview(imageStackView)
        parentStackView.addArrangedSubview(detailStackView)
        parentStackView.translatesAutoresizingMaskIntoConstraints = false
        seprator.translatesAutoresizingMaskIntoConstraints = false
        seprator.backgroundColor = UIColor.paleLilac
        contentView.addSubview(seprator)
        let views = ["parentStackView": parentStackView, "kaProfileImageView": kaProfileImageView, "detailStackView": detailStackView, "kaOptionalLabel": kaOptionalLabel, "seprator": seprator]
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-12-[parentStackView]|", options:[], metrics:nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[kaOptionalLabel]-14-|", options:[], metrics:nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-59-[seprator]|", options:[], metrics:nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-12-[kaOptionalLabel]-13-|", options:[], metrics:nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-12-[parentStackView]-13-|", options:[], metrics:nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[seprator(1)]|", options:[], metrics:nil, views: views))
        
    }
    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}

class KREGrowingTextViewCell: UITableViewCell {
    var titleLabel: UILabel = {
        let titleLabel = UILabel(frame: CGRect.zero)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.numberOfLines = 0
        return titleLabel
    }()
    var authorLabel: UITextView = {
        let authorLabel = UITextView(frame: .zero)
        authorLabel.isScrollEnabled = false
        authorLabel.translatesAutoresizingMaskIntoConstraints = false
        return authorLabel
    }()
    // MARK: -init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: properties with observers
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func initialize() {
        selectionStyle = .none
        clipsToBounds = true
        
        titleLabel.textColor = UIColor.gunmetal
        titleLabel.font = UIFont.textFont(ofSize: 21.0, weight: .bold)
        titleLabel.backgroundColor = .clear
        contentView.addSubview(titleLabel)
        
        authorLabel.textColor = UIColor.charcoalGrey
        authorLabel.backgroundColor = .clear
        authorLabel.font = UIFont.textFont(ofSize: 15.0, weight: .regular)
        contentView.addSubview(authorLabel)
        
        titleLabel.setContentCompressionResistancePriority(UILayoutPriority.defaultHigh, for: .vertical)
        authorLabel.setContentCompressionResistancePriority(UILayoutPriority.defaultLow, for: .vertical)
        
        // Setting Constraints
        let views: [String: UIView] = ["titleLabel": titleLabel, "authorLabel": authorLabel]
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[titleLabel]-16-|", options:[], metrics:nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[authorLabel]-16-|", options:[], metrics:nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[titleLabel]-15-[authorLabel]-|", options:[], metrics:nil, views: views))
        contentView.layoutSubviews()
    }
    
    // MARK:- deinit
    deinit {
        
    }
}

public class KREMeetingButtonsCollectionViewCell: UICollectionViewCell {
    // MARK: - properties
    public var iconImage: UIImageView = UIImageView(frame: .zero)
    public var nameLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.textFont(ofSize: 14.0, weight: .regular)
        label.textColor = UIColor.charcoalGrey
        label.textAlignment = NSTextAlignment.center
        label.numberOfLines = 1
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        intialize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        intialize()
    }
    
    func intialize() {
        backgroundColor = UIColor.clear
        iconImage.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(nameLabel)
        contentView.addSubview(iconImage)
        
        let views: [String: Any] = ["nameLabel": nameLabel, "iconImage": iconImage]
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[iconImage(80)]-15-|", options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[iconImage(80)]-9-[nameLabel]", options: [], metrics: nil, views: views))
        nameLabel.centerXAnchor.constraint(equalTo: iconImage.centerXAnchor, constant: 0.0).isActive = true
        iconImage.layer.cornerRadius = 40
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
extension KREMeetingDetailViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return bottomSheetData.count
    }
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let collectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: collectionViewIdentifier, for: indexPath)
        if let cell = collectionViewCell as? KREMeetingButtonsCollectionViewCell  {
            //Take notes
            let dataToShow = bottomSheetData[indexPath.row]
            cell.iconImage.backgroundColor = dataToShow.color
            cell.iconImage.image = dataToShow.icon
            cell.nameLabel.text = dataToShow.title
            cell.iconImage.contentMode = .center
            cell.iconImage.tintColor = .white
        }
        return collectionViewCell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = self.bottomSheetCollectionView.cellForItem(at: indexPath) as? KREMeetingButtonsCollectionViewCell {
            switch cell.nameLabel.text {
            case "Join Meeting":
                guard let meeting = element?.meetJoin?.meetingUrl else{
                    return
                }
                guard let meetingUrl = URL(string: meeting) else { return }
                updateActivity(with: "Join Meeting")
                if  UIApplication.shared.canOpenURL(meetingUrl) {
                    UIApplication.shared.open(meetingUrl, options: [:])
                }
            case "Dial-in":
                guard let phone = element?.meetJoin?.dialIn else{
                    return
                }

                let phoneUrl = URL(string: "telprompt://\(phone)")
                let phoneFallbackUrl = URL(string: "tel://\(phone)")
                if let url = phoneUrl, UIApplication.shared.canOpenURL(url) {
                    updateActivity(with: "Dial-in")
                    UIApplication.shared.open(url, options: [:], completionHandler: { (success) in
                        if (!success) {
                            debugPrint("Error message: Failed to public the url")
                        }
                    })
                } else if let url = phoneFallbackUrl, UIApplication.shared.canOpenURL(url) {
                    updateActivity(with: "Dial-in")
                    UIApplication.shared.open(url, options: [:], completionHandler: { (success) in
                        if (!success) {
                            debugPrint("Error message: Failed to public the url")
                        }
                    })
                } else {
                    let alertController = UIAlertController(title: "Error!", message: "Phone calls are not configured on your device.", preferredStyle: .alert)
                    let noAction = UIAlertAction(title: "Ok", style: .cancel, handler: { (action) in
                    })
                    alertController.addAction(noAction)
                    self.present(alertController, animated: true, completion: nil)

                    debugPrint("Error message: Your device can not do phone calls")
                }
            case "Take Notes":
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "onTakeNotesButtonClick"), object: ["meetingData" : (self.element as? KRECalendarEvent), "controller": self])
                print("take notes")
            default:
                break
            }
        }
    }
    
    func prepareBottomSheetValues() {
        bottomSheetData.removeAll()
        if element?.meetJoin?.dialIn != nil {
            let color = UIColor.algaeGreen
            guard let image = UIImage(named: "dial-in")?.withRenderingMode(.alwaysTemplate) else { return }
            let title = "Dial-in"
            bottomSheetData.append(BottomSheetData(icon: image, title: title, color: color))
        }
        if element?.meetJoin?.meetingUrl != nil {
            let color = UIColor.lightRoyalBlue
            guard let image = UIImage(named: "join-meeting")?.withRenderingMode(.alwaysTemplate) else { return }
            let title = "Join Meeting"
            bottomSheetData.append(BottomSheetData(icon: image, title: title, color: color))
        }
        let color = UIColor.mango
        guard let image = UIImage(named: "notes")?.withRenderingMode(.alwaysTemplate) else { return }
        let title = "Take Notes"
        bottomSheetData.append(BottomSheetData(icon: image, title: title, color: color))
        bottomSheetCollectionView.reloadData()
    }
    
    // MARK: - UICollectionViewDelegateContactFlowLayout
    fileprivate var sectionInsets: UIEdgeInsets {
        return .zero
    }
    
    fileprivate var itemsPerRow: CGFloat {
        return 3
    }
    
    fileprivate var interitemSpace: CGFloat {
        return 5.0
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAt indexPath: IndexPath) -> CGSize {
        let sectionPadding = sectionInsets.left * (itemsPerRow + 1)
        let interitemPadding = max(0.0, itemsPerRow - 1) * interitemSpace
        let availableWidth = collectionView.bounds.width - sectionPadding - interitemPadding
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return interitemSpace
    }
    
    // MARK: -
    func updateActivity(with action: String) {
        switch action {
        case "Dial-in":
            let activityInfo = KREActivityInfo()
            activityInfo.action = "DAILIN"
            activityInfo.entity = "Meeting"
            if let entityId = element?.eventId {
                activityInfo.entityId = entityId
            }
            activityInfo.from = "widget"
            activityHandler?(activityInfo)
        case "Join Meeting":
            let activityInfo = KREActivityInfo()
            activityInfo.action = "JOIN"
            activityInfo.entity = "Meeting"
            if let entityId = element?.eventId {
                activityInfo.entityId = entityId
            }
            activityInfo.from = "widget"
            activityHandler?(activityInfo)
        default:
            break
        }
    }
}
