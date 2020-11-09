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
    func closeQuickReplyCards()
    func optionsButtonTapNewAction(text:String, payload:String)
    func populateCalenderView(with message: KREMessage?)
    func populateFeedbackSliderView(with message: KREMessage?)
}

class BotMessagesView: UIView, UITableViewDelegate, UITableViewDataSource, KREFetchedResultsControllerDelegate {

    var tableView: UITableView
    var fetchedResultsController: KREFetchedResultsController!
    var viewDelegate: BotMessagesViewDelegate?
    var shouldScrollToBottom: Bool = false
    var clearBackground = false
    var userActive = false
    
    weak var thread: KREThread! {
        didSet{
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
    
    required init?(coder aDecoder: NSCoder) {
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
        
        self.tableView.transform = CGAffineTransform(scaleX: 1, y: -1)
        
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
        self.tableView.register(NewListBubbleCell.self, forCellReuseIdentifier:"NewListBubbleCell")
        self.tableView.register(TableListBubbleCell.self, forCellReuseIdentifier:"TableListBubbleCell")
        self.tableView.register(CalendarBubbleCell.self, forCellReuseIdentifier:"CalendarBubbleCell")
        self.tableView.register(QuickRepliesWelcomeCell.self, forCellReuseIdentifier:"QuickRepliesWelcomeCell")
        self.tableView.register(NotificationBubbleCell.self, forCellReuseIdentifier:"NotificationBubbleCell")
        self.tableView.register(MultiSelectBubbleCell.self, forCellReuseIdentifier:"MultiSelectBubbleCell")
        self.tableView.register(ListWidgetBubbleCell.self, forCellReuseIdentifier:"ListWidgetBubbleCell")
        self.tableView.register(FeedbackBubbleCell.self, forCellReuseIdentifier:"FeedbackBubbleCell")
        self.tableView.register(InLineFormCell.self, forCellReuseIdentifier:"InLineFormCell")
        self.tableView.register(DropDownell.self, forCellReuseIdentifier:"DropDownell")

    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    //MARK:- removing refernces to elements
    func prepareForDeinit(){
        self.fetchedResultsController?.kreDelegate = nil
        self.fetchedResultsController.tableView = nil
    }
    
    func initializeFetchedResultsController() {
        if(self.thread != nil){
            let request: NSFetchRequest<KREMessage> = KREMessage.fetchRequest()
            request.predicate = NSPredicate(format: "thread.threadId == %@", self.thread.threadId!)
            request.sortDescriptors = [NSSortDescriptor(key: "sentOn", ascending: false)]
            
            let mainContext: NSManagedObjectContext = DataStoreManager.sharedManager.coreDataManager.mainContext
            fetchedResultsController = KREFetchedResultsController(fetchRequest: request as! NSFetchRequest<NSManagedObject>, managedObjectContext: mainContext, sectionNameKeyPath: nil, cacheName: nil)
            fetchedResultsController.tableView = self.tableView
            fetchedResultsController.kreDelegate = self
            do {
                try fetchedResultsController.performFetch()
            } catch {
                fatalError("Failed to initialize FetchedResultsController: \(error)")
            }
        }
    }
    
    // MARK: UITable view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController?.fetchedObjects?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let message: KREMessage = fetchedResultsController!.object(at: indexPath) as! KREMessage
        
        var cellIdentifier: String! = nil
        if let componentType = ComponentType(rawValue: (message.templateType?.intValue)!) {
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
            case .newList:
                cellIdentifier = "NewListBubbleCell"
                break
            case .tableList:
                cellIdentifier = "TableListBubbleCell"
                break
            case .calendarView:
                cellIdentifier = "CalendarBubbleCell"
                break
            case .quick_replies_welcome:
                cellIdentifier = "QuickRepliesWelcomeCell"
                break
            case .notification:
                cellIdentifier = "NotificationBubbleCell"
                break
            case .multiSelect:
                cellIdentifier = "MultiSelectBubbleCell"
                break
            case .list_widget:
                cellIdentifier = "ListWidgetBubbleCell"
                break
            case .feedbackTemplate:
                cellIdentifier = "FeedbackBubbleCell"
                break
            case .inlineForm:
                cellIdentifier = "InLineFormCell"
                break
            case .dropdown_template:
                cellIdentifier = "DropDownell"
                break
            }
            
        }
        
        let cell: MessageBubbleCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! MessageBubbleCell
        cell.configureWithComponents(message.components?.array as! Array<KREComponent>)
        if self.clearBackground {
            cell.backgroundColor = .clear
        }
        
        var isQuickReply = false
        var isCalenderView = false
        var isFeedbackView = false
        
        switch (cell.bubbleView.bubbleType!) {
        case .text:
            
            let bubbleView: TextBubbleView = cell.bubbleView as! TextBubbleView
            
            self.textLinkDetection(textLabel: bubbleView.textLabel)
            if(bubbleView.textLabel.attributedText?.string == "Welcome John, You already hold a Savings account with Kore bank."){
                userActive = true
            }
            if(userActive){
                self.updtaeUserImage()
            }
            
            bubbleView.onChange = { [weak self](reload) in
                self?.tableView.reloadRows(at: [indexPath], with: .none)
            }
            cell.bubbleView.drawBorder = true
            break
        case .image:
            break
        case .options:
            let bubbleView: OptionsBubbleView = cell.bubbleView as! OptionsBubbleView
            self.textLinkDetection(textLabel: bubbleView.textLabel);
            bubbleView.optionsAction = {[weak self] (text, payload) in
                self?.viewDelegate?.optionsButtonTapNewAction(text: text!, payload: payload ?? text!)
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
            bubbleView.optionsAction = {[weak self] (text, payload) in
                self?.viewDelegate?.optionsButtonTapNewAction(text: text!, payload: payload ?? text!)
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
            bubbleView.optionsAction = {[weak self] (text) in
                self?.viewDelegate?.optionsButtonTapAction(text: text!)
            }
            bubbleView.linkAction = {[weak self] (text) in
                self?.viewDelegate?.linkButtonTapAction(urlString: text!)
            }
            
            cell.bubbleView.drawBorder = true
            break
        case .newList:
            let bubbleView: NewListBubbleView = cell.bubbleView as! NewListBubbleView
            bubbleView.optionsAction = {[weak self] (text, payload) in
                self?.viewDelegate?.optionsButtonTapNewAction(text: text!, payload: payload!)
            }
            bubbleView.linkAction = {[weak self] (text) in
                self?.viewDelegate?.linkButtonTapAction(urlString: text!)
            }
            
            cell.bubbleView.drawBorder = true
            break
        case .tableList:
            let bubbleView: TableListBubbleView = cell.bubbleView as! TableListBubbleView
            bubbleView.optionsAction = {[weak self] (text, payload) in
                self?.viewDelegate?.optionsButtonTapNewAction(text: text!, payload: payload!)
            }
            bubbleView.linkAction = {[weak self] (text) in
                self?.viewDelegate?.linkButtonTapAction(urlString: text!)
            }
            
            cell.bubbleView.drawBorder = true
            break
        case .calendarView:
            //let bubbleView: CalenderBubbleView = cell.bubbleView as! CalenderBubbleView
            isCalenderView = true
            cell.bubbleView.drawBorder = true
            break
        case .quick_replies_welcome:
            let bubbleView: QuickReplyWelcomeBubbleView = cell.bubbleView as! QuickReplyWelcomeBubbleView
            bubbleView.optionsAction = {[weak self] (text, payload) in
                self?.viewDelegate?.optionsButtonTapNewAction(text: text!, payload: payload!)
            }
            cell.bubbleView.drawBorder = true
            break
        case .notification:
            let bubbleView: NotificationBubbleView = cell.bubbleView as! NotificationBubbleView
            bubbleView.optionsAction = {[weak self] (text, payload) in
                self?.viewDelegate?.optionsButtonTapNewAction(text: text!, payload: payload!)
            }
            break
        case .multiSelect:
            let bubbleView: MultiSelectNewBubbleView = cell.bubbleView as! MultiSelectNewBubbleView
            bubbleView.optionsAction = {[weak self] (text, payload) in
                self?.viewDelegate?.optionsButtonTapNewAction(text: text!, payload: payload!)
            }
            cell.bubbleView.drawBorder = true
            break
        case .list_widget:
            let bubbleView: ListWidgetBubbleView = cell.bubbleView as! ListWidgetBubbleView
            bubbleView.optionsAction = {[weak self] (text, payload) in
                self?.viewDelegate?.optionsButtonTapNewAction(text: text!, payload: payload!)
            }
            bubbleView.linkAction = {[weak self] (text) in
                self?.viewDelegate?.linkButtonTapAction(urlString: text!)
            }
            cell.bubbleView.drawBorder = true
            break
        case .feedbackTemplate:
            let bubbleView: FeedbackBubbleView = cell.bubbleView as! FeedbackBubbleView
            bubbleView.optionsAction = {[weak self] (text, payload) in
                self?.viewDelegate?.optionsButtonTapNewAction(text: text!, payload: payload!)
            }
            isFeedbackView = true
            cell.bubbleView.drawBorder = true
            break
        case .inlineForm:
            let bubbleView: InLineFormBubbleView = cell.bubbleView as! InLineFormBubbleView
            bubbleView.inlineTextField.tag = indexPath.row
            bubbleView.optionsAction = {[weak self] (text, payload) in
                self?.viewDelegate?.optionsButtonTapNewAction(text: text!, payload: payload!)
            }
            cell.bubbleView.drawBorder = true
            break
        case .dropdown_template:
            cell.bubbleView.drawBorder = true
            break
        }
        let firstIndexPath:NSIndexPath = NSIndexPath.init(row: 0, section: 0)
        if firstIndexPath.isEqual(indexPath) {
            if isQuickReply {
                self.viewDelegate?.populateQuickReplyCards(with: message)
            }else{
                self.viewDelegate?.closeQuickReplyCards()
            }
            
            if isCalenderView{
                self.viewDelegate?.populateCalenderView(with: message)
            }
            
            if isFeedbackView{
                if message.templateType == (ComponentType.feedbackTemplate.rawValue as NSNumber) {
                    let component: KREComponent = message.components![0] as! KREComponent
                    if ((component.componentDesc) != nil) {
                        let jsonString = component.componentDesc
                        let jsonObject: NSDictionary = Utilities.jsonObjectFromString(jsonString: jsonString!) as! NSDictionary
                        if jsonObject["sliderView"] as! Bool{
                            self.viewDelegate?.populateFeedbackSliderView(with: message)
                        }
                    }
                }
            }
        }
        
        return cell
    }
    
    // MARK: UITable view delegate source
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        return view
    }
    
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        var date = Date()
        if fetchedResultsController?.fetchedObjects?.count ?? 0 > 0 {
            let message = fetchedResultsController?.object(at: IndexPath(row: 0, section: 0)) as? KREMessage
            if let sentOn = message?.sentOn as Date? {
                date = sentOn
            }
        }
        
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, d MMMM YYYY"
        let dateString = dateFormatter.string(from: date)
        
        let label = UILabel()
        label.transform = CGAffineTransform(scaleX: 1, y: -1)
        label.text = dateString
        label.textAlignment = .center
        label.textColor = UIColor.darkGray.withAlphaComponent(0.8)
        label.font = UIFont(name: "HelveticaNeue", size: 13)
        return label
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5.0
    }
    
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 20.0
    }
    
    // MARK:- KREFetchedResultsControllerDelegate methods
    func fetchedControllerWillChangeContent() {
        let visibleCelIndexPath: [IndexPath]? = self.tableView.indexPathsForVisibleRows
        let firstIndexPath:NSIndexPath = NSIndexPath.init(row: 0, section: 0)
        if (visibleCelIndexPath?.contains(firstIndexPath as IndexPath))!{
            self.shouldScrollToBottom = true
        }
    }
    
    func fetchedControllerDidChangeContent() {
        if (self.shouldScrollToBottom && !self.tableView.isDragging) {
            self.shouldScrollToBottom = false
            self.scrollToTop(animate: true)
        }
    }
    
    func scrollToTop(animate: Bool){
        self.tableView.scrollToRow(at: IndexPath.init(row: 0, section: 0), at: .bottom, animated: animate)
    }
    
    // MARK: - scrollTo related methods
    func getIndexPathForLastItem()->(NSIndexPath){
        var indexPath:NSIndexPath = NSIndexPath.init(row: 0, section: 0);
        let numberOfSections: Int = self.tableView.numberOfSections
        if numberOfSections > 0 {
            let numberOfRows: Int = self.tableView.numberOfRows(inSection: numberOfSections - 1)
            if numberOfRows > 0 {
                indexPath = NSIndexPath(row: numberOfRows - 1, section: numberOfSections - 1)
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
extension String {
    func regEx() -> String {
        return self.replacingOccurrences(of: "[A-Za-z0-9 !\"#$%&'()*+,-./:;<=>?@\\[\\\\\\]^_`{|}~]", with: "•", options: .regularExpression, range: nil)
    }
}
