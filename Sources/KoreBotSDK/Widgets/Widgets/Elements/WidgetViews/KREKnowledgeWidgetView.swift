//
//  KREKnowledgeWidgetView.swift
//  KoreBotSDK
//
//  Created by Srinivas Vasadi on 13/03/19.
//  Copyright © 2019 Srinivas Vasadi. All rights reserved.
//

import UIKit

public class KREKnowledgeWidgetView: KREWidgetView {
    // MARK: - properites
    let bundle = Bundle.sdkModule
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
    public var elements: [KREKnowledgeItem]?

    let utteranceListCellIdentifier = "KREUtteranceListCell"
    let noDataCellIdentifier = "KREWidgetNoDataTableViewCell"
    let widgetViewCellIdentifier = "KREWidgetViewCell"
    let announcementCellIdentifier = "KAAnnouncementsTableViewCell"
    let knowledgeCellIdentifier = "KAKnowledgeTableViewCell"
    let hashTagCellIdentifier = "KRETrendingHashtagTableViewCell"
    let buttonTemplateCellIdentifier = "KREButtonTemplateCellIdentifier"

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
        NotificationCenter.default.removeObserver(self)
        tableView.register(KRETrendingHashtagTableViewCell.self, forCellReuseIdentifier: hashTagCellIdentifier)
        tableView.register(KAKnowledgeTableViewCell.self, forCellReuseIdentifier: knowledgeCellIdentifier)
        tableView.register(KREHelpUtteranceTableViewCell.self, forCellReuseIdentifier: utteranceListCellIdentifier)
        tableView.register(KAAnnouncementsTableViewCell.self, forCellReuseIdentifier: announcementCellIdentifier)
        tableView.register(KREButtonTemplateCell.self, forCellReuseIdentifier: buttonTemplateCellIdentifier)
        tableView.register(KREWidgetNoDataTableViewCell.self, forCellReuseIdentifier: noDataCellIdentifier)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: widgetViewCellIdentifier)
        addSubview(tableView)
        tableView.tableFooterView = UIView(frame: CGRect(x: CGFloat(0), y: CGFloat(0), width: tableView.bounds.width, height: CGFloat(44)))
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
            if let items = widgetComponent?.elements as? [KREKnowledgeItem] {
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
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension KREKnowledgeWidgetView: UITableViewDelegate, UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let _ = widgetComponent else {
            return 0
        }
        
        let count = elements?.count ?? 0
        switch widgetViewType {
        case .trim:
            return min(MAX_ELEMENTS + 1, count > 0 ? count : 1)
        case .full:
            return count > 0 ? count : 1
        }
    }

    public func showLoadingIndicatorOnTableView() {
        let spinner = UIActivityIndicatorView(style: .gray)
        spinner.startAnimating()
        spinner.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: tableView.bounds.width, height: CGFloat(44))

        tableView.tableFooterView = spinner
        tableView.tableFooterView?.isHidden = false
    }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cellIdentifier = widgetViewCellIdentifier
        var templateType = KRETemplateType.none
        switch widget?.widgetState {
        case .loading?:
            switch widget?.widgetId {
            case WidgetId.article.rawValue:
                templateType = .knowledge
                cellIdentifier = knowledgeCellIdentifier
                let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
                if let cell = cell as? KAKnowledgeTableViewCell {
                    cell.loadingDataState()
                }
                return cell
            case WidgetId.announcement.rawValue:
                templateType = .announcement
                cellIdentifier = announcementCellIdentifier
                let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
                if let cell = cell as? KAAnnouncementsTableViewCell {
                    cell.loadingDataState()
                }
                return cell
            default:
                return UITableViewCell(style: .value1, reuseIdentifier: widgetViewCellIdentifier)
            }
        default:
            let elementsCount = elements?.count ?? 0
            if elementsCount == 0 {
                cellIdentifier = noDataCellIdentifier
                let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
                if let cell = cell as? KREWidgetNoDataTableViewCell {
                    switch widget?.widgetId {
                    case WidgetId.article.rawValue:
                        cell.noDataView.noDataLabel.text = NSLocalizedString("No Knowledge data", comment: "No Knowledge data")
                    case WidgetId.announcement.rawValue:
                        cell.noDataView.noDataLabel.text = NSLocalizedString("No Announcement data", comment: "No Announcement data")
                    default:
                        cell.noDataView.noDataLabel.text = NSLocalizedString("No Data", comment: "No Data")
                    }
                }
                cell.separatorInset = UIEdgeInsets(top: 0.0, left: bounds.size.width ?? 0, bottom: 0.0, right: 0.0)
                return cell
            }
        }
        
        guard let element = elements?[indexPath.row] else {
            return UITableViewCell(style: .value1, reuseIdentifier: widgetViewCellIdentifier)
        }
        setTemplateTypeOfElements(&templateType, &cellIdentifier, element, widget: widget)
        
        switch widgetViewType {
        case .trim:
            switch indexPath.row {
            case 0..<MAX_ELEMENTS:
                return widgetViewCell(cellIdentifier: cellIdentifier, indexPath: indexPath, element: element, templateType: templateType)
            default:
                let cellIdentifier = buttonTemplateCellIdentifier
                let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
                if let cell = cell as? KREButtonTemplateCell {
                    cell.title = NSLocalizedString("View more", comment: "View more")
                }
                cell.layoutSubviews()
                return cell
            }
        case .full:
            return widgetViewCell(cellIdentifier: cellIdentifier, indexPath: indexPath, element: element, templateType: templateType)
        }
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch widgetViewType {
        case .trim:
            switch indexPath.row {
            case 0..<MAX_ELEMENTS:
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
    
    // MARK: - UITableViewDelegateSource
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 84.0
    }
}

// MARK: - KREWidgetViewDataSource
extension KREKnowledgeWidgetView: KREWidgetViewDataSource {
    public func willUpdateWidget(_ widget: KREWidget) {
        
    }
    
    public func didUpdateWidget(_ widget: KREWidget) {
        DispatchQueue.main.async {
            self.reloadWidget(widget)
        }
    }
}

// MARK: -
extension KREKnowledgeWidgetView {
    // MARK: -
    func widgetViewCell(cellIdentifier: String, indexPath: IndexPath, element: Decodable, templateType: KRETemplateType) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        switch templateType {
        case .announcement:
            if let cell = cell as? KAAnnouncementsTableViewCell, let knowledgeItem = element as? KREKnowledgeItem {
                cell.loadedDataState()
                configureAnnouncementItemCell(cell, at: indexPath, knowledgeItem: knowledgeItem)
            }
        case .knowledge:
            if let cell = cell as? KAKnowledgeTableViewCell, let knowledgeItem = element as? KREKnowledgeItem {
                configureKnowledgeItemCell(cell, at: indexPath, knowledgeItem: knowledgeItem)
            }
        case .hashTag:
            if let cell = cell as? KRETrendingHashtagTableViewCell, let hashTagItem = element as? KREHashTag {
                cell.titleLabel.text = "#\(hashTagItem.name ?? "")"
                if let count = hashTagItem.count  {
                    cell.viewLabel.text =  count > 1 ? "\(count) Articles":"\(count) Article"
                }
            }
        case .button:
            let selectedFilters = widget?.filters?.filter { $0.isSelected == true }
            if let cell = cell as? KREButtonTemplateCell {
                cell.title = NSLocalizedString("View more", comment: "View more")
            }
        default:
            break
        }
        cell.selectionStyle = .none
        cell.layoutSubviews()
        return cell
    }
    
    // MARK: - configure KnowledgeItem cell
    func configureAnnouncementItemCell(_ informationViewCell: KAAnnouncementsTableViewCell, at indexPath: IndexPath, knowledgeItem: KREKnowledgeItem) {
        let jsonDecoder = JSONDecoder()
        if let owner = knowledgeItem.owner {
            let firstName = owner.fN
            let lastName  = owner.lN
            let color = owner.color
            let identity = widgetManager.profileIdentity(for: owner)
            informationViewCell.kaProfileImageView.setProfileImage(for: identity, initials: true)
            if let firstName = firstName {
                informationViewCell.kaNameLabel.text = "\(firstName) \(lastName ?? "")"
            }
        }
        if let sharedList = knowledgeItem.sharedList {
            var sharedListStr = ""
            for contact in sharedList ?? [] {
                if let name = contact.name {
                    sharedListStr += "\(name), "
                }
            }
            let resultStr = String(sharedListStr.dropLast(2))
            informationViewCell.kaSharedListLabel.text = resultStr
        }
        
        if let lastModifiedOn = knowledgeItem.lastModified, let sharedOn = knowledgeItem.sharedOn {
            var dateStr = ""
            if sharedOn == lastModifiedOn {
                let lastModifiedOnInSeconds = Double(truncating: NSNumber(value: lastModifiedOn)) / 1000
                let lastModifiedDate = Date(timeIntervalSince1970: lastModifiedOnInSeconds)

                let dateTime = lastModifiedDate as Date
                if Date().isSameDay(as: dateTime) {
                    dateStr = dateTime.formatTimeAsHours()
                } else if dateTime.isYesterday(Date()) {
                    dateStr = "Yesterday"
                } else {
                    dateStr = dateTime.formatAsDayShortDate(using: dateTime)
                }
                informationViewCell.dateLabel.text = dateStr
            } else {
                let lastModifiedOnInSeconds = Double(truncating: NSNumber(value: lastModifiedOn)) / 1000
                let lastModifiedDate = Date(timeIntervalSince1970: lastModifiedOnInSeconds)

                let dateTime = lastModifiedDate as Date
                if Date().isSameDay(as: dateTime) {
                    dateStr = dateTime.formatTimeAsHours()
                } else if dateTime.isYesterday(Date()) {
                    dateStr = "Yesterday"
                } else {
                    dateStr = dateTime.formatAsDayShortDate(using: dateTime)
                }
                informationViewCell.dateLabel.text = dateStr
            }
        }
        if let desc = knowledgeItem.desc {
            informationViewCell.kaSubTitleLabel.text = desc.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        if let title = knowledgeItem.title {
            informationViewCell.kaTitleLabel.text = title.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        let isSeedData = knowledgeItem.isSeedData ?? false
        if isSeedData {
            informationViewCell.actionContainerHeightConstraint.isActive = false
            informationViewCell.layoutSubviews()
        } else {
            informationViewCell.actionContainerHeightConstraint.isActive = true
            informationViewCell.layoutSubviews()

            if let comments = knowledgeItem.nComments {
                informationViewCell.kaCommentLabel.text = " \(comments)"
            }
            if let upVotes = knowledgeItem.nUpVotes {
                informationViewCell.kaLikeLabel.text = "\(upVotes)"
            }
        }
    }
    
    // MARK: - configure KnowledgeItem cell
    func configureKnowledgeItemCell(_ informationViewCell: KAKnowledgeTableViewCell, at indexPath: IndexPath, knowledgeItem: KREKnowledgeItem) {
        informationViewCell.loadedDataState()
        let informationView = informationViewCell.templateView
        if let count = knowledgeItem.title?.count, count > 0 {
            informationView.titleLabel.text = knowledgeItem.title
        } else {
            informationView.titleLabel.text = NSLocalizedString("[Untitled Article]", comment: "Article")
        }
        
        if let count = knowledgeItem.desc?.count, count > 0 {
            informationView.subTitleLabel.text = knowledgeItem.desc
        } else {
            informationView.subTitleLabel.text = NSLocalizedString("[No description added]", comment: "Article")
            informationView.subTitleLabel.font = UIFont.textItalicFont(ofSize: 15.0)
        }

        if let createdOn = knowledgeItem.createdOn, let sharedOn = knowledgeItem.sharedOn {
            if sharedOn != nil {
                let createdOnInSeconds = Double(truncating: NSNumber(value: sharedOn)) / 1000
                let createdOnDate = Date(timeIntervalSince1970: createdOnInSeconds)
                let dateTime = createdOnDate as Date
                let dateStr = dateTime.formatAsDayShort(using: createdOnDate)
                informationView.dateLabel.text = "Modified: " + dateStr
            } else {
                let createdOnInSeconds = Double(truncating: NSNumber(value: createdOn)) / 1000
                let createdOnDate = Date(timeIntervalSince1970: createdOnInSeconds)
                let dateTime = createdOnDate as Date
                let dateStr = dateTime.formatAsDayShort(using: createdOnDate)
                informationView.dateLabel.text = "Created: " + dateStr
            }
        }

        informationView.loadDescriptionImage(knowledgeItem.imageUrl)

        let isSeedData = knowledgeItem.isSeedData ?? false
        if isSeedData {
            informationView.horizontalStackView.isHidden = true
            informationViewCell.layoutSubviews()
        } else {
            informationView.horizontalStackView.isHidden = false
            if let comments = knowledgeItem.nComments {
                informationView.commentCountLabel.text = "\(comments)"
            }
            if let votes = knowledgeItem.nUpVotes {
                informationView.likeCountLabel.text = "\(votes)"
            }
            if let downVotes = knowledgeItem.nDownVotes {
                informationView.dislikeCountLabel.text = "\(downVotes)"
            }
            if let views = knowledgeItem.nViews {
                informationView.spectatorCountLabel.text = "\(views)"
            }
            informationViewCell.layoutSubviews()
        }
    }

    func setTemplateTypeOfElements(_ templateType: inout KRETemplateType, _ cellIdentifier: inout String,_ element: Any?, widget: KREWidget?) {
        if let _ = element as? KREButtonTemplate {
            templateType = .button
            cellIdentifier = buttonTemplateCellIdentifier
        } else if let element = element as? KREKnowledgeItem {
            if element.isAnnounement {
                templateType = .announcement
                cellIdentifier = announcementCellIdentifier
            } else {
                templateType = .knowledge
                cellIdentifier = knowledgeCellIdentifier
            }
        } else if let _ = element as? KREHashTag {
            templateType = .hashTag
            cellIdentifier = hashTagCellIdentifier
        }
    }
    
    func getInitialsFromNameOne(name1: String, name2: String) -> String {
        let firstName = name1.first ?? Character(" ")
        let lastName = name2.first ?? Character(" ")
        return "\(firstName)\(lastName)".trimmingCharacters(in: .whitespaces)
    }
}
