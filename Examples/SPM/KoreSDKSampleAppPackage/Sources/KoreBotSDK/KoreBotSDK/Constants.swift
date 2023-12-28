//
//  Constants.swift
//  KoreBotSDK
//
//  Created by developer@kore.com on 23/05/16.
//  Copyright © 2016 Kore Inc. All rights reserved.
//

import UIKit

open class Constants: NSObject {
    public static var KORE_BOT_SERVER = String(format: "https://pilot-bots.kore.com")
    struct URL {
        static let baseUrl = KORE_BOT_SERVER
        static let jwtAuthorizationUrl = String(format: "%@/api/oAuth/token/jwtgrant", KORE_BOT_SERVER)
        static let rtmUrl = String(format: "%@/api/rtm/start", KORE_BOT_SERVER)
        static let historyUrl = String(format: "%@/api/botmessages/rtm", KORE_BOT_SERVER)
        static func subscribeUrl(_ userId: String!) -> String {
            return  String(format: "%@/api/users/%@/sdknotifications/subscribe", KORE_BOT_SERVER, userId)
        }
        static func unSubscribeUrl(_ userId: String!) -> String {
            return  String(format: "%@/api/users/%@/sdknotifications/unsubscribe", KORE_BOT_SERVER, userId)
        }
    }
    
    public static var WB_BOT_SERVER = String(format: "https://pilot-bots.kore.com")
    struct WB_URL {
           static let baseUrl = WB_BOT_SERVER
           static let jwtAuthorizationUrl = String(format: "%@/oAuth/token/jwtgrant", WB_BOT_SERVER)
       }
    
    public static func getUUID() -> String {
        let uuid = UUID().uuidString
        let date: Date = Date()
        return String(format: "%@-%.0f", uuid, date.timeIntervalSince1970)
    }
}

public enum KREMessageAction: String {
    case startSpeaking = "StartSpeakingNowNotificationName"
    case stopSpeaking = "StopSpeakingNowNotificationName"
    case utteranceHandler = "utteranceHandler"
    case navigateToComposeBar = "navigateToComposeBar"
    case validateAgainstSkill = "ValidateAgainstSkill"
    case keyboardWillShow = "keyboardWillShow"
    case keyboardWillHide = "keyboardWillHide"
    case keyboardDidShow = "keyboardDidShow"
    case keyboardDidHide = "keyboardDidHide"

    public var notification: Notification.Name {
        switch self {
        case .startSpeaking:
            return Notification.Name(rawValue: KREMessageAction.startSpeaking.rawValue)
        case .stopSpeaking:
            return Notification.Name(rawValue: KREMessageAction.stopSpeaking.rawValue)
        case .utteranceHandler:
            return Notification.Name(rawValue: KREMessageAction.utteranceHandler.rawValue)
        case .navigateToComposeBar:
            return Notification.Name(rawValue: KREMessageAction.navigateToComposeBar.rawValue)
        case .validateAgainstSkill:
            return Notification.Name(rawValue: KREMessageAction.validateAgainstSkill.rawValue)
        case .keyboardWillShow:
            return Notification.Name(rawValue: KREMessageAction.keyboardWillShow.rawValue)
        case .keyboardWillHide:
            return Notification.Name(rawValue: KREMessageAction.keyboardWillHide.rawValue)
        case .keyboardDidShow:
            return Notification.Name(rawValue: KREMessageAction.keyboardDidShow.rawValue)
        case .keyboardDidHide:
            return Notification.Name(rawValue: KREMessageAction.keyboardDidHide.rawValue)
        }
    }
}
