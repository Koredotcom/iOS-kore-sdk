//
//  KAAccount.swift
//  KoraSDK
//
//  Created by Srinivas Vasadi on 06/11/18.
//  Copyright © 2018 Srinivas Vasadi. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation
import AFNetworking
import Mantle
import KoreBotSDK
import Intents

public class KAAccount: NSObject {
    // MARK: - properties
    public var adminAccount: KAAdminAccount?
    public var currentSkill: KASkillMessage? {
        didSet {
            //currentSkillChanged.value += 1
        }
    }
    var recentSkillsArr: [KASkillMessage]?
    var usageLimit: [UsageLimits]?
   
    var wsKeyMapping: NSDictionary!
    var userDispatchQueue: DispatchQueue?
    let koraApplication = KoraApplication.sharedInstance
    var error: Error!
    private var completionQueue = DispatchQueue(label: "com.queue.kora")
    public let CONTACTS_FETCH_LIMIT: Int = 500
    public let NOTFICATION_FETCH_LIMIT = 50
    public var botClient: KABotClient?
    public var activeRequests: [String: Any] = [String: Any]()
    public var notificationCountHandler: (() -> Void)?
    public var timeZoneHandler: (() -> Void)?
    var pendingTasks = [URLSessionDataTask]()
    var user: KREUser?
   
    var isContactSyncInProgress = false
    var jwtToken: String?
  
    var networkReachabilityStatus = AFNetworkReachabilityStatus.notReachable
    
    var requestSessionManager: KAHTTPSessionManager = {
        let sessionManager = KAHTTPSessionManager(baseURL: URL(string: SDKConfiguration.serverConfig.JWT_SERVER))
        return sessionManager
    }()
    
    var sessionManager: KAHTTPSessionManager = {
        let sessionManager = KAHTTPSessionManager(baseURL: URL(string: SDKConfiguration.serverConfig.JWT_SERVER))
        return sessionManager
    }()
    
    var operationQueue = OperationQueue()
    
    public var DEFAULT_TIMEOUT_INTERVAL: Double = 60.0
    public var KORE_SERVER = SDKConfiguration.serverConfig.JWT_SERVER
    public var dispatchQueue: DispatchQueue = DispatchQueue(label: "com.kora.requestQueue")
    
    // MARK: -
    public var identity: String {
//        guard let identity = userInfo?.currentIdentity?.identity else {
//            return ""
//        }
//        return identity
        return "Ka"
    }
    
    public var userId: String {
//        guard let koraUserId = userInfo?.userId else {
//            return ""
//        }
//        return koraUserId
        return "Ka"
    }
    
    public var orgId: String {
//        guard let koraOrgId = userInfo?.orgId else {
//            return ""
//        }
//        return koraOrgId
        return "Ka"
    }
    
    public var accessToken: String {
//        guard let authorizationToken = authInfo?.accessToken else {
//            return ""
//        }
//        return authorizationToken
        return AcccesssTokenn ?? ""
    }
    
    // private properties
    var chunkOperationQueue: OperationQueue = OperationQueue()
    var componentOperationQueue: OperationQueue = OperationQueue()
    var downloadOperationQueue: OperationQueue = OperationQueue()
    var uploadOperationQueue: OperationQueue = OperationQueue()
    
    // MARK: - init
    public override init() {
        super.init()
    }

    // MARK: - upload component
    public func uploadComponent(_ component: Component, progress: ((_ progress: Double) -> Void)?, success: ((_ component: Component) -> Void)?, failure: ((_ error: Error?) -> Void)?) {        
        let componentOperation: KAComponentOperation = KAComponentOperation(component: component)
        componentOperation.account = self
        componentOperation.setCompletionBlock(progress: { (value) in
            progress?(value)
        }, success: { (component) in
            success?(component)
        }, failure: { (error) in
            failure?(error)
        })
        self.componentOperationQueue.addOperation(componentOperation)
    }
    
    func sizeLimitCheck(bytes: NSNumber) -> Bool {
        guard let usage = usageLimit else {
            return false
        }
        
        let limit = usage.filter {$0.type == "attachment"}
        let kbSize = Int(truncating: bytes)/(1000 * 1000)
        if kbSize > (limit.first)?.size ?? 0 {
            return false
        } else {
            return true
        }
    }
    
    public func cancelUpload(for component: Component) {
        self.componentOperationQueue.cancelAllOperations()
    }
    

    
    public func cancelDownload(for component: Component) {
        downloadOperationQueue.cancelAllOperations()
    }
    
    // MARK: - cancel all tasks
    func suspendAllTasks() {
        requestSessionManager.suspendAllTasks()
        sessionManager.suspendAllTasks()
    }
    
    func resumeAllTasks() {
        for dataTask in pendingTasks {
            dataTask.resume()
        }
        pendingTasks.removeAll()
    }
    
    func cancelAllTasks() {
        requestSessionManager.cancelAllTasks()
        sessionManager.cancelAllTasks()
    }
}
