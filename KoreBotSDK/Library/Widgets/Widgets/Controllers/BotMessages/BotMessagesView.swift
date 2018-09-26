//
//  BotMessagesView.swift
//  KoreBotSDKDemo
//
//  Created by Anoop Dhiman on 31/07/17.
//  Copyright © 2017 Kore. All rights reserved.
//

import UIKit
import CoreData

protocol BotMessagesViewDelegate {
    func optionsButtonTapAction(text:String)
    func linkButtonTapAction(urlString:String)
    func populateQuickReplyCards(with message: KREMessage?)
    func populatePickerView(with message: KREMessage?)
    func populateSessionEndView(with message: KREMessage?)
    func populateBottomTableView(with message: KREMessage?)
    func startWaitTimerTasks()
    func stopWaitTimerTasks()
    func setComposeBarHidden(_ isHidden: Bool)
    func closeQuickReplyCards()
}

open class BotMessagesView: UIView, UITableViewDelegate, UITableViewDataSource, KREFetchedResultsControllerDelegate {
    var tableView: UITableView
    var fetchedResultsController: KREFetchedResultsController?
    var viewDelegate: BotMessagesViewDelegate?
    var shouldScrollToBottom: Bool = true
    var clearBackground = false
    var userActive = false
    var agentTransferMode = false

    weak var thread: KREThread! {
        didSet {
            self.initializeFetchedResultsController()
        }
    }
    
    convenience init(){
        self.init(frame: CGRect.zero)
    }
    
    override init(frame: CGRect) {
        self.tableView = UITableView(frame: frame, style: .grouped)
        super.init(frame: frame)
        self.setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        self.tableView = UITableView(frame: CGRect.zero, style: .grouped)
        super.init(coder: aDecoder)
        self.setup()
    }
    
    func setup() {
        self.tableView.backgroundColor = UIColor.clear
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.separatorStyle = .none
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.addSubview(self.tableView)
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[tableView]|", options:[], metrics:nil, views:["tableView" : self.tableView]))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[tableView]|", options:[], metrics:nil, views:["tableView" : self.tableView]))
        
        //Register reusable cells
        self.tableView.register(MessageBubbleCell.self, forCellReuseIdentifier:"MessageBubbleCell")
        self.tableView.register(TextBubbleCell.self, forCellReuseIdentifier:"TextBubbleCell")
        self.tableView.register(ImageBubbleCell.self, forCellReuseIdentifier:"ImageBubbleCell")
        self.tableView.register(OptionsBubbleCell.self, forCellReuseIdentifier:"OptionsBubbleCell")
        self.tableView.register(ListBubbleCell.self, forCellReuseIdentifier:"ListBubbleCell")
        self.tableView.register(QuickReplyBubbleCell.self, forCellReuseIdentifier:"QuickReplyBubbleCell")
        self.tableView.register(CarouselBubbleCell.self, forCellReuseIdentifier:"CarouselBubbleCell")
        self.tableView.register(ErrorBubbleCell.self, forCellReuseIdentifier:"ErrorBubbleCell")
        self.tableView.register(PiechartBubbleCell.self, forCellReuseIdentifier:"PiechartBubbleCell")
        self.tableView.register(TableBubbleCell.self, forCellReuseIdentifier:"TableBubbleCell")
        self.tableView.register(MiniTableBubbleCell.self, forCellReuseIdentifier:"MiniTableBubbleCell")
        self.tableView.register(ResponsiveTableBubbleCell.self, forCellReuseIdentifier:"ResponsiveTableBubbleCell")
        self.tableView.register(MenuBubbleCell.self, forCellReuseIdentifier:"MenuBubbleCell")
        self.tableView.register(PickerBubbleCell.self, forCellReuseIdentifier:"PickerBubbleCell")
        self.tableView.register(SessionEndBubbleCell.self, forCellReuseIdentifier:"SessionEndBubbleCell")
        self.tableView.register(ShowProgressBubbleCell.self, forCellReuseIdentifier:"ShowProgressBubbleCell")
        self.tableView.register(MessageTimeLineCell.self, forCellReuseIdentifier: "MessageTimeLineCell")
        self.tableView.register(AgentTransferModeBubbleCell.self, forCellReuseIdentifier: "AgentTransferModeBubbleCell")
        self.tableView.register(TimerTaskBubbleCell.self, forCellReuseIdentifier: "TimerTaskBubbleCell")
        self.tableView.register(BotMessagesHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "BotMessagesHeaderFooterView")
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
    }
    
    //MARK:- removing refernces to elements
    func prepareForDeinit() {
        self.fetchedResultsController?.kreDelegate = nil
        self.fetchedResultsController?.tableView = nil
    }
    
    func initializeFetchedResultsController() {
        if(self.thread != nil){
            let request: NSFetchRequest<KREMessage> = KREMessage.fetchRequest()
            request.predicate = NSPredicate(format: "thread.threadId == %@", self.thread.threadId!)
            let sortSection = NSSortDescriptor(key: "sortDay", ascending: true)
            let sortDates = NSSortDescriptor(key: "sentOn", ascending: true)
            request.sortDescriptors = [sortSection, sortDates]
            
            let mainContext: NSManagedObjectContext = DataStoreManager.sharedManager.coreDataManager.mainContext
            fetchedResultsController = KREFetchedResultsController(fetchRequest: request as! NSFetchRequest<NSManagedObject>, managedObjectContext: mainContext, sectionNameKeyPath: "sortDay", cacheName: nil)
            fetchedResultsController?.tableView = self.tableView
            fetchedResultsController?.kreDelegate = self
            do {
                try fetchedResultsController?.performFetch()
                scrollToBottom(animated: true)
            } catch {
                fatalError("Failed to initialize FetchedResultsController: \(error)")
            }
        }
    }
    
    // MARK: UITable view data source
    public func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController?.sections?.count ?? 0
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionInfo = fetchedResultsController?.sections?[section] else {
            return 0
        }
        return sectionInfo.numberOfObjects
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let message = fetchedResultsController?.object(at: indexPath) as? KREMessage else {
            return UITableViewCell(style: .default, reuseIdentifier: "UITableViewCell")
        }
        
        if let messageType = message.messageType?.intValue, messageType == MessageType.timeline.rawValue {
            let cellIdentifier = "MessageTimeLineCell"
            if let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? MessageTimeLineCell {
                UserDefaults.standard.setSignifyBottomView(with: true)
                cell.configure(with: message)
//                self.viewDelegate?.closeQuickReplyCards()
                return cell
            }
        }
        
        var cellIdentifier = "TextBubbleCell"
        if let templateType = message.templateType?.intValue, let componentType = ComponentType(rawValue: templateType) {
            switch componentType {
            case .text:
                cellIdentifier = "TextBubbleCell"
                break
            case .image:
                cellIdentifier = "ImageBubbleCell"
                break
            case .options:
                cellIdentifier = "OptionsBubbleCell"
                break
            case .quickReply:
                cellIdentifier = "QuickReplyBubbleCell"
                break
            case .list:
                cellIdentifier = "ListBubbleCell"
                break
            case .carousel:
                cellIdentifier = "CarouselBubbleCell"
                break
            case .error:
                cellIdentifier = "ErrorBubbleCell"
                break
            case .chart:
                cellIdentifier = "PiechartBubbleCell"
                break
            case .minitable:
                cellIdentifier = "MiniTableBubbleCell"
                break
            case .table:
                cellIdentifier = "TableBubbleCell"
                break
            case .responsiveTable:
                cellIdentifier = "ResponsiveTableBubbleCell"
                break
            case .menu:
                cellIdentifier = "MenuBubbleCell"
                break
            case .picker:
                cellIdentifier = "PickerBubbleCell"
                break
            case .sessionend:
                cellIdentifier = "SessionEndBubbleCell"
                break
            case .showProgress:
                cellIdentifier = "ShowProgressBubbleCell"
                break
            case .agentTransferMode:
                cellIdentifier = "AgentTransferModeBubbleCell"
                break
            case .timerTask:
                cellIdentifier = "TimerTaskBubbleCell"
            }
        }
        
        let cell: MessageBubbleCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! MessageBubbleCell
        if let components = message.components?.array as? [KREComponent] {
            cell.configureWithComponents(components)
        }
        if self.clearBackground {
            cell.backgroundColor = .clear
        }
        
        var isQuickReply = false
        var isPicker = false
        var isSessionEnd = false
        var isshowProgress = false
        
        switch (cell.bubbleView.bubbleType!) {
        case .text:
            let bubbleView: TextBubbleView = cell.bubbleView as! TextBubbleView
            self.textLinkDetection(textLabel: bubbleView.textLabel)
            if (bubbleView.textLabel.attributedText?.string == "Welcome John, You already hold a Savings account with Kore bank."){
                userActive = true
            }
            if userActive {
                self.updtaeUserImage()
            }
            
            bubbleView.onChange = { [weak self](reload) in
                self?.tableView.reloadRows(at: [indexPath], with: .none)
            }
            
            break
        case .image:
            break
        case .options:
            let bubbleView: OptionsBubbleView = cell.bubbleView as! OptionsBubbleView
            self.textLinkDetection(textLabel: bubbleView.textLabel);
            bubbleView.optionsAction = {[weak self] (text) in
                self?.viewDelegate?.optionsButtonTapAction(text: text!)
            }
            bubbleView.linkAction = {[weak self] (text) in
                self?.viewDelegate?.linkButtonTapAction(urlString: text!)
            }
            
            cell.bubbleView.drawBorder = true
            break
        case .list:
            let bubbleView: ListBubbleView = cell.bubbleView as! ListBubbleView
            bubbleView.optionsAction = {[weak self] (text) in
                self?.viewDelegate?.optionsButtonTapAction(text: text!)
            }
            bubbleView.linkAction = {[weak self] (text) in
                self?.viewDelegate?.linkButtonTapAction(urlString: text!)
            }
            
            cell.bubbleView.drawBorder = true
            break
        case .quickReply:
            isQuickReply = true
            break
        case .carousel:
            let bubbleView: CarouselBubbleView = cell.bubbleView as! CarouselBubbleView
            bubbleView.optionsAction = {[weak self] (text) in
                self?.viewDelegate?.optionsButtonTapAction(text: text!)
            }
            bubbleView.linkAction = {[weak self] (text) in
                self?.viewDelegate?.linkButtonTapAction(urlString: text!)
            }
            break
        case .error:
            let bubbleView: ErrorBubbleView = cell.bubbleView as! ErrorBubbleView
            self.textLinkDetection(textLabel: bubbleView.textLabel)
            break
        case .chart:
            break
        case .table:
            break
        case .minitable:
            break
        case .responsiveTable:
            break
        case .menu:
            let bubbleView: MenuBubbleView = cell.bubbleView as! MenuBubbleView
            bubbleView.optionsAction = { [weak self] (text) in
                self?.viewDelegate?.optionsButtonTapAction(text: text!)
            }
            bubbleView.linkAction = { [weak self] (text) in
                self?.viewDelegate?.linkButtonTapAction(urlString: text!)
            }
            
            cell.bubbleView.drawBorder = true
            break
        case .picker:
            isPicker = true
            break
        case .sessionend:
            isSessionEnd = true
           
            break
        case .showProgress:
            isshowProgress = true
            break
        case .agentTransferMode:
            agentTransferMode = true
           
            break
        case .timerTask:
            break
        }
        
        let lastIndexPath = getIndexPathForLastItem()
        if lastIndexPath.compare(indexPath) == ComparisonResult.orderedSame {
            DataStoreManager.sharedManager.getComposeBarStatus { (hideComposeBar) in
                DispatchQueue.main.async { [unowned self] in
                    self.viewDelegate?.setComposeBarHidden(hideComposeBar)
                }
            }
            
            if isQuickReply {
                UserDefaults.standard.setSignifyBottomView(with: true)
                self.viewDelegate?.populateQuickReplyCards(with: message)
            } else if isPicker {
                UserDefaults.standard.setSignifyBottomView(with: true)
                self.viewDelegate?.populatePickerView(with: message)
            } else if isSessionEnd {
                UserDefaults.standard.setSignifyBottomView(with: true)
                self.viewDelegate?.populateSessionEndView(with: message)
            } else if isshowProgress {
                UserDefaults.standard.setSignifyBottomView(with: true)
                self.viewDelegate?.populateBottomTableView(with: message)
            } else {
                 self.viewDelegate?.closeQuickReplyCards()
            }
            
            if agentTransferMode, let bubbleType = cell.bubbleView.bubbleType, bubbleType == .text {
                self.viewDelegate?.stopWaitTimerTasks()
                self.viewDelegate?.startWaitTimerTasks()
            } else if agentTransferMode, let bubbleType = cell.bubbleView.bubbleType, bubbleType == .sessionend {
                agentTransferMode = false
                self.viewDelegate?.stopWaitTimerTasks()
            }
        }
        return cell
    }
    
    // MARK: UITable view delegate source
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var date = Date()
        if let rowsCount = fetchedResultsController?.fetchedObjects?.count, rowsCount > 0 {
            if let message = fetchedResultsController?.object(at: IndexPath(row: 0, section: section)) as? KREMessage {
                if let sentOn = message.sentOn as Date? {
                    date = sentOn
                }
            }
        }
        
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, d MMMM YYYY"
        let dateString = dateFormatter.string(from: date)
        
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "BotMessagesHeaderFooterView") as? BotMessagesHeaderFooterView ?? BotMessagesHeaderFooterView(reuseIdentifier: "BotMessagesHeaderFooterView")
        headerView.titleLabel.text = dateString
        return headerView
    }
    
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        return view
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 36.0
    }
    
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 5.0
    }
    
    // MARK:- KREFetchedResultsControllerDelegate methods
    func fetchedControllerWillChangeContent() {
        let indexPath = getIndexPathForLastItem()
        if let visibleCelIndexPaths = self.tableView.indexPathsForVisibleRows, visibleCelIndexPaths.contains(indexPath) {
            shouldScrollToBottom = true
        }
    }
    
    func fetchedControllerDidChangeContent() {

    }
    
    func fetchedControllerDidEndAnimation() {
        if (self.shouldScrollToBottom && !self.tableView.isDragging) {
            self.shouldScrollToBottom = true
            self.scrollToLastMessage()
        }
    }
    
    func scrollToLastMessage() {
        CATransaction.begin()
        CATransaction.setCompletionBlock({ () -> Void in
            self.scrollToBottom(animated: true)
        })
        
        // scroll down by 1 point: this causes the newly added cell to be dequeued and rendered.
        var contentOffset = tableView.contentOffset
        contentOffset.y += 1
        self.tableView.setContentOffset(contentOffset, animated: true)
        
        CATransaction.commit()
    }
    
    // MARK: - scrollTo related methods
    func scrollWithOffset(_ offset: CGFloat, animated animate: Bool) {
        if self.tableView.contentSize.height < self.frame.size.height { // when content is too less
            return
        }
        if self.frame.size.height + self.tableView.contentOffset.y >= self.tableView.contentSize.height - 1.0/*fraction buffer*/ {
            return
        }

        var contentOffset = self.tableView.contentOffset
        contentOffset.y += offset
        if contentOffset.y < -self.tableView.contentInset.top {
            contentOffset.y = -self.tableView.contentInset.top
        }
        if self.tableView.frame.size.height + offset > self.tableView.contentSize.height {
            contentOffset.y = self.tableView.contentSize.height - self.tableView.frame.size.height
        }

        self.tableView.setContentOffset(contentOffset, animated: animate)
    }
    
    func scrollToBottom(animated animate: Bool) {
        let indexPath: IndexPath = self.getIndexPathForLastItem()
        if (indexPath.row > 0 || indexPath.section > 0) {
            self.tableView.scrollToRow(at: indexPath as IndexPath, at: .bottom, animated: animate)
        }
    }
    
    func getIndexPathForLastItem() -> IndexPath {
        var indexPath: IndexPath = IndexPath(row: 0, section: 0);
        let numberOfSections: Int = self.tableView.numberOfSections
        if numberOfSections > 0 {
            let numberOfRows: Int = self.tableView.numberOfRows(inSection: numberOfSections - 1)
            if numberOfRows > 0 {
                indexPath = IndexPath(row: numberOfRows - 1, section: numberOfSections - 1)
            }
        }
        return indexPath
    }
    
    // MARK: helper functions
    func textLinkDetection(textLabel:KREAttributedLabel) {
        textLabel.detectionBlock = {(hotword, string) in
            switch hotword {
            case KREAttributedHotWordLink:
                self.viewDelegate?.linkButtonTapAction(urlString: string!)
                break
            default:
                break
            }
        }
    }
    
    @objc fileprivate func updtaeUserImage() {
        NotificationCenter.default.post(name: Notification.Name(updateUserImageNotification), object: nil)
    }
    
    
    // MARK:- deinit
    deinit {
        NSLog("BotMessagesView dealloc")
        self.fetchedResultsController = nil
    }
}

// MARK: - BotMessagesHeaderFooterView
class BotMessagesHeaderFooterView: UITableViewHeaderFooterView {
    // MARK: - properties
    let titleLabel = UILabel()
    var title: String?
    
    // MARK: -
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        // content View
        contentView.backgroundColor = .white
        let marginGuide = contentView.layoutMarginsGuide
        
        // title label
        contentView.addSubview(titleLabel)
        titleLabel.textColor = UIColorRGB(0xB0B0B0)
        titleLabel.backgroundColor = .clear
        titleLabel.font = UIFont.systemFont(ofSize: 15.0)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.topAnchor.constraint(equalTo: marginGuide.topAnchor).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: marginGuide.trailingAnchor).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: marginGuide.bottomAnchor).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: marginGuide.leadingAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

