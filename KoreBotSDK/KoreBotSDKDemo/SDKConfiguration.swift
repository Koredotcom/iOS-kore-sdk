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
    struct botConfig {
        static let clientId = "cs-efbb5584-cce6-52e7-b8ed-52ed6dba64f1" // Copy this value from Bot Builder SDK Settings ex. cs-5250bdc9-6bfe-5ece-92c9-ab54aa2d4285
        
        static let clientSecret = "pWRI/AWybyd4ZzYEdyplORKKrU/CmZjySlwPv3jKUJ4=" // Copy this value from Bot Builder SDK Settings ex. Wibn3ULagYyq0J10LCndswYycHGLuIWbwHvTRSfLwhs=
        
        static let botId =  "st-d45e59c9-6753-5cba-8e29-d796b70ee63b" // Copy this value from Bot Builder -> Channels -> Web/Mobile Client  ex. st-acecd91f-b009-5f3f-9c15-7249186d827d

        static let chatBotName = "Barry Pilot" // Copy this value from Bot Builder -> Channels -> Web/Mobile Client  ex. "Demo Bot"
        
        static let identity = "girish.ahankari@kore.com"// This should represent the subject for JWT token. This can be an email or phone number, in case of known user, and in case of anonymous user, this can be a randomly generated unique id.
        
        static let isAnonymous = false // This should be either true (in case of known-user) or false (in-case of anonymous user).
    }
    
    struct dataStoreConfig {
        static let resetDataStoreOnConnect = true // This should be either true or false. Conversation with the bot will be persisted, if it is false.
    }
}

class ServerConfigs: NSObject {
    open static let JWT_SERVER = String(format: "http://demo.kore.net:3000/") // Replace it with the actual JWT server URL, if required. Refer to developer documentation for instructions on hosting JWT Server.
    
    open static func koreJwtUrl() -> String {
        return String(format: "%@users/sts", JWT_SERVER)
    }
    
    open static let BOT_SERVER = String(format: "https://pilot-bots.kore.ai/")
    open static let BOT_SPEECH_SERVER = String(format: "https://qa-speech.kore.ai/")
}
