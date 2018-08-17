//
//  KoreRTMClient.swift
//  KoreBotSDK
//
//  Created by developer@kore.com on 21/05/16.
//  Copyright © 2016 Kore Inc. All rights reserved.
//

import UIKit
import Starscream
import Mantle

@objc public protocol RTMPersistentConnectionDelegate {
    func rtmConnectionDidOpen()
    func rtmConnectionReady()
    func rtmConnectionDidClose(_ code: Int, reason: String)
    func rtmConnectionDidFailWithError(_ error: NSError)
    @objc optional func didReceiveMessage(_ message: BotMessageModel)
    @objc optional func didReceiveMessageAck(_ ack: Ack)
}

open class RTMPersistentConnection : NSObject, WebSocketDelegate, WebSocketPongDelegate {

    var botInfo: BotInfoModel!
    fileprivate var botInfoParameters: NSDictionary! = nil
    private(set) public var socket: WebSocket?
    var connectionDelegate: RTMPersistentConnectionDelegate?

    fileprivate let timerSource: DispatchSourceTimer
    fileprivate let pingInterval: TimeInterval
    fileprivate var receivedLastPong = true
    open var tryReconnect = false
    
    // MARK: init
    public init(botInfo: BotInfoModel!, botInfoParameters: NSDictionary!, tryReconnect: Bool) {
        self.pingInterval = 10
        self.timerSource = DispatchSource.makeTimerSource(flags: [], queue: .main)
        super.init()
        self.botInfo = botInfo
        self.botInfoParameters = botInfoParameters
        self.tryReconnect = tryReconnect
    }
    
    open func start() {
        var url: String = self.botInfo.botUrl!
        if (self.tryReconnect == true) {
            url.append("&isReconnect=true")
        }
        
        socket = WebSocket(url: URL(string: url)!)
        socket?.delegate = self
        socket?.pongDelegate = self
        socket?.connect()
    }
    
    open func disconnect() {
        if let socket = socket {
            socket.disconnect()
        }
    }
    
    // MARK: WebSocketDelegate methods
    public func websocketDidConnect(socket: WebSocketClient) {
        self.connectionDelegate?.rtmConnectionDidOpen()
        let intervalInNSec = pingInterval * Double(NSEC_PER_SEC)
        let startTime = DispatchTime.now() + Double(intervalInNSec) / Double(NSEC_PER_SEC)
        
        timerSource.scheduleRepeating(deadline: startTime, interval: pingInterval, leeway: .nanoseconds(Int(NSEC_PER_SEC / 10)))
        timerSource.setEventHandler { [unowned self] in
            
            guard let socket = self.socket else {
                return
            }
            if self.receivedLastPong == false {
                // we did not receive the last pong
                // abort the socket so that we can spin up a new connection
                socket.disconnect()
            } else if !socket.isConnected {
                socket.disconnect()
            } else {
                // we got a pong recently
                // send another ping
                self.receivedLastPong = false
                socket.write(ping: Data())
            }
        }
        timerSource.resume()
    }
    
    public func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        if let error = error as NSError? {
        self.connectionDelegate?.rtmConnectionDidFailWithError(error)
        }
        else {
            self.connectionDelegate?.rtmConnectionDidClose(0, reason: "unknown")
        }
        
    }
    
    public func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        processMessage(text)
    }
    
    public func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        if let text = String(data: data, encoding: .utf8) {
            processMessage(text)
        }
    }
    
    public func websocketDidReceivePong(socket: WebSocketClient, data: Data?) {
        self.receivedLastPong = true
    }


    private func processMessage (_ text: String) {
        
        guard let responseObject = self.convertStringToDictionary(text) else {
            return
        }
        
        guard let type = responseObject["type"] as? String else {
            return
        }
        
        if (type == "ready") {
            self.connectionDelegate?.self.rtmConnectionReady()
        }
        else if (responseObject["ok"] != nil) {
            let ack: Ack = try! (MTLJSONAdapter.model(of: Ack.self, fromJSONDictionary: responseObject ) as! Ack)
            self.connectionDelegate?.didReceiveMessageAck!(ack)
        }
        else if (type == "bot_response") {
            print("received: \(responseObject)")
            
            if let message = responseObject["message"] as? NSArray {
                if (message.count > 0) {
                let botMessageModel: BotMessageModel = try! (MTLJSONAdapter.model(of: BotMessageModel.self, fromJSONDictionary: responseObject ) as! BotMessageModel)
                self.connectionDelegate?.didReceiveMessage!(botMessageModel)
            }
        }
    }
    }
    
    // MARK: sending message
    open func sendMessageModel(_ message: String, options: AnyObject?) {
        
        guard let socket = socket else {
            print("Socket is not initialised")
            start()
            return
        }
        
        if socket.isConnected {
            print("Socket is connected")
            let parameters: NSMutableDictionary = NSMutableDictionary()
            let messageObject = ["body":message, "attachments":[]] as [String : Any];
            parameters.setObject(messageObject, forKey: "message" as NSCopying)
            parameters.setObject("/bot.message", forKey: "resourceid" as NSCopying)
            if (botInfoParameters != nil) {
                parameters.setObject(botInfoParameters, forKey: "botInfo" as NSCopying)
            }
            let uuid: String = Constants.getUUID()
            parameters.setObject(uuid, forKey: "id" as NSCopying)
            parameters.setObject(uuid, forKey: "clientMessageId" as NSCopying)
            print("send: \(parameters)")

            var error : NSError?
            let jsonData = try! JSONSerialization.data(withJSONObject: parameters, options: JSONSerialization.WritingOptions.prettyPrinted)
            socket.write(data: jsonData)
        }
        else {
            print("Socket is not connected")
            start()
        }

    }
    
    // MARK: helpers
    func convertStringToDictionary(_ text: String) -> [String:AnyObject]? {
        if let data = text.data(using: String.Encoding.utf8) {
            do {
                return try! JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject]
            } catch let error as NSError {
                print(error)
            }
        }
        return nil
    }
}
