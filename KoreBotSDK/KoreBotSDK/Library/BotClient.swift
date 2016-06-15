//
//  KoreBot.swift
//  KoreBotSDK
//
//  Created by Srinivas Vasadi on 23/05/16.
//  Copyright © 2016 Kore. All rights reserved.
//

import UIKit

enum SignInType : Int {
    case AuthenticatedUser = 0
    case AnonymousUser = 1
    case None = 2
}

public class BotClient: NSObject, RTMPersistentConnectionDelegate {
    
    // MARK: properties
    private var connection: RTMPersistentConnection! = nil
    private var token: String! = nil
    private var clientId: String! = nil
    private var botInfoParameters: NSDictionary! = nil
    private var authInfoModel: AuthInfoModel! = nil
    private var userInfoModel: UserModel! = nil
    private var reconnecting = false
    private var currentReconnectAttempt = 0
    private(set) var reconnectAttempts = 5
    
    private var reconnects = false
    private var reconnectWait = 10
    
    private var signInType: SignInType = .None
    
    public var connectionWillOpen: ((Void) -> Void)!
    public var connectionDidOpen: ((Void) -> Void)!
    public var onConnectionError: ((error: NSError) -> Void)!
    public var onMessage: ((message: BotMessageModel!) -> Void)!
    public var onMessageAck: ((ack: Ack!) -> Void)!
    public var connectionDidClose: ((code: Int, reason: String) -> Void)!
    public var connectionDidEnd: ((code: Int, reason: String, error: NSError) -> Void)!
    
    private var successClosure: ((botClient: BotClient!) -> Void)!
    private var failureClosure: ((error: NSError) -> Void)!
    
    // MARK: init
    public convenience init(botInfoParameters: NSDictionary!) {
        self.init()
        self.botInfoParameters = botInfoParameters
    }
    
    // MARK:
    private func connect() {
        if (self.authInfoModel == nil) {
            switch self.signInType {
            case .AuthenticatedUser:
                self.connectAsAuthenticatedUser(token, success: { [weak self] (client) in
                    if (self!.successClosure != nil) {
                        self!.successClosure(botClient: client)
                    }
                    }, failure: { [weak self] (error) in
                        self!.reconnecting = false
                        if (self!.failureClosure != nil) {
                            self!.failureClosure(error: NSError(domain: "RTM", code: 0, userInfo: error.userInfo))
                        }
                })
                break
            case .AnonymousUser:
                self.connectAsAnonymousUser(clientId, success: { [weak self] (client) in
                    if (self!.successClosure != nil) {
                        self!.successClosure(botClient: client)
                    }
                    }, failure: { [weak self] (error) in
                        self!.reconnecting = false
                        if (self!.failureClosure != nil) {
                            self!.failureClosure(error: NSError(domain: "RTM", code: 0, userInfo: error.userInfo))
                        }
                })
                break
            case .None:
                self.reconnecting = false
                if (self.failureClosure != nil) {
                    self.failureClosure(error: NSError(domain: "RTM", code: 0, userInfo: [:]))
                }
                break
            }
        } else {
            let requestManager: HTTPRequestManager = HTTPRequestManager.sharedManager
            requestManager.getRtmUrlWithAuthInfoModel(self.authInfoModel, botInfo: self.botInfoParameters, success: { (botInfo) in
                self.connection = self.rtmConnectionWithBotInfoModel(botInfo, isReconnect: self.reconnects)
                if (self.reconnects == false) {
                    if (self.successClosure != nil) {
                        self.successClosure(botClient: self)
                    }
                }
                }, failure: { (error) in
                    self.reconnecting = false
                    self.tryReconnect()
            })
        }
    }
    
    public func reconnect() {
        if self.reconnecting == false {
            self.reconnecting = true
            connect()
        }
    }
    
    private func tryReconnect() {
        if reconnecting == true {
            return
        }
        
        if currentReconnectAttempt + 1 > reconnectAttempts {
            if (self.connectionDidClose != nil) {
                self.connectionDidClose(code: 100, reason: "Reconnect Failed")
                if (self.failureClosure != nil) {
                    self.failureClosure(error: NSError(domain: "RTM", code: 0, userInfo: ["message": "connection timed-out"]))
                }
            }
            return
        }
        
        currentReconnectAttempt += 1
        reconnect()
        
        let dispatchAfter = dispatch_time(DISPATCH_TIME_NOW, Int64(UInt64(reconnectWait) * NSEC_PER_SEC))
        dispatch_after(dispatchAfter, dispatch_get_main_queue(), tryReconnect)
    }
    
    public func disconnect() {
        if self.connection != nil {
            self.connection.disconnect()
        }
    }
    
    // MARK: make connection
    public func connectAsAuthenticatedUser(token: String!, success:((botClient: BotClient!) -> Void)?, failure:((error: NSError) -> Void)?)  {
        self.signInType = .AuthenticatedUser
        self.token = token
        
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
        
        let group: dispatch_group_t  = dispatch_group_create()
        let requestManager: HTTPRequestManager = HTTPRequestManager.sharedManager
        
        dispatch_group_enter(group) // -- 1
        
        if (self.authInfoModel == nil) {
            dispatch_group_enter(group) // -- 2
            requestManager.authorizeWithToken(token, botInfo: self.botInfoParameters, success: { (jwToken) in
                
                dispatch_group_enter(group) // -- 3
                requestManager.signInWithToken(jwToken, botInfo: self.botInfoParameters, success: { [weak self] (user, authInfo) in
                    self?.authInfoModel = authInfo
                    self?.userInfoModel = user
                    
                    dispatch_group_leave(group) // -- 3
                    
                    }, failure: { (error) in
                        status = status && false
                        rtmError = error
                        dispatch_group_leave(group) // -- 3
                })
                dispatch_group_leave(group) // -- 2
            }) { (error) in
                status = status && false
                rtmError = error
                dispatch_group_leave(group) // -- 2
            }
        } else {
            isReconnect = true
        }
        
        dispatch_group_leave(group) // -- 1
        
        dispatch_group_notify(group, dispatch_get_main_queue(), {
            if (rtmError != nil && !status) {
                if (failure != nil) {
                    failure!(error: rtmError)
                }
            } else {
                self.connect()
            }
        })
    }
    
    public func connectAsAnonymousUser(clientId: String!,  success:((botClient: BotClient!) -> Void)?, failure:((error: NSError) -> Void)?)  {
        self.signInType = .AnonymousUser
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
                    failure!(error: error)
                }
        })
    }
    
    // MARK: WebSocketDelegate methods
    public func rtmConnectionWillOpen() {
        self.currentReconnectAttempt = 0
        self.reconnects = true
        self.reconnecting = false
    }
    
    public func rtmConnectionDidOpen() {
        if (self.connectionDidOpen != nil) {
            self.connectionDidOpen()
        }
    }
    
    public func rtmConnectionDidClose(code: Int, reason: String) {
        switch code {
        case 1000:
            if (self.connectionDidClose != nil) {
                self.connectionDidClose(code: code, reason: reason)
            }
            break
        default:
            self.reconnect()
            break
        }
    }
    
    public func rtmConnectionDidFailWithError(error: NSError) {
        self.reconnecting = false
    }
    
    public func didReceiveMessage(messageModel: BotMessageModel) {
        if (self.onMessage != nil) {
            self.onMessage(message: messageModel)
        }
    }
    
    public func didReceiveMessageAck(ack: Ack) {
        if (self.onMessageAck != nil) {
            self.onMessageAck(ack: ack)
        }
    }
    
    public func rtmConnectionDidEnd(code: Int, reason: String, wasClean: Bool, error: NSError?) {
        self.reconnecting = false
        if (self.connectionDidEnd != nil) {
            self.connectionDidEnd(code: code, reason: reason, error: NSError(domain: "", code: 0, userInfo: [:]))
        }
    }
    
    // MARK: functions
    private func rtmConnectionWithBotInfoModel(botInfo: BotInfoModel, isReconnect: Bool) -> RTMPersistentConnection {
        if (self.connection != nil && (self.connection.connectionStatus == .Open || self.connection.connectionStatus == .Connecting)) {
            return self.connection
        } else {
            let rtmConnection: RTMPersistentConnection = RTMPersistentConnection(botInfo: botInfo, botInfoParameters: self.botInfoParameters, tryReconnect: isReconnect)
            rtmConnection.connectionDelegate = self
            rtmConnection.start()
            return rtmConnection
        }
    }
    
    public func sendMessage(message: String!, options: AnyObject!) {
        if (self.connection == nil) {

        } else {
            switch self.connection.connectionStatus {
            case .Open:
                self.connection.sendMessageModel(message, options: [])
                break
            default:
                break
            }
        }
    }
    
    // MARK: anonymous user sign-in
    public func anonymousUserSignIn(clientId: String!, success:((user: UserModel!, authInfo: AuthInfoModel!) -> Void)?, failure:((error: NSError) -> Void)?) {
        let requestManager: HTTPRequestManager = HTTPRequestManager.sharedManager
        requestManager.anonymousUserSignIn(clientId, success: success, failure: failure)
    }
    
    // MARK: subscribe/ unsubscribe to push notifications
    public func subscribeToNotifications(deviceToken: NSData!, success:((staus: Bool) -> Void)?, failure:((error: NSError) -> Void)?) {
        let requestManager: HTTPRequestManager = HTTPRequestManager.sharedManager
        requestManager.subscribeToNotifications(deviceToken, userInfo: self.userInfoModel, authInfo: self.authInfoModel, success: success, failure: failure)
    }
    
    public func unsubscribeToNotifications(deviceToken: NSData!, success:((staus: Bool) -> Void)?, failure:((error: NSError) -> Void)?) {
        let requestManager: HTTPRequestManager = HTTPRequestManager.sharedManager
        requestManager.unsubscribeToNotifications(deviceToken, userInfo: self.userInfoModel, authInfo: self.authInfoModel, success: success, failure: failure)
    }
}
