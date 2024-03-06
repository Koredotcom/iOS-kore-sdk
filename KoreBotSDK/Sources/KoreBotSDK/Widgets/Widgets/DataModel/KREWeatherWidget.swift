//
//  KREWeatherWidget+CoreDataProperties.swift
//  KoreBotSDK
//
//  Created by Srinivas Vasadi on 02/04/19.
//  Copyright © 2019 Srinivas Vasadi. All rights reserved.
//
//

import Foundation

public class KREWeatherWidget: NSObject, Decodable {
    public var api: String?
    public var cacheInterval: String?
    public var message: String?
    public var refreshInterval: String?
    public var title: String?
    public var weatherComponent: Any?
    public var query: [String]?
    
    public enum WidgetKeys: String, CodingKey {
        case api = "api"
        case cacheInterval = "cache_interval"
        case refreshInterval = "refresh_interval"
        case title = "title"
        case message = "message"
        case query = "query"
    }
    
    // MARK: - init
    public override init() {
        super.init()
    }

    required public init(from decoder: Decoder) throws {
        let dataContainer = try decoder.container(keyedBy: WidgetKeys.self)
        api = try? dataContainer.decode(String.self, forKey: .api)
        cacheInterval = try? dataContainer.decode(String.self, forKey: .cacheInterval)
        refreshInterval = try? dataContainer.decode(String.self, forKey: .refreshInterval)
        title = try? dataContainer.decode(String.self, forKey: .title)
        message = try? dataContainer.decode(String.self, forKey: .message)
        query = try? dataContainer.decode([String].self, forKey: .query)
    }
}
