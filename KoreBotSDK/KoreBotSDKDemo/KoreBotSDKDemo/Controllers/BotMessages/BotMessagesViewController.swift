//
//  BotMessagesViewController.swift
//  KoreBotSDKDemo
//
//  Created by Srinivas Vasadi on 09/05/16.
//  Copyright © 2016 Kore. All rights reserved.
//

import UIKit
import TOWebViewController
import AFNetworking
import CoreData

enum MessageThreadHeaderType : Int {
    case none = 1, sender = 2, date = 3, senderAndDate = 4
}


protocol BotMessagesDelegate {
    func optionsButtonTapAction(text:String)
}


class BotMessagesViewController : UITableViewController, KREFetchedResultsControllerDelegate {

    var fetchedResultsController: KREFetchedResultsController? = nil
    var messagesArray:NSArray!
    var mainContext: NSManagedObjectContext = DataStoreManager.sharedManager.coreDataManager.mainContext
    var lastMessage:KREMessage!
    var delegate:BotMessagesDelegate?
    var shouldScrollToBottom:Bool = false
    var thread: KREThread! {
        didSet {
            let request = NSFetchRequest<KREMessage>(entityName: "KREMessage")
            request.predicate = NSPredicate(format: "thread.threadId == %@ && templateType != 5", self.thread.threadId!)

            request.sortDescriptors = [NSSortDescriptor(key: "sentOn", ascending: true)]
            fetchedResultsController = KREFetchedResultsController(fetchRequest: request as! NSFetchRequest<NSManagedObject>, managedObjectContext: mainContext, sectionNameKeyPath: nil, cacheName: nil)
            fetchedResultsController?.tableView = self.tableView
            fetchedResultsController?.kreDelegate = self
//            fetchedResultsController?.fetchRequest.fetchLimit = 20
            try! fetchedResultsController? .performFetch()
            
//            self.getLastQuickReplyMessage()
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
        self.shouldScrollToBottom = false;
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 200

        self.tableView.separatorStyle = .none

        self.tableView.register(TextBubbleCell.self, forCellReuseIdentifier:"TextBubbleCell")
        self.tableView.register(ImageBubbleCell.self, forCellReuseIdentifier:"ImageBubbleCell")
        self.tableView.register(OptionsBubbleCell.self, forCellReuseIdentifier:"OptionsBubbleCell")
        self.tableView.register(ListBubbleCell.self, forCellReuseIdentifier:"ListBubbleCell")
        self.tableView.register(MessageBubbleCell.self, forCellReuseIdentifier:"MessageBubbleCell")
    }

    func getLastQuickReplyMessage()  {
        let request = NSFetchRequest<KREMessage>(entityName: "KREMessage")
        request.predicate = NSPredicate(format: "thread.threadId == %@", self.thread.threadId!)

        do {
            let results = try mainContext.fetch(request)
            if(results.count > 0){
                self.lastMessage = results.last!
                print(self.lastMessage)
            }
        } catch let error {
            print(error.localizedDescription)
        }
    }
    func scrollToBottom() {
        
        let numberOfSections: Int = self.tableView.numberOfSections
        if (numberOfSections >= 0) {
            let numberOfRows: Int = self.tableView.numberOfRows(inSection: numberOfSections-1)
            if (numberOfRows > 0) {
                let indexPath: IndexPath = IndexPath(row:numberOfRows-1, section:numberOfSections-1)
                self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
            }
        }
    }
    
    // MARK: UITable view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController!.fetchedObjects!.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let message: KREMessage = fetchedResultsController!.object(at: indexPath) as! KREMessage        
        let maskType: BubbleMaskType! = .top
        
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
                cellIdentifier = "TextBubbleCell"
                break
            case .list:
                cellIdentifier = "ListBubbleCell"
                break

            default:
                cellIdentifier = "TextBubbleCell"
            }
        }

        let cell: MessageBubbleCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! MessageBubbleCell
        cell.configureWithComponents(message.components?.array as! Array<KREComponent>, maskType:maskType, templateType: ComponentType(rawValue: (message.templateType?.intValue)!)!)
        
        switch (cell.bubbleView.bubbleType!) {
        case .text:
            let bubbleView: TextBubbleView = cell.bubbleView as! TextBubbleView
            self.textLinkDetection(textLabel: bubbleView.textLabel);
                       break
        case .image:
            cell.didSelectComponentAtIndex = { (sender, index) in
                
            }
            break
        case .options:
            let components: Array<KREComponent> = message.components?.array as! Array<KREComponent>
            let bubbleView: OptionsBubbleView = cell.bubbleView as! OptionsBubbleView
            self.textLinkDetection(textLabel: bubbleView.textLabel);

            bubbleView.components = components as NSArray!
            bubbleView.optionsAction = {[weak self] (text) in
                self?.delegate?.optionsButtonTapAction(text: text!)
            }
            
            cell.bubbleView.drawBorder = true
            break
        case .list:
            let components: Array<KREComponent> = message.components?.array as! Array<KREComponent>
            let bubbleView: ListBubbleView = cell.bubbleView as! ListBubbleView
            self.textLinkDetection(textLabel: bubbleView.textLabel);

            bubbleView.showMore = message.showMore
            bubbleView.components = components as NSArray!
            bubbleView.optionsAction = {[weak self] (text) in
                if(text == "Show more"){
                    message.showMore = true;
                    bubbleView.invalidateIntrinsicContentSize()
                    let indexpath:NSIndexPath = NSIndexPath.init(row: (self?.fetchedResultsController?.fetchedObjects?.index(of: message))!, section: 0)
                    self?.tableView.reloadRows(at: [indexpath as IndexPath], with: UITableViewRowAnimation.automatic)

                }else{
                    self?.delegate?.optionsButtonTapAction(text: text!)
                }
            }
            bubbleView.linkAction = {[weak self] (text) in
                self?.launchWebViewWithURLLink(urlString: text!)
            }
            cell.bubbleView.drawBorder = true
            break
        default:
            cell.didSelectComponentAtIndex = nil
            break
        }
        cell.layoutIfNeeded()
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    // MARK:- KREFetchedResultsControllerDelegate methods
    func fetchedControllerDidChangeContent() {

    
        if(self.shouldScrollToBottom && !self.tableView.isDragging){
            self.shouldScrollToBottom = false;
            self.scrollToBottom(animated: true);
        }

    }
   
    
    
    func fetchedControllerWillChangeContent() {
        let visibleCelIndexPath: [IndexPath]? = self.tableView.indexPathsForVisibleRows
        let indexPath: IndexPath? = self.getIndexPathForLastItem() as IndexPath
        if (visibleCelIndexPath?.contains(indexPath!))!{
            self.shouldScrollToBottom = true
        }
    
    }
    // MARK: - scrollTo related methods
    func scrollToBottom(animated animate: Bool) {
        let indexPath: NSIndexPath = self.getIndexPathForLastItem()
        if( indexPath.row > 0 || indexPath.section > 0){
            self.tableView.scrollToRow(at: indexPath as IndexPath, at: .bottom, animated: animate)
        }
    }
    
    func getIndexPathForLastItem()->(NSIndexPath){
        var  indexPath:NSIndexPath = NSIndexPath.init(row: 0, section: 0);
        let numberOfSections: Int = self.tableView.numberOfSections
        if numberOfSections > 0 {
            let numberOfRows: Int = self.tableView.numberOfRows(inSection: numberOfSections - 1)
            if numberOfRows > 0 {
                indexPath = NSIndexPath(row: numberOfRows - 1, section: numberOfSections - 1)
                
            }
        }
        return indexPath
    }
    
    func textLinkDetection(textLabel:KREAttributedLabel) {
        textLabel.detectionBlock = {(hotword, string) in
            switch hotword {
            case KREAttributedHotWordMention:
                break
            case KREAttributedHotWordHashtag:
                break
            case KREAttributedHotWordLink:
                let url: URL = URL(string: string!)!
                let webViewController: TOWebViewController = TOWebViewController(url: url)
                let webNavigationController: UINavigationController = UINavigationController(rootViewController: webViewController)
                webNavigationController.tabBarItem.title = "Bots"
                
                self.present(webNavigationController, animated: true, completion: {
                    
                })
                break
            case KREAttributedHotWordPhoneNumber:
                break
            case KREAttributedHotWordUserDefined:
                break
            case KREAttributedHotWordPlainText:
                break
            default:
                break
            }
        }

    }
    
    func launchWebViewWithURLLink(urlString:String)  {
        let url: URL = URL(string: urlString)!
        let webViewController: TOWebViewController = TOWebViewController(url: url)
        let webNavigationController: UINavigationController = UINavigationController(rootViewController: webViewController)
        webNavigationController.tabBarItem.title = "Bots"
        
        self.present(webNavigationController, animated: true, completion: {
            
        })

    }
    
    func clearAssociateObjects()  {
        for message in (fetchedResultsController?.fetchedObjects)! {
            let messageObject: KREMessage = message as! KREMessage
            messageObject.showMore = false
        }

    }
    // MARK:- deinit
    deinit {
        
    }
}
