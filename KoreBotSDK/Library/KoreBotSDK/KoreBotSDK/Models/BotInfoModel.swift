//
//  BotInfoModel.swift
//  KoreBotSDK
//
//  Created by Srinivas Vasadi on 27/05/16.
//  Copyright © 2016 Kore. All rights reserved.
//

import UIKit
import Mantle

open class BotInfoModel: MTLModel, MTLJSONSerializing {
    open var botUrl: String?
    
    // MARK: MTLJSONSerializing methods
    open static func jsonKeyPathsByPropertyKey() -> [AnyHashable : Any]! {
        return ["botUrl":"url"]
    }
}

