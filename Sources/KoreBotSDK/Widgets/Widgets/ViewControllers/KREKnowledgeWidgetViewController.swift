//
//  KREKnowledgeWidgetViewController.swift
//  KoreBotSDK
//
//  Created by Srinivas Vasadi on 16/04/2020.
//  Copyright © 2020 Srinivas Vasadi. All rights reserved.
//

import UIKit

public class KREKnowledgeWidgetViewController: UIViewController {
    // MARK: - properites
    let bundle = Bundle.sdkModule
    var requestInProgress: Bool = false
    var isScrolling: Bool = false
    var needLoadMore: Bool = true
    var selectedIndex = 0
    var hasMore = false
    var pagination = false
    var hook: Hook?
    lazy var errorView: UIButton = {
        let errorView = UIButton(frame: .zero)
        errorView.backgroundColor = .paleLilacFour
        errorView.translatesAutoresizingMaskIntoConstraints = false
        errorView.titleLabel?.font = UIFont.textFont(ofSize: 14.0, weight: .bold)
        errorView.titleLabel?.textAlignment = .center
        errorView.titleLabel?.lineBreakMode = .byWordWrapping
        errorView.titleLabel?.numberOfLines = 0
        errorView.setTitleColor(.black, for: .normal)
        errorView.setImage(UIImage(named: "refreshAlert"), for: .normal)
        errorView.imageEdgeInsets = UIEdgeInsets(top: 0.0, left: (view.bounds.width - 50), bottom: 0.0, right: 0.0)
        errorView.titleEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 60.0)
        return errorView
    }()

    public lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = UIColor.clear
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.alwaysBounceHorizontal = false
        tableView.bounces = false
        tableView.tableFooterView = UIView(frame: .zero)
        return tableView
    }()
    public var widgetElementAction:((_ action: Any?, _ component: KREWidgetComponent?) -> Void)?
    public var viewMoreAction:((_ action: [Any]?) -> Void)?
    public var widgetActionHandler:((_ component: Any) -> Void)?
    public var addKnowledgeActionHandler:((_ component: Any) -> Void)?
    public var viewMoreActionTask:((_ action: [Any]?,_ component: KREWidgetComponent?) -> Void)?
    public weak var delegate: KREGenericWidgetViewDelegate?
    public var widget: KREWidget? {
        didSet {
            tableView.reloadData()
            scrollToTop()
        }
    }
    public var moreAction:(() -> Void)?
    public var elements: [KREKnowledgeItem]?
    var widgetManager = KREWidgetManager.shared

    let utteranceListCellIdentifier = "KREUtteranceListCell"
    let noDataCellIdentifier = "KREWidgetNoDataTableViewCell"
    let widgetViewCellIdentifier = "KREWidgetViewCell"
    let announcementCellIdentifier = "KAAnnouncementsTableViewCell"
    let knowledgeCellIdentifier = "KAKnowledgeTableViewCell"
    let hashTagCellIdentifier = "KRETrendingHashtagTableViewCell"
    let widgetHeaderViewIdentifier = "KREWidgetHeaderView"
    let widgetFooterViewIdentifier = "KREWidgetFooterView"
    let buttonTemplateCellIdentifier = "KREButtonTemplateCellIdentifier"

    // MARK: - init
    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        tableView.register(KRETrendingHashtagTableViewCell.self, forCellReuseIdentifier: hashTagCellIdentifier)
        tableView.register(KAKnowledgeTableViewCell.self, forCellReuseIdentifier: knowledgeCellIdentifier)
        tableView.register(KREHelpUtteranceTableViewCell.self, forCellReuseIdentifier: utteranceListCellIdentifier)
        tableView.register(KAAnnouncementsTableViewCell.self, forCellReuseIdentifier: announcementCellIdentifier)
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
    
    // MARK: -
    public var widgetComponent: KREWidgetComponent? {
        didSet(newValue) {
            if widgetComponent == newValue {
               return
            }
            if let knowledgeItems = widgetComponent?.elements as? [KREKnowledgeItem] {
                elements = knowledgeItems
                if let hook = widget?.hook {
                    self.hook = hook
                } else {
                    let selectedFilters = widget?.filters?.filter { $0.isSelected == true}
                    if let filter = selectedFilters?.first {
                        self.hook = filter.hook
                    }
                }
                hasMore = widgetComponent?.hasMore ?? false
            }
        }
    }
    
    public func prepareForReuse() {
//        widgetComponent = nil
//        widget = nil
        tableView.reloadData()
    }

    // MARK: -
    func populateWidgetComponent(in section: Int) {
        let selectedFilters = widget?.filters?.filter { $0.isSelected == true}
        if let widgetFilter = selectedFilters?.first, let component = widgetFilter.component {
            widgetComponent = component
        } else {
            widgetComponent = nil
        }
    }
    
    // MARK: -
    func reloadWidget(_ widget: KREWidget) {
        switch widget.widgetState {
        case .loading:
            break
        case .loaded, .refreshed, .refreshing:
            tableView.reloadData()
        case .noData:
            tableView.reloadData()
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
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension KREKnowledgeWidgetViewController: UITableViewDelegate, UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !pagination {
            populateWidgetComponent(in: section)
        }
        guard let _ = widgetComponent else {
            return 0
        }
        
        if let count = elements?.count, count > 0 {
            return count
        }
        
        return 1
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
                let tableViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
                if let cell = tableViewCell as? KAKnowledgeTableViewCell {
                    cell.loadingDataState()
                }
                return tableViewCell
            case WidgetId.announcement.rawValue:
                templateType = .announcement
                cellIdentifier = announcementCellIdentifier
                let tableViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
                if let cell = tableViewCell as? KAAnnouncementsTableViewCell {
                    cell.loadingDataState()
                }
                return tableViewCell
            default:
                return UITableViewCell(style: .value1, reuseIdentifier: widgetViewCellIdentifier)
            }
        default:
            let elementsCount = elements?.count ?? 0
            if elementsCount == 0 {
                cellIdentifier = noDataCellIdentifier
                let tableViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
                if let cell = tableViewCell as? KREWidgetNoDataTableViewCell {
                    switch widget?.widgetId {
                    case WidgetId.article.rawValue:
                        cell.noDataView.noDataLabel.text = "No Knowledge data"
                    case WidgetId.announcement.rawValue:
                        cell.noDataView.noDataLabel.text = "No Announcement data"
                    default:
                        cell.noDataView.noDataLabel.text = "No Data"
                    }
                }
                tableViewCell.separatorInset = UIEdgeInsets(top: 0.0, left: view.bounds.size.width ?? 0, bottom: 0.0, right: 0.0)
                return tableViewCell
            }
        }
        
        guard let element = elements?[indexPath.row] else {
            return UITableViewCell(style: .value1, reuseIdentifier: widgetViewCellIdentifier)
        }
        setTemplateTypeOfElements(&templateType, &cellIdentifier, element, widget: widget)
        
        let tableViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        switch templateType {
        case .announcement:
            if let cell = tableViewCell as? KAAnnouncementsTableViewCell, let knowledgeItem = element as? KREKnowledgeItem {
                cell.loadedDataState()
                configureAnnouncementItemCell(cell, at: indexPath, knowledgeItem: knowledgeItem)
            }
        case .knowledge:
            if let cell = tableViewCell as? KAKnowledgeTableViewCell, let knowledgeItem = element as? KREKnowledgeItem {
                configureKnowledgeItemCell(cell, at: indexPath, knowledgeItem: knowledgeItem)
            }
        case .hashTag:
            if let cell = tableViewCell as? KRETrendingHashtagTableViewCell, let hashTagItem = element as? KREHashTag {
                cell.titleLabel.text = "#\(hashTagItem.name ?? "")"
                if let count = hashTagItem.count  {
                    cell.viewLabel.text =  count > 1 ? "\(count) Articles":"\(count) Article"
                }
            }
        case .button:
            let selectedFilters = widget?.filters?.filter { $0.isSelected == true }
            if let cell = tableViewCell as? KREButtonTemplateCell {
                cell.title = "View more"
            }
        default:
           break
        }
        
        tableViewCell.selectionStyle = .none
        tableViewCell.setNeedsUpdateConstraints()
        tableViewCell.updateConstraintsIfNeeded()
        tableViewCell.isHidden = false
        return tableViewCell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let element = elements?[indexPath.row] {
            delegate?.elementAction(for: element, in: widget, in: nil)
        }
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: widgetHeaderViewIdentifier)

        if let headerFooterView = headerView as? KREWidgetHeaderFooterView, let widget = widget {
            if widget.widgetId == WidgetId.article.rawValue || widget.widgetId == WidgetId.announcement.rawValue {
                headerFooterView.bubbleView.moveButton.isHidden = false
            } else {
                headerFooterView.bubbleView.moveButton.isHidden = true
            }
            
            headerFooterView.bubbleView.widget = widget
            headerFooterView.bubbleView.addActionHandler = { [weak self] in
                if widget.widgetId == WidgetId.article.rawValue {
                    self?.delegate?.addWidgetElement(in: widget, completion: { (status) in
                        
                    })
                } else if widget.widgetId == WidgetId.announcement.rawValue {
                    self?.delegate?.addWidgetElement(in: widget, completion: { (status) in
                        
                    })
                }
            }
            headerFooterView.bubbleView.didSelectComponentAtIndex = { [weak self] (index) in
                self?.pagination = false
                tableView.reloadData()
            }
        }
        return headerView
    }
    
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: widgetFooterViewIdentifier)
        footerView?.backgroundView?.backgroundColor = .clear
        return UIView(frame: .zero)
    }
    
    // MARK: - UITableViewDelegateSource
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 84.0
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0
    }

    public func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 44.0
    }
}

// MARK: - KREWidgetViewDataSource
extension KREKnowledgeWidgetViewController: KREWidgetViewDataSource {
    public func willUpdateWidget(_ widget: KREWidget) {
        
    }
    
    public func didUpdateWidget(_ widget: KREWidget) {
        DispatchQueue.main.async {
            self.reloadWidget(widget)
        }
    }
}

// MARK: -
extension KREKnowledgeWidgetViewController {
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
        if let comments = knowledgeItem.nComments {
            informationViewCell.kaCommentLabel.text = " \(comments)"
        }
        if let upVotes = knowledgeItem.nUpVotes {
            informationViewCell.kaLikeLabel.text = "\(upVotes)"
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

extension KREKnowledgeWidgetViewController {
    // MARK: scrollView delegate
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isScrolling = true
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollViewDidFinishScrolling(scrollView)
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            scrollViewDidFinishScrolling(scrollView)
        }
    }
    
    func scrollViewDidFinishScrolling(_ scrollView: UIScrollView) {
        let contentHeight = scrollView.contentOffset.y + scrollView.frame.size.height
        if isScrolling && !requestInProgress && needLoadMore && contentHeight >= scrollView.contentSize.height {
            requestInProgress = true
            if let widget = widget {
                let selectedFilters = widget.filters?.filter { $0.isSelected == true}
                if let hook = widget.hook {
                    if hasMore {
                        loadData()
                    } else {
                        self.requestInProgress = false
                    }
                } else if let widgetFilter = selectedFilters?.first, let component = widgetFilter.component {
                  if let hook = widgetFilter.hook, hasMore {
                    loadData()
                  } else {
                    self.requestInProgress = false
                    }
                }
            }
        }
        isScrolling = false
    }
    
    func loadData() {
        let driveManager = KREDriveListManager()
        let jsonDecoder = JSONDecoder()
        tableView.showLoadingFooter()
        print("Hooked data before\(self.hook?.params)")

        driveManager.paginationApiCall(hookParams: self.hook) { (success, object) in
            if !success {
                self.showErrorView()
                return
            }
            self.pagination = true
            if let elements = object["elements"] as? Array<[String: Any]>,
                let data = try? JSONSerialization.data(withJSONObject: elements, options: .prettyPrinted),
                let knowledgeItems = try? jsonDecoder.decode([KREKnowledgeItem].self, from: data) {
                if let widget = self.widget {
                    if widget.templateType == "announcement_list" {
                        knowledgeItems.forEach { (knowledgeItem) in
                            knowledgeItem.isAnnounement = true
                        }
                    }
                }
                if let hookDictionary = object["hook"] as? [String: Any], let hookData = try? JSONSerialization.data(withJSONObject: hookDictionary, options: .prettyPrinted),
                    let hook = try? jsonDecoder.decode(Hook.self, from: hookData) {
                    self.hook = hook
                }
                DispatchQueue.main.async { [weak self] in
                    self?.requestInProgress = false
                    self?.elements?.append(contentsOf:(knowledgeItems))
                    self?.tableView.reloadData()
                    self?.tableView.hideLoadingFooter()
                }
            }
            if let hasmore = object["hasMore"] as? Bool {
                self.hasMore = hasmore
            }
        }
    }
    
    private func showErrorView() {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 60))
        footerView.addSubview(errorView)
        let errorViews: [String: Any] = ["errorView": errorView]
        footerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[errorView]|", options:[], metrics: nil, views: errorViews))
        footerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[errorView]|", options:[], metrics: nil, views: errorViews))
        
        var error = NSLocalizedString("Oops! Something went wrong. Please try again after a while.", comment: "Oops! Something went wrong. Please try again after a while.")
        errorView.setTitle(error, for: .normal)
        errorView.addTarget(self, action: #selector(retryAction(_:)), for: .touchUpInside)
        self.tableView.tableFooterView = footerView
    }
    
    @objc func retryAction(_ sender: UIButton) {
        loadData()
        self.tableView.tableFooterView = UIView(frame: .zero)
    }
}
