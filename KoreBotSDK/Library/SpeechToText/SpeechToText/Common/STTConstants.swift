//
//  STTConstants.swift
//  Pods
//
//  Created by developer@kore.com on 24/07/17.
//
//

import Foundation

open class STTConstants: NSObject {
    open static var KORE_BOT_SERVER = "https://qa-speech.kore.ai/"
    open static var voiceContentType = "audio/x-raw,+layout=interleaved,+rate=16000,+format=S16LE,+channels=1"
    open static var kreSpeechServer = "%@content-type=%@"
    struct SocketURL {
        static let baseUrl = KORE_BOT_SERVER
        static let urlPath = "%@asrsocket/dev/start?email=%@"
    }
}
