//
//  KoreRTMClient.swift
//  KoreBotSDK
//
//  Created by developer@kore.com on 21/05/16.
//  Copyright © 2016 Kore Inc. All rights reserved.
//

import UIKit
import SocketRocket
import Mantle

@objc public protocol RTMPersistentConnectionDelegate {
    func rtmConnectionDidOpen()
    func rtmConnectionReady()
    func rtmConnectionDidClose(_ code: Int, reason: String?)
    func rtmConnectionDidFailWithError(_ error: NSError)
    @objc optional func didReceiveMessage(_ message: BotMessageModel)
    @objc optional func didReceiveMessageAck(_ ack: Ack)
}

open class RTMTimer: NSObject {
    public enum RTMTimerState {
        case suspended
        case resumed
    }
    open let pingInterval: TimeInterval = 30.0
    open lazy var timer: DispatchSourceTimer = {
        let intervalInNSec = pingInterval * Double(NSEC_PER_SEC)
        let startTime = DispatchTime.now() + Double(intervalInNSec) / Double(NSEC_PER_SEC)

        let t = DispatchSource.makeTimerSource(flags: [], queue: .main)
        t.schedule(deadline: startTime, repeating: pingInterval)
        t.setEventHandler(handler: { [weak self] in
            self?.eventHandler?()
        })
        return t
    }()
    
    open var eventHandler: (() -> Void)?
    open var state: RTMTimerState = .suspended
    
    open func resume() {
        if state == .resumed {
            return
        }
        state = .resumed
        timer.resume()
    }
    
    open func suspend() {
        if state == .suspended {
            return
        }
        state = .suspended
        timer.suspend()
    }
    
    // MARK: -
    deinit {
        timer.setEventHandler {}
        timer.cancel()
        
        resume()
        eventHandler = nil
    }
}

open class RTMPersistentConnection : NSObject, SRWebSocketDelegate {
    var botInfo: BotInfoModel!
    fileprivate var botInfoParameters: [String: Any]?
    var websocket: SRWebSocket! = nil
    var connectionDelegate: RTMPersistentConnectionDelegate?

    fileprivate var timerSource = RTMTimer()
    fileprivate let pingInterval: TimeInterval
    fileprivate var receivedLastPong = true
    open var tryReconnect = false
    
    // MARK: init
    public init(botInfo: BotInfoModel, botInfoParameters: [String: Any]?, tryReconnect: Bool) {
        self.pingInterval = 30.0
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
        self.websocket = SRWebSocket(urlRequest: URLRequest(url: URL(string: url)! as URL) as URLRequest?)
        self.websocket.delegate = self
        self.websocket.open()
    }
    
    open func disconnect() {
        if (self.websocket != nil) {
            self.websocket.close()
        }
    }
    
    // MARK: WebSocketDelegate methods
    open func webSocketDidOpen(_ webSocket: SRWebSocket!) {
        self.connectionDelegate?.rtmConnectionDidOpen()

        timerSource.eventHandler = { [weak self] in
            if self?.receivedLastPong == false {
                // we did not receive the last pong
                // abort the socket so that we can spin up a new connection
                // self.websocket.close()
                // self.timerSource.suspend()
                // self.connectionDelegate?.rtmConnectionDidFailWithError(NSError())
            } else if self?.websocket.readyState == .CLOSED || self?.websocket.readyState == .CLOSING {
                self?.websocket.close()
                self?.timerSource.suspend()
            } else if self?.websocket.readyState == .OPEN {
                
                // we got a pong recently
                // send another ping
                self?.receivedLastPong = false
                self?.websocket.sendPing(nil)
            }
        }
        timerSource.resume()
    }
    
    open func webSocket(_ webSocket: SRWebSocket!, didFailWithError error: Error!) {
        self.connectionDelegate?.rtmConnectionDidFailWithError(error! as NSError)
    }
    
    public func webSocket(_ webSocket: SRWebSocket!, didCloseWithCode code: Int, reason: String!, wasClean: Bool) {
        self.connectionDelegate?.rtmConnectionDidClose(code, reason: reason)
    }

    open func webSocket(_ webSocket: SRWebSocket!, didReceivePong pongPayload: Data!) {
        self.receivedLastPong = true
    }

    open func webSocket(_ webSocket: SRWebSocket!, didReceiveMessage message: Any!) {
        let responseObject = self.convertStringToDictionary(message as! String)!
        if (responseObject["type"]! as!  String == "ready") {
            self.connectionDelegate?.self.rtmConnectionReady()
        } else if (responseObject["ok"] != nil) {
            let ack: Ack = try! (MTLJSONAdapter.model(of: Ack.self, fromJSONDictionary: responseObject ) as! Ack)
            self.connectionDelegate?.didReceiveMessageAck!(ack)
        } else if (responseObject["type"]! as! String == "bot_response") {
            print("received: \(responseObject)")
            let array: NSArray = responseObject["message"] as! NSArray
            if (array.count > 0) {
                let botMessageModel: BotMessageModel = try! (MTLJSONAdapter.model(of: BotMessageModel.self, fromJSONDictionary: responseObject ) as! BotMessageModel)
                self.connectionDelegate?.didReceiveMessage!(botMessageModel)
            }
        }
    }
    
    open func webSocketShouldConvertTextFrameToString() -> ObjCBool {
        return true
    }
    
    // MARK: sending message
    open func sendMessage(_ message: String, parameters: [String: Any], options: [String: Any]?) {
        switch (self.websocket.readyState) {
        case .CONNECTING:
            print("Socket is in CONNECTING state")
            break
        case .CLOSED:
            self.start()
            print("Socket is in CLOSED state")
            break
        case .CLOSING:
            print("Socket is in CLOSING state")
            break
        case .OPEN:
            print("Socket is in OPEN state")
            let dictionary: NSMutableDictionary = NSMutableDictionary()
            let messageObject: NSMutableDictionary = NSMutableDictionary()
            messageObject.addEntries(from: ["body": message, "attachments":[], "customData": parameters] as [String : Any])
            if let object = options {
                messageObject.addEntries(from: object)
            }
            
            dictionary.setObject(messageObject, forKey: "message" as NSCopying)
            dictionary.setObject("/bot.message", forKey: "resourceid" as NSCopying)
            if (self.botInfoParameters != nil) {
                dictionary.setObject(self.botInfoParameters, forKey: "botInfo" as NSCopying)
            }
            let uuid: String = Constants.getUUID()
            dictionary.setObject(uuid, forKey: "id" as NSCopying)
            dictionary.setObject(uuid, forKey: "clientMessageId" as NSCopying)
            print("send: \(dictionary)")

            let jsonData = try! JSONSerialization.data(withJSONObject: dictionary, options: JSONSerialization.WritingOptions.prettyPrinted)
            self.websocket.send(jsonData)
            break
        }
    }
    
    // MARK: helpers
    func convertStringToDictionary(_ text: String) -> [String:AnyObject]? {
        if let data = text.data(using: String.Encoding.utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject]
            } catch let error as NSError {
                print(error)
            }
        }
        return nil
    }
}
