//
//  SDKConfiguration.swift
//  KoreBotSDKDemo
//
//  Created by developer@kore.com on 12/16/16.
//  Copyright © 2016 Kore Inc. All rights reserved.
//

import UIKit
import KoreBotSDK

class SDKConfiguration: NSObject {
    
    struct dataStoreConfig {
        static let resetDataStoreOnConnect = true // This should be either true or false. Conversation with the bot will be persisted, if it is false.
    }
    
    struct botConfig {
        public static var clientId = "<client-id>" // Copy this value from Bot Builder SDK Settings.
        
        public static var clientSecret = "<client-secret>" // Copy this value from Bot Builder SDK Settings.
        
        public static var botId =  "<bot-id>" // Copy this value from Bot Builder -> Channels -> Web/Mobile Client.

        public static var chatBotName = "bot-name" // Copy this value from Bot Builder -> Channels -> Web/Mobile Client.
        
        public static var identity = "<identity-email> or <random-id>"// This should represent the subject for JWT token. This can be an email or phone number, in case of known user, and in case of anonymous user, this can be a randomly generated unique id.
        
        public static var isAnonymous = true // This should be either true (in case of known-user) or false (in-case of anonymous user).

        public static var isWebhookEnabled = false // This should be either true (in case of Webhook connection) or false (in-case of Socket connection).
        
        public static var enableAckDelivery = false // Set true to send acknowledgment to server on receiving response from bot
        
        public static var tenantId = "12112123123" // This is For Branding
        
        public static var customData : [String: Any] = [:]
        
        public static var queryParameters : [[String: Any]] = []
        
        public static var customJWToken : String = "" //This should represent the subject for send own JWToken.
        
        static var isShowChatHistory = true // Set true to Show chat history or false hide chat history.
        
        public static var deviceToken:Data? =  nil
    }
    
    struct serverConfig {
        public static var JWT_SERVER = String(format: "http://<jwt-server-host>/") // Replace it with the actual JWT server URL, if required. Refer to developer documentation for instructions on hosting JWT Server.
        
        static func koreJwtUrl() -> String {
            return String(format: "%@users/sts", JWT_SERVER)
        }
        
        public static var BOT_SERVER = String(format: "https://bots.kore.ai")
        public static var Branding_SERVER = String(format: "https://bots.kore.ai")
        public static var WIDGET_SERVER = String(format: "https://bots.kore.ai")
    }
   
    struct widgetConfig {
        static let clientId = "<client-id>" // Copy this value from Bot Builder SDK Settings.
        
        static let clientSecret = "<client-secret>" // Copy this value from Bot Builder SDK Settings.
        
        static let botId =  "<bot-id>" // Copy this value from Bot Builder -> Channels -> Web/Mobile Client.

        static let chatBotName = "bot-name" // Copy this value from Bot Builder -> Channels -> Web/Mobile Client.
        
        static let identity = "<identity-email> or <random-id>"// This should represent the subject for JWT token. This can be an email or phone number, in case of known user, and in case of anonymous user, this can be a randomly generated unique id.
        
        static let isAnonymous = true // This should be either true (in case of known-user) or false (in-case of anonymous user).
        
        static let isPanelView = false // This should be either true (in case of Show Panel) or false (in-case of Hide Panel).
    }
    
    // googleapi speech API_KEY
    struct speechConfig {
        static let API_KEY = "<speech_api_key>"
    }
}
