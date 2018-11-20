//
//  ChatMessagesViewController.swift
//  KoreBotSDKDemo
//
//  Created by Anoop Dhiman on 26/07/17.
//  Copyright © 2017 Kore. All rights reserved.
//

import UIKit
import AVFoundation
import SafariServices

public protocol ChatMessagesViewControllerDelegate: class {
    func sendMessageToBot(with text: String?)
    func voiceRecordingStarted()
    func voiceRecordingStopped()
    func disconnectBot()
    func refreshButton(_ enable : Bool)
}

open class ChatMessagesViewController: UIViewController, BotMessagesViewDelegate, ComposeBarViewDelegate, KREGrowingTextViewDelegate {
    
    // MARK: - public properties
    public weak var messagesViewControllerDelegate: ChatMessagesViewControllerDelegate?

    // MARK: private properties
    var thread: KREThread?
    var tapToDismissGestureRecognizer: UITapGestureRecognizer!
    
    @IBOutlet weak public var threadContainerView: UIView!
    @IBOutlet weak public var quickSelectContainerView: UIView!
    @IBOutlet weak public var composeBarContainerView: UIView!
    @IBOutlet weak public var audioComposeContainerView: UIView!
    @IBOutlet weak var informationView: UIView!
    @IBOutlet weak public var menuButton: UIButton!
    
    @IBOutlet weak var quickSelectContainerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var informationViewHeightConstraint: NSLayoutConstraint!

    public var composeBarContainerHeightConstraint: NSLayoutConstraint!
    public var composeViewBottomConstraint: NSLayoutConstraint!
    public var audioComposeContainerHeightConstraint: NSLayoutConstraint!
    public var botMessagesView: BotMessagesView!
    public var composeView: ComposeBarView!
    public var audioComposeView: AudioComposeView!
    public var quickReplyView: KREQuickSelectView!
    public var pickerView: PickerSelectView!
    public var sessionEndView: SessionEndView!
    public var loaderView: LoaderView!
    public var typingStatusView: KRETypingStatusView!
    public var webViewController: InputTOWebViewController!
    public var speechSynthesizer: AVSpeechSynthesizer!
    public var hideComposeBar: Bool = false
    public var hideAudioComposerView: Bool = true
    public var informationLabel: UILabel!
    public var isSessionEndBtnClicked: Bool = false
    public var timer: Timer?
    
    // MARK: init
    public init(thread: KREThread?) {
        super.init(nibName: "ChatMessagesViewController", bundle: Bundle(for: ChatMessagesViewController.self))
        self.thread = thread
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        //Initialize elements
        self.configureThreadView()
        self.configureComposeBar()
        self.configureAudioComposer()
        self.configureQuickReplyView()
        self.configurePickerView()
        self.configureSessionEndView()
        self.configureTypingStatusView()
        self.configureSTTClient()
        self.configureBottomView() 
        self.configureInformationView()
        UserDefaults.standard.setSignifyBottomView(with: true)

        isSpeakingEnabled = UserDefaults.standard.getsignifyBotStatus()
        self.speechSynthesizer = AVSpeechSynthesizer()
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.addNotifications()
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override open func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.removeNotifications()
    }

    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override open func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    override open var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //MARK:- deinit
    deinit {
        self.thread = nil
        self.composeView = nil
        self.audioComposeView = nil
        self.botMessagesView = nil
        self.quickReplyView = nil
        self.typingStatusView = nil
        self.tapToDismissGestureRecognizer = nil
    }
    
    //MARK:- removing refernces to elements
    func prepareForDeinit(){
        self.deConfigureSTTClient()
        self.stopTTS()
        self.composeView.growingTextView.viewDelegate = nil
        self.composeView.delegate = nil
        self.audioComposeView.prepareForDeinit()
        self.botMessagesView.prepareForDeinit()
        self.botMessagesView.viewDelegate = nil
        self.quickReplyView.sendQuickReplyAction = nil
    }
    
    // MARK: cancel
    func cancel(_ sender: AnyObject) {
        self.prepareForDeinit()
        
        //Addition fade in animation
        let transition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionFade
        self.navigationController?.view.layer.add(transition, forKey: nil)
        
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: Menu Button Action
    @IBAction func menuButtonAction(_ sender: Any) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        var string = NSLocalizedString("Enable Playback", comment: "Default action")
        if isSpeakingEnabled {
            string = NSLocalizedString("Disable Playback", comment: "Default action")
        }
        actionSheet.addAction(UIAlertAction(title: string, style: .`default`, handler: { [weak self] _ in
            if isSpeakingEnabled {
                self?.stopTTS()
            }
            isSpeakingEnabled = !isSpeakingEnabled
            self?.audioComposeView.enablePlayback(enable: isSpeakingEnabled)
        }))
        
        // Add close Action
        actionSheet.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: "close action sheet"), style: .cancel, handler: nil))
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    // MARK: configuring views
    
    func configureThreadView() {
        self.botMessagesView = BotMessagesView()
        self.botMessagesView.translatesAutoresizingMaskIntoConstraints = false
        self.botMessagesView.backgroundColor = .clear
        self.botMessagesView.thread = self.thread
        self.botMessagesView.viewDelegate = self
        self.botMessagesView.clearBackground = true
        self.threadContainerView.addSubview(self.botMessagesView!)
        
        self.threadContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[botMessagesView]|", options:[], metrics:nil, views:["botMessagesView" : self.botMessagesView!]))
        self.threadContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[botMessagesView]|", options:[], metrics:nil, views:["botMessagesView" : self.botMessagesView!]))
    }
    
    func configureComposeBar() {
        self.composeView = ComposeBarView()
        self.composeView.translatesAutoresizingMaskIntoConstraints = false
        self.composeView.growingTextView.viewDelegate = self
        self.composeView.delegate = self
        self.composeBarContainerView.addSubview(self.composeView!)
        
        self.composeBarContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[composeView]|", options:[], metrics:nil, views:["composeView" : self.composeView!]))
        self.composeBarContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[composeView]", options:[], metrics:nil, views:["composeView" : self.composeView!]))
        
        self.composeViewBottomConstraint = NSLayoutConstraint.init(item: self.composeBarContainerView, attribute: .bottom, relatedBy: .equal, toItem: self.composeView, attribute: .bottom, multiplier: 1.0, constant: 0.0)
        self.composeBarContainerView.addConstraint(self.composeViewBottomConstraint)
        self.composeViewBottomConstraint.isActive = false
        
        self.composeBarContainerHeightConstraint = NSLayoutConstraint.init(item: self.composeBarContainerView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 0.0)
        self.view.addConstraint(self.composeBarContainerHeightConstraint)
    }
    
    func configureAudioComposer()  {
        self.audioComposeView = AudioComposeView()
        self.audioComposeView.translatesAutoresizingMaskIntoConstraints = false
        self.audioComposeContainerView.addSubview(self.audioComposeView!)
        
        self.audioComposeContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[audioComposeView]|", options:[], metrics:nil, views:["audioComposeView" : self.audioComposeView!]))
        self.audioComposeContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[audioComposeView]|", options:[], metrics:nil, views:["audioComposeView" : self.audioComposeView!]))
        
        self.audioComposeContainerHeightConstraint = NSLayoutConstraint.init(item: self.audioComposeContainerView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 0.0)
        self.view.addConstraint(self.audioComposeContainerHeightConstraint)
        self.audioComposeContainerHeightConstraint.isActive = false
        
        self.audioComposeView.voiceRecordingStarted = { [unowned self] (composeBar) in
            self.stopTTS()
            self.messagesViewControllerDelegate?.voiceRecordingStarted()
        }
        self.audioComposeView.voiceRecordingStopped = { [unowned self] (composeBar) in
           
            self.messagesViewControllerDelegate?.voiceRecordingStopped()
        }
        self.audioComposeView.getAudioPeakOutputPower = { () in
            return 0.0
        }
        self.audioComposeView.onKeyboardButtonAction = { [unowned self] () in
            _ = self.composeView.becomeFirstResponder()
            self.configureViewForKeyboard(true)
//            self.composeView.isHidden = false
        }
        self.audioComposeView.checkAudioRecordingPermissions = { [unowned self] (composeBar, block) in
            self.composeBarViewSpeechToTextButtonAction(self.composeView)
            block?(true)
        }
    }
    
    func configureQuickReplyView() {
        self.quickReplyView = KREQuickSelectView()
        self.quickReplyView.isHidden = true
        self.quickReplyView.translatesAutoresizingMaskIntoConstraints = false
        self.quickSelectContainerView.addSubview(self.quickReplyView)
        
        self.quickSelectContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[quickReplyView]|", options:[], metrics:nil, views:["quickReplyView" : self.quickReplyView]))
        self.quickSelectContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[quickReplyView(60)]", options:[], metrics:nil, views:["quickReplyView" : self.quickReplyView]))
        
        self.quickReplyView.sendQuickReplyAction = { [weak self] (text) in
            self?.sendTextMessage(text!)
        }
    }
    func configurePickerView() {
        self.pickerView = PickerSelectView()
        self.pickerView.translatesAutoresizingMaskIntoConstraints = false
        self.quickSelectContainerView.addSubview(self.pickerView)
        self.pickerView.isHidden = true
        self.quickSelectContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[pickerView]|", options:[], metrics:nil, views:["pickerView" : self.pickerView]))
        self.quickSelectContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[pickerView(215)]|", options:[], metrics:nil, views:["pickerView" : self.pickerView]))
        
        self.pickerView.sendPickerAction = { [weak self] (text) in
            self?.sendTextMessage(text!)
        }
        self.pickerView.cancelAction = {
            self.closeQuickReplyCards()
        }
    }
    
    func configureSessionEndView() {
        self.sessionEndView = SessionEndView()
        self.sessionEndView.translatesAutoresizingMaskIntoConstraints = false
        self.quickSelectContainerView.addSubview(self.sessionEndView)
        self.sessionEndView.isHidden = true
        self.quickSelectContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[sessionEndView]|", options:[], metrics:nil, views:["sessionEndView" : self.sessionEndView]))
        self.quickSelectContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[sessionEndView]|", options:[], metrics:nil, views:["sessionEndView" : self.sessionEndView]))
        
        self.sessionEndView.sendSessionAction = { () in
            self.isSessionEndBtnClicked = true
            self.closeQuickReplyCards()
            self.messagesViewControllerDelegate?.disconnectBot()
        }
        
    }

    func configureBottomView() {
        self.loaderView = LoaderView()
        self.loaderView.translatesAutoresizingMaskIntoConstraints = false
        self.quickSelectContainerView.addSubview(self.loaderView)
        self.loaderView.isHidden = true
        self.quickSelectContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[loaderView]|", options:[], metrics:nil, views:["loaderView" : self.loaderView]))
        self.quickSelectContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[loaderView]|", options:[], metrics:nil, views:["loaderView" : self.loaderView]))
    }
    
    func configureTypingStatusView() {
        self.typingStatusView = KRETypingStatusView()
        self.typingStatusView?.isHidden = true
        self.typingStatusView?.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.typingStatusView!)
        
        let views: [String: Any] = ["typingStatusView" : self.typingStatusView, "composeBarContainerView" : self.composeBarContainerView]
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[typingStatusView]|", options:[], metrics:nil, views: views))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[typingStatusView(40)][composeBarContainerView]", options:[], metrics:nil, views: views))
    }
    
    func configureInformationView() {
        informationLabel = UILabel(frame: .zero)
        informationLabel.translatesAutoresizingMaskIntoConstraints = false
        informationLabel.backgroundColor = .clear
        informationLabel.textColor = .white
        informationLabel.font = UIFont.systemFont(ofSize: 10.0)
        informationLabel.textAlignment = .center
        informationView.addSubview(informationLabel)
        
        informationView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[informationLabel]|", options:[], metrics:nil, views:["informationLabel" : self.informationLabel]))
        informationView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[informationLabel]|", options:[], metrics:nil, views:["informationLabel" : self.informationLabel]))
    }
    
    open func configureSTTClient() {

    }
    
    open func deConfigureSTTClient() {

    }
    
    // MARK: notifications
    func addNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(ChatMessagesViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ChatMessagesViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ChatMessagesViewController.keyboardDidShow(_:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ChatMessagesViewController.keyboardDidHide(_:)), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ChatMessagesViewController.startSpeaking), name: NSNotification.Name(rawValue: startSpeakingNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ChatMessagesViewController.stopSpeaking), name: NSNotification.Name(rawValue: stopSpeakingNotification), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ChatMessagesViewController.showTableTemplateView), name: NSNotification.Name(rawValue: showTableTemplateNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ChatMessagesViewController.reloadTable(notification:)), name: NSNotification.Name(rawValue: reloadTableNotification), object: nil)
    }
    
    func removeNotifications() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardDidHide, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: startSpeakingNotification), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: stopSpeakingNotification), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: showTableTemplateNotification), object: nil)
          NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: reloadTableNotification), object: nil)
    }
    
    // MARK: notification handlers
    @objc func keyboardWillShow(_ notification: Notification) {
        let keyboardUserInfo: NSDictionary = NSDictionary(dictionary: (notification as NSNotification).userInfo!)
        let keyboardFrameBegin: CGRect = ((keyboardUserInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue?)!.cgRectValue)
        let keyboardFrameEnd: CGRect = ((keyboardUserInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue?)!.cgRectValue)
        let options = UIViewAnimationOptions(rawValue: UInt((keyboardUserInfo[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).intValue << 16))
        let durationValue = keyboardUserInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber
        let duration = durationValue.doubleValue
        
        var diff = keyboardFrameBegin.origin.y - keyboardFrameEnd.origin.y
        if !self.audioComposeContainerHeightConstraint.isActive {
            let composeViewDiff = self.audioComposeContainerView.frame.size.height - self.composeView.frame.size.height
            diff -= composeViewDiff
        }
        self.bottomConstraint.constant = keyboardFrameEnd.size.height
        UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
            self.view.layoutIfNeeded()
            self.botMessagesView.scrollWithOffset(diff, animated: false)
        }, completion: { (Bool) in
            
        })
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        let keyboardUserInfo: NSDictionary = NSDictionary(dictionary: (notification as NSNotification).userInfo!)
        let keyboardFrameBegin: CGRect = ((keyboardUserInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue?)!.cgRectValue)
        let keyboardFrameEnd: CGRect = ((keyboardUserInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue?)!.cgRectValue)
        let durationValue = keyboardUserInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber
        let duration = durationValue.doubleValue
        let options = UIViewAnimationOptions(rawValue: UInt((keyboardUserInfo[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).intValue << 16))
        
        let diff = keyboardFrameBegin.origin.y - keyboardFrameEnd.origin.y
        self.bottomConstraint.constant = 0
        UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
            self.view.layoutIfNeeded()
            self.botMessagesView.scrollWithOffset(diff, animated: false)
        }, completion: { (Bool) in
            
        })
    }
    
    @objc func keyboardDidShow(_ notification: Notification) {
        if (self.tapToDismissGestureRecognizer == nil) {
            self.tapToDismissGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(ChatMessagesViewController.dismissKeyboard(_:)))
            self.botMessagesView.addGestureRecognizer(tapToDismissGestureRecognizer)
        }
    }
    
    @objc func keyboardDidHide(_ notification: Notification) {
        if (self.tapToDismissGestureRecognizer != nil) {
            self.botMessagesView.removeGestureRecognizer(tapToDismissGestureRecognizer)
            self.tapToDismissGestureRecognizer = nil
        }
    }
    
    @objc func dismissKeyboard(_ gesture: UITapGestureRecognizer) {
        if (self.composeView.isFirstResponder) {
            _ = self.composeView.resignFirstResponder()
        }
    }
    
    // MARK: Helper functions
    func sendMessage(_ message: Message) {
        NotificationCenter.default.post(name: Notification.Name(stopSpeakingNotification), object: nil)
        if let thread = thread, message.components.count > 0 {
            let dataStoreManager: DataStoreManager = DataStoreManager.sharedManager
            dataStoreManager.createNewMessageIn(thread: thread, message: message, completion: { [unowned self] (success) in
                guard let component = message.components.first else {
                    return
                }
                switch component.componentType {
                case .agentTransferMode:
                    if let jsonString = component.payload, let jsonObject = Utilities.jsonObjectFromString(jsonString: jsonString) as? [String: Any], let text = jsonObject["text"] as? String {
                        self.messagesViewControllerDelegate?.sendMessageToBot(with: text)
                    }
                default:
                    self.messagesViewControllerDelegate?.sendMessageToBot(with: component.payload)
                }
                self.textMessageSent()
            })
        }
    }
    
    public func sendTextMessage(_ text: String) {
        let dataStoreManager = DataStoreManager.sharedManager
        dataStoreManager.getLastMessage { [unowned self] (kreMesssage) in
            let message: Message = Message()
            message.messageType = .default
            message.sentDate = Date()
            message.messageId = KoreConstants.getUUID()

            if let templateType = kreMesssage?.templateType?.intValue, let componentType = ComponentType(rawValue: templateType), let _ = self.timer, (componentType == .agentTransferMode || componentType == .timerTask)  {
                let component: Component = Component(ComponentType.agentTransferMode)
                let payload = ["template_type": "agent_transfer_mode", "text": text]
                if let jsonString = Utilities.stringFromJSONObject(object: payload) {
                    component.payload = jsonString
                    message.addComponent(component)
                    self.sendMessage(message)
                }
            } else {
                let textComponent: Component = Component()
                textComponent.payload = text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                message.addComponent(textComponent)
                self.sendMessage(message)
            }
        }
    }
    
    func textMessageSent() {
        self.composeView.clear()
    }
    
    public func speechToTextButtonAction() {
        self.configureViewForKeyboard(false)
        _ = self.composeView.resignFirstResponder()
        self.stopTTS()
        self.audioComposeView.startRecording()
        
        let options = UIViewAnimationOptions(rawValue: UInt(7 << 16))
        let duration = 0.25
        UIView.animate(withDuration: duration, delay: 0.0, options: options, animations: {
            self.view.layoutIfNeeded()
        }, completion: { (Bool) in
        })
    }
    
    func configureViewForKeyboard(_ prepare: Bool) {
        if prepare {
            self.composeBarContainerHeightConstraint.isActive = false
            self.composeViewBottomConstraint.isActive = true
        } else {
            self.composeViewBottomConstraint.isActive = false
            self.composeBarContainerHeightConstraint.isActive = true
        }
        self.audioComposeContainerHeightConstraint.isActive = prepare
        self.audioComposeContainerView.clipsToBounds = prepare
        self.composeView.configureViewForKeyboard(prepare)
        self.composeBarContainerView.isHidden = !prepare
        self.audioComposeContainerView.isHidden = prepare
    }
    
    // MARK: BotMessagesDelegate methods
    func optionsButtonTapAction(text: String) {
        self.sendTextMessage(text)
    }
    
    func linkButtonTapAction(urlString: String) {
        if (urlString.count > 0) {
            var url: URL = URL(string: urlString)!
            
            if urlString.hasPrefix("https://") || urlString.hasPrefix("http://"){
                url = URL(string: urlString)!
            }else {
                let correctedURL = "http://\(urlString)"
                 url = URL(string: correctedURL)!
            }
            let webViewController: SFSafariViewController = SFSafariViewController(url: url)
//            let webNavigationController: UINavigationController = UINavigationController(rootViewController: webViewController)
//            webNavigationController.tabBarItem.title = "Bots"
            self.present(webViewController, animated: true, completion:nil)
        }
    }
    open func phoneNumTapAction(urlString: String) {
        self.callNumber(urlString)
    }
    func callNumber(_ str : String){
        var uc = URLComponents()
        uc.scheme = "tel"
        uc.path = str
        if let url: URL = uc.url {
            print(url)
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    func populateQuickReplyCards(with message: KREMessage?) {
        self.quickReplyView.isHidden = false
        self.pickerView.isHidden = true
        self.sessionEndView.isHidden = true
         self.loaderView.isHidden = true
        if message?.templateType == (ComponentType.quickReply.rawValue as NSNumber) {
            let component: KREComponent = message!.components![0] as! KREComponent
            if (!component.isKind(of: KREComponent.self)) {
                return;
            }
            if (component.componentDesc != nil) {
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
            let words: Array<Word> = Array<Word>()
            self.quickReplyView.setWordsList(words: words)
            self.closeQuickSelectViewConstraints()
        }
    }
    
    func closeQuickReplyCards() {
        UserDefaults.standard.setSignifyBottomView(with: false)
        self.configureViews(hideComposeBar)
        self.closeQuickSelectViewConstraints()
    }
    
    func setComposeBarHidden(_ isHidden: Bool) {
        hideComposeBar = isHidden
        configureViews(isHidden)
    }
    
    func updateQuickSelectViewConstraints() {
        if self.quickSelectContainerHeightConstraint.constant == 60.0 {return}
        
        self.quickSelectContainerHeightConstraint.constant = 60.0
        UIView.animate(withDuration: 0.25, delay: 0.05, options: [], animations: {
            self.view.layoutIfNeeded()
        }) { (Bool) in
            
        }
    }
    
    func populatePickerView(with message: KREMessage?) {
        if (self.composeView.isFirstResponder) {
            _ = self.composeView.resignFirstResponder()
        }
        self.configureViews(true)
        self.pickerView.isHidden = false
        self.quickReplyView.isHidden = true
        self.sessionEndView.isHidden = true
        self.loaderView.isHidden = true
        if message?.templateType == (ComponentType.picker.rawValue as NSNumber) {
            let component: KREComponent = message!.components![0] as! KREComponent
            if (!component.isKind(of: KREComponent.self)) {
                return;
            }
            if ((component.componentDesc) != nil) {
                let jsonObject: NSDictionary = Utilities.jsonObjectFromString(jsonString: component.componentDesc!) as! NSDictionary
                let pickerValues: Array<Dictionary<String, String>> = jsonObject["elements"] as! Array<Dictionary<String, String>>
                var valuesArr: Array<String> = Array<String>()
                
                for dictionary in pickerValues {
                    let title: String = dictionary["title"] != nil ? dictionary["title"]! : ""

                    valuesArr.append(title)
                }
                self.pickerView.setValues(values:valuesArr)
                updatePickerViewConstraints()
            }
        } else if(message != nil) {
            let words: Array<String> = Array<String>()
            self.pickerView.setValues(values: words)
            self.closeQuickSelectViewConstraints()
        }
    }

    open func populateSessionEndView(with message: Message?) {
        guard let component = message?.components.first else {
            return
        }
        if (self.composeView.isFirstResponder) {
            _ = self.composeView.resignFirstResponder()
        }
        self.configureViews(true)
        self.pickerView.isHidden = true
        self.quickReplyView.isHidden = true
        self.sessionEndView.isHidden = false
        self.loaderView.isHidden = true

        if component.componentType == ComponentType.sessionend, let payload = component.payload, let jsonObject = Utilities.jsonObjectFromString(jsonString: payload) as? [String: Any]  {
            var titlesArr: [String] = [String]()
            if let sessionValues = jsonObject["buttons"] as? Array<[String: Any]> {
                for dictionary in sessionValues {
                    if let title = dictionary["title"] as? String {
                        titlesArr.append(title)
                    } else {
                        titlesArr.append("")
                    }
                }
            }
            
            if let text = jsonObject["text"] as? String {
                self.sessionEndView.setValues(titleArr: titlesArr, text: text)
            }
            updateSessionEndViewConstraints()
        }
    }
    
    func populateBottomTableView(with message: KREMessage?) {
        if (self.composeView.isFirstResponder) {
            _ = self.composeView.resignFirstResponder()
        }
        configureViews(true)
        self.pickerView.isHidden = true
        self.quickReplyView.isHidden = true
        self.sessionEndView.isHidden = true
        self.loaderView.isHidden = false
        if message?.templateType == (ComponentType.showProgress.rawValue as NSNumber) {
            let component: KREComponent = message!.components![0] as! KREComponent
            if (!component.isKind(of: KREComponent.self)) {
                return;
            }
            if ((component.componentDesc) != nil) {
                let jsonObject: NSDictionary = Utilities.jsonObjectFromString(jsonString: component.componentDesc!) as! NSDictionary
                let strText: String = jsonObject["text"] as! String
                self.loaderView.setValues(textLblTitle:strText)
                updateSessionEndViewConstraints()
            }
        } else if(message != nil) {
            self.closeQuickSelectViewConstraints()
        }
    }
    
    func updateSessionEndViewConstraints() {
//        if !isSessionEndBtnClicked{
            if self.quickSelectContainerHeightConstraint.constant == 150 {
                return
            }
            self.quickSelectContainerHeightConstraint.constant = 150
            UIView.animate(withDuration: 0.25, delay: 0.05, options: [], animations: {
                self.view.layoutIfNeeded()
            }) { (Bool) in
                
            }
//        }
    }

    func updatePickerViewConstraints() {
        if self.quickSelectContainerHeightConstraint.constant == 259 {
            return
        }
        
        self.quickSelectContainerHeightConstraint.constant = 259
        UIView.animate(withDuration: 0.25, delay: 0.05, options: [], animations: {
            self.view.layoutIfNeeded()
        }) { (Bool) in
            
        }
    }
    
    func closeQuickSelectViewConstraints() {
        if self.quickSelectContainerHeightConstraint.constant == 0.0 {return}
        self.quickSelectContainerHeightConstraint.constant = 0.0
        UIView.animate(withDuration: 0.25, delay: 0.0, options: [], animations: {
            self.view.layoutIfNeeded()
        }) { (Bool) in
            
        }
    }
    
    open func startWaitTimerTasks(for messageId: String) {

    }
    
    open func stopWaitTimerTasks() {

    }

    // MARK: -
    func configureViews(_ prepare: Bool) {
        if (prepare) {
            UIView.animate(withDuration: 0.5) {
                self.composeBarContainerHeightConstraint.isActive = prepare
                self.composeViewBottomConstraint.isActive = prepare
                self.audioComposeContainerHeightConstraint.isActive = prepare
                self.audioComposeContainerView.clipsToBounds = prepare
                self.composeView.configureViewForKeyboard(prepare)
                self.composeBarContainerView.isHidden = prepare
                self.audioComposeContainerView.isHidden = prepare
            }
        } else {
            UIView.animate(withDuration: 0.4) {
                self.composeViewBottomConstraint.isActive = !prepare
                self.composeBarContainerHeightConstraint.isActive = prepare
                self.audioComposeContainerHeightConstraint.isActive = self.hideComposeBar ? self.hideComposeBar : !prepare
                self.audioComposeContainerView.clipsToBounds = self.hideComposeBar ? self.hideComposeBar : !prepare
                self.composeView.configureViewForKeyboard(!prepare)
                self.composeBarContainerView.isHidden = prepare
                self.audioComposeContainerView.isHidden = !prepare
            }
        }
    }
    
    // MARK: - information view
    public func updateInformationViewConstraints(with connectionState: BotClientConnectionState) {
        
        var text = "Connecting..."
        var edgeInsets = UIEdgeInsetsMake(24.0, 0.0, 0.0, 0.0)
        switch connectionState {
        case .CONNECTING:
            text = "Connecting..."
            break
        case .CONNECTED:
            text = ""
            edgeInsets = .zero
            break
        case .NO_NETWORK:
            text = "Waiting for network..."
            break
        case .FAILED:
            text = "Something is not right. We will be connecting shortly."
            break
        default:
            break
        }
        if (connectionState == .CONNECTED) {
            UIView.animate(withDuration: 0.25, delay: 0.05, options: [], animations: {

            }) { [unowned self] (Bool) in
                
                if UserDefaults.standard.getSignifyBottomView() {
                    self.configureViews(true)
                } else {
                    self.configureViews(false)
                }
                self.messagesViewControllerDelegate?.refreshButton(true)
                self.quickSelectContainerView.isUserInteractionEnabled = true
                let fontVlaue = UIFont(name: "Roboto-Regular", size: 21)

                self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: fontVlaue!, NSAttributedStringKey.foregroundColor : UIColor(red: 60/255, green: 60/255, blue: 65/255, alpha: 1)]

                self.navigationItem.title = text
                self.navigationItem.title = "Support"
                UIView.animate(withDuration: 0.25, delay: 0.0, options: [], animations: { [unowned self] in
                    self.view.layoutIfNeeded()
                }) { (Bool) in
                    
                }
            }
        } else {
//            if (connectionState == .CONNECTING || connectionState == .NONE) {
//                self.closeQuickSelectViewConstraints()
//            }
            self.messagesViewControllerDelegate?.refreshButton(false)
            stopWaitTimerTasks()
            UIView.animate(withDuration: 0.25, delay: 0.05, options: [], animations: { [unowned self] in
                self.view.endEditing(true)

                let fontVlaue = UIFont(name: "Roboto-Regular", size: 16)

                self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: fontVlaue!, NSAttributedStringKey.foregroundColor : UIColor(red: 60/255, green: 60/255, blue: 65/255, alpha: 1)];
                self.navigationItem.title = text
                self.quickSelectContainerView.isUserInteractionEnabled = false
            }) { [unowned self] (Bool) in
                
                edgeInsets = .zero
                self.configureViews(true)
                self.botMessagesView.tableView.contentInset = edgeInsets
                UIView.animate(withDuration: 0.25, delay: 0.0, options: [], animations: { [unowned self] in
                    self.view.layoutIfNeeded()
                }) { (Bool) in
                    
                }
            }
        }
    }

    
    // MARK: ComposeBarViewDelegate methods
    open func composeBarView(_: ComposeBarView, sendButtonAction text: String) {
        self.sendTextMessage(text)
    }
    
    open func composeBarViewSpeechToTextButtonAction(_: ComposeBarView) {

    }
    
    open func composeBarViewDidBecomeFirstResponder(_: ComposeBarView) {
        self.audioComposeView.stopRecording()
    }
    
    // MARK: KREGrowingTextViewDelegate methods
    public func growingTextView(_: KREGrowingTextView, changingHeight height: CGFloat, animate: Bool) {
        UIView.animate(withDuration: animate ? 0.25: 0.0) {
            self.view.layoutIfNeeded()
        }
    }
    
    public func growingTextView(_: KREGrowingTextView, willChangeHeight height: CGFloat) {
        
    }
    
    public func growingTextView(_: KREGrowingTextView, didChangeHeight height: CGFloat) {
        
    }
    
    // MARK: TTS Functionality
    @objc func startSpeaking(notification:Notification) {
        if(isSpeakingEnabled){
            var string: String = notification.object! as! String
            string = KREUtilities.getHTMLStrippedString(from: string)
            self.readOutText(text: string)
        }
    }
    
    @objc func stopSpeaking(notification:Notification) {
        self.stopTTS()
    }
    
    func readOutText(text:String) {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayback)
            try audioSession.setMode(AVAudioSessionModeDefault)
        } catch {
            
        }
        let string = text
        let speechUtterance = AVSpeechUtterance(string: string)
        self.speechSynthesizer.speak(speechUtterance)
    }
    
    func stopTTS(){
        if(self.speechSynthesizer.isSpeaking){
            self.speechSynthesizer.stopSpeaking(at: AVSpeechBoundary.immediate)
        }
    }
    
    // MARK: show tying status view
    public func showTypingStatusForBotsAction() {
        self.botMessagesView.tableView.contentInset = UIEdgeInsetsMake(0.0, 0.0, 40.0, 0.0)

        let botId = "u-40d2bdc2-822a-51a2-bdcd-95bdf4po8331c9"
        let info = NSMutableDictionary()
        info.setValue(botId, forKey: "botId")
        info.setValue(KoreBotUIKit.Bot.BubbleView.imageName, forKey: "imageName")
        
        self.typingStatusView?.addTypingStatus(forContact: info, forTimeInterval: 2.0)
    }
    
    // MARK: show TableTemplateView
    @objc func showTableTemplateView(notification:Notification) {
        let dataString: String = notification.object as! String
        let tableTemplateViewController = TableTemplateViewController(dataString: dataString)
            self.navigationController?.present(tableTemplateViewController, animated: true, completion: nil)
    }
    
    @objc func reloadTable(notification:Notification){
        botMessagesView.tableView.reloadData()
    }
}

public extension UserDefaults {
    func setSignifyBotStatus(with mute: Bool) {
        set(mute, forKey: "MuteSignifyBot")
        synchronize()
    }
    
    func getsignifyBotStatus() -> Bool {
        return bool(forKey: "MuteSignifyBot")
    }
    func setSignifyBottomView(with isPresent: Bool) {
        set(isPresent, forKey: "BottomViewSignifyBot")
        synchronize()
    }
    
    func getSignifyBottomView() -> Bool {
        return bool(forKey: "BottomViewSignifyBot")
    }
}
