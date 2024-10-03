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

    public var showQuickRepliesBottom = true
    public var showVideoOption = false
    public var closeAgentChatEventName = "close_agent_chat"
    public var closeButtonEventName = "close_button_event"
    public var minimizeButtonEventName = "minimize_button_event"
    
    public var closeOrMinimizeEvent: ((_ dic: [String:Any]?) -> Void)!
    // MARK: - init
    public override init() {
        super.init()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func show(){
        isShowQuickRepliesBottom = showQuickRepliesBottom
        isShowVideoOption = showVideoOption
        close_AgentChat_EventName = closeAgentChatEventName
        close_Button_EventName = closeButtonEventName
        minimize_Button_EventName = minimizeButtonEventName
        guard let rootViewController = UIApplication.shared.keyWindow?.rootViewController else {
            return
        }
        loadCustomFonts()
        isCallingHistoryApi = true
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
                let jsonString = Utilities.stringFromJSONObject(object: dic)
                NotificationCenter.default.post(name: Notification.Name("ChatbotCallBackNotification"), object: jsonString)
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
    
    public func showOrHideFooterViewIcons(isShowSpeachToTextIcon:Bool, isShowAttachmentIcon:Bool){
        SDKConfiguration.botConfig.isShowSpeachToTextIcon = isShowSpeachToTextIcon
        SDKConfiguration.botConfig.isShowAttachmentIcon = isShowAttachmentIcon
    }
    
    public func customTemplatesFromCustomer(numbersOfViews:[BubbleView], customerTemplaateTypes:[String]){
        arrayOfViews = numbersOfViews
        arrayOfTemplateTypes = customerTemplaateTypes
        print(arrayOfViews.count)
    }
    
}

