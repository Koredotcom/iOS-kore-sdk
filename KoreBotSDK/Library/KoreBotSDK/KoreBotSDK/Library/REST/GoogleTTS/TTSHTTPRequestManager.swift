//
//  TTSHTTPRequestManager.swift
//  KoreBotSDK
//
//  Created by Shylaja Mamidala on 26/06/18.
//  Copyright © 2018 Kore. All rights reserved.
//

import UIKit
import AFNetworking

open class TTSHTTPRequestManager: NSObject {
    static var instance: TTSHTTPRequestManager!
    
    open static let sharedManager : TTSHTTPRequestManager = {
        if (instance == nil) {
            instance = TTSHTTPRequestManager()
        }
        return instance
    }()
    
    open func doConvertTextToSpeech(with urlString: String, Params: [String: Any], success:((_ operation: AFHTTPRequestOperation?, _ response: [String: Any]?) -> Void)?, failure:((_ error: Error) -> Void)?) {
        let requestSerializer = AFJSONRequestSerializer()
        //to Use oAuth set accessToken in httpheaderfield
        let operationManager: AFHTTPRequestOperationManager = AFHTTPRequestOperationManager.init(baseURL: URL.init(string: urlString) as URL!)
        operationManager.responseSerializer = AFJSONResponseSerializer.init()
        operationManager.requestSerializer = requestSerializer
        operationManager.post(urlString, parameters: Params, success: { (operation, responseObject) in
            success?(operation, responseObject as! [String : Any])
        }) { (operation, error) in
            if (operation?.responseObject != nil) {
                print(operation?.responseObject)
            }
            failure?(error!)
        }
    }
}
