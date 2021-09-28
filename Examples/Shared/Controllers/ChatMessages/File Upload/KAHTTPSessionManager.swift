//
//  KAHTTPSessionManager.swift
//  KoraSDK
//
//  Created by Srinivas Vasadi on 25/07/18.
//  Copyright © 2018 Srinivas Vasadi. All rights reserved.
//

import UIKit
import Alamofire

public enum KAHTTPRequestStatus: Int {
    case noError = 0, requestExists = 1, noNetwork = 2, requestError = 3
}

open class KAHTTPSessionManager: NSObject {
    // MARK: -
    var baseURL: URL?
    let session: Session = {
        let configuration = URLSessionConfiguration.af.default
        configuration.timeoutIntervalForRequest = 30
        return Session(configuration: configuration)
    }()
    
    let reachabilityManager = NetworkReachabilityManager.default
    
    // MARK: - init
    public init(baseURL: URL?) {
        super.init()
        self.baseURL = baseURL
    }
    
    // MARK: -
    func configureSecurityPolicy() {

    }
    
    // MARK: -
    var isReachable: Bool {
        return reachabilityManager?.isReachable ?? false
    }
    
    var isReachableViaWiFi: Bool {
        return reachabilityManager?.isReachableOnEthernetOrWiFi ?? false
    }
    
    var isReachableViaWWAN: Bool {
        return self.reachabilityManager?.isReachableOnCellular ?? false
    }
    
    // MARK: -
    func suspendAllTasks() {
        session.cancelAllRequests()
    }
    
    func cancelAllTasks() {
        session.cancelAllRequests()
    }
    
    func resumeAllTasks(for account: KAAccount) {

    }
}
