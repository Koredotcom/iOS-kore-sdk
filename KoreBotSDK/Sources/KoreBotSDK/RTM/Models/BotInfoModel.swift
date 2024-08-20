//
//  BotInfoModel.swift
//  KoreBotSDK
//
//  Created by developer@kore.com on 27/05/16.
//  Copyright © 2016 Kore Inc. All rights reserved.
//

import UIKit

public class BotInfoModel: NSObject, Decodable {
    // MARK: - properties
    public var botUrl: String?
        
    enum CodingKeys: String, CodingKey {
        case botUrl = "url"
    }
    
    // MARK: - init
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        botUrl = try? container.decode(String.self, forKey: .botUrl)
    }
}

