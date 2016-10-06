//
//  BotInfoModel.swift
//  KoreBotSDK
//
//  Created by Srinivas Vasadi on 27/05/16.
//  Copyright © 2016 Kore. All rights reserved.
//

import UIKit
import Mantle

public class BotInfoModel: MTLModel, MTLJSONSerializing {
    public var botUrl: String?
    
    // MARK: MTLJSONSerializing methods
    public static func jsonKeyPathsByPropertyKey() -> [AnyHashable : Any]! {
        return ["botUrl":"url"]
    }
}

