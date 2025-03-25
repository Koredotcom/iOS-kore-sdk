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
    public var showVideoOption = false
    public var closeAgentChatEventName = "close_agent_chat"
    public var closeButtonEventName = "close_button_event"
    public var minimizeButtonEventName = "minimize_button_event"
    public var isZenDeskEvent = false
    public var history_enable = true
    public var history_batch_size = 20
    public var koreSDkLanguage = "en"
    public var networkOnResumeCallingHistory = true
    public var setIsShowBotIconTop = false
    public var device_Token: Data? = nil
    var botViewController:ChatMessagesViewController!
    public var composeBar_Placeholder = ""
    public var tap_To_Speak = ""
    public var close_Or_MinimizeTitle = ""
    public var close_Btn = ""
    public var minimize_Btn = ""
    public var alert_Ok = ""
    public var leftMenu_Title = ""
    public var confirm_Title = ""
    public var please_Try_Again = ""
    public var sessionExpiry_Msg = ""
    public var closeOrMinimizeEvent: ((_ dic: [String:Any]?) -> Void)!
    // MARK: - init
    public override init() {
        super.init()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func show(){
        customSettings()
        
        guard let rootViewController = UIApplication.shared.keyWindow?.rootViewController else {
            return
        }
        
         botViewController = ChatMessagesViewController()
        let navigationController = UINavigationController(rootViewController: botViewController)
        navigationController.isNavigationBarHidden = true
        navigationController.modalPresentationStyle = .fullScreen
        botViewController.title = SDKConfiguration.botConfig.chatBotName
        botViewController.modalPresentationStyle = .fullScreen
        rootViewController.present(navigationController, animated: false)
        
         botViewController.closeAndMinimizeEvent = { [weak self] (Dic) in
            if let dic = Dic {
                //let jsonString = Utilities.stringFromJSONObject(object: dic)
                //NotificationCenter.default.post(name: Notification.Name("ChatbotCallBackNotification"), object: jsonString)
                if self?.closeOrMinimizeEvent != nil{
                    self?.closeOrMinimizeEvent(dic)
                }
            }
        }
    }
    
    func customSettings(){
        isShowQuickRepliesBottom = showQuickRepliesBottom
        isShowVideoOption = showVideoOption
        close_AgentChat_EventName = closeAgentChatEventName
        close_Button_EventName = closeButtonEventName
        minimize_Button_EventName = minimizeButtonEventName
        isZenDesk_Event = isZenDeskEvent
        SDKConfiguration.botConfig.isShowChatHistory = history_enable
        SDKConfiguration.botConfig.history_batch_size = history_batch_size
        laguageSettings()
        SDKConfiguration.botConfig.deviceToken = device_Token
        loadCustomFonts()
        isCallingHistoryApi = true
        isNetworkOnResumeCallingHistory = networkOnResumeCallingHistory
        isShowBotIconTop = setIsShowBotIconTop
        if !isIntialiseFileUpload{
            isIntialiseFileUpload = true
            filesUpload()
        }
    }
    
    public func setBrandingConfig(configTheme:ActiveTheme){
        localActiveTheme = configTheme
    }
    
    public func setStatusBarBackgroundColor(bgColor: UIColor){
        statusBarBackgroundColor = bgColor
    }
    
    public func setBottomStatusBarBackgroundColor(bgColor: UIColor){
        statusBarBottomBackgroundColor = bgColor
    }
    
    public func setConnectionMode(connectMode: String){
        connectModeString = "&ConnectionMode="+connectMode
    }
    
    public func socketDisconnect(){
        botViewController.socketDisconnect()
    }
    
    public func socketConnect(isReconnect:Bool){
        botViewController.socketConnect(isReconnect: isReconnect)
    }
    
    // MARK: MinimiseChatBot
    public func minimizeChatBot(){
        botViewController.minimizeChatBotWindow()
    }
        
    func loadCustomFonts(){
        regularCustomFont = "HelveticaNeue"
        mediumCustomFont = "HelveticaNeue-Medium"
        boldCustomFont = "HelveticaNeue-Bold"
        semiBoldCustomFont = "HelveticaNeue-Semibold"
        italicCustomFont =  "HelveticaNeue-Italic"
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
    
    public func showOrHideFooterViewIcons(isShowSpeachToTextIcon:Bool, isShowAttachmentIcon:Bool, isShowMenuBtnIcon: Bool? = nil){
        SDKConfiguration.botConfig.isShowSpeachToTextIcon = isShowSpeachToTextIcon
        SDKConfiguration.botConfig.isShowAttachmentIcon = isShowAttachmentIcon
        if let showMenu = isShowMenuBtnIcon{
            isShowComposeMenuBtn = showMenu
        }
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
        
        if close_Btn != ""{
            closeMsg = close_Btn
        }else{
            closeMsg = bundle.localizedString(forKey: "closeMsg", value: "", table: nil)
        }
        
        if minimize_Btn != ""{
            minimizeMsg = minimize_Btn
        }else{
            minimizeMsg = bundle.localizedString(forKey: "minimizeMsg", value: "", table: nil)
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
    
    public func customTemplatesFromCustomer(numbersOfViews:[BubbleView], customerTemplaateTypes:[String]){
        arrayOfViews = numbersOfViews
        arrayOfTemplateTypes = customerTemplaateTypes
        print(arrayOfViews.count)
    }
    
}

