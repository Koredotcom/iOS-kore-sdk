//
//  HTTPRequestManager.swift
//  KoreBotSDK
//
//  Created by developer@kore.com on 21/04/16.
//  Copyright © 2016 Kore Inc. All rights reserved.
//

import Foundation
import AFNetworking

open class HTTPRequestManager : NSObject {
    var options: AnyObject?
    static var instance: HTTPRequestManager!
    var sessionManager: AFHTTPSessionManager?
    
    // MARK: request manager shared instance
    public static let sharedManager : HTTPRequestManager = {
        if (instance == nil) {
            instance = HTTPRequestManager()
            instance.configureSessionManager()
        }
        return instance
    }()
    
    func configureSessionManager() {
        
        // Session Configuration
        let configuration = URLSessionConfiguration.default
        
        //Manager
        sessionManager = AFHTTPSessionManager.init(baseURL: URL.init(string: Constants.URL.baseUrl) as URL?, sessionConfiguration: configuration)
        
        // Request
        let requestSerializer = AFJSONRequestSerializer()
        requestSerializer.httpMethodsEncodingParametersInURI = Set.init(["GET"]) as Set<String>
        requestSerializer.setValue("Keep-Alive", forHTTPHeaderField:"Connection")
        requestSerializer.setValue("application/json", forHTTPHeaderField:"Content-Type")
        
        sessionManager?.requestSerializer = requestSerializer
        
        // Response
        sessionManager?.responseSerializer = AFJSONResponseSerializer.init()
    }
    
    // MARK: requests
    open func signInWithToken(_ token: String, botInfo: [String: Any], success:((_ user: UserModel?, _ authInfo: AuthInfoModel?) -> Void)?, failure:((_ error: Error) -> Void)?)  {
        //let urlString: String = Constants.URL.jwtAuthorizationUrl //kkkk
        //let parameters: NSDictionary = ["assertion": token, "botInfo": botInfo] //kkkk
        
        let urlString: String = Constants.WB_URL.jwtAuthorizationUrl
        let parameters: NSDictionary = botInfo as NSDictionary
        
        sessionManager?.post(urlString, parameters: parameters, headers: nil, progress: { (progress) in
            
        }, success: { (dataTask, responseObject) in
            if let dictionary = responseObject as? [String: Any] {
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
        }) { (dataTask, error) in
            failure?(error)
        }
    }
    
    open func getRtmUrlWithAuthInfoModel(_ authInfo: AuthInfoModel, botInfo: [String: Any], success:((_ botInfo: BotInfoModel?) -> Void)?, failure:((_ error: Error) -> Void)?)  {
        let urlString: String = Constants.URL.rtmUrl
        let accessToken: String = String(format: "%@ %@", authInfo.tokenType!, authInfo.accessToken!)
        sessionManager?.requestSerializer.setValue(accessToken, forHTTPHeaderField:"Authorization")
        
        let parameters: NSDictionary = ["botInfo": botInfo, "authorization": accessToken]
        
        sessionManager?.post(urlString, parameters: parameters, headers: nil, progress: { (progress) in
            
        }, success: { (dataTask, responseObject) in
            let jsonDecoder = JSONDecoder()
            if let dictionary = responseObject as? [String: Any],
                let data = try? JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted) {
                let botInfo = try? jsonDecoder.decode(BotInfoModel.self, from: data)
                success?(botInfo)
            } else {
                failure?(NSError(domain: "", code: 0, userInfo: [:]))
            }
        }) { (dataTask, error) in
            failure?(error)
        }
    }
    
    // MARK: history from lastMessage
    open func getHistory(offset: Int, _ authInfo: AuthInfoModel, botInfo: [String: Any], success:((_ responseObject: [String: Any]?) -> Void)?, failure:((_ error: Error?) -> Void)?) {
        let urlString: String = Constants.URL.historyUrl
        if let tokenType = authInfo.tokenType, let accessToken = authInfo.accessToken {
            let token = String(format: "%@ %@", tokenType, accessToken)
            sessionManager?.requestSerializer.setValue(token, forHTTPHeaderField: "Authorization")
        }
        
        let parameters = ["botId": botInfo["taskBotId"], "direction": "false", "limit": "20"]
        sessionManager?.get(urlString, parameters: parameters, headers: nil, progress: { (progress) in
            
        }, success: { (dataTask, responseObject) in
            if let responseObject = responseObject as? [String: Any] {
                success?(responseObject)
            } else {
                failure?(NSError(domain: "", code: 0, userInfo: [:]))
            }
        }) { (dataTask, error) in
            failure?(error)
        }
    }
    
    open func getMessages(after messageId: String, direction: Int, _ authInfo: AuthInfoModel, botInfo: [String: Any], success:((_ responseObject: [String: Any]?) -> Void)?, failure:((_ error: Error?) -> Void)?) {
        let urlString: String = Constants.URL.historyUrl
        if let tokenType = authInfo.tokenType, let accessToken = authInfo.accessToken {
            let token = String(format: "%@ %@", tokenType, accessToken)
            sessionManager?.requestSerializer.setValue(token, forHTTPHeaderField: "Authorization")
        }

        //let parameters = ["botId": botInfo["taskBotId"], "msgId": messageId, "direction": direction, "limit": "20"]
        let parameters = ["botId": botInfo["taskBotId"], "limit": "20"]
        sessionManager?.get(urlString, parameters: parameters, headers: nil, progress: { (progress) in
            
        }, success: { (dataTask, responseObject) in
            if (responseObject is [String: Any]) {
                success?(responseObject as? [String : Any])
            } else {
                failure?(NSError(domain: "", code: 0, userInfo: [:]))
            }
        }) { (dataTask, error) in
            failure?(error)
        }
    }

    // MARK: subscribe/ unsubscribte for
    open func subscribeToNotifications(_ deviceToken: Data!, userInfo: UserModel!, authInfo: AuthInfoModel!, success:((_ staus: Bool) -> Void)?, failure:((_ error: Error) -> Void)?) {
        let urlString: String = Constants.URL.subscribeUrl(userInfo.userId)
        
        let accessToken: String = String(format: "%@ %@", authInfo.tokenType!, authInfo.accessToken!)
        sessionManager?.requestSerializer.setValue(accessToken, forHTTPHeaderField:"Authorization")
        
        let deviceId: String! = deviceToken.hexadecimal()
        if (deviceId == nil) {
            failure?(NSError(domain: "KoreBotSDK", code: 0, userInfo: ["message": "deviceId is nil"]))
            return
        }
        let parameters: NSDictionary = ["deviceId": deviceId, "osType": "ios"]
        
        sessionManager?.post(urlString, parameters: parameters, headers: nil, progress: { (progress) in
            
        }, success: { (dataTask, responseObject) in
            success?(true)
        }) { (dataTask, error) in
            failure?(error)
        }
    }
    
    open func unsubscribeToNotifications(_ deviceToken: Data!, userInfo: UserModel!, authInfo: AuthInfoModel!, success:((_ staus: Bool) -> Void)?, failure:((_ error: Error) -> Void)?) {
        let urlString: String = Constants.URL.unSubscribeUrl(userInfo.userId)
        
        let accessToken: String = String(format: "%@ %@", authInfo.tokenType!, authInfo.accessToken!)
        sessionManager?.requestSerializer.setValue(accessToken, forHTTPHeaderField:"Authorization")
        
        let deviceId: String! = deviceToken.hexadecimal()
        if (deviceId == nil) {
            failure?(NSError(domain: "KoreBotSDK", code: 0, userInfo: ["message": "deviceId is nil"]))
            return
        }
        
        let parameters: NSDictionary = ["deviceId": deviceId]
        
        sessionManager?.delete(urlString, parameters: parameters, headers: nil, success: { (operation, responseObject) in
            success?(true)
        }) { (operation, error) in
            failure?(error)
        }
    }
}

extension Data {
    func hexadecimal() -> String {
        return map { String(format: "%02x", $0) }
            .joined(separator: "")
    }
}
