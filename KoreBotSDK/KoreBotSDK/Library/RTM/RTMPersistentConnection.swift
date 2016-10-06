//
//  KoreRTMClient.swift
//  KoreBotSDK
//
//  Created by Srinivas Vasadi on 21/05/16.
//  Copyright © 2016 Kore. All rights reserved.
//

import UIKit
import SocketRocket
import Mantle

enum RTMConnectionStatus : Int {
    // connection is not yet open.
    case connecting = 0
    // connection is open and ready to communicate.
    case open = 1
    // connection is in the process of closing.
    case closing = 2
    // connection is closed or couldn't be opened.
    case closed = 3
    // connection is not initialized yet
    case none = 4
    fileprivate var isClosed : Bool {
        switch self {
        case .closing, .closed:
            return true
        default:
            return false
        }
    }
    
    // returns a string that represents the ReadyState value.
    public var description : String {
        switch self {
        case .connecting: return "Connecting"
        case .open: return "Open"
        case .closing: return "Closing"
        case .closed: return "Closed"
        case .none: return "None"
        }
    }
}

@objc public protocol RTMPersistentConnectionDelegate {
    func rtmConnectionWillOpen()
    func rtmConnectionDidOpen()
    func rtmConnectionDidClose(_ code: Int, reason: String)
    func rtmConnectionDidFailWithError(_ error: NSError)
    @objc optional func didReceiveMessage(_ message: BotMessageModel)
    @objc optional func didReceiveMessageAck(_ ack: Ack)
    @objc optional func rtmConnectionDidEnd(_ code: Int, reason: String, wasClean: Bool, error: NSError?)
}

open class RTMPersistentConnection : NSObject, SRWebSocketDelegate {
    var botInfo: BotInfoModel!
    fileprivate var botInfoParameters: NSDictionary! = nil
    var websocket: SRWebSocket! = nil
    var connectionDelegate: RTMPersistentConnectionDelegate?

    open var tryReconnect = false
    
    var connectionStatus: RTMConnectionStatus {
        get {
            switch self.websocket.readyState.rawValue {
            case 0: // SR_CONNECTING
                return .closed
            case 1: // SR_OPEN
                return .open
            case 2: // SR_CLOSING
                return .closing
            default: // SR_CLOSED
                return .closed
            }
        }
    }
    
    // MARK: init
    public init(botInfo: BotInfoModel!, botInfoParameters: NSDictionary!, tryReconnect: Bool) {
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
        self.websocket = SRWebSocket(urlRequest: URLRequest(url: URL(string: url)! as URL) as URLRequest!)
        self.websocket.delegate = self
        self.websocket.open()
    }
    
    open func disconnect() {
        if (self.websocket != nil) {
            self.websocket.close()
        }
    }
    
    // MARK: WebSocketDelegate methods
    open func webSocketDidOpen() {
        self.connectionDelegate?.rtmConnectionWillOpen()
    }
    
    open func webSocketShouldConvertTextFrameToString() -> ObjCBool {
        return true
    }
    
    open func webSocket(_ webSocket: SRWebSocket!, didCloseWithCode code: NSInteger!, reason: NSString!, wasClean: ObjCBool) {
        self.connectionDelegate?.rtmConnectionDidClose(code, reason: reason as String)
    }
    
    open func webSocket(_ webSocket: SRWebSocket!, didFailWithError error: NSError!) {
        self.connectionDelegate?.rtmConnectionDidFailWithError(error)
    }

    open func webSocket(_ webSocket: SRWebSocket!, didReceiveMessage message: Any!) {
        let responseObject = self.convertStringToDictionary(message as! String)!
        if (responseObject["type"]! as!  String == "ready") {
            self.connectionDelegate?.self.rtmConnectionDidOpen()
        } else if (responseObject["ok"] != nil) {
            let ack: Ack = try! (MTLJSONAdapter.model(of: Ack.self, fromJSONDictionary: responseObject ) as! Ack)
            self.connectionDelegate?.didReceiveMessageAck!(ack)
        } else if (responseObject["type"]! as! String == "bot_response") {
            let botMessageModel: BotMessageModel = try! (MTLJSONAdapter.model(of: BotMessageModel.self, fromJSONDictionary: responseObject ) as! BotMessageModel)
            self.connectionDelegate?.didReceiveMessage!(botMessageModel)
        }
    }

    open func webSocket(_ webSocket: SRWebSocket!, didReceivePong pongPayload: Data!) {

    }

//    public func webSocketEnd(code: Int, reason: String, wasClean: Bool, error: NSError?) {
//        self.connectionDelegate?.rtmConnectionDidEnd!(code, reason: reason, wasClean: wasClean, error: NSError(domain: "", code: 0, userInfo: [:]))
//    }
    
    // MARK:
    open func sendMessageModel(_ message: String, options: AnyObject?) {
        switch (self.connectionStatus) {
        case .connecting:
            print("Socket is in CONNECTING state")
            break
        case .closed:
            self.start()
            print("Socket is in CLOSED state")
            break
        case .closing:
            print("Socket is in CLOSING state")
            break
        case .open:
            print("Socket is in OPEN state")
            let parameters: NSMutableDictionary = NSMutableDictionary()
            let messageObject = ["body":message, "attachments":[]] as [String : Any];
            parameters.setObject(messageObject, forKey: "message" as NSCopying)
            parameters.setObject("/bot.message", forKey: "resourceid" as NSCopying)
            if (self.botInfoParameters != nil) {
                parameters.setObject(self.botInfoParameters, forKey: "botInfo" as NSCopying)
            }
            let uuid: String = Constants.getUUID()
            parameters.setObject(uuid, forKey: "id" as NSCopying)
            parameters.setObject(uuid, forKey: "clientMessageId" as NSCopying)
            print("send: \(parameters)")

            var error : NSError?
            let jsonData = try! JSONSerialization.data(withJSONObject: parameters, options: JSONSerialization.WritingOptions.prettyPrinted)
            self.websocket.send(jsonData)
            break
        case .none:
            break
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
