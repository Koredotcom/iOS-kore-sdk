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
        public static var clientId = "cs-16267e93-ae50-58f3-852a-6034d89b1cfa" // Copy this value from Bot Builder SDK Settings ex. cs-5250bdc9-6bfe-5ece-92c9-ab54aa2d4285
        
        public static var clientSecret = "MARMSzQORkdqUvNiyV9dmFkYf73DfqoXrOEJ1o1n6Cw=" // Copy this value from Bot Builder SDK Settings ex. Wibn3ULagYyq0J10LCndswYycHGLuIWbwHvTRSfLwhs=
        
        public static var botId =  "st-ab5a9721-28ec-5a68-9bd5-ccab1641bd66" // Copy this value from Bot Builder -> Channels -> Web/Mobile Client  ex. st-acecd91f-b009-5f3f-9c15-7249186d827d

        public static var chatBotName = "SDKBot" // Copy this value from Bot Builder -> Channels -> Web/Mobile Client  ex. "Demo Bot"
        
        public static var identity = "abc@kore.com"// This should represent the subject for JWT token. This can be an email or phone number, in case of known user, and in case of anonymous user, this can be a randomly generated unique id.
        
        public static var isAnonymous = true // This should be either true (in case of known-user) or false (in-case of anonymous user).
        
        public static var tenantId = "62bea6976a9b7201099eb67b" // This is For Branding

        public static var isWebhookEnabled = false // This should be either true (in case of Webhook connection) or false (in-case of Socket connection).
        
        public static var enableAckDelivery = false // Set true to send acknowledgment to server on receiving response from bot
        
        static let isShowChatHistory = false // Set true to Show chat history or false hide chat history.
        
        public static var customData : [String: Any] = [:]
    }
    
    struct serverConfig {
        public static var JWT_SERVER = String(format: "https://gw.dev.baraq.com/koreai/api/") // Replace it with the actual JWT server URL, if required. Refer to developer documentation for instructions on hosting JWT Server.
        
        static func koreJwtUrl() -> String {
            return String(format: "%@users/sts", JWT_SERVER)
        }
        
        public static var BOT_SERVER = String(format: "https://koreai.dev.baraq.com")
        public  static var Branding_SERVER = String(format: "https://koreai.dev.baraq.com")
        public static var reWriteSocketUrl = "koreai.dev.baraq.com" //koreai.dev.baraq.com
        
        public static let WIDGET_SERVER = String(format: "https://bots.kore.ai")
        
    }
       
    // googleapi speech API_KEY
    struct speechConfig {
        static let API_KEY = "<speech_api_key>"
    }
}
