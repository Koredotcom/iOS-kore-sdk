//
//  ServerConfigs.swift
//  KoreBotSDKDemo
//
//  Created by Srinivas Vasadi on 10/25/14.
//  Copyright (c) 2014 Kore Inc. All rights reserved.
//

import UIKit
import Foundation

public class ServerConfigs: NSObject {
    struct ServerAPIVersion {
        static let version: String = "1.1"
    }
    struct ServerConfig {
#if DEV_ENV
#if ENABLE_SSL
        static let KORE_SERVER = String(format: "https://devbots.kore.com/")
#else
        static let KORE_SERVER = String(format: "http://devbots.kore.com/")
#endif
#endif
    }
    static func getAllStreamsURL(userId: String!) -> String {
        return  String(format: "%@api/%@/users/%@/builder/streams", ServerConfig.KORE_SERVER, ServerAPIVersion.version, userId)
    }
}

public class Common : NSObject {
    public static func UIColorRGB(rgb: Int) -> UIColor {
        let blue = CGFloat(rgb & 0xFF)
        let green = CGFloat((rgb >> 8) & 0xFF)
        let red = CGFloat((rgb >> 16) & 0xFF)
        return UIColor(red: red / 255.0, green: green / 255.0, blue: blue / 255.0, alpha: 1)
    }
    
    public static func UIColorRGBA(rgb: Int, a: CGFloat) -> UIColor {
        let blue = CGFloat(rgb & 0xFF)
        let green = CGFloat((rgb >> 8) & 0xFF)
        let red = CGFloat((rgb >> 16) & 0xFF)
        return UIColor(red: red / 255.0, green: green / 255.0, blue: blue / 255.0, alpha: a)
    }
    
    // MARK: set access token
    public static func setAccessToken(token: String!) {
        let userDefauls: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        if (token != nil && token.characters.count > 0) {
            userDefauls.setObject(token, forKey: "TOKEN_FOR_AUTHORIZATION")
        } else {
            print("Please set valid token to interact with bots api")
        }
    }
    
    // MARK: set userId
    public static func setUserId(userId: String!) {
        let userDefauls: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        if (userId != nil && userId.characters.count > 0) {
            userDefauls.setObject(userId, forKey: "USER_ID")
        } else {
            print("Please set valid token to interact with bots api")
        }
    }
}

