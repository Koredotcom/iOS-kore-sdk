//
//  KREActivity.swift
//  KoraSDK
//
//  Created by Srinivas Vasadi on 04/06/20.
//  Copyright © 2018 Kore Inc. All rights reserved.
//

import UIKit

public class KREActivity: NSObject, Decodable {
    public var title: String?
    public var type: String?
    public var activityTrack: Bool?
    public var templateType: String?
    public var activityInfo: KREActivityInfo?
    
    // MARK: -
    public enum ActivityKeys: String, CodingKey {
        case activityTrack, dial, title, type, url, activityInfo
        case templateType = "template_type"
    }

    // MARK: - init    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ActivityKeys.self)
        title = try? container.decode(String.self, forKey: .title)
        type = try? container.decode(String.self, forKey: .type)
        activityTrack = try? container.decode(Bool.self, forKey: .activityTrack)
        templateType = try? container.decode(String.self, forKey: .templateType)
        activityInfo = try? container.decode(KREActivityInfo.self, forKey: .activityInfo)
    }
}

// MARK: - KREActivityInfo
public class KREActivityInfo: NSObject, Decodable, Encodable {
    public var action: String?
    public var entity: String?
    public var from: String?
    public var entityId: String?
    
    // MARK: -
    public enum ActivityInfoKeys: String, CodingKey {
        case action, entity, from, entityId
    }

    // MARK: - init
    public override init() {
        super.init()
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ActivityInfoKeys.self)
        action = try? container.decode(String.self, forKey: .action)
        entity = try? container.decode(String.self, forKey: .entity)
        from = try? container.decode(String.self, forKey: .from)
        entityId = try? container.decode(String.self, forKey: .entityId)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: ActivityInfoKeys.self)
        try container.encode(action, forKey: .action)
        try container.encode(entity, forKey: .entity)
        try container.encode(from, forKey: .from)
        try container.encode(entityId, forKey: .entityId)
    }
}

// MARK: - KREDialInActivity
public class KREDialInActivity: KREActivity {
    public var dial: String?
    
    public enum DialInKeys: String, CodingKey {
        case dial = "dial"
    }
    
    required public init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: DialInKeys.self)
        dial = try? container.decode(String.self, forKey: .dial)
    }
}

// MARK: - KREURLActivity
public class KREURLActivity: KREActivity {
    public var url: String?
    
    public enum URLKeys: String, CodingKey {
        case url = "url"
    }
    
    required public init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: URLKeys.self)
        url = try? container.decode(String.self, forKey: .url)
    }
}
