//
//  JwtModel.swift
//  KoreBotSDK
//
//  Created by developer@kore.com on 27/05/16.
//  Copyright © 2016 Kore Inc. All rights reserved.
//

import UIKit

public class JwtModel: NSObject, Decodable {
    // MARK: - properties
    public var jwtToken: String?
    public var streamId: String?
    public var botName: String?

    enum CodingKeys: String, CodingKey {
        case jwtToken = "jwt"
        case streamId = "streamId"
        case botName = "botName"
    }
    
    // MARK: - init
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        jwtToken = try? container.decode(String.self, forKey: .jwtToken)
        streamId = try? container.decode(String.self, forKey: .streamId)
        botName = try? container.decode(String.self, forKey: .botName)
    }
}

