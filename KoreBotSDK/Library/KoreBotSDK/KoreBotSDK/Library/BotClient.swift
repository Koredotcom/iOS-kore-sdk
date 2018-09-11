//
//  KoreBot.swift
//  KoreBotSDK
//
//  Created by developer@kore.com on 23/05/16.
//  Copyright © 2016 Kore Inc. All rights reserved.
//

import UIKit
import SocketRocket

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
    fileprivate var connection: RTMPersistentConnection! = nil
    fileprivate var jwToken: String! = nil
    fileprivate var clientId: String! = nil
    fileprivate var botInfoParameters: [String: Any]?
    public var authInfoModel: AuthInfoModel! = nil
    public var userInfoModel: UserModel! = nil
    public private(set) var isNetworkAvailable = false
    public var connectionState: BotClientConnectionState = .NONE
    fileprivate var reconnects = false
    
    open var connectionWillOpen: (() -> Void)!
    open var connectionDidOpen: (() -> Void)!
    open var connectionReady: (() -> Void)!
    open var connectionDidClose: ((Int?, String?) -> Void)!
    open var connectionDidFailWithError: ((NSError?) -> Void)!
    open var onMessage: ((BotMessageModel?) -> Void)!
    open var onMessageAck: ((Ack?) -> Void)!
    
    open var botsUrl: String {
        get {
            return Constants.KORE_BOT_SERVER
        }
        set(newValue) {
            Constants.KORE_BOT_SERVER = newValue
        }
    }
    fileprivate var successClosure: ((BotClient?) -> Void)!
    fileprivate var failureClosure: ((NSError) -> Void)!
    
    // MARK: - init
    public override init() {
        super.init()
        startNewtorkMonitoring()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: -
    public func initialize(with botInfoParameters: [String: Any]?) {
        self.botInfoParameters = botInfoParameters
    }
    
    // MARK: - start network monitoring
    func startNewtorkMonitoring() {
        let requestManager: HTTPRequestManager = HTTPRequestManager.sharedManager
        requestManager.startNewtorkMonitoring { [unowned self] (status) in
            if status == .reachableViaWiFi || status == .reachableViaWWAN {
                self.isNetworkAvailable = true
                if (self.connection == nil) {
                    // webSocket connection not available
                    if (self.connectionWillOpen != nil) {
                        self.connectionState = .CONNECTING
                        self.connectionWillOpen()
                    }
                } else {
                    switch self.connection.websocket.readyState {
                    case .OPEN:
                        self.connectionState = .CONNECTED
                        break
                    case .CLOSED:
                        self.connectionState = .CLOSED
                        self.rtmConnectionDidFailWithError(NSError(domain: "RTM", code: 0, userInfo: nil))
                        break
                    case .CLOSING:
                        self.connectionState = .CLOSING
                        self.rtmConnectionDidFailWithError(NSError(domain: "RTM", code: 0, userInfo: nil))
                        break
                    case .CONNECTING:
                        self.connectionState = .CONNECTING
                        self.connectionWillOpen()
                        break
                    }
                }
            } else {
                self.isNetworkAvailable = false
                self.rtmConnectionDidFailWithError(NSError(domain: "RTM", code: 0, userInfo: ["descripiton": "Network is not available"]))
            }
        }
    }
    
    // MARK: set server url
    open func setKoreBotServerUrl(url: String) {
        Constants.KORE_BOT_SERVER = url
    }
    
    // MARK: make connection
    open func connectWithJwToken(_ jwtToken: String, success:((BotClient?) -> Void)?, failure:((Error?) -> Void)?)  {
        self.jwToken = jwtToken
        
        if (self.successClosure == nil) {
            self.successClosure = success as ((BotClient?) -> Void)?
        }
        if (self.failureClosure == nil) {
            self.failureClosure = failure
        }
        if let botInfoParameters = botInfoParameters {
            let requestManager: HTTPRequestManager = HTTPRequestManager.sharedManager
            requestManager.signInWithToken(jwtToken, botInfo: botInfoParameters, success: { [unowned self] (user, authInfo) in
                self.authInfoModel = authInfo
                self.userInfoModel = user
                self.connectionState = .CONNECTING
                self.connect()
            }) { (error) in
                failure?(error)
            }
        } else {
            failure?(nil)
        }
    }
    
    open func disconnect() {
        if self.connection != nil {
            self.connection.disconnect()
            self.connection.connectionDelegate = nil
            self.connection = nil
        }
        let requestManager: HTTPRequestManager = HTTPRequestManager.sharedManager
        requestManager.stopNewtorkMonitoring()
    }
    
    // MARK: connect
    @objc fileprivate func connect() {
        if (self.authInfoModel == nil) {
            self.connectWithJwToken(jwToken, success: { [unowned self] (client) in
                self.successClosure?(client)
            }, failure: { [unowned self] (error) in
                self.failureClosure?(NSError(domain: "RTM", code: 0, userInfo: nil))
            })
        } else if let botInfoParameters = botInfoParameters {
            let requestManager: HTTPRequestManager = HTTPRequestManager.sharedManager
            requestManager.getRtmUrlWithAuthInfoModel(self.authInfoModel, botInfo: botInfoParameters, success: { (botInfo) in
                self.connection = self.rtmConnectionWithBotInfoModel(botInfo!, isReconnect: self.reconnects)
                if (self.reconnects == false) {
                    if (self.successClosure != nil) {
                        self.successClosure(self)
                    }
                }
            }, failure: { (error) in
                if (self.failureClosure != nil) {
                    self.failureClosure?(NSError(domain: "RTM", code: 0, userInfo: error._userInfo as? [String : Any]))
                }
            })
        } else {
            self.failureClosure?(NSError(domain: "RTM", code: 0, userInfo: nil))
        }
    }
    
    
    // MARK: WebSocketDelegate methods
    open func rtmConnectionDidOpen() {
        self.reconnects = true
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
    
    open func rtmConnectionDidClose(_ code: Int, reason: String?) {
        if isNetworkAvailable == false {
            self.connectionState = .NO_NETWORK
        }
        switch code {
        case 1000:
            if (self.connectionDidClose != nil) {
                self.connectionDidClose(code, reason)
            }
            break
        default:
            if (self.connectionDidClose != nil) {
                self.connectionDidClose(code, reason)
            }
            break
        }
    }
    
    open func rtmConnectionDidFailWithError(_ error: NSError) {
        if isNetworkAvailable == false { self.connectionState = .NO_NETWORK }
        if (self.connectionDidFailWithError != nil) {
            self.connectionDidFailWithError(error)
        }
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
    fileprivate func rtmConnectionWithBotInfoModel(_ botInfo: BotInfoModel, isReconnect: Bool) -> RTMPersistentConnection? {
        if (self.connection != nil && (self.connection.websocket.readyState == .OPEN || self.connection.websocket.readyState == .CONNECTING)) {
            return self.connection
        } else if let botInfoParameters = botInfoParameters {
            self.connection = nil
            let rtmConnection: RTMPersistentConnection = RTMPersistentConnection(botInfo: botInfo, botInfoParameters: botInfoParameters, tryReconnect: isReconnect)
            rtmConnection.connectionDelegate = self
            rtmConnection.start()
            return rtmConnection
        }
        return nil
    }
    
    open func sendMessage(_ message: String, options: [String: Any]?) {
        if (self.connection == nil) {
            NSLog("WebSocket connection not available")
        } else {
            switch self.connection.websocket.readyState {
            case .OPEN:
                self.connection.sendMessage(message, options: options)
                break
            case .CLOSED:
                break
            case .CLOSING:
                break
            case .CONNECTING:
                break
            }
        }
    }
    
    // MARK: subscribe/ unsubscribe to push notifications
    open func subscribeToNotifications(_ deviceToken: Data!, success:((Bool) -> Void)?, failure:((NSError) -> Void)?) {
        let requestManager: HTTPRequestManager = HTTPRequestManager.sharedManager
        requestManager.subscribeToNotifications(deviceToken as Data?, userInfo: self.userInfoModel, authInfo: self.authInfoModel, success: success, failure: failure as! ((Error) -> Void)?)
    }
    
    open func unsubscribeToNotifications(_ deviceToken: Data!, success:((Bool) -> Void)?, failure:((NSError) -> Void)?) {
        let requestManager: HTTPRequestManager = HTTPRequestManager.sharedManager
        requestManager.unsubscribeToNotifications(deviceToken as Data?, userInfo: self.userInfoModel, authInfo: self.authInfoModel, success: success, failure: failure as! ((Error) -> Void)?)
    }
    
    deinit {
        NSLog("BotClient dealloc")
    }
}
