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
        static let clientId = "Philips onboarding bot" // Copy this value from Bot Builder SDK Settings ex. cs-5250bdc9-6bfe-5ece-92c9-ab54aa2d4285
        
        static let clientSecret = "cs-d6cafc92-7fd9-5600-bdeb-19db57f84dd8" // Copy this value from Bot Builder SDK Settings ex. Wibn3ULagYyq0J10LCndswYycHGLuIWbwHvTRSfLwhs=
        
        static let botId =  "st-35169f26-3297-51c3-9656-63c93d9f1e6e" // Copy this value from Bot Builder -> Channels -> Web/Mobile Client  ex. st-acecd91f-b009-5f3f-9c15-7249186d827d

        static let chatBotName = "1TLPeYW6A0idwkUs+qeeCgsXQN8DSBJeK7heH+HzcFg=" // Copy this value from Bot Builder -> Channels -> Web/Mobile Client  ex. "Demo Bot"
        
        static let identity = "harinder.bommakanti@kore.com"// This should represent the subject for JWT token. This can be an email or phone number, in case of known user, and in case of anonymous user, this can be a randomly generated unique id.
        
        static let isAnonymous = true // This should be either true (in case of known-user) or false (in-case of anonymous user).
    }
    
    struct serverConfig {
        static let JWT_SERVER = String(format: "http://<jwt-server-host>/") // Replace it with the actual JWT server URL, if required. Refer to developer documentation for instructions on hosting JWT Server.
        
        static func koreJwtUrl() -> String {
            return String(format: "%@users/sts", JWT_SERVER)
        }
        
        static let BOT_SERVER = String(format: "https://bots.kore.ai/")
    }
    
    // googleapi speech API_KEY
    struct speechConfig {
        static let API_KEY = "<speech_api_key>"
    }
}
