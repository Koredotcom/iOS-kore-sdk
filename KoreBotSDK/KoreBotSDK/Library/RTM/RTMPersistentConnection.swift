//
//  KoreRTMClient.swift
//  KoreBotSDK
//
//  Created by Srinivas Vasadi on 21/05/16.
//  Copyright © 2016 Kore. All rights reserved.
//

import UIKit
import SwiftWebSocket
import Mantle

enum RTMConnectionStatus : Int {
    // connection is not yet open.
    case Connecting = 0
    // connection is open and ready to communicate.
    case Open = 1
    // connection is in the process of closing.
    case Closing = 2
    // connection is closed or couldn't be opened.
    case Closed = 3
    // connection is not initialized yet
    case None = 4
    private var isClosed : Bool {
        switch self {
        case .Closing, .Closed:
            return true
        default:
            return false
        }
    }
    
    // returns a string that represents the ReadyState value.
    public var description : String {
        switch self {
        case Connecting: return "Connecting"
        case Open: return "Open"
        case Closing: return "Closing"
        case Closed: return "Closed"
        case None: return "None"
        }
    }
}

@objc public protocol RTMPersistentConnectionDelegate {
    func rtmConnectionWillOpen()
    func rtmConnectionDidOpen()
    func rtmConnectionDidClose(code: Int, reason: String)
    func rtmConnectionDidFailWithError(error: NSError)
    optional func didReceiveMessage(message: BotMessageModel)
    optional func didReceiveMessageAck(ack: Ack)
    optional func rtmConnectionDidEnd(code: Int, reason: String, wasClean: Bool, error: NSError?)
}

public class RTMPersistentConnection : NSObject, WebSocketDelegate {
    var botInfo: BotInfoModel!
    private var botInfoParameters: NSDictionary! = nil
    var websocket: WebSocket! = nil
    var connectionDelegate: RTMPersistentConnectionDelegate?

    public var tryReconnect = false
    
    var connectionStatus: RTMConnectionStatus {
        get {
            switch self.websocket.readyState {
            case .Connecting:
                return .Closed
            case .Open:
                return .Open
            case .Closing:
                return .Closing
            default:
                return .Closed
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
    
    public func start() {
        var url: String = self.botInfo.botUrl!
        if (self.tryReconnect == true) {
            url.appendContentsOf("&isReconnect=true")
        }
        self.websocket = WebSocket(url)
        self.websocket.delegate = self
    }
    
    public func disconnect() {
        if (self.websocket != nil) {
            self.websocket.close()
        }
    }
    
    // MARK: WebSocketDelegate methods
    public func webSocketOpen() {
        self.connectionDelegate?.rtmConnectionWillOpen()
    }
    
    public func webSocketClose(code: Int, reason: String, wasClean: Bool) {
        self.connectionDelegate?.rtmConnectionDidClose(code, reason: reason)
    }
    
    public func webSocketError(error: NSError) {
        self.connectionDelegate?.rtmConnectionDidFailWithError(error)
    }

    public func webSocketMessageText(text: String) {
        let responseObject = self.convertStringToDictionary(text)!
        if (responseObject["type"]! as!  String == "ready") {
            self.connectionDelegate?.self.rtmConnectionDidOpen()
        } else if (responseObject["ok"] != nil) {
            let ack: Ack = try! (MTLJSONAdapter.modelOfClass(Ack.self, fromJSONDictionary: responseObject as! [String : AnyObject]) as! Ack)
            self.connectionDelegate?.didReceiveMessageAck!(ack)
        } else if (responseObject["type"]! as! String == "bot_response") {
            let botMessageModel: BotMessageModel = try! (MTLJSONAdapter.modelOfClass(BotMessageModel.self, fromJSONDictionary: responseObject as! [String : AnyObject]) as! BotMessageModel)
            self.connectionDelegate?.didReceiveMessage!(botMessageModel)
        }
    }

    public func webSocketMessageData(data: NSData) {

    }

    public func webSocketPong() {

    }

    public func webSocketEnd(code: Int, reason: String, wasClean: Bool, error: NSError?) {
        self.connectionDelegate?.rtmConnectionDidEnd!(code, reason: reason, wasClean: wasClean, error: NSError(domain: "", code: 0, userInfo: [:]))
    }
    
    // MARK:
    public func sendMessageModel(message: String, options: AnyObject?) {
        switch (self.connectionStatus) {
        case .Connecting:
            print("Socket is in CONNECTING state")
            break
        case .Closed:
            self.websocket.open(self.botInfo.botUrl!)
            print("Socket is in CLOSED state")
            break
        case .Closing:
            print("Socket is in CLOSING state")
            break
        case .Open:
            print("Socket is in OPEN state")
            var parameters: NSMutableDictionary = NSMutableDictionary()
            var messageObject = ["body":message, "attachments":[]];
            parameters.setObject(messageObject, forKey: "message")
            parameters.setObject("/bot.message", forKey: "resourceid")
            if (self.botInfoParameters != nil) {
                parameters.setObject(self.botInfoParameters, forKey: "botInfo")
            }
            let uuid: String = Constants.getUUID()
            parameters.setObject(uuid, forKey: "id")
            parameters.setObject(uuid, forKey: "clientMessageId")
            print("send: \(parameters)")

            var error : NSError?
            let jsonData = try! NSJSONSerialization.dataWithJSONObject(parameters, options: NSJSONWritingOptions.PrettyPrinted)
            self.websocket.send(data: jsonData)
            break
        case .None:
            break
        }
    }
    
    // MARK: helpers
    func convertStringToDictionary(text: String) -> [String:AnyObject]? {
        if let data = text.dataUsingEncoding(NSUTF8StringEncoding) {
            do {
                return try! NSJSONSerialization.JSONObjectWithData(data, options: []) as? [String:AnyObject]
            } catch let error as NSError {
                print(error)
            }
        }
        return nil
    }
}
