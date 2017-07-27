//
//  ChatMessagesViewController.swift
//  KoreBotSDKDemo
//
//  Created by Anoop Dhiman on 26/07/17.
//  Copyright © 2017 Kore. All rights reserved.
//

import UIKit
import KoreBotSDK
import KoreWidgets
import SpeechToText
import TOWebViewController
import AVFoundation

class ChatMessagesViewController: UIViewController, BotMessagesViewDelegate, ComposeBarViewDelegate, KREGrowingTextViewDelegate {
    
    // MARK: properties
    weak var thread: KREThread!
    weak var botClient: BotClient!
    var tapToDismissGestureRecognizer: UITapGestureRecognizer!
    var isFirstTime: Bool = true
    
    @IBOutlet weak var threadTableView: BotMessagesTableView!
    @IBOutlet weak var composeBarContainerView: UIView!
    @IBOutlet weak var quickSelectContainerView: UIView!
    
    @IBOutlet weak var quickSelectContainerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    var composeBar: ComposeBarView!
    var audioComposer: AudioComposer!
    var quickReplyView: KREQuickSelectView!

    let sttClient: STTClient = STTClient()
    var speechSynthesizer: AVSpeechSynthesizer? = nil
    
    // MARK: init
    init(thread: KREThread!) {
        super.init(nibName: "ChatMessagesViewController", bundle: nil)
        self.thread = thread
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action:  #selector(ChatMessagesViewController.cancel(_:)))
        
        //Initialize elements
        
        self.threadTableView.thread = self.thread
        self.threadTableView.viewDelegate = self
        
        self.configureComposeBar()
        self.configureAudioComposer()
        self.configureQuickReplyView()
        self.configureBotClient()
        
        isSpeakingEnabled = false
        self.speechSynthesizer = AVSpeechSynthesizer()
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.addNotifications()
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.isFirstTime = false
    }
    
    override open func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.removeNotifications()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillLayoutSubviews() {
        NSLog("viewWillLayoutSubviews")
        super.viewWillLayoutSubviews()
        if self.isFirstTime {
            self.threadTableView.scrollToBottom(animated: false)
        }
    }
    
    //MARK:- deinit
    deinit {
        NSLog("ChatMessagesViewController dealloc")
        self.thread = nil
        self.composeBar = nil
        self.tapToDismissGestureRecognizer = nil
    }
    
    //MARK:- removing refernces to elements
    func prepareForDeinit(){
        if(self.botClient != nil){
            self.botClient.disconnect()
        }
        self.botClient = nil
        
        self.composeBar.growingTextView.viewDelegate = nil
        self.composeBar.delegate = nil
        
        self.threadTableView.prepareForDeinit()
        self.threadTableView.viewDelegate = nil
        self.threadTableView.thread = nil
    }
    
    // MARK: cancel
    func cancel(_ sender: AnyObject) {
        self.prepareForDeinit()
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: configuring views
    
    func configureComposeBar() {
        self.composeBar = ComposeBarView()
        self.composeBar.translatesAutoresizingMaskIntoConstraints = false
        self.composeBar.growingTextView.viewDelegate = self
        self.composeBar.delegate = self
        self.composeBarContainerView.addSubview(self.composeBar!)
        
        self.composeBarContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[composeBar]|", options:[], metrics:nil, views:["composeBar" : self.composeBar!]))
        self.composeBarContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[composeBar]|", options:[], metrics:nil, views:["composeBar" : self.composeBar!]))
    }
    
    func configureAudioComposer()  {
        self.audioComposer = Bundle.main.loadNibNamed("AudioComposer", owner: self, options: nil)![0] as? AudioComposer
        self.audioComposer.translatesAutoresizingMaskIntoConstraints = false
        self.composeBarContainerView.addSubview(self.audioComposer!)
        self.audioComposer.isHidden = true;
        
        self.audioComposer.sendButtonAction = { [weak self] (composeBar, message) in
            self?.sendMessage(message!)
        }
        if(self.botClient != nil){
            self.audioComposer.identity = self.botClient.userInfoModel.identity
        }
        
        self.audioComposer.cancelledSpeechToText = {
            self.audioComposer.isHidden = true;
            self.composeBar.isHidden = false;
            
            self.composeBarContainerView.removeConstraints(self.composeBarContainerView.constraints)
            self.composeBarContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[composeBar]|", options:[], metrics:nil, views:["composeBar" : self.composeBar!]))
            self.composeBarContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[composeBar]|", options:[], metrics:nil, views:["composeBar" : self.composeBar!]))
            
            UIView.animate(withDuration: 0.25, animations: {
                self.view.layoutIfNeeded()
            }, completion: { (completion) in
                
            })
            
            self.quickReplyView.isHidden = false;
        }
        
        self.audioComposer.keyBoardActivated  = { (composedMessage) in
            self.composeBar.growingTextView.textView.text = composedMessage! as String
            self.composeBar.valueChanged()
        }
        self.audioComposer.showCursorForSpeechDone = { [weak self]() in
            _ = self?.composeBar.becomeFirstResponder()
        }
        
        self.audioComposer.voiceRecordingStarted = { [weak self] (composeBar) in
            let authInfo = self?.botClient.authInfoModel
            let authToken: String = String(format: "%@ %@", authInfo!.tokenType!, authInfo!.accessToken!)
            let identity = self?.botClient.userInfoModel.identity
            self?.sttClient.initialize(serverUrl: ServerConfigs.BOT_SPEECH_SERVER, authToken: authToken, identity: identity!)
            self?.sttClient.onReceiveMessage = composeBar?.onReceiveMessage(dataDictionary:)
        }
        self.audioComposer.voiceRecordingStopped = {  [weak self] (composeBar) in
            self?.sttClient.stopAudioQueueRecording()
            self?.sttClient.onReceiveMessage = nil
        }
        self.audioComposer.getAudioPeakOutputPower = { [weak self]() in
            if self?.sttClient.audioQueueRecorder != nil {
                self?.sttClient.audioQueueRecorder.updateMeters()
                return (self?.sttClient.audioQueueRecorder.peakPower(forChannel: 0))!
            }
            return 0.0
        }
    }
    
    func configureQuickReplyView() {
        self.quickReplyView = KREQuickSelectView()
        self.quickReplyView.translatesAutoresizingMaskIntoConstraints = false
        self.quickSelectContainerView.addSubview(self.quickReplyView)
        
        self.quickSelectContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[quickReplyView]|", options:[], metrics:nil, views:["quickReplyView" : self.quickReplyView]))
        self.quickSelectContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[quickReplyView(60)]", options:[], metrics:nil, views:["quickReplyView" : self.quickReplyView]))
        
        self.quickReplyView.sendQuickReplyAction = { [weak self] (text) in
            self?.sendTextMessage(text: text!)
        }
    }
    
    func configureBotClient() {
        if(botClient != nil){
            // events
            botClient.connectionWillOpen = { () in
                
            }
            
            botClient.connectionDidOpen = { () in
                
            }
            
            botClient.onConnectionError = { (error) in
                
            }
            
            botClient.onMessage = { [weak self] (object) in
                self?.onReceiveMessage(object: object)
            }
            
            botClient.onMessageAck = { (ack) in
                
            }
            
            botClient.connectionDidClose = { (code) in
                
            }
            
            botClient.connectionDidEnd = { (code, reason, error) in
                
            }
        }
    }
    
    func onReceiveMessage(object: BotMessageModel?) {
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
            let cInfo: NSDictionary = messageObject!.cInfo != nil ? messageObject!.cInfo! : [:]
            let cInfoBody: String = cInfo["body"] != nil ? cInfo["body"] as! String : ""
            
            if (componentModel.type == "text") {
                self.showTypingStatusForBotsAction()
                
                let payload: NSDictionary = componentModel.payload! as! NSDictionary
                let text: NSString = payload["text"] as! NSString
                let textComponent: TextComponent = TextComponent()
                textComponent.text = text
                
                message.addComponent(textComponent)
            } else if (componentModel.type == "template") {
                let payload: NSDictionary = componentModel.payload! as! NSDictionary
                let type: String = payload["type"] as! String
                if(type == "template"){
                    let dictionary: NSDictionary = payload["payload"] as! NSDictionary
                    let templateType: String = dictionary["template_type"] as! String
                    
                    if (templateType == "quick_replies") {
                        let quickRepliesComponent: QuickRepliesComponent = QuickRepliesComponent()
                        quickRepliesComponent.payload = Utilities.stringFromJSONObject(object: dictionary)
                        
                        message.addComponent(quickRepliesComponent)
                    } else if (templateType == "button") {
                        self.showTypingStatusForBotsAction()
                        
                        let optionsComponent: OptionsComponent = OptionsComponent()
                        optionsComponent.payload = Utilities.stringFromJSONObject(object: dictionary)
                        
                        message.addComponent(optionsComponent)
                    }else if (templateType == "list") {
                        self.showTypingStatusForBotsAction()
                        
                        let optionsComponent: ListComponent = ListComponent()
                        optionsComponent.payload = Utilities.stringFromJSONObject(object: dictionary)
                        
                        message.addComponent(optionsComponent)
                    }else if (templateType == "carousel") {
                        self.showTypingStatusForBotsAction()
                        
                        let carouselComponent: CarouselComponent = CarouselComponent()
                        carouselComponent.payload = Utilities.stringFromJSONObject(object: dictionary)
                        
                        message.addComponent(carouselComponent)
                    }
                }else if(type == "error"){
                    self.showTypingStatusForBotsAction()
                    
                    let dictionary: NSDictionary = payload["payload"] as! NSDictionary
                    let errorComponent: ErrorComponent = ErrorComponent()
                    errorComponent.payload = Utilities.stringFromJSONObject(object: dictionary)
                    
                    message.addComponent(errorComponent)
                }
            }
            
            if (message.components.count > 0) {
                let dataStoreManager: DataStoreManager = DataStoreManager.sharedManager
                dataStoreManager.createNewMessageIn(thread: self.thread, message: message, completionBlock: { (success) in
                })
                NotificationCenter.default.post(name: Notification.Name(startSpeakingNotification), object: cInfoBody)
            }
        }
    }
    
    // MARK: notifications
    func addNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(ChatMessagesViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ChatMessagesViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ChatMessagesViewController.keyboardDidShow(_:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ChatMessagesViewController.keyboardDidHide(_:)), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ChatMessagesViewController.startSpeaking), name: NSNotification.Name(rawValue: startSpeakingNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ChatMessagesViewController.stopSpeaking), name: NSNotification.Name(rawValue: stopSpeakingNotification), object: nil)
    }
    
    func removeNotifications() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardDidHide, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: startSpeakingNotification), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: stopSpeakingNotification), object: nil)
    }
    
    // MARK: notification handlers
    func keyboardWillShow(_ notification: Notification) {
        let keyboardUserInfo: NSDictionary = NSDictionary(dictionary: (notification as NSNotification).userInfo!)
        let keyboardFrameEnd: CGRect = ((keyboardUserInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue?)!.cgRectValue)
        let options = UIViewAnimationOptions(rawValue: UInt((keyboardUserInfo[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).intValue << 16))
        let durationValue = keyboardUserInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber
        let duration = durationValue.doubleValue
        
        self.bottomConstraint.constant = keyboardFrameEnd.size.height
        UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
            self.view.layoutIfNeeded()
            self.threadTableView.scrollWithOffset(keyboardFrameEnd.size.height, animated: false)
        }, completion: { (Bool) in
            
        })
    }
    
    func keyboardWillHide(_ notification: Notification) {
        let keyboardUserInfo: NSDictionary = NSDictionary(dictionary: (notification as NSNotification).userInfo!)
        let keyboardFrameEnd: CGRect = ((keyboardUserInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue?)!.cgRectValue)
        let durationValue = keyboardUserInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber
        let duration = durationValue.doubleValue
        let options = UIViewAnimationOptions(rawValue: UInt((keyboardUserInfo[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).intValue << 16))
        
        self.bottomConstraint.constant = 0
        UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
            self.view.layoutIfNeeded()
            self.threadTableView.scrollWithOffset(-keyboardFrameEnd.size.height, animated: false)
        }, completion: { (Bool) in
            
        })
    }
    
    func keyboardDidShow(_ notification: Notification) {
        if (self.tapToDismissGestureRecognizer == nil) {
            self.tapToDismissGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(ChatMessagesViewController.dismissKeyboard(_:)))
            self.threadTableView.addGestureRecognizer(tapToDismissGestureRecognizer)
        }
    }
    
    func keyboardDidHide(_ notification: Notification) {
        if (self.tapToDismissGestureRecognizer != nil) {
            self.threadTableView.removeGestureRecognizer(tapToDismissGestureRecognizer)
            self.tapToDismissGestureRecognizer = nil
        }
    }
    
    func dismissKeyboard(_ gesture: UITapGestureRecognizer) {
        if (self.composeBar.isFirstResponder) {
            _ = self.composeBar.resignFirstResponder()
        }
    }
    
    // MARK: Helper functions
    
    func sendMessage(_ message:Message){
        NotificationCenter.default.post(name: Notification.Name(stopSpeakingNotification), object: nil)
        let composedMessage: Message = message
        if (composedMessage.components.count > 0) {
            let dataStoreManager: DataStoreManager = DataStoreManager.sharedManager
            dataStoreManager.createNewMessageIn(thread: self.thread, message: composedMessage, completionBlock: { (success) in
                let textComponent: TextComponent = composedMessage.components[0] as! TextComponent
                let text: String = textComponent.text as String
                if(self.botClient != nil){
                    self.botClient.sendMessage(text, options: [] as AnyObject)
                }
                self.textMessageSent()
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
    
    func textMessageSent() {
        self.composeBar.clear()
        self.threadTableView.scrollToBottom(animated: true)
    }
    
    func speechToTextButtonAction() {
        self.quickReplyView.isHidden = true;
        _ = self.composeBar.resignFirstResponder()
        self.composeBar.isHidden = true;
        self.audioComposer.animateBGView.isHidden = true;
        self.audioComposer.cancelButton.isHidden = true;
        self.composeBarContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[audioComposer]|", options:[], metrics:nil, views:["audioComposer" : self.audioComposer!]))
        self.composeBarContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[audioComposer]|", options:[], metrics:nil, views:["audioComposer" : self.audioComposer!]))
        UIView.animate(withDuration: 0.25, animations: {
            self.audioComposer.isHidden = false;
            self.audioComposer.triggerAudioAnimation(radius: 25);
            self.view.layoutIfNeeded()
        }, completion: { (completion) in
            self.audioComposer.animateBGView.isHidden = false;
            self.audioComposer.cancelButton.isHidden = false;
        })
    }
    
    // MARK: BotMessagesDelegate methods
    func optionsButtonTapAction(text: String) {
        self.sendTextMessage(text: text)
    }
    
    func linkButtonTapAction(urlString: String) {
        if (urlString.characters.count > 0) {
            let url: URL = URL(string: urlString)!
            let webViewController: TOWebViewController = TOWebViewController(url: url)
            let webNavigationController: UINavigationController = UINavigationController(rootViewController: webViewController)
            webNavigationController.tabBarItem.title = "Bots"
            self.present(webNavigationController, animated: true, completion:nil)
        }
    }
    
    func populateQuickReplyCards(with message: KREMessage?) {
        if (message?.templateType == 5) {
            let component: KREComponent = message!.components![0] as! KREComponent
            if (!component.isKind(of: KREComponent.self)) {
                return;
            }
            if ((component.componentDesc) != nil) {
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
                
                self.updateQuickSelectViewConstraints()
            }
        } else if(message != nil) {
            self.closeQuickSelectViewConstraints()
        }
    }
    
    func closeQuickReplyCards(){
        self.closeQuickSelectViewConstraints()
    }
    
    func updateQuickSelectViewConstraints() {
        if self.quickSelectContainerHeightConstraint.constant == 60.0 {return}
        
        var contentInset = self.threadTableView.contentInset
        contentInset.bottom = 60
        self.threadTableView.contentInset = contentInset
        self.quickSelectContainerHeightConstraint.constant = 60.0
        
        UIView.animate(withDuration: 0.25, delay: 0.05, options: [], animations: {
            self.view.layoutIfNeeded()
        }) { (Bool) in
            
        }
    }
    
    func closeQuickSelectViewConstraints() {
        if self.quickSelectContainerHeightConstraint.constant == 0.0 {return}

        var contentInset = self.threadTableView.contentInset
        contentInset.bottom = 0
        self.threadTableView.contentInset = contentInset
        self.quickSelectContainerHeightConstraint.constant = 0.0
        
        UIView.animate(withDuration: 0.25, delay: 0.0, options: [], animations: {
            self.view.layoutIfNeeded()
        }) { (Bool) in
            
        }
    }
    
    // MARK: ComposeBarViewDelegate methods
    
    func composeBarView(_: ComposeBarView, sendButtonAction text: String) {
        self.sendTextMessage(text: text)
    }
    
    func composeBarViewSpeechToTextButtonAction(_: ComposeBarView) {
        self.sttClient.checkAudioRecordPermission(block: { [weak self] in
            self?.speechToTextButtonAction()
        })
    }
    
    // MARK: KREGrowingTextViewDelegate methods
    
    func growingTextView(_: KREGrowingTextView, changingHeight height: CGFloat, animate: Bool) {
        UIView.animate(withDuration: animate ? 0.25: 0.0) {
            self.view.layoutIfNeeded()
            self.threadTableView.scrollWithOffset(height, animated: false)
        }
    }
    
    func growingTextView(_: KREGrowingTextView, willChangeHeight height: CGFloat) {
        
    }
    
    func growingTextView(_: KREGrowingTextView, didChangeHeight height: CGFloat) {
        
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
    
    // MARK: show tying status view
    func showTypingStatusForBotsAction() {
//        let botId:String = "u-40d2bdc2-822a-51a2-bdcd-95bdf48331c9";
//        let info:NSMutableDictionary = NSMutableDictionary.init()
//        info.setValue(botId, forKey: "botId");
//        info.setValue("kora", forKey: "imageName");
//        
//        self.typingStatusView?.addTypingStatus(forContact: info, forTimeInterval: 2.0)
//        self.view.bringSubview(toFront: self.typingStatusView!)
    }
}
