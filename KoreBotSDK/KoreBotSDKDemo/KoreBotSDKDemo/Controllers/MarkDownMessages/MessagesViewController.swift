//
//  MessagesViewController.swift
//  KoreBotSDKDemo
//
//  Created by developer@kore.com on 18/11/16.
//  Copyright © 2016 Kore Inc. All rights reserved.
//

import UIKit
import TOWebViewController
import AFNetworking
import CoreData

class MessagesViewController : UITableViewController {
    
    var sectionedThread: SectionedThread!
    var fetchedResultsController: NSFetchedResultsController<KREMessage>! = nil
    var mainContext: NSManagedObjectContext = DataStoreManager.sharedManager.coreDataManager.mainContext
    var thread: KREThread! {
        didSet {
            let request = NSFetchRequest<KREMessage>(entityName: "KREMessage")
            request.predicate = NSPredicate(format: "threadId == %@", self.thread.threadId!)
            request.sortDescriptors = [NSSortDescriptor(key: "sentOn", ascending: false)]
            fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: mainContext, sectionNameKeyPath: nil, cacheName: nil)
            try! fetchedResultsController .performFetch()
            
            self.tableView.alpha = 0
            
            UIView.animate(withDuration: 0, animations: {
                self.tableView.reloadData()
                }, completion: { (completion) in
                    self.scrollToBottom()
                    self.tableView.alpha = 1
            })
        }
    }
    
    let startingViewImageIndex: Int! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let request = NSFetchRequest<KREMessage>(entityName: "KREMessage")
        request.predicate = NSPredicate(format: "thread.threadId == %@", "t-1")
        request.sortDescriptors = [NSSortDescriptor(key: "sentOn", ascending: false)]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: mainContext, sectionNameKeyPath: nil, cacheName: nil)
        try! fetchedResultsController .performFetch()
        
        self.tableView.alpha = 0
        
        UIView.animate(withDuration: 0, animations: {
            self.tableView.reloadData()
            }, completion: { (completion) in
                self.scrollToBottom()
                self.tableView.alpha = 1
        })
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 200
        
        self.tableView.separatorStyle = .none
        
        self.tableView.register(TextBubbleCell.self, forCellReuseIdentifier:"TextBubbleCell")
        self.tableView.register(ImageBubbleCell.self, forCellReuseIdentifier:"ImageBubbleCell")
        self.tableView.register(MessageBubbleCell.self, forCellReuseIdentifier:"MessageBubbleCell")
    }
    
    
    func scrollToBottom() {
        
    }
    
    // MARK: UITable view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.fetchedObjects!.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let message: KREMessage = fetchedResultsController.object(at: indexPath)
//        let componentGroup: ComponentGroup = threadSection.groups[(indexPath as NSIndexPath).row] as! ComponentGroup
        
        let maskType: BubbleMaskType! = .top
        
        let cellIdentifier: String! = "TextBubbleCell"
        let cell: MessageBubbleCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! MessageBubbleCell
//        cell.configureWithComponents(message.components?.array as! Array<KREComponent>, maskType:maskType, tem)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
}
