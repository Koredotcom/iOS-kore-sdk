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
//        static let clientId = "cs-154b0494-5814-5623-a209-4d7f81f648f4" // Copy this value from Bot Builder SDK Settings ex. cs-5250bdc9-6bfe-5ece-92c9-ab54aa2d4285
//
//        static let clientSecret = "SYGsaQnwelvpWaWn4YlhoRdWeLzJYMc1Qf/Fizt6IDg=" // Copy this value from Bot Builder SDK Settings ex. Wibn3ULagYyq0J10LCndswYycHGLuIWbwHvTRSfLwhs=
//
//        static let botId =  "st-2476eeca-1e5c-5854-90c3-fc5f31424f18" // Copy this value from Bot Builder -> Channels -> Web/Mobile Client  ex. st-acecd91f-b009-5f3f-9c15-7249186d827d
//
//        static let chatBotName = "Test_channel_publish" // Copy this value from Bot Builder -> Channels -> Web/Mobile Client  ex. "Demo Bot"
//
//        static let identity = "raj.peda@kore.com"// This should represent the subject for JWT token. This can be an email or phone number, in case of known user, and in case of anonymous user, this can be a randomly generated unique id.
//
//        static let isAnonymous = false // This should be either true (in case of known-user) or false (in-case of anonymous user).
//    }
    
//    struct botConfig {
//        static let clientId = "cs-99c4522b-d1ff-5cdf-b826-86459d8c835e" // Copy this value from Bot Builder SDK Settings ex. cs-5250bdc9-6bfe-5ece-92c9-ab54aa2d4285
//
//        static let clientSecret = "dTwkNeAtYB2zs7ZBlRrVLi76jQgwP4j9YBYInqkIUpw=" // Copy this value from Bot Builder SDK Settings ex. Wibn3ULagYyq0J10LCndswYycHGLuIWbwHvTRSfLwhs=
//
//        static let botId =  "st-afc6cf90-4d91-5fa5-aaf3-d7a65f372ae8" // Copy this value from Bot Builder -> Channels -> Web/Mobile Client  ex. st-acecd91f-b009-5f3f-9c15-7249186d827d
//
//        static let chatBotName = "testSDK1" // Copy this value from Bot Builder -> Channels -> Web/Mobile Client  ex. "Demo Bot"
//
//        static let identity = "raj.peda@kore.com"// This should represent the subject for JWT token. This can be an email or phone number, in case of known user, and in case of anonymous user, this can be a randomly generated unique id.
//
//        static let isAnonymous = false // This should be either true (in case of known-user) or false (in-case of anonymous user).
//    }
    
    struct botConfig {
        static var clientId = "cs-4d3a6498-acfd-5b35-b398-fe1d52b1b7fe" // Copy this value from Bot Builder SDK Settings ex. cs-5250bdc9-6bfe-5ece-92c9-ab54aa2d4285

        static var clientSecret = "98Toq/wxVUYnNKcuU1PIm8eq75+av18Dn+eha5NY8iU=" // Copy this value from Bot Builder SDK Settings ex. Wibn3ULagYyq0J10LCndswYycHGLuIWbwHvTRSfLwhs=

        static var botId =  "st-d5ffc5b4-eb1d-5c0f-aeac-438b4aff59ea" // Copy this value from Bot Builder -> Channels -> Web/Mobile Client  ex. st-acecd91f-b009-5f3f-9c15-7249186d827d

        static var chatBotName = "April 7" // Copy this value from Bot Builder -> Channels -> Web/Mobile Client  ex. "Demo Bot"

        static let identity = "kartheek.pagidimarri@kore.com"// This should represent the subject for JWT token. This can be an email or phone number, in case of known user, and in case of anonymous user, this can be a randomly generated unique id.

        static let isAnonymous = false // This should be either true (in case of known-user) or false (in-case of anonymous user).
    }
    

    
    struct serverConfig {
        static let JWT_SERVER = String(format: "https://mk2r2rmj21.execute-api.us-east-1.amazonaws.com/dev/") // Replace it with the actual JWT server URL, if required. Refer to developer documentation for instructions on hosting JWT Server.
        
        static func koreJwtUrl() -> String {
            return String(format: "%@users/sts", JWT_SERVER)
        }
        
        static let BOT_SERVER = String(format: "https://qa.findly.ai") //  "https://bots.kore.ai" "https://bankingassistant-stg.kore.ai" "https://bankingassistant-qa.kore.ai" "https://dev.findly.ai"
        public static let KORE_SERVER = String(format: "https://dev.findly.ai/")
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

