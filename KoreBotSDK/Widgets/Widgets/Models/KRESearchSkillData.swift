//
//  KRESearchSkillData.swift
//  KoreBotSDK
//
//  Created by Sukhmeet Singh on 13/03/20.
//

import UIKit

public class KRESearchSkillData: NSObject, Decodable {
    public var lMod: String?
    public var title: String?
    public var cOn: String?
    public var desc: String?
    public var rating: String?
    public var defaultAction: KREAction?
    
    public enum KnowledgeItemKeys: String, CodingKey {
        case title = "title"
        case lMod = "lMod"
        case desc = "desc"
        case cOn = "cOn"
        case rating = "rating"
        case defaultAction = "defaultAction"
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: KnowledgeItemKeys.self)
        lMod = try? container.decode(String.self, forKey: .lMod)
        title = try? container.decode(String.self, forKey: .title)
        cOn = try? container.decode(String.self, forKey: .cOn)
        desc = try? container.decode(String.self, forKey: .desc)
        rating = try? container.decode(String.self, forKey: .rating)
        defaultAction = try? container.decode(KREAction.self, forKey: .defaultAction)
    }
}
