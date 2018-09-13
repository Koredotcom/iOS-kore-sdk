//
//  ServerConfigs.swift
//  KoreBotSDKDemo
//
//  Created by developer@kore.com on 10/25/14.
//  Copyright (c) 2014 Kore Inc. All rights reserved.
//

import UIKit
import Foundation

public var startSpeakingNotification = "StartSpeakingNowNotificationName"
public var stopSpeakingNotification = "StopSpeakingNowNotificationName"
public var showTableTemplateNotification = "ShowTableTemplateNotificationName"
public var reloadTableNotification = "reloadTableNotification"
public var updateUserImageNotification = "updateUserImageNotification"
public var isSpeakingEnabled = false

public func UIColorRGB(_ rgb: Int) -> UIColor {
    let blue = CGFloat(rgb & 0xFF)
    let green = CGFloat((rgb >> 8) & 0xFF)
    let red = CGFloat((rgb >> 16) & 0xFF)
    return UIColor(red: red / 255.0, green: green / 255.0, blue: blue / 255.0, alpha: 1)
}
    
public func UIColorRGBA(_ rgb: Int, a: CGFloat) -> UIColor {
    let blue = CGFloat(rgb & 0xFF)
    let green = CGFloat((rgb >> 8) & 0xFF)
    let red = CGFloat((rgb >> 16) & 0xFF)
    return UIColor(red: red / 255.0, green: green / 255.0, blue: blue / 255.0, alpha: a)
}

open class Utilities: NSObject {
    // MARK:-
    open static func stringFromJSONObject(object: Any) -> String? {
        var jsonString: String?
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: object, options: .prettyPrinted)
            jsonString = String(data: jsonData, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
        } catch {
            print(error.localizedDescription)
        }
        return jsonString
    }
    
    open static func jsonObjectFromString(jsonString: String) -> Any? {
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
    
    open static func getKREActionFromDictionary(dictionary: Dictionary<String, Any>) -> KREAction? {
        let actionInfo:Dictionary<String,Any> = dictionary
        let actionType: String = actionInfo["type"] != nil ? actionInfo["type"] as! String : ""
        let title: String = actionInfo["title"] != nil ? actionInfo["title"] as! String : ""
        if (actionType == "web_url") {
            let url: String = actionInfo["url"] != nil ? actionInfo["url"] as! String : ""
            return KREAction(type: .webURL, title: title, payload: url)
        } else if (actionType == "postback") {
            let payload: String = actionInfo["payload"] != nil ? actionInfo["payload"] as! String : ""
            return KREAction(type: .postback, title: title, payload: payload)
        }
        return nil
    }
}


