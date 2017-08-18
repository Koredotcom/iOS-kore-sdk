//
//  STTRequestManager.swift
//  Pods
//
//  Created by developer@kore.com on 24/07/17.
//  Copyright © 2017 Kore Inc. All rights reserved.
//
//

import Foundation
import AFNetworking

open class STTRequestManager : NSObject {
    var options: AnyObject?
    static var instance: STTRequestManager!
    
    // MARK: request manager shared instance
    open static let sharedManager : STTRequestManager = {
        if (instance == nil) {
            instance = STTRequestManager()
        }
        return instance
    }()
    
    open func getSocketUrlWithAuthInfoModel(_ accessToken: String!, identity: String!, success:((_ responseObject: AnyObject?) -> Void)?, failure:((_ error: Error) -> Void)?)  {
        let urlString: String = String(format: STTConstants.SpeechServer.urlPath, STTConstants.SpeechServer.baseUrl, identity)
        let requestSerializer = AFJSONRequestSerializer()
        requestSerializer.httpMethodsEncodingParametersInURI = Set.init(["GET"]) as Set<String>
        requestSerializer.setValue(accessToken, forHTTPHeaderField:"Authorization")
        requestSerializer.setValue("Keep-Alive", forHTTPHeaderField:"Connection")
        requestSerializer.setValue("application/json", forHTTPHeaderField:"Content-Type")
        requestSerializer.setValue("application/json", forHTTPHeaderField:"Accept")
        
        let parameters: NSDictionary = ["email":identity]
        let operationManager: AFHTTPRequestOperationManager = AFHTTPRequestOperationManager.init(baseURL: URL.init(string: STTConstants.SpeechServer.baseUrl) as URL!)
        operationManager.responseSerializer = AFJSONResponseSerializer.init()
        operationManager.requestSerializer = requestSerializer
        operationManager.post(urlString, parameters: parameters, success: { (operation, responseObject) in
            print(responseObject ?? "")
            success?(responseObject as AnyObject)
        }) { (operation, requestError) in
            if (operation?.responseObject != nil) {
                print(operation?.responseObject ?? "")
            }
            failure?(requestError!)
        }
    }
}

