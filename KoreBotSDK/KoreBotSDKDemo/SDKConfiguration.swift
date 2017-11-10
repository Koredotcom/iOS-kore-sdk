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
        static let clientId = "cs-a6176814-90af-5741-a76c-9c43e6eccc54" // Copy this value from Bot Builder SDK Settings ex. cs-5250bdc9-6bfe-5ece-92c9-ab54aa2d4285
        
        static let clientSecret = "KvKYA29xd5XY7C7TK3wNgnE9CsUPJTMTNBlaxqUsb9Q=" // Copy this value from Bot Builder SDK Settings ex. Wibn3ULagYyq0J10LCndswYycHGLuIWbwHvTRSfLwhs=
        
        static let botId =  "st-eaf9ea82-b012-5284-b9a3-54ccf5597add" // Copy this value from Bot Builder -> Channels -> Web/Mobile Client  ex. st-acecd91f-b009-5f3f-9c15-7249186d827d

        static let chatBotName = "ME BOT" // Copy this value from Bot Builder -> Channels -> Web/Mobile Client  ex. "Demo Bot"
        
        static let identity = "joyce.gurramgadda@kore.com"// This should represent the subject for JWT token. This can be an email or phone number, in case of known user, and in case of anonymous user, this can be a randomly generated unique id.
        
        static let isAnonymous = true // This should be either true (in case of known-user) or false (in-case of anonymous user).
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
    
    open static let BOT_SERVER = String(format: "https://bots.kore.ai/")
    open static let BOT_SPEECH_SERVER = String(format: "https://qa-speech.kore.ai/")
}
