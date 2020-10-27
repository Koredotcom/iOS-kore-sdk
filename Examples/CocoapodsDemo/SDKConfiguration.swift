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
    
//    struct botConfig {
//        static let clientId = "cs-e28ed93e-0723-5e22-b8b4-27f8f66de93d" // Copy this value from Bot Builder SDK Settings ex. cs-5250bdc9-6bfe-5ece-92c9-ab54aa2d4285
//
//        static let clientSecret = "ezWdID0H6fu8rJUKLXjKRyMTeIFXmswm0Q/d+dwFkc0=" // Copy this value from Bot Builder SDK Settings ex. Wibn3ULagYyq0J10LCndswYycHGLuIWbwHvTRSfLwhs=
//
//        static let botId =  "st-13bd4aa0-8980-5226-984f-271b6468c848" // Copy this value from Bot Builder -> Channels -> Web/Mobile Client  ex. st-acecd91f-b009-5f3f-9c15-7249186d827d
//
//        static let chatBotName = "QA_Env_WB" // Copy this value from Bot Builder -> Channels -> Web/Mobile Client  ex. "Demo Bot"
//
//        static let identity = "sudheer.jampana@kore.com"// This should represent the subject for JWT token. This can be an email or phone number, in case of known user, and in case of anonymous user, this can be a randomly generated unique id.
//
//        static let isAnonymous = true // This should be either true (in case of known-user) or false (in-case of anonymous user).
//    }
    
//    struct botConfig {
//        static let clientId = "cs-9c811447-60b2-5a25-b4f5-e03c0493f262" // Copy this value from Bot Builder SDK Settings ex. cs-5250bdc9-6bfe-5ece-92c9-ab54aa2d4285
//
//        static let clientSecret = "jTTTEgdvJ1t1Wo+9yVPSMRpM+LrWs3V3f30WubbubIw=" // Copy this value from Bot Builder SDK Settings ex. Wibn3ULagYyq0J10LCndswYycHGLuIWbwHvTRSfLwhs=
//
//        static let botId =  "st-a9413ab9-f1e0-5c26-a23d-2f2fa19ad856" // Copy this value from Bot Builder -> Channels -> Web/Mobile Client  ex. st-acecd91f-b009-5f3f-9c15-7249186d827d
//
//        static let chatBotName = "Banking Staging ENV Bot" // Copy this value from Bot Builder -> Channels -> Web/Mobile Client  ex. "Demo Bot"
//
//        static let identity = "sudheer.jampana@kore.com"// This should represent the subject for JWT token. This can be an email or phone number, in case of known user, and in case of anonymous user, this can be a randomly generated unique id.
//
//        static let isAnonymous = true // This should be either true (in case of known-user) or false (in-case of anonymous user).
//    }
//
    
//    struct botConfig {
//        static let clientId = "cs-a677c7bd-75af-5c14-8f20-a7fccc8753bd" // Copy this value from Bot Builder SDK Settings ex. cs-5250bdc9-6bfe-5ece-92c9-ab54aa2d4285
//
//        static let clientSecret = "5lqiTkUCEykR2omAwp54Ps//7hmQX9WtcuaO2+tIiRQ=" // Copy this value from Bot Builder SDK Settings ex. Wibn3ULagYyq0J10LCndswYycHGLuIWbwHvTRSfLwhs=
//
//        static let botId =  "st-4c43bf14-ac30-51e2-80e9-0f69f246b4a9" // Copy this value from Bot Builder -> Channels -> Web/Mobile Client  ex. st-acecd91f-b009-5f3f-9c15-7249186d827d
//
//        static let chatBotName = "Banking Dev 1" // Copy this value from Bot Builder -> Channels -> Web/Mobile Client  ex. "Demo Bot"
//
//        static let identity = "sudheer.jampana@kore.com"// This should represent the subject for JWT token. This can be an email or phone number, in case of known user, and in case of anonymous user, this can be a randomly generated unique id.
//
//        static let isAnonymous = true // This should be either true (in case of known-user) or false (in-case of anonymous user).
//    }
    
    struct botConfig {
        static let clientId = "cs-5cd31fe5-cc44-5ab1-8b9c-104637d393fe" // Copy this value from Bot Builder SDK Settings ex. cs-5250bdc9-6bfe-5ece-92c9-ab54aa2d4285

        static let clientSecret = "LB2BtYsg4zWjZ6fprvRGhDG9ShX4TrkMNajiATImyIk=" // Copy this value from Bot Builder SDK Settings ex. Wibn3ULagYyq0J10LCndswYycHGLuIWbwHvTRSfLwhs=

        static let botId =  "st-3e4fb572-3e9b-57ae-abd2-13fa1799f947" // Copy this value from Bot Builder -> Channels -> Web/Mobile Client  ex. st-acecd91f-b009-5f3f-9c15-7249186d827d

        static let chatBotName = "IKEA Coworker" // Copy this value from Bot Builder -> Channels -> Web/Mobile Client  ex. "Demo Bot"

        static let identity = "henrikjansen72@gmail.com"// This should represent the subject for JWT token. This can be an email or phone number, in case of known user, and in case of anonymous user, this can be a randomly generated unique id.

        static let isAnonymous = true // This should be either true (in case of known-user) or false (in-case of anonymous user).
    }
    
    struct serverConfig {
        static let JWT_SERVER = String(format: "https://demo.kore.net/") // Replace it with the actual JWT server URL, if required. Refer to developer documentation for instructions on hosting JWT Server.
        
        static func koreJwtUrl() -> String {
            return String(format: "%@users/sts", JWT_SERVER)
        }
        
        static let BOT_SERVER = String(format: "https://bots.kore.ai") //  "https://bots.kore.ai" "https://bankingassistant-stg.kore.ai" "https://bankingassistant-qa.kore.ai"
        public static let KORE_SERVER = String(format: "https://bots.kore.ai/")
    }
   
    struct widgetConfig {
        static let clientId = "cs-5cd31fe5-cc44-5ab1-8b9c-104637d393fe" // Copy this value from Bot Builder SDK Settings ex. cs-5250bdc9-6bfe-5ece-92c9-ab54aa2d4285
        
        static let clientSecret = "LB2BtYsg4zWjZ6fprvRGhDG9ShX4TrkMNajiATImyIk=" // Copy this value from Bot Builder SDK Settings ex. Wibn3ULagYyq0J10LCndswYycHGLuIWbwHvTRSfLwhs=
        
        static let botId =  "st-3e4fb572-3e9b-57ae-abd2-13fa1799f947" // Copy this value from Bot Builder -> Channels -> Web/Mobile Client  ex. st-acecd91f-b009-5f3f-9c15-7249186d827d

        static let chatBotName = "IKEA Coworker" // Copy this value from Bot Builder -> Channels -> Web/Mobile Client  ex. "Demo Bot"
        
        static let identity = "henrikjansen72@gmail.com"// This should represent the subject for JWT token. This can be an email or phone number, in case of known user, and in case of anonymous user, this can be a randomly generated unique id.
        
        static let isAnonymous = true // This should be either true (in case of known-user) or false (in-case of anonymous user).
        
        static let isPanelView = false // This should be either true (in case of Show Panel) or false (in-case of Hide Panel).
    }
    
    // googleapi speech API_KEY
    struct speechConfig {
        static let API_KEY = "<speech_api_key>"
    }
}
