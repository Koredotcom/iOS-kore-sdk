//
//  JwtModel.swift
//  KoreBotSDK
//
//  Created by developer@kore.com on 27/05/16.
//  Copyright © 2016 Kore Inc. All rights reserved.
//

import UIKit
import Mantle

open class JwtModel: MTLModel, MTLJSONSerializing {
    @objc open var jwtToken: String?
    
    // MARK: MTLJSONSerializing methods
    open static func jsonKeyPathsByPropertyKey() -> [AnyHashable : Any]! {
        return ["jwtToken":"jwt"]
    }
}
