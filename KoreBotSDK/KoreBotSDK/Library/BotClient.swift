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
    public var onConnectionError: ((NSError) -> Void)!
    public var onMessage: ((BotMessageModel?) -> Void)!
    public var onMessageAck: ((Ack?) -> Void)!
    public var connectionDidClose: ((Int, String) -> Void)!
    public var connectionDidEnd: ((Int, String, NSError) -> Void)!
    
    private var successClosure: ((BotClient?) -> Void)!
    private var failureClosure: ((NSError) -> Void)!
    
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
                self.connectAsAuthenticatedUser(token: token, success: { [weak self] (client) in
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
            case .AnonymousUser:
                self.connectAsAnonymousUser(clientId: clientId, success: { [weak self] (client) in
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
            case .None:
                self.reconnecting = false
                if (self.failureClosure != nil) {
                    self.failureClosure(NSError(domain: "RTM", code: 0, userInfo: [:]))
                }
                break
            }
        } else {
            let requestManager: HTTPRequestManager = HTTPRequestManager.sharedManager
            requestManager.getRtmUrlWithAuthInfoModel(authInfo: self.authInfoModel, botInfo: self.botInfoParameters, success: { (botInfo) in
                self.connection = self.rtmConnectionWithBotInfoModel(botInfo: botInfo!, isReconnect: self.reconnects)
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
    
    public func disconnect() {
        if self.connection != nil {
            self.connection.disconnect()
        }
    }
    
    // MARK: make connection
    public func connectAsAuthenticatedUser(token: String!, success:((BotClient?) -> Void)?, failure:((Error) -> Void)?)  {
        self.signInType = .AuthenticatedUser
        self.token = token
        
        var rtmError: Error!
        var rtmBotInfoModel: BotInfoModel!
        var status: Bool = true
        var isReconnect = false
        
        if (self.successClosure == nil) {
            self.successClosure = success as! ((BotClient?) -> Void)!
        }
        if (self.failureClosure == nil) {
            self.failureClosure = failure
        }
        
        let group: DispatchGroup  = DispatchGroup()
        let requestManager: HTTPRequestManager = HTTPRequestManager.sharedManager
        
        group.enter() // -- 1
        
        if (self.authInfoModel == nil) {
            group.enter() // -- 2
            requestManager.authorizeWithToken(accessToken: token, botInfo: self.botInfoParameters, success: { (jwToken) in
                
                group.enter() // -- 3
                requestManager.signInWithToken(token: jwToken as AnyObject!, botInfo: self.botInfoParameters, success: { [weak self] (user, authInfo) in
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
    
    public func connectAsAnonymousUser(clientId: String!,  success:((BotClient?) -> Void)?, failure:((NSError) -> Void)?)  {
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
        
        self.anonymousUserSignIn(clientId: clientId, success: { (user, authInfo) in
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
                self.connectionDidClose(code, reason)
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
    
    public func didReceiveMessage(message: BotMessageModel) {
        if (self.onMessage != nil) {
            self.onMessage(message)
        }
    }
    public func didReceiveMessageAck(ack: Ack) {
        if (self.onMessageAck != nil) {
            self.onMessageAck(ack)
        }
    }
    
    public func rtmConnectionDidEnd(code: Int, reason: String, wasClean: Bool, error: NSError?) {
        self.reconnecting = false
        if (self.connectionDidEnd != nil) {
            self.connectionDidEnd(code, reason, NSError(domain: "", code: 0, userInfo: [:]))
        }
    }
    
    // MARK: functions
    private func rtmConnectionWithBotInfoModel(botInfo: BotInfoModel, isReconnect: Bool) -> RTMPersistentConnection {
        if (self.connection != nil && (self.connection.connectionStatus == .open || self.connection.connectionStatus == .connecting)) {
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
            case .open:
                self.connection.sendMessageModel(message: message, options: [] as AnyObject?)
                break
            default:
                break
            }
        }
    }
    
    // MARK: anonymous user sign-in
    public func anonymousUserSignIn(clientId: String!, success:((UserModel?, AuthInfoModel?) -> Void)?, failure:((NSError) -> Void)?) {
        let requestManager: HTTPRequestManager = HTTPRequestManager.sharedManager
        requestManager.anonymousUserSignIn(clientId: clientId, success: success, failure: failure)
    }
    
    // MARK: subscribe/ unsubscribe to push notifications
    public func subscribeToNotifications(deviceToken: NSData!, success:((Bool) -> Void)?, failure:((NSError) -> Void)?) {
        let requestManager: HTTPRequestManager = HTTPRequestManager.sharedManager
        requestManager.subscribeToNotifications(deviceToken: deviceToken as Data!, userInfo: self.userInfoModel, authInfo: self.authInfoModel, success: success, failure: failure as! ((Error) -> Void)?)
    }
    
    public func unsubscribeToNotifications(deviceToken: NSData!, success:((Bool) -> Void)?, failure:((NSError) -> Void)?) {
        let requestManager: HTTPRequestManager = HTTPRequestManager.sharedManager
        requestManager.unsubscribeToNotifications(deviceToken: deviceToken as Data!, userInfo: self.userInfoModel, authInfo: self.authInfoModel, success: success, failure: failure as! ((Error) -> Void)?)
    }
}
