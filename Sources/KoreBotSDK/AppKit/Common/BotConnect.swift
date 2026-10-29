//
//  BotConnect.swift
//  KoreBotSDKFrameWork
//
//  Created by Kartheek.Pagidimarri on 17/05/21.
//  Copyright © 2021 Kartheek.Pagidimarri. All rights reserved.
//

import UIKit
import Alamofire

import CoreData

open class BotConnect: NSObject {
    let bundle = Bundle.sdkModule
    public var showQuickRepliesBottom = true
    public var closeOrMinimizeEvent: ((_ dic: [String:Any]?) -> Void)!
    public var closeAgentChatEventName = "close_agent_chat"
    public var closeButtonEventName = "close_button_event"
    public var minimizeButtonEventName = "minimize_button_event"
    public var isZenDeskEvent = false
    public var device_Token: String? = nil
    public var networkOnResumeCallingHistory = true
    public var koreSDkLanguage = "en"
    public var composeBar_Placeholder = ""
    public var tap_To_Speak = ""
    public var close_Or_MinimizeTitle = ""
    public var close_Btn_Title = ""
    public var cancel_Btn_Title = ""
    public var minimize_Btn_Title = ""
    public var alert_Ok = ""
    public var leftMenu_Title = ""
    public var confirm_Title = ""
    public var please_Try_Again = ""
    public var sessionExpiry_Msg = ""
    public var agentImage: UIImage? = nil
    public var agentImageUrlString: String? = nil
    /// Optional absolute URL for a self-hosted AudioCodes WebRTC JavaScript client.
    /// When unset, the SDK loads the versioned client from BOTServerUrl.
    public var audioCodesSDKURL: String? = nil
    /// Click-to-call flow ID configured for the contact-center voice flow.
    public var clickToCallFlowId: String? = nil
    var botViewController:ChatMessagesViewController!
    public var default_Notifications = true
    public var enableButtonClicksOnAnyPosition = false
    
    // MARK: - init
    public override init() {
        super.init()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func show(){
        guard let rootViewController = UIApplication.shared.keyWindow?.rootViewController else {
            return
        }
        customSettings()
        botViewController = ChatMessagesViewController()
        isChatMessageViewControllerPresent = true
        let navigationController = UINavigationController(rootViewController: botViewController)
        navigationController.isNavigationBarHidden = true
        navigationController.modalPresentationStyle = .fullScreen
        botViewController.title = SDKConfiguration.botConfig.chatBotName
        botViewController.modalPresentationStyle = .fullScreen
        rootViewController.present(navigationController, animated: false)
        
        botViewController.closeAndMinimizeEvent = { [weak self] (Dic) in
           if let dic = Dic {
               if self?.closeOrMinimizeEvent != nil{
                   self?.closeOrMinimizeEvent(dic)
               }
           }
       }
    }
    public func show(in viewController: UIViewController){
        customSettings()
        botViewController = ChatMessagesViewController()
        isChatMessageViewControllerPresent = false
        let navigationController = UINavigationController(rootViewController: botViewController)
        navigationController.isNavigationBarHidden = true
        botViewController.title = SDKConfiguration.botConfig.chatBotName
        botViewController.edgesForExtendedLayout =  []
        viewController.navigationController?.show(botViewController, sender: nil)
        
        botViewController.closeAndMinimizeEvent = { [weak self] (Dic) in
           if let dic = Dic {
               if self?.closeOrMinimizeEvent != nil{
                   self?.closeOrMinimizeEvent(dic)
               }
           }
       }
    }
    
    func loadCustomFonts(){
        regularCustomFont = "HelveticaNeue"
        mediumCustomFont = "HelveticaNeue-Medium"
        boldCustomFont = "HelveticaNeue-Bold"
        semiBoldCustomFont = "HelveticaNeue-Semibold"
        italicCustomFont =  "HelveticaNeue-Italic"
    }
    func customSettings(){
        isNetworkOnResumeCallingHistory = networkOnResumeCallingHistory
        SDKConfiguration.serverConfig.AUDIOCODES_SDK_URL = audioCodesSDKURL
        SDKConfiguration.botConfig.clickToCallFlowId = clickToCallFlowId
        SDKConfiguration.botConfig.deviceToken = device_Token
        isShowQuickRepliesBottom = showQuickRepliesBottom
        close_AgentChat_EventName = closeAgentChatEventName
        close_Button_EventName = closeButtonEventName
        minimize_Button_EventName = minimizeButtonEventName
        isZenDesk_Event = isZenDeskEvent
        loadCustomFonts()
        laguageSettings()
        isCallingHistoryApi = true
        agent_Image = agentImage
        agent_Image_UrlString = agentImageUrlString
        default_notifications = default_Notifications
        buttons_Remain_Clickable = enableButtonClicksOnAnyPosition
        if !isIntialiseFileUpload{
            isIntialiseFileUpload = true
            filesUpload()
        }
    }
    
    func filesUpload(){
        let koraApplication = KoraApplication.sharedInstance
        if !koraApplication.isStackInitialised() {
            
        }
        
        if koraApplication.account == nil {
            
        }
        
        KoraApplication.sharedInstance.prepareNewAccount(userInfo: [:], auth: [:]) { (success, error) in
            
        }
    }
    
    public func setConnectionMode(connectMode: String){
        connectModeString = "&ConnectionMode="+connectMode
    }
    public func setStatusBarBackgroundColor(bgColor: UIColor){
        statusBarBackgroundColor = bgColor
    }
    public func setBottomStatusBarBackgroundColor(bgColor: UIColor){
        statusBarBottomBackgroundColor = bgColor
    }
    public func setBrandingConfig(configTheme:BrandingModel){
        overRideBrandingTheme = configTheme
    }
    public func socketDisconnect(){
        isShowWelcomeMsg = true
    }
    // MARK: MinimiseChatBot
    public func minimizeChatBot(){
        if botViewController != nil{
            botViewController.minimizeChatBotWindow()
        }
    }
    public func initialize(_ clientId: String, clientSecret: String, botId: String, chatBotName: String, identity: String, isAnonymous: Bool, isWebhookEnabled: Bool, JWTServerUrl: String, BOTServerUrl: String, BrandingUrl: String, customData: [String: Any], queryParameters:[[String: Any]], customJWToken: String){
        customSettings()
        SDKConfiguration.botConfig.clientId = clientId as String
        SDKConfiguration.botConfig.clientSecret = clientSecret as String
        SDKConfiguration.botConfig.botId = botId as String
        SDKConfiguration.botConfig.chatBotName = chatBotName as String
        SDKConfiguration.botConfig.identity = identity as String
        SDKConfiguration.botConfig.isAnonymous =  isAnonymous as Bool
        SDKConfiguration.botConfig.isWebhookEnabled =  isWebhookEnabled as Bool
        SDKConfiguration.serverConfig.JWT_SERVER = JWTServerUrl as String
        SDKConfiguration.serverConfig.BOT_SERVER = BOTServerUrl as String
        SDKConfiguration.serverConfig.Branding_SERVER = BrandingUrl as String
        SDKConfiguration.botConfig.customData = customData as [String: Any]
        SDKConfiguration.botConfig.queryParameters = queryParameters as [[String: Any]]
        SDKConfiguration.botConfig.customJWToken = customJWToken
    }
    
    public func addCustomTemplates(numbersOfViews:[BubbleView.Type], customerTemplaateTypes:[String]){
        arrayOfViews = numbersOfViews
        arrayOfTemplateTypes = customerTemplaateTypes
        print(arrayOfViews.count)
    }
    
    func laguageSettings(){
        //let locale = NSLocale.current.languageCode
        var localizedText = koreSDkLanguage
            if let path = bundle.path(forResource: localizedText, ofType: "lproj") {
                  let bundle = Bundle(path: path)
                  getLaguageValues(bundle: bundle!)
            }else{
                if let url = bundle.url(forResource: localizedText, withExtension: "lproj", subdirectory: "Languages"){
                    let bundle = Bundle(url: url)
                    getLaguageValues(bundle: bundle!)
                }else{
                    //localizedText = Text("How to change the language inside of the app.", bundle: bundleImage)
                }
            }
    }
    
    func getLaguageValues(bundle: Bundle){
        if composeBar_Placeholder != ""{
            composeBarPlaceholder = composeBar_Placeholder
        }else{
            composeBarPlaceholder = bundle.localizedString(forKey: "composeBarPlaceholder", value: "", table: nil)
        }
        
        if tap_To_Speak != ""{
            tapToSpeak = tap_To_Speak
        }else{
            tapToSpeak = bundle.localizedString(forKey: "tapToSpeak", value: "", table: nil)
        }
        
        if close_Or_MinimizeTitle != ""{
            closeOrMinimizeMsg = close_Or_MinimizeTitle
        }else{
            closeOrMinimizeMsg = bundle.localizedString(forKey: "closeOrMinimizeMsg", value: "", table: nil)
        }
        
        if close_Btn_Title != ""{
            closeBtnTitle = close_Btn_Title
        }else{
            closeBtnTitle = bundle.localizedString(forKey: "closeMsg", value: "", table: nil)
        }
        
        if cancel_Btn_Title != ""{
            cancelBtnTitle = cancel_Btn_Title
        }else{
            cancelBtnTitle = bundle.localizedString(forKey: "cancelBtnMsg", value: "", table: nil)
        }
        
        if minimize_Btn_Title != ""{
            minimizeBtnTitle = minimize_Btn_Title
        }else{
            minimizeBtnTitle = bundle.localizedString(forKey: "minimizeMsg", value: "", table: nil)
        }
        
        if alert_Ok != ""{
            alertOk = alert_Ok
        }else{
            alertOk = bundle.localizedString(forKey: "alertOk", value: "", table: nil)
        }
        
        if leftMenu_Title != ""{
            leftMenuTitle = leftMenu_Title
        }else{
            leftMenuTitle = bundle.localizedString(forKey: "leftMenuTitle", value: "", table: nil)
        }
        
        if confirm_Title != ""{
            confirm = confirm_Title
        }else{
            confirm = bundle.localizedString(forKey: "confirm", value: "", table: nil)
        }
        
        if please_Try_Again != ""{
            pleaseTryAgain = please_Try_Again
        }else{
            pleaseTryAgain = bundle.localizedString(forKey: "pleaseTryAgain", value: "", table: nil)
        }
        
        if sessionExpiry_Msg != ""{
            sessionExpiryMsg = sessionExpiry_Msg
        }else{
            sessionExpiryMsg = bundle.localizedString(forKey: "sessionExpiryMsg", value: "", table: nil)
        }
    }
    
    public func addCustomHeaderView(headerView: KoreCustomHeaderView, headerViewHeight: Double? = 64.0){
        customHeaderView = headerView
        customHeaderViewHeight = headerViewHeight ?? 64.0
    }
    public func addCustomFooterComposeBarView(footerView: ComposeBarView, growingTxtV: KREGrowingTextView){
        dynamicFooterview = footerView
        dynamicGrowingTxtv = growingTxtV
    }
    public func addCustomFooterAudioComposeBar(footerView: AudioComposeView){
        dynamicAudioComposeFooterview = footerView
    }
    
    public func subscribeNotifications(){
        if botViewController != nil{
            botViewController.subscribeNotifications()
        }
    }
    
    public func unsubscribeNotifications(){
        if botViewController != nil{
            botViewController.unsubscribeNotifications()
        }
    }
}

