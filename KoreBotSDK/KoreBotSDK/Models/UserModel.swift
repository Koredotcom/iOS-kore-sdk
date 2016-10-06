//
//  UserModel.swift
//  KoreBotSDK
//
//  Created by Srinivas Vasadi on 27/05/16.
//  Copyright © 2016 Kore. All rights reserved.
//

import UIKit
import Mantle

public class UserModel: MTLModel, MTLJSONSerializing {
    
    // MARK: properties
    public var userId: String?
    public var resourceOwnerID: String?
    public var enrollType: String?
    public var orgID: String?
    public var emailId: String?

    // MARK: MTLJSONSerializing methods
    public static func jsonKeyPathsByPropertyKey() -> [AnyHashable : Any]! {
        return ["userId":"id",
                "resourceOwnerID":"resourceOwnerID",
                "enrollType":"enrollType",
                "orgID":"orgID",
                "emailId":"emailId"]
    }
}
