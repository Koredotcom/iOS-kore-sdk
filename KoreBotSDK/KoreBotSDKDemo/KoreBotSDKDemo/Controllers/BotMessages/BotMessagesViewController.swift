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
    case none = 1, sender = 2, date = 3, senderAndDate = 4
}

class BotMessagesViewController : UITableViewController {

    var sectionedThread: SectionedThread!
    var thread: Thread! {
        didSet {
            self.sectionedThread = SectionedThread.sectionedThread(self.thread)

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

        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 200

        self.tableView.separatorStyle = .none

        self.tableView.register(TextBubbleCell.self, forCellReuseIdentifier:"TextBubbleCell")
        self.tableView.register(ImageBubbleCell.self, forCellReuseIdentifier:"ImageBubbleCell")
        self.tableView.register(MessageBubbleCell.self, forCellReuseIdentifier:"MessageBubbleCell")
    }


    func scrollToBottom() {
        let lastSection: Int = self.sectionedThread.sections.count - 1
        if (lastSection >= 0) {
            let threadSection: ThreadSection = self.sectionedThread.sections[lastSection]
            
            let lastRow: Int = threadSection.groups.count - 1
//            if (lastRow > 0) {
                let indexPath: IndexPath = IndexPath(row:lastRow, section:lastSection)
                self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
//            }
        }
    }
    
    // MARK: UITable view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.sectionedThread.sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let threadSection: ThreadSection = self.sectionedThread.sections[section]
        return threadSection.groups.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let threadSection: ThreadSection = self.sectionedThread.sections[(indexPath as NSIndexPath).section]
        let componentGroup: ComponentGroup = threadSection.groups[(indexPath as NSIndexPath).row] as! ComponentGroup
        
        let maskType: BubbleMaskType!
        
        if (threadSection.groups.count == 1) {
            maskType = .full
        } else if ((indexPath as NSIndexPath).row == 0) {
            maskType = .top
        } else if ((indexPath as NSIndexPath).row == threadSection.groups.count - 1) {
            maskType = .bottom
        } else {
            maskType = .middle
        }
        
        var cellIdentifier: String!
        switch (componentGroup.componentKind()) {
        case .text:
            cellIdentifier = "TextBubbleCell"
            break
            
        case .image:
            cellIdentifier = "ImageBubbleCell"
            break
            
        case .unknown:
            cellIdentifier = "MessageBubbleCell"
            break
        }
        
        let cell: MessageBubbleCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! MessageBubbleCell
        
        cell.configureWithComponentGroup(componentGroup, maskType:maskType)
        
        switch (cell.bubbleView.bubbleType!) {
        case .text:
            let bubbleView: TextBubbleView = cell.bubbleView as! TextBubbleView
            bubbleView.textLabel.detectionBlock = {(hotword, string) in

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
            break
        case .image:
            cell.didSelectComponentAtIndex = { (sender, index) in
                
            }
            break
        default:
            cell.didSelectComponentAtIndex = nil
            break
        }
        
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
}
