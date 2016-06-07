//
//  KoreBot.swift
//  KoreBotSDK
//
//  Created by Srinivas Vasadi on 23/05/16.
//  Copyright © 2016 Kore. All rights reserved.
//

import UIKit

public class BotClient: NSObject, RTMPersistentConnectionDelegate {
    
    // MARK: properties
    public var connection: RTMPersistentConnection! = nil
    private var token: String! = nil
    private var botInfoParameters: NSDictionary! = nil
    private var authInfoModel: AuthInfoModel! = nil
    private var userInfoModel: UserModel! = nil
    private var reconnecting = false
    private var currentReconnectAttempt = 0
    private(set) var currentAck = -1
    private(set) var reconnectAttempts = -1

    public var reconnects = true
    public var reconnectWait = 10

    public var connectionWillOpen: ((Void) -> Void)!
    public var connectionDidOpen: ((Void) -> Void)!
    public var onConnectionError: ((error: NSError) -> Void)!
    public var onMessage: ((message: BotMessageModel!) -> Void)!
    public var onMessageAck: ((ack: Ack!) -> Void)!
    public var connectionDidClose: ((code: Int, reason: String) -> Void)!
    public var connectionDidEnd: ((code: Int, reason: String, error: NSError) -> Void)!
    
    // MARK: init
    public convenience init(token: String!, botInfoParameters: NSDictionary!) {
        self.init()
        self.token = token
        self.botInfoParameters = botInfoParameters
    }
    // MARK:
    public func connect() {
        self.rtmConnection({ [weak self] (connection) in
            self!.connection = connection
            }, failure: { (error) in
                self.tryReconnect()
        })
    }
    
    public func reconnect() {
        if self.reconnecting == false {
            self.reconnecting = true
            connect()
        }
    }
    
    private func tryReconnect() {
        if !reconnecting {
            return
        }
        
        if reconnectAttempts != -1 && currentReconnectAttempt + 1 > reconnectAttempts || !reconnects {
            if (self.connectionDidClose != nil) {
                self.connectionDidClose(code: 100, reason: "Reconnect Failed")
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
    public func rtmConnection(success:((connection: RTMPersistentConnection!) -> Void)?, failure:((error: NSError) -> Void)?)  {
        
        var rtmError: NSError!
        var rtmBotInfoModel: BotInfoModel!
        var status: Bool = true
        var isReconnect = false
        
        let group: dispatch_group_t  = dispatch_group_create()
        let requestManager: HTTPRequestManager = HTTPRequestManager.sharedManager

        dispatch_group_enter(group) // -- 1
        
        if (self.authInfoModel == nil) {
            dispatch_group_enter(group) // -- 2
            requestManager.authorizeWithToken(token, success: { (jwToken) in
                
                dispatch_group_enter(group) // -- 3
                requestManager.signInWithToken(jwToken, success: { [weak self] (user, authInfo) in
                    self?.authInfoModel = authInfo
                    self?.userInfoModel = user

                    dispatch_group_enter(group) // -- 4
                    requestManager.getRtmUrlWithAuthInfoModel(authInfo, botInfo: self?.botInfoParameters, success: { [weak self] (botInfo) in
                        rtmBotInfoModel = botInfo
                        dispatch_group_leave(group) // -- 4
                        
                        }, failure: { (error) in
                            status = status && false
                            rtmError = error
                            dispatch_group_leave(group) // -- 4
                    })
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
            dispatch_group_enter(group) // -- 2
            requestManager.getRtmUrlWithAuthInfoModel(self.authInfoModel, botInfo: self.botInfoParameters, success: { [weak self] (botInfo) in
                rtmBotInfoModel = botInfo
                dispatch_group_leave(group) // -- 2
                
                }, failure: { (error) in
                    status = status && false
                    rtmError = error
                    dispatch_group_leave(group) // -- 2
            })
        }
        dispatch_group_leave(group) // -- 1
        
        dispatch_group_notify(group, dispatch_get_main_queue(), {
            if (rtmError != nil && !status) {
                if (failure != nil) {
                    failure!(error: rtmError)
                }
            } else {
                if (success != nil) {
                    self.connection = self.rtmConnectionWithBotInfoModel(rtmBotInfoModel, isReconnect: isReconnect)
                    success!(connection: self.connection)
                }
            }
        })
    }
    
    // MARK: WebSocketDelegate methods
    
    public func rtmConnectionWillOpen() {
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
    public static func anonymousUserSignIn(clientId: String!, success:((user: UserModel!, authInfo: AuthInfoModel!) -> Void)?, failure:((error: NSError) -> Void)?) {
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
