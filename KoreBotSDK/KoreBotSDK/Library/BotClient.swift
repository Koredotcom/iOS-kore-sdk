//
//  KoreBot.swift
//  KoreBotSDK
//
//  Created by Srinivas Vasadi on 23/05/16.
//  Copyright © 2016 Kore. All rights reserved.
//

import UIKit

enum SignInType : Int {
    case authenticatedUser = 0
    case anonymousUser = 1
    case none = 2
}

open class BotClient: NSObject, RTMPersistentConnectionDelegate {
    
    // MARK: properties
    fileprivate var connection: RTMPersistentConnection! = nil
    fileprivate var token: String! = nil
    fileprivate var clientId: String! = nil
    fileprivate var botInfoParameters: NSDictionary! = nil
    fileprivate var authInfoModel: AuthInfoModel! = nil
    fileprivate var userInfoModel: UserModel! = nil
    fileprivate var reconnecting = false
    fileprivate var currentReconnectAttempt = 0
    fileprivate(set) var reconnectAttempts = 5
    
    fileprivate var reconnects = false
    fileprivate var reconnectWait = 10
    
    fileprivate var signInType: SignInType = .none
    
    open var connectionWillOpen: ((Void) -> Void)!
    open var connectionDidOpen: ((Void) -> Void)!
    open var onConnectionError: ((NSError) -> Void)!
    open var onMessage: ((BotMessageModel?) -> Void)!
    open var onMessageAck: ((Ack?) -> Void)!
    open var connectionDidClose: ((Int, String) -> Void)!
    open var connectionDidEnd: ((Int, String, NSError) -> Void)!
    
    fileprivate var successClosure: ((BotClient?) -> Void)!
    fileprivate var failureClosure: ((NSError) -> Void)!
    
    // MARK: init
    public convenience init(botInfoParameters: NSDictionary!) {
        self.init()
        self.botInfoParameters = botInfoParameters
    }
    
    // MARK:
    fileprivate func connect() {
        if (self.authInfoModel == nil) {
            switch self.signInType {
            case .authenticatedUser:
                self.connectAsAuthenticatedUser(token, success: { [weak self] (client) in
                    if (self!.successClosure != nil) {
                        self!.successClosure(client)
                    }
                    }, failure: { [weak self] (error) in
                        self!.reconnecting = false
                        if (self?.failureClosure != nil) {
                            self?.failureClosure?(NSError(domain: "RTM", code: 0, userInfo: error._userInfo as! [AnyHashable : Any]?))
                        }
                })
                break
            case .anonymousUser:
                self.connectAsAnonymousUser(clientId, success: { [weak self] (client) in
                    if (self!.successClosure != nil) {
                        self!.successClosure(client)
                    }
                    }, failure: { [weak self] (error) in
                        self!.reconnecting = false
                        if (self!.failureClosure != nil) {
                            self!.failureClosure(NSError(domain: "RTM", code: 0, userInfo: error.userInfo))
                        }
                })
                break
            case .none:
                self.reconnecting = false
                if (self.failureClosure != nil) {
                    self.failureClosure(NSError(domain: "RTM", code: 0, userInfo: [:]))
                }
                break
            }
        } else {
            let requestManager: HTTPRequestManager = HTTPRequestManager.sharedManager
            requestManager.getRtmUrlWithAuthInfoModel(self.authInfoModel, botInfo: self.botInfoParameters, success: { (botInfo) in
                self.connection = self.rtmConnectionWithBotInfoModel(botInfo!, isReconnect: self.reconnects)
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
    
    open func reconnect() {
        if self.reconnecting == false {
            self.reconnecting = true
            connect()
        }
    }
    
    fileprivate func tryReconnect() {
        if reconnecting == true {
            return
        }
        
        if currentReconnectAttempt + 1 > reconnectAttempts {
            if (self.connectionDidClose != nil) {
                self.connectionDidClose(100, "Reconnect Failed")
                if (self.failureClosure != nil) {
                    self.failureClosure(NSError(domain: "RTM", code: 0, userInfo: ["message": "connection timed-out"]))
                }
            }
            return
        }
        
        currentReconnectAttempt += 1
        reconnect()
        
        let dispatchAfter = DispatchTime(uptimeNanoseconds: UInt64(reconnectWait) * NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: dispatchAfter) {
            self.tryReconnect()
        }
    }
    
    open func disconnect() {
        if self.connection != nil {
            self.connection.disconnect()
        }
    }
    
    // MARK: make connection
    open func connectAsAuthenticatedUser(_ token: String!, success:((BotClient?) -> Void)?, failure:((Error) -> Void)?)  {
        self.signInType = .authenticatedUser
        self.token = token
        
        var rtmError: Error!
        var rtmBotInfoModel: BotInfoModel!
        var status: Bool = true
        var isReconnect = false
        
        if (self.successClosure == nil) {
            self.successClosure = success as ((BotClient?) -> Void)!
        }
        if (self.failureClosure == nil) {
            self.failureClosure = failure
        }
        
        let group: DispatchGroup  = DispatchGroup()
        let requestManager: HTTPRequestManager = HTTPRequestManager.sharedManager
        
        group.enter() // -- 1
        
        if (self.authInfoModel == nil) {
            group.enter() // -- 2
            requestManager.authorizeWithToken(token, botInfo: self.botInfoParameters, success: { (jwToken) in
                
                group.enter() // -- 3
                requestManager.signInWithToken(jwToken as AnyObject!, botInfo: self.botInfoParameters, success: { [weak self] (user, authInfo) in
                    self?.authInfoModel = authInfo
                    self?.userInfoModel = user
                    
                    group.leave() // -- 3
                    
                    }, failure: { (error) in
                        status = status && false
                        rtmError = error
                        group.leave() // -- 3
                })
                group.leave() // -- 2
            }) { (error) in
                status = status && false
                rtmError = error
                group.leave() // -- 2
            }
        } else {
            isReconnect = true
        }
        
        group.leave() // -- 1
        group.notify(queue: DispatchQueue.main, execute: {
            if (rtmError != nil && !status) {
                if (failure != nil) {
                    failure!(rtmError)
                }
            } else {
                self.connect()
            }
        })
    }
    
    open func connectAsAnonymousUser(_ clientId: String!,  success:((BotClient?) -> Void)?, failure:((NSError) -> Void)?)  {
        self.signInType = .anonymousUser
        self.clientId = clientId

        var rtmError: NSError!
        var rtmBotInfoModel: BotInfoModel!
        var status: Bool = true
        var isReconnect = false
        
        if (self.successClosure == nil) {
            self.successClosure = success
        }
        if (self.failureClosure == nil) {
            self.failureClosure = failure
        }
        
        self.anonymousUserSignIn(clientId, success: { (user, authInfo) in
            self.authInfoModel = authInfo
            self.userInfoModel = user
            self.connect()
            }, failure: { (error) in
                if (failure != nil) {
                    failure!(error)
                }
        })
    }
    
    // MARK: WebSocketDelegate methods
    open func rtmConnectionWillOpen() {
        self.currentReconnectAttempt = 0
        self.reconnects = true
        self.reconnecting = false
    }
    
    open func rtmConnectionDidOpen() {
        if (self.connectionDidOpen != nil) {
            self.connectionDidOpen()
        }
    }
    
    open func rtmConnectionDidClose(_ code: Int, reason: String) {
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
    
    open func rtmConnectionDidEnd(_ code: Int, reason: String, wasClean: Bool, error: NSError?) {
        self.reconnecting = false
        if (self.connectionDidEnd != nil) {
            self.connectionDidEnd(code, reason, NSError(domain: "", code: 0, userInfo: [:]))
        }
    }
    
    // MARK: functions
    fileprivate func rtmConnectionWithBotInfoModel(_ botInfo: BotInfoModel, isReconnect: Bool) -> RTMPersistentConnection {
        if (self.connection != nil && (self.connection.connectionStatus == .open || self.connection.connectionStatus == .connecting)) {
            return self.connection
        } else {
            let rtmConnection: RTMPersistentConnection = RTMPersistentConnection(botInfo: botInfo, botInfoParameters: self.botInfoParameters, tryReconnect: isReconnect)
            rtmConnection.connectionDelegate = self
            rtmConnection.start()
            return rtmConnection
        }
    }
    
    open func sendMessage(_ message: String!, options: AnyObject!) {
        if (self.connection == nil) {

        } else {
            switch self.connection.connectionStatus {
            case .open:
                self.connection.sendMessageModel(message, options: [] as AnyObject?)
                break
            default:
                break
            }
        }
    }
    
    // MARK: anonymous user sign-in
    open func anonymousUserSignIn(_ clientId: String!, success:((UserModel?, AuthInfoModel?) -> Void)?, failure:((NSError) -> Void)?) {
        let requestManager: HTTPRequestManager = HTTPRequestManager.sharedManager
        requestManager.anonymousUserSignIn(clientId, success: success, failure: failure)
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
}
