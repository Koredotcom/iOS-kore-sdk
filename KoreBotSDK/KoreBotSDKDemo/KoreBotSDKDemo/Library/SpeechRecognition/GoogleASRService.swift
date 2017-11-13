//
//  GoogleASRService.swift
//  KoreBotSDKDemo
//
//  Created by Anoop Dhiman on 11/10/17.
//  Copyright © 2017 Kore. All rights reserved.
//

import Foundation
import AVFoundation
import googleapis

class GoogleASRService: AudioControllerDelegate {
    var retryCount: Int = 0
    var audioData: NSMutableData!
    let sample_rate = 16000
    
    open var onError: ((Error) -> Void)!
    open var onResponse: ((_ transcript: String, _ isFinal: Bool) -> Void)!

    init() {
        AudioController.sharedInstance.delegate = self
    }
    
    static func checkAudioRecordPermission(block:(() -> Void)?) {
        let audioSession = AVAudioSession.sharedInstance()
        if (audioSession.responds(to: #selector(AVAudioSession.requestRecordPermission(_:)))) {
            audioSession.requestRecordPermission({ (granted: Bool) in
                if(granted){
                    DispatchQueue.main.async {
                        block!()
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
    
    func start() {
        NSLog("Starting audio recording")
        
        audioData = NSMutableData()
        _ = AudioController.sharedInstance.prepare(specifiedSampleRate: sample_rate)
        SpeechRecognitionService.sharedInstance.sampleRate = sample_rate
        _ = AudioController.sharedInstance.start()
    }
    
    func stop() {
        NSLog("Stopping audio recording")
        
        _ = AudioController.sharedInstance.stop()
        SpeechRecognitionService.sharedInstance.stopStreaming()
    }
    
    internal func processSampleData(_ data: Data) -> Void {
        audioData.append(data)
        
        // We recommend sending samples in 100ms chunks
        let chunkSize : Int /* bytes/chunk */ = Int(0.1 /* seconds/chunk */
            * Double(sample_rate) /* samples/second */
            * 2 /* bytes/sample */);
        
        if (audioData.length > chunkSize) {
            SpeechRecognitionService.sharedInstance.streamAudioData(audioData, completion:{ [weak self] (response, error) in
                guard let strongSelf = self else {
                    return
                }
                
                if let error = error {
                    NSLog("SpeechRecognitionService failed with error: %@", error.debugDescription)
                    strongSelf.stop()
                    if strongSelf.retryCount == 3 {
                        strongSelf.retryCount = 0
                        if strongSelf.onError != nil {
                            strongSelf.onError(error)
                        }
                    }else{
                        let deadline = DispatchTime.now() + .milliseconds(100)
                        DispatchQueue.main.asyncAfter(deadline: deadline) {
                            strongSelf.retryCount += 1
                            strongSelf.start()
                        }
                    }
                } else if let response = response {
                    strongSelf.retryCount = 0
                    var finished = false
                    var transcript = ""
                    
                    for result in response.resultsArray! {
                        if let result = result as? StreamingRecognitionResult {
                            if result.isFinal {
                                finished = true
                                strongSelf.stop()
                                if let speechResult = result.alternativesArray[0] as? SpeechRecognitionAlternative {
                                    transcript = speechResult.transcript
                                }
                            }else{
                                if let speechResult = result.alternativesArray[0] as? SpeechRecognitionAlternative {
                                    transcript += speechResult.transcript
                                }
                            }
                        }
                    }
                    if finished {
                        strongSelf.stop()
                    }
                    
                    if strongSelf.onResponse != nil {
                        strongSelf.onResponse(transcript, finished)
                    }
                }
            })
            self.audioData = NSMutableData()
        }
    }
}
