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
    case thread = 1, chat = 2, email = 3, kora = 4
}

enum QuickSelectMode : Int  {
    case off = 1, slashCommand = 2, atMention = 3, botCommand = 4
}

open class ChatMessagesViewController : UIViewController {
    
    // MARK: properties
    var composeMode: ComposeMode = .kora {
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
    
    var botClient: BotClient! {
        didSet {
            // events
            botClient.connectionWillOpen = { () in
                
            }
            
            botClient.connectionDidOpen = { () in
                
            }
            
            botClient.onConnectionError = { (error) in
                
            }
            
            botClient.onMessage = { [weak self] (object) in
                let message: Message = Message()
                message.messageType = .reply
                if (object?.createdOn != nil) {
                    message.sentDate = object?.createdOn as Date!
                }
                
                if (object?.iconUrl != nil) {
                    message.iconUrl = object?.iconUrl
                }
                
                var currentGroup: ComponentGroup!
                let messageObject = object?.messages[0]
                if (messageObject?.component == nil) {
                    
                } else {
                    let componentModel: ComponentModel = messageObject!.component!
                    
                    let textComponent: TextComponent = TextComponent()
                    if (componentModel.body != nil) {
                        textComponent.text = componentModel.body as NSString!
                    }
                    message.addComponent(textComponent, currentGroup:&currentGroup)
                    
                    self!.thread.addMessage(message)
                    self!.threadTableViewController.thread = self!.thread
                }
            }
            
            botClient.onMessageAck = { (ack) in
                
            }
            
            botClient.connectionDidClose = { (code) in
                
            }
            
            botClient.connectionDidEnd = { (code, reason, error) in
                
            }
        }
    }
    
    // MARK: properties with observers
    var thread: Thread! = nil {
        didSet {
            self.threadTableViewController.thread = self.thread
        }
    }

    var botInfoParameters: NSDictionary! = nil {
        didSet {
            if (self.botInfoParameters["botInfo"] != nil) {
                let botInfo: NSDictionary = self.botInfoParameters["botInfo"] as! NSDictionary
                if (botInfo["chatBot"] != nil) {
                    self.title = botInfo["chatBot"] as? String
                }
            } else {
                self.title = "Kora"
            }
        }
    }
    var quickSelectMode: QuickSelectMode! {
        didSet {
            if (self.quickSelectMode == .off) {
                self.setAutoCorrectionType(UITextAutocorrectionType.default)
                self.quickSelectData = nil
                self.quickSelectHeightConstraint.constant = 0
                self.view.updateConstraintsIfNeeded()
            } else {
                self.setAutoCorrectionType(UITextAutocorrectionType.no)
            }
            
            self.view.setNeedsLayout()
        }
    }
    
    // MARK: view-controller life-cycle
    override open func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        self.edgesForExtendedLayout = UIRectEdge()
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action:  #selector(ChatMessagesViewController.cancel(_:)))
                
        self.quickSelectTableView.register(UITableViewCell.self, forCellReuseIdentifier: "MessageThreadCell")
        self.initialize(.kora, thread: Thread())
        
        self.setupBotClient()
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.addKeyboardNotifications()
    }
    
    override open func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.removeKeyboardNotifications()
    }
    
    // MARK: setup bot client
    func setupBotClient() {
        if self.botClient == nil {
            let token: String = self.botInfoParameters["authorization"] as! String
            let botInfo: NSDictionary = (self.botInfoParameters["botInfo"] as? NSDictionary)!
            let client: BotClient = BotClient(botInfoParameters: botInfo)
            client.connectAsAuthenticatedUser(token, success: { [weak self] (botClient) in
                self!.botClient = client
                }, failure: { (error) in
            })
        }
    }

    
    // MARK: cancel
    func cancel(_ sender: AnyObject) {
        self.botClient.disconnect()
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: initialize
    func initialize(_ composeMode: ComposeMode, thread: Thread) {
        self.composeMode = composeMode
        self.quickSelectTableView.register(UINib.init(nibName: "QuickSelectCommandCell", bundle: nil), forCellReuseIdentifier: "QuickSelectCommandCell")
        self.quickSelectTableView.register(UINib.init(nibName: "QuickSelectIdentityCell", bundle: nil), forCellReuseIdentifier:"QuickSelectIdentityCell")
        
        switch (composeMode) {
        case .thread:
            break
            
        case .kora:
            break
            
        default:
            self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.cancel, target: self, action: nil)
            
            self.createAddressBar()
            self.createSubjectBar()
            break
        }
        
        self.createComposeBar()
        self.createThreadContent()
        
        self.thread = thread

        
        self.quickSelectHorizontalLineHeightConstraint.constant = 0.5
        self.quickSelectTableView.rowHeight = 44
        
        self.quickSelectMode = QuickSelectMode.off
        
        if ((self.composeMode == .chat) || (composeMode == .email)) {
            self.composeBar.textView.becomeFirstResponder()
        }
    }
    
    func createAddressBar() {
        
    }
    
    func createSubjectBar() {
        
    }
    
    func createComposeBar() {
        self.composeBar = Bundle.main.loadNibNamed("MessageComposeBar", owner: self, options: nil)![0] as? MessageComposeBar
        self.composeBar.translatesAutoresizingMaskIntoConstraints = false
        
//        self.composeBar.isKora = self.composeMode == ComposeMode.Kora
        
        self.composeBarContainer.addSubview(self.composeBar!)
        self.composeBarContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[composeBar]|", options:[], metrics:nil, views:["composeBar" : self.composeBar!]))
        self.composeBarContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[composeBar]|", options:[], metrics:nil, views:["composeBar" : self.composeBar!]))
        
        self.composeBar.ownerViewController = self
        
        self.composeBar.valueDidChange = { (composeBar) in
            
        }
        self.composeBar.sendButtonAction = { [weak self] (composeBar, message) in
            let composedMessage: Message = message!
            if (composedMessage.groupedComponents.count > 0) {
                let group: ComponentGroup = composedMessage.groupedComponents[0] as! ComponentGroup
                if (group.components.count > 0) {
                    let textComponent: TextComponent = group.components[0] as! TextComponent
                    let text: String = textComponent.text as String
                    self!.botClient.sendMessage(text, options: [] as AnyObject)
                    if (self!.composeMode == .thread) {
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
        self.threadTableViewController.tableView.backgroundColor = UIColor.white

        
        self.addChildViewController(self.threadTableViewController)
        self.threadTableViewController.view.frame = self.threadContentView.bounds
        self.threadContentView.addSubview(threadTableViewController.view)
        
        self.threadContentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[thread]|", options:[], metrics:nil, views:["thread" : self.threadTableViewController.tableView]))
        
        self.threadContentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[thread]|", options:[], metrics:nil, views:["thread" : self.threadTableViewController.tableView]))
        self.threadTableViewController.didMove(toParentViewController: self)
    }

    func addKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(ChatMessagesViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ChatMessagesViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ChatMessagesViewController.keyboardDidShow(_:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ChatMessagesViewController.keyboardDidHide(_:)), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
    }

    func removeKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardDidHide, object: nil)
    }
    
    // MARK: helpers
    func setAutoCorrectionType(_ autoCorrectionType: UITextAutocorrectionType) {
        if (self.composeBar.textView.autocorrectionType != autoCorrectionType) {
            if (self.composeBar.textView.isFirstResponder) {
                
                self.disableKeyboardAdjustmentAnimationDuration = true
                
                UIView.animate(withDuration: 0, animations: {
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
    
    func dismissInputView(_ becomeFirstResponser: Bool) {
        self.dismiss(animated: true) { 
            
        }
        self.composeBar.resetKeyboard()
        
        if (becomeFirstResponser) {
            self.composeBar.textView.becomeFirstResponder()
        }
    }

    // MARK: notification handlers
    func keyboardWillShow(_ notification: Notification) {
        let keyboardUserInfo: NSDictionary = NSDictionary(dictionary: (notification as NSNotification).userInfo!)
        let keyboardFrameEnd: CGRect = ((keyboardUserInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue?)!.cgRectValue)
        let newFrame: CGRect = self.view.convert(keyboardFrameEnd, from: (UIApplication.shared.delegate as! AppDelegate).window)
        let options = UIViewAnimationOptions(rawValue: UInt((keyboardUserInfo[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).intValue << 16))
        let durationValue = keyboardUserInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber
        let duration = durationValue.doubleValue

        UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
            let c: CGFloat = self.view.frame.height - newFrame.origin.y
            self.bottomConstraint.constant = c
            self.view.layoutIfNeeded()
            }, completion: { (Bool) in
                
        })
    }

    func keyboardDidShow(_ notification: Notification) {
        if (self.tapToDismissGestureRecognizer != nil) {
            self.threadContentView.removeGestureRecognizer(self.tapToDismissGestureRecognizer) // in case we've already added one
        }
        self.tapToDismissGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(ChatMessagesViewController.dismissKeyboard(_:)))
        self.threadContentView.addGestureRecognizer(tapToDismissGestureRecognizer)
    }

    func keyboardDidHide(_ notification: Notification) {
        if (self.tapToDismissGestureRecognizer != nil) {
            self.threadContentView.removeGestureRecognizer(tapToDismissGestureRecognizer)
        }
        self.tapToDismissGestureRecognizer = nil
    }

    func dismissKeyboard(_ gesture: UITapGestureRecognizer) {
        if (self.composeBar.textView.isFirstResponder) {
            self.composeBar.textView.resignFirstResponder()
        }
    }

    func keyboardWillHide(_ notification: Notification) {
        if (!self.composeBar.isSwitchingKeyboards) {
            let keyboardUserInfo: NSDictionary = NSDictionary(dictionary: (notification as NSNotification).userInfo!)
            
            let durationValue = keyboardUserInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber
            var duration = durationValue.doubleValue
            let options = UIViewAnimationOptions(rawValue: UInt((keyboardUserInfo[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).intValue << 16))
            
            if (self.disableKeyboardAdjustmentAnimationDuration == true) {
                duration = 0.0
            }
            
            UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
                self.bottomConstraint.constant = 0
                self.view.layoutIfNeeded()
                }, completion: { (Bool) in
                    
            })
        }
    }
    
    // MARK: tableView dataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.quickSelectMode == QuickSelectMode.off) {
            return 0
        }
        
        return self.quickSelectData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "MessageThreadCell", for: indexPath)
        
        return cell
    }
}
