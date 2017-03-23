//
//  ServerConfigs.swift
//  KoreBotSDKDemo
//
//  Created by developer@kore.com on 10/25/14.
//  Copyright (c) 2014 Kore Inc. All rights reserved.
//

import UIKit
import Foundation

open class ServerConfigs: NSObject {
    open static let API_Version: String = "1.1"

    open static let KORE_SERVER = String(format: "pilot-bots.kore.com")
    
    open static func getAllStreamsURL(_ userId: String!) -> String {
        return  String(format: "%@api/%@/users/%@/builder/streams", KORE_SERVER, API_Version, userId)
    }
    open static func oAuthUrl() -> String {
        return String(format: "%@api/%@/oauth/token", KORE_SERVER, API_Version)
    }
    open static func jwtUrl() -> String {
        return String(format: "%@api/users/sts", KORE_SERVER)
    }
    open static func koreJwtUrl() -> String {
        return String(format: "http://50.19.64.173:4000/api/users/sts")
    }
}

open class Common : NSObject {
    open static func UIColorRGB(_ rgb: Int) -> UIColor {
        let blue = CGFloat(rgb & 0xFF)
        let green = CGFloat((rgb >> 8) & 0xFF)
        let red = CGFloat((rgb >> 16) & 0xFF)
        return UIColor(red: red / 255.0, green: green / 255.0, blue: blue / 255.0, alpha: 1)
    }
    
    open static func UIColorRGBA(_ rgb: Int, a: CGFloat) -> UIColor {
        let blue = CGFloat(rgb & 0xFF)
        let green = CGFloat((rgb >> 8) & 0xFF)
        let red = CGFloat((rgb >> 16) & 0xFF)
        return UIColor(red: red / 255.0, green: green / 255.0, blue: blue / 255.0, alpha: a)
    }
}

open class Utilities: NSObject {
    // MARK:-
    open static func stringFromJSONObject(object: Any) -> NSString {
        var jsonString: NSString!
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: object, options: .prettyPrinted)
            jsonString = NSString(data: jsonData, encoding: String.Encoding.ascii.rawValue)
        } catch {
            print(error.localizedDescription)
        }
        return jsonString
    }
    
    open static func jsonObjectFromString(jsonString: String) -> Any {
        var jsonObject: Any! = nil
        do {
            let data: Data = jsonString.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))! as Data
            jsonObject = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            return jsonObject!
        } catch {
            print(error.localizedDescription)
        }
        return jsonObject
    }
}
