//
//  KoreRTMClient.swift
//  KoreBotSDK
//
//  Created by developer@kore.com on 21/05/16.
//  Copyright © 2016 Kore Inc. All rights reserved.
//

import UIKit
import Starscream

public protocol RTMPersistentConnectionDelegate {
    func rtmConnectionDidOpen()
    func rtmConnectionReady()
    func rtmConnectionDidClose(_ code: UInt16, reason: String?)
    func rtmConnectionDidFailWithError(_ error: Error?)
    func didReceiveMessage(_ message: BotMessageModel)
    func didReceiveMessageAck(_ ack: Ack)
    func didReceivedUserMessage(_ userMessageDict:[String:Any])
}

open class RTMTimer: NSObject {
    public enum RTMTimerState {
        case suspended
        case resumed
    }
    public var pingInterval: TimeInterval = 10.0
    open var timer: DispatchSourceTimer?
    open var eventHandler: (() -> Void)?
    open var state: RTMTimerState = .suspended
    
    // MARK: - init
    public init(timeInterval: TimeInterval = 10.0) {
        super.init()
        pingInterval = timeInterval
        initalizeTimer()
    }
    
    func initalizeTimer() {
        let intervalInNSec = pingInterval * Double(NSEC_PER_SEC)
        let startTime = DispatchTime.now() + Double(intervalInNSec) / Double(NSEC_PER_SEC)
        
        timer = DispatchSource.makeTimerSource(flags: [], queue: .main)
        timer?.schedule(deadline: startTime, repeating: pingInterval)
        timer?.setEventHandler(handler: { [weak self] in
            self?.eventHandler?()
        })
    }
    
    // MARK: -
    open func resume() {
        if state == .resumed {
            return
        }
        state = .resumed
        timer?.resume()
    }
    
    open func suspend() {
        if state == .suspended {
            return
        }
        state = .suspended
        timer?.suspend()
    }
    
    // MARK: -
    deinit {
        timer?.setEventHandler {}
        timer?.cancel()
        
        resume()
        eventHandler = nil
    }
}

open class RTMPersistentConnection : NSObject, WebSocketDelegate {
    var botInfo: BotInfoModel!
    fileprivate var botInfoParameters: [String: Any]?
    fileprivate var reWriteOptions: [String: Any]?
    
    var isConnected = true // kkkk
    var isConnecting = false
    var websocket: WebSocket?
    var connectionDelegate: RTMPersistentConnectionDelegate?
    
    fileprivate var timerSource = RTMTimer()
    //    fileprivate let pingInterval: TimeInterval
    fileprivate var receivedLastPong = true
    open var tryReconnect = false
    
    // MARK: init
    override public init() {
        super.init()
    }
    
    public func connect(botInfo: BotInfoModel, botInfoParameters: [String: Any]?, reWriteOptions: [String: Any]? = nil, tryReconnect: Bool) {
        self.botInfo = botInfo
        self.botInfoParameters = botInfoParameters
        self.reWriteOptions = reWriteOptions
        self.tryReconnect = tryReconnect
        start()
    }
    
    open func start() {
        guard var urlString = botInfo.botUrl, !isConnecting else {
            print("botUrl is nil")
            return
        }
        if tryReconnect == true {
            urlString.append("&isReconnect=true")
        }
        
        var urlComponents = URLComponents(string: urlString)
        if let scheme = reWriteOptions?["scheme"] as? String {
            urlComponents?.scheme = scheme
        }
        if let host = reWriteOptions?["host"] as? String {
            urlComponents?.host = host
        }
        if let port = reWriteOptions?["port"] as? Int {
            urlComponents?.port = port
        }
        
        if let url = urlComponents?.url {
            receivedLastPong = true
            websocket = WebSocket(request: URLRequest(url: url))
            websocket?.delegate = self
            websocket?.connect()
        }
    }
    
    open func disconnect() {
        self.websocket?.disconnect()
    }
    
    // MARK: WebSocketDelegate methods
    open func didReceive(event: WebSocketEvent, client: WebSocket) {
        
        switch event {
        case .connected(let headers):
            connectionDelegate?.rtmConnectionDidOpen()
            isConnected = true
            isConnecting = false
            print("websocket is connected: \(headers)")
        case .disconnected(let reason, let code):
            connectionDelegate?.rtmConnectionDidClose(code, reason: reason)
            isConnected = false
            isConnecting = false
            print("websocket is disconnected: \(reason) with code: \(code)")
        case .text(let message):
            print("Received text: \(message)")
            guard let message = message as? String,
                  let responseObject = convertStringToDictionary(message),
                  let type = responseObject["type"] as? String else {
                return
            }
            switch type {
            case "ready":
                connectionDelegate?.rtmConnectionReady()
            case "ok":
                if let model = try? Ack(JSON: responseObject), let ack = model as? Ack {
                    connectionDelegate?.didReceiveMessageAck(ack)
                }
            case "bot_response":
                print("received: \(responseObject)")
                guard let array = responseObject["message"] as? Array<[String: Any]>, array.count > 0 else {
                    return
                }
                if let model = try? BotMessageModel(JSON: responseObject), let botMessageModel = model as? BotMessageModel {
                    connectionDelegate?.didReceiveMessage(botMessageModel)
                }
            case "user_message":
                connectionDelegate?.didReceivedUserMessage(responseObject)
            default:
                break
            }
        case .binary(let data):
            print("Received data: \(data.count)")
        case .ping(_):
            break
        case .pong(_):
            receivedLastPong = true
            break
        case .viabilityChanged(_):
            break
        case .reconnectSuggested(_):
            break
        case .cancelled:
            isConnected = false
            isConnecting = false
            break
        case .error(let error):
            isConnected = false
            isConnecting = false
            connectionDelegate?.rtmConnectionDidFailWithError(error)
            break
        }
        
        timerSource.eventHandler = { [weak self] in
            if self?.receivedLastPong == false {
                // we did not receive the last pong
                // abort the socket so that we can spin up a new connection
                // self.websocket.close()
                // self.timerSource.suspend()
                // self.connectionDelegate?.rtmConnectionDidFailWithError(NSError())
            } else if self?.isConnected == false {
                self?.websocket?.disconnect()
                self?.timerSource.suspend()
            } else if self?.isConnected == true {
                
                // we got a pong recently
                // send another ping
                self?.receivedLastPong = false
                _ = try? self?.websocket?.write(ping: Data())
            }
        }
        timerSource.resume()
    }
    
    // MARK: sending message
    open func sendMessage(_ message: String, parameters: [String: Any], options: [String: Any]?) {
        if (isConnected) {
            
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
                dictionary.setObject(self.botInfoParameters as Any, forKey: "botInfo" as NSCopying)
            }
            let uuid: String = Constants.getUUID()
            dictionary.setObject(uuid, forKey: "id" as NSCopying)
            dictionary.setObject(uuid, forKey: "clientMessageId" as NSCopying)
            dictionary.setObject("iOS", forKey: "client" as NSCopying)
            
            let meta = ["timezone": TimeZone.current.identifier, "locale": Locale.current.identifier]
            dictionary.setValue(meta, forKey: "meta")
            
            debugPrint("send: \(dictionary)")
            
            let jsonData = try! JSONSerialization.data(withJSONObject: dictionary, options: JSONSerialization.WritingOptions.prettyPrinted)
            self.websocket?.write(data: jsonData)
        } else {
            print("Socket is in CONNECTING / CLOSING / CLOSED state")
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
