//
//  KREASRService.swift
//  KoraSDK
//
//  Created by Srinivas Vasadi on 24/01/19.
//  Copyright © 2019 Srinivas Vasadi. All rights reserved.
//


import Foundation
import AVFoundation
import Speech

public class KREASRService: NSObject {
    // MARK: - properties
    let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    var recognitionTask: SFSpeechRecognitionTask?
    let audioEngine = AVAudioEngine()
    let queue = DispatchQueue(label: "com.kora.asr")
    public var onError: ((Error?, [String: Any]?) -> Void)?
    public var onResponse: ((_ transcript: String, _ isFinal: Bool) -> Void)?
    public var processTranscript:(() -> Void)?
    public var speechRecognizerAvailabilityDidChange:((Bool) -> Void)?
    var idleTimeInterval = 1.0
    var timer: Timer?
    var counter: Int = 0
    public var peakOutputPower: CGFloat = -1.0
    public var transcripitons: [SFTranscription]?
    static var instance: KREASRService!
    
    // MARK:- shared instance
    public static let shared: KREASRService = {
        if (instance == nil) {
            instance = KREASRService()
        }
        return instance
    }()
    
    public func checkAudioRecordPermission(_ block:(() -> Void)?) {
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
                        alertTitle = NSLocalizedString("Speech Recognition", comment: "Speech Recognition")
                        alertMessage = NSLocalizedString("There was a problem starting the Speech Recognition.", comment: "There was a problem starting the Speech Recognition")
                    }
                case .denied:
                    alertTitle = NSLocalizedString("Speech Recognition", comment: "Speech Recognition")
                    alertMessage = NSLocalizedString("Kora needs access to your iPhone’s speech recognition. Tap Settings and turn on Speech Recognition.", comment: "Kora needs access to your iPhone’s speech recognition. Tap Settings and turn on Speech Recognition.")
                    settings = true
                case .restricted, .notDetermined:
                    alertTitle = NSLocalizedString("Speech Recognition", comment: "Speech Recognition")
                    alertMessage = NSLocalizedString("Could not start the Speech Recognition. Please check your internet connection and try again.", comment: "Could not start the Speech Recognition. Please check your internet connection and try again.")
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
            debugPrint("Start Recording")
            try startRecording()
            startWaitTimer()
        }
    }
    
    public func stopRecording() {
        if audioEngine.isRunning {
            debugPrint("Stopping audio recording")
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
            recognitionRequest?.endAudio()
            
            recognitionRequest = nil
            recognitionTask = nil
        }
        timer?.invalidate()
        timer = nil
        
        peakOutputPower = -1.0
        counter = 0
        transcripitons = nil
    }
    
    public func startRecording() throws {
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
            try audioSession.setCategory(.playAndRecord, mode: .measurement, options: [])
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            debugPrint("audioSession properties weren't set because of an error.")
        }
        
        transcripitons = [SFTranscription]()
        guard speechRecognizer?.isAvailable == true else {
            let alertTitle = NSLocalizedString("Speech Recognition", comment: "Speech Recognition")
            let alertMessage = NSLocalizedString("Could not start the Speech Recognition. Please check your internet connection and try again.", comment: "Could not start the Speech Recognition. Please check your internet connection and try again.")
            let userInfo: [String: Any] = ["title": alertTitle, "message": alertMessage]
            onError?(nil, userInfo)
            return
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        let inputNode = audioEngine.inputNode
        guard let recognitionRequest = recognitionRequest else {
            debugPrint("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
            return
        }
        
        recognitionRequest.shouldReportPartialResults = true
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { [weak self] (result, error) in
            guard let result = result, let weakSelf = self else {
                return
            }
            let finished = result.isFinal
            let transcript = result.bestTranscription.formattedString
            if !finished {
                weakSelf.onResponse?(transcript, finished)
            }
            
            weakSelf.transcripitons?.append(contentsOf: result.transcriptions)
            weakSelf.queue.sync {
                weakSelf.counter = 0
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] (buffer, when) in
            guard let weakSelf = self else {
                return
            }
            
            weakSelf.recognitionRequest?.append(buffer)
            
            // test if channel data is present.
            guard let channelData = buffer.floatChannelData else {
                return
            }
            
            // get channel data
            let channelDataValue = channelData.pointee
            let channelDataValueArray = stride(from: 0, to: Int(buffer.frameLength), by: buffer.stride).map{ channelDataValue[$0] }
            
            // calculate value
            let mapReduceResult = channelDataValueArray.map{ $0 * $0 }.reduce(0, +)
            let performDivision = mapReduceResult / Float(buffer.frameLength)
            let rms = sqrt(performDivision)
            let avgPower = 20 * log10(rms)
            let meterLevel = weakSelf.scaledPower(power: CGFloat(avgPower))
            weakSelf.peakOutputPower = meterLevel
        }
        
        audioEngine.prepare()
        try audioEngine.start()
    }
    
    @objc func cancelRecording() {
        stopRecording()
        recognitionTask?.cancel()
    }
    
    // MARK: -
    func startWaitTimer() {
        self.timer?.invalidate()
        self.timer = nil

        let timer = Timer.scheduledTimer(withTimeInterval: idleTimeInterval, repeats: true) { [weak self] (timer) in
            guard let weakSelf = self else {
                return
            }
            
            let transcripitonsCount = weakSelf.transcripitons?.count ?? 0
            if transcripitonsCount == 0 && weakSelf.counter > 3 {
                weakSelf.recognitionTask?.cancel()
                weakSelf.stopRecording()
                weakSelf.onError?(nil, [:])
            } else if transcripitonsCount > 0 && weakSelf.counter > 1 {
                weakSelf.recognitionTask?.cancel()
                weakSelf.stopRecording()
                weakSelf.processTranscript?()
            }
            weakSelf.queue.sync {
                weakSelf.counter = weakSelf.counter + 1
            }
        }
        RunLoop.main.add(timer, forMode: RunLoop.Mode.default)
        self.timer = timer
    }
    
    private func scaledPower(power: CGFloat) -> CGFloat {
        guard power.isFinite else {
            return 0.0
        }
        if power < -80.0 {
            return 0.0
        } else if power >= 1.0 {
            return 1.0
        } else {
            return (abs(-80.0) - abs(power)) / abs(-80.0)
        }
    }
}

// MARK: - SFSpeechRecognizerDelegate
extension KREASRService: SFSpeechRecognizerDelegate {
//    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
//        speechRecognizerAvailabilityDidChange?(available)
//    }
}

