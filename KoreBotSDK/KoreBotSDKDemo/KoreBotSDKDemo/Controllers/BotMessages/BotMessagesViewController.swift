//
//  BotMessagesViewController.swift
//  KoreBotSDKDemo
//
//  Created by developer@kore.com on 09/05/16.
//  Copyright © 2016 Kore Inc. All rights reserved.
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
    func populateQuickReplyCards(with message: KREMessage?)
    func closeQuickReplyCards()
}

class BotMessagesViewController : UITableViewController, KREFetchedResultsControllerDelegate {
    var fetchedResultsController: KREFetchedResultsController? = nil
    var messagesArray:NSArray!
    var delegate:BotMessagesDelegate?
    var shouldScrollToBottom:Bool = false
    var thread: KREThread! {
        didSet {
            if(self.thread != nil){
                let request = NSFetchRequest<KREMessage>(entityName: "KREMessage")
                request.predicate = NSPredicate(format: "thread.threadId == %@", self.thread.threadId!)
                request.sortDescriptors = [NSSortDescriptor(key: "sentOn", ascending: true)]
                
                let mainContext: NSManagedObjectContext = DataStoreManager.sharedManager.coreDataManager.mainContext
                fetchedResultsController = KREFetchedResultsController(fetchRequest: request as! NSFetchRequest<NSManagedObject>, managedObjectContext: mainContext, sectionNameKeyPath: nil, cacheName: nil)
                fetchedResultsController?.tableView = self.tableView
                fetchedResultsController?.kreDelegate = self
                try! fetchedResultsController? .performFetch()
                
                self.tableView.alpha = 0
                
                UIView.animate(withDuration: 0, animations: {
                    self.tableView.reloadData()
                }, completion: { (completion) in
                    self.scrollToBottom(animated: true)
                    self.tableView.alpha = 1
                })
            }
        }
    }

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
        self.tableView.register(QuickReplyBubbleCell.self, forCellReuseIdentifier:"QuickReplyBubbleCell")
        self.tableView.register(CarouselBubbleCell.self, forCellReuseIdentifier:"CarouselBubbleCell")

        if (self.tableView.contentSize.height > self.tableView.frame.size.height) {
            let point:CGPoint = CGPoint(x:0, y:self.tableView.contentSize.height - self.tableView.frame.size.height);
            self.tableView.setContentOffset(point, animated:true);
        }
    }
    
    //MARK:- removing refernces to elements
    func prepareForDeinit(){
        self.fetchedResultsController?.tableView = nil
        self.fetchedResultsController?.kreDelegate = nil
        self.fetchedResultsController = nil
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
                default:
                    cellIdentifier = "TextBubbleCell"
            }
        }

        let cell: MessageBubbleCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! MessageBubbleCell
        cell.configureWithComponents(message.components?.array as! Array<KREComponent>)
        
        switch (cell.bubbleView.bubbleType!) {
            case .text:
                self.delegate?.closeQuickReplyCards()
                let bubbleView: TextBubbleView = cell.bubbleView as! TextBubbleView
                bubbleView.onChange = { (reload) in
                    self.tableView?.reloadRows(at: [indexPath], with: .none)
                }
                self.textLinkDetection(textLabel: bubbleView.textLabel)
                break
            case .image:
                self.delegate?.closeQuickReplyCards()
                break
            case .options:
                self.delegate?.closeQuickReplyCards()
                
                let bubbleView: OptionsBubbleView = cell.bubbleView as! OptionsBubbleView
                self.textLinkDetection(textLabel: bubbleView.textLabel);
                bubbleView.optionsAction = {[weak self] (text) in
                    self?.delegate?.optionsButtonTapAction(text: text!)
                }
                bubbleView.linkAction = {[weak self] (text) in
                    self?.launchWebViewWithURLLink(urlString: text!)
                }
                
                cell.bubbleView.drawBorder = true
                break
            case .list:
                self.delegate?.closeQuickReplyCards()
                
                let bubbleView: ListBubbleView = cell.bubbleView as! ListBubbleView
                bubbleView.optionsAction = {[weak self] (text) in
                    self?.delegate?.optionsButtonTapAction(text: text!)
                }
                bubbleView.linkAction = {[weak self] (text) in
                    self?.launchWebViewWithURLLink(urlString: text!)
                }
                
                cell.bubbleView.drawBorder = true
                break
            case .quickReply:
                let lastIndexPath = getIndexPathForLastItem()
                if (lastIndexPath.isEqual(indexPath)) {
                    self.delegate?.populateQuickReplyCards(with: message)
                }
                break
            case .carousel:
                self.delegate?.closeQuickReplyCards()
                
                let bubbleView: CarouselBubbleView = cell.bubbleView as! CarouselBubbleView
                bubbleView.optionsAction = {[weak self] (text) in
                    self?.delegate?.optionsButtonTapAction(text: text!)
                }
                bubbleView.linkAction = {[weak self] (text) in
                    self?.launchWebViewWithURLLink(urlString: text!)
                }
                break
            default:
                break
        }
        return cell
    }
    
    // MARK: UITable view delegate source
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    // MARK:- KREFetchedResultsControllerDelegate methods
    func fetchedControllerDidChangeContent() {
        if (self.shouldScrollToBottom && !self.tableView.isDragging) {
            self.shouldScrollToBottom = false
            self.scrollToBottom(animated: true)
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
        if (indexPath.row > 0 || indexPath.section > 0) {
            self.tableView.scrollToRow(at: indexPath as IndexPath, at: .top, animated: animate)
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
                case KREAttributedHotWordLink:
                    self.launchWebViewWithURLLink(urlString: string!)
                    break
                default:
                    break
            }
        }
    }
    
    func launchWebViewWithURLLink(urlString:String)  {
        if (urlString.characters.count > 0) {
            let url: URL = URL(string: urlString)!
            let webViewController: TOWebViewController = TOWebViewController(url: url)
            let webNavigationController: UINavigationController = UINavigationController(rootViewController: webViewController)
            webNavigationController.tabBarItem.title = "Bots"
            
            self.present(webNavigationController, animated: true, completion:nil)
        }
    }
    
    func clearAssociateObjects()  {
        for message in (fetchedResultsController?.fetchedObjects)! {
            let messageObject: KREMessage = message as! KREMessage
            messageObject.showMore = false
        }
    }
    
    // MARK:- deinit
    deinit {
        self.fetchedResultsController = nil
        self.messagesArray = nil
        self.delegate = nil
        self.thread = nil
    }
}
