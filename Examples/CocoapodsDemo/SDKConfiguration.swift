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
    
    //MARK:- MashreqBank
    struct botConfig {
        static let clientId = "cs-551aa988-e5e4-5867-942a-160eaadbf7fe" // Copy this value from Bot Builder SDK Settings ex. cs-5250bdc9-6bfe-5ece-92c9-ab54aa2d4285

        static let clientSecret = "NRqssEiKREdz2UehQ24RW2Z7u6He73ELV0ZtbWRMuJg=" // Copy this value from Bot Builder SDK Settings ex. Wibn3ULagYyq0J10LCndswYycHGLuIWbwHvTRSfLwhs=

        static let botId =  "st-d2a249e3-8373-516c-9173-4e7616658167" // Copy this value from Bot Builder -> Channels -> Web/Mobile Client  ex. st-acecd91f-b009-5f3f-9c15-7249186d827d

        static let chatBotName = "Mashreq Bank Assist Dev" // Copy this value from Bot Builder -> Channels -> Web/Mobile Client  ex. "Demo Bot"
        static let tenantId = "60363400393c980647f2c8a1"

        static let identity = "sainath.bhima@kore.com"//"sainath.bhima@kore.com"// This should represent the subject for JWT token. This can be an email or phone number, in case of known user, and in case of anonymous user, this can be a randomly generated unique id.

        static let isAnonymous = true // This should be either true (in case of known-user) or false (in-case of anonymous user).
    }
    
    struct serverConfig {
        static let JWT_SERVER = String(format: "https://demodpd.kore.ai/api/v1/") // Replace it with the actual JWT server URL, if required. Refer to developer documentation for instructions on hosting JWT Server.

        static func koreJwtUrl() -> String {
            return String(format: "%@users/sts", JWT_SERVER)
        }

        static var BOT_SERVER = String(format: "https://wb-bots.korebots.com/api")
        public static let KORE_SERVER = String(format: "https://bots.kore.ai/")
    }
    
   
    struct widgetConfig {
        static let clientId = "cs-5cd31fe5-cc44-5ab1-8b9c-104637d393fe" // Copy this value from Bot Builder SDK Settings ex. cs-5250bdc9-6bfe-5ece-92c9-ab54aa2d4285
        
        static let clientSecret = "LB2BtYsg4zWjZ6fprvRGhDG9ShX4TrkMNajiATImyIk=" // Copy this value from Bot Builder SDK Settings ex. Wibn3ULagYyq0J10LCndswYycHGLuIWbwHvTRSfLwhs=
        
        static let botId =  "st-3e4fb572-3e9b-57ae-abd2-13fa1799f947" // Copy this value from Bot Builder -> Channels -> Web/Mobile Client  ex. st-acecd91f-b009-5f3f-9c15-7249186d827d

        static let chatBotName = "IKEA Coworker" // Copy this value from Bot Builder -> Channels -> Web/Mobile Client  ex. "Demo Bot"
        
        static let identity = "subrahmanyam.donepudi@kore.com"// This should represent the subject for JWT token. This can be an email or phone number, in case of known user, and in case of anonymous user, this can be a randomly generated unique id.
        
        static let isAnonymous = true // This should be either true (in case of known-user) or false (in-case of anonymous user).
        
        static let isPanelView = false // This should be either true (in case of Show Panel) or false (in-case of Hide Panel).
    }
    
    // googleapi speech API_KEY
    struct speechConfig {
        static let API_KEY = "<speech_api_key>"
    }
}
