//
//  HTTPRequestManager.swift
//  KoreBotSDK
//
//  Created by developer@kore.com on 21/04/16.
//  Copyright © 2016 Kore Inc. All rights reserved.
//

import Foundation
import AFNetworking
import Mantle

open class HTTPRequestManager : NSObject {
    var options: AnyObject?
    static var instance: HTTPRequestManager!

    // MARK: request manager shared instance
    open static let sharedManager : HTTPRequestManager = {
        if (instance == nil) {
            instance = HTTPRequestManager()
        }
        return instance
    }()
    
    // MARK: requests
    open func signInWithToken(_ token: AnyObject!, botInfo: AnyObject!, success:((_ user: UserModel?, _ authInfo: AuthInfoModel?) -> Void)?, failure:((_ error: Error) -> Void)?)  {
        let urlString: String = Constants.URL.jwtAuthorizationUrl
        let requestSerializer = AFJSONRequestSerializer()
        requestSerializer.httpMethodsEncodingParametersInURI = Set.init(["GET"]) as Set<String>
        requestSerializer.setValue("Keep-Alive", forHTTPHeaderField:"Connection")
        let parameters: NSDictionary = ["assertion":token!, "botInfo": botInfo]

        let sessionManager: AFHTTPSessionManager = AFHTTPSessionManager(baseURL: URL.init(string: Constants.URL.baseUrl) as URL!)
        sessionManager.responseSerializer = AFJSONResponseSerializer.init()
        sessionManager.requestSerializer = requestSerializer
        sessionManager.post(urlString, parameters: parameters, progress: { (progress) in
            
        }, success: { (dataTask, responseObject) in
            print(responseObject)
            let error: Error?
            if responseObject is [AnyHashable: Any] {
                let dictionary = responseObject as! [String : AnyObject]
                let authorization: [AnyHashable: Any] = dictionary["authorization"] as! [AnyHashable: Any]
                let userInfo: [AnyHashable: Any] = dictionary["userInfo"] as! [AnyHashable: Any]
                let authInfo: AuthInfoModel = try! (MTLJSONAdapter.model(of: AuthInfoModel.self, fromJSONDictionary: authorization) as! AuthInfoModel)
                let user: UserModel = try! (MTLJSONAdapter.model(of: UserModel.self, fromJSONDictionary: userInfo) as! UserModel)
                success?(user, authInfo)
            } else {
                failure?(NSError(domain: "", code: 0, userInfo: [:]))
            }
        }) { (dataTask, error) in
            if (error != nil) {
                print(error)
            }
            failure?(error)
        }
    }
    
    open func getRtmUrlWithAuthInfoModel(_ authInfo: AuthInfoModel!, botInfo: AnyObject!, success:((_ botInfo: BotInfoModel?) -> Void)?, failure:((_ error: Error) -> Void)?)  {
        let urlString: String = Constants.URL.rtmUrl
        let requestSerializer = AFJSONRequestSerializer()
        requestSerializer.httpMethodsEncodingParametersInURI = Set.init(["GET"]) as Set<String>
        requestSerializer.setValue("Keep-Alive", forHTTPHeaderField:"Connection")
        
        let accessToken: String = String(format: "%@ %@", authInfo.tokenType!, authInfo.accessToken!)
        requestSerializer.setValue(accessToken, forHTTPHeaderField:"Authorization")

        let parameters: NSDictionary = ["botInfo": botInfo, "authorization": accessToken]
        let sessionManager: AFHTTPSessionManager = AFHTTPSessionManager(baseURL: URL.init(string: Constants.URL.baseUrl) as URL!)
        sessionManager.responseSerializer = AFJSONResponseSerializer.init()
        sessionManager.requestSerializer = requestSerializer
        sessionManager.post(urlString, parameters: parameters, progress: { (progress) in
            
        }, success: { (dataTask, responseObject) in
            print(responseObject)
            let error: NSError?
            let botInfo: BotInfoModel = try! (MTLJSONAdapter.model(of: BotInfoModel.self, fromJSONDictionary: responseObject! as! [AnyHashable: Any]) as! BotInfoModel)
            success?(botInfo)
        }) { (dataTask, error) in
            if (error != nil) {
                print(error)
            }
            failure?(error)
        }
    }
    
    // MARK: subscribe/ unsubscribte for
    open func subscribeToNotifications(_ deviceToken: Data!, userInfo: UserModel!, authInfo: AuthInfoModel!, success:((_ staus: Bool) -> Void)?, failure:((_ error: Error) -> Void)?) {
        let urlString: String = Constants.URL.subscribeUrl(userInfo.userId)
        let requestSerializer = AFJSONRequestSerializer()
        requestSerializer.httpMethodsEncodingParametersInURI = Set.init(["GET"]) as Set<String>
        requestSerializer.setValue("Keep-Alive", forHTTPHeaderField:"Connection")
        
        let accessToken: String = String(format: "%@ %@", authInfo.tokenType!, authInfo.accessToken!)
        requestSerializer.setValue(accessToken, forHTTPHeaderField:"Authorization")

        let deviceId: String! = deviceToken.hexadecimal()
        if (deviceId == nil) {
            failure?(NSError(domain: "KoreBotSDK", code: 0, userInfo: ["message": "deviceId is nil"]))
            return
        }
        let parameters: NSDictionary = ["deviceId": deviceId, "osType": "ios"]
        
        let sessionManager: AFHTTPSessionManager = AFHTTPSessionManager(baseURL: URL.init(string: Constants.URL.baseUrl) as URL!)
        sessionManager.responseSerializer = AFJSONResponseSerializer.init()
        sessionManager.requestSerializer = requestSerializer
        sessionManager.post(urlString, parameters: parameters, progress: { (progress) in
            
        }, success: { (dataTask, responseObject) in
            print(responseObject)
            success?(true)
        }) { (dataTask, error) in
            if (error != nil) {
                print(error)
            }
            failure?(error)
        }
    }
    
    open func unsubscribeToNotifications(_ deviceToken: Data!, userInfo: UserModel!, authInfo: AuthInfoModel!, success:((_ staus: Bool) -> Void)?, failure:((_ error: Error) -> Void)?) {
        let urlString: String = Constants.URL.unSubscribeUrl(userInfo.userId)
        let requestSerializer = AFJSONRequestSerializer()
        requestSerializer.httpMethodsEncodingParametersInURI = Set.init(["GET"]) as Set<String>
        requestSerializer.setValue("Keep-Alive", forHTTPHeaderField:"Connection")
        
        let accessToken: String = String(format: "%@ %@", authInfo.tokenType!, authInfo.accessToken!)
        requestSerializer.setValue(accessToken, forHTTPHeaderField:"Authorization")
        
        let deviceId: String! = deviceToken.hexadecimal()
        if (deviceId == nil) {
            failure?(NSError(domain: "KoreBotSDK", code: 0, userInfo: ["message": "deviceId is nil"]))
            return
        }
        
        let parameters: NSDictionary = ["deviceId": deviceId]
        
        let sessionManager: AFHTTPSessionManager = AFHTTPSessionManager(baseURL: URL.init(string: Constants.URL.baseUrl) as URL!)
        sessionManager.responseSerializer = AFJSONResponseSerializer.init()
        sessionManager.requestSerializer = requestSerializer
        sessionManager.delete(urlString, parameters: parameters, success: { (operation, responseObject) in
            success?(true)
        }) { (operation, error) in
            if (error != nil) {
                print(error)
            }
            failure?(error)
        }
    }
    
    open func startNewtorkMonitoring(_ block: ((AFNetworkReachabilityStatus) -> Void)?) {
        AFNetworkReachabilityManager.shared().setReachabilityStatusChange { (status) in
            if block != nil { block!(status) }
        }
        AFNetworkReachabilityManager.shared().startMonitoring()
    }
    
    open func stopNewtorkMonitoring() {
        AFNetworkReachabilityManager.shared().stopMonitoring()
    }
}

extension Data {
    func hexadecimal() -> String {
        return map { String(format: "%02x", $0) }
            .joined(separator: "")
    }
}
