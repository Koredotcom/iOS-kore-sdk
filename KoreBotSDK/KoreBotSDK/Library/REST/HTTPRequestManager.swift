//
//  HTTPRequestManager.swift
//  KoreBotSDK
//
//  Created by Srinivas Vasadi on 21/04/16.
//  Copyright © 2016 Kore. All rights reserved.
//

import Foundation
import AFNetworking
import Mantle

public class HTTPRequestManager : NSObject {
    var options: AnyObject?
    static var instance: HTTPRequestManager!

    // MARK: request manager shared instance
    public static let sharedManager : HTTPRequestManager = {
        if (instance == nil) {
            instance = HTTPRequestManager()
        }
        return instance
    }()
    
    // MARK: requests
    public func authorizeWithToken(accessToken: String!, botInfo: AnyObject!, success:((token: String!) -> Void)?, failure:((error: NSError) -> Void)?) {
        let urlString: String = Constants.URL.jwtUrl
        let requestSerializer = AFJSONRequestSerializer()
        requestSerializer.HTTPMethodsEncodingParametersInURI = Set.init(["GET"]) as Set<String>
        requestSerializer.setValue("Keep-Alive", forHTTPHeaderField:"Connection")        
        requestSerializer.setValue(accessToken, forHTTPHeaderField:"Authorization")
        let parameters: NSDictionary = ["botInfo": botInfo]

        let operationManager: AFHTTPRequestOperationManager = AFHTTPRequestOperationManager.init(baseURL: NSURL.init(string: Constants.URL.baseUrl))
        operationManager.responseSerializer = AFJSONResponseSerializer.init()
        operationManager.requestSerializer = requestSerializer
        operationManager.POST(urlString, parameters: parameters, success: { (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) in
            let error: NSError?
            let jwt: JwtModel = try! (MTLJSONAdapter.modelOfClass(JwtModel.self, fromJSONDictionary: responseObject! as! [NSObject : AnyObject]) as! JwtModel)
            
            success?(token: jwt.jwtToken)

        }) { (operation: AFHTTPRequestOperation!, error: NSError!) in
            failure?(error: error)
        }
    }
    
    public func signInWithToken(token: AnyObject!, botInfo: AnyObject!, success:((user: UserModel!, authInfo: AuthInfoModel!) -> Void)?, failure:((error: NSError) -> Void)?)  {
        let urlString: String = Constants.URL.jwtAuthorizationUrl
        let requestSerializer = AFJSONRequestSerializer()
        requestSerializer.HTTPMethodsEncodingParametersInURI = Set.init(["GET"]) as Set<String>
        requestSerializer.setValue("Keep-Alive", forHTTPHeaderField:"Connection")
        let parameters: NSDictionary = ["assertion":token!, "botInfo": botInfo]

        let operationManager: AFHTTPRequestOperationManager = AFHTTPRequestOperationManager.init(baseURL: NSURL.init(string: Constants.URL.baseUrl))
        operationManager.responseSerializer = AFJSONResponseSerializer.init()
        operationManager.requestSerializer = requestSerializer
        operationManager.POST(urlString, parameters: parameters, success: { (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) in
            let error: NSError?
            let authInfo: AuthInfoModel = try! (MTLJSONAdapter.modelOfClass(AuthInfoModel.self, fromJSONDictionary: responseObject["authorization"]! as! [NSObject : AnyObject]) as! AuthInfoModel)
            let user: UserModel = try! (MTLJSONAdapter.modelOfClass(UserModel.self, fromJSONDictionary: responseObject["userInfo"]! as! [NSObject : AnyObject]) as! UserModel)
            
            success?(user: user, authInfo: authInfo)
            print(operation.responseObject)
        }) { (operation: AFHTTPRequestOperation!, error: NSError!) in
            if (operation.responseObject != nil) {
                print(operation.responseObject)
            }
            failure?(error: error)
        }
    }
    
    public func getRtmUrlWithAuthInfoModel(authInfo: AuthInfoModel!, botInfo: AnyObject!, success:((botInfo: BotInfoModel!) -> Void)?, failure:((error: NSError) -> Void)?)  {
        let urlString: String = Constants.URL.rtmUrl
        let requestSerializer = AFJSONRequestSerializer()
        requestSerializer.HTTPMethodsEncodingParametersInURI = Set.init(["GET"]) as Set<String>
        requestSerializer.setValue("Keep-Alive", forHTTPHeaderField:"Connection")
        
        let accessToken: String = String(format: "%@ %@", authInfo.tokenType!, authInfo.accessToken!)
        requestSerializer.setValue(accessToken, forHTTPHeaderField:"Authorization")

        let parameters: NSDictionary = ["botInfo": botInfo, "authorization": accessToken]
        let operationManager: AFHTTPRequestOperationManager = AFHTTPRequestOperationManager.init(baseURL: NSURL.init(string: Constants.URL.baseUrl))
        operationManager.responseSerializer = AFJSONResponseSerializer.init()
        operationManager.requestSerializer = requestSerializer
        operationManager.POST(urlString, parameters: parameters, success: { (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) in
            print(operation.responseObject)
            let error: NSError?
            let botInfo: BotInfoModel = try! (MTLJSONAdapter.modelOfClass(BotInfoModel.self, fromJSONDictionary: responseObject! as! [NSObject : AnyObject]) as! BotInfoModel)
            
            success?(botInfo: botInfo)
            print(operation.responseObject)
        }) { (operation: AFHTTPRequestOperation!, error: NSError!) in
            if (operation.responseObject != nil) {
                print(operation.responseObject)
            }
            failure?(error: error)
        }
    }
    
    // MARK: anonymous user login
    public func anonymousUserSignIn(clientId: String!, success:((user: UserModel!, authInfo: AuthInfoModel!) -> Void)?, failure:((error: NSError) -> Void)?) {
        let urlString: String = Constants.URL.signInUrl
        let requestSerializer = AFJSONRequestSerializer()
        requestSerializer.HTTPMethodsEncodingParametersInURI = Set.init(["GET"]) as Set<String>
        requestSerializer.setValue("Keep-Alive", forHTTPHeaderField:"Connection")
        
        let uuid = Constants.getUUID()
        let parameters: NSDictionary = ["assertion":["subject":uuid, "issuer": clientId!]]
        
        let operationManager: AFHTTPRequestOperationManager = AFHTTPRequestOperationManager.init(baseURL: NSURL.init(string: Constants.URL.baseUrl))
        operationManager.responseSerializer = AFJSONResponseSerializer.init()
        operationManager.requestSerializer = requestSerializer
        operationManager.POST(urlString, parameters: parameters, success: { (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) in
            let error: NSError?
            let authInfo: AuthInfoModel = try! (MTLJSONAdapter.modelOfClass(AuthInfoModel.self, fromJSONDictionary: responseObject["authorization"]! as! [NSObject : AnyObject]) as! AuthInfoModel)
            let user: UserModel = try! (MTLJSONAdapter.modelOfClass(UserModel.self, fromJSONDictionary: responseObject["userInfo"]! as! [NSObject : AnyObject]) as! UserModel)
            
            success?(user: user, authInfo: authInfo)
        }) { (operation: AFHTTPRequestOperation!, error: NSError!) in
            if (operation.responseObject != nil) {
                print(operation.responseObject)
            }
            failure?(error: error)
        }
    }
    
    // MARK: subscribe/ unsubscribte for
    public func subscribeToNotifications(deviceToken: NSData!, userInfo: UserModel!, authInfo: AuthInfoModel!, success:((staus: Bool) -> Void)?, failure:((error: NSError) -> Void)?) {
        let urlString: String = Constants.URL.subscribeUrl(userInfo.userId)
        let requestSerializer = AFJSONRequestSerializer()
        requestSerializer.HTTPMethodsEncodingParametersInURI = Set.init(["GET"]) as Set<String>
        requestSerializer.setValue("Keep-Alive", forHTTPHeaderField:"Connection")
        
        let accessToken: String = String(format: "%@ %@", authInfo.tokenType!, authInfo.accessToken!)
        requestSerializer.setValue(accessToken, forHTTPHeaderField:"Authorization")

        let deviceId: String! = self.stringWithHexData(deviceToken)
        if (deviceId == nil) {
            failure?(error: NSError(domain: "KoreBotSDK", code: 0, userInfo: ["message": "deviceId is nil"]))
            return
        }
        let parameters: NSDictionary = ["deviceId": deviceId, "osType": "ios"]
        
        let operationManager: AFHTTPRequestOperationManager = AFHTTPRequestOperationManager.init(baseURL: NSURL.init(string: Constants.URL.baseUrl))
        operationManager.responseSerializer = AFJSONResponseSerializer.init()
        operationManager.requestSerializer = requestSerializer
        operationManager.POST(urlString, parameters: parameters, success: { (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) in
            success?(staus: true)
        }) { (operation: AFHTTPRequestOperation!, error: NSError!) in
            if (operation.responseObject != nil) {
                print(operation.responseObject)
            }
            failure?(error: error)
        }
    }
    
    public func unsubscribeToNotifications(deviceToken: NSData!, userInfo: UserModel!, authInfo: AuthInfoModel!, success:((staus: Bool) -> Void)?, failure:((error: NSError) -> Void)?) {
        let urlString: String = Constants.URL.unSubscribeUrl(userInfo.userId)
        let requestSerializer = AFJSONRequestSerializer()
        requestSerializer.HTTPMethodsEncodingParametersInURI = Set.init(["GET"]) as Set<String>
        requestSerializer.setValue("Keep-Alive", forHTTPHeaderField:"Connection")
        
        let accessToken: String = String(format: "%@ %@", authInfo.tokenType!, authInfo.accessToken!)
        requestSerializer.setValue(accessToken, forHTTPHeaderField:"Authorization")
        
        let deviceId: String! = self.stringWithHexData(deviceToken)
        if (deviceId == nil) {
            failure?(error: NSError(domain: "KoreBotSDK", code: 0, userInfo: ["message": "deviceId is nil"]))
            return
        }
        
        let parameters: NSDictionary = ["deviceId": deviceId]
        
        let operationManager: AFHTTPRequestOperationManager = AFHTTPRequestOperationManager.init(baseURL: NSURL.init(string: Constants.URL.baseUrl))
        operationManager.responseSerializer = AFJSONResponseSerializer.init()
        operationManager.requestSerializer = requestSerializer
        operationManager.DELETE(urlString, parameters: parameters, success: { (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) in
            success?(staus: true)
        }) { (operation: AFHTTPRequestOperation!, error: NSError!) in
            if (operation.responseObject != nil) {
                print(operation.responseObject)
            }
            failure?(error: error)
        }
    }
    
    private func stringWithHexData(data: NSData!) -> String! {
        if (data == nil) {
            return nil
        }

        let stringBuffer: NSMutableString = NSMutableString(capacity: (data.length*2))
        let dataBuffer = UnsafeBufferPointer<UInt8>(start:UnsafePointer<UInt8>(data.bytes), count:data.length)
        for i in 0 ..< data.length {
            stringBuffer.appendFormat("%02lx", Int(dataBuffer[i]))
        }
        return String(dataBuffer)
    }
}
