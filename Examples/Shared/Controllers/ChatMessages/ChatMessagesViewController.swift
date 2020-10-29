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
import KoreBotSDK
import CoreData
import Mantle


class ChatMessagesViewController: UIViewController, BotMessagesViewDelegate, ComposeBarViewDelegate, KREGrowingTextViewDelegate, NewListViewDelegate, TaskMenuNewDelegate, calenderSelectDelegate, ListWidgetViewDelegate, feedbackViewDelegate, LiveSearchViewDelegate, LiveSearchDetailsViewDelegate, UIGestureRecognizerDelegate {
    // MARK: properties
    var messagesRequestInProgress: Bool = false
    var historyRequestInProgress: Bool = false
    var thread: KREThread?
    var botClient: BotClient!
    var tapToDismissGestureRecognizer: UITapGestureRecognizer!
    
    @IBOutlet weak var threadContainerView: UIView!
    @IBOutlet weak var quickSelectContainerView: UIView!
    @IBOutlet weak var composeBarContainerView: UIView!
    @IBOutlet weak var audioComposeContainerView: UIView!
    @IBOutlet weak var panelCollectionViewContainerView: UIView!
    @IBOutlet weak var menuButton: UIButton!
    
    @IBOutlet weak var quickSelectContainerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    var composeBarContainerHeightConstraint: NSLayoutConstraint!
    var composeViewBottomConstraint: NSLayoutConstraint!
    var audioComposeContainerHeightConstraint: NSLayoutConstraint!
    var botMessagesView: BotMessagesView!
    var composeView: ComposeBarView!
    var audioComposeView: AudioComposeView!
    var quickReplyView: KREQuickSelectView!
    var typingStatusView: KRETypingStatusView!
    var webViewController: SFSafariViewController!
    
    
    var taskMenuKeyBoard = true
    @IBOutlet weak var taskMenuContainerView: UIView!
    @IBOutlet weak var taskMenuContainerHeightConstant: NSLayoutConstraint!
    var taskMenuHeight = 0
    
    var panelCollectionView: KAPanelCollectionView!
    var launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    
    let sttClient = KoraASRService.shared
    var speechSynthesizer: AVSpeechSynthesizer!
    
    public var authInfoModel: AuthInfoModel?
    public var userInfoModel: UserModel?
    public var user: KREUser?
    public var sheetController: KABottomSheetController?
    var isShowAudioComposeView = false
    var insets: UIEdgeInsets = .zero
    @IBOutlet weak var panelCollectionViewContainerHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var backgroungImageView: UIImageView!
    @IBOutlet weak var dropDownBtn: UIButton!
    let colorDropDown = DropDown()
    lazy var dropDowns: [DropDown] = {
        return [
            self.colorDropDown
        ]
    }()
    
    @IBOutlet weak var liveSearchContainerView: UIView!
    var liveSearchView:  LiveSearchView!
    @IBOutlet weak var webViewContainerView: UIView!
    var webView: WebView!
    
    public var maxPanelHeight: CGFloat {
        var maxHeight = UIScreen.main.bounds.height
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        let delta: CGFloat = 15.0
        maxHeight -= statusBarHeight
        maxHeight -= delta
        return maxHeight
    }
    
    public var panelHeight: CGFloat {
        var maxHeight = maxPanelHeight
        maxHeight -= self.isShowAudioComposeView == true ? self.audioComposeView.bounds.height : self.composeView.bounds.height
        return maxHeight-panelCollectionViewContainerView.bounds.height - insets.bottom
    }
    var kaBotClient = KABotClient()
    
    // MARK: init
    init(thread: KREThread?) {
        super.init(nibName: "ChatMessagesViewController", bundle: nil)
        self.thread = thread
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Initialize elements
        self.configureThreadView()
        self.configureComposeBar()
        self.configureAudioComposer()
        self.configureQuickReplyView()
        self.configureTypingStatusView()
        self.configureSTTClient()
        
        self.configureViewForKeyboard(true)
        
        if SDKConfiguration.widgetConfig.isPanelView {
            self.configurePanelCollectionView()
        } else {
            panelCollectionViewContainerHeightConstraint.constant = 0
        }
        
        isSpeakingEnabled = false //kk true
        self.speechSynthesizer = AVSpeechSynthesizer()
        ConfigureDropDownView()
        liveSearchViewConfigure()
        configureWebView()
        welcomeMessage(messageString: "👋 Hello! How can I help you today?")
    }
    
    func configureWebView(){
        webViewContainerView.isHidden = true
        webView = WebView()
        webView?.translatesAutoresizingMaskIntoConstraints = false
        webViewContainerView.addSubview(webView!)
        
        let views: [String: Any] = ["webView" : webView]
        webViewContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[webView]|", options:[], metrics:nil, views: views))
        webViewContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[webView]|", options:[], metrics:nil, views: views))
    }
    
    func liveSearchViewConfigure(){
        liveSearchView = LiveSearchView()
        liveSearchView.viewDelegate = self
        liveSearchView?.translatesAutoresizingMaskIntoConstraints = false
        liveSearchContainerView.addSubview(self.liveSearchView!)
        
        let views: [String: Any] = ["liveSearchView" : self.liveSearchView]
        liveSearchContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[liveSearchView]|", options:[], metrics:nil, views: views))
        liveSearchContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-50-[liveSearchView]|", options:[], metrics:nil, views: views))
        
        self.tapToDismissGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(ChatMessagesViewController.dismissKeyboard(_:)))
        self.tapToDismissGestureRecognizer.delegate = self
        self.liveSearchContainerView.addGestureRecognizer(tapToDismissGestureRecognizer)
    }
    func addTextToTextView(text: String) {
        self.composeView.setText(text)
    }
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view?.isDescendant(of: self.liveSearchView.tableView) == true {
            return false
        }
        return true
    }
    
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addNotifications()
        
        let urlString = leftImage.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let url = URL(string: urlString!)
        var data : Data?
        if url != nil {
            data = try? Data(contentsOf: url!)
        }
        var image = UIImage(named: "cancel")
        if let imageData = data {
            image = UIImage(data: imageData)
        }
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(cancel(_:)))
        
        let moreImage = UIImage(named: "more")
        let questionImage = UIImage(named: "question")
        let moreButton   = UIBarButtonItem(image: moreImage,  style: .plain, target: self, action: #selector(more(_:)))
        let questionButton = UIBarButtonItem(image: questionImage,  style: .plain, target: self, action: #selector(more(_:)))
        navigationItem.rightBarButtonItems = [moreButton, questionButton]
        //navigationItem.rightBarButtonItem = UIBarButtonItem(image: rightImage, style: .plain, target: self, action: #selector(more(_:)))
        
        navigationController?.setNavigationBarHidden(false, animated: false)
        
        let font:UIFont? = UIFont(name: "Helvetica-Bold", size:17)
        let attString:NSMutableAttributedString = NSMutableAttributedString(string: "Findly.ai", attributes: [.font:font!]) //headerTitle
        let titleLabel = UILabel()
        titleLabel.textColor = .darkGray
        titleLabel.attributedText = attString
        self.navigationItem.titleView = titleLabel
        
        //navigationController?.navigationBar.barTintColor = themeColor
        navigationController?.navigationBar.tintColor = UIColor.darkGray
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        self.view.backgroundColor = UIColor.init(hexString: "#f3f3f5")
        
        if SDKConfiguration.widgetConfig.isPanelView {
            populatePanelItems()
        }
        
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override open func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.removeNotifications()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //MARK:- deinit
    deinit {
        NSLog("ChatMessagesViewController dealloc")
        self.thread = nil
        self.botClient = nil
        self.speechSynthesizer = nil
        self.composeView = nil
        self.audioComposeView = nil
        self.botMessagesView = nil
        self.quickReplyView = nil
        self.typingStatusView = nil
        self.tapToDismissGestureRecognizer = nil
    }
    
    //MARK:- removing refernces to elements
    func prepareForDeinit(){
        if(self.botClient != nil){
            self.botClient.disconnect()
        }
        
        KABotClient.shared.deConfigureBotClient()
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
    @objc func cancel(_ sender: Any) {
        //        prepareForDeinit()
        //        navigationController?.setNavigationBarHidden(true, animated: false)
        //        navigationController?.popViewController(animated: true)
        
        if ((self.composeView.isFirstResponder)) {
            _ = self.composeView.resignFirstResponder()
        }
        webViewContainerView.isHidden = false
        navigationController?.setNavigationBarHidden(true, animated: false)
        
    }
    
    // MARK: More
    @objc func more(_ sender: Any) {
        // colorDropDown.show()
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
        
        self.audioComposeView.voiceRecordingStarted = { [weak self] (composeBar) in
            self?.stopTTS()
            //self?.composeView.isHidden = true
        }
        self.audioComposeView.voiceRecordingStopped = { [weak self] (composeBar) in
            self?.sttClient.stopRecording()
        }
        self.audioComposeView.getAudioPeakOutputPower = { () in
            return 0.0
        }
        self.audioComposeView.onKeyboardButtonAction = { [weak self] () in
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ClosePanel"), object: nil)
            self?.isShowAudioComposeView = false
            _ = self?.composeView.becomeFirstResponder()
            self?.configureViewForKeyboard(true)
        }
    }
    
    func configureQuickReplyView() {
        self.quickReplyView = KREQuickSelectView()
        self.quickReplyView.translatesAutoresizingMaskIntoConstraints = false
        self.quickSelectContainerView.addSubview(self.quickReplyView)
        
        self.quickSelectContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[quickReplyView]|", options:[], metrics:nil, views:["quickReplyView" : self.quickReplyView]))
        self.quickSelectContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[quickReplyView(60)]", options:[], metrics:nil, views:["quickReplyView" : self.quickReplyView]))
        
        self.quickReplyView.sendQuickReplyAction = { [weak self] (text, payload) in
            if let text = text, let payload = payload {
                self?.sendTextMessage(text, options: ["body": payload])
            }
        }
    }
    
    func configurePanelCollectionView() {
        
        self.panelCollectionView = KAPanelCollectionView()
        self.panelCollectionView?.translatesAutoresizingMaskIntoConstraints = false
        self.panelCollectionViewContainerView.addSubview(self.panelCollectionView!)
        
        self.panelCollectionViewContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[panelCollectionView]|", options:[], metrics:nil, views:["panelCollectionView" : self.panelCollectionView!]))
        self.panelCollectionViewContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[panelCollectionView]|", options:[], metrics:nil, views:["panelCollectionView" : self.panelCollectionView!]))
        
        self.panelCollectionView.onPanelItemClickAction = { (item) in
        }
        
        self.panelCollectionView.retryAction = { [weak self] in
            self?.populatePanelItems()
        }
        
        self.panelCollectionView.panelItemHandler = { [weak self] (item, block) in
            guard let weakSelf = self else {
                return
            }
            
            switch item?.type {
            case "action":
                weakSelf.processActionPanelItem(item)
            default:
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "BringComposeBarToBottom"), object: nil)
                if #available(iOS 11.0, *) {
                    self?.insets = UIApplication.shared.delegate?.window??.safeAreaInsets ?? .zero
                }
                var inputViewHeight = self?.isShowAudioComposeView == true ? self!.audioComposeContainerView.bounds.height : self!.composeBarContainerView.bounds.height
                inputViewHeight = inputViewHeight + (self?.insets.bottom ?? 0.0) + (self?.panelCollectionViewContainerView.bounds.height)!
                let sizes: [SheetSize] = [.fixed(0.0), .fixed(weakSelf.panelHeight)]
                if weakSelf.sheetController == nil {
                    let panelItemViewController = KAPanelItemViewController()
                    panelItemViewController.panelId = item?.id
                    panelItemViewController.dismissAction = { [weak self] in
                        self?.sheetController = nil
                    }
                    if ((self?.composeView.isFirstResponder)!) {
                        _ = self!.composeView.resignFirstResponder()
                    }
                    
                    let bottomSheetController = KABottomSheetController(controller: panelItemViewController, sizes: sizes)
                    bottomSheetController.inputViewHeight = CGFloat(inputViewHeight)
                    bottomSheetController.willSheetSizeChange = { [weak self] (controller, newSize) in
                        switch newSize {
                        case .fixed(weakSelf.panelHeight):
                            controller.overlayColor = .clear
                            panelItemViewController.showPanelHeader(true)
                        default:
                            controller.overlayColor = .clear
                            panelItemViewController.showPanelHeader(false)
                            bottomSheetController.closeSheet(true)
                            
                            self?.sheetController = nil
                        }
                    }
                    bottomSheetController.modalPresentationStyle = .overCurrentContext
                    weakSelf.present(bottomSheetController, animated: true, completion: block)
                    weakSelf.sheetController = bottomSheetController
                } else if let bottomSheetController = weakSelf.sheetController,
                    let panelItemViewController = bottomSheetController.childViewController as? KAPanelItemViewController {
                    panelItemViewController.panelId = item?.id
                    
                    if bottomSheetController.presentingViewController == nil {
                        weakSelf.present(bottomSheetController, animated: true, completion: block)
                    } else {
                        block?()
                    }
                }
            }
        }
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
    
    
    func ConfigureDropDownView(){
        //DropDown
        dropDowns.forEach { $0.dismissMode = .onTap }
        dropDowns.forEach { $0.direction = .any }
        
        colorDropDown.backgroundColor = UIColor(white: 1, alpha: 1)
        colorDropDown.selectionBackgroundColor = UIColor(red: 0.6494, green: 0.8155, blue: 1.0, alpha: 0.2)
        colorDropDown.separatorColor = UIColor(white: 0.7, alpha: 0.8)
        colorDropDown.cornerRadius = 10
        colorDropDown.shadowColor = UIColor(white: 0.6, alpha: 1)
        colorDropDown.shadowOpacity = 0.9
        colorDropDown.shadowRadius = 25
        colorDropDown.animationduration = 0.25
        colorDropDown.textColor = .darkGray
        
        let urlString = backgroudImage.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let url = URL(string: urlString!)
        if url != nil{
            backgroungImageView.setImageWith(url!, placeholderImage: UIImage(named: ""))
            backgroungImageView.contentMode = .scaleAspectFit
        }
        setupColorDropDown()
    }
    // MARK: Setup DropDown
    func setupColorDropDown() {
        colorDropDown.anchorView = dropDownBtn
        
        colorDropDown.bottomOffset = CGPoint(x: 0, y: dropDownBtn.bounds.height)
        colorDropDown.dataSource = [
            "Theme Logo",
            "Theme Shopping"
        ]
        colorDropDown.selectRow(0)
        // Action triggered on selection
        colorDropDown.selectionAction = { [weak self] (index, item) in
            //self?.amountButton.setTitle(item, for: .normal)
            if item == "Theme Logo" {
                selectedTheme = "Theme 1"
            }else{
                selectedTheme = "Theme 2"
            }
            
            if selectedTheme == "Theme 1"{
                let urlString = backgroudImage.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                let url = URL(string: urlString!)
                if url != nil{
                    self!.backgroungImageView.setImageWith(url!, placeholderImage: UIImage(named: ""))
                }else{
                    self!.backgroungImageView.image = UIImage.init(named: "")
                }
                self!.backgroungImageView.contentMode = .scaleAspectFit
            }else{
                self!.backgroungImageView.image = UIImage.init(named: "Shoppingbackground")
                self!.backgroungImageView.contentMode = .scaleAspectFill
            }
            NotificationCenter.default.post(name: Notification.Name(reloadTableNotification), object: nil)
        }
        
    }
    
    func getComponentType(_ templateType: String,_ tabledesign: String) -> ComponentType {
        if (templateType == "quick_replies") {
            return .quickReply
        } else if (templateType == "button") {
            return .options
        }else if (templateType == "list") {
            return .list
        }else if (templateType == "carousel") {
            return .carousel
        }else if (templateType == "piechart" || templateType == "linechart" || templateType == "barchart") {
            return .chart
        }else if (templateType == "table"  && tabledesign == "regular") {
            return .table
        }
        else if (templateType == "table"  && tabledesign == "responsive") {
            return .responsiveTable
        }
        else if (templateType == "mini_table") {
            return .minitable
        }
        else if (templateType == "menu") {
            return .menu
        }
        else if (templateType == "listView") {
            return .newList
        }
        else if (templateType == "tableList") {
            return .tableList
        }
        else if (templateType == "daterange" || templateType == "dateTemplate") {
            return .calendarView
        }
        else if (templateType == "quick_replies_welcome"){
            return .quick_replies_welcome
        }
        else if (templateType == "Notification") {
            return .notification
        }
        else if (templateType == "multi_select") {
            return .multiSelect
        }
        else if (templateType == "List_widget") {
            return .list_widget
        }
        else if (templateType == "feedbackTemplate") {
            return .feedbackTemplate
        }
        else if (templateType == "form_template") {
            return .inlineForm
        }
        else if (templateType == "search") {
            return .search
        }
        return .text
    }
    
    func onReceiveMessage(object: BotMessageModel?) -> (Message?, String?) {
        var ttsBody: String?
        var textMessage: Message! = nil
        let message: Message = Message()
        message.messageType = .reply
        if let type = object?.type, type == "incoming" {
            message.messageType = .default
        }
        message.sentDate = object?.createdOn
        message.messageId = object?.messageId
        
        if (object?.iconUrl != nil) {
            message.iconUrl = object?.iconUrl
        }
        
        if (webViewController != nil) {
            webViewController.dismiss(animated: true, completion: nil)
            webViewController = nil
        }
        
        let messageObject = ((object?.messages.count)! > 0) ? (object?.messages[0]) : nil
        if (messageObject?.component == nil) {
            
        } else {
            let componentModel: ComponentModel = messageObject!.component!
            if (componentModel.type == "text") {
                let payload: NSDictionary = componentModel.payload! as! NSDictionary
                let text: NSString = payload["text"] as! NSString
                let textComponent: Component = Component()
                textComponent.payload = text as String
                ttsBody = text as String
                
                if(text.contains("use a web form")){
                    let range: NSRange = text.range(of: "use a web form - ")
                    let urlString: String? = text.substring(with: NSMakeRange(range.location+range.length, 44))
                    if (urlString != nil) {
                        let url: URL = URL(string: urlString!)!
                        webViewController = SFSafariViewController(url: url)
                        webViewController.modalPresentationStyle = .custom
                        present(webViewController, animated: true, completion:nil)
                    }
                    ttsBody = "Ok, Please fill in the details and submit"
                }
                message.addComponent(textComponent)
                return (message, ttsBody)
            } else if (componentModel.type == "template") {
                let payload: NSDictionary = componentModel.payload! as! NSDictionary
                let text: String = payload["text"] != nil ? payload["text"] as! String : ""
                let type: String = payload["type"] != nil ? payload["type"] as! String : ""
                ttsBody = payload["speech_hint"] != nil ? payload["speech_hint"] as? String : nil
                
                if (type == "template") {
                    let dictionary: NSDictionary = payload["payload"] as! NSDictionary
                    let templateType: String = dictionary["template_type"] as! String
                    var tabledesign: String
                    
                    tabledesign  = (dictionary["table_design"] != nil ? dictionary["table_design"] as? String : "responsive")!
                    let componentType = self.getComponentType(templateType,tabledesign)
                    
                    if componentType != .quickReply {
                        
                    }
                    
                    let tText: String = dictionary["text"] != nil ? dictionary["text"] as! String : ""
                    ttsBody = dictionary["speech_hint"] != nil ? dictionary["speech_hint"] as? String : nil
                    
                    if tText.count > 0 && (componentType == .carousel || componentType == .chart || componentType == .table || componentType == .minitable || componentType == .responsiveTable) {
                        textMessage = Message()
                        textMessage?.messageType = .reply
                        textMessage?.sentDate = message.sentDate
                        textMessage?.messageId = message.messageId
                        if (object?.iconUrl != nil) {
                            textMessage?.iconUrl = object?.iconUrl
                        }
                        let textComponent: Component = Component()
                        textComponent.payload = tText
                        textMessage?.addComponent(textComponent)
                    }
                    
                    let optionsComponent: Component = Component(componentType)
                    optionsComponent.payload = Utilities.stringFromJSONObject(object: dictionary)
                    message.sentDate = object?.createdOn
                    message.addComponent(optionsComponent)
                } else if (type == "error") {
                    let dictionary: NSDictionary = payload["payload"] as! NSDictionary
                    let errorComponent: Component = Component(.error)
                    errorComponent.payload = Utilities.stringFromJSONObject(object: dictionary)
                    message.addComponent(errorComponent)
                } else if text.count > 0 {
                    let textComponent: Component = Component()
                    textComponent.payload = text
                    message.addComponent(textComponent)
                }
                return (message, ttsBody)
            }
        }
        return (nil, ttsBody)
    }
    
    func addMessages(_ message: Message?, _ ttsBody: String?) {
        if let m = message, m.components.count > 0 {
            //showTypingStatusForBotsAction() //kk
            let delayInMilliSeconds = 500
            DispatchQueue.global().asyncAfter(deadline: .now() + .milliseconds(delayInMilliSeconds)) {
                let dataStoreManager = DataStoreManager.sharedManager
                dataStoreManager.createNewMessageIn(thread: self.thread, message: m, completion: { (success) in
                    
                })
                
                if let tts = ttsBody {
                    NotificationCenter.default.post(name: Notification.Name(startSpeakingNotification), object: tts)
                }
            }
        }
    }
    
    func configureSTTClient() {
        self.sttClient.onError = { [weak self] (error, userInfo) in
            guard let strongSelf = self else {
                return
            }
            strongSelf.audioComposeView.stopRecording()
            strongSelf.composeView.setText("")
            strongSelf.composeViewBottomConstraint.isActive = false
            strongSelf.composeBarContainerHeightConstraint.isActive = true
            strongSelf.composeBarContainerView.isHidden = true
            
            if let message = userInfo?["message"] as? String {
                let alert = UIAlertController(title: message, message: nil, preferredStyle: .alert)
                
                if let navigateToSettings = userInfo?["settings"] as? Bool, navigateToSettings {
                    let settingsAction = UIAlertAction(title: "Settings", style: .default, handler: { (action) in
                        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
                        }
                    })
                    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                        
                    })
                    alert.addAction(settingsAction)
                    alert.addAction(cancelAction)
                } else {
                    let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: { (action) in
                        
                    })
                    alert.addAction(cancelAction)
                }
                self?.present(alert, animated: true, completion: nil)
            }
        }
        self.sttClient.onResponse = { [weak self] (transcript, isFinal) in
            guard let strongSelf = self else {
                return
            }
            print("Got transcript: \(transcript) isFinal:\(isFinal)")
            if isFinal {
                strongSelf.composeView.setText(transcript)
                if !strongSelf.composeView.isKeyboardEnabled {
                    strongSelf.audioComposeView.stopRecording()
                    strongSelf.sendTextMessage(transcript, options: nil)
                    strongSelf.composeView.setText("")
                    strongSelf.composeViewBottomConstraint.isActive = false
                    strongSelf.composeBarContainerHeightConstraint.isActive = true
                    strongSelf.composeBarContainerView.isHidden = true
                }
            }else{
                strongSelf.composeView.setText(transcript)
                strongSelf.composeBarContainerHeightConstraint.isActive = false
                strongSelf.composeViewBottomConstraint.isActive = true
                strongSelf.composeBarContainerView.isHidden = false
            }
        }
    }
    
    func deConfigureSTTClient() {
        self.sttClient.onError = nil
        self.sttClient.onResponse = nil
    }
    
    func updateNavBarPrompt() {
        self.navigationItem.leftBarButtonItem?.isEnabled = true
        switch self.botClient.connectionState {
        case .CONNECTING:
            self.navigationItem.leftBarButtonItem?.isEnabled = false
            self.navigationItem.prompt = "Connecting..."
            break
        case .CONNECTED:
            self.navigationItem.prompt = "Connected"
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                self.navigationItem.prompt = nil
            })
            break
        case .FAILED:
            self.navigationItem.prompt = "Connection Failed"
            break
        case .CLOSED:
            self.navigationItem.prompt = "Connection Closed"
            break
        case .NO_NETWORK:
            self.navigationItem.prompt = "No Network"
            break
        case .NONE, .CLOSING:
            self.navigationItem.prompt = nil
            break
        }
    }
    
    // MARK: notifications
    func addNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(_:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide(_:)), name: UIResponder.keyboardDidHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive(_:)), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground(_:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(startSpeaking), name: NSNotification.Name(rawValue: startSpeakingNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(stopSpeaking), name: NSNotification.Name(rawValue: stopSpeakingNotification), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(showTableTemplateView), name: NSNotification.Name(rawValue: showTableTemplateNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTable(notification:)), name: NSNotification.Name(rawValue: reloadTableNotification), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(showListViewTemplateView), name: NSNotification.Name(rawValue: showListViewTemplateNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(processDynamicUpdates(_:)), name: KoraNotification.Widget.update.notification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(processPanelEvents(_:)), name: KoraNotification.Panel.event.notification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(navigateToComposeBar(_:)), name: KREMessageAction.navigateToComposeBar.notification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(showListWidgetViewTemplateView), name: NSNotification.Name(rawValue: showListWidgetViewTemplateNotification), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(startTypingStatusForBot), name: NSNotification.Name(rawValue: "StartTyping"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(stopTypingStatusForBot), name: NSNotification.Name(rawValue: "StopTyping"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(callingLiveSearchView(notification:)), name: NSNotification.Name(rawValue: "textViewDidChange"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(showLiveSearchViewTemplateView), name: NSNotification.Name(rawValue: showLiveSearchTemplateNotification), object: nil)
        
        
    }
    
    func removeNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidHideNotification, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: startSpeakingNotification), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: stopSpeakingNotification), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: showTableTemplateNotification), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: reloadTableNotification), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: showListViewTemplateNotification), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: showListWidgetViewTemplateNotification), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: KREMessageAction.navigateToComposeBar.notification, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "StartTyping"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "StopTyping"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "textViewDidChange"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: showLiveSearchTemplateNotification), object: nil)
    }
    
    // MARK: notification handlers
    @objc func keyboardWillShow(_ notification: Notification) {
        self.liveSearchContainerView.isHidden = false
        webViewContainerView.isHidden = true
        navigationController?.setNavigationBarHidden(false, animated: false)
        
        let keyboardUserInfo: NSDictionary = NSDictionary(dictionary: (notification as NSNotification).userInfo!)
        let keyboardFrameEnd: CGRect = ((keyboardUserInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue?)!.cgRectValue)
        let options = UIView.AnimationOptions(rawValue: UInt((keyboardUserInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as! NSNumber).intValue << 16))
        let durationValue = keyboardUserInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber
        let duration = durationValue.doubleValue
        
        var keyboardHeight = keyboardFrameEnd.size.height;
        if #available(iOS 11.0, *) {
            keyboardHeight -= self.view.safeAreaInsets.bottom
        } else {
            // Fallback on earlier versions
        };
        self.bottomConstraint.constant = keyboardHeight
        taskMenuHeight = Int(keyboardHeight)
        UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
            self.view.layoutIfNeeded()
        }, completion: { (Bool) in
            
        })
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        self.liveSearchContainerView.isHidden = true
        let keyboardUserInfo: NSDictionary = NSDictionary(dictionary: (notification as NSNotification).userInfo!)
        let durationValue = keyboardUserInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber
        let duration = durationValue.doubleValue
        let options = UIView.AnimationOptions(rawValue: UInt((keyboardUserInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as! NSNumber).intValue << 16))
        
        if taskMenuKeyBoard{
            self.bottomConstraint.constant = 0
            self.taskMenuContainerHeightConstant.constant = 0
        }
        
        UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
            self.view.layoutIfNeeded()
        }, completion: { (Bool) in
            
        })
    }
    
    @objc func didBecomeActive(_ notification: Notification) {
        startMonitoringForReachability()
    }
    
    @objc func didEnterBackground(_ notification: Notification) {
        stopMonitoringForReachability()
    }
    
    @objc func startMonitoringForReachability() {
        let networkReachabilityManager = AFNetworkReachabilityManager.shared()
        networkReachabilityManager.setReachabilityStatusChange({ (status) in
            print("Network reachability: \(AFNetworkReachabilityManager.shared().localizedNetworkReachabilityStatusString())")
            switch status {
            case AFNetworkReachabilityStatus.reachableViaWWAN, AFNetworkReachabilityStatus.reachableViaWiFi:
                self.establishBotConnection()
                break
            case AFNetworkReachabilityStatus.notReachable:
                fallthrough
            default:
                break
            }
            
            KABotClient.shared.setReachabilityStatusChange(status)
        })
        networkReachabilityManager.startMonitoring()
    }
    
    @objc func stopMonitoringForReachability() {
        AFNetworkReachabilityManager.shared().stopMonitoring()
    }
    
    @objc func navigateToComposeBar(_ notification: Notification) {
        DispatchQueue.main.async {
            self.minimizePanelWindow(false)
        }
        
        guard let params = notification.object as? [String: Any] else {
            return
        }
        
        if let utterance = params["utterance"] as? String, let options = params["options"] as? [String: Any] {
            sendTextMessage(utterance, dictionary: options, options: options)
        }
    }
    
    // MARK: - establish BotSDK connection
    func establishBotConnection() {
        KABotClient.shared.tryConnect()
    }
    
    @objc func keyboardDidShow(_ notification: Notification) {
        if (self.tapToDismissGestureRecognizer == nil) {
            self.taskMenuContainerHeightConstant.constant = 0
            self.tapToDismissGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(ChatMessagesViewController.dismissKeyboard(_:)))
            self.botMessagesView.addGestureRecognizer(tapToDismissGestureRecognizer)
        }
    }
    
    @objc func keyboardDidHide(_ notification: Notification) {
        if taskMenuKeyBoard{
            self.taskMenuContainerHeightConstant.constant = 0
            self.bottomConstraint.constant = 0
        }
        if (self.tapToDismissGestureRecognizer != nil) {
            self.botMessagesView.removeGestureRecognizer(tapToDismissGestureRecognizer)
            self.tapToDismissGestureRecognizer = nil
        }
    }
    
    @objc func dismissKeyboard(_ gesture: UITapGestureRecognizer) {
        self.liveSearchContainerView.isHidden = true
        self.bottomConstraint.constant = 0
        self.taskMenuContainerHeightConstant.constant = 0
        if (self.composeView.isFirstResponder) {
            _ = self.composeView.resignFirstResponder()
        }
    }
    
    // MARK: Helper functions
    func sendMessage(_ message: Message, dictionary: [String: Any]? = nil, options: [String: Any]?) {
        NotificationCenter.default.post(name: Notification.Name("StartTyping"), object: nil)
        NotificationCenter.default.post(name: Notification.Name(stopSpeakingNotification), object: nil)
        let composedMessage: Message = message
        if (composedMessage.components.count > 0) {
            let dataStoreManager: DataStoreManager = DataStoreManager.sharedManager
            dataStoreManager.createNewMessageIn(thread: self.thread, message: composedMessage, completion: { (success) in
                let textComponent = composedMessage.components[0] as? Component
                //                if let _ = self.botClient, let text = textComponent?.payload {
                //                    self.botClient.sendMessage(text, options: options)
                //                }
                if let _ = self.botClient, let text = textComponent?.payload {
                    self.liveSearchContainerView.isHidden = true
                    self.kaBotClient.getSearchResults(text ,success: { [weak self] (dictionary) in
                        print(dictionary)
                        self?.receviceMessage(dictionary: dictionary)
                        
                        }, failure: { (error) in
                            print(error)
                    })
                }
                
                self.textMessageSent()
            })
        }
    }
    func sendTextMessage(_ text: String, dictionary: [String: Any]? = nil, options: [String: Any]?) {
        let message: Message = Message()
        message.messageType = .default
        message.sentDate = Date()
        message.messageId = UUID().uuidString
        let textComponent: Component = Component()
        textComponent.payload = text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        message.addComponent(textComponent)
        sendMessage(message, options: options)
        
        let dic = NSMutableDictionary()
        dic.setObject(text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines), forKey: "_id" as NSCopying)
        dic.setObject(1, forKey: "count" as NSCopying)
        recentSearchArray.add(dic)
    }
    
    func receviceMessage(dictionary:[String: Any]){
        let message: Message = Message()
        message.messageType = .reply
        message.sentDate = Date()
        message.messageId = UUID().uuidString
        let textComponent: Component = Component()
        let templateType = dictionary["templateType"] as? String ?? ""
        if templateType ==  "botAction"{
            var webhookPayloadisArray : Bool?
            let webhookPalyload = (((dictionary["template"] as AnyObject).object(forKey: "webhookPayload") as AnyObject).object(forKey: "text") as AnyObject)
            webhookPayloadisArray = verifyIsObjectOfAnArray(webhookPalyload) ? true : false
            
            if webhookPayloadisArray! {
                let jsonString = (webhookPalyload.object(at: 0))
                let jsonObject: NSDictionary = Utilities.jsonObjectFromString(jsonString: jsonString as! String) as? NSDictionary ?? [:]
                if jsonObject.count > 0{
                    let templateTypenew  = ((jsonObject["payload"] as AnyObject).object(forKey: "template_type") as! String)
                               
                    let componentType = getComponentType(templateTypenew, "responsive")
                    let optionsComponent: Component = Component(componentType)
                    optionsComponent.payload = Utilities.stringFromJSONObject(object: jsonObject["payload"] as Any)
                    message.addComponent(optionsComponent)
                }else{
                    textComponent.payload = jsonString as? String
                    message.addComponent(textComponent)
                }
            }else{
                textComponent.payload = (webhookPalyload as! String)
                message.addComponent(textComponent)
            }
        }else{
            let componentType = getComponentType(templateType, "responsive")
            textComponent.payload = Utilities.stringFromJSONObject(object: dictionary)
            message.addComponent(textComponent)
            let optionsComponent: Component = Component(componentType)
            optionsComponent.payload = Utilities.stringFromJSONObject(object: dictionary)
            message.addComponent(optionsComponent)
        }
        
        addMessages(message, "")
        NotificationCenter.default.post(name: Notification.Name("StopTyping"), object: nil)
    }
    func welcomeMessage(messageString:String){
        let message: Message = Message()
        message.messageType = .reply
        message.sentDate = Date()
        message.messageId = UUID().uuidString
        let textComponent: Component = Component()
        textComponent.payload = messageString
        message.addComponent(textComponent)
        addMessages(message, "")
    }
    
    func textMessageSent() {
        self.composeView.clear()
        self.botMessagesView.scrollToTop(animate: true)
    }
    
    func speechToTextButtonAction() {
        self.configureViewForKeyboard(false)
        _ = self.composeView.resignFirstResponder()
        self.stopTTS()
        self.audioComposeView.startRecording()
        
        let options = UIView.AnimationOptions(rawValue: UInt(7 << 16))
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
        self.sendTextMessage(text, options: nil)
    }
    
    func optionsButtonTapNewAction(text:String, payload:String){
        self.sendTextMessage(text, options: ["body": payload])
    }
    
    func linkButtonTapAction(urlString: String) {
        if (urlString.count > 0) {
            let url: URL = URL(string: urlString)!
            let webViewController = SFSafariViewController(url: url)
            present(webViewController, animated: true, completion:nil)
        }
    }
    
    func populateQuickReplyCards(with message: KREMessage?) {
        if message?.templateType == (ComponentType.quickReply.rawValue as NSNumber) {
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
                self.quickReplyView.words = words
                
                self.updateQuickSelectViewConstraints()
            }
        } else if(message != nil) {
            let words: Array<Word> = Array<Word>()
            self.quickReplyView.words = words
            self.closeQuickSelectViewConstraints()
        }
    }
    
    func closeQuickReplyCards(){
        self.closeQuickSelectViewConstraints()
    }
    
    func updateQuickSelectViewConstraints() {
        if self.quickSelectContainerHeightConstraint.constant == 60.0 {return}
        
        self.quickSelectContainerHeightConstraint.constant = 60.0
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
    
    func populateCalenderView(with message: KREMessage?) {
        var messageId = ""
        if message?.templateType == (ComponentType.calendarView.rawValue as NSNumber) {
            let component: KREComponent = message!.components![0] as! KREComponent
            print(component)
            if (!component.isKind(of: KREComponent.self)) {
                return;
            }
            if (component.message != nil) {
                messageId = component.message!.messageId!
            }
            if ((component.componentDesc) != nil) {
                let jsonString = component.componentDesc
                let calenderViewController = CalenderViewController(dataString: jsonString!, chatId: messageId, kreMessage: message!)
                calenderViewController.viewDelegate = self
                calenderViewController.modalPresentationStyle = .overFullScreen
                self.navigationController?.present(calenderViewController, animated: true, completion: nil)
            }
        }
    }
    
    func populateFeedbackSliderView(with message: KREMessage?) {
        var messageId = ""
        if message?.templateType == (ComponentType.feedbackTemplate.rawValue as NSNumber) {
            let component: KREComponent = message!.components![0] as! KREComponent
            print(component)
            if (!component.isKind(of: KREComponent.self)) {
                return;
            }
            if (component.message != nil) {
                messageId = component.message!.messageId!
            }
            if ((component.componentDesc) != nil) {
                let jsonString = component.componentDesc
                let feedbackViewController = FeedbackSliderViewController(dataString: jsonString!)
                feedbackViewController.viewDelegate = self
                feedbackViewController.modalPresentationStyle = .overFullScreen
                self.navigationController?.present(feedbackViewController, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: ComposeBarViewDelegate methods
    
    func composeBarView(_: ComposeBarView, sendButtonAction text: String) {
        self.sendTextMessage(text, options: nil)
    }
    
    func composeBarViewSpeechToTextButtonAction(_: ComposeBarView) {
        KoraASRService.shared.checkAudioRecordPermission({ [weak self] in
            self?.isShowAudioComposeView = true
            self?.speechToTextButtonAction()
        })
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ClosePanel"), object: nil)
    }
    
    func composeBarViewDidBecomeFirstResponder(_: ComposeBarView) {
        self.audioComposeView.stopRecording()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ClosePanel"), object: nil)
    }
    
    func composeBarTaskMenuButtonAction(_: ComposeBarView) {
        self.bottomConstraint.constant = 0
        self.taskMenuContainerHeightConstant.constant = 0
        if (self.composeView.isFirstResponder) {
            _ = self.composeView.resignFirstResponder()
        }
        
        let taskMenuViewController = TaskMenuViewController()
        taskMenuViewController.modalPresentationStyle = .overFullScreen
        taskMenuViewController.viewDelegate = self
        taskMenuViewController.view.backgroundColor = .white
        self.navigationController?.present(taskMenuViewController, animated: false, completion: nil)
    }
    
    // MARK: KREGrowingTextViewDelegate methods
    func growingTextView(_: KREGrowingTextView, changingHeight height: CGFloat, animate: Bool) {
        UIView.animate(withDuration: animate ? 0.25: 0.0) {
            self.view.layoutIfNeeded()
        }
    }
    
    func growingTextView(_: KREGrowingTextView, willChangeHeight height: CGFloat) {
        
    }
    
    func growingTextView(_: KREGrowingTextView, didChangeHeight height: CGFloat) {
        
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
            try audioSession.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.default, options: AVAudioSession.CategoryOptions.defaultToSpeaker)
            try audioSession.setMode(AVAudioSession.Mode.default)
        } catch {
            
        }
        let string = text
        print("Reading text: ", string);
        let speechUtterance = AVSpeechUtterance(string: string)
        self.speechSynthesizer.speak(speechUtterance)
    }
    
    func stopTTS(){
        if(self.speechSynthesizer.isSpeaking){
            self.speechSynthesizer.stopSpeaking(at: AVSpeechBoundary.immediate)
        }
    }
    
    // MARK: show tying status view
    func showTypingStatusForBotsAction() {
        let botId:String = "u-40d2bdc2-822a-51a2-bdcd-95bdf4po8331c9";
        let info:NSMutableDictionary = NSMutableDictionary.init()
        info.setValue(botId, forKey: "botId");
        info.setValue("findly", forKey: "imageName");
        
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
    
    // MARK: show NewListViewDetailsTemplateView
    @objc func showListViewTemplateView(notification:Notification) {
        let dataString: String = notification.object as! String
        let listViewDetailsViewController = ListViewDetailsViewController(dataString: dataString)
        listViewDetailsViewController.viewDelegate = self
        listViewDetailsViewController.modalPresentationStyle = .overFullScreen
        self.navigationController?.present(listViewDetailsViewController, animated: true, completion: nil)
    }
    
    @objc func showListWidgetViewTemplateView(notification:Notification){
        let dataString: String = notification.object as! String
        let listViewDetailsViewController = ListWidgetDetailsViewController(dataString: dataString)
        listViewDetailsViewController.viewDelegate = self
        listViewDetailsViewController.modalPresentationStyle = .overFullScreen
        listViewDetailsViewController.view.backgroundColor = .white
        self.navigationController?.present(listViewDetailsViewController, animated: true, completion: nil)
    }
    
    @objc func showLiveSearchViewTemplateView(notification:Notification){
        let dataString: String = notification.object as! String
        let liveSearchDetailsViewController = LiveSearchDetailsViewController(dataString: dataString)
        liveSearchDetailsViewController.viewDelegate = self
        liveSearchDetailsViewController.modalPresentationStyle = .overFullScreen
        liveSearchDetailsViewController.view.backgroundColor = .white
        self.navigationController?.present(liveSearchDetailsViewController, animated: true, completion: nil)
    }
    
    // MARK: -
    public func maximizePanelWindow() {
        
    }
    
    public func minimizePanelWindow(_ canValidateSession: Bool = true) {
        sheetController?.dismissAllPresentedViewControllers { [weak self] in
            self?.sheetController?.closeSheet(completion: {
                self?.sheetController = nil
            })
        }
    }
}

// MARK: -
extension ChatMessagesViewController {
    // MARK: - get history
    public func getMessages(offset: Int) {
        guard historyRequestInProgress == false else {
            return
        }
        
        botClient.getHistory(offset: offset, success: { [weak self] (responseObj) in
            if let responseObject = responseObj as? [String: Any], let messages = responseObject["messages"] as? Array<[String: Any]> {
                self?.insertOrUpdateHistoryMessages(messages)
            }
            self?.historyRequestInProgress = false
            }, failure: { [weak self] (error) in
                self?.historyRequestInProgress = false
                print("Unable to fetch messges \(error?.localizedDescription ?? "")")
        })
    }
    
    public func getRecentHistory() {
        guard messagesRequestInProgress == false else {
            return
        }
        
        let dataStoreManager = DataStoreManager.sharedManager
        let context = dataStoreManager.coreDataManager.workerContext
        messagesRequestInProgress = true
        let request: NSFetchRequest<KREMessage> = KREMessage.fetchRequest()
        let isSenderPredicate = NSPredicate(format: "isSender == \(false)")
        request.predicate = isSenderPredicate
        let sortDates = NSSortDescriptor(key: "sentOn", ascending: false)
        request.sortDescriptors = [sortDates]
        request.fetchLimit = 1
        
        context.perform { [weak self] in
            guard let array = try? context.fetch(request), array.count > 0 else {
                self?.messagesRequestInProgress = false
                return
            }
            
            guard let messageId = array.first?.messageId else {
                self?.messagesRequestInProgress = false
                return
            }
            
            self?.botClient.getMessages(after: messageId, direction: 1, success: { (responseObj) in
                if let responseObject = responseObj as? [String: Any]{
                    if let messages = responseObject["messages"] as? Array<[String: Any]> {
                        self?.insertOrUpdateHistoryMessages(messages)
                    }
                }
                self?.messagesRequestInProgress = false
            }, failure: { (error) in
                self?.messagesRequestInProgress = false
                print("Unable to fetch history \(error?.localizedDescription ?? "")")
            })
        }
    }
    
    // MARK: - insert or update messages
    func insertOrUpdateHistoryMessages(_ messages: Array<[String: Any]>) {
        guard let botMessages = try? MTLJSONAdapter.models(of: BotMessages.self, fromJSONArray: messages) as? [BotMessages], botMessages.count > 0 else {
            return
        }
        
        var allMessages: [Message] = [Message]()
        for message in botMessages {
            if message.type == "outgoing" || message.type == "incoming" {
                guard let components = message.components, let data = components.first?.data else {
                    continue
                }
                
                guard let jsonString = data["text"] as? String else {
                    continue
                }
                
                let botMessage: BotMessageModel = BotMessageModel()
                botMessage.createdOn = message.createdOn
                botMessage.messageId = message.messageId
                botMessage.type = message.type
                
                let messageModel: MessageModel = MessageModel()
                let componentModel: ComponentModel = ComponentModel()
                if jsonString.contains("payload"), let jsonObject: [String: Any] = Utilities.jsonObjectFromString(jsonString: jsonString) as? [String : Any] {
                    componentModel.type = jsonObject["type"] as? String
                    
                    var payloadObj: [String: Any] = [String: Any]()
                    payloadObj["payload"] = jsonObject["payload"] as! [String : Any]
                    payloadObj["type"] = jsonObject["type"]
                    componentModel.payload = payloadObj
                } else {
                    var payloadObj: [String: Any] = [String: Any]()
                    payloadObj["text"] = jsonString
                    payloadObj["type"] = "text"
                    componentModel.type = "text"
                    componentModel.payload = payloadObj
                }
                
                messageModel.type = "text"
                messageModel.component = componentModel
                botMessage.messages = [messageModel]
                let messageTuple = onReceiveMessage(object: botMessage)
                if let object = messageTuple.0 {
                    allMessages.append(object)
                }
            }
        }
        
        // insert all messages
        if allMessages.count > 0 {
            let dataStoreManager = DataStoreManager.sharedManager
            dataStoreManager.insertMessages(allMessages, in: thread, completion: nil)
        }
    }
    
    // MARK: - fetch messages
    func fetchMessages() {
        let dataStoreManager = DataStoreManager.sharedManager
        dataStoreManager.getMessagesCount(completion: { [weak self] (count) in
            if count == 0 {
                self?.getMessages(offset: 0)
            }
        })
    }
}
extension ChatMessagesViewController: KABotClientDelegate {
    func showTypingStatusForBot() {
        self.typingStatusView?.addTypingStatus(forContact: [:], forTimeInterval: 0.5)
    }
    
    // MARK: - KABotlientDelegate methods
    open func botConnection(with connectionState: BotClientConnectionState) {
        updateNavBarPrompt()
        
    }
    
    @objc func startTypingStatusForBot() {
        self.typingStatusView?.isHidden = true
        let botId:String = SDKConfiguration.botConfig.botId
        let info:NSMutableDictionary = NSMutableDictionary.init()
        info.setValue(botId, forKey: "botId");
        let urlString = leftImage.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        info.setValue(urlString ?? "findly", forKey: "imageName");
        self.typingStatusView?.addTypingStatus(forContact: info, forTimeInterval: 0.5)
    }
    
    @objc func stopTypingStatusForBot(){
        self.typingStatusView?.timerFired(toRemoveTypingStatus: nil)
    }
    
    @objc func callingLiveSearchView(notification:Notification) {
        navigationController?.setNavigationBarHidden(false, animated: false)
        let dataString: String = notification.object as! String
        print("chatView: \(dataString)")
        if liveSearchContainerView.isHidden{
            if dataString != ""{
                liveSearchContainerView.isHidden = false
            }
        }
    }
}
// MARK: - requests
extension ChatMessagesViewController {
    func populatePanelItems() {
        let widgetManager = KREWidgetManager.shared
        panelCollectionView.startAnimating()
        widgetManager.getPanelItems { [weak self] (success, items, error) in
            DispatchQueue.main.async {
                self!.panelCollectionView.stopAnimating(error)
                guard let panelItems = items as? [KREPanelItem] else {
                    return
                }
                
                self?.showHomePanel(completion: {
                    
                })
                //KoraApplication.sharedInstance.account?.validateTimeZone()
                self!.panelCollectionView.items = panelItems
                widgetManager.getPriorityWidgets(from: panelItems, block: nil)
                NotificationCenter.default.post(name: KoraNotification.Panel.update.notification, object: nil)
                
                if let _ = error  {
                    
                }
            }
        }
    }
    
    @objc func processDynamicUpdates(_ notification: Notification?) {
        guard let dictionary = notification?.object as? [String: Any],
            let type = dictionary["t"] as? String, let _ = dictionary["uid"] as? String else {
                return
        }
        
        switch type {
        case "kaa":
            let panelItems = self.panelCollectionView.items
            guard let panelItem = panelItems?.filter({ $0.iconId == "announcement" }).first else {
                return
            }
            
            let widgetManager = KREWidgetManager.shared
            widgetManager.getWidgets(in: panelItem, forceReload: true, update: { [weak self] (success, widget) in
                DispatchQueue.main.async {
                    self?.updatePanel(with: panelItem)
                }
                }, completion: nil)
        default:
            break
        }
    }
    
    @objc func processPanelEvents(_ notification: Notification?) {
        guard let dictionary = notification?.object as? [String: Any],
            let type = dictionary["entity"] as? String else {
                return
        }
        
        switch type {
        case "panels":
            populatePanelItems()
            if let data = dictionary["data"] as? [String: Any] {
                KREWidgetManager.shared.pinOrUnpinWidget(data)
            }
        default:
            break
        }
    }
    
    public func showHomePanel(_ isOnboardingInProgress: Bool = false, completion block:(()->Void)? = nil) {
        let panelItems = KREWidgetManager.shared.panelItems
        guard launchOptions == nil else {
            return
        }
        
        let panelBar = panelCollectionView
        switch panelBar!.panelState {
        case .loaded:
            guard let panelItem = panelItems?.filter({ $0.name == "Quick Summar" }).first else {
                return
            }
            
            panelCollectionView.panelItemHandler?(panelItem) { [weak self] in
                if !isOnboardingInProgress {
                    self?.startTryOut()
                }
                block?()
            }
            
        default:
            break
        }
    }
    
    func updatePanel(with panelItem: KREPanelItem) {
        guard let panelItemViewController = sheetController?.childViewController as? KAPanelItemViewController else {
            return
        }
        
        panelItemViewController.updatePanel(with: panelItem)
    }
    // MARK: - tryout
    open func startTryOut() {
        
    }
    // MARK: -
    func processActionPanelItem(_ item: KREPanelItem?) {
        if let uriString = item?.action?.uri, let url = URL(string: uriString + "?teamId=59196d5a0dd8e3a07ff6362b") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    func verifyIsObjectOfAnArray<T>(_ object: T) -> Bool {
       if let _ = object as? [T] {
          return true
       }

       return false
    }
}

