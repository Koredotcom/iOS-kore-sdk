//
//  BotInfoModel.swift
//  KoreBotSDK
//
//  Created by developer@kore.com on 27/05/16.
//  Copyright © 2016 Kore Inc. All rights reserved.
//

import UIKit
import Mantle

open class BotInfoModel: MTLModel, MTLJSONSerializing {
    @objc open var botUrl: String?
    
    // MARK: MTLJSONSerializing methods
    open static func jsonKeyPathsByPropertyKey() -> [AnyHashable : Any]! {
        return ["botUrl":"url"]
    }
}

