//
//  KREKnowledgeCollectionItem.swift
//  KoreBotSDK
//
//  Created by Srinivas Vasadi on 07/01/2020.
//  Copyright © 2019 Srinivas Vasadi. All rights reserved.
//

import UIKit

public class KREKnowledgeCollectionItem: NSObject, Decodable {
    // MARK: - properties
    public var elements: KREKnowledgeCollectionElement?
    public var title: String?
    public var type: String?

    public enum CodingKeys: String, CodingKey {
        case elements = "elements"
        case title = "title"
        case type = "type"
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        elements = try? container.decode(KREKnowledgeCollectionElement.self, forKey: .elements)
        title = try? container.decode(String.self, forKey: .title)
        type = try? container.decode(String.self, forKey: .type)
    }
}

public class KREKnowledgeCollectionElement: NSObject, Decodable {
    // MARK: - properties
    public var definitive: [KREKnowledgeCollectionElementData]?
    public var suggestive: [KREKnowledgeCollectionElementData]?
    
    
    public enum CodingKeys: String, CodingKey {
        case definitive = "definitive"
        case suggestive = "suggestive"
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        definitive = try? container.decode([KREKnowledgeCollectionElementData].self, forKey: .definitive)
        suggestive = try? container.decode([KREKnowledgeCollectionElementData].self, forKey: .suggestive)
    }
}

public class KREKnowledgeCollectionElementData: NSObject, Decodable {
    // MARK: - properties
    public var question: String?
    public var score: Double?
    public var name: String?
    public var answerPayload: [KREKnowledgeCollectionAnswerPayload]?
    public var type = "definitive"

    
    public enum CodingKeys: String, CodingKey {
        case question = "question"
        case score = "score"
        case name = "name"
        case answerPayload = "answerPayload"
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        question = try? container.decode(String.self, forKey: .question)
        score = try? container.decode(Double.self, forKey: .score)
        name = try? container.decode(String.self, forKey: .name)
        answerPayload = try? container.decode([KREKnowledgeCollectionAnswerPayload].self, forKey: .answerPayload)
    }
}

public class KREKnowledgeCollectionAnswerPayload: NSObject, Decodable {
    // MARK: - properties
    public var _id: String?
    public var text: String?

    
    public enum CodingKeys: String, CodingKey {
        case _id = "_id"
        case text = "text"
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        _id = try? container.decode(String.self, forKey: ._id)
        text = try? container.decode(String.self, forKey: .text)
    }
}
