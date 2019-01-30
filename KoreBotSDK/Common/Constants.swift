//
//  Constants.swift
//  KoreBotSDK
//
//  Created by developer@kore.com on 23/05/16.
//  Copyright © 2016 Kore Inc. All rights reserved.
//

import UIKit

open class Constants: NSObject {
    open static var KORE_BOT_SERVER = String(format: "https://pilot-bots.kore.com/")
    struct URL {
        static let baseUrl = KORE_BOT_SERVER
        
        static let jwtAuthorizationUrl = String(format: "%@api/1.1/oAuth/token/jwtgrant", KORE_BOT_SERVER)
        static let rtmUrl = String(format: "%@api/rtm/start", KORE_BOT_SERVER)
        static func subscribeUrl(_ userId: String!) -> String {
            return  String(format: "%@api/users/%@/sdknotifications/subscribe", KORE_BOT_SERVER, userId)
        }
        static func unSubscribeUrl(_ userId: String!) -> String {
            return  String(format: "%@api/users/%@/sdknotifications/unsubscribe", KORE_BOT_SERVER, userId)
        }
    }
    
    open static func getUUID() -> String {
        let uuid = UUID().uuidString
        let date: Date = Date()
        return String(format: "%@-%.0f", uuid, date.timeIntervalSince1970)
    }
    
}
