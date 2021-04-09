//
//  KREUniversalSearchTemplate.swift
//  KoreBotSDK
//
//  Created by Srinivas Vasadi on 07/01/2020.
//  Copyright © 2019 Srinivas Vasadi. All rights reserved.
//

import UIKit
public enum KRESearchResultType: Int {
    case none, article, email, meetingNotes, knowledgeCollection, files, skill
}

public class KRESearchResult: NSObject, Decodable {
    // MARK: - properties
    public var title: String?
    public var elements: [KRESearchResultElement]?
    public var expiryMsg: String?
    public var isAuthRequired: Bool?
    public var askExpert: KREAskExpert?
    public enum CodingKeys: String, CodingKey {
        case title = "title"
        case elements = "elements"
        case expiryMsg = "expiryMsg"
        case isAuthRequired = "isAuthRequired"
        case askExpert = "askExpert"
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try? container.decode(String.self, forKey: .title)
        elements = try? container.decode([KRESearchResultElement].self, forKey: .elements)
        expiryMsg = try? container.decode(String.self, forKey: .expiryMsg)
        isAuthRequired = try? container.decode(Bool.self, forKey: .isAuthRequired)
        askExpert = try? container.decode(KREAskExpert.self, forKey: .askExpert)
    }
}

public class KREAskExpert: NSObject, Decodable {
    // MARK: - properties
    public var title: String?
    public var defaultAction: KREAction?
    
    public enum CodingKeys: String, CodingKey {
        case title = "text"
        case defaultAction = "defaultAction"
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try? container.decode(String.self, forKey: .title)
        defaultAction = try? container.decode(KREAction.self, forKey: .defaultAction)
    }
}

public class KRESearchResultElement: NSObject, Decodable {
    // MARK: - properties
    public var title: String?
    public var count: Int64?
    public var elements: [Decodable]?
    public var knowledgeCollElement: Decodable?
    public var type: String?
    public var resultType: KRESearchResultType = .none
    public var icon: String?
    public enum CodingKeys: String, CodingKey {
        case title = "title"
        case count = "count"
        case elements = "elements"
        case type = "type"
        case icon = "icon"
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try? container.decode(String.self, forKey: .title)
        count = try? container.decode(Int64.self, forKey: .count)
        type = try? container.decode(String.self, forKey: .type)
        icon = try? container.decode(String.self, forKey: .icon)
        switch type {
        case "Email":
            resultType = .email
            elements = try? container.decode([KAEmailCardInfo].self, forKey: .elements)
        case "Article":
            resultType = .article
            elements = try? container.decode([KREKnowledgeItem].self, forKey: .elements)
        case "MeetingNotes":
            resultType = .meetingNotes
            elements = try? container.decode([KRECalendarEvent].self, forKey: .elements)
        case "KnowledgeCollection":
            resultType = .knowledgeCollection
            knowledgeCollElement = try? container.decode(KREKnowledgeCollectionElement.self, forKey: .elements)
        case "Files":
            resultType = .files
            elements = try? container.decode([KADriveFileInfo].self, forKey: .elements)
        case "Skill":
            resultType = .skill
            elements = try? container.decode([KRESearchSkillData].self, forKey: .elements)
        default:
            resultType = .none
            break
        }
    }
}
