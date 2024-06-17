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
        public static var clientId = "cs-1e845b00-81ad-5757-a1e7-d0f6fea227e9" // Copy this value from Bot Builder SDK Settings ex. cs-5250bdc9-6bfe-5ece-92c9-ab54aa2d4285
        
        public static var clientSecret = "5OcBSQtH/k6Q/S6A3bseYfOee02YjjLLTNoT1qZDBso=" // Copy this value from Bot Builder SDK Settings ex. Wibn3ULagYyq0J10LCndswYycHGLuIWbwHvTRSfLwhs=
        
        public static var botId =  "st-b9889c46-218c-58f7-838f-73ae9203488c" // Copy this value from Bot Builder -> Channels -> Web/Mobile Client  ex. st-acecd91f-b009-5f3f-9c15-7249186d827d

        public static var chatBotName = "SDKBot" // Copy this value from Bot Builder -> Channels -> Web/Mobile Client  ex. "Demo Bot"
        
        public static var identity = "rajasekhar.balla@kore.com"// This should represent the subject for JWT token. This can be an email or phone number, in case of known user, and in case of anonymous user, this can be a randomly generated unique id.
        
        public static var isAnonymous = true // This should be either true (in case of known-user) or false (in-case of anonymous user).

        public static var isWebhookEnabled = false // This should be either true (in case of Webhook connection) or false (in-case of Socket connection).
        
        public static var enableAckDelivery = false // Set true to send acknowledgment to server on receiving response from bot
        
        public static var tenantId = "62bea6976a9b7201099eb67b" // This is For Branding
        
        public static var customData : [String: Any] = [:]
        
        public static var queryParameters : [[String: Any]] = []
        
        static let isShowChatHistory = true // Set true to Show chat history or false hide chat history.
    }
    
    struct serverConfig {
        public static var JWT_SERVER = String(format: "https://mk2r2rmj21.execute-api.us-east-1.amazonaws.com/dev/") // Replace it with the actual JWT server URL, if required. Refer to developer documentation for instructions on hosting JWT Server.
        
        static func koreJwtUrl() -> String {
            return String(format: "%@users/sts", JWT_SERVER)
        }
        
        public static var BOT_SERVER = String(format: "https://bots.kore.ai")
        public static var Branding_SERVER = String(format: "https://bots.kore.ai")
        public static var WIDGET_SERVER = String(format: "https://bots.kore.ai")
    }
   
    struct widgetConfig {
        static let clientId = "cs-0245d453-ab18-560f-8205-305e37dfcbb8" // Copy this value from Bot Builder SDK Settings ex. cs-5250bdc9-6bfe-5ece-92c9-ab54aa2d4285
        
        static let clientSecret = "8BpBIPWGMEqhwXuyLAJNlqd6mknIlQxbfQzdJpLJ/RY=" // Copy this value from Bot Builder SDK Settings ex. Wibn3ULagYyq0J10LCndswYycHGLuIWbwHvTRSfLwhs=
        
        static let botId =  "st-e72d2d68-2fe4-5379-bcfc-6b66e2193da4" // Copy this value from Bot Builder -> Channels -> Web/Mobile Client  ex. st-acecd91f-b009-5f3f-9c15-7249186d827d

        static let chatBotName = "Widgets View more" // Copy this value from Bot Builder -> Channels -> Web/Mobile Client  ex. "Demo Bot"
        
        static let identity = "paladiprashanth95@gmail.com"// This should represent the subject for JWT token. This can be an email or phone number, in case of known user, and in case of anonymous user, this can be a randomly generated unique id.
        
        static let isAnonymous = true // This should be either true (in case of known-user) or false (in-case of anonymous user).
        
        static let isPanelView = false // This should be either true (in case of Show Panel) or false (in-case of Hide Panel).
    }
    
    // googleapi speech API_KEY
    struct speechConfig {
        static let API_KEY = "<speech_api_key>"
    }
}
