//
//  KRETaskListViewController.swift
//  KoreBotSDK
//
//  Created by Sukhmeet Singh on 19/03/19.
//

import UIKit
import Foundation
import KoreBotSDK

public class KRETaskListViewController: UIViewController {
    let bundle = Bundle(for: KRETaskListViewController.self)
    var buttonCollectionViewHeight: CGFloat = 60.0
    public var widgetComponent: KREWidgetComponent?
    public var widget: KREWidget?
    lazy var titleStrikeThroughAttributes: [NSAttributedString.Key: Any] = {
        return [.font: UIFont.textFont(ofSize: 14.0, weight: .bold), .foregroundColor: UIColor.blueyGrey]
    }()
    
    lazy var taskTitleAttributes: [NSAttributedString.Key: Any] = {
        return [.font: UIFont.textFont(ofSize: 14.0, weight: .bold), .foregroundColor: UIColor.gunmetal]
    }()
    var isScrolling: Bool = false
    var needLoadMore: Bool = true
    var requestInProgress: Bool = false
    let fetchLimit: Int = 10
    var itemsSelectionHandler:((Int) -> Void)?
    var uttrenceViewHeightConstraint: NSLayoutConstraint!
    var showButton = true
    let taskPreviewCellIdentifier = "KRETaskPreviewCell"
    var urlString: String?
    public var objects: Array<Any> = Array<Any>() {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    lazy var utterancesView: KREActionCollectionView = {
        let utteranceCollectionView = KREActionCollectionView(frame: .zero)
        utteranceCollectionView.translatesAutoresizingMaskIntoConstraints = false
        utteranceCollectionView.widget = widget
        return utteranceCollectionView
    }()

    
    lazy private var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.separatorColor = UIColor.lightGreyBlue
        tableView.backgroundColor = .white
//        tableView.bounces = false
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.singleLine
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        tableView.separatorColor = UIColor.lightGreyBlue
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setup()
        setupNavigationItems()
        tableView.register(KRETaskPreviewCell.self, forCellReuseIdentifier: taskPreviewCellIdentifier)
        self.objects = self.widgetComponent?.elements ?? []
        let driveManager = KREDriveListManager()
        let parameters = ["offSet": "\(self.objects.count ?? 0)", "limit": NSNumber(value: 10)] as [String : Any]
        if let urlString = urlString {
            driveManager.getDrive(urlString: urlString ?? "", parameters: parameters, with: { [weak self] (status, elements) in
                if let weakSelf = self, let componentElements = elements as? [Decodable] {
                    DispatchQueue.main.async {
                        weakSelf.objects.append(contentsOf: componentElements)
                    }
                }
            })
        }

        self.itemsSelectionHandler = { [weak self] (count) in
            let selectdTaskListItems = self?.objects.filter { ($0 as! KRETaskListItem).isSelected == true }
        
            if selectdTaskListItems?.count ?? 0 > 0 {
                let count = selectdTaskListItems?.count ?? 0
                let title = "\(count) \(count == 1 ? "task" : "tasks") selected"
                self?.addTitleAsNavigationBtn(title: title)
            } else {
                self?.closeSelectionAction()
            }
        }
    }
    
    func getTasks() {
        self.tableView.showLoadingFooter()
        if let hasMore = widgetComponent?.hasMore, hasMore == true {
            let driveManager = KREDriveListManager()
            guard let filters = widget?.filters?.filter ({ $0.isSelected == true }),
                let filter = filters.first else {
                    requestInProgress = false
                    return
            }
            
            guard let widgetComponent = filter.component, widgetComponent.hasMore == true else {
                requestInProgress = false
                return
            }

            driveManager.paginationApiCall(hookParams: filter.hook) { [weak self] (success, responseObject) in
                self?.requestInProgress = false
                guard success, let dictionary = responseObject as? [String: Any] else {
                    return
                }
                
                let manager = KREWidgetManager.shared
                manager.insertOrUpdateWidgetComponent(for: filter, in: self?.widget, pagination: true, with: dictionary)
                
                // update elements
                let filters = self?.widget?.filters?.filter { $0.isSelected == true }
                if let widgetComponent = filters?.first?.component {
                    self?.widgetComponent = widgetComponent
                }
                self?.objects = self?.widgetComponent?.elements ?? []
                self?.requestInProgress = false
                self?.tableView.hideLoadingFooter()
                
            }
       }
    }
    
    func setupNavigationItems() {
        let image = UIImage(named: "backIcon", in: bundle, compatibleWith: nil)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(closeButtonAction))
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.gunmetal
        self.navigationController?.navigationBar.barTintColor = UIColor.white
    }
    
    @objc func closeButtonAction() {
        if isModal {
            dismiss(animated: true, completion: nil)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    func setup() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(KREDocumentInformationCell.self, forCellReuseIdentifier: "KREDocumentInformationCell")
        self.view.addSubview(tableView)
        self.view.addSubview(utterancesView)
        let views: [String: UIView] = ["tableView": tableView, "utterancesView": utterancesView]
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[tableView]-[utterancesView]", options: [], metrics: nil, views: views))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[tableView]|", options: [], metrics: nil, views: views))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[utterancesView]|", options: [], metrics: nil, views: views))
        let longPressGesture: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture))
        longPressGesture.cancelsTouchesInView = false
        longPressGesture.minimumPressDuration = 0.5
        tableView.addGestureRecognizer(longPressGesture)
        self.utterancesView.isHidden = true
        uttrenceViewHeightConstraint = NSLayoutConstraint(item: utterancesView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 0.0)
        view.addConstraint(uttrenceViewHeightConstraint)
        uttrenceViewHeightConstraint.isActive = true
        utterancesView.backgroundColor = .white
        if let multiActions = widgetComponent?.multiActions {
            utterancesView.actions = multiActions
        }
        
        utterancesView.widget = widget
        let multiActions = widgetComponent?.multiActions
        utterancesView.utteranceClickAction = { [weak self] (action) in
            var params: [String: Any] =  [String: Any]()
            if let utterance = action?.utterance {
                params["utterance"] = utterance
            }
            if let taskListItems = self?.objects as? [KRETaskListItem] {
                let taskIds = taskListItems.filter { $0.isSelected == true }.map { $0.taskId ?? ""}
                params["options"] = ["params": ["ids": taskIds]] as? [String: Any]
            }
            self?.resetNavigationItem()
            self?.dismiss(animated: true, completion: {
                NotificationCenter.default.post(name: KREMessageAction.utteranceHandler.notification, object: params)
            })
        }
        
        if #available(iOS 11, *) {
            let guide = view.safeAreaLayoutGuide
            utterancesView.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: 0.0).isActive = true
        } else {
            let standardSpacing: CGFloat = 0.0
            utterancesView.bottomAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: standardSpacing).isActive = true
        }
    }
    
    @objc func handleLongPressGesture(_ longPressGesture: UILongPressGestureRecognizer) {
        let point = longPressGesture.location(in: tableView)
        guard let indexPath = tableView.indexPathForRow(at: point) else {
            return
        }
        self.setupNavigationBarForTask()
        
        var taskItem = objects[indexPath.row] as? KRETaskListItem
        
        UIView.transition(with: self.utterancesView, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.uttrenceViewHeightConstraint.constant = self.buttonCollectionViewHeight
            self.utterancesView.isHidden = false
        })
        
        if (longPressGesture.state == UIGestureRecognizer.State.began) {
            if let status = taskItem?.status {
                switch status.lowercased() {
                case "close":
                    return
                default:
                    if var isSelected = taskItem?.isSelected {
                        taskItem?.isSelected = !isSelected
                    }
                    showButton = false
                    self.objects[indexPath.row] = taskItem
                    if let indexPathsForVisibleRows = tableView.indexPathsForVisibleRows {
                        UIView.performWithoutAnimation {
                            let sectionIndexes = IndexSet([0, 0])
                            tableView.beginUpdates()
                            tableView.reloadSections(sectionIndexes, with: .fade)
                            tableView.endUpdates()
                        }
                    }
//                    longTapHandler?(true)
                    let selectdTaskListItems = objects.filter { ($0 as! KRETaskListItem).isSelected == true }
                    itemsSelectionHandler?(selectdTaskListItems.count ?? 0)
                }
            }
        }
    }

    func setupNavigationBarForTask() {
        self.navigationController?.navigationBar.barTintColor = .red
        navigationItem.rightBarButtonItems = nil
        navigationItem.leftBarButtonItem?.tintColor = .white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont.textFont(ofSize: 17.0, weight: .semibold)]
    }
    
    func addTitleAsNavigationBtn(title: String) {
        let titleButton = UIButton(frame: CGRect(x: 0, y: 0, width: self.view.frame.width - 60, height: 44))
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.width - 60, height: 44))
        label.textColor = UIColor.white
        label.text = title//KALocalized("1 task selected")
        label.font = UIFont.textFont(ofSize: 17.0, weight: UIFont.Weight.bold)
        label.textAlignment = NSTextAlignment.left
        titleButton.addSubview(label)
        let closeButtonImage: UIImage = UIImage(named: "close_gray_icon")!
        // Add it to your left bar button
        navigationItem.leftBarButtonItems = [UIBarButtonItem(customView: titleButton)]
        let leftItem = UIBarButtonItem(image: closeButtonImage, style: .plain, target: self, action: #selector(closeSelectionAction))
        leftItem.tintColor = .white
        // titleBarButton.setTitleTextAttributes(attrs, for: .normal)
        navigationItem.leftBarButtonItems = [leftItem, UIBarButtonItem(customView: titleButton)]
    }
    
    func resetNavigationItem() {
        UIView.transition(with: self.utterancesView, duration: 0.5, options: .transitionCrossDissolve, animations:{
            self.uttrenceViewHeightConstraint.constant = 0.0
            self.utterancesView.isHidden = true
        })
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: UIFont.textFont(ofSize: 17.0, weight: .semibold)]
        let image = UIImage(named: "backIcon", in: bundle, compatibleWith: nil)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(closeButtonAction))
        navigationItem.leftBarButtonItem?.tintColor = .white
        navigationItem.leftBarButtonItem?.tintColor = UIColor.gunmetal
        self.navigationController?.navigationBar.barTintColor = .white
        showButton = true
        if let indexPathsForVisibleRows = tableView.indexPathsForVisibleRows {
            UIView.performWithoutAnimation {
                let sectionIndexes = IndexSet([0, 0])
                tableView.beginUpdates()
                tableView.reloadSections(sectionIndexes, with: .fade)
                tableView.endUpdates()
            }
        }
        for index in 0 ..< objects.count {
            if var taskItem = objects[index] as? KRETaskListItem {
                taskItem.isSelected = false
                objects[index] = taskItem
            }
        }
    }
    
    // MARK: scrollView delegate
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.isScrolling = true
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
    
    public func scrollViewDidFinishScrolling(_ scrollView: UIScrollView) {
        let contentHeight = scrollView.contentOffset.y + scrollView.frame.size.height
        if self.isScrolling && !self.requestInProgress && self.needLoadMore && contentHeight >= scrollView.contentSize.height {
            self.requestInProgress = true
            self.getTasks()
            //  fetchKnowledgeWithOffset(offset: self.fetchedResultsController?.fetchedObjects?.count)
        }
        
        self.isScrolling = false
    }
    
    

    
    @objc func closeSelectionAction() {
        resetNavigationItem()
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
extension KRETaskListViewController: UITableViewDataSource, UITableViewDelegate {
    // MARK: - table view data source
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.objects.count
    }
    
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: taskPreviewCellIdentifier, for: indexPath) as? KRETaskPreviewCell
        if let taskListItem = self.objects[indexPath.row]  as? KRETaskListItem {
            var utcDate: Date?
            cell?.selectionStyle = .none
            cell?.loadedDataState()
            cell?.moreSelectionHandler = { [weak self] (taskListItemCell) in
                guard let indexPath = self?.tableView.indexPath(for: taskListItemCell) else {
                    return
                }
                self?.widgetActionUi(component: self?.objects[indexPath.row])
            }

            if let dueDate = taskListItem.dueDate {
                cell?.dateTimeLabel.text = convertUTCToDate(dueDate)
                utcDate = Date(milliseconds: Int64(truncating: NSNumber(value: dueDate)))
            }
            cell?.itemSelectionHandler = { [weak self] (taskListItemcell) in
                guard let indexPath = self?.tableView.indexPath(for: taskListItemcell) else {
                    return
                }
                
                if var taskListItem = self?.objects[indexPath.row] as? KRETaskListItem {
                    taskListItem.isSelected = !taskListItem.isSelected
                    cell?.selectionView.isSelected = taskListItem.isSelected
                    if taskListItem.isSelected {
                        cell?.contentView.backgroundColor = UIColor(red: 252/255, green: 234/255, blue: 236/255, alpha: 1)
                    } else {
                        cell?.contentView.backgroundColor = UIColor.white
                    }
                    self?.objects[indexPath.row] = taskListItem
                    let selectdTaskListItems = self?.objects.filter { ($0 as! KRETaskListItem).isSelected == true }
                    self?.itemsSelectionHandler?(selectdTaskListItems?.count ?? 0)
                }
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
            if showButton {
                cell?.selectionViewWidthConstraint.constant = 0.0
                cell?.selectionViewLeadingConstraint.constant = 0.0
                cell?.moreButton.isHidden = false
            } else {
                cell?.selectionViewWidthConstraint.constant = 22.0
                cell?.moreButton.isHidden = true
            }
            cell?.selectionView.isHidden = showButton
            
            if let status = taskListItem.status, let taskTitle = taskListItem.title {
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
                        cell?.contentView.backgroundColor = UIColor.white
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
                        cell?.contentView.backgroundColor = UIColor.white
                    }
                }
            }
        }
        cell?.containerViewLeadingConstraint.constant = 16
        cell?.containerViewTrailingConstraint.constant = 16
        cell?.layoutSubviews()
        return cell ?? UITableViewCell()
    }
    
    // MARK: - table view delegate methods
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        return 
        if showButton {
            let widgetActionViewController = KREWidgetActionViewController()
            widgetActionViewController.modalPresentationStyle = .fullScreen
            widgetActionViewController.widget = widget
            widgetActionViewController.dismissParent = { [weak self] in
                self?.navigationController?.popViewController(animated: false)
            }
            widgetActionViewController.element = self.objects[indexPath.row]
            self.present(widgetActionViewController, animated: false, completion: nil)
            return
        }
        if var taskListItem = self.objects[indexPath.row] as? KRETaskListItem {
            if let status = taskListItem.status {
                switch status.lowercased() {
                case "close":
                    return
                default:
                    if let cell = tableView.cellForRow(at: indexPath) as? KRETaskPreviewCell {
                        cell.itemSelectionHandler?(cell)
                    }
                }
            }
        }
    }
    
    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    public func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        var cell = tableView.cellForRow(at: indexPath)
        cell?.contentView.backgroundColor = UIColor(red: 252/255, green: 234/255, blue: 236/255, alpha: 1)
    }
    
    public func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        var cell = tableView.cellForRow(at: indexPath)
        cell?.contentView.backgroundColor = UIColor.white
    }
    
    func widgetActionUi(component: Any) {
        var actions: [(String, UIAlertAction.Style)] = []
        var actionString = [String]()
        var title = ""
        var elementAction: [KREAction]?
        // Element Sepration
        if let _ = component as? KRECalendarEvent {
            return
        } else if let element = component as? KREDriveFileInfo {
            guard let urlAction = element.defaultAction?.url else {
                return
            }
            openDriveUrl(urlString: urlAction, fileType: element.fileType ?? "")
        } else if let element = component as? KRETaskListItem {
            elementAction = element.actions ?? []
            for button in element.actions ?? [] {
                actionString.append(button.title ?? "")
            }
            title = element.title ?? ""
        } else if let _ = component as? KREButtonTemplate {
        }
        else if let element = component as? KREKnowledgeItem {
        }
        //--
        for utterance in actionString ?? [] {
            actions.append((utterance, UIAlertAction.Style.default))
        }
        actions.append(("Cancel", UIAlertAction.Style.cancel))
        Alerts.showActionsheet(viewController: self, title: title, message: "", actions: actions) { [weak self] (index) in
            if index == actionString.count {
                debugPrint("Cancel")
            } else {
                var params: [String: Any] =  [String: Any]()
                if let elementAction = elementAction {
                    params["utterance"] = elementAction[index].utterance
                    params["options"] = [:]
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PanelPositionNotification"), object: "bottom")
                }
                self?.dismiss(animated: true, completion: {
                    NotificationCenter.default.post(name: KREMessageAction.utteranceHandler.notification, object: params)
                })
            }
        }
    }
    
    public func getDriveListData() {
        
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


extension UITableView {
    
    func showLoadingFooter(){
        let loadingFooter = UIActivityIndicatorView(style: .gray)
        loadingFooter.color = UIColor.lightRoyalBlue
        loadingFooter.frame.size.height = 50
        loadingFooter.hidesWhenStopped = true
        loadingFooter.startAnimating()
        tableFooterView = loadingFooter
    }
    
    func hideLoadingFooter(){
        let tableContentSufficentlyTall = (contentSize.height > frame.size.height)
        let atBottomOfTable = (contentOffset.y >= contentSize.height - frame.size.height)
        if atBottomOfTable && tableContentSufficentlyTall {
            UIView.animate(withDuration: 0.2, animations: {
                self.contentOffset.y = self.contentOffset.y - 50
            }, completion: { finished in
                self.tableFooterView = UIView()
            })
        } else {
            self.tableFooterView = UIView()
        }
    }
    
    func isLoadingFooterShowing() -> Bool {
        return tableFooterView is UIActivityIndicatorView
    }
    
}

class Alerts {
    static func showActionsheet(viewController: UIViewController, title: String, message: String, actions: [(String, UIAlertAction.Style)], completion: @escaping (_ index: Int) -> Void) {
        let alertViewController = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        for (index, (title, style)) in actions.enumerated() {
            let alertAction = UIAlertAction(title: title, style: style) { (_) in
                completion(index)
            }
            alertViewController.addAction(alertAction)
        }
        viewController.present(alertViewController, animated: true, completion: nil)
    }
}
