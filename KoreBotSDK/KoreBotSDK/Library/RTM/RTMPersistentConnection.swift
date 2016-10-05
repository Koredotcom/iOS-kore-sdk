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

public class RTMPersistentConnection : NSObject, SRWebSocketDelegate {
    var botInfo: BotInfoModel!
    private var botInfoParameters: NSDictionary! = nil
    var websocket: SRWebSocket! = nil
    var connectionDelegate: RTMPersistentConnectionDelegate?

    public var tryReconnect = false
    
    var connectionStatus: RTMConnectionStatus {
        get {
            switch self.websocket.readyState.rawValue {
            case 0: // SR_CONNECTING
                return .Closed
            case 1: // SR_OPEN
                return .Open
            case 2: // SR_CLOSING
                return .Closing
            default: // SR_CLOSED
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
        self.websocket = SRWebSocket(URLRequest: NSURLRequest(URL: NSURL(string: url)!))
        self.websocket.delegate = self
        self.websocket.open()
    }
    
    public func disconnect() {
        if (self.websocket != nil) {
            self.websocket.close()
        }
    }
    
    // MARK: WebSocketDelegate methods
//    - (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message;
//    
//    @optional
//    
//    - (void)webSocketDidOpen:(SRWebSocket *)webSocket;
//    - (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error;
//    - (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean;
//    - (void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload;
//    
//    // Return YES to convert messages sent as Text to an NSString. Return NO to skip NSData -> NSString conversion for Text messages. Defaults to YES.
//    - (BOOL)webSocketShouldConvertTextFrameToString:(SRWebSocket *)webSocket;

    public func webSocketDidOpen() {
        self.connectionDelegate?.rtmConnectionWillOpen()
    }
    
    public func webSocketShouldConvertTextFrameToString() -> ObjCBool {
        return true
    }
    
    public func webSocket(webSocket: SRWebSocket!, didCloseWithCode code: NSInteger!, reason: NSString!, wasClean: ObjCBool) {
        self.connectionDelegate?.rtmConnectionDidClose(code, reason: reason as String)
    }
    
    public func webSocket(webSocket: SRWebSocket!, didFailWithError error: NSError!) {
        self.connectionDelegate?.rtmConnectionDidFailWithError(error)
    }

    public func webSocket(webSocket: SRWebSocket!, didReceiveMessage message: AnyObject!) {
        let responseObject = self.convertStringToDictionary(message as! String)!
        if (responseObject["type"]! as!  String == "ready") {
            self.connectionDelegate?.self.rtmConnectionDidOpen()
        } else if (responseObject["ok"] != nil) {
            let ack: Ack = try! (MTLJSONAdapter.modelOfClass(Ack.self, fromJSONDictionary: responseObject ) as! Ack)
            self.connectionDelegate?.didReceiveMessageAck!(ack)
        } else if (responseObject["type"]! as! String == "bot_response") {
            let botMessageModel: BotMessageModel = try! (MTLJSONAdapter.modelOfClass(BotMessageModel.self, fromJSONDictionary: responseObject ) as! BotMessageModel)
            self.connectionDelegate?.didReceiveMessage!(botMessageModel)
        }
    }

    public func webSocket(webSocket: SRWebSocket!, didReceivePong pongPayload: NSData!) {

    }

//    public func webSocketEnd(code: Int, reason: String, wasClean: Bool, error: NSError?) {
//        self.connectionDelegate?.rtmConnectionDidEnd!(code, reason: reason, wasClean: wasClean, error: NSError(domain: "", code: 0, userInfo: [:]))
//    }
    
    // MARK:
    public func sendMessageModel(message: String, options: AnyObject?) {
        switch (self.connectionStatus) {
        case .Connecting:
            print("Socket is in CONNECTING state")
            break
        case .Closed:
            self.start()
            print("Socket is in CLOSED state")
            break
        case .Closing:
            print("Socket is in CLOSING state")
            break
        case .Open:
            print("Socket is in OPEN state")
            let parameters: NSMutableDictionary = NSMutableDictionary()
            let messageObject = ["body":message, "attachments":[]];
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
            self.websocket.send(jsonData)
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
