//
//  ServerConfigs.swift
//  KoreBotSDKDemo
//
//  Created by Srinivas Vasadi on 10/25/14.
//  Copyright (c) 2014 Kore Inc. All rights reserved.
//

import UIKit
import Foundation

open class ServerConfigs: NSObject {
    open static let API_Version: String = "1.1"
    // NOTE: You must set your URL to generate JWT.
    open static let JWT_KORE_SERVER = String(format: "http://50.19.64.173:4000/")
    
//    open static let KORE_SERVER = String(format: "https://qa1-bots.kore.com/")
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
        return String(format: "%@api/users/sts", JWT_KORE_SERVER)
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
    
    // MARK: set access token
    open static func setAccessToken(_ token: String!) {
        let userDefauls: UserDefaults = UserDefaults.standard
        if (token != nil && token.characters.count > 0) {
            userDefauls.set(token, forKey: "TOKEN_FOR_AUTHORIZATION")
        } else {
            print("Please set valid token to interact with bots api")
        }
    }
    
    // MARK: set userId
    open static func setUserId(_ userId: String!) {
        let userDefauls: UserDefaults = UserDefaults.standard
        if (userId != nil && userId.characters.count > 0) {
            userDefauls.set(userId, forKey: "USER_ID")
        } else {
            print("Please set valid token to interact with bots api")
        }
    }
}

