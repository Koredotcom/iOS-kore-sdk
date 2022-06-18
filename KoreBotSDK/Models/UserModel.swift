//
//  UserModel.swift
//  KoreBotSDK
//
//  Created by developer@kore.com on 27/05/16.
//  Copyright © 2016 Kore Inc. All rights reserved.
//

import UIKit

public class UserModel: NSObject, Decodable {
    // MARK: - properties
    public var userId: String?
    public var resourceOwnerID: String?
    public var enrollType: String?
    public var orgID: String?
    public var emailId: String?
    public var identity: String?
    
    enum CodingKeys: String, CodingKey {
        case userId = "userId"
        case resourceOwnerID = "resourceOwnerID"
        case enrollType = "enrollType"
        case orgID = "orgId"
        case emailId = "emailId"
        case identity = "identity"
    }
    
    // MARK: - init
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        userId = try? container.decode(String.self, forKey: .userId)
        resourceOwnerID = try? container.decode(String.self, forKey: .resourceOwnerID)
        enrollType = try? container.decode(String.self, forKey: .enrollType)
        orgID = try? container.decode(String.self, forKey: .orgID)
        emailId = try? container.decode(String.self, forKey: .emailId)
        identity = try? container.decode(String.self, forKey: .identity)
    }
}
