//
//  ComponentModel.swift
//  KoreBotSDK
//
//  Created by Srinivas Vasadi on 30/05/16.
//  Copyright © 2016 Kore. All rights reserved.
//

import UIKit
import Mantle

public class ComponentModel: MTLModel, MTLJSONSerializing {
    // MARK: properties
    public var type: String?
    public var body: String?

    // MARK: MTLJSONSerializing methods
    public static func jsonKeyPathsByPropertyKey() -> [AnyHashable : Any]! {
        return ["body":"body",
                "type":"body"]
    }
}
