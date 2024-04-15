//
//  TaskList.swift
//  KoraSDK
//
//  Created by Sowmya Ponangi on 09/12/18.
//  Copyright © 2018 Srinivas Vasadi. All rights reserved.
//

import UIKit

public class KREKnowledgeItem: NSObject, Decodable {
    public var createdOn: Int64?
    public var creator: String?
    public var desc: String?
    public var details: NSObject?
    public var followers: NSObject?
    public var hashtags: [String]?
    public var imageUrl: String?
    public var knowledgeId: String?
    public var lastModified: Int64?
    public var nComments: Int64?
    public var nDownVotes: Int64?
    public var nFollows: Int64?
    public var nLikes: Int64?
    public var nShares: Int64?
    public var nUpVotes: Int64?
    public var nViews: Int64?
    public var owner: KREContacts?
    public var privilege: Int64?
    public var sharedList: [KREContacts]?
    public var sortDay: Date?
    public var title: String?
    public var scope: String?
    public var type: Int64?
    public var isAnnounement = false
    public var isSeedData: Bool?
    public var sharedOn: Int64?
    
    public enum KnowledgeItemKeys: String, CodingKey {
        case createdOn = "createdOn"
        case creator = "creator"
        case desc = "desc"
        case details = "details"
        case followers = "followers"
        case hashtags = "hashtags"
        case imageUrl = "imageUrl"
        case knowledgeId = "id"
        case lastModified = "lastMod"
        case nComments = "nComments"
        case nDownVotes = "nDownVotes"
        case nFollows = "nFollows"
        case nLikes = "nLikes"
        case nShares = "nShares"
        case nUpVotes = "nUpVotes"
        case nViews = "nViews"
        case owner = "owner"
        case privilege = "privilege"
        case sharedList = "sharedList"
        case sortDay = "sortDay"
        case title = "title"
        case type = "type"
        case scope = "scope"
        case isSeedData = "isSeedData"
        case sharedOn = "sharedOn"
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: KnowledgeItemKeys.self)
        createdOn = try? container.decode(Int64.self, forKey: .createdOn)
        creator = try? container.decode(String.self, forKey: .creator)
        desc = try? container.decode(String.self, forKey: .desc)
        hashtags = try? container.decode([String].self, forKey: .hashtags)
        imageUrl = try? container.decode(String.self, forKey: .imageUrl)
        knowledgeId = try? container.decode(String.self, forKey: .knowledgeId)
        lastModified = try? container.decode(Int64.self, forKey: .lastModified)
        nComments = try? container.decode(Int64 .self, forKey: .nComments)
        nDownVotes = try? container.decode(Int64 .self, forKey: .nDownVotes)
        nFollows = try? container.decode(Int64 .self, forKey: .nFollows)
        nLikes = try? container.decode(Int64 .self, forKey: .nLikes)
        nShares = try? container.decode(Int64 .self, forKey: .nShares)
        nUpVotes = try? container.decode(Int64 .self, forKey: .nUpVotes)
        nViews = try? container.decode(Int64 .self, forKey: .nViews)
        owner = try? container.decode(KREContacts.self, forKey: .owner)
        privilege = try? container.decode(Int64 .self, forKey: .privilege)
        sharedList = try? container.decode([KREContacts].self, forKey: .sharedList)
        sortDay = try? container.decode(Date.self, forKey: .sortDay)
        title = try? container.decode(String.self, forKey: .title)
        type = try? container.decode(Int64 .self, forKey: .type)
        isSeedData = try? container.decode(Bool.self, forKey: .isSeedData)
        sharedOn = try? container.decode(Int64.self, forKey: .createdOn)
        scope = try? container.decode(String.self, forKey: .scope)
    }
}
