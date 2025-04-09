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
    public var device_Token: Data? = nil
    public var networkOnResumeCallingHistory = true
    public var koreSDkLanguage = "en"
    public var composeBar_Placeholder = ""
    public var tap_To_Speak = ""
    public var close_Or_MinimizeTitle = ""
    public var close_Btn_Title = ""
    public var minimize_Btn_Title = ""
    public var alert_Ok = ""
    public var leftMenu_Title = ""
    public var confirm_Title = ""
    public var please_Try_Again = ""
    public var sessionExpiry_Msg = ""
    
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
        isShowQuickRepliesBottom = showQuickRepliesBottom
        loadCustomFonts()
        isCallingHistoryApi = true
        close_AgentChat_EventName = closeAgentChatEventName
        if !isIntialiseFileUpload{
            isIntialiseFileUpload = true
            filesUpload()
        }
        let botViewController = ChatMessagesViewController()
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
    
    func loadCustomFonts(){
        regularCustomFont = "HelveticaNeue"
        mediumCustomFont = "HelveticaNeue-Medium"
        boldCustomFont = "HelveticaNeue-Bold"
        semiBoldCustomFont = "HelveticaNeue-Semibold"
        italicCustomFont =  "HelveticaNeue-Italic"
    }
    func customSettings(){
        isNetworkOnResumeCallingHistory = networkOnResumeCallingHistory
        SDKConfiguration.botConfig.deviceToken = device_Token
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
    public func initialize(_ clientId: String, clientSecret: String, botId: String, chatBotName: String, identity: String, isAnonymous: Bool, isWebhookEnabled: Bool, JWTServerUrl: String, BOTServerUrl: String, BrandingUrl: String, customData: [String: Any], queryParameters:[[String: Any]], customJWToken: String){
        
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
    
    public func addCustomTemplates(numbersOfViews:[BubbleView], customerTemplaateTypes:[String]){
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
    
}

