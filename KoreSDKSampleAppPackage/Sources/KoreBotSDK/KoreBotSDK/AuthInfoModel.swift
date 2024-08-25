//
//  AuthInfoModel.swift
//  KoreBotSDK
//
//  Created by developer@kore.com on 24/05/16.
//  Copyright © 2016 Kore Inc. All rights reserved.
//

import UIKit

public class AuthInfoModel: NSObject, Decodable {
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
    public var expiresDate: Date?
    public var refreshExpiresDate: Date?
    public var issuedDate: Date?
    
    // MARK:
    enum CodingKeys: String, CodingKey {
        case identity = "identity"
        case resourceOwnerID = "resourceOwnerID"
        case orgID = "orgID"
        case clientID = "clientID"
        case sesId = "sesId"
        case accountId = "accountId"
        case managedBy = "managedBy"
        case accessToken = "accessToken"
        case refreshToken = "refreshToken"
        case tokenType = "token_type"
    }
    
    // MARK: - init
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        identity = try? container.decode(String.self, forKey: .identity)
        resourceOwnerID = try? container.decode(String.self, forKey: .resourceOwnerID)
        orgID = try? container.decode(String.self, forKey: .orgID)
        clientID = try? container.decode(String.self, forKey: .clientID)
        sesId = try? container.decode(String.self, forKey: .sesId)
        accountId = try? container.decode(String.self, forKey: .accountId)
        managedBy = try? container.decode(String.self, forKey: .managedBy)
        accessToken = try? container.decode(String.self, forKey: .accessToken)
        refreshToken = try? container.decode(String.self, forKey: .refreshToken)
        tokenType = try? container.decode(String.self, forKey: .tokenType)
    }
}
