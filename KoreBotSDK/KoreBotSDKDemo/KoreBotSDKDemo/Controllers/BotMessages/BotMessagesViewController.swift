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

enum MessageThreadHeaderType : Int {
    case None = 1, Sender = 2, Date = 3, SenderAndDate = 4
}

class BotMessagesViewController : UITableViewController {

    var sectionedThread: SectionedThread!
    var thread: Thread! {
        didSet {
            self.sectionedThread = SectionedThread.sectionedThread(self.thread)

            self.tableView.alpha = 0
            
            UIView.animateWithDuration(0, animations: {
                self.tableView.reloadData()
            }) { (completion) in
                self.scrollToBottom()
                self.tableView.alpha = 1
            }
        }
    }
    
    let startingViewImageIndex: Int! = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 200

        self.tableView.separatorStyle = .None

        self.tableView.registerClass(TextBubbleCell.self, forCellReuseIdentifier:"TextBubbleCell")
        self.tableView.registerClass(ImageBubbleCell.self, forCellReuseIdentifier:"ImageBubbleCell")
        self.tableView.registerClass(MessageBubbleCell.self, forCellReuseIdentifier:"MessageBubbleCell")
    }


    func scrollToBottom() {
        let lastSection: Int = self.sectionedThread.sections.count - 1
        if (lastSection >= 0) {
            let threadSection: ThreadSection = self.sectionedThread.sections[lastSection]
            
            let lastRow: Int = threadSection.groups.count - 1
//            if (lastRow > 0) {
                let indexPath: NSIndexPath = NSIndexPath(forRow:lastRow, inSection:lastSection)
                self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Bottom, animated: false)
//            }
        }
    }
    
    // MARK: UITable view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.sectionedThread.sections.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let threadSection: ThreadSection = self.sectionedThread.sections[section]
        return threadSection.groups.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let threadSection: ThreadSection = self.sectionedThread.sections[indexPath.section]
        let componentGroup: ComponentGroup = threadSection.groups[indexPath.row] as! ComponentGroup
        
        let maskType: BubbleMaskType!
        
        if (threadSection.groups.count == 1) {
            maskType = .Full
        } else if (indexPath.row == 0) {
            maskType = .Top
        } else if (indexPath.row == threadSection.groups.count - 1) {
            maskType = .Bottom
        } else {
            maskType = .Middle
        }
        
        var cellIdentifier: String!
        switch (componentGroup.componentKind()) {
        case .Text:
            cellIdentifier = "TextBubbleCell"
            break
            
        case .Image:
            cellIdentifier = "ImageBubbleCell"
            break
            
        case .Unknown:
            cellIdentifier = "MessageBubbleCell"
            break
        }
        
        let cell: MessageBubbleCell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! MessageBubbleCell
        
        cell.configureWithComponentGroup(componentGroup, maskType:maskType)
        
        switch (cell.bubbleView.bubbleType!) {
        case .Text:
            let bubbleView: TextBubbleView = cell.bubbleView as! TextBubbleView
            
            bubbleView.textLabel.customize { label in
                label.handleURLTap({ (url) in
                    let webViewController: TOWebViewController = TOWebViewController(URL: url)
                    let webNavigationController: UINavigationController = UINavigationController(rootViewController: webViewController)
                    webNavigationController.tabBarItem.title = "Bots"
                    
                    self.presentViewController(webNavigationController, animated: true, completion: {
                        
                    })
                })
                label.handleMentionTap({ (mention) in
                    
                })
                label.handleHashtagTap({ (hashtag) in
                    
                })
            }
            break
        case .Image:
            cell.didSelectComponentAtIndex = { (sender, index) in
                
            }
            break
        default:
            cell.didSelectComponentAtIndex = nil
            break
        }
        
        return cell
    }

    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.min
    }

    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.min
    }
}