//
//  ServerConfigs.swift
//  KoreBotSDKDemo
//
//  Created by developer@kore.com on 10/25/14.
//  Copyright (c) 2014 Kore Inc. All rights reserved.
//

import UIKit
import Foundation
import KoreBotSDK

var startSpeakingNotification = "StartSpeakingNowNotificationName"
var stopSpeakingNotification = "StopSpeakingNowNotificationName"
var showTableTemplateNotification = "ShowTableTemplateNotificationName"
var reloadTableNotification = "reloadTableNotification"
var updateUserImageNotification = "updateUserImageNotification"
var showListViewTemplateNotification = "ListViewTemplateNotificationName"
var showListWidgetViewTemplateNotification = "ListWidgetViewTemplateNotificationName"
var showLiveSearchTemplateNotification = "LiveSearchViewTemplateNotificationName"


var isSpeakingEnabled = false
var selectedTheme = "Theme 1"
var themeColorUserDefaults = "ThemeColor"
let FindlyUrl = "https://qa.findly.ai//"//"https://pilot.findly.ai/" //"https://app.findly.ai/" 
var findlySidx = "sidx-24471eaf-88c7-5789-9cfc-4a17e7e94a9e" //"sidx-29f25be6-a8af-5f2b-8ca3-80b0601d458a"
var findlyUserId = "4bbe86a4-dfdc-429d-98de-253f5248a322"//"03B41D62-FB69-5B6D-A95E-473842F4DFE3"
var userInfoUserId: String?
var authInfoAccessToken: String?
let findlyStreamId = SDKConfiguration.botConfig.botId //"st-a4a4fabe-11d3-56cc-801d-894ddcd26c51"
let recentSearchArray = NSMutableArray()

//var isAutoSendMessage = false
var isAutoSendMessage:String?
var isShowLoginView = false
var isLogin = false
var isEndOfTask = true

let userColor: UIColor = UIColor(red: 38 / 255.0, green: 52 / 255.0, blue: 74 / 255.0, alpha: 1)
let botColor: UIColor = UIColor(red: 237 / 255.0, green: 238 / 255.0, blue: 241 / 255.0, alpha: 1)

var themeColor: UIColor = UIColor.init(hexString: "#2881DF")  // 149C3F
var headerTitle = ""
var backgroudImage = ""
var leftImage = ""
var dynamicIdentity:String?

open class Common : NSObject {
    public static func UIColorRGB(_ rgb: Int) -> UIColor {
        let blue = CGFloat(rgb & 0xFF)
        let green = CGFloat((rgb >> 8) & 0xFF)
        let red = CGFloat((rgb >> 16) & 0xFF)
        return UIColor(red: red / 255.0, green: green / 255.0, blue: blue / 255.0, alpha: 1)
    }
    
    public static func UIColorRGBA(_ rgb: Int, a: CGFloat) -> UIColor {
        let blue = CGFloat(rgb & 0xFF)
        let green = CGFloat((rgb >> 8) & 0xFF)
        let red = CGFloat((rgb >> 16) & 0xFF)
        return UIColor(red: red / 255.0, green: green / 255.0, blue: blue / 255.0, alpha: a)
    }
}

open class Utilities: NSObject {
    // MARK:-
    public static func stringFromJSONObject(object: Any) -> String? {
        var jsonString: String? = nil
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: object, options: .prettyPrinted)
            jsonString = String(data: jsonData, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
        } catch {
            print(error.localizedDescription)
        }
        return jsonString
    }
    
    public static func jsonObjectFromString(jsonString: String) -> Any? {
        var jsonObject: Any?
        do {
            let data: Data = jsonString.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))! as Data
            jsonObject = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            return jsonObject!
        } catch {
            print(error.localizedDescription)
        }
        return jsonObject
    }
    
    public static func getKREActionFromDictionary(dictionary: Dictionary<String, Any>) -> KREAction? {
        let actionInfo:Dictionary<String,Any> = dictionary
        let actionType: String = actionInfo["type"] != nil ? actionInfo["type"] as! String : ""
        let title: String = actionInfo["title"] != nil ? actionInfo["title"] as! String : ""
        switch (actionType.lowercased()) {
        case "web_url", "iframe_web_url", "url":
            let url: String = actionInfo["url"] != nil ? actionInfo["url"] as! String : ""
            return KREAction(actionType: .webURL, title: title, payload: url)
        case "postback":
            let payload: String = (actionInfo["payload"] != nil ? actionInfo["payload"] as? String : "") ?? String(actionInfo["payload"] as! Int) //kk
            return KREAction(actionType: .postback, title: title, payload: payload)
        case "postback_disp_payload":
            let payload: String = actionInfo["payload"] != nil ? actionInfo["payload"] as! String : ""
            return KREAction(actionType: .postback_disp_payload, title: payload, payload: payload)
        default:
            break
        }
        return nil
    }
}
