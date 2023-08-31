//
//  KAHTTPRequestManager.swift
//  KoraApp
//
//  Created by Srinivas Vasadi on 21/03/18.
//  Copyright © 2018 Srinivas Vasadi. All rights reserved.
//

import UIKit
import KoreBotSDK
import Alamofire

open class KAHTTPRequestManager: NSObject {
    static var instance: KAHTTPRequestManager!
    
    // MARK: request manager shared instance
    public static let sharedManager : KAHTTPRequestManager = {
        if (instance == nil) {
            instance = KAHTTPRequestManager()
        }
        return instance
    }()
}

// MARK: - requests
extension KAAccount {
    // MARK: - check networkReachability
    public func networkReachability(shouldTriggerNotificaiton: Bool = true) -> Bool {
        return networkReachability(with: "", shouldTriggerNotificaiton: shouldTriggerNotificaiton)
    }
    
    func networkReachability(with message: String?, shouldTriggerNotificaiton: Bool) -> Bool {
        var isReachable = true
        let networkReachabilityManager = NetworkReachabilityManager.default
        networkReachabilityManager?.startListening(onUpdatePerforming: { (status) in
            print("Network reachability: \(status)")
            switch status {
            case .notReachable:
                isReachable = false
            default:
                break
            }
            
            KABotClient.shared.setReachabilityStatusChange(status)
        })
        
        if isReachable == false && shouldTriggerNotificaiton {
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: Notification.Name("KANetworkNotReachableNotification"), object: nil, userInfo: ["message": message ?? ""])
            }
        }
        return isReachable
    }

    // MARK: - upload components
    func requestSerializerHeaders() -> HTTPHeaders {
        let tokenType = "bearer"
        let authorizationStr = "\(tokenType) \(accessToken)"
        let headers: HTTPHeaders = [
            "Connection": "Keep-Alive",
            "X-KORA-Client": KoraAssistant.shared.applicationHeader,
            "Authorization": authorizationStr
        ]
        return headers
    }
    
    // MARK: add query parameters
    func addQueryString(to urlString: String, with parameters: [String: Any]?) -> String {
        guard var urlComponents = URLComponents(string: urlString), let parameters = parameters, !parameters.isEmpty else {
            return urlString
        }
        let keys = parameters.keys.map { $0.lowercased() }
        urlComponents.queryItems = urlComponents.queryItems?
            .filter { !keys.contains($0.name.lowercased()) } ?? []
        
        urlComponents.queryItems?.append(contentsOf: parameters.compactMap {
            return URLQueryItem(name: $0.key, value: "\($0.value)")
        })
        
        return urlComponents.string ?? urlString
    }
}
 
