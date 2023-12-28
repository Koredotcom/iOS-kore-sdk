//
//  KoraASRService.swift
//  KoreBotSDKDemo
//
//  Created by Srinivas Vasadi on 30/01/19.
//  Copyright © 2019 Kore. All rights reserved.
//

import Foundation
import AVFoundation
import Speech

class KoraASRService: NSObject {
    // MARK: - properties
    let speechRecognizer = SFSpeechRecognizer()
    var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    var recognitionTask: SFSpeechRecognitionTask?
    let audioEngine = AVAudioEngine()
    
    var onError: ((Error?, [String: Any]?) -> Void)?
    var onResponse: ((_ transcript: String, _ isFinal: Bool) -> Void)?
    var speechRecognizerAvailabilityDidChange:((Bool) -> Void)?
    var initialTimeInterval = 5.0
    var idleTimeInterval = 1.0
    var timer: Timer?
    
    static var instance: KoraASRService!
    
    // MARK:- shared instance
    public static let shared: KoraASRService = {
        if (instance == nil) {
            instance = KoraASRService()
        }
        return instance
    }()
    
    func checkAudioRecordPermission(_ block:(() -> Void)?) {
        speechRecognizer?.delegate = self
        SFSpeechRecognizer.requestAuthorization { [weak self] (authStatus) in
            guard let weakSelf = self else {
                return
            }
            OperationQueue.main.addOperation() {
                var alertTitle: String?
                var alertMessage: String?
                var settings = false
                switch authStatus {
                case .authorized:
                    do {
                        try weakSelf.start()
                        block?()
                    } catch {
                        alertTitle = "Speech Recognition"
                        alertMessage = "There was a problem starting the Speech Recognition."
                    }
                case .denied:
                    alertTitle = "Speech Recognition"
                    alertMessage = "Kora needs access to your iPhone’s speech recognition. Tap Settings and turn on Speech Recognition."
                    settings = true
                case .restricted, .notDetermined:
                    alertTitle = "Speech Recognition"
                    alertMessage = "Could not start the Speech Recognition. Please check your internet connection and try again."
                }
                
                if let title = alertTitle, let message = alertMessage {
                    let userInfo: [String: Any] = ["title": title, "message": message, "settings": settings]
                    weakSelf.onError?(nil, userInfo)
                }
            }
        }
    }
    
    private func start() throws {
        if audioEngine.isRunning {
            
        } else {
            print("Start Recording")
            try startRecording()
            startTimer(timeInterval: initialTimeInterval)
        }
    }
    
    func stopRecording() {
        print("Stopping audio recording")
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        
        recognitionRequest = nil
        recognitionTask = nil
        
        timer?.invalidate()
        timer = nil
    }
    
    func startRecording() throws {
        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()
            self.audioEngine.stop()
            self.audioEngine.inputNode.removeTap(onBus: 0)
            self.recognitionTask = nil
            self.recognitionRequest = nil
            self.recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .measurement, options: .defaultToSpeaker)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        guard speechRecognizer?.isAvailable == true else {
            let alertTitle = "Speech Recognition"
            let alertMessage = "Could not start the Speech Recognition. Please check your internet connection and try again."
            let userInfo: [String: Any] = ["title": alertTitle, "message": alertMessage]
            onError?(nil, userInfo)
            return
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        let inputNode = audioEngine.inputNode
        guard let recognitionRequest = recognitionRequest else {
            print("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
            return
        }
        
        recognitionRequest.shouldReportPartialResults = true
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { [weak self] (result, error) in
            var finished = false
            guard let result = result, let weakSelf = self else {
                return
            }
            let transcript = result.bestTranscription.formattedString
            finished = result.isFinal
            self?.onResponse?(transcript, finished)
            
            
            if (finished) {
                //                self?.onResponse?(transcript, finished)
                weakSelf.stopRecording()
            }
            
            weakSelf.startTimer(timeInterval: weakSelf.idleTimeInterval)
        })
        
        let recordingFormat = audioEngine.inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            print("audioBuffer SFSpeechAudioBufferRecognitionRequest installTap")
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        try audioEngine.start()
    }
    
    @objc func cancelRecording() {
        stopRecording()
        recognitionTask?.cancel()
        onError?(nil, [:])
    }
    
    // MARK: -
    func startTimer(timeInterval: TimeInterval) {
        if let timer = self.timer {
            timer.invalidate()
            self.timer = nil
        }
        print(timeInterval)
        let timer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: false) { (timer) in
            self.stopRecording()
            self.recognitionTask?.cancel()
            self.onError?(nil, [:])
        }
        RunLoop.main.add(timer, forMode: RunLoop.Mode.default)
        self.timer = timer
    }
}

// MARK: - SFSpeechRecognizerDelegate
extension KoraASRService: SFSpeechRecognizerDelegate {
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        speechRecognizerAvailabilityDidChange?(available)
    }
}


