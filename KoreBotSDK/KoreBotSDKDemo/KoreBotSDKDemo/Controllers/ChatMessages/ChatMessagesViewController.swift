//
//  ChatMessagesViewController.swift
//  KoreBotSDKDemo
//
//  Created by developer@kore.com on 09/05/16.
//  Copyright © 2016 Kore Inc. All rights reserved.
//

import Foundation
import UIKit
import KoreBotSDK
import AFNetworking
import KoreWidgets
import KoreTextParser
import SpeechToText
import AVFoundation

enum ComposeMode : Int {
    case thread = 1, chat = 2, email = 3, kora = 4
}

enum QuickSelectMode : Int  {
    case off = 1, slashCommand = 2, atMention = 3, botCommand = 4
}

open class ChatMessagesViewController : UIViewController,BotMessagesDelegate {
    
    // MARK: init
    init(thread: KREThread!) {
        super.init(nibName: "ChatMessagesViewController", bundle: nil)
        self.thread = thread
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: "ChatMessagesViewController", bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: properties
    var thread: KREThread! = nil
    var composeMode: ComposeMode = .kora

    @IBOutlet weak var composeBarContainer: UIView!
    @IBOutlet weak var threadContentView: UIView!
    @IBOutlet weak var quickSelectContentView: UIView!
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var quickSelectHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var quickSelectHorizontalLineHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!

    var markdownParser: MarkdownParser! = nil
    var quickReplyView: KREQuickSelectView! = nil
    var threadTableViewController: BotMessagesViewController!
    var composeBar: MessageComposeBar!
    var audioComposer: AudioComposer!
    var tapToDismissGestureRecognizer: UITapGestureRecognizer!
    var disableKeyboardAdjustmentAnimationDuration: Bool = false
    var isSpeechToTextActive: Bool = false
    var typingStatusView:KRETypingStatusView?
    var speechSynthesizer: AVSpeechSynthesizer? = nil
    
    var botClient: BotClient! {
        didSet {
            if(botClient != nil){
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
                    } else {
                        message.sentDate = Date()
                    }
                    
                    if (object?.iconUrl != nil) {
                        message.iconUrl = object?.iconUrl
                    }
                    
                    let messageObject = ((object?.messages.count)! > 0) ? (object?.messages[0]) : nil
                    if (messageObject?.component == nil) {
                        
                    } else {
                        let componentModel: ComponentModel = messageObject!.component!
                        let cInfo: NSDictionary = messageObject!.cInfo!
                        let cInfoBody: NSString = cInfo["body"] as! NSString
                        
                        if (componentModel.type == "text") {
                            self?.showTypingStatusForBotsAction()
                            
                            let payload: NSDictionary = componentModel.payload! as! NSDictionary
                            let text: NSString = payload["text"] as! NSString
                            let textComponent: TextComponent = TextComponent()
                            textComponent.text = text
                            textComponent.cInfo = cInfoBody
                            
                            message.addComponent(textComponent)
                        } else if (componentModel.type == "template") {
                            let payload: NSDictionary = componentModel.payload! as! NSDictionary
                            let dictionary: NSDictionary = payload["payload"] as! NSDictionary
                            let templateType: String = dictionary["template_type"] as! String
                            
                            if (templateType == "quick_replies") {
                                let quickRepliesComponent: QuickRepliesComponent = QuickRepliesComponent()
                                quickRepliesComponent.payload = Utilities.stringFromJSONObject(object: dictionary)
                                quickRepliesComponent.cInfo = cInfoBody
                                
                                message.addComponent(quickRepliesComponent)
                            } else if (templateType == "button") {
                                self?.showTypingStatusForBotsAction()

                                let optionsComponent: OptionsComponent = OptionsComponent()
                                optionsComponent.payload = Utilities.stringFromJSONObject(object: dictionary)
                                optionsComponent.cInfo = cInfoBody
                                
                                message.addComponent(optionsComponent)
                            }else if (templateType == "list") {
                                self?.showTypingStatusForBotsAction()

                                let optionsComponent: ListComponent = ListComponent()
                                optionsComponent.payload = Utilities.stringFromJSONObject(object: dictionary)
                                optionsComponent.cInfo = cInfoBody
                                
                                message.addComponent(optionsComponent)
                            }else if (templateType == "carousel") {
                                self?.showTypingStatusForBotsAction()
                                
                                let carouselComponent: CarouselComponent = CarouselComponent()
                                carouselComponent.payload = Utilities.stringFromJSONObject(object: dictionary)
                                
                                message.addComponent(carouselComponent)
                            }
                        }

                        if (message.components.count > 0) {
                            let dataStoreManager: DataStoreManager = DataStoreManager.sharedManager
                            dataStoreManager.createNewMessageIn(thread: self!.thread, message: message, completionBlock: { (success) in
                                self?.populateQuickReplyCards(with: nil)
                            })
                            NotificationCenter.default.post(name: Notification.Name(startSpeakingNotification), object: cInfoBody)
                        }
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
    }
    
    // MARK: properties with observers
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
                
        self.initialize(.kora)
        self.typingStatusView = KRETypingStatusView.init()
        self.view.addSubview(self.typingStatusView!)
        self.typingStatusView?.isHidden = true
        
        self.speechSynthesizer = AVSpeechSynthesizer()
        NotificationCenter.default.addObserver(self, selector: #selector(self.startSpeaking), name: NSNotification.Name(rawValue: startSpeakingNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.stopSpeaking), name: NSNotification.Name(rawValue: stopSpeakingNotification), object: nil)
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.addKeyboardNotifications()
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override open func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.removeKeyboardNotifications()
        NotificationCenter.default.removeObserver(Any.self)
    }
    
    override open func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.typingStatusView?.frame = CGRect(x:0, y:self.composeBarContainer.frame.origin.y-40.0, width:self.view.bounds.size.width-50.0, height:40.0)
    }

    func viewLayoutUpdated() {
        self.threadTableViewController?.scrollToBottom(animated: true);
        self.typingStatusView?.frame = CGRect(x:0, y:self.composeBarContainer.frame.origin.y-40.0, width:self.view.bounds.size.width-50.0, height:40.0);
    }
    
    //MARK:- removing refernces to elements
    func prepareForDeinit(){
        self.composeBarContainer.subviews.forEach { subview in
            subview.removeFromSuperview()
        }
        self.composeBar = nil
        self.audioComposer = nil
        
        self.threadTableViewController?.clearAssociateObjects()
        self.threadTableViewController?.prepareForDeinit()
        self.threadTableViewController.willMove(toParentViewController: nil)
        self.threadTableViewController.view.removeFromSuperview()
        self.threadTableViewController.removeFromParentViewController()
        self.threadTableViewController.delegate = nil
        self.threadTableViewController.thread = nil
        self.threadTableViewController = nil
        
        self.quickReplyView.prepareForDeinit()
        self.quickReplyView.removeFromSuperview()
        self.quickReplyView = nil
        
        stopTTS()
        self.speechSynthesizer = nil
    }
    
    // MARK: cancel
    func cancel(_ sender: AnyObject) {
        if(self.botClient != nil){
            self.botClient.disconnect()
        }
        prepareForDeinit()
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: initialize
    func initialize(_ composeMode: ComposeMode) {
        self.composeMode = composeMode
        
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
        self.createAudioComposer()
        self.createThreadContent()
        self.createQuickReplyView()
        
        self.quickSelectHorizontalLineHeightConstraint.constant = 0.5
        self.quickSelectMode = QuickSelectMode.off
        
        if ((self.composeMode == .chat) || (composeMode == .email)) {
            self.composeBar.textView.becomeFirstResponder()
        }
    }
    
    func populateQuickReplyCards(with message: KREMessage?) {
        if (message?.templateType == 5) {
            let component: KREComponent = message!.components![0] as! KREComponent
            if (!component.isKind(of: KREComponent.self)) {
                return;
            }
            if ((component.componentDesc) != nil) {
                if (self.isSpeechToTextActive == false) {
                    self.updateQuickSelectViewConstraints()
                }
                
                let jsonObject: NSDictionary = Utilities.jsonObjectFromString(jsonString: component.componentDesc!) as! NSDictionary
                let quickReplies: Array<Dictionary<String, String>> = jsonObject["quick_replies"] as! Array<Dictionary<String, String>>
                var words: Array<Word> = Array<Word>()
                
                for dictionary in quickReplies {
                    let title: String = dictionary["title"] != nil ? dictionary["title"]! : ""
                    let payload: String = dictionary["payload"] != nil ? dictionary["payload"]! : ""
                    let imageURL: String = dictionary["image_url"] != nil ? dictionary["image_url"]! : ""
                    
                    let word: Word = Word(title: title, payload: payload, imageURL: imageURL)
                    words.append(word)
                }
                self.quickReplyView.setWordsList(words: words)
            }
        } else if(message != nil) {
            self.closeQuickSelectViewConstraints()
        }
    }
    
    func closeQuickReplyCards(){
        self.closeQuickSelectViewConstraints()
    }
    
    func createAddressBar() {
        
    }
    
    func createSubjectBar() {
        
    }
    
    func createAudioComposer()  {
        self.audioComposer = Bundle.main.loadNibNamed("AudioComposer", owner: self, options: nil)![0] as? AudioComposer
        self.audioComposer.translatesAutoresizingMaskIntoConstraints = false
        self.composeBarContainer.addSubview(self.audioComposer!)
        self.audioComposer.isHidden = true;
        
        self.audioComposer.viewWillResizeSubViews = { [weak self]() in
            self?.viewLayoutUpdated()
        }
        self.audioComposer.sendButtonAction = { [weak self] (composeBar, message) in
            self?.sendMessage(message!)
        }
        if(self.botClient != nil){
            self.audioComposer.identity = self.botClient.userInfoModel.identity
        }
        
        self.audioComposer.cancelledSpeechToText = {
            self.audioComposer.isHidden = true;
            self.composeBar.isHidden = false;
            UIView.animate(withDuration: 0.3, animations: {
                self.composeBarContainer.removeConstraints(self.composeBarContainer.constraints)
                self.composeBarContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[composeBar]|", options:[], metrics:nil, views:["composeBar" : self.composeBar!]))
                self.composeBarContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[composeBar]|", options:[], metrics:nil, views:["composeBar" : self.composeBar!]))
                self.view.layoutIfNeeded()
            }, completion: { (completion) in
           
            })
            
            self.quickReplyView.isHidden = false;
            self.isSpeechToTextActive = false;
        }
        
        self.audioComposer.keyBoardActivated  = { (composedMessage) in
            self.composeBar.textView.isUserInteractionEnabled = true;
            self.composeBar.textView.text = composedMessage! as String;
            self.composeBar.enableSendButton = (self.composeBar.textView.text.characters.count > 0)
            self.composeBar.textView.isEditable = true
            self.composeBar.valueChanged()
        }
        self.audioComposer.showCursorForSpeechDone = { [weak self]() in
            self?.composeBar.disabledSpeech()
        }
    }
    
    func createComposeBar() {
        self.composeBar = Bundle.main.loadNibNamed("MessageComposeBar", owner: self, options: nil)![0] as? MessageComposeBar
        self.composeBar.translatesAutoresizingMaskIntoConstraints = false
        self.composeBar.speechToTextButtonActionTriggered = {
            self.isSpeechToTextActive = true;
            self.quickReplyView.isHidden = true;
            self.quickSelectMode = QuickSelectMode.off
            self.composeBar.textView.resignFirstResponder()
            self.composeBar.isHidden = true;
            self.audioComposer.animateBGView.isHidden = true;
            self.audioComposer.cancelButton.isHidden = true;
            UIView.animate(withDuration: 0.3, animations: {
                self.audioComposer.isHidden = false;
                self.audioComposer.triggerAudioAnimation(radius: 25);
                self.composeBarContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[audioComposer]|", options:[], metrics:nil, views:["audioComposer" : self.audioComposer!]))
                self.composeBarContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[audioComposer]|", options:[], metrics:nil, views:["audioComposer" : self.audioComposer!]))
                self.view.layoutIfNeeded()
            }, completion: { (completion) in
                self.audioComposer.animateBGView.isHidden = false;
                self.audioComposer.cancelButton.isHidden = false;
                self.viewLayoutUpdated();
            })
        }
        
        self.composeBarContainer.addSubview(self.composeBar!)
        self.composeBarContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[composeBar]|", options:[], metrics:nil, views:["composeBar" : self.composeBar!]))
        self.composeBarContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[composeBar]|", options:[], metrics:nil, views:["composeBar" : self.composeBar!]))
        
        self.composeBar.ownerViewController = self
        
        self.composeBar.valueDidChange = { (composeBar) in
            
        }
        self.composeBar.viewWillResizeSubViews = { [weak self]() in
            self?.viewLayoutUpdated()
        }

        self.composeBar.sendButtonAction = { [weak self] (composeBar, message) in
            let composedMessage: Message = message!
            if (composedMessage.components.count > 0) {
                let dataStoreManager: DataStoreManager = DataStoreManager.sharedManager
                dataStoreManager.createNewMessageIn(thread: self!.thread, message: composedMessage, completionBlock: { (success) in
                    let textComponent: TextComponent = composedMessage.components[0] as! TextComponent
                    let text: String = textComponent.text as String
                    if(self?.botClient != nil){
                        self!.botClient.sendMessage(text, options: [] as AnyObject)
                    }
                    self!.composeBar.clear()
                })
            }
        }
    }
   
    func createThreadContent() {
        self.threadTableViewController = BotMessagesViewController(nibName: "BotMessagesViewController", bundle: nil)
        self.threadTableViewController.tableView.backgroundView = nil
        self.threadTableViewController.tableView.backgroundColor = UIColor.white
        self.threadTableViewController.delegate = self
        self.threadTableViewController.view.translatesAutoresizingMaskIntoConstraints = false
        self.addChildViewController(self.threadTableViewController)
        self.threadTableViewController.view.frame = self.threadContentView.bounds
        self.threadContentView.addSubview(threadTableViewController.view)
        self.threadTableViewController.didMove(toParentViewController: self)
        
        self.threadContentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[thread]|", options:[], metrics:nil, views:["thread" : self.threadTableViewController.tableView]))
        self.threadContentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[thread]|", options:[], metrics:nil, views:["thread" : self.threadTableViewController.tableView]))
        
        self.threadTableViewController.thread = self.thread
        self.threadTableViewController.tableView.contentInset = UIEdgeInsetsMake(10, 0, 10, 0);
    }
    
    func createQuickReplyView() {
        self.quickReplyView = KREQuickSelectView()
        self.quickReplyView.translatesAutoresizingMaskIntoConstraints = false
        self.quickSelectContentView.addSubview(self.quickReplyView)
    
        self.quickSelectContentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[quickReplyView]|", options:[], metrics:nil, views:["quickReplyView" : self.quickReplyView]))
        self.quickSelectContentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[quickReplyView]|", options:[], metrics:nil, views:["quickReplyView" : self.quickReplyView]))
        
        self.quickReplyView.sendQuickReplyAction = { [weak self] (text) in
            self?.closeQuickSelectViewConstraints()
            self?.sendTextMessage(text: text!)
        }
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
        if (self.composeBar != nil && self.composeBar.textView.autocorrectionType != autoCorrectionType) {
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
    
    func updateQuickSelectViewConstraints() {
        self.quickSelectHeightConstraint.constant = 60.0
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 5, options: [], animations: {
            self.view.layoutIfNeeded()
        }) { (Bool) in
            
        }
    }
    
    func closeQuickSelectViewConstraints() {
        self.quickSelectHeightConstraint.constant = 0.0
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 5, options: [], animations: {
            self.view.layoutIfNeeded()
        }) { (Bool) in
            
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
            self.threadTableViewController.scrollToBottom(animated: true)
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
    
    // MARK: Send Actions
    
    func sendMessage(_ message:Message){
        let composedMessage: Message = message
        
        NotificationCenter.default.post(name: Notification.Name(stopSpeakingNotification), object: nil)
        if (composedMessage.components.count > 0) {
            let dataStoreManager: DataStoreManager = DataStoreManager.sharedManager
            dataStoreManager.createNewMessageIn(thread: self.thread, message: composedMessage, completionBlock: { (success) in
                let textComponent: TextComponent = composedMessage.components[0] as! TextComponent
                let text: String = textComponent.text as String
                if(self.botClient != nil){
                    self.botClient.sendMessage(text, options: [] as AnyObject)
                    self.audioComposer.clear()
                }
            })
        }
    }
    
    func sendTextMessage(text:String) {
        let message: Message = Message()
        message.messageType = .default
        message.sentDate = Date()
        let textComponent: TextComponent = TextComponent()
        textComponent.text = text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) as NSString!
        message.addComponent(textComponent)
        self.sendMessage(message)
    }
    
    func optionsButtonTapAction(text: String) {
        self.sendTextMessage(text: text)
    }
    
    func showTypingStatusForBotsAction() {
        let botId:String = "u-40d2bdc2-822a-51a2-bdcd-95bdf48331c9";
        let info:NSMutableDictionary = NSMutableDictionary.init()
        info.setValue(botId, forKey: "botId");
        info.setValue("kora", forKey: "imageName");

        self.typingStatusView?.addTypingStatus(forContact: info, forTimeInterval: 2.0)
        self.view.bringSubview(toFront: self.typingStatusView!)
    }
    
    //MARK :- TTS Functionality
    func startSpeaking(notification:Notification) {
        if(isSpeakingEnabled){
            let string: String = notification.object! as! String
            let htmlStrippedString = KREUtilities.getHTMLStrippedString(from: string)
            let parsedString:String = KREUtilities.formatHTMLEscapedString(htmlStrippedString)
            self.readOutText(text: parsedString)
        }
    }
    
    func stopSpeaking(notification:Notification) {
        self.stopTTS()
    }
    
    func readOutText(text:String) {
        let string = text
        print("Reading text: ", text);
        let speechUtterance = AVSpeechUtterance(string: string)
        self.speechSynthesizer?.speak(speechUtterance)
    }
    
    func stopTTS(){
        if(self.speechSynthesizer?.isSpeaking)!{
            self.speechSynthesizer?.stopSpeaking(at: AVSpeechBoundary.immediate)
        }
    }
    
    //MARK:- deinit
    deinit {
        print("ChatMessagesViewController dealloc")
        NotificationCenter.default.removeObserver(Any.self)
        self.removeKeyboardNotifications()
        
        self.thread = nil
        self.markdownParser = nil
        self.quickReplyView = nil
        self.threadTableViewController = nil
        self.composeBar = nil
        self.audioComposer = nil
        self.tapToDismissGestureRecognizer = nil
        self.typingStatusView = nil
        self.speechSynthesizer = nil
        self.botClient = nil
        self.botInfoParameters = nil
    }
}
