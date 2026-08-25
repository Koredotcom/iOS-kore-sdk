//
//  SDKConfiguration.swift
//  KoreBotSDKDemo
//
//  Created by developer@kore.com on 12/16/16.
//  Copyright © 2016 Kore Inc. All rights reserved.
//

import UIKit

class SDKConfiguration: NSObject {
    
    struct dataStoreConfig {
        static let resetDataStoreOnConnect = true // This should be either true or false. Conversation with the bot will be persisted, if it is false.
    }
    
    struct botConfig {
        public static var clientId = "<client-id>" // Copy this value from Bot Builder SDK Settings.
        
        public static var clientSecret = "<client-secret>" // Copy this value from Bot Builder SDK Settings.
        
        public static var botId =  "<bot-id>" // Copy this value from Bot Builder -> Channels -> Web/Mobile Client.

        public static var chatBotName = "bot-name" // Copy this value from Bot Builder -> Channels -> Web/Mobile Client.

        public static var iosChatScreenPercentage: Int?
        public static var chatScreenPercentage: Int?
        public static var chatWindowHeightPercentage = 90
        public static var resolvedChatScreenPercentage: Int {
            let requestedPercentage =
                iosChatScreenPercentage
                ?? chatScreenPercentage
                ?? chatWindowHeightPercentage
            return min(100, max(1, requestedPercentage))
        }

        public static var showMessageTimeStamps = false

        public static var showTextToSpeech = false
        
        public static var identity = "<identity-email> or <random-id>"// This should represent the subject for JWT token. This can be an email or phone number, in case of known user, and in case of anonymous user, this can be a randomly generated unique id.
        
        public static var isAnonymous = true // This should be either true (in case of known-user) or false (in-case of anonymous user).

        public static var isWebhookEnabled = false // This should be either true (in case of Webhook connection) or false (in-case of Socket connection).
        
        public static var enableAckDelivery = false // Set true to send acknowledgment to server on receiving response from bot
        
        public static var tenantId = "12112123123" // This is For Branding
        
        public static var customData : [String: Any] = [:]
        
        public static var queryParameters : [[String: Any]] = []
        
        public static var customJWToken : String = "" //This should represent the subject for send own JWToken.

        public static var useMoeJwt = true

        /// Extra HTTP headers for MOE JWT requests (from Flutter `customHeaders`).
        public static var customHeaders: [String: String] = [
            "Content-Type": "application/json"
        ]

        static var isShowChatHistory = true // Set true to Show chat history or false hide chat history.
        
        public static var deviceToken:Data? =  nil
    }
    
    struct serverConfig {
        public static var JWT_SERVER = "http://<jwt-server-host>"
        public static var MOE_JWT_SERVER = "http://<jwt-server-host>"
        
        static func koreJwtUrl() -> String {
            return JWT_SERVER
        }

        static func moeJwtUrl() -> String {
            return MOE_JWT_SERVER
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
