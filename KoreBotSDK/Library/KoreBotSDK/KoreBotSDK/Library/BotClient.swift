//
//  KoreBot.swift
//  KoreBotSDK
//
//  Created by developer@kore.com on 23/05/16.
//  Copyright © 2016 Kore Inc. All rights reserved.
//

import UIKit
import Starscream

public enum BotClientConnectionState : Int {
    case NONE
    case CONNECTING
    case CONNECTED
    case FAILED
    case CLOSED
    case NO_NETWORK
}

open class BotClient: NSObject, RTMPersistentConnectionDelegate {
    
    // MARK: properties
    fileprivate var connection: RTMPersistentConnection! = nil
    fileprivate var jwToken: String! = nil
    fileprivate var clientId: String! = nil
    fileprivate var botInfoParameters: NSDictionary! = nil
    public var authInfoModel: AuthInfoModel! = nil
    public var userInfoModel: UserModel! = nil
    public private(set) var isNetworkAvailable = false
    public var connectionState: BotClientConnectionState = .NONE
    
    fileprivate var reconnects = false
    fileprivate var reconnecting = false
    fileprivate var currentReconnectAttempt = 0
    fileprivate(set) var reconnectAttempts = 3
    fileprivate var reconnectTimer: Timer!
    
    open var connectionWillOpen: (() -> Void)!
    open var connectionDidOpen: (() -> Void)!
    open var connectionReady: (() -> Void)!
    open var connectionDidClose: ((Int, String) -> Void)!
    open var connectionDidFailWithError: ((NSError) -> Void)!
    open var onMessage: ((BotMessageModel?) -> Void)!
    open var onMessageAck: ((Ack?) -> Void)!
    
    fileprivate var successClosure: ((BotClient?) -> Void)!
    fileprivate var failureClosure: ((NSError) -> Void)!
    
    // MARK: init
    public convenience init(botInfoParameters: NSDictionary!) {
        self.init()
        self.botInfoParameters = botInfoParameters
        let requestManager: HTTPRequestManager = HTTPRequestManager.sharedManager
        requestManager.startNewtorkMonitoring {[weak self] (status) in
            if status == .reachableViaWiFi || status == .reachableViaWWAN {
                self?.isNetworkAvailable = true
                if (self?.reconnects)! { self?.reconnect() }
            } else {
                self?.isNetworkAvailable = false
                self?.connectionState = .NO_NETWORK
            }
        }
    }
    
    // MARK: set server url
    open func setKoreBotServerUrl(url: String) {
        Constants.KORE_BOT_SERVER = url
    }
    
    // MARK: make connection
    open func connectWithJwToken(_ jwtToken: String!, success:((BotClient?) -> Void)?, failure:((Error) -> Void)?)  {
        self.jwToken = jwtToken
        
        if (self.successClosure == nil) {
            self.successClosure = success as ((BotClient?) -> Void)!
        }
        if (self.failureClosure == nil) {
            self.failureClosure = failure
        }
        
        let requestManager: HTTPRequestManager = HTTPRequestManager.sharedManager
        requestManager.signInWithToken(jwtToken as AnyObject, botInfo: self.botInfoParameters, success: { (user, authInfo) in
            self.authInfoModel = authInfo
            self.userInfoModel = user
            self.connectionState = .CONNECTING
            self.connect()
        }) { (error) in
            failure!(error)
        }
    }
    
    @objc open func reconnect() {
        if self.reconnecting == false && self.isNetworkAvailable {
            self.reconnecting = true
            self.connectionState = .CONNECTING
            
            if (self.connectionWillOpen != nil) {
                self.connectionWillOpen()
            }
            
            self.connect()
        }
    }
    
    open func reconnectAfter(_ timeInterval: TimeInterval) {
        self.addReconnectTimer(timeInterval)
    }
    
    open func disconnect() {
        self.removeReconnectTimer()
        if self.connection != nil {
            self.connection.disconnect()
            self.connection.connectionDelegate = nil
            self.connection = nil
        }
        let requestManager: HTTPRequestManager = HTTPRequestManager.sharedManager
        requestManager.stopNewtorkMonitoring()
    }
    
    // MARK:
    @objc fileprivate func connect() {
        if (self.authInfoModel == nil) {
            self.connectWithJwToken(jwToken, success: { (client) in
                self.reconnecting = false
                if (self.successClosure != nil) {
                    self.successClosure(client)
                }
            }, failure: { (error) in
                self.reconnecting = false
                if (self.failureClosure != nil) {
                    self.failureClosure?(NSError(domain: "RTM", code: 0, userInfo: error._userInfo as! [AnyHashable : Any]? as! [String : Any]))
                }
            })
        } else {
            let requestManager: HTTPRequestManager = HTTPRequestManager.sharedManager
            requestManager.getRtmUrlWithAuthInfoModel(self.authInfoModel, botInfo: self.botInfoParameters, success: { (botInfo) in
                self.connection = self.rtmConnectionWithBotInfoModel(botInfo!, isReconnect: self.reconnects)
                self.reconnecting = false
                if (self.reconnects == false) {
                    if (self.successClosure != nil) {
                        self.successClosure(self)
                    }
                }
            }, failure: { (error) in
                self.reconnecting = false
                self.tryReconnect()
            })
        }
    }
    
    fileprivate func tryReconnect() {
        if self.reconnecting == false && self.isNetworkAvailable {
            self.reconnecting = true
        
            if currentReconnectAttempt + 1 > reconnectAttempts {
                if (self.connectionDidClose != nil) {
                    self.connectionDidClose(100, "Reconnect Failed")
                }
                if (self.reconnects == false) {
                    if (self.failureClosure != nil) {
                        self.failureClosure(NSError(domain: "RTM", code: 0, userInfo: ["message": "connection timed-out"]))
                    }
                }
                return
            }
            
            self.connectionState = .CONNECTING
            if (self.connectionWillOpen != nil) {
                self.connectionWillOpen()
            }
            
            currentReconnectAttempt += 1
            self.connect()
        }
    }
    
    fileprivate func addReconnectTimer(_ interval: TimeInterval) {
        self.removeReconnectTimer()
        self.reconnectTimer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(self.reconnect), userInfo: nil, repeats: false)
        RunLoop.main.add(self.reconnectTimer, forMode: RunLoopMode.defaultRunLoopMode)
    }
    
    fileprivate func removeReconnectTimer() {
        if self.reconnectTimer != nil {
            self.reconnectTimer.invalidate()
            self.reconnectTimer = nil
        }
    }
    
    // MARK: WebSocketDelegate methods
    
    open func rtmConnectionDidOpen() {
        self.currentReconnectAttempt = 0
        self.reconnects = true
        self.reconnecting = false
        self.connectionState = .CONNECTED
        if (self.connectionDidOpen != nil) {
            self.connectionDidOpen()
        }
    }
    
    public func rtmConnectionReady() {
        if (self.connectionReady != nil) {
            self.connectionReady()
        }
    }
    
    open func rtmConnectionDidClose(_ code: Int, reason: String) {
        if self.isNetworkAvailable { self.connectionState = .CLOSED }
        switch code {
        case 1000:
            if (self.connectionDidClose != nil) {
                self.connectionDidClose(code, reason)
            }
            break
        default:
            self.reconnect()
            break
        }
    }
    
    open func rtmConnectionDidFailWithError(_ error: NSError) {
        self.reconnecting = false
        if self.isNetworkAvailable { self.connectionState = .FAILED }
        if (self.connectionDidFailWithError != nil) {
            self.connectionDidFailWithError(error)
        }
        self.tryReconnect()
    }
    
    open func didReceiveMessage(_ message: BotMessageModel) {
        if (self.onMessage != nil) {
            self.onMessage(message)
        }
    }
    open func didReceiveMessageAck(_ ack: Ack) {
        if (self.onMessageAck != nil) {
            self.onMessageAck(ack)
        }
    }
    
    // MARK: functions
    fileprivate func rtmConnectionWithBotInfoModel(_ botInfo: BotInfoModel, isReconnect: Bool) -> RTMPersistentConnection {
        if connection != nil {
            return connection
        } else {
            let rtmConnection: RTMPersistentConnection = RTMPersistentConnection(botInfo: botInfo, botInfoParameters: self.botInfoParameters, tryReconnect: isReconnect)
            rtmConnection.connectionDelegate = self
            rtmConnection.start()
            return rtmConnection
        }
    }
    
    open func sendMessage(_ message: String!, options: AnyObject!) {
        guard let socket = connection.socket else {
            NSLog("WebSocket connection not available")
            return
        }
        
        if socket.isConnected {
            connection.sendMessageModel(message, options: [] as AnyObject?)
        }
    }
    
    // MARK: subscribe/ unsubscribe to push notifications
    open func subscribeToNotifications(_ deviceToken: Data!, success:((Bool) -> Void)?, failure:((NSError) -> Void)?) {
        let requestManager: HTTPRequestManager = HTTPRequestManager.sharedManager
        requestManager.subscribeToNotifications(deviceToken as Data!, userInfo: self.userInfoModel, authInfo: self.authInfoModel, success: success, failure: failure as! ((Error) -> Void)?)
    }
    
    open func unsubscribeToNotifications(_ deviceToken: Data!, success:((Bool) -> Void)?, failure:((NSError) -> Void)?) {
        let requestManager: HTTPRequestManager = HTTPRequestManager.sharedManager
        requestManager.unsubscribeToNotifications(deviceToken as Data!, userInfo: self.userInfoModel, authInfo: self.authInfoModel, success: success, failure: failure as! ((Error) -> Void)?)
    }

    deinit {
        NSLog("BotClient dealloc")
    }
}
