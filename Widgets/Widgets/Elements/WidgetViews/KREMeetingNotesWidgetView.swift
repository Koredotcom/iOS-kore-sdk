//
//  KREMeetingNotesWidgetView.swift
//  KoreBotSDK
//
//  Created by Srinivas Vasadi on 20/03/19.
//  Copyright © 2019 Srinivas Vasadi. All rights reserved.
//

import UIKit

public class KREMeetingNotesWidgetView: KREWidgetView {
    // MARK: - properites
    let bundle = Bundle(for: KREMeetingNotesWidgetView.self)
    var widgetManager = KREWidgetManager.shared

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
        tableView.tableFooterView = UIView(frame: .zero)
        return tableView
    }()
    public var widgetElementAction:((_ action: Any?, _ component: KREWidgetComponent?) -> Void)?
    public var viewMoreAction:((_ action: [Any]?) -> Void)?
    public var widgetActionHandler:((_ component: Any) -> Void)?
    public var addKnowledgeActionHandler:((_ component: Any) -> Void)?
    public var viewMoreActionTask:((_ action: [Any]?,_ component: KREWidgetComponent?) -> Void)?
    public var moreAction:(() -> Void)?
    public var sections:[(key: Date, value: [KREMeetingNote])]?
    public var elements: [KREMeetingNote]? {
        didSet {
            sections = widgetManager.sortMeetingNotes(elements)
        }
    }
    

    let noDataCellIdentifier = "KREWidgetNoDataTableViewCell"
    let widgetViewCellIdentifier = "KREWidgetViewCell"
    let meetingNotesCellIdentifier = "KREMeetingNotesViewCell"
    let buttonTemplateCellIdentifier = "KREButtonTemplateCellIdentifier"
    let headerViewIdentifier = "KREWidgetHeaderFooterView"
    
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
        tableView.register(KREMeetingNotesViewCell.self, forCellReuseIdentifier: meetingNotesCellIdentifier)
        tableView.register(KREButtonTemplateCell.self, forCellReuseIdentifier: buttonTemplateCellIdentifier)
        tableView.register(KREWidgetNoDataTableViewCell.self, forCellReuseIdentifier: noDataCellIdentifier)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: widgetViewCellIdentifier)
        tableView.register(KREWidgetHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: headerViewIdentifier)
        addSubview(tableView)
        
        let views = ["tableView": tableView]
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[tableView]|", options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[tableView]|", options: [], metrics: nil, views: views))
    }
    
    // MARK: - KREWidgetView methods
    override public var widget: KREWidget? {
        didSet {
            
        }
    }
    
    override public var widgetComponent: KREWidgetComponent? {
        didSet {
            if let items = widgetComponent?.elements as? [KREMeetingNote] {
                elements = items
            } else {
                elements = nil
            }
            
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
    
    // MARK: -
    open override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return subviews.contains {
            !$0.isHidden && $0.point(inside: convert(point, to: $0), with: event)
        }
    }
    
    func reloadWidget(_ widget: KREWidget) {
        switch widget.widgetState {
        case .loading:
            break
        case .loaded:
            tableView.reloadData()
            tableView.layoutIfNeeded()
        case .refreshed, .refreshing:
            tableView.reloadSections([0], with: .none)
            tableView.layoutIfNeeded()
        case .noData:
            tableView.reloadData()
            tableView.layoutIfNeeded()
        case .requestFailed:
            break
        case .noNetwork:
            break
        case .none:
            break
        }
    }
    
    // MARK:- deinit
    deinit {

    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension KREMeetingNotesWidgetView: UITableViewDelegate, UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        let numberOfSections = sections?.count ?? 0
        switch widget?.widgetState {
        case .loading?:
            return 1
        case .loaded?, .refreshed?, .refreshing?:
            if numberOfSections == 0 {
                return 1
            }

            switch widgetViewType {
            case .trim:
                return min(numberOfSections, MAX_SECTIONS) + 1
            case .full:
                return numberOfSections
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
                var eventsCount = 0
                var elements = [KREMeetingNote]()
                let sectionsCount = sections?.count ?? 0
                for index in 0..<section {
                    if index < sectionsCount {
                        eventsCount += sections?[index].value.count ?? 0
                    }
                }

                switch section {
                case 0..<MAX_SECTIONS:
                    let count = min(sections?.count ?? 0, MAX_ELEMENTS)
                    if section < count {
                        elements = sections?[section].value ?? []
                    }
                    
                    let remaining = max(MAX_ELEMENTS - eventsCount, 0)
                    return min(remaining, elements.count)
                default:
                    if eventsCount > MAX_ELEMENTS {
                        return 1
                    }
                    return 0
                }
            case .full:
                return sections?[section].value.count ?? 0
            }
        case .noData?:
            return 1
        default:
            return 0
        }
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cellIdentifier = widgetViewCellIdentifier
        switch widget?.widgetState {
        case .loading?:
            cellIdentifier = meetingNotesCellIdentifier
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
            if let cell = cell as? KREMeetingNotesViewCell {
                
            }
            return cell
        case .loaded?, .refreshing?, .refreshed?:
            switch widgetViewType {
            case .trim:
                let count = min(sections?.count ?? 0, MAX_ELEMENTS)
                if indexPath.section < count {
                    return widgetViewCell(for: indexPath)
                } else {
                    return buttonTemplateCell(at: indexPath)
                }
            case .full:
                return widgetViewCell(for: indexPath)
            }
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: noDataCellIdentifier, for: indexPath)
            if let cell = cell as? KREWidgetNoDataTableViewCell, let elementsCount = elements?.count, elementsCount == 0 {
                cell.noDataView.noDataLabel.text = NSLocalizedString("No Data", comment: "No Data")
                cell.separatorInset = UIEdgeInsets(top: 0.0, left: bounds.size.width ?? 0, bottom: 0.0, right: 0.0)
            }
            return cell
        }
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch widgetViewType {
        case .trim:
            switch indexPath.section {
            case 0..<MAX_ELEMENTS:
                let elements = sections?[indexPath.section].value
                if let element = elements?[indexPath.row] {
                    viewDelegate?.elementAction(for: element, in: widget)
                }
            default:
                viewDelegate?.viewMoreElements(for: widgetComponent, in: widget)
            }
        case .full:
            if let element = elements?[indexPath.row] {
                viewDelegate?.elementAction(for: element, in: widget)
            }
        }
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch widgetViewType {
        case .trim:
            switch section {
            case MAX_SECTIONS:
                return nil
            default:
                let count = tableView.numberOfRows(inSection: section)
                guard count > 0 else {
                    return nil
                }
            }
            
            fallthrough
        case .full:
            let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: headerViewIdentifier)
            if let headerFooterView = headerView as? KREWidgetHeaderFooterView {
                headerFooterView.bubbleView.moveButton.isHidden = true
                headerFooterView.sepratorLine.isHidden = false
                var title = ""
                let sectionData = sections?[section]
                if let date = sectionData?.key {
                    if Date().isTomorow(as: date) {
                        title = NSLocalizedString("Tomorrow", comment: "Tomorrow")
                    } else if Date().isSameDay(as: date) {
                        title = NSLocalizedString("Today", comment: "Today")
                    } else if date.isYesterday(Date()) {
                        title = NSLocalizedString("Yesterday", comment: "Yesterday")
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
        switch widgetViewType {
        case .trim:
            switch section {
            case 0..<MAX_SECTIONS:
                let count = tableView.numberOfRows(inSection: section)
                guard count > 0 else {
                    return CGFloat.leastNormalMagnitude
                }
                return UITableView.automaticDimension
            default:
                return CGFloat.leastNormalMagnitude
            }
        case .full:
            return UITableView.automaticDimension
        }
    }
    
    public func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        switch widgetViewType {
        case .trim:
            var eventsCount = 0
            var elements = [KREMeetingNote]()
            let sectionsCount = sections?.count ?? 0
            for index in 0..<section {
                if index < sectionsCount {
                    eventsCount += sections?[index].value.count ?? 0
                }
            }

            switch section {
            case 0..<MAX_SECTIONS:
                let count = min(sections?.count ?? 0, MAX_ELEMENTS)
                if section < count {
                    elements = sections?[section].value ?? []
                }
                
                let remaining = max(MAX_ELEMENTS - eventsCount, 0)
                if remaining > 0 {
                    return 36.0
                }
                return CGFloat.leastNormalMagnitude
            default:
                if eventsCount > MAX_ELEMENTS {
                    return 36.0
                }
                return CGFloat.leastNormalMagnitude
            }
        case .full:
            return 36.0
        }
    }
}

// MARK: - KREWidgetViewDataSource
extension KREMeetingNotesWidgetView: KREWidgetViewDataSource {
    public func willUpdateWidget(_ widget: KREWidget) {
        
    }
    
    public func didUpdateWidget(_ widget: KREWidget) {
        DispatchQueue.main.async {
            self.reloadWidget(widget)
        }
    }
}

// MARK: - meeting notes population
extension KREMeetingNotesWidgetView {
    // MARK: -
    func widgetViewCell(for indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: meetingNotesCellIdentifier, for: indexPath)
        if let allDates = sections?[indexPath.section] {
            let notes = allDates.value[indexPath.row]
            if let cell = cell as? KREMeetingNotesViewCell, let element = notes as? KREMeetingNote {
                cell.meetingNotesView.populateView(element)
            }
        }
        cell.selectionStyle = .none
        cell.layoutSubviews()
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
}
