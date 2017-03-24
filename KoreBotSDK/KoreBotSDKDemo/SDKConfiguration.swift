//
//  SDKConfiguration.swift
//  KoreBotSDKDemo
//
//  Created by developer@kore.com on 12/16/16.
//  Copyright © 2016 Kore Inc. All rights reserved.
//

import UIKit
import KoreBotSDK

class SDKConfiguration: NSObject {
    struct botConfig {
        static let clientId = "cs-a3d69bdb-996e-5551-b78e-996deb62039f"
        static let clientSecret = "1Jm6IHQt8PfunGjgtV444wfEff3YnwtYd1tjmZElXIY="
        static let identity = "riz@testadmin3.xyz"
        
        static let chatBotName = "BBCConsu"
        static let botId = "st-a03b7d94-8823-568f-b3aa-a0bf80a91e16"
        static let isAnonymous = false
    }
}

open class ServerConfigs: NSObject {
    open static let JWT_SERVER = String(format: "http://50.19.64.173:4000/")
    
    open static func koreJwtUrl() -> String {
        return String(format: "%@api/users/sts", JWT_SERVER)
    }
    
    open static let BOT_SERVER = String(format: "https://pilot-bots.kore.com/")
    open static let BOT_SPEECH_SERVER = String(format: "wss://speech.kore.ai/speechcntxt/verizon")
}
