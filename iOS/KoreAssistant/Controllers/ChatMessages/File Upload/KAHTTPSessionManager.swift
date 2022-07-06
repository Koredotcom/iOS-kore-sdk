//
//  KAHTTPSessionManager.swift
//  KoraSDK
//
//  Created by Srinivas Vasadi on 25/07/18.
//  Copyright © 2018 Srinivas Vasadi. All rights reserved.
//

import UIKit
//import AFNetworking

public enum KAHTTPRequestStatus: Int {
    case noError = 0, requestExists = 1, noNetwork = 2, requestError = 3
}
/*
open class KAHTTPSessionManager: AFHTTPSessionManager {
    // MARK: - init
    public init(baseURL: URL?) {
        super.init(baseURL: baseURL, sessionConfiguration: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: -
    func configureSecurityPolicy() {
        // load certificate
        let productionServer = baseURL?.host
        let isKoreFilesServer: Bool = Int((productionServer as NSString?)?.range(of: "kore-files.com").location ?? 0) != NSNotFound
        var thePath: String? = nil
        if isKoreFilesServer {
            thePath = Bundle.main.path(forResource: "KoreRootCA_Files", ofType: "cer")
        } else {
            let isProductionServer: Bool = Int((productionServer as NSString?)?.range(of: "kore.com").location ?? 0) != NSNotFound
            if isProductionServer {
                thePath = Bundle.main.path(forResource: "KoreRootCA_Prod", ofType: "cer")
            } else {
                if Int((productionServer as NSString?)?.range(of: "app.kore.ai").location ?? 0) != NSNotFound {
                    thePath = Bundle.main.path(forResource: "star_kore_ai", ofType: "cer")
                } else {
                    thePath = Bundle.main.path(forResource: "qa_kore_ai", ofType: "cer")
                }
            }
        }
        
        if let path = thePath, let fileUrl = URL(string: path), let certificateData = try? Data(contentsOf: fileUrl) {
            let securityPolicy = AFSecurityPolicy(pinningMode: AFSSLPinningMode.certificate)
            securityPolicy.pinnedCertificates = [certificateData]
            securityPolicy.allowInvalidCertificates = true
            securityPolicy.allowInvalidCertificates = false
            self.securityPolicy = securityPolicy
        }
    }
    
    // MARK: -
    var isReachable: Bool {
        return self.reachabilityManager.isReachable
    }
    
    var isReachableViaWiFi: Bool {
        return self.reachabilityManager.isReachableViaWiFi
    }
    
    var isReachableViaWWAN: Bool {
        return self.reachabilityManager.isReachableViaWWAN
    }
    
    // MARK: -
    func suspendAllTasks() {
        session.getTasksWithCompletionHandler({ dataTasks, uploadTasks, downloadTasks in
            for dataTask in dataTasks {
                dataTask.suspend()
            }
        })
    }
    
    func cancelAllTasks() {
        session.getTasksWithCompletionHandler({ dataTasks, uploadTasks, downloadTasks in
            for dataTask in dataTasks {
                dataTask.cancel()
            }
        })
    }
    
    func resumeAllTasks(for account: KAAccount) {
        session.getTasksWithCompletionHandler({ (dataTasks, uploadTasks, downloadTasks) in
            for dataTask in dataTasks {
                dataTask.resume()
            }
        })
    }
}
*/
