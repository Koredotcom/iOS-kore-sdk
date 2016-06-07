//
//  ChatMessagesViewController.swift
//  KoreBotSDKDemo
//
//  Created by Srinivas Vasadi on 09/05/16.
//  Copyright © 2016 Kore. All rights reserved.
//

import Foundation
import UIKit
import KoreBotSDK

enum ComposeMode : Int {
    case Thread = 1, Chat = 2, Email = 3, Kora = 4
}

enum QuickSelectMode : Int  {
    case Off = 1, SlashCommand = 2, AtMention = 3, BotCommand = 4
}

public class ChatMessagesViewController : UIViewController {
    
    // MARK: properties
    var composeMode: ComposeMode = .Kora {
        didSet {
            
        }
    }

    @IBOutlet weak var composeBarContainer: UIView!
    @IBOutlet weak var threadContentView: UIView!
    @IBOutlet weak var quickSelectContentView: UIView!
    @IBOutlet weak var quickSelectTableView: UITableView!
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var quickSelectHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var quickSelectHorizontalLineHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!

    var threadTableViewController: BotMessagesViewController!
    var composeBar: MessageComposeBar!
    var tapToDismissGestureRecognizer: UITapGestureRecognizer!
    var disableKeyboardAdjustmentAnimationDuration: Bool = false
    var quickSelectData: NSArray!
    
    var botClient: BotClient!
    
    // MARK: properties with observers
    var thread: Thread! = nil {
        didSet {
            self.threadTableViewController.thread = self.thread
        }
    }

    var botInfoParameters: NSDictionary! = nil {
        didSet {
            if (self.botInfoParameters["botInfo"]!["chatBot"] != nil) {
                self.title = self.botInfoParameters["botInfo"]!["chatBot"] as? String
            } else {
                self.title = "Kora"
            }
        }
    }
    var quickSelectMode: QuickSelectMode! {
        didSet {
            if (self.quickSelectMode == .Off) {
                self.setAutoCorrectionType(UITextAutocorrectionType.Default)
                self.quickSelectData = nil
                self.quickSelectHeightConstraint.constant = 0
                self.view.updateConstraintsIfNeeded()
            } else {
                self.setAutoCorrectionType(UITextAutocorrectionType.No)
            }
            
            self.view.setNeedsLayout()
        }
    }
    
    // MARK: view-controller life-cycle
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        self.edgesForExtendedLayout = .None
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action:  #selector(ChatMessagesViewController.cancel(_:)))
                
        self.quickSelectTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "MessageThreadCell")
        self.initialize(.Kora, thread: Thread())
        
        let token: String = self.botInfoParameters["authorization"] as! String
        let botInfo: NSDictionary = (self.botInfoParameters["botInfo"] as? NSDictionary)!
        self.botClient = BotClient(token: token, botInfoParameters: botInfo)
        self.botClient.rtmConnection({ (connection) in
            // events
            self.botClient.connectionWillOpen = { () in
                
            }
            
            self.botClient.connectionDidOpen = { () in
                
            }
            
            self.botClient.onConnectionError = { (error) in
                
            }

            self.botClient.onMessage = { [weak self] (object) in
                let message: Message = Message()
                message.messageType = .Reply
                message.sentDate = NSDate()
                
                var currentGroup: ComponentGroup!
                let messageObject = object.messages[0]
                
                if (messageObject.component == nil) {
                
                } else {
                    let componentModel: ComponentModel = messageObject.component!

                    let textComponent: TextComponent = TextComponent()
                    if (componentModel.body != nil) {
                        textComponent.text = componentModel.body
                    }
                    message.addComponent(textComponent, currentGroup:&currentGroup)
                    
                    self!.thread.addMessage(message)
                    self!.threadTableViewController.thread = self!.thread
                }
            }
            
            self.botClient.onMessageAck = { (ack) in
                
            }
            
            self.botClient.connectionDidClose = { (code) in
                
            }
            
            self.botClient.connectionDidEnd = { (code, reason, error) in
                
            }
            }, failure: { (error) in
                
        })
    }
    
    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.addKeyboardNotifications()
    }
    
    override public func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.removeKeyboardNotifications()
    }
    
    // MARK: cancel
    func cancel(sender: AnyObject) {
        self.botClient.disconnect()
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK: initialize
    func initialize(composeMode: ComposeMode, thread: Thread) {
        self.composeMode = composeMode
        self.quickSelectTableView.registerNib(UINib.init(nibName: "QuickSelectCommandCell", bundle: nil), forCellReuseIdentifier: "QuickSelectCommandCell")
        self.quickSelectTableView.registerNib(UINib.init(nibName: "QuickSelectIdentityCell", bundle: nil), forCellReuseIdentifier:"QuickSelectIdentityCell")
        
        switch (composeMode) {
        case .Thread:
            break
            
        case .Kora:
            break
            
        default:
            self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: nil)
            
            self.createAddressBar()
            self.createSubjectBar()
            break
        }
        
        self.createComposeBar()
        self.createThreadContent()
        
        self.thread = thread

        
        self.quickSelectHorizontalLineHeightConstraint.constant = 0.5
        self.quickSelectTableView.rowHeight = 44
        
        self.quickSelectMode = QuickSelectMode.Off
        
        if ((self.composeMode == .Chat) || (composeMode == .Email)) {
            self.composeBar.textView.becomeFirstResponder()
        }
    }
    
    func createAddressBar() {
        
    }
    
    func createSubjectBar() {
        
    }
    
    func createComposeBar() {
        self.composeBar = NSBundle.mainBundle().loadNibNamed("MessageComposeBar", owner: self, options: nil)[0] as? MessageComposeBar
        self.composeBar.translatesAutoresizingMaskIntoConstraints = false
        
//        self.composeBar.isKora = self.composeMode == ComposeMode.Kora
        
        self.composeBarContainer.addSubview(self.composeBar!)
        self.composeBarContainer.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[composeBar]|", options:[], metrics:nil, views:["composeBar" : self.composeBar!]))
        self.composeBarContainer.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[composeBar]|", options:[], metrics:nil, views:["composeBar" : self.composeBar!]))
        
        self.composeBar.ownerViewController = self
        
        self.composeBar.valueDidChange = { (composeBar: MessageComposeBar!) in
            
        }
        self.composeBar.sendButtonAction = { [weak self] (composeBar: MessageComposeBar!, composedMessage: Message!) in
            
            if (composedMessage.groupedComponents.count > 0) {
                let group: ComponentGroup = composedMessage.groupedComponents[0] as! ComponentGroup
                if (group.components.count > 0) {
                    let textComponent: TextComponent = group.components[0] as! TextComponent
                    let text: String = textComponent.text as String
                    self!.botClient.sendMessage(text, options: [])
                    if (self!.composeMode == .Thread) {
                        self!.composeBar.clear()
                        self!.thread.addMessage(composedMessage)
                        self!.threadTableViewController.thread = self!.thread
                    } else {
                        
                    }
                    self!.thread.addMessage(composedMessage)
                    self!.threadTableViewController.thread = self!.thread

                    
                    self!.composeBar.clear()
                }
            }
        }
        
    }

    func createThreadContent() {
        self.threadTableViewController = BotMessagesViewController(nibName: "BotMessagesViewController", bundle: nil)
        self.threadTableViewController.tableView.backgroundView = nil
        self.threadTableViewController.tableView.backgroundColor = UIColor.whiteColor()

        
        self.addChildViewController(self.threadTableViewController)
        self.threadTableViewController.view.frame = self.threadContentView.bounds
        self.threadContentView.addSubview(threadTableViewController.view)
        
        self.threadContentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[thread]|", options:[], metrics:nil, views:["thread" : self.threadTableViewController.tableView]))
        
        self.threadContentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[thread]|", options:[], metrics:nil, views:["thread" : self.threadTableViewController.tableView]))
        self.threadTableViewController.didMoveToParentViewController(self)
    }

    func addKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChatMessagesViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChatMessagesViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChatMessagesViewController.keyboardDidShow(_:)), name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChatMessagesViewController.keyboardDidHide(_:)), name: UIKeyboardDidHideNotification, object: nil)
    }

    func removeKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardDidHideNotification, object: nil)
    }
    
    // MARK: helpers
    func setAutoCorrectionType(autoCorrectionType: UITextAutocorrectionType) {
        if (self.composeBar.textView.autocorrectionType != autoCorrectionType) {
            if (self.composeBar.textView.isFirstResponder()) {
                
                self.disableKeyboardAdjustmentAnimationDuration = true
                
                UIView.animateWithDuration(0, animations: {
                    self.composeBar.textView.resignFirstResponder()
                    self.composeBar.textView.autocorrectionType = autoCorrectionType
                    self.composeBar.textView.becomeFirstResponder()
                    }, completion: { (Bool) in
                        self.disableKeyboardAdjustmentAnimationDuration = false
                })
            } else {
                self.composeBar.textView.autocorrectionType = autoCorrectionType
            }
        }
    }
    
    func dismissInputView(becomeFirstResponser: Bool) {
        self.dismissViewControllerAnimated(true) { 
            
        }
        self.composeBar.resetKeyboard()
        
        if (becomeFirstResponser) {
            self.composeBar.textView.becomeFirstResponder()
        }
    }

    // MARK: notification handlers
    func keyboardWillShow(notification: NSNotification) {
        let keyboardUserInfo: NSDictionary = NSDictionary(dictionary: notification.userInfo!)
        let keyboardFrameEnd: CGRect = (keyboardUserInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue())!
        let newFrame: CGRect = self.view.convertRect(keyboardFrameEnd, fromView: (UIApplication.sharedApplication().delegate as! AppDelegate).window)
        let options = UIViewAnimationOptions(rawValue: UInt((keyboardUserInfo[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).integerValue << 16))
        let durationValue = keyboardUserInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber
        let duration = durationValue.doubleValue

        UIView.animateWithDuration(duration, delay: 0, options: options, animations: {
            let c: CGFloat = CGRectGetHeight(self.view.frame) - newFrame.origin.y
            self.bottomConstraint.constant = c
            self.view.layoutIfNeeded()
            }, completion: { (Bool) in
                
        })
    }

    func keyboardDidShow(notification: NSNotification) {
        if (self.tapToDismissGestureRecognizer != nil) {
            self.threadContentView.removeGestureRecognizer(self.tapToDismissGestureRecognizer) // in case we've already added one
        }
        self.tapToDismissGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(ChatMessagesViewController.dismissKeyboard(_:)))
        self.threadContentView.addGestureRecognizer(tapToDismissGestureRecognizer)
    }

    func keyboardDidHide(notification: NSNotification) {
        if (self.tapToDismissGestureRecognizer != nil) {
            self.threadContentView.removeGestureRecognizer(tapToDismissGestureRecognizer)
        }
        self.tapToDismissGestureRecognizer = nil
    }

    func dismissKeyboard(gesture: UITapGestureRecognizer) {
        if (self.composeBar.textView.isFirstResponder()) {
            self.composeBar.textView.resignFirstResponder()
        }
    }

    func keyboardWillHide(notification: NSNotification) {
        if (!self.composeBar.isSwitchingKeyboards) {
            let keyboardUserInfo: NSDictionary = NSDictionary(dictionary: notification.userInfo!)
            
            let durationValue = keyboardUserInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber
            var duration = durationValue.doubleValue
            let options = UIViewAnimationOptions(rawValue: UInt((keyboardUserInfo[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).integerValue << 16))
            
            if (self.disableKeyboardAdjustmentAnimationDuration == true) {
                duration = 0.0
            }
            
            UIView.animateWithDuration(duration, delay: 0, options: options, animations: {
                self.bottomConstraint.constant = 0
                self.view.layoutIfNeeded()
                }, completion: { (Bool) in
                    
            })
        }
    }
    
    // MARK: tableView dataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.quickSelectMode == QuickSelectMode.Off) {
            return 0
        }
        
        return self.quickSelectData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("MessageThreadCell", forIndexPath: indexPath)
        
        return cell
    }
}


