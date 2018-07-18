//
//  GoogleTTSService.swift
//  KoreBotSDKDemo
//
//  Created by Shylaja Mamidala on 26/06/18.
//  Copyright © 2018 Kore. All rights reserved.
//

import UIKit
import KoreBotSDK

class GoogleTTSService: NSObject {
    public override init() {
        super.init()
    }
    
    public func initWithSpeechText(text: String, fileUrl: ((_ url: URL?, _ encodeString: String) -> Void)?){
        let ttsManager: TTSHTTPRequestManager = TTSHTTPRequestManager.sharedManager
        
        let parameters: [String: Any] = ["audioConfig":
            ["audioEncoding": "MP3",
             "pitch": "0.00",
             "speakingRate": "1.00"],
                                         "input":
                                            ["text": text],
                                         "voice":
                                            ["languageCode": "en-US",
                                             "name": "en-US-Wavenet-C"]]
        
        ttsManager.doConvertTextToSpeech(with: SDKConfiguration.textToSpeechConfig.speechServerUrl(), Params: parameters, success: { (dataTask, responseObject) in
            let encodedAudioString: String = responseObject!["audioContent"] as! String
            let decodedData = Data(base64Encoded: encodedAudioString, options: [])
            let audioFileURL = self.fileURL(withFileName: "ttsFile.mp3")
            do {
                try decodedData?.write(to: audioFileURL!, options: Data.WritingOptions(rawValue: 0))
            } catch {
                
            }
            fileUrl!(audioFileURL, encodedAudioString)
        }) { (error) in
            print(error)
        }
    }
    
    func fileURL(withFileName fileName: String?) -> URL? {
        let documentDirectory: URL? = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last
        return documentDirectory?.appendingPathComponent(fileName ?? "")
    }
}
