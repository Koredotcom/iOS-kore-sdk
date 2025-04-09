//
//  KoreRTMClient.swift
//  KoreBotSDK
//
//  Created by developer@kore.com on 21/05/16.
//  Copyright © 2016 Kore Inc. All rights reserved.
//

#if os(iOS)

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
    public func didReceive(event: Starscream.WebSocketEvent, client: Starscream.WebSocketClient) {
        
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
            case "events":
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
        case .peerClosed:
            break
        }
        
        timerSource.eventHandler = { [weak self] in
            if self?.receivedLastPong == false {
                // we did not receive the last pong
                // abort the socket so that we can spin up a new connection
                self?.websocket?.disconnect()
                self?.timerSource.suspend()
                self?.connectionDelegate?.rtmConnectionDidFailWithError(NSError())
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
    var queryParams: [[String: Any]] = []
    // MARK: init
    override public init() {
        super.init()
    }
    
    // MARK: set queryParameters
    open func setqueryParameters(queryParameters: [[String: Any]]) {
        queryParams = queryParameters
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
            if let connectModeStr = connectModeString ,connectModeStr != ""{
                urlString.append("&ConnectionMode=Reconnect")
            }else{
                urlString.append("&isReconnect=true")
            }
        }else{
            if let connectModeStr = connectModeString ,connectModeStr != ""{
                urlString.append(connectModeStr)
            }
            for i in 0..<queryParams.count{
                let params = queryParams[i]
                let key = Array(params)[0].key
                let value = Array(params)[0].value
                print("\(key), \(value)")
                urlString.append("&\(key)=\(value)")
            }
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
//                guard let array = responseObject["message"] as? Array<[String: Any]>, array.count > 0 else {
//                    return
//                }
//                if let model = try? BotMessageModel(JSON: responseObject), let botMessageModel = model as? BotMessageModel {
//                    connectionDelegate?.didReceiveMessage(botMessageModel)
//                }
                let receViedStr = "{\"type\":\"bot_response\",\"from\":\"bot\",\"message\":[{\"type\":\"text\",\"component\":{\"type\":\"template\",\"payload\":{\"type\":\"template\",\"payload\":{\"template_type\":\"otpValidationTemplate\",\"title\":\"EnterOTP\",\"sliderView\":true,\"description\":\"PleaseEnteryour4digitOnetimepasswordbelow\",\"mobileNumber\":\"+91******8161\",\"piiReductionChar\":\"#\",\"pinLength\":4,\"otpButtons\":[{\"title\":\"Submit\",\"type\":\"submit\"},{\"title\":\"ResendOTP\",\"type\":\"resend\",\"payload\":\"resend\"}]}}},\"cInfo\":{\"body\":\"{\\\"type\\\":\\\"template\\\",\\\"payload\\\":{\\\"template_type\\\":\\\"otpValidationTemplate\\\",\\\"title\\\":\\\"EnterOTP\\\",\\\"sliderView\\\":true,\\\"description\\\":\\\"PleaseEnteryour4digitOnetimepasswordbelow\\\",\\\"mobileNumber\\\":\\\"+91******8161\\\",\\\"piiReductionChar\\\":\\\"#\\\",\\\"pinLength\\\":4,\\\"otpButtons\\\":[{\\\"title\\\":\\\"Submit\\\",\\\"type\\\":\\\"submit\\\"},{\\\"title\\\":\\\"ResendOTP\\\",\\\"type\\\":\\\"resend\\\",\\\"payload\\\":\\\"resend\\\"}]}}\"}}],\"messageId\":\"ms-c5c22dc7-91a9-5d29-b3b0-2de725d1de65\",\"sessionId\":\"67bd8d1b2c5be0071225f98d\",\"botInfo\":{\"chatBot\":\"v3_Templates\",\"taskBotId\":\"st-0c3be6e0-3f7c-5134-97f9-2d14d7ca922c\",\"uiVersion\":\"v3\",\"hostDomain\":\"https://platform.kore.ai\",\"os\":\"MacOS\",\"device\":\"Macintosh\",\"userId\":\"u-5cf1e9bf-b782-5d75-aa60-c162140bf90d\"},\"createdOn\":\"2025-02-25T09:28:01.089Z\",\"xTraceId\":\"9ab85fb1-bdfb-4f68-8595-1716a6e6c76e\",\"icon\":\"https://platform.kore.ai/api/getMediaStream/market/f-8a5bba34-8917-5bb1-b1b8-72a288339fca.png?n=5875221462&s=Ikx0MUo3ZWNRcS9Fc1RkRVdKV0s1ZDdieTJDWlp5dWppS0tRNng3N0ZsaTA9Ig$$\",\"timestamp\":1740475681129}"
                /*"{\"type\":\"bot_response\",\"from\":\"bot\",\"message\":[{\"type\":\"text\",\"component\":{\"type\":\"template\",\"payload\":{\"type\":\"template\",\"payload\":{\"template_type\":\"articleTemplate\",\"elements\":[{\"title\":\"GeneratedByAI\",\"description\":\"-WhenfacingaSlackapplicationerror,itcouldbeduetonetworksettingsorsecuritydeviceslikeaproxy,firewall,antivirus,orVPNinterfering.-TroubleshootbyclearingthecacheandrestartingSlack.-Clickon'RestartSlack'belowtheerrormessage.-Ifissuespersist,collectandsendnetlogsforfurtherinvestigation.-OpenSlack,clickHelp,selectTroubleshooting,thenRestartandcollectnetlogs.-StoploggingwhentheissueoccursandsendthezipfiletoSlacksupport.[1\\n-Forloadingissues,browserextensionsorsecuritydevicesmaycauseinterference.-ClearcachebyclickingHelp,selectingTroubleshooting,andthenClearCacheandRestart.-Ensureyourbrowserisuptodateandsupported,andtryaccessingSlackinaprivatewindowtoruleoutextensionissues.2\",\"icon\":\"data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMTIiIGhlaWdodD0iMTQiIHZpZXdCb3g9IjAgMCAxMiAxNCIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHBhdGggZmlsbC1ydWxlPSJldmVub2RkIiBjbGlwLXJ1bGU9ImV2ZW5vZGQiIGQ9Ik05LjczMjQgMC43NzczNDRDMTAuMDExNiAwLjc3NzM0NCAxMC4yNDA4IDAuOTkxMDk0IDEwLjI2NTUgMS4yNjM4N0wxMC4yNjc2IDEuMzEyNTlWMi4wNDExMkgxMS4zMTIxQzExLjYwNzcgMi4wNDExMiAxMS44NDc0IDIuMjgwNzUgMTEuODQ3NCAyLjU3NjM2VjEyLjY4NjVDMTEuODQ3NCAxMi45ODIyIDExLjYwNzcgMTMuMjIxOCAxMS4zMTIxIDEzLjIyMThIMS4yMDE5M0MwLjkwNjMyNCAxMy4yMjE4IDAuNjY2Njg3IDEyLjk4MjIgMC42NjY2ODcgMTIuNjg2NVYyLjU3NjM2QzAuNjY2Njg3IDIuMjgwNzUgMC45MDYzMjQgMi4wNDExMiAxLjIwMTkzIDIuMDQxMTJIMi4yNDY0VjEuMzEyNTlDMi4yNDY0IDEuMDE2OTggMi40ODYwNCAwLjc3NzM0NCAyLjc4MTY1IDAuNzc3MzQ0QzMuMDYwODMgMC43NzczNDQgMy4yOTAwOSAwLjk5MTA5NCAzLjMxNDcxIDEuMjYzODdMMy4zMTY4OSAxLjMxMjU5VjIuMDQxMTJIOS4xOTcxNVYxLjMxMjU5QzkuMTk3MTUgMS4wMTY5OCA5LjQzNjc5IDAuNzc3MzQ0IDkuNzMyNCAwLjc3NzM0NFpNMTAuNzc2OCA0Ljg4NDZWMy4xMTEzNUgxLjczNzE4VjQuODg0NkgxMC43NzY4Wk0xLjczNzE4IDUuOTU1MDlIMTAuNzc2OFYxMi4xNTEzSDEuNzM3MThWNS45NTUwOVoiIGZpbGw9IiMyMDIxMjQiLz4KPC9zdmc+Cg==\",\"button\":{\"title\":\"ShowArticle\",\"type\":\"url\",\"url\":\"https://ven06090.service-now.com/nav_to.do?uri=kb_view.do?sys_kb_id=e6cc228ec3b37110d1b77aef0501310d\"},\"createdOn\":\"Created:May24th2024\",\"updatedOn\":\"Updated:May24th2024\"},{\"title\":\"GeneratedByAI\",\"description\":\"-WhenfacingaSlackapplicationerror,itcouldbeduetonetworksettingsorsecuritydeviceslikeaproxy,firewall,antivirus,orVPNinterfering.-TroubleshootbyclearingthecacheandrestartingSlack.-Clickon'RestartSlack'belowtheerrormessage.-Ifissuespersist,collectandsendnetlogsforfurtherinvestigation.-OpenSlack,clickHelp,selectTroubleshooting,thenRestartandcollectnetlogs.-StoploggingwhentheissueoccursandsendthezipfiletoSlacksupport.[1\\n-Forloadingissues,browserextensionsorsecuritydevicesmaycauseinterference.-ClearcachebyclickingHelp,selectingTroubleshooting,andthenClearCacheandRestart.-Ensureyourbrowserisuptodateandsupported,andtryaccessingSlackinaprivatewindowtoruleoutextensionissues.2\",\"icon\":\"data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMTIiIGhlaWdodD0iMTQiIHZpZXdCb3g9IjAgMCAxMiAxNCIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHBhdGggZmlsbC1ydWxlPSJldmVub2RkIiBjbGlwLXJ1bGU9ImV2ZW5vZGQiIGQ9Ik05LjczMjQgMC43NzczNDRDMTAuMDExNiAwLjc3NzM0NCAxMC4yNDA4IDAuOTkxMDk0IDEwLjI2NTUgMS4yNjM4N0wxMC4yNjc2IDEuMzEyNTlWMi4wNDExMkgxMS4zMTIxQzExLjYwNzcgMi4wNDExMiAxMS44NDc0IDIuMjgwNzUgMTEuODQ3NCAyLjU3NjM2VjEyLjY4NjVDMTEuODQ3NCAxMi45ODIyIDExLjYwNzcgMTMuMjIxOCAxMS4zMTIxIDEzLjIyMThIMS4yMDE5M0MwLjkwNjMyNCAxMy4yMjE4IDAuNjY2Njg3IDEyLjk4MjIgMC42NjY2ODcgMTIuNjg2NVYyLjU3NjM2QzAuNjY2Njg3IDIuMjgwNzUgMC45MDYzMjQgMi4wNDExMiAxLjIwMTkzIDIuMDQxMTJIMi4yNDY0VjEuMzEyNTlDMi4yNDY0IDEuMDE2OTggMi40ODYwNCAwLjc3NzM0NCAyLjc4MTY1IDAuNzc3MzQ0QzMuMDYwODMgMC43NzczNDQgMy4yOTAwOSAwLjk5MTA5NCAzLjMxNDcxIDEuMjYzODdMMy4zMTY4OSAxLjMxMjU5VjIuMDQxMTJIOS4xOTcxNVYxLjMxMjU5QzkuMTk3MTUgMS4wMTY5OCA5LjQzNjc5IDAuNzc3MzQ0IDkuNzMyNCAwLjc3NzM0NFpNMTAuNzc2OCA0Ljg4NDZWMy4xMTEzNUgxLjczNzE4VjQuODg0NkgxMC43NzY4Wk0xLjczNzE4IDUuOTU1MDlIMTAuNzc2OFYxMi4xNTEzSDEuNzM3MThWNS45NTUwOVoiIGZpbGw9IiMyMDIxMjQiLz4KPC9zdmc+Cg==\",\"button\":{\"title\":\"ShowArticle\",\"type\":\"url\",\"url\":\"https://ven06090.service-now.com/nav_to.do?uri=kb_view.do?sys_kb_id=e6cc228ec3b37110d1b77aef0501310d\"},\"createdOn\":\"Created:May24th2024\",\"updatedOn\":\"Updated:May24th2024\"},{\"title\":\"GeneratedByAI\",\"description\":\"-WhenfacingaSlackapplicationerror,itcouldbeduetonetworksettingsorsecuritydeviceslikeaproxy,firewall,antivirus,orVPNinterfering.-TroubleshootbyclearingthecacheandrestartingSlack.-Clickon'RestartSlack'belowtheerrormessage.-Ifissuespersist,collectandsendnetlogsforfurtherinvestigation.-OpenSlack,clickHelp,selectTroubleshooting,thenRestartandcollectnetlogs.-StoploggingwhentheissueoccursandsendthezipfiletoSlacksupport.[1\\n-Forloadingissues,browserextensionsorsecuritydevicesmaycauseinterference.-ClearcachebyclickingHelp,selectingTroubleshooting,andthenClearCacheandRestart.-Ensureyourbrowserisuptodateandsupported,andtryaccessingSlackinaprivatewindowtoruleoutextensionissues.2\",\"icon\":\"data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMTIiIGhlaWdodD0iMTQiIHZpZXdCb3g9IjAgMCAxMiAxNCIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHBhdGggZmlsbC1ydWxlPSJldmVub2RkIiBjbGlwLXJ1bGU9ImV2ZW5vZGQiIGQ9Ik05LjczMjQgMC43NzczNDRDMTAuMDExNiAwLjc3NzM0NCAxMC4yNDA4IDAuOTkxMDk0IDEwLjI2NTUgMS4yNjM4N0wxMC4yNjc2IDEuMzEyNTlWMi4wNDExMkgxMS4zMTIxQzExLjYwNzcgMi4wNDExMiAxMS44NDc0IDIuMjgwNzUgMTEuODQ3NCAyLjU3NjM2VjEyLjY4NjVDMTEuODQ3NCAxMi45ODIyIDExLjYwNzcgMTMuMjIxOCAxMS4zMTIxIDEzLjIyMThIMS4yMDE5M0MwLjkwNjMyNCAxMy4yMjE4IDAuNjY2Njg3IDEyLjk4MjIgMC42NjY2ODcgMTIuNjg2NVYyLjU3NjM2QzAuNjY2Njg3IDIuMjgwNzUgMC45MDYzMjQgMi4wNDExMiAxLjIwMTkzIDIuMDQxMTJIMi4yNDY0VjEuMzEyNTlDMi4yNDY0IDEuMDE2OTggMi40ODYwNCAwLjc3NzM0NCAyLjc4MTY1IDAuNzc3MzQ0QzMuMDYwODMgMC43NzczNDQgMy4yOTAwOSAwLjk5MTA5NCAzLjMxNDcxIDEuMjYzODdMMy4zMTY4OSAxLjMxMjU5VjIuMDQxMTJIOS4xOTcxNVYxLjMxMjU5QzkuMTk3MTUgMS4wMTY5OCA5LjQzNjc5IDAuNzc3MzQ0IDkuNzMyNCAwLjc3NzM0NFpNMTAuNzc2OCA0Ljg4NDZWMy4xMTEzNUgxLjczNzE4VjQuODg0NkgxMC43NzY4Wk0xLjczNzE4IDUuOTU1MDlIMTAuNzc2OFYxMi4xNTEzSDEuNzM3MThWNS45NTUwOVoiIGZpbGw9IiMyMDIxMjQiLz4KPC9zdmc+Cg==\",\"button\":{\"title\":\"ShowArticle\",\"type\":\"url\",\"url\":\"https://ven06090.service-now.com/nav_to.do?uri=kb_view.do?sys_kb_id=e6cc228ec3b37110d1b77aef0501310d\"},\"createdOn\":\"Created:May24th2024\",\"updatedOn\":\"Updated:May24th2024\"},{\"title\":\"GeneratedByAI\",\"description\":\"-WhenfacingaSlackapplicationerror,itcouldbeduetonetworksettingsorsecuritydeviceslikeaproxy,firewall,antivirus,orVPNinterfering.-TroubleshootbyclearingthecacheandrestartingSlack.-Clickon'RestartSlack'belowtheerrormessage.-Ifissuespersist,collectandsendnetlogsforfurtherinvestigation.-OpenSlack,clickHelp,selectTroubleshooting,thenRestartandcollectnetlogs.-StoploggingwhentheissueoccursandsendthezipfiletoSlacksupport.[1\\n-Forloadingissues,browserextensionsorsecuritydevicesmaycauseinterference.-ClearcachebyclickingHelp,selectingTroubleshooting,andthenClearCacheandRestart.-Ensureyourbrowserisuptodateandsupported,andtryaccessingSlackinaprivatewindowtoruleoutextensionissues.2\",\"icon\":\"data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMTIiIGhlaWdodD0iMTQiIHZpZXdCb3g9IjAgMCAxMiAxNCIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHBhdGggZmlsbC1ydWxlPSJldmVub2RkIiBjbGlwLXJ1bGU9ImV2ZW5vZGQiIGQ9Ik05LjczMjQgMC43NzczNDRDMTAuMDExNiAwLjc3NzM0NCAxMC4yNDA4IDAuOTkxMDk0IDEwLjI2NTUgMS4yNjM4N0wxMC4yNjc2IDEuMzEyNTlWMi4wNDExMkgxMS4zMTIxQzExLjYwNzcgMi4wNDExMiAxMS44NDc0IDIuMjgwNzUgMTEuODQ3NCAyLjU3NjM2VjEyLjY4NjVDMTEuODQ3NCAxMi45ODIyIDExLjYwNzcgMTMuMjIxOCAxMS4zMTIxIDEzLjIyMThIMS4yMDE5M0MwLjkwNjMyNCAxMy4yMjE4IDAuNjY2Njg3IDEyLjk4MjIgMC42NjY2ODcgMTIuNjg2NVYyLjU3NjM2QzAuNjY2Njg3IDIuMjgwNzUgMC45MDYzMjQgMi4wNDExMiAxLjIwMTkzIDIuMDQxMTJIMi4yNDY0VjEuMzEyNTlDMi4yNDY0IDEuMDE2OTggMi40ODYwNCAwLjc3NzM0NCAyLjc4MTY1IDAuNzc3MzQ0QzMuMDYwODMgMC43NzczNDQgMy4yOTAwOSAwLjk5MTA5NCAzLjMxNDcxIDEuMjYzODdMMy4zMTY4OSAxLjMxMjU5VjIuMDQxMTJIOS4xOTcxNVYxLjMxMjU5QzkuMTk3MTUgMS4wMTY5OCA5LjQzNjc5IDAuNzc3MzQ0IDkuNzMyNCAwLjc3NzM0NFpNMTAuNzc2OCA0Ljg4NDZWMy4xMTEzNUgxLjczNzE4VjQuODg0NkgxMC43NzY4Wk0xLjczNzE4IDUuOTU1MDlIMTAuNzc2OFYxMi4xNTEzSDEuNzM3MThWNS45NTUwOVoiIGZpbGw9IiMyMDIxMjQiLz4KPC9zdmc+Cg==\",\"button\":{\"title\":\"ShowArticle\",\"type\":\"url\",\"url\":\"https://ven06090.service-now.com/nav_to.do?uri=kb_view.do?sys_kb_id=e6cc228ec3b37110d1b77aef0501310d\"},\"createdOn\":\"Created:May24th2024\",\"updatedOn\":\"Updated:May24th2024\"}],\"showmore\":true,\"seeMoreTitle\":\"ShowMore\",\"displayLimit\":3,\"seemoreAction\":\"slider\"}}},\"cInfo\":{\"body\":\"{\\\"type\\\":\\\"template\\\",\\\"payload\\\":{\\\"template_type\\\":\\\"articleTemplate\\\",\\\"elements\\\":[{\\\"title\\\":\\\"GeneratedByAI\\\",\\\"description\\\":\\\"-WhenfacingaSlackapplicationerror,itcouldbeduetonetworksettingsorsecuritydeviceslikeaproxy,firewall,antivirus,orVPNinterfering.-TroubleshootbyclearingthecacheandrestartingSlack.-Clickon'RestartSlack'belowtheerrormessage.-Ifissuespersist,collectandsendnetlogsforfurtherinvestigation.-OpenSlack,clickHelp,selectTroubleshooting,thenRestartandcollectnetlogs.-StoploggingwhentheissueoccursandsendthezipfiletoSlacksupport.[1\\\\n-Forloadingissues,browserextensionsorsecuritydevicesmaycauseinterference.-ClearcachebyclickingHelp,selectingTroubleshooting,andthenClearCacheandRestart.-Ensureyourbrowserisuptodateandsupported,andtryaccessingSlackinaprivatewindowtoruleoutextensionissues.2\\\",\\\"icon\\\":\\\"data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMTIiIGhlaWdodD0iMTQiIHZpZXdCb3g9IjAgMCAxMiAxNCIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHBhdGggZmlsbC1ydWxlPSJldmVub2RkIiBjbGlwLXJ1bGU9ImV2ZW5vZGQiIGQ9Ik05LjczMjQgMC43NzczNDRDMTAuMDExNiAwLjc3NzM0NCAxMC4yNDA4IDAuOTkxMDk0IDEwLjI2NTUgMS4yNjM4N0wxMC4yNjc2IDEuMzEyNTlWMi4wNDExMkgxMS4zMTIxQzExLjYwNzcgMi4wNDExMiAxMS44NDc0IDIuMjgwNzUgMTEuODQ3NCAyLjU3NjM2VjEyLjY4NjVDMTEuODQ3NCAxMi45ODIyIDExLjYwNzcgMTMuMjIxOCAxMS4zMTIxIDEzLjIyMThIMS4yMDE5M0MwLjkwNjMyNCAxMy4yMjE4IDAuNjY2Njg3IDEyLjk4MjIgMC42NjY2ODcgMTIuNjg2NVYyLjU3NjM2QzAuNjY2Njg3IDIuMjgwNzUgMC45MDYzMjQgMi4wNDExMiAxLjIwMTkzIDIuMDQxMTJIMi4yNDY0VjEuMzEyNTlDMi4yNDY0IDEuMDE2OTggMi40ODYwNCAwLjc3NzM0NCAyLjc4MTY1IDAuNzc3MzQ0QzMuMDYwODMgMC43NzczNDQgMy4yOTAwOSAwLjk5MTA5NCAzLjMxNDcxIDEuMjYzODdMMy4zMTY4OSAxLjMxMjU5VjIuMDQxMTJIOS4xOTcxNVYxLjMxMjU5QzkuMTk3MTUgMS4wMTY5OCA5LjQzNjc5IDAuNzc3MzQ0IDkuNzMyNCAwLjc3NzM0NFpNMTAuNzc2OCA0Ljg4NDZWMy4xMTEzNUgxLjczNzE4VjQuODg0NkgxMC43NzY4Wk0xLjczNzE4IDUuOTU1MDlIMTAuNzc2OFYxMi4xNTEzSDEuNzM3MThWNS45NTUwOVoiIGZpbGw9IiMyMDIxMjQiLz4KPC9zdmc+Cg==\\\",\\\"button\\\":{\\\"title\\\":\\\"ShowArticle\\\",\\\"type\\\":\\\"url\\\",\\\"url\\\":\\\"https://ven06090.service-now.com/nav_to.do?uri=kb_view.do?sys_kb_id=e6cc228ec3b37110d1b77aef0501310d\\\"},\\\"createdOn\\\":\\\"Created:May24th2024\\\",\\\"updatedOn\\\":\\\"Updated:May24th2024\\\"},{\\\"title\\\":\\\"GeneratedByAI\\\",\\\"description\\\":\\\"-WhenfacingaSlackapplicationerror,itcouldbeduetonetworksettingsorsecuritydeviceslikeaproxy,firewall,antivirus,orVPNinterfering.-TroubleshootbyclearingthecacheandrestartingSlack.-Clickon'RestartSlack'belowtheerrormessage.-Ifissuespersist,collectandsendnetlogsforfurtherinvestigation.-OpenSlack,clickHelp,selectTroubleshooting,thenRestartandcollectnetlogs.-StoploggingwhentheissueoccursandsendthezipfiletoSlacksupport.[1\\\\n-Forloadingissues,browserextensionsorsecuritydevicesmaycauseinterference.-ClearcachebyclickingHelp,selectingTroubleshooting,andthenClearCacheandRestart.-Ensureyourbrowserisuptodateandsupported,andtryaccessingSlackinaprivatewindowtoruleoutextensionissues.2\\\",\\\"icon\\\":\\\"data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMTIiIGhlaWdodD0iMTQiIHZpZXdCb3g9IjAgMCAxMiAxNCIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHBhdGggZmlsbC1ydWxlPSJldmVub2RkIiBjbGlwLXJ1bGU9ImV2ZW5vZGQiIGQ9Ik05LjczMjQgMC43NzczNDRDMTAuMDExNiAwLjc3NzM0NCAxMC4yNDA4IDAuOTkxMDk0IDEwLjI2NTUgMS4yNjM4N0wxMC4yNjc2IDEuMzEyNTlWMi4wNDExMkgxMS4zMTIxQzExLjYwNzcgMi4wNDExMiAxMS44NDc0IDIuMjgwNzUgMTEuODQ3NCAyLjU3NjM2VjEyLjY4NjVDMTEuODQ3NCAxMi45ODIyIDExLjYwNzcgMTMuMjIxOCAxMS4zMTIxIDEzLjIyMThIMS4yMDE5M0MwLjkwNjMyNCAxMy4yMjE4IDAuNjY2Njg3IDEyLjk4MjIgMC42NjY2ODcgMTIuNjg2NVYyLjU3NjM2QzAuNjY2Njg3IDIuMjgwNzUgMC45MDYzMjQgMi4wNDExMiAxLjIwMTkzIDIuMDQxMTJIMi4yNDY0VjEuMzEyNTlDMi4yNDY0IDEuMDE2OTggMi40ODYwNCAwLjc3NzM0NCAyLjc4MTY1IDAuNzc3MzQ0QzMuMDYwODMgMC43NzczNDQgMy4yOTAwOSAwLjk5MTA5NCAzLjMxNDcxIDEuMjYzODdMMy4zMTY4OSAxLjMxMjU5VjIuMDQxMTJIOS4xOTcxNVYxLjMxMjU5QzkuMTk3MTUgMS4wMTY5OCA5LjQzNjc5IDAuNzc3MzQ0IDkuNzMyNCAwLjc3NzM0NFpNMTAuNzc2OCA0Ljg4NDZWMy4xMTEzNUgxLjczNzE4VjQuODg0NkgxMC43NzY4Wk0xLjczNzE4IDUuOTU1MDlIMTAuNzc2OFYxMi4xNTEzSDEuNzM3MThWNS45NTUwOVoiIGZpbGw9IiMyMDIxMjQiLz4KPC9zdmc+Cg==\\\",\\\"button\\\":{\\\"title\\\":\\\"ShowArticle\\\",\\\"type\\\":\\\"url\\\",\\\"url\\\":\\\"https://ven06090.service-now.com/nav_to.do?uri=kb_view.do?sys_kb_id=e6cc228ec3b37110d1b77aef0501310d\\\"},\\\"createdOn\\\":\\\"Created:May24th2024\\\",\\\"updatedOn\\\":\\\"Updated:May24th2024\\\"},{\\\"title\\\":\\\"GeneratedByAI\\\",\\\"description\\\":\\\"-WhenfacingaSlackapplicationerror,itcouldbeduetonetworksettingsorsecuritydeviceslikeaproxy,firewall,antivirus,orVPNinterfering.-TroubleshootbyclearingthecacheandrestartingSlack.-Clickon'RestartSlack'belowtheerrormessage.-Ifissuespersist,collectandsendnetlogsforfurtherinvestigation.-OpenSlack,clickHelp,selectTroubleshooting,thenRestartandcollectnetlogs.-StoploggingwhentheissueoccursandsendthezipfiletoSlacksupport.[1\\\\n-Forloadingissues,browserextensionsorsecuritydevicesmaycauseinterference.-ClearcachebyclickingHelp,selectingTroubleshooting,andthenClearCacheandRestart.-Ensureyourbrowserisuptodateandsupported,andtryaccessingSlackinaprivatewindowtoruleoutextensionissues.2\\\",\\\"icon\\\":\\\"data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMTIiIGhlaWdodD0iMTQiIHZpZXdCb3g9IjAgMCAxMiAxNCIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHBhdGggZmlsbC1ydWxlPSJldmVub2RkIiBjbGlwLXJ1bGU9ImV2ZW5vZGQiIGQ9Ik05LjczMjQgMC43NzczNDRDMTAuMDExNiAwLjc3NzM0NCAxMC4yNDA4IDAuOTkxMDk0IDEwLjI2NTUgMS4yNjM4N0wxMC4yNjc2IDEuMzEyNTlWMi4wNDExMkgxMS4zMTIxQzExLjYwNzcgMi4wNDExMiAxMS44NDc0IDIuMjgwNzUgMTEuODQ3NCAyLjU3NjM2VjEyLjY4NjVDMTEuODQ3NCAxMi45ODIyIDExLjYwNzcgMTMuMjIxOCAxMS4zMTIxIDEzLjIyMThIMS4yMDE5M0MwLjkwNjMyNCAxMy4yMjE4IDAuNjY2Njg3IDEyLjk4MjIgMC42NjY2ODcgMTIuNjg2NVYyLjU3NjM2QzAuNjY2Njg3IDIuMjgwNzUgMC45MDYzMjQgMi4wNDExMiAxLjIwMTkzIDIuMDQxMTJIMi4yNDY0VjEuMzEyNTlDMi4yNDY0IDEuMDE2OTggMi40ODYwNCAwLjc3NzM0NCAyLjc4MTY1IDAuNzc3MzQ0QzMuMDYwODMgMC43NzczNDQgMy4yOTAwOSAwLjk5MTA5NCAzLjMxNDcxIDEuMjYzODdMMy4zMTY4OSAxLjMxMjU5VjIuMDQxMTJIOS4xOTcxNVYxLjMxMjU5QzkuMTk3MTUgMS4wMTY5OCA5LjQzNjc5IDAuNzc3MzQ0IDkuNzMyNCAwLjc3NzM0NFpNMTAuNzc2OCA0Ljg4NDZWMy4xMTEzNUgxLjczNzE4VjQuODg0NkgxMC43NzY4Wk0xLjczNzE4IDUuOTU1MDlIMTAuNzc2OFYxMi4xNTEzSDEuNzM3MThWNS45NTUwOVoiIGZpbGw9IiMyMDIxMjQiLz4KPC9zdmc+Cg==\\\",\\\"button\\\":{\\\"title\\\":\\\"ShowArticle\\\",\\\"type\\\":\\\"url\\\",\\\"url\\\":\\\"https://ven06090.service-now.com/nav_to.do?uri=kb_view.do?sys_kb_id=e6cc228ec3b37110d1b77aef0501310d\\\"},\\\"createdOn\\\":\\\"Created:May24th2024\\\",\\\"updatedOn\\\":\\\"Updated:May24th2024\\\"},{\\\"title\\\":\\\"GeneratedByAI\\\",\\\"description\\\":\\\"-WhenfacingaSlackapplicationerror,itcouldbeduetonetworksettingsorsecuritydeviceslikeaproxy,firewall,antivirus,orVPNinterfering.-TroubleshootbyclearingthecacheandrestartingSlack.-Clickon'RestartSlack'belowtheerrormessage.-Ifissuespersist,collectandsendnetlogsforfurtherinvestigation.-OpenSlack,clickHelp,selectTroubleshooting,thenRestartandcollectnetlogs.-StoploggingwhentheissueoccursandsendthezipfiletoSlacksupport.[1\\\\n-Forloadingissues,browserextensionsorsecuritydevicesmaycauseinterference.-ClearcachebyclickingHelp,selectingTroubleshooting,andthenClearCacheandRestart.-Ensureyourbrowserisuptodateandsupported,andtryaccessingSlackinaprivatewindowtoruleoutextensionissues.2\\\",\\\"icon\\\":\\\"data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMTIiIGhlaWdodD0iMTQiIHZpZXdCb3g9IjAgMCAxMiAxNCIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHBhdGggZmlsbC1ydWxlPSJldmVub2RkIiBjbGlwLXJ1bGU9ImV2ZW5vZGQiIGQ9Ik05LjczMjQgMC43NzczNDRDMTAuMDExNiAwLjc3NzM0NCAxMC4yNDA4IDAuOTkxMDk0IDEwLjI2NTUgMS4yNjM4N0wxMC4yNjc2IDEuMzEyNTlWMi4wNDExMkgxMS4zMTIxQzExLjYwNzcgMi4wNDExMiAxMS44NDc0IDIuMjgwNzUgMTEuODQ3NCAyLjU3NjM2VjEyLjY4NjVDMTEuODQ3NCAxMi45ODIyIDExLjYwNzcgMTMuMjIxOCAxMS4zMTIxIDEzLjIyMThIMS4yMDE5M0MwLjkwNjMyNCAxMy4yMjE4IDAuNjY2Njg3IDEyLjk4MjIgMC42NjY2ODcgMTIuNjg2NVYyLjU3NjM2QzAuNjY2Njg3IDIuMjgwNzUgMC45MDYzMjQgMi4wNDExMiAxLjIwMTkzIDIuMDQxMTJIMi4yNDY0VjEuMzEyNTlDMi4yNDY0IDEuMDE2OTggMi40ODYwNCAwLjc3NzM0NCAyLjc4MTY1IDAuNzc3MzQ0QzMuMDYwODMgMC43NzczNDQgMy4yOTAwOSAwLjk5MTA5NCAzLjMxNDcxIDEuMjYzODdMMy4zMTY4OSAxLjMxMjU5VjIuMDQxMTJIOS4xOTcxNVYxLjMxMjU5QzkuMTk3MTUgMS4wMTY5OCA5LjQzNjc5IDAuNzc3MzQ0IDkuNzMyNCAwLjc3NzM0NFpNMTAuNzc2OCA0Ljg4NDZWMy4xMTEzNUgxLjczNzE4VjQuODg0NkgxMC43NzY4Wk0xLjczNzE4IDUuOTU1MDlIMTAuNzc2OFYxMi4xNTEzSDEuNzM3MThWNS45NTUwOVoiIGZpbGw9IiMyMDIxMjQiLz4KPC9zdmc+Cg==\\\",\\\"button\\\":{\\\"title\\\":\\\"ShowArticle\\\",\\\"type\\\":\\\"url\\\",\\\"url\\\":\\\"https://ven06090.service-now.com/nav_to.do?uri=kb_view.do?sys_kb_id=e6cc228ec3b37110d1b77aef0501310d\\\"},\\\"createdOn\\\":\\\"Created:May24th2024\\\",\\\"updatedOn\\\":\\\"Updated:May24th2024\\\"}],\\\"showmore\\\":true,\\\"seeMoreTitle\\\":\\\"ShowMore\\\",\\\"displayLimit\\\":3,\\\"seemoreAction\\\":\\\"slider\\\"}}\"}}],\"messageId\":\"ms-534fae2d-058c-59a0-af7c-b0e04f52d9ea\",\"sessionId\":\"67bc2136af07cc470c494cf1\",\"botInfo\":{\"chatBot\":\"v3_Templates\",\"taskBotId\":\"st-0c3be6e0-3f7c-5134-97f9-2d14d7ca922c\",\"uiVersion\":\"v3\",\"hostDomain\":\"https://platform.kore.ai\",\"os\":\"MacOS\",\"device\":\"Macintosh\",\"userId\":\"u-b17ead21-239f-5b40-9b7d-10f693e9e920\"},\"createdOn\":\"2025-02-24T07:36:48.977Z\",\"xTraceId\":\"51eaca63-05a8-4433-a710-18a47ab31d31\",\"icon\":\"https://platform.kore.ai/api/getMediaStream/market/f-8a5bba34-8917-5bb1-b1b8-72a288339fca.png?n=3549900165&s=ImxCUnQ0WjRNK1VwNnd3NElXWFEwY0xlclQyazFJQXV3SFR1RmI5Z3J4UVk9Ig$$\",\"timestamp\":1740382609004}"*/
               
                            let staticresponseObject = convertStringToDictionary(receViedStr)
                            guard let array = staticresponseObject?["message"] as? Array<[String: Any]>, array.count > 0 else {
                                return
                            }
                            if let model = try? BotMessageModel(JSON: staticresponseObject ?? [:]), let botMessageModel = model as? BotMessageModel {
                                connectionDelegate?.didReceiveMessage(botMessageModel)
                            }
            case "user_message":
                connectionDelegate?.didReceivedUserMessage(responseObject)
            case "events":
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
        case .peerClosed:
            break
        }
        
        timerSource.eventHandler = { [weak self] in
            if self?.receivedLastPong == false {
                // we did not receive the last pong
                // abort the socket so that we can spin up a new connection
                self?.websocket?.disconnect()
                self?.timerSource.suspend()
                self?.connectionDelegate?.rtmConnectionDidFailWithError(NSError())
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
    
    // MARK: AgentChat Events
    open func sendEventToAgentChat(_ message: String, parameters: [String: Any], options: [String: Any]?, eventName: String?, messageId: String?) {
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
            if let id =  messageId, id != ""{
                dictionary.setObject(id, forKey: "id" as NSCopying)
            }else{
                dictionary.setObject(uuid, forKey: "id" as NSCopying)
            }
            dictionary.setObject(uuid, forKey: "clientMessageId" as NSCopying)
            dictionary.setObject("iOS", forKey: "client" as NSCopying)
            dictionary.setObject(eventName ?? "", forKey: "event" as NSCopying)
            
            let meta = ["timezone": TimeZone.current.identifier, "locale": Locale.current.identifier]
            dictionary.setValue(meta, forKey: "meta")
            
            debugPrint("Agent chat end: \(dictionary)")
            
            let jsonData = try! JSONSerialization.data(withJSONObject: dictionary, options: JSONSerialization.WritingOptions.prettyPrinted)
            self.websocket?.write(data: jsonData)
        } else {
            print("Socket is in CONNECTING / CLOSING / CLOSED state")
        }
    }
    
    // MARK: sending ACK
    open func sendACK(ackDic: [String: Any]?) {
        if (isConnected) {
            print("Socket is in OPEN state")
            var dictionary: NSMutableDictionary = NSMutableDictionary()
            dictionary =  NSMutableDictionary(dictionary: ackDic ?? [:])
            debugPrint("send ACK: \(dictionary)")
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

#endif
