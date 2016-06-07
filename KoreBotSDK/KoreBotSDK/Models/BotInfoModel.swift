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
    public static func JSONKeyPathsByPropertyKey() -> [NSObject : AnyObject]! {
        return ["botUrl":"url"]
    }
}

