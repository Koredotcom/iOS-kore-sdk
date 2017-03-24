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
        static let clientId = "<client-id>" // Copy this value from Bot Builder SDK Settings ex. cs-5250bdc9-6bfe-5ece-92c9-ab54aa2d4285
        
        static let clientSecret = "<client-secret>" // Copy this value from Bot Builder SDK Settings ex. Wibn3ULagYyq0J10LCndswYycHGLuIWbwHvTRSfLwhs=
        
        static let botId =  "<bot-identifier>" // Copy this value from Bot Builder -> Channels -> Web/Mobile Client  ex. st-acecd91f-b009-5f3f-9c15-7249186d827d

        static let chatBotName = "<bot-name>" // Copy this value from Bot Builder -> Channels -> Web/Mobile Client  ex. "Demo Bot"
        
        static let identity = "<identity-email> or <random-id>"// This should represent the subject for JWT token. This can be an email or phone number, in case of known user, and in case of anonymous user, this can be a randomly generated unique id.
        
        static let isAnonymous = false // This should be either true (in case of known-user) or false (in-case of anonymous user).
    }
}

class ServerConfigs: NSObject {
    open static let JWT_SERVER = String(format: "http://50.19.64.173:4000/") // Replace it with your on-premise server URL, if required.
    
    open static func koreJwtUrl() -> String {
        return String(format: "%@api/users/sts", JWT_SERVER)
    }
    
    open static let BOT_SERVER = String(format: "https://pilot-bots.kore.com/")
    open static let BOT_SPEECH_SERVER = String(format: "wss://speech.kore.ai/speechcntxt/verizon")
}
