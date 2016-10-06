//
//  AuthInfoModel.swift
//  KoreBotSDK
//
//  Created by Srinivas Vasadi on 24/05/16.
//  Copyright © 2016 Kore. All rights reserved.
//

import UIKit
import Mantle

public class AuthInfoModel : MTLModel, MTLJSONSerializing {
    // MARK: properties
    public var identity: String?
    public var resourceOwnerID: String?
    public var orgID: String?
    public var clientID: String?
    public var sesId: String?
    public var accountId: String?
    public var managedBy: String?
    public var accessToken: String?
    public var refreshToken: String?
    public var tokenType: String?
    public var expiresDate: NSDate?
    public var refreshExpiresDate: NSDate?
    public var issuedDate: NSDate?
    
    // MARK: MTLJSONSerializing methods
    public static func jsonKeyPathsByPropertyKey() -> [AnyHashable : Any]! {
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
