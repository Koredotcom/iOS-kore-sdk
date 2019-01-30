//
//  ComponentModel.swift
//  KoreBotSDK
//
//  Created by developer@kore.com on 30/05/16.
//  Copyright © 2016 Kore Inc. All rights reserved.
//

import UIKit
import Mantle

open class ComponentModel: MTLModel, MTLJSONSerializing {
    // MARK: properties
    @objc open var type: String?
    @objc open var body: String?
    @objc open var payload: Any?

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
