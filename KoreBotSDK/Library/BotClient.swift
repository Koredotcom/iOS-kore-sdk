//
//  KoreBot.swift
//  KoreBotSDK
//
//  Created by developer@kore.com on 23/05/16.
//  Copyright © 2016 Kore Inc. All rights reserved.
//

import UIKit
import Alamofire

public enum BotClientConnectionState : Int {
    case NONE
    case CONNECTING
    case CONNECTED
    case FAILED
    case CLOSED
    case CLOSING
    case NO_NETWORK
}

open class BotClient: NSObject, RTMPersistentConnectionDelegate {
    // MARK: properties
    fileprivate var connection: RTMPersistentConnection?
    public var jwToken: String?
    fileprivate var clientId: String?
    fileprivate var botInfoParameters: [String: Any]?
    fileprivate var customData: [String: Any]?
    public var reWriteOptions: [String: Any]?
    public var authInfoModel: AuthInfoModel?
    public var userInfoModel: UserModel?
    public var isNetworkAvailable: Bool?
    public var connectionState: BotClientConnectionState {
        get {
            if let isNetworkAvailable = isNetworkAvailable, isNetworkAvailable == false {
                return .NO_NETWORK
            }
            
            guard let connection = connection else {
                return .NONE
            }
            
            let isConnecting = connection.isConnecting
            let isConnected = connection.isConnected
            
            if (isConnected) {
                return .CONNECTED
            }
            if (!isConnecting && !isConnected) {
                return.CLOSED
            }
            if (isConnecting && !isConnected) {
                return .CONNECTING
            }
            
            return .NONE
        }
    }
    fileprivate var reconnects = false
    
    open var connectionWillOpen: (() -> Void)?
    open var connectionDidOpen: (() -> Void)?
    open var connectionReady: (() -> Void)?
    open var connectionDidClose: ((UInt16?, String?) -> Void)?
    open var connectionDidFailWithError: ((Error?) -> Void)?
    open var onMessage: ((BotMessageModel?) -> Void)?
    open var onMessageAck: ((Ack?) -> Void)?
    open var onUserMessageReceived:(([String:Any])-> Void)?
    open var botsUrl: String {
        get {
            return Constants.KORE_BOT_SERVER
        }
        set(newValue) {
            Constants.KORE_BOT_SERVER = newValue
        }
    }
    
    fileprivate var successClosure: ((BotClient?) -> Void)?
    fileprivate var failureClosure: ((NSError) -> Void)?
    fileprivate var intermediaryClosure: ((BotClient?) -> Void)?
    
    // MARK: - init
    public override init() {
        super.init()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: -
    public func initialize(botInfoParameters: [String: Any]?, customData: [String: Any]?, reWriteOptions: [String: Any]? = nil) {
        self.botInfoParameters = botInfoParameters
        self.customData = customData
        self.reWriteOptions = reWriteOptions
    }
    
    // MARK: - start network monitoring
    public func setReachabilityStatusChange(_ status: NetworkReachabilityManager.NetworkReachabilityStatus) {
        if status == .reachable(.ethernetOrWiFi) || status == .reachable(.cellular) {
            self.isNetworkAvailable = true
            guard let connection = self.connection else {
                // webSocket connection not available
                self.connectionWillOpen?()
                return
            }
            let isConnected = connection.isConnected
            if isConnected {
                self.rtmConnectionDidFailWithError(NSError(domain: "RTM", code: 0, userInfo: nil))
            } else {
                self.connectionWillOpen?()
            }
        } else {
            self.isNetworkAvailable = false
            self.rtmConnectionDidFailWithError(NSError(domain: "RTM", code: 0, userInfo: ["descripiton": "Network is not available"]))
        }
    }
    
    
    // MARK: set server url
    open func setKoreBotServerUrl(url: String) {
        Constants.KORE_BOT_SERVER = url
    }
    
    // MARK: make connection
    open func connectWithJwToken(_ jwtToken: String?, intermediary:((BotClient?) -> Void)?,  success:((BotClient?) -> Void)?, failure:((Error?) -> Void)?)  {
        guard let jwtToken = jwtToken else {
            failure?(nil)
            return
        }
        self.jwToken = jwtToken
        successClosure = success
        failureClosure = failure
        intermediaryClosure = intermediary
        
        if let botInfoParameters = botInfoParameters {
            let requestManager: HTTPRequestManager = HTTPRequestManager.sharedManager
            requestManager.signInWithToken(jwtToken, botInfo: botInfoParameters, success: { [weak self] (user, authInfo) in
                self?.authInfoModel = authInfo
                self?.userInfoModel = user
                self?.intermediaryClosure?(self)
            }) { (error) in
                failure?(error)
            }
        } else {
            failure?(nil)
        }
    }
    
    open func disconnect() {
        if let connection = connection {
            connection.disconnect()
            connection.connectionDelegate = nil
        }
        connection = nil
    }
    
    // MARK:connect
    @objc public func connect(isReconnect: Bool) {
        reconnects = isReconnect
        if authInfoModel == nil {
            self.connectWithJwToken(jwToken, intermediary: { [weak self] (client) in
                self?.intermediaryClosure?(client)
            }, success: { (client) in
                self.successClosure?(client)
            }, failure: { (error) in
                self.failureClosure?(NSError(domain: "RTM", code: 0, userInfo: error?._userInfo as? [String : Any]))
            })
        } else if let authInfoModel = authInfoModel, let botInfoParameters = botInfoParameters {
            let requestManager: HTTPRequestManager = HTTPRequestManager.sharedManager
            requestManager.getRtmUrlWithAuthInfoModel(authInfoModel, botInfo: botInfoParameters, success: { [weak self] (botInfo) in
                self?.connection = self?.rtmConnectionWithBotInfoModel(botInfo!, isReconnect: self?.reconnects ?? false)
                if self?.reconnects == false {
                    self?.successClosure?(self)
                }
            }, failure: { [weak self] (error) in
                self?.failureClosure?(NSError(domain: "RTM", code: 0, userInfo: error._userInfo as? [String : Any]))
            })
        } else {
            failureClosure?(NSError(domain: "RTM", code: 0, userInfo: nil))
        }
    }
    
    // MARK: WebSocketDelegate methods
    open func rtmConnectionDidOpen() {
        connectionDidOpen?()
    }
    
    public func rtmConnectionReady() {
        connectionReady?()
    }
    
    open func rtmConnectionDidClose(_ code: UInt16, reason: String?) {
        switch code {
        case 1000:
            connectionDidClose?(code, reason)
            break
        default:
            connectionDidClose?(code, reason)
            break
        }
    }
    
    open func rtmConnectionDidFailWithError(_ error: Error?) {
        connectionDidFailWithError?(error)
    }
    open func didReceivedUserMessage(_ usrMessage:[String:Any]) {
        onUserMessageReceived?(usrMessage)
    }
    open func didReceiveMessage(_ message: BotMessageModel) {
        onMessage?(message)
    }
    
    open func didReceiveMessageAck(_ ack: Ack) {
        onMessageAck?(ack)
    }
    
    // MARK: functions
    fileprivate func rtmConnectionWithBotInfoModel(_ botInfo: BotInfoModel, isReconnect: Bool) -> RTMPersistentConnection? {
        if let connection = connection, (connection.isConnected || connection.isConnecting) {
            return connection
        } else if let botInfoParameters = botInfoParameters {
            if connection == nil {
                connection = RTMPersistentConnection()
            }
            connection?.connect(botInfo: botInfo, botInfoParameters: botInfoParameters, reWriteOptions: reWriteOptions, tryReconnect: isReconnect)
            connection?.connectionDelegate = self
            return connection
        }
        return nil
    }
    
    open func sendMessage(_ message: String, dictionary: [String: Any]? = nil, options: [String: Any]?) {
        guard let connection = connection else {
            NSLog("WebSocket connection not available")
            return
        }
        
        let isConnected = connection.isConnected
        if isConnected {
            var parameters = customData ?? [:]
            if let botToken = authInfoModel?.accessToken {
                parameters["botToken"] = botToken
            }
            dictionary?.forEach { (key, value) in parameters[key] = value }
            connection.sendMessage(message, parameters: parameters, options: options)
        }
    }
    
    // MARK: subscribe/unsubscribe to push notifications
    open func subscribeToNotifications(_ deviceToken: Data!, success:((Bool) -> Void)?, failure:((NSError) -> Void)?) {
        let requestManager: HTTPRequestManager = HTTPRequestManager.sharedManager
        requestManager.subscribeToNotifications(deviceToken as Data?, userInfo: userInfoModel, authInfo: authInfoModel, success: success, failure: failure as! ((Error) -> Void)?)
    }
    
    open func unsubscribeToNotifications(_ deviceToken: Data!, success:((Bool) -> Void)?, failure:((NSError) -> Void)?) {
        let requestManager: HTTPRequestManager = HTTPRequestManager.sharedManager
        requestManager.unsubscribeToNotifications(deviceToken as Data?, userInfo: userInfoModel, authInfo: authInfoModel, success: success, failure: failure as! ((Error) -> Void)?)
    }
    
    open func getHistory(offset: Int, success:((_ responseObject: Any?) -> Void)?, failure:((_ error: Error?) -> Void)?) {
        let requestManager: HTTPRequestManager = HTTPRequestManager.sharedManager
        if let botInfo = botInfoParameters, let authInfo = authInfoModel {
            requestManager.getHistory(offset: offset, authInfo, botInfo: botInfo, success: success, failure: failure)
        } else {
            failure?(nil)
        }
    }
    
    open func getMessages(after messageId: String, direction: Int, success:((_ responseObject: Any?) -> Void)?, failure:((_ error: Error?) -> Void)?) {
        let requestManager: HTTPRequestManager = HTTPRequestManager.sharedManager
        if let botInfo = botInfoParameters, let authInfo = authInfoModel {
            requestManager.getMessages(after: messageId, direction: direction, authInfo, botInfo: botInfo, success: success, failure: failure)
        } else {
            failure?(nil)
        }
    }
    
    // MARK: - deinit
    deinit {
        print("BotClient dealloc")
    }
}
