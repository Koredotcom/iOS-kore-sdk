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
import KoreBotSDK
import Intents
import Alamofire

public class KAAccount: NSObject {
    // MARK: - properties
    public var adminAccount: KAAdminAccount?
    public var currentSkill: KASkillMessage? {
        didSet {
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
  
    //var networkReachabilityStatus = AFNetworkReachabilityStatus.notReachable
    
    static let APIManager: Session = {
          let configuration = URLSessionConfiguration.default
          configuration.timeoutIntervalForRequest = 20
          let delegate = Session.default.delegate
          let manager = Session.init(configuration: configuration,
                                     delegate: delegate,
                                     startRequestsImmediately: true,
                                     cachedResponseHandler: nil)
          return manager
      }()
    
    var requestSessionManager: Session = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 60
        let delegate = Session.default.delegate
        let sessionManager = Session.init(configuration: configuration,
                                   delegate: delegate,
                                   startRequestsImmediately: true,
                                   cachedResponseHandler: nil)
        return sessionManager
    }()
    
    var sessionManager: Session = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 60
        let delegate = Session.default.delegate
        let sessionManager = Session.init(configuration: configuration,
                                   delegate: delegate,
                                   startRequestsImmediately: true,
                                   cachedResponseHandler: nil)
        return sessionManager
    }()
    
    var operationQueue = OperationQueue()
    
    public var DEFAULT_TIMEOUT_INTERVAL: Double = 60.0
    public var KORE_SERVER = SDKConfiguration.serverConfig.JWT_SERVER
    public var dispatchQueue: DispatchQueue = DispatchQueue(label: "com.kora.requestQueue")
    
    // MARK: -
    public var userId: String {
        return ""
    }
    public var accessToken: String {
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
    
//    // MARK: - cancel all tasks
//    func suspendAllTasks() {
//        requestSessionManager.suspendAllTasks()
//        sessionManager.suspendAllTasks()
//    }
//
//    func resumeAllTasks() {
//        for dataTask in pendingTasks {
//            dataTask.resume()
//        }
//        pendingTasks.removeAll()
//    }
//
//    func cancelAllTasks() {
//        requestSessionManager.cancelAllTasks()
//        sessionManager.cancelAllTasks()
//    }
}
