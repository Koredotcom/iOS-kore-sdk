//
//  KRESummaryWidgetView.swift
//  KoreBotSDK
//
//  Created by Srinivas Vasadi on 2/01/2020.
//  Copyright © 2019 Srinivas Vasadi. All rights reserved.
//

import UIKit

// MARK: - KREWidgetViewDelegate
public protocol KREGenericWidgetViewDelegate: class {
    func addWidgetElement(in widget: KREWidget, completion block:((Bool) -> Void)?)
    func didLoadWidgetView(with widget: KREWidget, in panel: KREPanelItem?)
    func didSelectElement(_ component: Decodable, in widget: KREWidget?, in panel: KREPanelItem?)
    func elementAction(for component: Decodable, in widget: KREWidget?, in panel: KREPanelItem?)
    func viewMoreElements(for component: KREWidgetComponent?, in widget: KREWidget?, in panel: KREPanelItem?)
    func editButtonAction(in panel: KREPanelItem?)
    func populateActions(_ actions: [KREAction]?, in widget: KREWidget?, in panel: KREPanelItem?)
    func addSnackBar(text: String)
}

public class KRESummaryWidgetView: UIView {
    // MARK: - properties
    private let MAX_ELEMENTS = 1
    let bundle = Bundle(for: KRESummaryWidgetView.self)
    public var panelId: String? {
        didSet {
            panelItem = widgetManager.getPanelItem(with: panelId)
        }
    }
    private var panelItem: KREPanelItem? {
        didSet {
            shouldInvalidateLayout = false
            getWidgets()
            reloadWidgetView()
        }
    }
    lazy var collectionViewLayout: KREWidgetCollectionViewLayout = {
        let layout = KREWidgetCollectionViewLayout()
        layout.delegate = self
        return layout
    }()
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: collectionViewLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()
    public var shouldInvalidateLayout = false
    public weak var delegate: KREGenericWidgetViewDelegate?
    public var didLayoutSubviewsForTheFirstTime: Bool = true
    let widgetManager = KREWidgetManager.shared

    var isScrolling: Bool = false
    
    // MARK: - init
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    // MARK: - setup
    func setup() {
        collectionView.register(KRESummaryWidgetViewCell.self, forCellWithReuseIdentifier: "KRESummaryWidgetViewCell")
        collectionView.register(KREUtterancesListWidgetViewCell.self, forCellWithReuseIdentifier: "KREUtterancesListWidgetViewCell")
        collectionView.register(KRECalendarWidgetViewCell.self, forCellWithReuseIdentifier: "KRECalendarWidgetViewCell")
        collectionView.register(KREMeetingNotesWidgetViewCell.self, forCellWithReuseIdentifier: "KREMeetingNotesWidgetViewCell")
        collectionView.register(KREDriveWidgetViewCell.self, forCellWithReuseIdentifier: "KREDriveWidgetViewCell")
        collectionView.register(KREStandardWidgetViewCell.self, forCellWithReuseIdentifier: "KREStandardWidgetViewCell")
        collectionView.register(KREChartListWidgetViewCell.self, forCellWithReuseIdentifier: "KREChartListWidgetViewCell")
        collectionView.register(KREChartWidgetViewCell.self, forCellWithReuseIdentifier: "KREChartWidgetViewCell")
        collectionView.register(KREListWidgetViewCell.self, forCellWithReuseIdentifier: "KREListWidgetViewCell")
        collectionView.register(KRETaskWidgetViewCell.self, forCellWithReuseIdentifier: "KRETaskWidgetViewCell")
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "KREWidgetViewCell")
        collectionView.register(KREActivityWidgetViewCell.self, forCellWithReuseIdentifier: "KREActivityWidgetViewCell")
        collectionView.register(KREKnowledgeWidgetViewCell.self, forCellWithReuseIdentifier: "KREKnowledgeWidgetViewCell")
        addSubview(collectionView)

        let views: [String: UIView] = ["collectionView": collectionView]
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[collectionView]|", options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[collectionView]|", options: [], metrics: nil, views: views))
        
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    // MARK: -
    func getWidgets(forceReload: Bool = false) {
        KREWidgetManager.shared.getWidgets(in: panelItem, forceReload: forceReload, update: { [weak self] (success, widget) in
            self?.reloadWidget(widget)
        }) { (success) in
            
        }
    }
    
    func setAllPins(widget: KREWidget, unPinFlag: Bool) {
        guard let panels = KREWidgetManager.shared.panelItems else {
            return
        }
        if var panelItem = panels.filter({$0.id == "home" }).first {
            if unPinFlag {
//                panelItem.widgets?.append(widget)
            } else if let index = panelItem.widgets?.index(where: { $0._id == widget._id }) {
                panelItem.widgets?.remove(at: index)
            }
        }
    }
    
    func reloadWidgetView() {
        collectionView.reloadData()
    }
    
    func invalidateWidgetView() {
        if shouldInvalidateLayout {
            collectionView.collectionViewLayout.invalidateLayout()
            shouldInvalidateLayout = false
        }
    }
    
    func reloadWidget(_ widget: KREWidget) {
        switch widget.widgetState {
        case .loaded:
            reloadWidgetView()
            delegate?.didLoadWidgetView(with: widget, in: panelItem)
        case .refreshed, .refreshing:
            reloadWidgetView()
        default:
            reloadWidgetView()
        }
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension KRESummaryWidgetView: UICollectionViewDataSource, UICollectionViewDelegate {
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard let widgets = panelItem?.widgets else {
            return MAX_ELEMENTS
        }
        return widgets.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let widgets = panelItem?.widgets else {
            return MAX_ELEMENTS
        }

        let widget = widgets[section]
        switch widget.templateType {
        case "SystemHealth":
            return 0
        default:
            return 1
        }
        
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let widgets = panelItem?.widgets, indexPath.section < widgets.count else {
            let cellIdentifier = "KREWidgetViewCell"
            return collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath)
        }

        let widget = widgets[indexPath.section]
        switch widget.templateType {
        case "calendar_events":
            let cellIdentifier = "KRECalendarWidgetViewCell"
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath)
            if let cell = cell as? KRECalendarWidgetViewCell {
                cell.widget = widget
                cell.calendarWidgetView.widgetViewType = widgets.count > 1 ? .trim : .full
                cell.widgetView.delegate = self
                cell.widgetView.populateBubbleView()
            }
            cell.layoutSubviews()
            return cell
        case "meeting_notes":
            let cellIdentifier = "KREMeetingNotesWidgetViewCell"
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath)
            if let cell = cell as? KREMeetingNotesWidgetViewCell {
                cell.widget = widget
                cell.meetingNotesWidgetView.widgetViewType = widgets.count > 1 ? .trim : .full
                cell.widgetView.delegate = self
                cell.widgetView.populateBubbleView()
            }
            cell.layoutSubviews()
            return cell
        case "standard", "custom_style":
            let cellIdentifier = "KREStandardWidgetViewCell"
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath)
            if let cell = cell as? KREStandardWidgetViewCell {
                cell.widget = widget
                cell.widgetView.delegate = self
                cell.widgetView.populateBubbleView()
            }
            cell.layoutSubviews()
            return cell
        case "piechart", "linechart", "barchart":
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "KREChartWidgetViewCell", for: indexPath)
            if let cell = cell as? KREChartWidgetViewCell {
                cell.widget = widget
                cell.widgetView.delegate = self
                cell.widgetView.populateBubbleView()
            }
            cell.layoutSubviews()
            return cell
        case "chartList":
            let cellIdentifier = "KREChartListWidgetViewCell"
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath)
            if let cell = cell as? KREChartListWidgetViewCell {
                cell.widget = widget
                cell.widgetView.delegate = self
                cell.widgetView.populateBubbleView()
            }
            cell.layoutSubviews()
            return cell
        case "summaryCard":
            let cellIdentifier = "KRESummaryWidgetViewCell"
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath)
            if let summaryCell = cell as? KRESummaryWidgetViewCell {
                summaryCell.widget = widget
                summaryCell.actionHandler = { [weak self] (action) in
                    self?.delegate?.elementAction(for: action, in: widget, in: self?.panelItem)
                }
            }
            cell.layoutSubviews()
            return cell
        case "weatherGreeting":
            let cellIdentifier = "KRESummaryWidgetViewCell"
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath)
            if let summaryCell = cell as? KRESummaryWidgetViewCell {
                summaryCell.widget = widget
                summaryCell.actionHandler = { [weak self] (action) in
                    self?.delegate?.elementAction(for: action, in: widget, in: self?.panelItem)
                }
            }
            cell.layoutSubviews()
            return cell
        case "List":
            let cellIdentifier = "KREListWidgetViewCell"
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath)
            if let cell = cell as? KREListWidgetViewCell {
                cell.widget = widget
                cell.widgetView.delegate = self
                cell.widgetView.populateBubbleView()
                cell.listWidgetView.updateSubviews = { [weak self] in
                    self?.shouldInvalidateLayout = true
                    self?.invalidateWidgetView()
                }
            }
            cell.layoutSubviews()
            return cell
        case "announcement_list":
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "KREKnowledgeWidgetViewCell", for: indexPath)
            if let cell = cell as? KREKnowledgeWidgetViewCell {
                cell.widget = widget
                cell.knowledgeWidgetView.widgetViewType = widgets.count > 1 ? .trim : .full
                cell.widgetView.delegate = self
                cell.widgetView.populateBubbleView()
                cell.widgetView.updateSubviews = { [weak self] in
                    self?.invalidateWidgetView()
                }
            }
            cell.layoutSubviews()
            return cell
        default:
            let cellIdentifier = "KREWidgetViewCell"
            return collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath)
        }
    }
}

// MARK: - KREWidgetCollectionViewLayoutDelegate
extension KRESummaryWidgetView: KREWidgetCollectionViewLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, numberOfColumnsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, estimatedHeightForItemAt indexPath: IndexPath) -> CGFloat {
        return 200.0
    }
}

// MARK: - KREWidgetViewDelegate methods
extension KRESummaryWidgetView: KREWidgetViewDelegate {
    public func addSnackBar(text: String) {
        delegate?.addSnackBar(text: text)
    }
    
    public func addWidgetElement(in widget: KREWidget) {
        delegate?.addWidgetElement(in: widget, completion:{ [weak self] (status) in
            self?.getWidgets(forceReload: status)
        })
    }
    
    public func didLoadWidgetView(with widget: KREWidget) {
        delegate?.didLoadWidgetView(with: widget, in: panelItem)
    }
    
    public func didSelectElement(_ component: Decodable, in widget: KREWidget?) {
        delegate?.didSelectElement(component, in: widget, in: panelItem)
    }
    
    public func elementAction(for component: Decodable, in widget: KREWidget?) {
        delegate?.elementAction(for: component, in: widget, in: panelItem)
    }
    
    public func viewMoreElements(for component: KREWidgetComponent?, in widget: KREWidget?) {
        delegate?.viewMoreElements(for: component, in: widget, in: panelItem)
    }
        
    public func populateActions(_ actions: [KREAction]?, in widget: KREWidget?) {
        delegate?.populateActions(actions, in: widget, in: panelItem)
    }
    
    public func pinOrUnpinAction(for widget: KREWidget?, completion block:((Bool, KREWidget?) -> Void)?) {
        guard let widget = widget else {
            return
        }

        let widgetManager = KREWidgetManager.shared
        var params = [String: Any]()
        if widget.pinned == true {
            params["unpinWidget"] = ["id": widget._id, "panelId": panelItem?.id]
        } else {
            params["pinWidget"] = ["id": widget._id, "panelId": panelItem?.id]
        }
        widgetManager.setPinUnPinApi(parameters: params) { [weak self] (success, response) in
            if success {
                self?.getWidgets()
                if widget.pinned == true {
                    widget.pinned = false
                    self?.setAllPins(widget: widget, unPinFlag: false)
                } else {
                    widget.pinned = true
                    self?.setAllPins(widget: widget, unPinFlag: true)
                }
            }
            DispatchQueue.main.async {
                block?(success, widget)
            }
        }
    }
}

// MARK: - UIScrollViewDelegate methods
extension KRESummaryWidgetView {
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
        guard isScrolling, contentHeight >= scrollView.contentSize.height,
            let widgets = panelItem?.widgets else {
                return
        }

        let visibleCells = collectionView.visibleCells
        let widgetViewType: KREWidgetViewType = widgets.count > 1 ? .trim : .full
        guard widgetViewType == .full,
            let widget = widgets.first as? KREWidget else {
                return
        }

        switch widget.type {
        case "List":
            switch widget.templateType {
            case "announcement_list":
                guard let cell = collectionView.visibleCells.first as? KREKnowledgeWidgetViewCell else {
                    return
                }

                let widgetView = cell.knowledgeWidgetView
                widgetView.tableView.tableFooterView?.isHidden = false
                widgetView.showLoadingIndicatorOnTableView()
                widgetView.paginateWidget { [weak self] (success) in
                    CATransaction.begin()
                    CATransaction.setCompletionBlock {
                        widgetView.tableView.tableFooterView?.isHidden = true
                    }
                    widgetView.tableView.reloadData()
                    CATransaction.commit()
                    if !success {
                        return
                    }
                }
            default:
                break
            }
        case "FilteredList":
            switch widget.templateType {
            case "file_list":
                break
            case "knowledge_list":
                guard let cell = collectionView.visibleCells.first as? KREKnowledgeWidgetViewCell else {
                    return
                }
                
                let widgetView = cell.knowledgeWidgetView
                widgetView.tableView.tableFooterView?.isHidden = false
                widgetView.showLoadingIndicatorOnTableView()
                widgetView.paginateWidget { [weak self] (success) in
                    CATransaction.begin()
                    CATransaction.setCompletionBlock {
                        widgetView.tableView.tableFooterView?.isHidden = true
                    }

                    if let filters = widgetView.widget?.filters?.filter ({ $0.isSelected == true }) {
                        if let filter = filters.first {
                            if let widgetComponent = filter.component, widgetComponent.hasMore == false {
                                widgetView.tableView.tableFooterView?.isHidden = true
                                widgetView.tableView.tableFooterView = nil
                            }
                        }
                    }
                    widgetView.tableView.reloadData()
                    CATransaction.commit()
                    if !success {
                        return
                    }
                }
            default:
                break
            }
        default:
            break
        }

        isScrolling = false
    }
}

