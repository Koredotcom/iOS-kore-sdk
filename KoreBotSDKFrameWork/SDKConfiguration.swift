//
//  SDKConfiguration.swift
//  KoreBotSDKDemo
//
//  Created by developer@kore.com on 12/16/16.
//  Copyright © 2016 Kore Inc. All rights reserved.
//

import UIKit
import KoreBotSDK

public class SDKConfiguration: NSObject {
    
    struct dataStoreConfig {
        static let resetDataStoreOnConnect = true // This should be either true or false. Conversation with the bot will be persisted, if it is false.
    }

    //MARK:- MashreqBank
   public struct botConfig {
       public static var clientId = "cs-8cad0d10-79d6-56d4-9f9c-1a4325b64dbe" // Copy this value from Bot Builder SDK Settings ex. cs-5250bdc9-6bfe-5ece-92c9-ab54aa2d4285

       public static var clientSecret = "DBS1E8mzBdVy9QYA1aUe9RfDgCHZtwegLD+txU7xlEs=" // Copy this value from Bot Builder SDK Settings ex. Wibn3ULagYyq0J10LCndswYycHGLuIWbwHvTRSfLwhs=

       public static var botId =  "st-b1ed5f83-a15a-54fa-8611-02610e497b4e" // Copy this value from Bot Builder -> Channels -> Web/Mobile Client  ex. st-acecd91f-b009-5f3f-9c15-7249186d827d

       public static var chatBotName = "Mashreq Bank Assist Dev" // Copy this value from Bot Builder -> Channels -> Web/Mobile Client  ex. "Demo Bot"
       public static var tenantId = "6040d03a7db76200b8e16a97"

       public static var identity = "sainath.bhima@kore.com"//"sainath.bhima@kore.com"// This should represent the subject for JWT token. This can be an email or phone number, in case of known user, and in case of anonymous user, this can be a randomly generated unique id.

       public static let isAnonymous = true // This should be either true (in case of known-user) or false (in-case of anonymous user).
    }
    
   
   public struct serverConfig {
       public static let JWT_SERVER = String(format: "https://demodpd.kore.ai/api/v1/") // Replace it with the actual JWT server URL, if required. Refer to developer documentation for instructions on hosting JWT Server.

       public static func koreJwtUrl() -> String {
            return String(format: "%@users/sts", JWT_SERVER)
        }

      public  static var BOT_SERVER = String(format: "https://wb-bots.korebots.com/api")
      public  static var JWT_NewSERVER = String(format: "https://demodpd.kore.ai/api")
      public  static var Branding_SERVER = String(format: "https://wb.korebots.com")
    
      public static let KORE_SERVER = String(format: "https://bots.kore.ai/")
    }
   
    struct widgetConfig {
        static let clientId = "<client-id>" // Copy this value from Bot Builder SDK Settings ex. cs-5250bdc9-6bfe-5ece-92c9-ab54aa2d4285
        
        static let clientSecret = "<client-secret>" // Copy this value from Bot Builder SDK Settings ex. Wibn3ULagYyq0J10LCndswYycHGLuIWbwHvTRSfLwhs=
        
        static let botId =  "<bot-id>" // Copy this value from Bot Builder -> Channels -> Web/Mobile Client  ex. st-acecd91f-b009-5f3f-9c15-7249186d827d

        static let chatBotName = "<bot-name>" // Copy this value from Bot Builder -> Channels -> Web/Mobile Client  ex. "Demo Bot"
        
        static let identity = "<identity-email> or <random-id>"// This should represent the subject for JWT token. This can be an email or phone number, in case of known user, and in case of anonymous user, this can be a randomly generated unique id.
        
        static let isAnonymous = true // This should be either true (in case of known-user) or false (in-case of anonymous user).
        
        static let isPanelView = false // This should be either true (in case of Show Panel) or false (in-case of Hide Panel).
    }
    
    // googleapi speech API_KEY
    struct speechConfig {
        static let API_KEY = "<speech_api_key>"
    }
}
