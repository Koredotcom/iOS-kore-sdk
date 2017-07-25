//
//  STTClient.swift
//  Pods
//
//  Created by developer@kore.com on 24/07/17.
//
//

import Foundation
import AVFoundation

open class STTClient: NSObject, KREWebSocketDelegate, MCAudioInputQueueDelegate {

    public var webSocket: KREWebSocket!
    public var audioQueueRecorder: MCAudioInputQueue!
    fileprivate var audioFormat: AudioStreamBasicDescription = AudioStreamBasicDescription()
    
    fileprivate var speechSocketURL: String!
    fileprivate var authToken: String!
    fileprivate var identity: String!
    
    fileprivate var reconnecting = false
    fileprivate var currentReconnectAttempt = 0
    fileprivate(set) var reconnectAttempts = 5
    fileprivate var reconnectWait = 10
    
    var audioBuffer: Data!
    var recordedData: Data!
    public var isAudioQueueRecordingInProgress = false
    
    open var onReceiveMessage: (([AnyHashable : Any]?) -> Void)!
    open var connectionDidClose: ((Int, String) -> Void)!
    
    public func initialize(serverUrl: String, authToken:String, identity: String) {
        self.setKoreBotServerUrl(url: serverUrl)
        self.authToken = authToken
        self.identity = identity
        
        self.setUpAudioQueueFormat()
        self.doAudioQueueRecording()
        self.connect()
    }
    
    public func stopAudioQueueRecording() {
        self.webSocket.sendEndOFSpeechMarker()
        self.audioQueueRecorder.stop()
        self.isAudioQueueRecordingInProgress = false
    }
    
    func setUpAudioQueueFormat() {
        audioFormat.mFormatID = kAudioFormatLinearPCM
        audioFormat.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked
        audioFormat.mBitsPerChannel = 16
        audioFormat.mChannelsPerFrame = 1
        audioFormat.mBytesPerFrame = (audioFormat.mBitsPerChannel / 8) * audioFormat.mChannelsPerFrame as UInt32
        audioFormat.mBytesPerPacket = audioFormat.mBytesPerFrame
        audioFormat.mFramesPerPacket = 1;
        audioFormat.mSampleRate = 16000.0
        audioFormat.mReserved = 0;
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
            try audioSession.setActive(true)
        } catch {
            NSLog("Failed to set category")
        }
    }
    
    func doAudioQueueRecording() {
        self.audioBuffer = Data()
        self.recordedData = Data()
        
        let audioSession = AVAudioSession.sharedInstance()
        if(audioSession.responds(to: Selector(("requestRecordPermission")))){
            audioSession.requestRecordPermission({ (granted: Bool) in
                if(granted){
                    DispatchQueue.main.async {
                        self.audioQueueRecorder = MCAudioInputQueue.init(format: self.audioFormat, bufferDuration: 0.25, delegate: self)
                        self.audioQueueRecorder.meteringEnabled = true
                        self.isAudioQueueRecordingInProgress = true
                    }
                }else{
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Microphone Access Denied", message: "This app requires access to your device's Microphone.\n\nPlease enable Microphone access for this app in Settings / Privacy / Microphone", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.cancel, handler: nil))
                        
                        // Get root view controller
                        if let viewController = UIApplication.shared.keyWindow?.rootViewController {
                            viewController.present(alert, animated: true, completion: nil)
                        }
                    }
                }
            })
        }
    }

    // MARK:
    fileprivate func connect() {
        if (self.authToken != nil) {
            let requestManager: STTRequestManager = STTRequestManager.sharedManager
            requestManager.getSocketUrlWithAuthInfoModel(self.authToken, identity: self.identity, success: { (responseObject) in
                if let socketURL: String = responseObject?["link"] as? String {
                    self.speechSocketURL = socketURL
                }
                self.webSocket = self.webSocketConnectWithURL(self.getSpeechServerUrl())
                self.reconnecting = false
            }, failure: { (error) in
                self.reconnecting = false
                self.tryReconnect()
            })
        }
    }
    
    open func reconnect() {
        if self.reconnecting == false {
            self.reconnecting = true
            connect()
        }
    }
    
    fileprivate func tryReconnect() {
        if reconnecting == true {
            return
        }
        
        if currentReconnectAttempt + 1 > reconnectAttempts {
            if (self.connectionDidClose != nil) {
                self.connectionDidClose(100, "Reconnect Failed")
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
    
    open func disconnect() {
        if self.webSocket != nil {
            self.webSocket.close()
        }
    }
    
    // MARK: functions
    fileprivate func webSocketConnectWithURL(_ url: String) -> KREWebSocket {
        if (self.webSocket != nil && (self.webSocket.webSocket.readyState == .OPEN || self.webSocket.webSocket.readyState == .CONNECTING)) {
            return self.webSocket
        } else {
            let webSocketConnection: KREWebSocket = KREWebSocket.init(urlString:url)
            webSocketConnection.delegate = self
            webSocketConnection.connect()
            return webSocketConnection
        }
    }
    
    // MARK:
    open func setKoreBotServerUrl(url: String) {
        STTConstants.KORE_BOT_SERVER = url
    }
    
    func getSpeechServerUrl() -> String {
        return String(format: STTConstants.kreSpeechServer, arguments: [self.speechSocketURL, STTConstants.voiceContentType, self.identity])
    }
    
    // MARK: KREWebSocketDelegate methods
    
    public func webSocketOpen(_ webSocket: SRWebSocket!) {
        
    }
    
    public func webSocket(_ webSocket: SRWebSocket!, onFailWithError error: Error!) {
        NSLog("*******%s********", #function)
        self.webSocket.delegate = nil;
        self.webSocket = nil;
        if (self.isAudioQueueRecordingInProgress) {
            reconnect()
        }
    }
    
    public func webSocket(_ webSocket: SRWebSocket!, onCloseWithCode code: Int, reason: String!, wasClean: Bool) {
        NSLog("*******%s********", #function)
        self.webSocket.delegate = nil;
        self.webSocket = nil;
        if(self.isAudioQueueRecordingInProgress){
            reconnect()
        }
    }
    
    public func webSocket(_ webSocket: SRWebSocket!, onReceivePong pongPayload: Data!) {
        
    }
    
    @nonobjc public func webSocket(_ webSocket: SRWebSocket!, onReceiveMessage message: Any!) {
        if let data = message {
            do {
                if let jsonResult = try JSONSerialization.jsonObject(with: (data as AnyObject).data(using: String.Encoding.utf8.rawValue)!, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String:Any] {
                    let status = jsonResult["status"] as! NSNumber
                    if(status.intValue == 0){
                        let dataDictionary = jsonResult["result"] as! [AnyHashable : Any]
                        if (self.onReceiveMessage != nil) {
                            self.onReceiveMessage(dataDictionary)
                        }
                    }
                }
            } catch {
                NSLog("JSON Serializaation failed")
            }
        }
    }
    
    // MARK: MCAudioInputQueueDelegate methods
    
    public func inputQueue(_ inputQueue: MCAudioInputQueue!, errorOccur error: Error!) {
        NSLog("error occured %s", #function)
    }

    public func inputQueue(_ inputQueue: MCAudioInputQueue!, inputData data: Data!, numberOfPackets: UInt32) {
        if self.webSocket.webSocket.readyState == .OPEN {
            if self.audioBuffer.count > 0 {
                self.webSocket.send(self.audioBuffer)
                self.audioBuffer.removeAll()
            }else{
                self.webSocket.send(data)
            }
        }else{
            self.audioBuffer.append(data)
        }
    }
}
