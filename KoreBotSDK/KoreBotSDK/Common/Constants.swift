//
//  Constants.swift
//  KoreBotSDK
//
//  Created by Srinivas Vasadi on 23/05/16.
//  Copyright © 2016 Kore. All rights reserved.
//

import UIKit

class Constants: NSObject {
    struct ServerConfigs {
        static let KORE_BOT_SERVER = String(format: "https://pilot-bots.kore.com/")
    }
    struct URL {
        static let baseUrl = "https://pilot-bots.kore.com/"
        static let jwtUrl = String(format: "%@api/users/sts", Constants.ServerConfigs.KORE_BOT_SERVER)
        static let jwtAuthorizationUrl = String(format: "%@api/oAuth/token/jwtgrant", Constants.ServerConfigs.KORE_BOT_SERVER)
        static let rtmUrl = String(format: "%@api/rtm/start", Constants.ServerConfigs.KORE_BOT_SERVER)
        static let signInUrl = String(format: "%@api/oAuth/token/jwtgrant/anonymous", Constants.ServerConfigs.KORE_BOT_SERVER)
        static func subscribeUrl(_ userId: String!) -> String {
            return  String(format: "%@api/users/%@/sdknotifications/subscribe", ServerConfigs.KORE_BOT_SERVER, userId)
        }
        static func unSubscribeUrl(_ userId: String!) -> String {
            return  String(format: "%@api/users/%@/sdknotifications/unsubscribe", ServerConfigs.KORE_BOT_SERVER, userId)
        }
    }
    
    open static func getUUID() -> String {
        let uuid = UUID().uuidString
        let date: Date = Date()
        return String(format: "%@-%.0f", uuid, date.timeIntervalSince1970)
    }
    
}
