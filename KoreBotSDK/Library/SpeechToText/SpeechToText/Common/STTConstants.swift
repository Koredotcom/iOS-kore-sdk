//
//  STTConstants.swift
//  Pods
//
//  Created by developer@kore.com on 24/07/17.
//  Copyright © 2017 Kore Inc. All rights reserved.
//
//

import Foundation

open class STTConstants: NSObject {
    open static var KORE_SPEECH_SERVER = "https://qa-speech.kore.ai/"
    struct SpeechServer {
        static let baseUrl = KORE_SPEECH_SERVER
        static let urlPath = "%@asr/wss/start?email=%@"
    }
    struct SocketURL {
        static let urlFormat = "%@&content-type=%@"
    }
    open static var voiceContentType = "audio/x-raw,+layout=interleaved,+rate=16000,+format=S16LE,+channels=1"
}
