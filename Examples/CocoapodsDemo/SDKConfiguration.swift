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
        static let clientId = "cs-3dd6a21c-70ef-5d52-b742-7b9dcf6a6a89"
        
        static let clientSecret = "Zf/sPAMUgD4Hl/y6nUELodw6DJu9cuzaytcAyqL5gO8="
        static let botId = "st-05303785-9992-526c-a83c-be3252fd478e"
        
        static let chatBotName = "CanCan"
        
        static let identity = "sainath.bhima@kore.com"
        
        static let isAnonymous = true
    }
    
    struct serverConfig {
        static let JWT_SERVER = String(format: "https://demo.kore.net/") // Replace it with the actual JWT server URL, if required. Refer to developer documentation for instructions on hosting JWT Server.
        
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
