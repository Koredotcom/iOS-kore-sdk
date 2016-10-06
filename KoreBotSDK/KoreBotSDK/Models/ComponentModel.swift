//
//  ComponentModel.swift
//  KoreBotSDK
//
//  Created by Srinivas Vasadi on 30/05/16.
//  Copyright © 2016 Kore. All rights reserved.
//

import UIKit
import Mantle

open class ComponentModel: MTLModel, MTLJSONSerializing {
    // MARK: properties
    open var type: String?
    open var body: String?

    // MARK: MTLJSONSerializing methods
    open static func jsonKeyPathsByPropertyKey() -> [AnyHashable : Any]! {
        return ["body":"body",
                "type":"body"]
    }
}
