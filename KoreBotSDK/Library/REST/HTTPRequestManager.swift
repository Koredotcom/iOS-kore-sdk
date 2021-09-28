//
//  HTTPRequestManager.swift
//  KoreBotSDK
//
//  Created by developer@kore.com on 21/04/16.
//  Copyright © 2016 Kore Inc. All rights reserved.
//

import Foundation
import Alamofire

open class HTTPRequestManager : NSObject {
    var options: AnyObject?
    static var instance: HTTPRequestManager!
    let sessionManager: Session = {
        let configuration = URLSessionConfiguration.af.default
        configuration.timeoutIntervalForRequest = 30
        return Session(configuration: configuration)
    }()
    
    // MARK: request manager shared instance
    public static let sharedManager = HTTPRequestManager()
    
    // MARK: requests
    open func signInWithToken(_ token: String, botInfo: [String: Any], success:((_ user: UserModel?, _ authInfo: AuthInfoModel?) -> Void)?, failure:((_ error: Error) -> Void)?)  {
        let urlString = Constants.URL.jwtAuthorizationUrl
        let parameters: [String: Any] = ["assertion": token, "botInfo": botInfo]
        
        let dataRequest = sessionManager.request(urlString, method: .post, parameters: parameters)
        dataRequest.validate().responseJSON { (response) in
            if let _ = response.error {
                let code = response.error?.responseCode ?? 0
                let error: NSError = NSError(domain: "", code: code, userInfo: [:])
                failure?(error)
                return
            }
            
            if let dictionary = response.value as? [String: Any] {
                let jsonDecoder = JSONDecoder()
                var user: UserModel?
                var authInfo: AuthInfoModel?
                
                if let userInfo = dictionary["userInfo"] as? [String: Any],
                   let data = try? JSONSerialization.data(withJSONObject: userInfo, options: .prettyPrinted) {
                    user = try? jsonDecoder.decode(UserModel.self, from: data)
                }
                
                if let authorization = dictionary["authorization"] as? [String: Any],
                   let data = try? JSONSerialization.data(withJSONObject: authorization, options: .prettyPrinted) {
                    authInfo = try? jsonDecoder.decode(AuthInfoModel.self, from: data)
                }
                success?(user, authInfo)
            } else {
                failure?(NSError(domain: "", code: 0, userInfo: [:]))
            }
        }
    }
    
    open func getRtmUrlWithAuthInfoModel(_ authInfo: AuthInfoModel, botInfo: [String: Any], success:((_ botInfo: BotInfoModel?) -> Void)?, failure:((_ error: Error) -> Void)?)  {
        let urlString: String = Constants.URL.rtmUrl
        let accessToken = String(format: "%@ %@", authInfo.tokenType ?? "", authInfo.accessToken ?? "")
        let headers: HTTPHeaders = [
            "Authorization": accessToken,
        ]
        
        let parameters: [String: Any] = ["botInfo": botInfo, "authorization": accessToken]
        let dataRequest = sessionManager.request(urlString, method: .post, parameters: parameters, headers: headers)
        dataRequest.validate().responseJSON { (response) in
            if let _ = response.error {
                let error: NSError = NSError(domain: "", code: 0, userInfo: [:])
                failure?(error)
                return
            }
            
            let jsonDecoder = JSONDecoder()
            if let dictionary = response.value as? [String: Any],
               let data = try? JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted) {
                let botInfo = try? jsonDecoder.decode(BotInfoModel.self, from: data)
                success?(botInfo)
            } else {
                failure?(NSError(domain: "", code: 0, userInfo: [:]))
            }
        }
    }
    
    // MARK: history from lastMessage
    open func getHistory(offset: Int, _ authInfo: AuthInfoModel, botInfo: [String: Any], success:((_ responseObject: [String: Any]?) -> Void)?, failure:((_ error: Error?) -> Void)?) {
        let urlString: String = Constants.URL.historyUrl
        let accessToken = String(format: "%@ %@", authInfo.tokenType ?? "", authInfo.accessToken ?? "")
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "Authorization": accessToken,
        ]
        
        var parameters = ["direction": "false", "limit": "20"]
        if let taskBotId = botInfo["taskBotId"] as? String {
            parameters["botId"] = taskBotId
        }
        let dataRequest = sessionManager.request(urlString, method: .get, parameters: parameters, headers: headers)
        dataRequest.validate().responseJSON { (response) in
            if let _ = response.error {
                let error: NSError = NSError(domain: "", code: 0, userInfo: [:])
                failure?(error)
                return
            }
            
            if let responseObject = response.value as? [String: Any] {
                success?(responseObject)
            } else {
                failure?(NSError(domain: "", code: 0, userInfo: [:]))
            }
        }
    }
    
    open func getMessages(after messageId: String, direction: Int, _ authInfo: AuthInfoModel, botInfo: [String: Any], success:((_ responseObject: [String: Any]?) -> Void)?, failure:((_ error: Error?) -> Void)?) {
        let urlString = Constants.URL.historyUrl
        let accessToken = String(format: "%@ %@", authInfo.tokenType ?? "", authInfo.accessToken ?? "")
        let headers: HTTPHeaders = [
            "Authorization": accessToken,
        ]
        
        let parameters = ["botId": botInfo["taskBotId"], "msgId": messageId, "direction": direction, "limit": "20"]
        let dataRequest = sessionManager.request(urlString, method: .get, parameters: parameters, headers: headers)
        dataRequest.validate().responseJSON { (response) in
            if let _ = response.error {
                let error: NSError = NSError(domain: "", code: 0, userInfo: [:])
                failure?(error)
                return
            }
            
            if let responseObject = response.value as? [String: Any] {
                success?(responseObject)
            } else {
                failure?(NSError(domain: "", code: 0, userInfo: [:]))
            }
        }
    }
    
    // MARK: subscribe/ unsubscribte for
    open func subscribeToNotifications(_ deviceToken: Data!, userInfo: UserModel!, authInfo: AuthInfoModel!, success:((_ staus: Bool) -> Void)?, failure:((_ error: Error) -> Void)?) {
        let urlString: String = Constants.URL.subscribeUrl(userInfo.userId)
        
        let accessToken = String(format: "%@ %@", authInfo.tokenType ?? "", authInfo.accessToken ?? "")
        let headers: HTTPHeaders = [
            "Authorization": accessToken,
        ]
        
        let deviceId = deviceToken.hexadecimal()
        if (deviceId == nil) {
            failure?(NSError(domain: "KoreBotSDK", code: 0, userInfo: ["message": "deviceId is nil"]))
            return
        }
        let parameters: [String: Any] = ["deviceId": deviceId, "osType": "ios"]
        
        let dataRequest = sessionManager.request(urlString, method: .post, parameters: parameters, headers: headers)
        dataRequest.validate().responseJSON { (response) in
            if let _ = response.error {
                let error: NSError = NSError(domain: "KoreBotSDK", code: 0, userInfo: [:])
                failure?(error)
                return
            }
            
            if let _ = response.value {
                success?(true)
            } else {
                failure?(NSError(domain: "KoreBotSDK", code: 0, userInfo: [:]))
            }
        }
    }
    
    open func unsubscribeToNotifications(_ deviceToken: Data!, userInfo: UserModel!, authInfo: AuthInfoModel!, success:((_ staus: Bool) -> Void)?, failure:((_ error: Error) -> Void)?) {
        let urlString: String = Constants.URL.unSubscribeUrl(userInfo.userId)
        
        let accessToken = String(format: "%@ %@", authInfo.tokenType ?? "", authInfo.accessToken ?? "")
        let headers: HTTPHeaders = [
            "Authorization": accessToken,
        ]
        
        let deviceId = deviceToken.hexadecimal()
        if (deviceId == nil) {
            failure?(NSError(domain: "KoreBotSDK", code: 0, userInfo: ["message": "deviceId is nil"]))
            return
        }
        
        let parameters: [String: Any] = ["deviceId": deviceId]
        
        let dataRequest = sessionManager.request(urlString, method: .delete, parameters: parameters, headers: headers)
        dataRequest.validate().responseJSON { (response) in
            if let _ = response.error {
                let error: NSError = NSError(domain: "KoreBotSDK", code: 0, userInfo: [:])
                failure?(error)
                return
            }
            
            if let _ = response.value {
                success?(true)
            } else {
                failure?(NSError(domain: "KoreBotSDK", code: 0, userInfo: [:]))
            }
        }
    }
}

extension Data {
    func hexadecimal() -> String {
        return map { String(format: "%02x", $0) }
            .joined(separator: "")
    }
}
