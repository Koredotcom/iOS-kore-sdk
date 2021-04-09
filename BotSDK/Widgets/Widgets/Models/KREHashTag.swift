//
//  KREHashTag.swift
//  KoreBotSDK
//
//  Created by Sukhmeet Singh on 28/10/19.
//

import UIKit

public class KREHashTag: NSObject, Decodable {
    public var name: String?
    public var count: Int?
    
    public enum KnowledgeItemKeys: String, CodingKey {
        case name = "name"
        case count = "count"
    }
    
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: KnowledgeItemKeys.self)
        name = try? container.decode(String.self, forKey: .name)
        count = try? container.decode(Int.self, forKey: .count)
    }
}
