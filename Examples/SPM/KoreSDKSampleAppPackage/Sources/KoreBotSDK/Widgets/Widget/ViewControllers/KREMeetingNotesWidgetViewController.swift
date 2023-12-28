//
//  KREMeetingNotesWidgetViewController.swift
//  KoreBotSDK
//
//  Created by Srinivas Vasadi on 11/04/20.
//  Copyright © 2019 Srinivas Vasadi. All rights reserved.
//

import UIKit

public class KREMeetingNotesWidgetViewController: UIViewController {
    // MARK: -
    let bundle = Bundle(for: KREMeetingNotesWidgetViewController.self)
    var widgetManager = KREWidgetManager.shared
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
        tableView.showsVerticalScrollIndicator = false
        tableView.alwaysBounceHorizontal = false
        tableView.bounces = false
        tableView.tableFooterView = UIView(frame: .zero)
        return tableView
    }()
    var sections:[(key: Date, value: [KREMeetingNote])]?
    public var elements: [KREMeetingNote]? {
        didSet {
            sections = widgetManager.sortMeetingNotes(elements)
        }
    }
    
    public weak var delegate: KREGenericWidgetViewDelegate?
    public var panelItem: KREPanelItem?

    let noDataCellIdentifier = "KREWidgetNoDataTableViewCell"
    let widgetViewCellIdentifier = "KREWidgetViewCell"
    let meetingNotesCellIdentifier = "KREMeetingNotesViewCell"
    let buttonTemplateCellIdentifier = "KREButtonTemplateCellIdentifier"
    let tableViewHeaderFooterIdentifier = "KREWidgetHeaderFooterView"
    // MARK: -
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        tableView.register(KREMeetingNotesViewCell.self, forCellReuseIdentifier: meetingNotesCellIdentifier)
        tableView.register(KREButtonTemplateCell.self, forCellReuseIdentifier: buttonTemplateCellIdentifier)
        tableView.register(KREWidgetNoDataTableViewCell.self, forCellReuseIdentifier: noDataCellIdentifier)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: widgetViewCellIdentifier)
        self.tableView.register(KREWidgetHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: tableViewHeaderFooterIdentifier)
        view.addSubview(tableView)
        
        let views = ["tableView": tableView]
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[tableView]|", options: [], metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[tableView]|", options: [], metrics: nil, views: views))
        
        tableView.dataSource = self
        tableView.delegate = self

        setupNavigationBar()
    }
    
    // MARK: - KREWidgetView methods
    public var widget: KREWidget? {
        didSet {
            
        }
    }
    
    public var widgetComponent: KREWidgetComponent? {
        didSet {
            if let items = widgetComponent?.elements as? [KREMeetingNote] {
                elements = items
            } else {
                elements = nil
            }
            tableView.reloadData()

            if let hook = widget?.hook {
                self.hook = hook
            } else {
                let selectedFilters = widget?.filters?.filter { $0.isSelected == true}
                if let filter = widget?.filters?.first {
                    self.hook = filter.hook
                }
            }
            hasMore = widgetComponent?.hasMore ?? false
        }
    }
        
    // MARK: -
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
    
    // MARK: -
    func setupNavigationBar() {
        let image = UIImage(named: "backIcon", in: bundle, compatibleWith: nil)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(closeButtonAction))
        navigationItem.leftBarButtonItem?.tintColor = UIColor.gunmetal
        navigationController?.navigationBar.barTintColor = UIColor.white
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = false
    }

    @objc func closeButtonAction() {
        if isModal {
            dismiss(animated: true, completion: nil)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    // MARK:- deinit
    deinit {
        
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension KREMeetingNotesWidgetViewController: UITableViewDelegate, UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        if let allDates = sections {
            return allDates.count
        }
        else {
            return 1
        }
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let _ = widgetComponent else {
            return 0
        }
        var count = 0
        if let allDates = sections {
            count = allDates[section].value.count ?? 0
        }
        else {
            count = elements?.count ?? 0
        }
        return count > 0 ? count : 1
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
            return widgetViewCell(for: indexPath)
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: noDataCellIdentifier, for: indexPath)
            if let cell = cell as? KREWidgetNoDataTableViewCell, let elementsCount = elements?.count, elementsCount == 0 {
                cell.noDataView.noDataLabel.text = NSLocalizedString("No Data", comment: "No Data")
                cell.separatorInset = UIEdgeInsets(top: 0.0, left: view.bounds.size.width ?? 0, bottom: 0.0, right: 0.0)
            }
            return cell
        }
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let sectionData = sections?[indexPath.section] {
            if indexPath.row < sectionData.value.count {
                let calender = sectionData.value[indexPath.row]
                delegate?.elementAction(for: calender, in: widget, in: panelItem)
            }
        }
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: tableViewHeaderFooterIdentifier)
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

    
    // MARK: - UITableViewDelegateSource
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 84.0
    }
}

// MARK: - meeting notes population
extension KREMeetingNotesWidgetViewController {
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
}

// MARK: UIScrollViewDelegate methods
extension KREMeetingNotesWidgetViewController {
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
                let meetingNoteElements = try? jsonDecoder.decode([KREMeetingNote].self, from: data) {
                if let hookDictionary = object["hook"] as? [String: Any], let hookData = try? JSONSerialization.data(withJSONObject: hookDictionary, options: .prettyPrinted),
                    let hook = try? jsonDecoder.decode(Hook.self, from: hookData) {
                    self.hook = hook
                }
                DispatchQueue.main.async { [weak self] in
                    self?.requestInProgress = false
                    var tempArray = [KREMeetingNote]()
                    if let ele = self?.elements {
                        tempArray.append(contentsOf: ele)
                    }
                    tempArray.append(contentsOf: meetingNoteElements)
                    self?.elements = tempArray
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
