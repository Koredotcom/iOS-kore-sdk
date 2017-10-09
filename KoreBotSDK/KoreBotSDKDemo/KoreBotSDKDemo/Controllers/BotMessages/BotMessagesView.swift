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
}

class BotMessagesView: UIView, UITableViewDelegate, UITableViewDataSource, KREFetchedResultsControllerDelegate {

    var tableView: UITableView
    var fetchedResultsController: KREFetchedResultsController!
    var viewDelegate: BotMessagesViewDelegate?
    var shouldScrollToBottom: Bool = false
    var prototypeCell: MessageBubbleCell!
    var clearBackground = false
    
    weak var thread: KREThread! {
        didSet{
            self.initializeFetchedResultsController()
        }
    }
    
    convenience init(){
        self.init(frame: CGRect.zero)
    }
    
    override init(frame: CGRect) {
        self.tableView = UITableView(frame: frame, style: .plain)
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.tableView = UITableView(frame: CGRect.zero, style: .plain)
        super.init(coder: aDecoder)
        self.setup()
    }
    
    func setup() {
        self.tableView.backgroundColor = UIColor.white
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
        
        self.prototypeCell = MessageBubbleCell()
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
            request.sortDescriptors = [NSSortDescriptor(key: "sentOn", ascending: true)]
            
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
        return fetchedResultsController!.fetchedObjects!.count
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
            case .piechart:
                cellIdentifier = "PiechartBubbleCell"
                break
            case .table:
                cellIdentifier = "TableBubbleCell"
                break
            default:
                cellIdentifier = "TextBubbleCell"
            }
        }
        
        let cell: MessageBubbleCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! MessageBubbleCell
        cell.configureWithComponents(message.components?.array as! Array<KREComponent>)
        if self.clearBackground {
            cell.backgroundColor = .clear
        }
        
        var isQuickReply = false
        
        switch (cell.bubbleView.bubbleType!) {
        case .text:
            let bubbleView: TextBubbleView = cell.bubbleView as! TextBubbleView
            self.textLinkDetection(textLabel: bubbleView.textLabel)
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
        case .piechart:
            
            break
        case .table:
            
            break
        default:
            break
        }
        
        let lastIndexPath = getIndexPathForLastItem()
        if lastIndexPath.isEqual(indexPath) {
            if isQuickReply {
                self.viewDelegate?.populateQuickReplyCards(with: message)
            }else{
                self.viewDelegate?.closeQuickReplyCards()
            }
        }
        
        return cell
    }
    
    // MARK: UITable view delegate source
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let message: KREMessage = fetchedResultsController!.object(at: indexPath) as! KREMessage
        var cellHeight = message.cellHeight
        
        if(cellHeight == 0.0){
            cellHeight = self.prototypeCell.getEstimatedHeightForComponents(message.components?.array as! Array<KREComponent>, bubbleType: BubbleType(rawValue: (message.templateType?.intValue)!)!)
            cellHeight = CGFloat(ceilf(Float(cellHeight)))
            
            message.cellHeight = cellHeight
        }
        
        return cellHeight
    }
    
    // MARK:- KREFetchedResultsControllerDelegate methods
    func fetchedControllerWillChangeContent() {
        let visibleCelIndexPath: [IndexPath]? = self.tableView.indexPathsForVisibleRows
        let indexPath: IndexPath? = self.getIndexPathForLastItem() as IndexPath
        if (visibleCelIndexPath?.contains(indexPath!))!{
            self.shouldScrollToBottom = true
        }
    }
    
    func fetchedControllerDidChangeContent() {
        if (self.shouldScrollToBottom && !self.tableView.isDragging) {
            self.shouldScrollToBottom = false
            self.scrollToBottom(animated: true)
        }
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
        let indexPath: NSIndexPath = self.getIndexPathForLastItem()
        if (indexPath.row > 0 || indexPath.section > 0) {
            self.tableView.scrollToRow(at: indexPath as IndexPath, at: .bottom, animated: animate)
        }
    }
    
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
    
    // MARK:- deinit
    deinit {
        NSLog("BotMessagesView dealloc")
        self.fetchedResultsController = nil
    }
}
