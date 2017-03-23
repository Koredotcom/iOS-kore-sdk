//
//  JwtModel.swift
//  KoreBotSDK
//
//  Created by Srinivas Vasadi on 27/05/16.
//  Copyright © 2016 Kore. All rights reserved.
//

import UIKit
import Mantle

open class JwtModel: MTLModel, MTLJSONSerializing {
    open var jwtToken: String?
    
    // MARK: MTLJSONSerializing methods
    open static func jsonKeyPathsByPropertyKey() -> [AnyHashable : Any]! {
        return ["jwtToken":"jwt"]
    }
}
