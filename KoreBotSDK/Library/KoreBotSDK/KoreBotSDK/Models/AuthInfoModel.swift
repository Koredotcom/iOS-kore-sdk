//
//  AuthInfoModel.swift
//  KoreBotSDK
//
//  Created by developer@kore.com on 24/05/16.
//  Copyright © 2016 Kore Inc. All rights reserved.
//

import UIKit
import Mantle

open class AuthInfoModel : MTLModel, MTLJSONSerializing {
    // MARK: properties
    @objc open var identity: String?
    @objc open var resourceOwnerID: String?
    @objc open var orgID: String?
    @objc open var clientID: String?
    @objc open var sesId: String?
    @objc open var accountId: String?
    @objc open var managedBy: String?
    @objc open var accessToken: String?
    @objc open var refreshToken: String?
    @objc open var tokenType: String?
    @objc open var expiresDate: Date?
    @objc open var refreshExpiresDate: Date?
    @objc open var issuedDate: Date?
    
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
