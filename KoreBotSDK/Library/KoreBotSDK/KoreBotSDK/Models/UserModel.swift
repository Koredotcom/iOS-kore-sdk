//
//  UserModel.swift
//  KoreBotSDK
//
//  Created by developer@kore.com on 27/05/16.
//  Copyright © 2016 Kore Inc. All rights reserved.
//

import UIKit
import Mantle

open class UserModel: MTLModel, MTLJSONSerializing {
    
    // MARK: properties
    @objc open var userId: String?
    @objc open var resourceOwnerID: String?
    @objc open var enrollType: String?
    @objc open var orgID: String?
    @objc open var emailId: String?
    @objc open var identity: String?

    // MARK: MTLJSONSerializing methods
    open static func jsonKeyPathsByPropertyKey() -> [AnyHashable : Any]! {
        return ["userId":"id",
                "resourceOwnerID":"resourceOwnerID",
                "enrollType":"enrollType",
                "orgID":"orgID",
                "emailId":"emailId",
                "identity":"identity"]
    }
}
