//
//  BotMessagesTableView.swift
//  KoreBotSDKDemo
//
//  Created by Anoop Dhiman on 26/07/17.
//  Copyright © 2017 Kore. All rights reserved.
//

import UIKit
import CoreData

class BotMessagesTableView: UITableView, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate {
    
    var fetchedResultsController: NSFetchedResultsController<KREMessage>!
    var shouldScrollToBottom:Bool = false
    var prototypeCell: MessageBubbleCell!

    weak var thread: KREThread! {
        didSet{
            self.initializeFetchedResultsController()
        }
    }
    
    convenience init(){
        self.init(frame: CGRect.zero, style: .grouped)
    }
    
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    func setup() {
        self.separatorStyle = .none
        self.dataSource = self
        self.delegate = self
        
        self.prototypeCell = MessageBubbleCell()
        
        self.register(MessageBubbleCell.self, forCellReuseIdentifier:"MessageBubbleCell")
        self.register(TextBubbleCell.self, forCellReuseIdentifier:"TextBubbleCell")
        self.register(ImageBubbleCell.self, forCellReuseIdentifier:"ImageBubbleCell")
        self.register(OptionsBubbleCell.self, forCellReuseIdentifier:"OptionsBubbleCell")
        self.register(ListBubbleCell.self, forCellReuseIdentifier:"ListBubbleCell")
        self.register(QuickReplyBubbleCell.self, forCellReuseIdentifier:"QuickReplyBubbleCell")
        self.register(CarouselBubbleCell.self, forCellReuseIdentifier:"CarouselBubbleCell")
        self.register(ErrorBubbleCell.self, forCellReuseIdentifier:"ErrorBubbleCell")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    //MARK:- removing refernces to elements
    func prepareForDeinit(){
        self.fetchedResultsController?.delegate = nil
        self.fetchedResultsController = nil
    }
    
    func initializeFetchedResultsController() {
        if(self.thread != nil){
            let request: NSFetchRequest<KREMessage> = KREMessage.fetchRequest()
            request.predicate = NSPredicate(format: "thread.threadId == %@", self.thread.threadId!)
            request.sortDescriptors = [NSSortDescriptor(key: "sentOn", ascending: true)]
            
            let mainContext: NSManagedObjectContext = DataStoreManager.sharedManager.coreDataManager.mainContext
            fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: mainContext, sectionNameKeyPath: nil, cacheName: nil)
            fetchedResultsController.delegate = self
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
        
        let message: KREMessage = fetchedResultsController!.object(at: indexPath)
        
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
            default:
                cellIdentifier = "TextBubbleCell"
            }
        }
        
        let cell: MessageBubbleCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! MessageBubbleCell
        cell.configureWithComponents(message.components?.array as! Array<KREComponent>)
        
        return cell
    }
    
    // MARK: UITable view delegate source
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let message: KREMessage = fetchedResultsController!.object(at: indexPath)
        var cellHeight = message.cellHeight
        
        if(cellHeight == 0.0){
            cellHeight = self.prototypeCell.getEstimatedHeightForComponents(message.components?.array as! Array<KREComponent>, bubbleType: BubbleType(rawValue: (message.templateType?.intValue)!)!)
            cellHeight = CGFloat(ceilf(Float(cellHeight)))
            
            message.cellHeight = cellHeight
        }
        
        return cellHeight
    }
    
    // MARK:- NSFetchedResultsControllerDelegate methods
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.fetchedControllerWillChangeContent()
        self.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
            case .insert:
                self.insertSections(IndexSet(integer: sectionIndex), with: .fade)
            case .delete:
                self.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
            case .move:
                break
            case .update:
                break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
            case .insert:
                self.insertRows(at: [newIndexPath!], with: .fade)
            case .delete:
                self.deleteRows(at: [indexPath!], with: .fade)
            case .update:
                self.reloadRows(at: [indexPath!], with: .fade)
            case .move:
                self.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.endUpdates()
        self.fetchedControllerDidChangeContent()
    }
    
    func fetchedControllerWillChangeContent() {
        let visibleCelIndexPath: [IndexPath]? = self.indexPathsForVisibleRows
        let indexPath: IndexPath? = self.getIndexPathForLastItem() as IndexPath
        if (visibleCelIndexPath?.contains(indexPath!))!{
            self.shouldScrollToBottom = true
        }
    }
    
    func fetchedControllerDidChangeContent() {
        if (self.shouldScrollToBottom && !self.isDragging) {
            self.shouldScrollToBottom = false
            self.scrollToBottom(animated: true)
        }
    }
    
    // MARK: - scrollTo related methods
    func scrollWithOffset(_ offset: CGFloat, animated animate: Bool) {
        var contentOffset = self.contentOffset
        contentOffset.y += offset
        
        if contentOffset.y < -self.contentInset.top {
            contentOffset.y = -self.contentInset.top
        }
        if self.frame.size.height + self.contentOffset.y >= self.contentSize.height - 1.0/*fraction buffer*/ {
            return
        }
        
        self.setContentOffset(contentOffset, animated: animate)
    }
    
    func scrollToBottom(animated animate: Bool, withDelay delay:TimeInterval) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delay) {
            self.scrollToBottom(animated: animate)
        }
    }
    
    func scrollToBottom(animated animate: Bool) {
        NSLog("BotMessagesTableView: scrollToBottom")
        let indexPath: NSIndexPath = self.getIndexPathForLastItem()
        if (indexPath.row > 0 || indexPath.section > 0) {
            self.scrollToRow(at: indexPath as IndexPath, at: .bottom, animated: animate)
        }
    }
    
    func getIndexPathForLastItem()->(NSIndexPath){
        var indexPath:NSIndexPath = NSIndexPath.init(row: 0, section: 0);
        let numberOfSections: Int = self.numberOfSections
        if numberOfSections > 0 {
            let numberOfRows: Int = self.numberOfRows(inSection: numberOfSections - 1)
            if numberOfRows > 0 {
                indexPath = NSIndexPath(row: numberOfRows - 1, section: numberOfSections - 1)
            }
        }
        return indexPath
    }
    
    // MARK:- deinit
    deinit {
        NSLog("BotMessagesTableView dealloc")
        self.fetchedResultsController = nil
        self.thread = nil
    }
}
