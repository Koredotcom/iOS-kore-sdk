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
        static let clientId = " cs-3a8af47c-6212-5996-bc6f-a0841ea42ddc" // Copy this value from Bot Builder SDK Settings ex. cs-5250bdc9-6bfe-5ece-92c9-ab54aa2d4285
        
        static let clientSecret = " Aj70H/QfsOgh2Q9Gdu+BZ5sFuyiMlibEXx33L4I/VjI=" // Copy this value from Bot Builder SDK Settings ex. Wibn3ULagYyq0J10LCndswYycHGLuIWbwHvTRSfLwhs=
        
        static let botId =  "st-1d3dd297-47b1-572c-bc49-a848fcccfbfe" // Copy this value from Bot Builder -> Channels -> Web/Mobile Client  ex. st-acecd91f-b009-5f3f-9c15-7249186d827d
        
        static let chatBotName = "Sample templates" // Copy this value from Bot Builder -> Channels -> Web/Mobile Client  ex. "Demo Bot"
        
        static let identity = "subrahmanyam.donepudi@kore.com"// This should represent the subject for JWT token. This can be an email or phone number, in case of known user, and in case of anonymous user, this can be a randomly generated unique id.
        
        static let isAnonymous = true // This should be either true (in case of known-user) or false (in-case of anonymous user).
    }
    
    struct serverConfig {
//        static let JWT_SERVER = String(format: "https://fbintegration.kore.com/jwtservice/api/") // Replace it with the actual JWT server URL, if required. Refer to developer documentation for instructions on hosting JWT Server.http://demo.kore.net:3000/
        static let JWT_SERVER = String(format: "https://demo.kore.net:3000/")
        static func koreJwtUrl() -> String {
            return String(format: "%@users/sts", JWT_SERVER)
        }
        
        static let BOT_SERVER = String(format: "https://qa1-bots.kore.ai/api/")
    }
    
    // googleapi speech API_KEY
    struct speechConfig {
        static let API_KEY = "AIzaSyCagwsHmUxecD-ZR6OJoL_YAvRBFIXFArQ"
    }
}


