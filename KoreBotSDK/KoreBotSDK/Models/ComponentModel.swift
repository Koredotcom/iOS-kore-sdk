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
    open var payload: Any?

    // MARK: MTLJSONSerializing methods
    open static func jsonKeyPathsByPropertyKey() -> [AnyHashable : Any]! {
        return ["type":"type",
                "payload":"payload"
                ]
    }
    
    open static func payloadJSONTransformer() -> ValueTransformer {
        return MTLValueTransformer.reversibleTransformer(forwardBlock: { (payload) in
                return payload
            }, reverse: { (payload) in
                return nil
        })
    }
}
