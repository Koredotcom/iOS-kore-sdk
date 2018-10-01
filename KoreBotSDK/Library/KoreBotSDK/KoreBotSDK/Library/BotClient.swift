//
//  KoreBot.swift
//  KoreBotSDK
//
//  Created by developer@kore.com on 23/05/16.
//  Copyright © 2016 Kore Inc. All rights reserved.
//

import UIKit
import JWT
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
    fileprivate var connection: RTMPersistentConnection?
    fileprivate var parameters: [String: Any]?
    fileprivate var clientId: String?
    fileprivate var botInfoParameters: [String: Any]?
    public var authInfoModel: AuthInfoModel?
    public var userInfoModel: UserModel?
    public private(set) var isNetworkAvailable = false
    public var connectionState: BotClientConnectionState = .NONE
    fileprivate var reconnects = false
    
    open var connectionWillOpen: (() -> Void)?
    open var connectionDidOpen: (() -> Void)?
    open var connectionReady: (() -> Void)?
    open var connectionDidClose: ((Int?, String?) -> Void)?
    open var connectionDidFailWithError: ((NSError?) -> Void)?
    open var onMessage: ((BotMessageModel?) -> Void)?
    open var onMessageAck: ((Ack?) -> Void)?

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
                guard let connection = self.connection else {
                    // webSocket connection not available
                    self.connectionState = .CONNECTING
                    self.connectionWillOpen?()
                    return
                }

                switch connection.websocket.readyState {
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
                    self.connectionWillOpen?()
                    break
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
    
    // MARK: - generate JWT
    open func generateJWT(with parameters: [String: Any]?) -> String? {
        guard let clientSecret = parameters?["clientSecret"] as? String, let data = clientSecret.data(using: .utf8) else {
            print("\'clientSecret\' doesn't exist. Please set \'clientSecret\' value")
            return nil
        }
        guard let issuer = parameters?["clientId"] as? String else {
            print("\'clientId\' doesn't exist. Please set \'clientId\' value")
            return nil
        }
        guard let audience = parameters?["aud"] as? String else {
            print("\'aud\' doesn't exist. Please set \'aud\' value")
            return nil
        }
        guard let subject = parameters?["identity"] as? String else {
            print("\'identity\' doesn't exist. Please set \'identity\' value")
            return nil
        }
        guard let isAnonymous = parameters?["isAnonymous"] as? Bool else {
            print("\'isAnonymous\' doesn't exist. Please set \'isAnonymous\' value")
            return nil
        }
        
        let jwToken = JWT.encode(Algorithm.hs256(data)) { (claims) in
            let date = Date()
            var dateComponents = DateComponents()
            dateComponents.day = 1
            let calendar = Calendar.current
            
            claims.issuer = issuer
            claims.audience = audience
            let iat = Int64(date.timeIntervalSince1970 * 1000)
            claims["iat"] = iat
            if let nextDate = calendar.date(byAdding: dateComponents, to: date) {
                let exp = Int64(nextDate.timeIntervalSince1970 * 1000)
                claims["exp"] = exp
            }
            claims["sub"] = subject
            claims["isAnonymous"] = isAnonymous
        }
        return jwToken
    }
    
    // MARK: make connection
    open func connect(with parameters: [String: Any]?, success:((BotClient?) -> Void)?, failure:((Error?) -> Void)?)  {
        guard let jwtToken = generateJWT(with: parameters) else {
            failure?(nil)
            return
        }
        self.parameters = parameters
        
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
        if let connection = connection {
            connection.disconnect()
            connection.connectionDelegate = nil
        }
        connection = nil
        let requestManager: HTTPRequestManager = HTTPRequestManager.sharedManager
        requestManager.stopNewtorkMonitoring()
    }
    
    // MARK: connect
    @objc fileprivate func connect() {
        if authInfoModel == nil {
            connect(with: parameters, success: { [unowned self] (client) in
                self.successClosure?(client)
            }, failure: { [unowned self] (error) in
                self.failureClosure?(NSError(domain: "RTM", code: 0, userInfo: nil))
            })
        } else if let authInfoModel = authInfoModel, let botInfoParameters = botInfoParameters {
            let requestManager: HTTPRequestManager = HTTPRequestManager.sharedManager
            requestManager.getRtmUrlWithAuthInfoModel(authInfoModel, botInfo: botInfoParameters, success: { (botInfo) in
                self.connection = self.rtmConnectionWithBotInfoModel(botInfo!, isReconnect: self.reconnects)
                if self.reconnects == false {
                    self.successClosure?(self)
                }
            }, failure: { (error) in
                self.failureClosure?(NSError(domain: "RTM", code: 0, userInfo: error._userInfo as? [String : Any]))
            })
        } else {
            failureClosure?(NSError(domain: "RTM", code: 0, userInfo: nil))
        }
    }
    
    // MARK: WebSocketDelegate methods
    open func rtmConnectionDidOpen() {
        reconnects = true
        connectionState = .CONNECTED
        connectionDidOpen?()
    }
    
    public func rtmConnectionReady() {
        connectionReady?()
    }
    
    open func rtmConnectionDidClose(_ code: Int, reason: String?) {
        if isNetworkAvailable == false {
            connectionState = .NO_NETWORK
        }
        switch code {
        case 1000:
            connectionDidClose?(code, reason)
            break
        default:
            connectionDidClose?(code, reason)
            break
        }
    }
    
    open func rtmConnectionDidFailWithError(_ error: NSError) {
        if isNetworkAvailable == false { connectionState = .NO_NETWORK }
        connectionDidFailWithError?(error)
    }
    
    open func didReceiveMessage(_ message: BotMessageModel) {
        onMessage?(message)
    }
    
    open func didReceiveMessageAck(_ ack: Ack) {
        onMessageAck?(ack)
    }
    
    // MARK: functions
    fileprivate func rtmConnectionWithBotInfoModel(_ botInfo: BotInfoModel, isReconnect: Bool) -> RTMPersistentConnection? {
        if let connection = connection, (connection.websocket.readyState == .OPEN || connection.websocket.readyState == .CONNECTING) {
            return connection
        } else if let botInfoParameters = botInfoParameters {
            connection = nil
            let rtmConnection: RTMPersistentConnection = RTMPersistentConnection(botInfo: botInfo, botInfoParameters: botInfoParameters, tryReconnect: isReconnect)
            rtmConnection.connectionDelegate = self
            rtmConnection.start()
            return rtmConnection
        }
        return nil
    }
    
    open func sendMessage(_ message: String, options: [String: Any]?) {
        guard let connection = connection else {
            NSLog("WebSocket connection not available")
            return
        }
        switch connection.websocket.readyState {
        case .OPEN:
            connection.sendMessage(message, options: options)
            break
        case .CLOSED:
            break
        case .CLOSING:
            break
        case .CONNECTING:
            break
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
    
    // MARK: - deinit
    deinit {
        print("BotClient dealloc")
    }
}
