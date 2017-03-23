//
//  UserModel.swift
//  KoreBotSDK
//
//  Created by Srinivas Vasadi on 27/05/16.
//  Copyright © 2016 Kore. All rights reserved.
//

import UIKit
import Mantle

open class UserModel: MTLModel, MTLJSONSerializing {
    
    // MARK: properties
    open var userId: String?
    open var resourceOwnerID: String?
    open var enrollType: String?
    open var orgID: String?
    open var emailId: String?

    // MARK: MTLJSONSerializing methods
    open static func jsonKeyPathsByPropertyKey() -> [AnyHashable : Any]! {
        return ["userId":"id",
                "resourceOwnerID":"resourceOwnerID",
                "enrollType":"enrollType",
                "orgID":"orgID",
                "emailId":"emailId"]
    }
}
