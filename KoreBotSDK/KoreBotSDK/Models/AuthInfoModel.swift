//
//  AuthInfoModel.swift
//  KoreBotSDK
//
//  Created by Srinivas Vasadi on 24/05/16.
//  Copyright © 2016 Kore. All rights reserved.
//

import UIKit
import Mantle

open class AuthInfoModel : MTLModel, MTLJSONSerializing {
    // MARK: properties
    open var identity: String?
    open var resourceOwnerID: String?
    open var orgID: String?
    open var clientID: String?
    open var sesId: String?
    open var accountId: String?
    open var managedBy: String?
    open var accessToken: String?
    open var refreshToken: String?
    open var tokenType: String?
    open var expiresDate: Date?
    open var refreshExpiresDate: Date?
    open var issuedDate: Date?
    
    // MARK: MTLJSONSerializing methods
    open static func jsonKeyPathsByPropertyKey() -> [AnyHashable : Any]! {
        return ["identity":"identity",
                "resourceOwnerID":"resourceOwnerID",
                "orgID":"orgID",
                "clientID":"clientID",
                "sesId":"sesId",
                "accountId":"accountId",
                "managedBy":"managedBy",
                "accessToken":"accessToken",
                "refreshToken":"refreshToken",
                "tokenType":"token_type"]
    }
}
