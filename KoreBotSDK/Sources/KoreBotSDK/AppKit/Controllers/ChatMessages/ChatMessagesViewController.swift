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
import CoreData
import FMPhotoPicker
import Photos
import MobileCoreServices
import Alamofire
import AlamofireImage
import ObjectMapper

#if SWIFT_PACKAGE
//import KoreBotSDKAgent
import ObjcSupport
#endif

class ChatMessagesViewController: UIViewController, BotMessagesViewDelegate, ComposeBarViewDelegate, KREGrowingTextViewDelegate, NewListViewDelegate, TaskMenuNewDelegate, calenderSelectDelegate, ListWidgetViewDelegate, feedbackViewDelegate, CustomTableTemplateDelegate, WelcomeScreenViewDelegate, ArticleViewDelegate, OTPValidationDelegate, resetPinDelegate {
    // MARK: properties
    var messagesRequestInProgress: Bool = false
    var historyRequestInProgress: Bool = false
    var thread: KREThread?
    var botClient: BotClient!
    var tapToDismissGestureRecognizer: UITapGestureRecognizer!
    var kaBotClient: KABotClient!
    
    @IBOutlet weak var threadContainerView: UIView!
    @IBOutlet weak var quickSelectContainerView: UIView!
    @IBOutlet weak var composeBarContainerView: UIView!
    @IBOutlet weak var audioComposeContainerView: UIView!
    @IBOutlet weak var panelCollectionViewContainerView: UIView!
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var headerTitileLbl: UILabel!
    @IBOutlet var chatMaskview: UIView!
    @IBOutlet var leftMenuContainerView: UIView!
    @IBOutlet weak var leftMenuContainerSubView: UIView!
    @IBOutlet weak var leftMenuBackBtn: UIButton!
    var leftMenuView: LeftMenuView!
    @IBOutlet var leftMenuTitleLbl: UILabel!
    let linerProgressBar: LinearProgressBar = {
        let progressBar = LinearProgressBar()
        progressBar.backgroundColor = .clear
        progressBar.progressBarColor = themeColor
        progressBar.progressBarWidth = 4
        progressBar.cornerRadius = 2
        
        return progressBar
    }()
    
    @IBOutlet weak var quickSelectContainerHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var attachmentContainerView: UIView!
    @IBOutlet weak var attachmentContainerHeightConstraint: NSLayoutConstraint!
    var attachmentArray = NSMutableArray()
    @IBOutlet weak var attachmentCollectionView: UICollectionView!
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
    @IBOutlet weak var backgroungImageView: UIImageView!
    
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
    
    var offSet = 0
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
    @IBOutlet weak var dropDownBtn: UIButton!
    
    let bundleImage = Bundle.sdkModule
    var phassetToUpload: PHAsset?
    var componentSelectedToupload: Component?
    public weak var account = KoraApplication.sharedInstance.account
    var isShowWelcomeScreen = false
    @IBOutlet weak var statusBarView: UIView!
    var welcomeScreenView: WelcomeScreenView!
    @IBOutlet weak var chatWelcomeScreenContainerView: UIView!
    @IBOutlet weak var headerTitleLbl: UILabel!
    var headerDic = HeaderModel()
    @IBOutlet weak var headerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var incomingCallContainerView: UIView!
    var inComingCallView: InComingCallView!
    var callFromAgentData: [String: Any]? = [:]
    var appDisplayName = "Kore Bot SDK"
    var isAppEnterBackground = false
    public var closeAndMinimizeEvent: ((_ dic: [String:Any]?) -> Void)!
    var quickReplyViewLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var footerStatusBarView: UIView!
#if SWIFT_PACKAGE
    //let agentConnect = AgentConnect()
#endif
    // MARK: init
    init() {
        super.init(nibName: "ChatMessagesViewController", bundle: .sdkModule)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        appDisplayName = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ?? SDKConfiguration.botConfig.chatBotName
        isAppEnterBackground = false
        isTryConnect = true
        isBotConnectSucessFully = false
        networkMonitoringForReachability()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        self.incomingCallContainerView.isHidden = true
        linerProgressBar.frame = CGRect(x: 0, y: 0 , width: UIScreen.main.bounds.size.width, height:1)
        headerView.addSubview(linerProgressBar)
        //Initialize elements
        self.configureQuickReplyView()
        self.configureTypingStatusView()
        self.configureSTTClient()
        self.configAttachmentCollectionView()
        self.botConnectingMethod()
        panelCollectionViewContainerHeightConstraint.constant = 0
        isSpeakingEnabled = false
        self.speechSynthesizer = AVSpeechSynthesizer()
        self.view.bringSubviewToFront(chatMaskview)
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addNotifications()
        navigationController?.setNavigationBarHidden(true, animated: false)
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
    
//    override var preferredStatusBarStyle: UIStatusBarStyle {
//        return .lightContent
//    }
    
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
        if composeView != nil{
            self.composeView.growingTextView.viewDelegate = nil
            self.composeView.delegate = nil
        }
        if audioComposeView != nil{
            self.audioComposeView.prepareForDeinit()
        }
        
        if botMessagesView != nil{
            self.botMessagesView.prepareForDeinit()
            self.botMessagesView.viewDelegate = nil
        }
        if quickReplyView != nil{
            self.quickReplyView.sendQuickReplyAction = nil
        }
        
    }
    
    // MARK: cancel
    @objc func cancel(_ sender: Any) {
        botClosed()
    }
    
    func botClosed(){
        isTryConnect = false
        //isShowWelcomeMsg = true // Set fasle here.. when you go back and come chat sceen new welcome message not displied.
        if isAgentConnect{
            self.botClient.sendEventToAgentChat(eventName: "close_agent_chat",messageId: "")
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { (_) in
                self.prepareForDeinit()
                self.navigationController?.dismiss(animated: false)
            }
        }else{
            prepareForDeinit()
            navigationController?.dismiss(animated: false)
        }
    }
    @IBAction func tapsOnBackBtnAct(_ sender: Any) {
        if self.isShowWelcomeScreen{
            view.endEditing(true)
            chatWelcomeScreenContainerView.isHidden = false
        }else{
            //botClosed()
            //isShowWelcomeMsg = true
            showCloseOrMinimiseAlert()
        }
    }
    
    func showCloseOrMinimiseAlert(){
        let alertController = UIAlertController(title: "", message: "Would you like to close the concersation or minimize.", preferredStyle:.alert)
        alertController.addAction(UIAlertAction(title: "Close", style: .default)
                  { action -> Void in
                        isShowWelcomeMsg = true
                        let dic = ["event_code": "BotClosed", "event_message": "Bot closed by the user"]
                        self.closeAndMinimizeEvent(dic)
                       if isAgentConnect{
                           self.botClient.sendEventToAgentChat(eventName: close_AgentChat_EventName,messageId: "")
                           Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { (_) in
                               self.botClosed()
                           }
                       }else{
                               self.botClosed()
                       }
                        
                  })
        alertController.addAction(UIAlertAction(title: "Minimize", style: .default)
                  { action -> Void in
                        let dic = ["event_code": "BotMinimized", "event_message": "Bot Minimized by the user"]
                        self.closeAndMinimizeEvent(dic)
                        self.botClosed()
                  })
        self.present(alertController, animated: true, completion: nil)
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
        
        self.composeViewBottomConstraint = NSLayoutConstraint.init(item: self.composeBarContainerView as Any, attribute: .bottom, relatedBy: .equal, toItem: self.composeView, attribute: .bottom, multiplier: 1.0, constant: 0.0)
        self.composeBarContainerView.addConstraint(self.composeViewBottomConstraint)
        self.composeViewBottomConstraint.isActive = false
        
        self.composeBarContainerHeightConstraint = NSLayoutConstraint.init(item: self.composeBarContainerView as Any, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 0.0)
        self.view.addConstraint(self.composeBarContainerHeightConstraint)
    }
    
    func configureAudioComposer()  {
        self.audioComposeView = AudioComposeView()
        self.audioComposeView.translatesAutoresizingMaskIntoConstraints = false
        self.audioComposeContainerView.addSubview(self.audioComposeView!)
        
        self.audioComposeContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[audioComposeView]|", options:[], metrics:nil, views:["audioComposeView" : self.audioComposeView!]))
        self.audioComposeContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[audioComposeView]|", options:[], metrics:nil, views:["audioComposeView" : self.audioComposeView!]))
        
        self.audioComposeContainerHeightConstraint = NSLayoutConstraint.init(item: self.audioComposeContainerView as Any, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 0.0)
        self.view.addConstraint(self.audioComposeContainerHeightConstraint)
        self.audioComposeContainerHeightConstraint.isActive = false
        
        self.audioComposeView.voiceRecordingStarted = { [weak self] (composeBar) in
            self?.stopTTS()
            self?.composeView.changeBgColorForAudioComposeBar()
        }
        self.audioComposeView.voiceRecordingStopped = { [weak self] (composeBar) in
            self?.sttClient.stopRecording()
        }
        self.audioComposeView.getAudioPeakOutputPower = { () in
            return 0.0
        }
        self.audioComposeView.onKeyboardButtonAction = { [weak self] () in
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ClosePanel"), object: nil)
            self?.composeView.changeBgColorForComposeBar()
            self?.isShowAudioComposeView = false
            _ = self?.composeView.becomeFirstResponder()
            self?.configureViewForKeyboard(true)
        }
        self.audioComposeView.audioComposeBarTaskMenuButtonAction = { [weak self] () in
            self?.audioComposeBarTaskMenuButtonAction()
        }
        self.audioComposeView.audioComposeBarAttachmentButtonAction = { [weak self] () in
            self?.openAcionSheet()
        }
    }
    
    func configureQuickReplyView() {
        self.quickReplyView = KREQuickSelectView()
        self.quickReplyView.translatesAutoresizingMaskIntoConstraints = false
        self.quickSelectContainerView.addSubview(self.quickReplyView)
        let bgColor = btnBgActiveColor
        let textColor = btnActiveTextColor
        self.quickReplyView.bgColor = bgColor
        self.quickReplyView.textColor = textColor
        self.quickReplyView.boarderColor = textColor
        self.quickReplyView.fontName = mediumCustomFont
        self.quickSelectContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-40-[quickReplyView]-15-|", options:[], metrics:nil, views:["quickReplyView" : self.quickReplyView as Any]))
        self.quickSelectContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[quickReplyView]-5-|", options:[], metrics:nil, views:["quickReplyView" : self.quickReplyView as Any]))
        
        quickReplyViewLeadingConstraint = NSLayoutConstraint(item:self.quickReplyView as Any, attribute:.leading, relatedBy:.equal, toItem:self.quickSelectContainerView, attribute:.leading, multiplier:1.0, constant:40)
        self.quickSelectContainerView.addConstraints([quickReplyViewLeadingConstraint])
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
        
        kaBotClient = KABotClient()
        kaBotClient.delegate = self
        
        self.typingStatusView = KRETypingStatusView()
        self.typingStatusView?.isHidden = true
        self.typingStatusView?.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.typingStatusView!)
        
        let views: [String: Any] = ["typingStatusView" : self.typingStatusView as Any, "composeBarContainerView" : self.composeBarContainerView as Any]
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[typingStatusView]", options:[], metrics:nil, views: views)) //-20
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[typingStatusView(40)][composeBarContainerView]", options:[], metrics:nil, views: views))
        
    }
    
    func getComponentType(_ templateType: String,_ tabledesign: String) -> ComponentType {
        if (templateType == "quick_replies") {
            return .quickReply
        } else if (templateType == "buttonn") {
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
        else if (templateType == "mini_table_horizontal") {
            return .minitable_Horizontal
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
        else if (templateType == "daterange" || templateType == "dateTemplate" || templateType == "clockTemplate") {
            return .calendarView
        }
        else if (templateType == "quick_replies_welcome" || templateType == "button"){
            return .quick_replies_welcome
        }
        else if (templateType == "Notification") {
            return .notification
        }
        else if (templateType == "multi_select") {
            return .multiSelect
        }
        else if (templateType == "listWidget") {
            return .list_widget
        }
        else if (templateType == "feedbackTemplate") {
            return .feedbackTemplate
        }
        else if (templateType == "form_template") {
            return .inlineForm
        }
        else if (templateType == "dropdown_template") {
            return .dropdown_template
        }else if (templateType == "custom_table")
        {
            return .custom_table
        }else if (templateType == "advancedListTemplate"){
            return .advancedListTemplate
        }else if (templateType == "cardTemplate"){
            return .cardTemplate
        }else if (templateType == "stacked"){
            return .stackedCarousel
        }else if templateType == "advanced_multi_select"{
            return .advanced_multi_select
        }else if templateType == "radioOptionTemplate"{
            return .radioOptionTemplate
        }else if templateType == "quick_replies_top"{
            return .quick_replies_top
        }
        else if templateType == "articleTemplate"{
            return .articleTemplate
        }else if templateType == "answerTemplate"{
            return .answerTemplate
        }else if templateType == "otpValidationTemplate" || templateType == "resetPinTemplate"{
            return .OtpOrResetTemplate
        }
        else if templateType == "text"{
            return .text
        }
        return .noTemplate
    }
    
    func onReceiveMessage(object: BotMessageModel?) -> (Message?, String?) {
        isOTPValidationTemplate = false
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
        }else{
            message.iconUrl = botHistoryIcon
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
                if let text: NSString = payload["text"] as? NSString{
                    let textComponent: Component = Component()
                    textComponent.payload = text as String
                    ttsBody = text as String
                    
                    if(text.contains("use a web form")){
                        let range: NSRange = text.range(of: "use a web form - ")
//                        let urlString: String? = text.substring(with: NSMakeRange(range.location+range.length, 44))
//                        if (urlString != nil) {
//                            let url: URL = URL(string: urlString!)!
//                            webViewController = SFSafariViewController(url: url)
//                            webViewController.modalPresentationStyle = .custom
//                            present(webViewController, animated: true, completion:nil)
//                        }
                        ttsBody = "Ok, Please fill in the details and submit"
                    }
                    message.addComponent(textComponent)
                }else{
                    if let dictionary = payload["payload"] as? [String: Any],
                       let text = dictionary["text"] as? String{
                        let textComponent = Component()
                        textComponent.payload = text
                        ttsBody = text
                        message.addComponent(textComponent)
                    }
                }
                return (message, ttsBody)
            } else if (componentModel.type == "image") {
                if let payload = componentModel.payload as? [String: Any] {
                    if let dictionary = payload["payload"] as? [String: Any] {
                        let optionsComponent: Component = Component(.image)
                        optionsComponent.payload = Utilities.stringFromJSONObject(object: dictionary)
                        message.sentDate = object?.createdOn
                        message.addComponent(optionsComponent)
                        return (message, ttsBody)
                    }
                }
            }else if (componentModel.type == "template") {
                let payload: NSDictionary = componentModel.payload! as! NSDictionary
                let text: String = payload["text"] != nil ? payload["text"] as! String : ""
                let type: String = payload["type"] != nil ? payload["type"] as! String : ""
                ttsBody = payload["speech_hint"] != nil ? payload["speech_hint"] as? String : nil
                
                if (type == "template") {
                    let dictionary: NSDictionary = payload["payload"] as! NSDictionary
                    var templateType: String = dictionary["template_type"] as? String ?? ""
                    var tabledesign: String
                    
                    tabledesign  = (dictionary["table_design"] != nil ? dictionary["table_design"] as? String : "responsive")!
                    
                    if templateType == "mini_table"{
                        if let layOut = dictionary["layout"] as? String, layOut == "horizontal"{
                            templateType = "mini_table_horizontal"
                        }
                    }
                    
                    let componentType = self.getComponentType(templateType,tabledesign)
                    
                    if componentType != .quickReply {
                        
                    }
                    if templateType == "otpValidationTemplate" || templateType == "resetPinTemplate"{
                        //isOTPValidationTemplate = true
                        //OTPValidationRemoveCount += 1
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
                    if templateType == "SYSTEM" || templateType == "live_agent"{
                        let textComponent = Component(.text)
                        let text = dictionary["text"] as? String ?? ""
                        textComponent.payload = text
                        ttsBody = text
                        message.addComponent(textComponent)
                    }else{
                        let optionsComponent: Component = Component(componentType)
                        optionsComponent.payload = Utilities.stringFromJSONObject(object: dictionary)
                        message.sentDate = object?.createdOn
                        message.addComponent(optionsComponent)
                    }
                    
                }else if (type == "image"){
                    
                    if let dictionary = payload["payload"] as? [String: Any] {
                        let optionsComponent: Component = Component(.image)
                        optionsComponent.payload = Utilities.stringFromJSONObject(object: dictionary)
                        message.sentDate = object?.createdOn
                        message.addComponent(optionsComponent)
                    }
                }
                else if (type == "message"){
                    
                    if let dictionary = payload["payload"] as? [String: Any] {
                        let  componentType = dictionary["audioUrl"] != nil ? Component(.audio) : Component(.video)
                        let optionsComponent: Component = componentType
                        if let speechText = dictionary["text"] as? String{
                            ttsBody = speechText
                        }
                        optionsComponent.payload = Utilities.stringFromJSONObject(object: dictionary)
                        message.sentDate = object?.createdOn
                        message.addComponent(optionsComponent)
                    }
                }
                else if (type == "video"){
                    
                    if let _ = payload["payload"] as? [String: Any] {
                        let  componentType = Component(.video)
                        let optionsComponent: Component = componentType
                        optionsComponent.payload = Utilities.stringFromJSONObject(object: payload)
                        message.sentDate = object?.createdOn
                        message.addComponent(optionsComponent)
                    }
                }
                else if (type == "audio"){
                    
                    if let dictionary = payload["payload"] as? [String: Any] {
                        let  componentType = Component(.audio)
                        let optionsComponent: Component = componentType
                        optionsComponent.payload = Utilities.stringFromJSONObject(object: dictionary)
                        message.sentDate = object?.createdOn
                        message.addComponent(optionsComponent)
                    }
                }
                else if (type == "link"){
                    
                    if let dictionary = payload["payload"] as? [String: Any] {
                        let  componentType = Component(.linkDownload)
                        let optionsComponent: Component = componentType
                        optionsComponent.payload = Utilities.stringFromJSONObject(object: dictionary)
                        message.sentDate = object?.createdOn
                        message.addComponent(optionsComponent)
                    }
                    
                }else if (type == "error") {
                    let dictionary: NSDictionary = payload["payload"] as! NSDictionary
                    let errorComponent: Component = Component(.error)
                    errorComponent.payload = Utilities.stringFromJSONObject(object: dictionary)
                    message.addComponent(errorComponent)
                    ttsBody = dictionary["speech_hint"] != nil ? dictionary["speech_hint"] as? String : nil
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(dropDownTemplateActtion), name: NSNotification.Name(rawValue: dropDownTemplateNotification), object: nil)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(showCustomTableTemplateView), name: NSNotification.Name(rawValue: showCustomTableTemplateNotification), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(showPDFViewController), name: NSNotification.Name(rawValue: pdfcTemplateViewNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showPDFErrorMeesage), name: NSNotification.Name(rawValue: pdfcTemplateViewErrorNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(callFromAgent), name: NSNotification.Name(rawValue: callFromAgentNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willTerminate(_:)), name: UIApplication.willTerminateNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(tokenExpiry), name: NSNotification.Name(rawValue: tokenExipryNotification), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(showArticleTemplateView), name: NSNotification.Name(rawValue: showArticleTemplateNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(OTPvalidateTemplateActtion), name: NSNotification.Name(rawValue: otpValidationTemplateNotification), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(resetPinTemplateActtion), name: NSNotification.Name(rawValue: resetpinTemplateNotification), object: nil)
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
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: showAttachmentSendButtonNotification), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "StartTyping"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "StopTyping"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: dropDownTemplateNotification), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: showCustomTableTemplateNotification), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: reloadVideoCellNotification), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: pdfcTemplateViewNotification), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: pdfcTemplateViewErrorNotification), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: callFromAgentNotification), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: tokenExipryNotification), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: showArticleTemplateNotification), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: otpValidationTemplateNotification), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: resetpinTemplateNotification), object: nil)

    }
    
    // MARK: notification handlers
    @objc func keyboardWillShow(_ notification: Notification) {
        let keyboardUserInfo: NSDictionary = NSDictionary(dictionary: (notification as NSNotification).userInfo!)
        let keyboardFrameEnd: CGRect = ((keyboardUserInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue?)!.cgRectValue)
        let options = UIView.AnimationOptions(rawValue: UInt((keyboardUserInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as! NSNumber).intValue << 16))
        let durationValue = keyboardUserInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber
        let duration = durationValue.doubleValue
        
        var keyboardHeight = keyboardFrameEnd.size.height;
        if #available(iOS 11.0, *) {
            keyboardHeight -= self.view.safeAreaInsets.bottom
        } else {
            
        };
        self.bottomConstraint.constant = keyboardHeight
        taskMenuHeight = Int(keyboardHeight)
        UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
            self.view.layoutIfNeeded()
        }, completion: { (Bool) in
            
        })
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
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
        isAppEnterBackground = true
        stopMonitoringForReachability()
    }
    
    @objc func startMonitoringForReachability() {
        let networkReachabilityManager = NetworkReachabilityManager.default
        networkReachabilityManager?.startListening(onUpdatePerforming: { (status) in
            print("Network reachability: \(status)")
            switch status {
            case .reachable(.ethernetOrWiFi), .reachable(.cellular):
                if isTryConnect{
                    isInternetAvailable = true
                    if !SDKConfiguration.botConfig.isWebhookEnabled{
                        if isNetworkOnResumeCallingHistory{
                            loadReconnectionHistory = true
                        }
                        self.establishBotConnection()
                    }
                    if isAgentConnect{
                        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { (_) in
                            self.stopLoader()
                        }
                    }else{
                        self.stopLoader()
                    }
                }
                break
            case .notReachable:
                if isTryConnect{
                    isInternetAvailable = false
                    self.showLoader()
                }
                fallthrough
            default:
                break
            }
            
            KABotClient.shared.setReachabilityStatusChange(status)
        })
    }
    
    @objc func networkMonitoringForReachability() {
        let networkReachabilityManager = NetworkReachabilityManager.default
        networkReachabilityManager?.startListening(onUpdatePerforming: { (status) in
            print("Network reach \(status)")
            switch status {
            case .reachable(.ethernetOrWiFi), .reachable(.cellular):
                if isTryConnect{
                    isInternetAvailable = true
                    if isBotConnectSucessFully{
                        if !self.isAppEnterBackground{
                            if !SDKConfiguration.botConfig.isWebhookEnabled{
                                if isNetworkOnResumeCallingHistory{
                                    loadReconnectionHistory = true
                                }
                                self.establishBotConnection()
                            }
                        }
                        self.stopLoader()
                    }
                }
                break
            case .notReachable:
                if isTryConnect{
                    isInternetAvailable = false
                    if isBotConnectSucessFully{
                        self.showLoader()
                    }
                }
                fallthrough
            default:
                break
            }
            
            KABotClient.shared.setReachabilityStatusChange(status)
        })
    }
    
    @objc func stopMonitoringForReachability() {
        NetworkReachabilityManager.default?.stopListening()
    }
    
    @objc func willTerminate(_ notification: Notification) {
        if isAgentConnect{
            self.botClient.sendEventToAgentChat(eventName: "close_agent_chat",messageId: "")
            sleep(1)
        }
    }
    func showTypingToAgent(_: ComposeBarView){
        if isAgentConnect{
            self.botClient.sendEventToAgentChat(eventName: "typing", messageId: "")
        }
    }
    func stopTypingToAgent(_: ComposeBarView){
        if isAgentConnect{
            self.botClient.sendEventToAgentChat(eventName: "stop_typing", messageId: "")
        }
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
            //self.botMessagesView.addGestureRecognizer(tapToDismissGestureRecognizer)
            self.tapToDismissGestureRecognizer.delegate = self
            self.headerView.addGestureRecognizer(tapToDismissGestureRecognizer)
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
        self.bottomConstraint.constant = 0
        self.taskMenuContainerHeightConstant.constant = 0
        if (self.composeView.isFirstResponder) {
            _ = self.composeView.resignFirstResponder()
        }
    }
    
    // MARK: Helper functions
    func sendMessage(_ message: Message, dictionary: [String: Any]? = nil, options: [String: Any]?) {
        NotificationCenter.default.post(name: Notification.Name("StartTyping"), object: nil)
        calenderCloseTag = false
        NotificationCenter.default.post(name: Notification.Name(stopSpeakingNotification), object: nil)
        let composedMessage: Message = message
        if (composedMessage.components.count > 0) {
            let dataStoreManager: DataStoreManager = DataStoreManager.sharedManager
            dataStoreManager.createNewMessageIn(thread: self.thread, message: composedMessage, completion: { (success) in
                let textComponent = composedMessage.components[0] as? Component
                if SDKConfiguration.botConfig.isWebhookEnabled{
                    if let text = textComponent?.payload {
                        self.webhookSendMessage(text: text, attahment: dictionary ?? [:])
                    }
                }else{
                    if let _ = self.botClient, let text = textComponent?.payload {
                        self.botClient.sendMessage(text, dictionary: dictionary, options: options)
                    }
                }
                arrayOfSelectedBtnIndex.insert(1000, at: 0)
                historyLimit += 1
                self.textMessageSent()
            })
        }
    }
    
    func webhookSendMessage(text:String, attahment: [String:Any]){
        self.kaBotClient.webhookSendMessage(text, "text", attahment, success: { [weak self] (dictionary) in
            print(dictionary)
            if dictionary["pollId"] as? String == nil{
                self?.receviceMessage(dictionary: dictionary)
            }else{
                self?.receviceMessage(dictionary: dictionary)
                self?.callPollApi(pollID: dictionary["pollId"] as! NSString)
            }
            
            }, failure: { (error) in
                print(error)
        })
    }
    func callPollApi(pollID: NSString){
        let pollIDStr = pollID
        self.kaBotClient.pollApi(pollID as String, success: { [weak self] (dictionary) in
            print(dictionary)
            if dictionary["status"] as? String == "Inprogress"{
                self?.callPollApi(pollID: pollIDStr)
            }else{
                self?.receviceMessage(dictionary: dictionary)
            }
            }, failure: { (error) in
                print(error)
        })
    }
    
    func verifyIsObjectOfAnArray<T>(_ object: T) -> Bool {
       if let _ = object as? [T] {
          return true
       }

       return false
    }
    
    func dateFormatter() -> DateFormatter {
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return dateFormatter
    }
    
    func receviceMessage(dictionary:[String: Any]){
        let data: Array = dictionary["data"] != nil ? dictionary["data"] as! Array : []
        for i in 0..<data.count{
            
            let message: Message = Message()
            message.messageType = .reply
            let textComponent: Component = Component()
            var templateType = ""
            var ttsBody: String?

            let valData: Dictionary<String, Any> = data[i] as! Dictionary<String, Any>
            var textMessage: Message! = nil
            message.sentDate = self.dateFormatter().date(from: valData["createdOn"] as? String ?? "")
            message.messageId = valData["messageId"] as? String
            if let type = valData["createdOn"] as? String, type == "incoming" {
                message.messageType = .default
            }
            if let iconUrl = valData["iconUrl"] as? String {
                message.iconUrl = iconUrl
            }else{
                message.iconUrl = botHistoryIcon
            }
            
            let jsonString = valData["val"] as? String
            if ((jsonString?.contains("payload")) != nil), let jsonObject: [String: Any] = Utilities.jsonObjectFromString(jsonString: jsonString ?? "") as? [String : Any] {
                let type = jsonObject["type"] as? String ?? ""
                let text = jsonObject["text"] as? String
                ttsBody = jsonObject["speech_hint"] as? String
                switch type {
                case "template":
                    if let dictionary = jsonObject["payload"] as? [String: Any] {
                        var templateType = dictionary["template_type"] as? String ?? ""
                        if templateType == "carousel"{
                            if dictionary["carousel_type"] as? String ?? ""  == "stacked"{
                                templateType = "stacked"
                            }
                        }
                        var tabledesign = "responsive"
                        if let value = dictionary["table_design"] as? String {
                            tabledesign = value
                        }
                        let componentType = getComponentType(templateType, tabledesign)
                        if componentType != .quickReply {
                        }
                        ttsBody = dictionary["speech_hint"] != nil ? dictionary["speech_hint"] as? String : nil
                        if let tText = dictionary["text"] as? String, tText.count > 0 && (componentType == .carousel || componentType == .chart || componentType == .table || componentType == .minitable || componentType == .responsiveTable) {
                            textMessage = Message()
                            textMessage?.messageType = .reply
                            textMessage?.sentDate = message.sentDate
                            textMessage?.messageId = message.messageId
                            if let iconUrl = valData["iconUrl"] as? String {
                                textMessage?.iconUrl = iconUrl
                            }
                            let textComponent: Component = Component()
                            textComponent.payload = tText
                            textMessage?.addComponent(textComponent)
                        }
                        
                        let optionsComponent: Component = Component(componentType)
                        optionsComponent.payload = Utilities.stringFromJSONObject(object: dictionary)
                        message.addComponent(optionsComponent)
                    }
                case "image":
                    if let _ = jsonObject["payload"] as? [String: Any] {
                        let optionsComponent: Component = Component(.image)
                        optionsComponent.payload = Utilities.stringFromJSONObject(object: jsonObject)
                        message.sentDate = self.dateFormatter().date(from: valData["createdOn"] as? String ?? "")
                        message.addComponent(optionsComponent)
                    }
                case "video":
                    if let _ = jsonObject["payload"] as? [String: Any] {
                        let  componentType = Component(.video)
                        let optionsComponent: Component = componentType
                        optionsComponent.payload = Utilities.stringFromJSONObject(object: jsonObject)
                        message.sentDate = self.dateFormatter().date(from: valData["createdOn"] as? String ?? "")
                        message.addComponent(optionsComponent)
                    }
                case "audio":
                    if let dictionary = jsonObject["payload"] as? [String: Any] {
                        let  componentType = Component(.audio)
                        let optionsComponent: Component = componentType
                        optionsComponent.payload = Utilities.stringFromJSONObject(object: dictionary)
                        message.sentDate = self.dateFormatter().date(from: valData["createdOn"] as? String ?? "")
                        message.addComponent(optionsComponent)
                    }
                case "message":
                    if let dictionary = jsonObject["payload"] as? [String: Any] {
                        let  componentType = dictionary["audioUrl"] != nil ? Component(.audio) : Component(.video)
                        let optionsComponent: Component = componentType
                        if let speechText = dictionary["text"] as? String{
                            ttsBody = speechText
                        }
                        optionsComponent.payload = Utilities.stringFromJSONObject(object: dictionary)
                        message.sentDate = self.dateFormatter().date(from: valData["createdOn"] as? String ?? "")
                        message.addComponent(optionsComponent)
                    }
                case "error":
                    if let dictionary = jsonObject["payload"] as? [String: Any] {
                        let errorComponent: Component = Component(.error)
                        errorComponent.payload = Utilities.stringFromJSONObject(object: dictionary)
                        message.addComponent(errorComponent)
                        ttsBody = dictionary["speech_hint"] != nil ? dictionary["speech_hint"] as? String : nil
                    }
                default:
                    if let text = text, text.count > 0 {
                        let textComponent: Component = Component()
                        textComponent.payload = text
                        message.addComponent(textComponent)
                    }
                }
            }else if let jsonObject: [String: Any] = valData["val"] as? [String : Any]{
                let type = jsonObject["type"] as? String ?? ""
                let text = jsonObject["text"] as? String
                ttsBody = jsonObject["speech_hint"] as? String
                switch type {
                case "template":
                    if let dictionary = jsonObject["payload"] as? [String: Any] {
                        let templateType = dictionary["template_type"] as? String ?? ""
                        var tabledesign = "responsive"
                        if let value = dictionary["table_design"] as? String {
                            tabledesign = value
                        }

                        let componentType = getComponentType(templateType, tabledesign)
                        if componentType != .quickReply {
                            
                        }
                        
                        ttsBody = dictionary["speech_hint"] != nil ? dictionary["speech_hint"] as? String : nil
                        if let tText = dictionary["text"] as? String, tText.count > 0 && (componentType == .carousel || componentType == .chart || componentType == .table || componentType == .minitable || componentType == .responsiveTable) {
                            textMessage = Message()
                            textMessage?.messageType = .reply
                            textMessage?.sentDate = message.sentDate
                            textMessage?.messageId = message.messageId
                            if let iconUrl = valData["iconUrl"] as? String {
                                textMessage?.iconUrl = iconUrl
                            }
                            let textComponent: Component = Component()
                            textComponent.payload = tText
                            textMessage?.addComponent(textComponent)
                        }
                        
                        let optionsComponent: Component = Component(componentType)
                        optionsComponent.payload = Utilities.stringFromJSONObject(object: dictionary)
                        message.addComponent(optionsComponent)
                    }
                case "image":
                    if let _ = jsonObject["payload"] as? [String: Any] {
                        let optionsComponent: Component = Component(.image)
                        optionsComponent.payload = Utilities.stringFromJSONObject(object: jsonObject)
                        message.sentDate = self.dateFormatter().date(from: valData["createdOn"] as? String ?? "")
                        message.addComponent(optionsComponent)
                    }
                case "video":
                    if let _ = jsonObject["payload"] as? [String: Any] {
                        let  componentType = Component(.video)
                        let optionsComponent: Component = componentType
                        optionsComponent.payload = Utilities.stringFromJSONObject(object: jsonObject)
                        message.sentDate = self.dateFormatter().date(from: valData["createdOn"] as? String ?? "")
                        message.addComponent(optionsComponent)
                    }
                case "audio":
                    if let dictionary = jsonObject["payload"] as? [String: Any] {
                        let  componentType = Component(.audio)
                        let optionsComponent: Component = componentType
                        optionsComponent.payload = Utilities.stringFromJSONObject(object: dictionary)
                        message.sentDate = self.dateFormatter().date(from: valData["createdOn"] as? String ?? "")
                        message.addComponent(optionsComponent)
                    }
                case "message":
                    if let dictionary = jsonObject["payload"] as? [String: Any] {
                        let  componentType = dictionary["audioUrl"] != nil ? Component(.audio) : Component(.video)
                        let optionsComponent: Component = componentType
                        if let speechText = dictionary["text"] as? String{
                            ttsBody = speechText
                        }
                        optionsComponent.payload = Utilities.stringFromJSONObject(object: dictionary)
                        message.sentDate = self.dateFormatter().date(from: valData["createdOn"] as? String ?? "")
                        message.addComponent(optionsComponent)
                    }
                case "error":
                    if let dictionary = jsonObject["payload"] as? [String: Any] {
                        let errorComponent: Component = Component(.error)
                        errorComponent.payload = Utilities.stringFromJSONObject(object: dictionary)
                        message.addComponent(errorComponent)
                        ttsBody = dictionary["speech_hint"] != nil ? dictionary["speech_hint"] as? String : nil
                    }
                default:
                    if let text = text, text.count > 0 {
                        let textComponent: Component = Component()
                        textComponent.payload = text
                        message.addComponent(textComponent)
                    }
                }
            }
            else{
                templateType = valData["type"] as? String ?? ""
                textComponent.payload = jsonString
                if lastMessageID == valData["messageId"] as? String{
                    ttsBody = ""
                }else{
                    ttsBody = jsonString
                }
                message.addComponent(textComponent)
                lastMessageID = valData["messageId"] as? String
            }
        addMessages(message, ttsBody)
        NotificationCenter.default.post(name: Notification.Name("StopTyping"), object: nil)
    }
}

    func sendTextMessage(_ text: String, dictionary: [String: Any]? = nil, options: [String: Any]?) {
        if attachmentArray.count>0 {
            closeAndOpenAttachment(imageAttached: nil, height: 0.0)
            self.uploadAttachment(text: text)
        }else{
            let message: Message = Message()
            message.messageType = .default
            message.sentDate = Date()
            message.messageId = UUID().uuidString
            let textComponent: Component = Component()
            textComponent.payload = text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            message.addComponent(textComponent)
            
            if dictionary?.count ?? 0 > 0{
                sendMessage(message, dictionary: dictionary, options: options)
            }else{
                sendMessage(message, options: options)
            }
            
        }
        
    }
    
    func textMessageSent() {
        self.composeView.clear()
        if botMessagesView != nil{
            self.botMessagesView.scrollToTop(animate: true)
        }
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
        self.sendTextMessage(text, options: ["body": payload, "renderMsg":text])
    }
    
    func linkButtonTapAction(urlString: String) {
        if verifyUrl(urlString: urlString){
            if (urlString.count > 0) {
                NotificationCenter.default.post(name: Notification.Name(stopSpeakingNotification), object: nil)
                let url: URL = URL(string: urlString)!
                let webViewController = SFSafariViewController(url: url)
                present(webViewController, animated: true, completion:nil)
            }
        }
        
    }
    
    func verifyUrl(urlString: String?) -> Bool {
        if let urlString = urlString {
            if let url = URL(string: urlString) {
                return UIApplication.shared.canOpenURL(url)
            }
        }
        return false
    }
    
    func populateQuickReplyCards(with message: KREMessage?) {
        if message?.templateType == (ComponentType.quickReply.rawValue as NSNumber) {
            let component: KREComponent = message!.components![0] as! KREComponent
            if (!component.isKind(of: KREComponent.self)) {
                return;
            }
            if ((component.componentDesc) != nil) {
                let jsonObject: NSDictionary = Utilities.jsonObjectFromString(jsonString: component.componentDesc!) as! NSDictionary
                let quickReplies: Array<Dictionary<String, Any>> = jsonObject["quick_replies"] as? Array<Dictionary<String, Any>> ?? []
                var words: Array<Word> = Array<Word>()
                
                for dictionary in quickReplies {
                    let title: String = dictionary["title"] as? String ?? ""
                    var payload = ""
                    if let payloadStr = dictionary["payload"] as? [String: Any]{
                        payload = payloadStr["name"] as? String ?? ""
                    }else{
                        payload = dictionary["payload"] as? String ?? ""
                    }
                    let imageURL: String = dictionary["image_url"] as? String ?? ""
                    
                    let word: Word = Word(title: title, payload: payload, imageURL: imageURL)
                    words.append(word)
                }
                self.quickReplyView.words = words
                let bgColor = btnBgActiveColor
                let textColor = btnActiveTextColor
                self.quickReplyView.bgColor = bgColor
                self.quickReplyView.textColor = textColor
                self.quickReplyView.boarderColor = textColor
                self.quickReplyView.fontName = mediumCustomFont
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
        if quickRepliesIsHorizontal{
            DispatchQueue.main.async {
                self.quickReplyView.collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .centeredHorizontally, animated: true)
                }
            self.quickReplyViewLeadingConstraint.constant = 0
            if self.quickSelectContainerHeightConstraint.constant == 60.0 {return}
            self.quickSelectContainerHeightConstraint.constant = 60.0
            UIView.animate(withDuration: 0.25, delay: 0.05, options: [], animations: {
                self.view.layoutIfNeeded()
            }) { (Bool) in
                
            }
        }else{
            self.quickReplyViewLeadingConstraint.constant = 40
            let height = self.quickReplyView.collectionView.collectionViewLayout.collectionViewContentSize.height
            let maxHeight = height > 198.0 ? 198.0 : height //248.0
            self.quickReplyView.collectionView.isScrollEnabled = false
            if  maxHeight >= 198.0{
                self.quickReplyView.collectionView.isScrollEnabled = true
            }
            var quickSelectCollVheight = maxHeight > 60.0 ? maxHeight : 60.0
            //quickSelectCollVheight += CGFloat(quickReplySuggesstionLblHeight)
            if self.quickSelectContainerHeightConstraint.constant == quickSelectCollVheight {return}
            
            self.quickSelectContainerHeightConstraint.constant = quickSelectCollVheight
            UIView.animate(withDuration: 0.25, delay: 0.05, options: [], animations: {
                self.view.layoutIfNeeded()
            }) { (Bool) in
                
            }
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
    
    func populateClockView(with message: KREMessage?) {
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
                let clockViewController = ClockViewController(dataString: jsonString!)
                //clockViewController.viewDelegate = self
                clockViewController.modalPresentationStyle = .overFullScreen
                self.navigationController?.present(clockViewController, animated: true, completion: nil)
                
                clockViewController.optionsButtonTapNewAction = { [weak self] (text, payload) in
                    if let text = text, let payload = payload {
                        self?.optionsButtonTapNewAction(text: text, payload: payload)
                    }
                }
            }
        }
    }
    
    func populateFeedbackSliderView(with message: KREMessage?) {
        if message?.templateType == (ComponentType.feedbackTemplate.rawValue as NSNumber) {
            let component: KREComponent = message!.components![0] as! KREComponent
            print(component)
            if (!component.isKind(of: KREComponent.self)) {
                return;
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
        self.closeWidgetPanelView()
    }
    
    func composeBarViewDidBecomeFirstResponder(_: ComposeBarView) {
        self.audioComposeView.stopRecording()
        self.closeWidgetPanelView()
    }
    
    func composeBarTaskMenuButtonAction(_: ComposeBarView) {
        self.closeWidgetPanelView()
        self.bottomConstraint.constant = 0
        self.taskMenuContainerHeightConstant.constant = 0
        if (self.composeView.isFirstResponder) {
            _ = self.composeView.resignFirstResponder()
        }
        
        leftMenuContainerView.isHidden = false
        let zero = CGAffineTransform(translationX: 0.0, y: 0.0)
        self.leftMenuContainerView.transform = zero
        
            leftMenuContainerView.semanticContentAttribute = .forceLeftToRight
            leftMenuContainerSubView.semanticContentAttribute = .forceLeftToRight
            let transition = CATransition()
            transition.type = .push
            transition.subtype = .fromLeft
            self.leftMenuContainerView.layer.add(CATransition().segueFromLeft(), forKey: nil)
            self.leftMenuView.leftMenuTableviewReload()
            leftMenuTitleLbl.text = "Menu"
    }
    func composeBarAttachmentButtonAction(_: ComposeBarView) {
        self.openAcionSheet()
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
        info.setValue("kore", forKey: "imageName");
        self.typingStatusView?.startTypingStatus(using: botHistoryIcon,dotColor: themeColor)
    }
    
    // MARK: show TableTemplateView
    @objc func showTableTemplateView(notification:Notification) {
        let dataString: String = notification.object as! String
        let tableTemplateViewController = TableTemplateViewController(dataString: dataString)
        self.navigationController?.present(tableTemplateViewController, animated: true, completion: nil)
    }
    
    // MARK: show CustomTableTemplateView
    @objc func showCustomTableTemplateView(notification:Notification) {
        let dataString: String = notification.object as! String
        let customTableTemplateViewController = CustomTableTemplateVC(dataString: dataString)
        customTableTemplateViewController.viewDelegate = self
        self.navigationController?.present(customTableTemplateViewController, animated: true, completion: nil)
    }
    
    @objc func showPDFErrorMeesage(notification:Notification){
        let dataString: String = notification.object as? String ?? ""
        self.toastMessage(dataString)
    }
    
    @objc func showPDFViewController(notification:Notification){
        let dataString: String = notification.object as? String ?? ""
        if dataString == "Show"{
            self.toastMessage("Statement saved successfully under Files")
        }else{
            if #available(iOS 11.0, *) {
                let vc = PdfShowViewController(dataString: dataString)
                vc.pdfUrl = URL(string: dataString)
                vc.modalPresentationStyle = .overFullScreen
                self.navigationController?.present(vc, animated: true, completion: nil)
            } else {
                // Fallback on earlier versions
            }
            
        }
    }
    @objc func tokenExpiry(notification:Notification){
        let alertController = UIAlertController(title: appDisplayName, message: "Your session has expired. Please re-login", preferredStyle: .alert)
        // Create the actions
        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
            UIAlertAction in
            let dic = ["event_code": "BotMinimized", "event_message": "Bot Minimized by the user"]
            self.closeAndMinimizeEvent(dic)
            self.botClosed()
        }
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @objc func reloadTable(notification:Notification){
        if botMessagesView != nil{
            botMessagesView.tableView.reloadData()
        }
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
    
    @objc func showArticleTemplateView(notification:Notification) {
        let dataString: String = notification.object as! String
        let articleDetailsViewController = ArticleDetailVC(dataString: dataString)
        articleDetailsViewController.viewDelegate = self
        articleDetailsViewController.modalPresentationStyle = .overFullScreen
        self.navigationController?.present(articleDetailsViewController, animated: true, completion: nil)
    }
    
    @objc func OTPvalidateTemplateActtion(notification:Notification){
        let dataString: String = notification.object as! String
        let otpValidationVC = OTPValidationVC(dataString: dataString)
        otpValidationVC.viewDelegate = self
        otpValidationVC.modalPresentationStyle = .overFullScreen
        self.navigationController?.present(otpValidationVC, animated: true, completion: nil)
    }
    
    @objc func resetPinTemplateActtion(notification:Notification){
        let dataString: String = notification.object as! String
        let oresetPinVC = ResetPinViewController(dataString: dataString)
        oresetPinVC.viewDelegate = self
        oresetPinVC.modalPresentationStyle = .overFullScreen
        self.navigationController?.present(oresetPinVC, animated: true, completion: nil)
    }
    
    @objc func dropDownTemplateActtion(notification:Notification){
         let dataString: String = notification.object as! String
        composeView.setText(dataString)
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
        
        botClient.getHistory(offset: offset,limit: 20, success: { [weak self] (responseObj) in
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
        guard let botMessages = Mapper<BotMessages>().mapArray(JSONArray: messages) as? [BotMessages], botMessages.count > 0 else {
            return
        }
        
        var allMessages: [Message] = [Message]()
        var removeTemplate = false
        for message in botMessages {
            removeTemplate = false
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
                    if let tags = message.tags{
                        if let allText = tags.altText, allText.count > 0{
                            if let payloadValue = allText[0].value {
                                payloadObj["text"]  = payloadValue
                            }
                        }
                    }
                    payloadObj["type"] = "text"
                    componentModel.type = "text"
                    componentModel.payload = payloadObj
                    
                    if Utilities.isValidJson(check: jsonString) == true{
                       if let jsonDicc: [String: Any] = Utilities.jsonObjectFromString(jsonString: jsonString) as? [String : Any]{
                           if let textStr = jsonDicc["text"] as? String{
                               payloadObj["text"] = textStr
                               componentModel.payload = payloadObj
                           }
                       }
                   }
                    if jsonString == "Welpro"{
                        removeTemplate = true
                        RemovedTemplateCount  += 1
                    }
                }
                
                messageModel.type = "text"
                messageModel.component = componentModel
                botMessage.messages = [messageModel]
                let messageTuple = onReceiveMessage(object: botMessage)
                if let object = messageTuple.0 {
                    if !removeTemplate{
                        if !isOTPValidationTemplate{
                            arrayOfSelectedBtnIndex.add(1001)
                            allMessages.append(object)
                        }
                    }
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
            }else{
                self?.offSet =  count + RemovedTemplateCount + OTPValidationRemoveCount
                if (self?.botMessagesView.spinner.isHidden)!{
                    self?.getMessages(offset: self!.offSet)
                }
            }
        })
    }
    func tableviewScrollDidEnd(){
        if SDKConfiguration.botConfig.isShowChatHistory{
            fetchMessages()
        }
    }
}
extension ChatMessagesViewController: KABotClientDelegate {
    func showTypingStatusForBot() {
        self.typingStatusView?.isHidden = true
        self.typingStatusView?.startTypingStatus(using: botHistoryIcon,dotColor: themeColor)
    }
    
    func hideTypingStatusForBot(){
        self.typingStatusView?.stopTypingStatus()
    }
    
    // MARK: - KABotlientDelegate methods
    public func botConnection(with connectionState: BotClientConnectionState) {
        updateNavBarPrompt()
        
    }
    
    @objc func startTypingStatusForBot() {
        self.typingStatusView?.isHidden = true
        let botId:String = SDKConfiguration.botConfig.botId
        let info:NSMutableDictionary = NSMutableDictionary.init()
        info.setValue(botId, forKey: "botId");
        
        let urlString:String?
        if SDKConfiguration.botConfig.isWebhookEnabled{
            urlString = botHistoryIcon?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        }else{
             urlString = botHistoryIcon?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        }
        
        info.setValue(urlString ?? "kore", forKey: "imageName");
        self.typingStatusView?.startTypingStatus(using: urlString,dotColor: themeColor)
    }
    
    @objc func stopTypingStatusForBot(){
        self.typingStatusView?.stopTypingStatus()
    }
    
}

extension ChatMessagesViewController{
    // MARK: - button actions
    @objc func openAcionSheet() {
        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let photoAction: UIAlertAction = UIAlertAction(title: "Take Photo", style: .default) { (action) in
            self.photoAction()
        }
        let videoAction: UIAlertAction = UIAlertAction(title: "Capture Video", style: .default) { (action) in
            self.videoAction()
        }
        let cameraRollAction: UIAlertAction = UIAlertAction(title: "Photo Library", style: .default) { (action) in
            self.cameraRollAction()
        }
        let documentAction: UIAlertAction = UIAlertAction(title: "Attach Document", style: .default) { (action) in
            self.documentAction()
        }
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            
        }
        actionSheetController.addAction(photoAction)
        actionSheetController.addAction(videoAction)
        actionSheetController.addAction(cameraRollAction)
        actionSheetController.addAction(documentAction)
        actionSheetController.addAction(cancelAction)
        present(actionSheetController, animated: true, completion: nil)
    }
    
    // MARK: -
    public func photoAction() {
        showImagePicker(with: .image)
    }
    
    public func videoAction() {
        showImagePicker(with: .video)
    }
    
    public func cameraRollAction() {
        var config = FMPhotoPickerConfig()
        config.selectMode = .single
        config.shouldReturnAsset = true
        config.strings["permission_dialog_title"] = appDisplayName
        config.strings["permission_dialog_message"] = "\(appDisplayName) wants to access Photo Library"
        let picker = FMPhotoPickerViewController(config: config)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    public func documentAction() {
        let types = KAAssetManager.shared.supportedAssetTypes()
        let documentPickerViewController = UIDocumentPickerViewController(documentTypes: types, in: .import)
        documentPickerViewController.modalPresentationStyle = .fullScreen
        documentPickerViewController.delegate = self
        present(documentPickerViewController, animated: true, completion: nil)
    }
    
    func showImagePicker(with mediaType: KAAsset) {
        if(UIImagePickerController.isSourceTypeAvailable(.camera)){
            let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
            if authStatus == AVAuthorizationStatus.denied {
                let alert = UIAlertController(title: "Unable to access the Camera",
                                              message: "To enable access, go to Settings > Privacy > Camera and turn on Camera access for this app.",
                                              preferredStyle: UIAlertController.Style.alert)
                
                let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alert.addAction(okAction)
                
                let settingsAction = UIAlertAction(title: "Settings", style: .default, handler: { _ in
                    guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
                    if UIApplication.shared.canOpenURL(settingsUrl) {
                        if #available(iOS 10.0, *) {
                            UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                                
                            })
                        } else {
                            
                        }
                    }
                })
                alert.addAction(settingsAction)
                present(alert, animated: true, completion: nil)
            } else if (authStatus == AVAuthorizationStatus.notDetermined) {
                AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (granted) in
                    if granted {
                        DispatchQueue.main.async {
                            self.showImagePicker(sourceType: UIImagePickerController.SourceType.camera, with: mediaType)
                        }
                    }
                })
            } else {
                switch mediaType {
                case .image:
                    showImagePicker(sourceType: UIImagePickerController.SourceType.camera, with: mediaType)
                case .video:
                    showImagePicker(sourceType: UIImagePickerController.SourceType.camera, with: mediaType)
                default:
                    break
                }
            }
        }
        else{
            let actionController: UIAlertController = UIAlertController(title: appDisplayName,message: "Camera is not available", preferredStyle: .alert)
            let cancelAction: UIAlertAction = UIAlertAction(title: "OK", style: .cancel) { action -> Void  in
                //Just dismiss the action sheet
            }
            actionController.addAction(cancelAction)
            self.present(actionController, animated: true, completion: nil)
        }
        
        
    }
    
    fileprivate func showImagePicker(sourceType: UIImagePickerController.SourceType, with mediaType: KAAsset) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.modalPresentationStyle = .currentContext
        imagePickerController.sourceType = sourceType
        imagePickerController.delegate = self
        
        switch mediaType {
        case .image:
            if sourceType == UIImagePickerController.SourceType.camera {
                imagePickerController.showsCameraControls = true
                imagePickerController.modalPresentationStyle = .fullScreen
                imagePickerController.mediaTypes = [kUTTypeImage] as [String]
                present(imagePickerController, animated: true, completion: nil)
            }
        case .video:
            if sourceType == UIImagePickerController.SourceType.camera {
                imagePickerController.showsCameraControls = true
                imagePickerController.modalPresentationStyle = .fullScreen
                imagePickerController.mediaTypes = [kUTTypeMovie] as [String]
                imagePickerController.allowsEditing = true
                imagePickerController.videoMaximumDuration = KAAsset.video.maxDuration
                present(imagePickerController, animated: true, completion: nil)
            }
        default:
            break
        }
    }
}
extension ChatMessagesViewController: FMPhotoPickerViewControllerDelegate {
    func closeAndOpenAttachment(imageAttached: UIImage?, height: CGFloat){
        attachmentArray = []
        attachmentKeybord = false
        if imageAttached != nil{
            attachmentArray.add(imageAttached!)
            attachmentKeybord = true
        }
        NotificationCenter.default.post(name: Notification.Name(showAttachmentSendButtonNotification), object: nil)
        self.attachmentContainerHeightConstraint.constant = height
        DispatchQueue.main.async {
            self.attachmentCollectionView.reloadData()
        }
    }
    
    func fmPhotoPickerController(_ picker: FMPhotoPickerViewController, didFinishPickingPhotoWith photos: [UIImage]) {
        
    }
    func fmPhotoPickerController(_ picker: FMPhotoPickerViewController, didFinishPickingPhotoWith assets: [PHAsset]) {
        self.dismiss(animated: false)
        // self.messageInputBar.presenter?.attachmentManager.invalidate()
        let phAsset:PHAsset  = assets.first!
        self.phassetToUpload = phAsset
        let imageAttached = getAssetThumbnail(asset: assets.first!)
        
        let activityIndicator = displayActivityIndicator(onView: view)
        KAAssetManager.shared.requestMediaAsset(for: phAsset, progress: { (value) in
            debugPrint("Progress value : \(value)")
        }) { [weak self] (success, asset) in
            self?.removeActivityIndicator(spinner: activityIndicator)
            if let mediaAsset = asset {
                let component: Component = Component()
                component.componentId = mediaAsset.fileName
                component.fileMeta.fileName = mediaAsset.fileName
                component.fileMeta.fileExtn = mediaAsset.fileExtn
                component.templateType = mediaAsset.fileType
                component.fileMeta.orientation = mediaAsset.imageOrientation
                component.componentServer = SDKConfiguration.serverConfig.BOT_SERVER
                component.fileMeta.fileContext = "workflows"
                
                var totalFileSize = 0
                let size =
                    KAFileUtilities.shared.sizeForItem(at: mediaAsset.filePath)
                totalFileSize = totalFileSize + Int(size)
                self?.componentSelectedToupload = component
                self?.closeAndOpenAttachment(imageAttached: imageAttached, height: 90.0)
               
            }
        }
    }
    
    func uploadAttachment(text: String) {
        // do your job with selected assets
        
        guard let component = self.componentSelectedToupload else {
            return
        }
        let activityIndicator = displayActivityIndicator(onView: view)
        //        self.showLoaderView()
        //self.account = KoraApplication.sharedInstance.account
        self.account?.uploadComponent(component, progress: { (progress) in
            DispatchQueue.main.async {
                debugPrint("Progress: \(progress * 100)")
            }
        }, success: { (component) in
            if let fileId = component.componentFileId {
                DispatchQueue.main.async {
                    var attachment = [String: Any]()
                    var textTo = ""
                    attachment["fileId"] = fileId
                    attachment["fileName"] = "\(component.fileMeta.fileName ?? "").\(component.fileMeta.fileExtn ?? "")"
                    //attachment["fileType"] = component.templateType
                    attachment["fileExtn"] = component.fileMeta.fileExtn
                    if component.templateType == "image" {
                        textTo = "\(text)\n \u{1F4F7} \(component.fileMeta.fileName ?? "").\(component.fileMeta.fileExtn ?? "")"
                        attachment["fileType"] = "image"
                    }else if component.templateType == "video" {
                        textTo = "\(text)\n 🎥 \(component.fileMeta.fileName ?? "").\(component.fileMeta.fileExtn ?? "")"
                        attachment["fileType"] = "video"
                    } else {
                        if component.fileMeta.fileExtn == "pdf"{
                            textTo = "\(text)\n 📄 \(component.fileMeta.fileName ?? "").\(component.fileMeta.fileExtn ?? "")"
                            attachment["fileType"] = "pdf"
                        }else if component.fileMeta.fileExtn == "mp3"{
                            textTo = "\(text)\n 🎵 \(component.fileMeta.fileName ?? "").\(component.fileMeta.fileExtn ?? "")"
                            attachment["fileType"] = "mp3"
                        }else{
                            textTo = "\(text)\n 📁 \(component.fileMeta.fileName ?? "").\(component.fileMeta.fileExtn ?? "")"
                            attachment["fileType"] = component.templateType
                        }
                        
                    }
                    self.removeActivityIndicator(spinner: activityIndicator)
                    
                    self.sendTextMessage(textTo, dictionary: [:], options: ["attachments": [attachment]])
                    
                }
            }
        }, failure: { (error) in
            DispatchQueue.main.async {
                
                self.removeActivityIndicator(spinner: activityIndicator)
            }
            debugPrint("Failed to upload a \(component.templateType ?? "")")
        })
        
    }
    
    func getAssetThumbnail(asset: PHAsset) -> UIImage {
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        var thumbnail = UIImage()
        option.isSynchronous = true
        manager.requestImage(for: asset, targetSize: CGSize(width: 100.0, height: 100.0), contentMode: .aspectFit, options: option, resultHandler: {(result, info)->Void in
            thumbnail = result!
        })
        return thumbnail
    }
}

extension ChatMessagesViewController {
    func uploadAttachment() {
        
    }
}

// MARK: - UIDocumentPickerDelegate, UIDocumentMenuDelegate
extension ChatMessagesViewController: UIDocumentPickerDelegate, UIDocumentMenuDelegate {
    public func documentMenu(_ documentMenu: UIDocumentMenuViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
        documentPicker.delegate = self
        present(documentPicker, animated: true) {() -> Void in }
    }
    
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        let activityIndicator = displayActivityIndicator(onView: view)
        KAAssetManager.shared.exportAsset(with: url) { [weak self] (success, asset) in
            if controller.documentPickerMode == .import {
                DispatchQueue.main.async(execute: {
                    self?.removeActivityIndicator(spinner: activityIndicator)
                    
                    //self?.messageInputBar.presenter?.attachmentManager.invalidate()
                    
                    if let mediaAsset = asset {
                        let component: Component = Component()
                        component.componentId = KAFileUtilities.shared.getUUID(for: KAAsset.attachment.fileType)
                        component.fileMeta.fileName = mediaAsset.fileName
                        component.fileMeta.fileExtn = mediaAsset.fileExtn
                        component.templateType = mediaAsset.fileType
                        component.fileMeta.orientation = mediaAsset.imageOrientation
                        component.componentServer = SDKConfiguration.serverConfig.BOT_SERVER
                        component.fileMeta.fileContext = "workflows"
                        self?.componentSelectedToupload = component
                        let filePath = KAFileUtilities.shared.path(for: mediaAsset.fileName, of: mediaAsset.fileType, with: mediaAsset.fileExtn)
                        
                        print(filePath)
                        let imageAttached = self?.getFileImage(fileType: mediaAsset.fileExtn)
                        self?.closeAndOpenAttachment(imageAttached: imageAttached, height: 90.0)
                    }
                })
            }
            
        }
    }
    
    public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
    }
    
    func getFileImage(fileType: String) -> UIImage? {
        switch fileType.uppercased() {
        case "GIF", "ICO", "DDS", "HEIC", "JPG", "PNG", "PSD", "PSPIMAGE","TGA","THM","TIF","TIFF","BMP","YUV":// Raster Image Files
            return UIImage(named: "raster_image", in: bundleImage, compatibleWith: nil)
        case "PAGES", "LOG", "MSG", "ODT", "RTF", "TEX", "TXT", "WPD", "WPS", "GDOCS", "GDOC"://Text Files
            return UIImage(named: "documents", in: bundleImage, compatibleWith: nil)
        case "DOCX", "DOC":
            return UIImage(named: "word", in: bundleImage, compatibleWith: nil)
        case "XLR", "CSV", "ODS","GSHEET"://SpreadSheeet Files
            return UIImage(named: "sheet", in: bundleImage, compatibleWith: nil)
        case "XLSX", "XLS"://SpreadSheeet Files
            return UIImage(named: "excel", in: bundleImage, compatibleWith: nil)
        case "PPS", "KEY", "GED", "ODP", "GSLIDE"://Presentation Files
            return UIImage(named: "slides", in: bundleImage, compatibleWith: nil)
        case "PPT", "PPTX":
            return UIImage(named: "powerPoint", in: bundleImage, compatibleWith: nil)
        case "PDF":
            return UIImage(named: "pdf", in: bundleImage, compatibleWith: nil)
        case "MP3", "WAV", "AIF", "IFF", "M3U", "M4A", "MID", "WMA", "MPA":// Audio Files
            return UIImage(named: "music", in: bundleImage, compatibleWith: nil)
        case "3G2", "3GP", "ASF", "AVI", "FLV", "M4V", "MOV", "MP4", "MPG", "RM", "SRT", "SWF", "VOB", "WMV": //Video Files
            return UIImage(named: "video", in: bundleImage, compatibleWith: nil)
        case "3DM", "3DS", "MAX", "OBJ": //3d image files
            return UIImage(named: "3dobject", in: bundleImage, compatibleWith: nil)
        case "AI", "EPS", "PS", "SVG": //Vector image files
            return UIImage(named: "file_general", in: bundleImage, compatibleWith: nil)
        case "SKETCH":
            return UIImage(named: "sketch", in: bundleImage, compatibleWith: nil)
        case "ZIP":
            return UIImage(named: "zip", in: bundleImage, compatibleWith: nil)
        default:
            return UIImage(named: "file_general", in: bundleImage, compatibleWith: nil)
        }
    }
    
}

// MARK: - UIImagePickerControllerDelegate
extension ChatMessagesViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
            
        }
        dismiss(animated: true, completion: {
            //            _ = self.richTextEditor?.becomeFirstResponder()
        })
        
        guard let mediaType = info[.mediaType] as? String else {
            return
        }
        
        if CFStringCompare(mediaType as CFString, kUTTypeImage, .compareCaseInsensitive) == .compareEqualTo {
            guard let image = info[.originalImage] as? UIImage else {
                return
            }
            let activityIndicator = displayActivityIndicator(onView: view)
            KAAssetManager.shared.exportImage(image, progress: { (value) in
                
            }) { [weak self] (success, asset) in
                self?.removeActivityIndicator(spinner: activityIndicator)
                
                if let mediaAsset = asset {
                    let component: Component = Component()
                    component.componentId = mediaAsset.fileName
                    component.fileMeta.fileName = mediaAsset.fileName
                    component.fileMeta.fileExtn = mediaAsset.fileExtn
                    component.templateType = mediaAsset.fileType
                    component.fileMeta.orientation = mediaAsset.imageOrientation
                    component.componentServer = SDKConfiguration.serverConfig.BOT_SERVER
                    component.fileMeta.fileContext = "workflows"
                    self?.componentSelectedToupload = component
                    let filePath = KAFileUtilities.shared.path(for: mediaAsset.fileName, of: mediaAsset.fileType, with: mediaAsset.fileExtn)
                    print(filePath)
                    self?.closeAndOpenAttachment(imageAttached: image, height: 90.0)
                }
            }
        } else if CFStringCompare(mediaType as CFString, kUTTypeMovie, .compareCaseInsensitive) == .compareEqualTo {
            guard let url = info[.mediaURL] as? URL else {
                return
            }
            let activityIndicator = displayActivityIndicator(onView: view)
            KAAssetManager.shared.exportVideo(url, progress: { (progress) in
                
            }, completion: { [weak self] (success, asset) in
                self?.removeActivityIndicator(spinner: activityIndicator)
                
                if let mediaAsset = asset {
                    let component: Component = Component()
                    component.componentId = mediaAsset.fileName
                    component.fileMeta.fileName = mediaAsset.fileName
                    component.fileMeta.fileExtn = mediaAsset.fileExtn
                    component.templateType = mediaAsset.fileType
                    component.fileMeta.orientation = mediaAsset.imageOrientation
                    component.componentServer = SDKConfiguration.serverConfig.BOT_SERVER
                    component.fileMeta.fileContext = "workflows"
                    self?.componentSelectedToupload = component
                    let filePath = KAFileUtilities.shared.path(for: mediaAsset.fileName, of: mediaAsset.fileType, with: mediaAsset.fileExtn)
                    print(filePath)
                    let image = self?.videoSnapshot(filePathLocal: url)
                    self?.closeAndOpenAttachment(imageAttached: image, height: 90.0)
                }
            })
        }
        
    }
    
    func videoSnapshot(filePathLocal:URL) -> UIImage? {
        do
        {
            let asset = AVURLAsset(url: filePathLocal)
            let imgGenerator = AVAssetImageGenerator(asset: asset)
            imgGenerator.appliesPreferredTrackTransform = true
            let cgImage = try imgGenerator.copyCGImage(at:CMTimeMake(value: Int64(0), timescale: Int32(1)),actualTime: nil)
            let thumbnail = UIImage(cgImage: cgImage)
            return thumbnail
        }
        catch let error as NSError
        {
            print("Error generating thumbnail: \(error)")
            return nil
        }
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
            
        }
        dismiss(animated: true, completion: {
            
        })
    }
}

// activity indicator
extension UIViewController {
    func displayActivityIndicator(onView : UIView) -> UIView {
        let spinnerView = UIView(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView.init(style: .whiteLarge)
        ai.startAnimating()
        ai.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
        }
        
        return spinnerView
    }
    
    func removeActivityIndicator(spinner: UIView) {
        DispatchQueue.main.async {
            spinner.removeFromSuperview()
        }
    }
}

extension ChatMessagesViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func configAttachmentCollectionView(){
        attachmentContainerView.backgroundColor = .clear
        attachmentCollectionView.backgroundColor = .clear
        attachmentContainerHeightConstraint.constant = 0
        self.attachmentCollectionView.register(Bundle.xib(named: "AttachmentCell"),
                                               forCellWithReuseIdentifier: "AttachmentCell")
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return attachmentArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // swiftlint:disable force_cast
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AttachmentCell", for: indexPath) as! AttachmentCell
        cell.backgroundColor = .clear
        cell.imageView.image = attachmentArray[indexPath.item] as? UIImage
        cell.closeButton.addTarget(self, action: #selector(self.deleteAttachmentButtonAction(_:)), for: .touchUpInside)
        cell.closeButton.tag = indexPath.item
        return cell
    }
    @objc fileprivate func deleteAttachmentButtonAction(_ sender: AnyObject!) {
        self.closeAndOpenAttachment(imageAttached: nil, height: 0.0)
    }
}
// MARK: - BotConnection
extension ChatMessagesViewController{
    func botConnectingMethod(){
        let clientId: String = SDKConfiguration.botConfig.clientId
        let clientSecret: String = SDKConfiguration.botConfig.clientSecret
        let isAnonymous: Bool = SDKConfiguration.botConfig.isAnonymous
        let chatBotName: String = SDKConfiguration.botConfig.chatBotName
        let botId: String = SDKConfiguration.botConfig.botId
        
        var identity: String! = nil
        if (isAnonymous) {
            identity = self.getUUID()
        } else {
            identity = SDKConfiguration.botConfig.identity
        }
        
        let dataStoreManager: DataStoreManager = DataStoreManager.sharedManager
        dataStoreManager.deleteThreadIfRequired(with: botId, completionBlock: { (success) in
            
        })
        
        if !clientId.hasPrefix("<") && !clientSecret.hasPrefix("<") && !chatBotName.hasPrefix("<") && !botId.hasPrefix("<") {
            self.showLoader()
            kaBotClient.connect(block: { [weak self] (client, thread) in
                self?.brandingApis(client: client, thread: thread)
                
            }) { (error) in
                self.stopLoader()
                self.showAlert(title: self.appDisplayName, message: "Please try again")
            }
        } else {
            self.stopLoader()
            self.showAlert(title: appDisplayName, message: "YOU MUST SET BOT 'clientId', 'clientSecret', 'chatBotName', 'identity' and 'botId'. Please check the documentation.")
        }
    }
    
    func brandingApis(client: BotClient?, thread: KREThread?){
        let brandingShared = BrandingSingleton.shared
        self.kaBotClient.brandingApiRequest(AcccesssTokenn,success: { [weak self] (jsonResult) in
            print("brandingDic : \(jsonResult)")
            if let v3Dic = jsonResult["v3"]{
                let jsonDecoder = JSONDecoder()
                guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonResult["v3"] as Any , options: .prettyPrinted),
                let brandingDic = try? jsonDecoder.decode(BrandingModel.self, from: jsonData) else {
                    return
                }
                //brandingValues = brandingDic
                self?.overRideLocalBranding(responseTheme: brandingDic)
                self?.sucessMethod(client: client, thread: thread)
            }else{
                self?.getOfflineBrandingData(client: client, thread: thread)
            }
            
        }, failure: { (error) in
            self.getOfflineBrandingData(client: client, thread: thread)
        })
    }
    
    func overRideLocalBranding(responseTheme: BrandingModel){
        let overRideTheme = overRideBrandingTheme != nil ? responseTheme.updateWith(configModel: overRideBrandingTheme!) : responseTheme
        brandingValues = overRideTheme
    }
    
    func getOfflineBrandingData(client: BotClient?, thread: KREThread?){
        
        let brandingShared = BrandingSingleton.shared
        if let path = bundleImage.path(forResource: "branding", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = jsonResult as? Dictionary<String, AnyObject> {
                    let brandingDic = try DictionaryDecoder().decode(BrandingModel.self, from: jsonResult as [String : Any])
                    //brandingValues = brandingDic
                    self.overRideLocalBranding(responseTheme: brandingDic)
                    self.sucessMethod(client: client, thread: thread)
                }
            } catch {
                // handle error
            }
        }else{
            if let url = bundleImage.url(forResource: "branding", withExtension: "json", subdirectory: "BrandindFiles"){
                if let data = try? Data(contentsOf:url, options: .mappedIfSafe){
                    let jsonResult = try? JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                    if let jsonResult = jsonResult as? Dictionary<String, AnyObject> {
                        let brandingDic = try? DictionaryDecoder().decode(BrandingModel.self, from: jsonResult as [String : Any])
                        //brandingValues = brandingDic ?? BrandingModel()
                        self.overRideLocalBranding(responseTheme: brandingDic ?? BrandingModel())
                        self.sucessMethod(client: client, thread: thread)
                    }else{
                        self.sucessMethod(client: client, thread: thread)
                    }
                }else{
                    self.sucessMethod(client: client, thread: thread)
                }
                
            }else{
                self.sucessMethod(client: client, thread: thread)
            }
            
        }
    }
    func sucessMethod(client: BotClient?, thread: KREThread?){
        isBotConnectSucessFully = true
        chatMaskview.isHidden = true
        self.stopLoader()
        self.thread = thread
        self.botClient = client
        self.brandingValuesChanges()
        self.configureleftMenu()
        self.configureWelcomeScreenView()
        
        self.configureThreadView()
        self.configureComposeBar()
        self.configureAudioComposer()
        self.configureIncomingCallView()
        if let footerDic = brandingValues.footer{
            if statusBarBottomBackgroundColor == nil{
                footerStatusBarView.backgroundColor = UIColor.init(hexString: footerDic.bg_color ?? "#FFFFFF")
            }else{
                footerStatusBarView.backgroundColor = statusBarBottomBackgroundColor
            }
            if let layout = footerDic.layout, layout == "keypad"{
                self.configureViewForKeyboard(true)
            }else{
                self.configureViewForKeyboard(false)
            }
        }else{
            self.configureViewForKeyboard(true)
        }
        
        if SDKConfiguration.botConfig.isWebhookEnabled{
            NotificationCenter.default.post(name: Notification.Name("StartTyping"), object: nil)
            self.kaBotClient.webhookBotMetaApi(success: { (dictionary) in
                print(dictionary)
                if let userIcon: String = dictionary["icon"] as? String  {
                    botHistoryIcon = userIcon
                }
                 
                }, failure: { (error) in
                    print(error)
            })
            
            self.kaBotClient.webhookSendMessage("ON_CONNECT", "event",[:], success: { [weak self] (dictionary) in
                print(dictionary)
                self?.chatMaskview.isHidden = true
                if dictionary["pollId"] as? String == nil{
                    self?.receviceMessage(dictionary: dictionary)
                }else{
                    self?.callPollApi(pollID: dictionary["pollId"] as! NSString)
                }
                
                }, failure: { (error) in
                    print(error)
            })
        }
        
        // MARK: - isShowWidget
        if SDKConfiguration.widgetConfig.isPanelView {
            let clientIdForWidget: String = SDKConfiguration.widgetConfig.clientId
            let clientSecretForWidget: String = SDKConfiguration.widgetConfig.clientSecret
            let isAnonymousForWidget: Bool = SDKConfiguration.widgetConfig.isAnonymous
            let chatBotNameForWidget: String = SDKConfiguration.widgetConfig.chatBotName
            let botIdForWidget: String = SDKConfiguration.widgetConfig.botId
            var identityForWidget: String! = nil
            if (isAnonymousForWidget) {
                identityForWidget = self.getUUID()
            } else {
                identityForWidget = SDKConfiguration.widgetConfig.identity
            }
            
            if !clientIdForWidget.hasPrefix("<") && !clientSecretForWidget.hasPrefix("<") && !chatBotNameForWidget.hasPrefix("<") && !botIdForWidget.hasPrefix("<") && !identityForWidget.hasPrefix("<") {
                
                kaBotClient.getWidgetJwTokenWithClientId(clientIdForWidget, clientSecret: clientSecretForWidget, identity: identityForWidget, isAnonymous: isAnonymousForWidget, success: { [weak self] (jwToken) in
                    if let token = jwToken{
                        self?.panelCollectionViewContainerHeightConstraint.constant = 55.0
                        self?.initializeWidgetManager(widgetJWTToken: token)
                        self?.configurePanelCollectionView()
                        self?.populatePanelItems()
                    }
                }, failure: { (error) in
                    print(error)
                    
                })
                
            }else{
                self.showAlert(title: appDisplayName, message: "YOU MUST SET WIDGET 'clientId', 'clientSecret', 'chatBotName', 'identity' and 'botId'. Please check the documentation.")
            }

        } else {
            panelCollectionViewContainerHeightConstraint.constant = 0
        }
    }
    
    func showdDynamicError(messageString:String){
        let payloadStr = ["text":messageString,"color": "#fc0307"]
        let message: Message = Message()
        message.messageType = .reply
        message.sentDate = Date()
        message.messageId = UUID().uuidString
        let textComponent: Component = Component(.error)
        textComponent.payload = Utilities.stringFromJSONObject(object: payloadStr)
        message.addComponent(textComponent)
        addMessages(message, "")
    }

    
    func showAlert(title: String, message: String) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        //**
        let titleAttributes = [NSAttributedString.Key.font: UIFont(name: mediumCustomFont, size: 15.0), NSAttributedString.Key.foregroundColor: UIColor.black]
        let titleString = NSAttributedString(string: alertController.title!, attributes: titleAttributes as [NSAttributedString.Key : Any])
        let messageAttributes = [NSAttributedString.Key.font: UIFont(name: mediumCustomFont, size: 14.0), NSAttributedString.Key.foregroundColor: UIColor.black]
        let messageString = NSAttributedString(string: alertController.message!, attributes: messageAttributes as [NSAttributedString.Key : Any])
        alertController.setValue(titleString, forKey: "attributedTitle")
        alertController.setValue(messageString, forKey: "attributedMessage")
        if #available(iOS 13.0, *) {
            alertController.overrideUserInterfaceStyle  = .light
        }
        //     **
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func getUUID() -> String {
        var id: String?
        let userDefaults = UserDefaults.standard
        if let UUID = userDefaults.string(forKey: "UUID") {
            id = UUID
        } else {
            let date: Date = Date()
            id = String(format: "email%ld%@", date.timeIntervalSince1970, "@domain.com")
            userDefaults.set(id, forKey: "UUID")
        }
        return id!
    }
    
    func showLoader(){
        [linerProgressBar].forEach {
            $0.startAnimating()
        }
    }
    
    func stopLoader(){
        [linerProgressBar].forEach {
            $0.stopAnimating()
        }
    }
    
    func brandingValuesChanges(){
        let font:UIFont? = UIFont(name: boldCustomFont, size:16)
        let titleStr = SDKConfiguration.botConfig.chatBotName
        headerTitileLbl.text = titleStr
        headerTitileLbl.font = font
        headerTitileLbl.textColor = UIColor.init(hexString: "#000000")
        
        self.view.backgroundColor = UIColor.init(hexString: "#F8FAFC")
        BubbleViewRightTint = UIColor.init(hexString: "#2881DF")
        themeColor = BubbleViewRightTint
        BubbleViewLeftTint = UIColor.init(hexString: "#F0F1F2")
        BubbleViewUserChatTextColor = UIColor.init(hexString: "#FFFFFF")
        BubbleViewBotChatTextColor = UIColor.init(hexString: "#000000")
        headerView.backgroundColor = UIColor.init(hexString: "#FFFFFF")
        
    }
}
// MARK: - LeftMenu
extension ChatMessagesViewController: LeftMenuViewDelegate{
    func leftMenuSelectedText(text: String, payload: String) {
        leftMenuBackBtnAct(self as Any)
        Timer.scheduledTimer(withTimeInterval: 0.6, repeats: false) { (_) in
            self.optionsButtonTapNewAction(text: text, payload: payload)
        }
    }
    func leftMenulinkAction(urlString: String) {
        if verifyUrl(urlString: urlString){
            if (urlString.count > 0) {
                NotificationCenter.default.post(name: Notification.Name(stopSpeakingNotification), object: nil)
                leftMenuBackBtnAct(self as Any)
                Timer.scheduledTimer(withTimeInterval: 0.6, repeats: false) { (_) in
                    let url: URL = URL(string: urlString)!
                    let webViewController = SFSafariViewController(url: url)
                    self.present(webViewController, animated: true, completion:nil)
                }
            }
        }
        
    }
    
    @IBAction func leftMenuBackBtnAct(_ sender: Any) {
        let frame = UIScreen.main.bounds.size
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: {
                let moveLeft = CGAffineTransform(translationX: frame.width * -1, y: 0.0)
                self.leftMenuContainerView.transform = moveLeft
            }) { (finished) in
                self.leftMenuContainerView.isHidden = true
            }
    }
    
    func configureleftMenu(){
        leftMenuContainerView.isHidden = true
        self.view.bringSubviewToFront(leftMenuContainerView)
        self.leftMenuTitleLbl.font = UIFont(name: mediumCustomFont, size: 14.0)
        self.leftMenuView = LeftMenuView()
        self.leftMenuView.translatesAutoresizingMaskIntoConstraints = false
        self.leftMenuView.backgroundColor = .clear
        self.leftMenuView.viewDelegate = self
        self.leftMenuContainerSubView.addSubview(self.leftMenuView!)
        
        self.leftMenuContainerSubView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[leftMenuView]|", options:[], metrics:nil, views:["leftMenuView" : self.leftMenuView!]))
        self.leftMenuContainerSubView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-70-[leftMenuView]|", options:[], metrics:nil, views:["leftMenuView" : self.leftMenuView!]))
        
    }
    
    
}

// MARK: - Widgets
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
    public func startTryOut() {
        
    }
    // MARK: -
    func processActionPanelItem(_ item: KREPanelItem?) {
        if let uriString = item?.action?.uri, let url = URL(string: uriString + "?teamId=59196d5a0dd8e3a07ff6362b") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    func closeWidgetPanelView(){
        if SDKConfiguration.widgetConfig.isPanelView {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ClosePanel"), object: nil)
        }
    }
    func initializeWidgetManager(widgetJWTToken: String) {
        let widgetManager = KREWidgetManager.shared
        let user = KREUser()
        user.userId = SDKConfiguration.widgetConfig.botId //userId
        user.accessToken = widgetJWTToken
        user.server = "\(SDKConfiguration.serverConfig.WIDGET_SERVER)/"
        user.tokenType = "bearer"
        user.userEmail = SDKConfiguration.widgetConfig.identity
        user.headers = ["X-KORA-Client": KoraAssistant.shared.applicationHeader]
        widgetManager.initialize(with: user)
        self.user = user
        widgetManager.sessionExpiredAction = { (error) in
            DispatchQueue.main.async {
            }
        }
    }
}

extension ChatMessagesViewController {
    func toastMessage(_ message: String){
        guard let window = UIApplication.shared.keyWindow else {return}
        let messageLbl = UILabel()
        messageLbl.text = message
        messageLbl.textAlignment = .center
        messageLbl.font = UIFont.systemFont(ofSize: 12)
        messageLbl.textColor = .white
        messageLbl.backgroundColor = UIColor(white: 0, alpha: 0.5)
        
        let textSize:CGSize = messageLbl.intrinsicContentSize
        let labelWidth = min(textSize.width, window.frame.width - 40)
        //window.frame.height - 80
        let yaxis = self.composeBarContainerView.frame.origin.y + 10
        messageLbl.frame = CGRect(x: 20, y: yaxis, width: labelWidth + 30, height: textSize.height + 20)
        messageLbl.center.x = window.center.x
        messageLbl.layer.cornerRadius = messageLbl.frame.height/2
        messageLbl.layer.masksToBounds = true
        window.addSubview(messageLbl)
        self.view.bringSubviewToFront(messageLbl)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            UIView.animate(withDuration: 2.5, animations: {
                messageLbl.alpha = 0
            }) { (_) in
                messageLbl.removeFromSuperview()
            }
        }
    }
}
extension ChatMessagesViewController: UIGestureRecognizerDelegate{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view?.isDescendant(of: botMessagesView.tableView) == true || touch.view?.isDescendant(of: quickReplyView) == true{
            return false
        }
        return true
    }
}
//SDK V3
extension ChatMessagesViewController{
    func audioComposeBarTaskMenuButtonAction() {
        self.bottomConstraint.constant = 0
        self.taskMenuContainerHeightConstant.constant = 0
        if (self.composeView.isFirstResponder) {
            _ = self.composeView.resignFirstResponder()
        }
        leftMenuContainerView.isHidden = false
        let zero = CGAffineTransform(translationX: 0.0, y: 0.0)
        self.leftMenuContainerView.transform = zero
        
            leftMenuContainerView.semanticContentAttribute = .forceLeftToRight
            leftMenuContainerSubView.semanticContentAttribute = .forceLeftToRight
            let transition = CATransition()
            transition.type = .push
            transition.subtype = .fromLeft
            self.leftMenuContainerView.layer.add(CATransition().segueFromLeft(), forKey: nil)
            self.leftMenuView.leftMenuTableviewReload()
            leftMenuTitleLbl.text = "Menu"
    }
    
    func configureWelcomeScreenView() {
        
//        if let path = Bundle.main.path(forResource: "Branding", ofType: "json") {
//            do {
//                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
//                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
//                if let jsonResult = jsonResult as? Dictionary<String, AnyObject> {
//                    let brandingDic = try DictionaryDecoder().decode(BrandingModel.self, from: jsonResult as [String : Any])
//                    brandingValues = brandingDic
//                }
//            } catch {
//                // handle error
//            }
//        }
        
        if let genaralDic = brandingValues.general{
            if let generalColors = genaralDic.generalColors, generalColors.useColorPaletteOnly == true{
                 useColorPaletteOnly = true
                 genaralPrimaryColor = generalColors.primaryColor ?? "#D38A17"
                 genaralSecondaryColor = generalColors.secondaryColor ?? "#101828"
                 genaralPrimary_textColor = generalColors.primary_text ?? "#C1EDB9"
                 genaralSecondary_textColor = generalColors.secondary_text ?? "#000000"
            }
        }
        
        if let bodyDic = brandingValues.body{
            brandingBodyDic = bodyDic
            if let background = bodyDic.background{
                if background.type == "image"{
                    if let img = background.img, let url = URL(string: img){
                        backgroungImageView.af.setImage(withURL: url, placeholderImage: UIImage(named: "", in: bundleImage, compatibleWith: nil))
                    }
                }else{
                    if let color = bodyDic.background?.color{
                        self.view.backgroundColor = UIColor.init(hexString: color)
                    }
                }
            }
            
            if let userMessage = bodyDic.user_message{
                if let bg_color =  userMessage.bg_color{
                    themeColor  = UIColor.init(hexString: bg_color)
                    if statusBarBackgroundColor != nil{
                        statusBarView.backgroundColor = statusBarBackgroundColor
                        statusBarView.isHidden = false
                    }else{
                        statusBarView.backgroundColor = UIColor.init(hexString: bg_color)
                        statusBarView.isHidden = true
                    }
                    
                    BubbleViewRightTint = UIColor.init(hexString: bg_color)
                    btnBgActiveColor = bg_color
                }
                if let textColor = userMessage.color{
                    BubbleViewUserChatTextColor  = UIColor.init(hexString: textColor)
                    btnActiveTextColor = textColor
                }
            }
            
            if let botMessage = bodyDic.bot_message{
                if let bg_color =  botMessage.bg_color{
                    BubbleViewLeftTint = UIColor.init(hexString: bg_color)
                }
                if let textColor = botMessage.color{
                    BubbleViewBotChatTextColor = UIColor.init(hexString: textColor)
                }
            }
            
            if  useColorPaletteOnly == true{
                BubbleViewRightTint = UIColor.init(hexString:genaralPrimaryColor)
                BubbleViewUserChatTextColor = UIColor.init(hexString:genaralSecondary_textColor)
                BubbleViewLeftTint = UIColor.init(hexString:genaralSecondaryColor)
                BubbleViewBotChatTextColor = UIColor.init(hexString:genaralPrimary_textColor)
                
                btnBgActiveColor = genaralPrimaryColor
                btnActiveTextColor = genaralSecondary_textColor
            }
            
        }
        
        
        chatWelcomeScreenContainerView.isHidden = true
        if isShowWelcomeMsg{
            if let welcomeScreenDic = brandingValues.welcome_screen{
                if let isShowWelcomeScreen = welcomeScreenDic.show, isShowWelcomeScreen == true{
                    self.view.bringSubviewToFront(chatWelcomeScreenContainerView)
                    chatWelcomeScreenContainerView.isHidden = false
                    self.isShowWelcomeScreen = isShowWelcomeScreen
                     
                    self.welcomeScreenView = WelcomeScreenView()
                    self.welcomeScreenView.viewDelegate = self
                    self.welcomeScreenView.translatesAutoresizingMaskIntoConstraints = false
                    self.welcomeScreenView.configure(with: welcomeScreenDic, generalDic: brandingValues.general)
                    self.welcomeScreenView.backgroundColor = UIColor(hexString: "#F8FAFC")
                    self.chatWelcomeScreenContainerView.addSubview(self.welcomeScreenView!)
                    
                    self.chatWelcomeScreenContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[welcomeScreenView]|", options:[], metrics:nil, views:["welcomeScreenView" : self.welcomeScreenView!]))
                    self.chatWelcomeScreenContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[welcomeScreenView]|", options:[], metrics:nil, views:["welcomeScreenView" : self.welcomeScreenView!]))
                }
            }
        }
    
        if let headerDic = brandingValues.header{
            configureHeaderView(headerDic: headerDic)
        }
        headerView.bringSubviewToFront(linerProgressBar)
    }
    
    func configureHeaderView(headerDic: HeaderModel){
        self.headerDic = headerDic
        var titleTxt = headerDic.title?.name
        if titleTxt == ""{
            titleTxt = SDKConfiguration.botConfig.chatBotName
        }
        let titleTxtColor = headerDic.title?.color
        let titleFont = UIFont(name: "HelveticaNeue-Bold", size: 16.0)
        let subTitleTxt = headerDic.sub_title?.name
        let subTitleTxtColor = headerDic.sub_title?.color
        let subTitleFont = UIFont(name: "HelveticaNeue", size: 14.0)
        let deafaultColor = "#ffffff"
        let bgColor = headerDic.bg_color
        let size = headerDic.size
        let showIcon  = headerDic.icon?.show ?? true
        let iconUrl  = headerDic.icon?.icon_url
        
        var headerVHeight = 0.0
        if size == "compact"{
            headerVHeight = 70.0
            self.headerViewHeightConstraint.constant = headerVHeight
        }else if size == "regular"{
            headerVHeight  = 112.0
            self.headerViewHeightConstraint.constant = headerVHeight
        }
        else if size == "large"{
            headerVHeight  = 170.0
            self.headerViewHeightConstraint.constant = headerVHeight
        }
        
        let chatVCHeaderView = ChatVCHeaderView()
        chatVCHeaderView.translatesAutoresizingMaskIntoConstraints = false
        chatVCHeaderView.configure(headerDic: self.headerDic,headerHeight: Float(headerVHeight))
        headerView.addSubview(chatVCHeaderView)
        if useColorPaletteOnly == true{
            headerView.backgroundColor = UIColor.init(hexString: genaralSecondaryColor)
        }
        
        chatVCHeaderView.chatHeaderVBackBtnAct = { [weak self] (text) in
            self?.tapsOnBackBtnAct((Any).self)
        }
        chatVCHeaderView.chatHeaderVHelpBtnAct = { [weak self] (text) in
            self?.tapsOnHelpBtnAct((Any).self)
        }
        chatVCHeaderView.chatHeaderVSupportBtnAct = { [weak self] (text) in
            self?.tapsOnSupportBtnAct((Any).self)
        }
        chatVCHeaderView.chatHeaderVCloseBtnAct = { [weak self] (text) in
            self?.tapsOnCloseBtnAct((Any).self)
        }
        self.headerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[chatVCHeaderView]|", options:[], metrics:nil, views:["chatVCHeaderView" : chatVCHeaderView]))
        self.headerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[chatVCHeaderView]|", options:[], metrics:nil, views:["chatVCHeaderView" : chatVCHeaderView]))
    }
    
    func welcomeScreenBtnsAction(text:String, payload:String){
        chatWelcomeScreenContainerView.isHidden = true
        self.sendTextMessage(text, options: ["body": payload])
    }
    func hidewelcomeScreenView(){
        chatWelcomeScreenContainerView.isHidden = true
    }
    
    @IBAction func tapsOnSupportBtnAct(_ sender: Any) {
        if let liveAgent = headerDic.buttons?.live_agent{
            if let actionType = liveAgent.action?.type, actionType == "postback"{
                if let value = liveAgent.action?.value{
                    optionsButtonTapNewAction(text: value, payload: value)
                }
            }else if let actionType = liveAgent.action?.type, actionType == "url"{
                if let value = liveAgent.action?.value{
                    linkButtonTapAction(urlString: value)
                }
            }
            else if let actionType = liveAgent.action?.type, actionType == "postback|url"{
                if let value = liveAgent.action?.value{
                    optionsButtonTapNewAction(text: value, payload: value)
                }
            }
        }
        
    }
    @IBAction func tapsOnHelpBtnAct(_ sender: Any) {
        if let help = headerDic.buttons?.help{
            if let actionType = help.action?.type, actionType == "postback"{
                if let value = help.action?.value{
                    optionsButtonTapNewAction(text: value, payload: value)
                }
            }else if let actionType = help.action?.type, actionType == "url"{
                if let value = help.action?.value{
                    linkButtonTapAction(urlString: value)
                }
            }else if let actionType = help.action?.type, actionType == "postback|url"{
                if let value = help.action?.value{
                    linkButtonTapAction(urlString: value)
                }
            }
        }
        
    }
    @IBAction func tapsOnCloseBtnAct(_ sender: Any) {
        //botClosed()
        //isShowWelcomeMsg = true
        showCloseOrMinimiseAlert()
    }
}

extension ChatMessagesViewController: inComingCallDelegate{
    func configureIncomingCallView(){
        self.incomingCallContainerView.isHidden = true
        self.inComingCallView = InComingCallView()
        self.inComingCallView.viewDelegate = self
        self.inComingCallView.translatesAutoresizingMaskIntoConstraints = false
        self.incomingCallContainerView.addSubview(self.inComingCallView)
        self.view.bringSubviewToFront(incomingCallContainerView)
        self.incomingCallContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[inComingCallView]-10-|", options:[], metrics:nil, views:["inComingCallView" : self.inComingCallView!]))
        let inComingCallViewHeight = 120.0
        let screenTopConstraint = UIScreen.main.bounds.height/2 - inComingCallViewHeight
        self.incomingCallContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-\(screenTopConstraint)-[inComingCallView]|", options:[], metrics:nil, views:["inComingCallView" : self.inComingCallView!]))
    }
    
    func acceptCallIncomingCall() {
        guard let window = UIApplication.shared.keyWindow else {
            return
        }
        incomingCallContainerView.isHidden = true
        if let domain = callFromAgentData?["domain"] as? String{
            let dynamicRemotePort = 5080
            guard let sipUser = callFromAgentData?["sipUser"] as? String else {
               return
            }
            guard let videoCall = callFromAgentData?["videoCall"] as? Bool else{
                return
            }
            #if SWIFT_PACKAGE
            //agentConnect.showAgentWindow(window:window, domain: domain, dynamicRemoteHost: domain, port: dynamicRemotePort, sipUser: sipUser, isVideoCall: videoCall)
            #endif
           
        }
        
    }
    
    func rejectIncomingCall() {
        incomingCallContainerView.isHidden = true
        var typeDic = callFromAgentData
        typeDic?["type"] = "call_agent_webrtc_rejected"
        self.botClient.sendMessage("", options: ["body": typeDic ?? [:]])
    }
    
    @objc func callFromAgent(notification:Notification){
        view.endEditing(true) //KeyBoard Hide
        
        let dataString: String = notification.object as! String
        if let agentCallData = Utilities.jsonObjectFromString(jsonString: dataString){
            callFromAgentData = agentCallData as? [String : Any]
        }
        incomingCallContainerView.isHidden = false
        var imageStr = ""
        var nameStr = ""
        var isVideoCall = false
        if let imgStr = callFromAgentData?["profileIcon"] as? String{
            imageStr = imgStr
        }
        if let firstName = callFromAgentData?["firstName"] as? String{
            nameStr = firstName
        }
        if let videoCall = callFromAgentData?["videoCall"] as? Bool{
            isVideoCall = videoCall
        }
        self.inComingCallView.configure(imageUrlStr: imageStr, nameStr: nameStr, isVideoCall: isVideoCall)
    }
}
