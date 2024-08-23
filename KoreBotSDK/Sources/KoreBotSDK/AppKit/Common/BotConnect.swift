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

import CoreGraphics
import CoreText

open class BotConnect: NSObject {
    var customEnabled = false
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
        loadDefaultFonts()
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
    
    func filesUpload(){
        let koraApplication = KoraApplication.sharedInstance
        if !koraApplication.isStackInitialised() {
            
        }
        
        if koraApplication.account == nil {
            
        }
        
        KoraApplication.sharedInstance.prepareNewAccount(userInfo: [:], auth: [:]) { (success, error) in
            
        }
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
    
    func loadDefaultFonts(){
        if !customEnabled{
            regularCustomFont = "HelveticaNeue"
            mediumCustomFont = "HelveticaNeue-Medium"
            boldCustomFont = "HelveticaNeue-Bold"
            semiBoldCustomFont = "HelveticaNeue-Semibold"
            italicCustomFont =  "HelveticaNeue-Italic"
            
            let userDefaults = UserDefaults.standard
                userDefaults.set(regularCustomFont, forKey: "Regular")
                userDefaults.set(mediumCustomFont, forKey: "Medium")
                userDefaults.set(boldCustomFont, forKey: "Bold")
                userDefaults.set(semiBoldCustomFont, forKey: "Semibold")
                userDefaults.set(italicCustomFont, forKey: "Italic")
                userDefaults.synchronize()
        }
    }
    
    public func loadCustomFonts(regularFont:String?, mediumFont:String?, boldFont:String?, semiBoldFont:String?, italicFont:String?){
        customEnabled = true
        if !isLoadCustomFonts{
            isLoadCustomFonts = true
            let userDefaults = UserDefaults.standard
           if let regular = regularFont{
               do {
                  try registerFont(named: regular)
                   regularCustomFont = regular
                   userDefaults.set(regularCustomFont, forKey: "Regular")
               } catch {
                  let reason = error.localizedDescription
                   regularCustomFont = "HelveticaNeue"
                   userDefaults.set(regularCustomFont, forKey: "Regular")
               }
           }
           
           if let medium = mediumFont{
               do {
                  try registerFont(named: medium)
                   mediumCustomFont = medium
                   userDefaults.set(mediumCustomFont, forKey: "Medium")
               } catch {
                  let reason = error.localizedDescription
                   mediumCustomFont = "HelveticaNeue-Medium"
                   userDefaults.set(mediumCustomFont, forKey: "Medium")
               }
           }
           
           if let bold = boldFont{
               do {
                  try registerFont(named: bold)
                   boldCustomFont = bold
                   userDefaults.set(boldCustomFont, forKey: "Bold")
               } catch {
                  let reason = error.localizedDescription
                   boldCustomFont = "HelveticaNeue-Bold"
                   userDefaults.set(boldCustomFont, forKey: "Bold")
               }
           }
           
           if let semiBold = semiBoldFont{
               do {
                  try registerFont(named: semiBold)
                   semiBoldCustomFont = semiBold
                   userDefaults.set(semiBoldCustomFont, forKey: "Semibold")
               } catch {
                  let reason = error.localizedDescription
                   semiBoldCustomFont = "HelveticaNeue-Semibold"
                   userDefaults.set(semiBoldCustomFont, forKey: "Semibold")
               }
           }
           
           if let italic = italicFont{
               do {
                  try registerFont(named: italic)
                   italicCustomFont =  italic
                   userDefaults.set(italicCustomFont, forKey: "Italic")
               } catch {
                  let reason = error.localizedDescription
                   italicCustomFont =  "HelveticaNeue-Italic"
                   userDefaults.set(italicCustomFont, forKey: "Italic")
               }
           }
       userDefaults.synchronize()
        }
            
    }
    
    public enum FontError: Swift.Error {
        case failedToRegisterFont
    }
    
    func registerFont(named name: String) throws {
        guard let asset = NSDataAsset(name: "Fonts/\(name)", bundle: Bundle.main),
              let provider = CGDataProvider(data: asset.data as NSData),
              let font = CGFont(provider),
              CTFontManagerRegisterGraphicsFont(font, nil) else {
            throw FontError.failedToRegisterFont
        }
        
    }
}
