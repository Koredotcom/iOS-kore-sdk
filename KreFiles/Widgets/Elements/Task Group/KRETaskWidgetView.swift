//
//  KRETaskWidgetView.swift
//  KoreBotSDK
//
//  Created by Srinivas Vasadi on 13/03/19.
//  Copyright © 2019 Srinivas Vasadi. All rights reserved.
//

import UIKit

public enum KRETemplateType: Int {
    case none = 0, calendarEvent = 1, fileSearch = 2, taskList = 3, button = 4, announcement = 5, knowledge = 6, hashTag = 7, skill = 8, customWidget = 9, customWidgetCircle = 10, loginWidget = 11
}

public enum WidgetId: String {
    case upcomingTasksWidgetId = "upcomingTasks"
    case overdueTasksWidgetId = "overdueTasks"
    case files = "cloudFiles"
    case upcomingMeetings = "upcomingMeetings"
    case article = "Article"
    case announcement = "Announcement"
}

// MARK: - KRETaskWidgetView
public class KRETaskWidgetView: KREWidgetView {
    // MARK: - properites
    public lazy var stackView: KREStackView = {
        let stackView = KREStackView(frame: .zero)
        stackView.axis = .vertical
        stackView.separatorColor = .paleLilacFour
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.automaticallyHidesLastSeparator = true
        return stackView
    }()
    
    public var updateSubviews:(() -> Void)?
    var elements: [KRETaskListItem]?
    
    public weak var widgetViewDelegate: KREWidgetViewDelegate?
    public var actionHandler:((KREAction) -> Void)?
    
    lazy var titleStrikeThroughAttributes: [NSAttributedString.Key: Any] = {
        return [.font: UIFont.textFont(ofSize: 14.0, weight: .bold), .foregroundColor: UIColor.blueyGrey]
    }()
    
    lazy var taskTitleAttributes: [NSAttributedString.Key: Any] = {
        return [.font: UIFont.textFont(ofSize: 14.0, weight: .bold), .foregroundColor: UIColor.gunmetal]
    }()
    
    // MARK: - init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    func setup() {
        addSubview(stackView)
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[stackView]|", options:[], metrics: nil, views: ["stackView": stackView]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[stackView]|", options:[], metrics: nil, views: ["stackView": stackView]))
    }
        
    func populateWidget() {
        stackView.removeAllRows()
        switch widget?.widgetState {
        case .loading?:
            let cell = KRECustomWidgetView(frame: .zero)
            cell.translatesAutoresizingMaskIntoConstraints = false
            cell.loadingDataState()
            stackView.addRow(cell)
        case .loaded?, .refreshed?, .refreshing?:
            let numberOfRows = min(MAX_ELEMENTS + 1, elements?.count ?? 1)
            for index in 0..<numberOfRows {
                switch index {
                case 0..<MAX_ELEMENTS:
                    let element = elements?[index]
                    let listItemView = KRETaskListItemView(frame: .zero)
                    listItemView.translatesAutoresizingMaskIntoConstraints = false
                    if let taskListItem = element as? KRETaskListItem {
                        configureTaskListItemView(listItemView, taskListItem: taskListItem)
                        
                        listItemView.layoutSubviews()
                        stackView.addRow(listItemView)

                        stackView.setTapHandler(forRow: listItemView) { [weak self] (listItemView) in
                            self?.viewDelegate?.elementAction(for: taskListItem, in: self?.widget)
                        }
                    }
                default:
                    let buttonView = KREButtonView()
                    buttonView.translatesAutoresizingMaskIntoConstraints = false
                    buttonView.title = NSLocalizedString("View more", comment: "Widgets")
                    stackView.addRow(buttonView)
                    
                    stackView.setTapHandler(forRow: buttonView) { [weak self] (view) in
                        self?.viewDelegate?.viewMoreElements(for: self?.widgetComponent, in: self?.widget)
                    }
                }
            }
        default:
            break
        }
        layoutSubviews()
        invalidateIntrinsicContentSize()
        updateSubviews?()
    }
    
    // MARK: - KREWidgetView methods
    override public var widget: KREWidget? {
        didSet {
            populateWidget()
        }
    }
    
    override public var widgetComponent: KREWidgetComponent? {
        didSet {
            if let taskElements = widgetComponent?.elements as? [KRETaskListItem] {
                elements = taskElements
            }
            
            populateWidget()
            invalidateIntrinsicContentSize()
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
        populateWidget()
        layoutIfNeeded()
        invalidateIntrinsicContentSize()
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
}

// MARK: -
extension KRETaskWidgetView {
    func configureTaskListItemView(_ view: KRETaskListItemView, taskListItem: KRETaskListItem) {
        var utcDate: Date?
        view.loadedDataState()
        
        if let dueDate = taskListItem.dueDate {
            view.dateTimeLabel.text = convertUTCToDate(dueDate)
            utcDate = Date(milliseconds: Int64(truncating: NSNumber(value: dueDate)))
        }
        view.itemSelectionHandler = { [weak self] (taskListItemCell) in
            
        }
        view.moreSelectionHandler = { [weak self] (taskListItemCell) in
            self?.viewDelegate?.elementAction(for: taskListItem, in: self?.widget)
        }
        
        let assigneeMatching = KREWidgetManager.shared.user?.userId == taskListItem.assignee?.id
        let ownerMatching = KREWidgetManager.shared.user?.userId == taskListItem.owner?.id
        
        if assigneeMatching {
            view.assigneeLabel.text = "You"
        } else {
            view.assigneeLabel.text = taskListItem.assignee?.fullName
        }
        if ownerMatching {
            view.ownerLabel.text = "You"
        } else {
            view.ownerLabel.text = taskListItem.owner?.fullName
        }
        if ownerMatching && assigneeMatching {
            view.ownerLabel.text = "You"
            view.assigneeLabel.isHidden = true
            view.triangle.isHidden = true
        } else {
            view.assigneeLabel.isHidden = false
            view.triangle.isHidden = false
        }
        view.selectionView.isHidden = true
        view.selectionViewWidthConstraint.constant = 0.0
        view.selectionViewLeadingConstraint.constant = 0.0
        if let status = taskListItem.status, let taskTitle = taskListItem.title {
            switch status.lowercased() {
            case "close":
                let attributeString =  NSMutableAttributedString(string: taskTitle, attributes: titleStrikeThroughAttributes)
                attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: NSMakeRange(0, attributeString.length))
                view.titleLabel.attributedText = attributeString
                view.ownerLabel.textColor = UIColor.blueyGrey
                view.assigneeLabel.textColor = UIColor.blueyGrey
                view.dateTimeLabel.textColor = UIColor.blueyGrey
                view.selectionView.isSelected = taskListItem.isSelected
                if taskListItem.isSelected {
                    view.backgroundColor = UIColor(red: 252/255, green: 234/255, blue: 236/255, alpha: 1)
                } else {
                    view.backgroundColor = UIColor.white
                }
            default:
                view.titleLabel.attributedText = NSAttributedString(string: taskTitle, attributes: taskTitleAttributes)
                view.ownerLabel.textColor = UIColor.gunmetal
                view.assigneeLabel.textColor = UIColor.gunmetal
                let comparasionResult = compareDates(Date(), utcDate)
                
                if comparasionResult == .orderedAscending {
                    view.dateTimeLabel.textColor = UIColor.gunmetal
                } else {
                    view.dateTimeLabel.textColor = UIColor.red
                }
                
                view.selectionView.isSelected = taskListItem.isSelected
                if taskListItem.isSelected {
                    view.backgroundColor = UIColor(red: 252/255, green: 234/255, blue: 236/255, alpha: 1)
                } else {
                    view.backgroundColor = UIColor.white
                }
            }
        }
    }
        
    func getInitialsFromNameOne(name1: String, name2: String) -> String {
        let firstName = name1.first ?? Character(" ")
        let lastName = name2.first ?? Character(" ")
        return "\(firstName)\(lastName)".trimmingCharacters(in: .whitespaces)
    }
}

// MARK: - KREWidgetHeaderFooterView
public class KREWidgetHeaderFooterView: UITableViewHeaderFooterView {
    // MARK: - properties
    public lazy var bubbleView: KREWidgetBubbleView = {
        let bubbleView = KREWidgetBubbleView()
        bubbleView.translatesAutoresizingMaskIntoConstraints = false
        return bubbleView
    }()
    
    public lazy var sepratorLine: UIView = {
        let view = UIView(frame: .zero)
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    // MARK: -
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        bubbleView.prepareForReuse()
    }
    
    // MARK: -
    func setup() {
        contentView.addSubview(bubbleView)
        contentView.addSubview(sepratorLine)

        let bubbleViews: [String: UIView] = ["bubbleView": bubbleView, "sepratorLine": sepratorLine]
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[bubbleView]-1-|", options: [], metrics: nil, views: bubbleViews))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[sepratorLine(1)]-|", options: [], metrics: nil, views: bubbleViews))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[bubbleView]|", options: [], metrics: nil, views: bubbleViews))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[sepratorLine]|", options: [], metrics: nil, views: bubbleViews))
    }
}

extension Date {
    public func formatTimeAsHours() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        dateFormatter.amSymbol = "am"
        dateFormatter.pmSymbol = "pm"
        return dateFormatter.string(from: self)
    }
    
    //Fri, Mar 30 2018
    public func formatTimeAsFullDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d LLL, yyyy, h:mm a"
        dateFormatter.amSymbol = "am"
        dateFormatter.pmSymbol = "pm"
        return dateFormatter.string(from: self)
    }
}
