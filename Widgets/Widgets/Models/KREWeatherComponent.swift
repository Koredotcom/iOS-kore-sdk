//
//  Widget.swift
//  KoreBotSDK
//
//  Created by Srinivas Vasadi on 11/03/19.
//  Copyright © 2019 Srinivas Vasadi. All rights reserved.
//

import UIKit

// MARK: - KREUser
public class KREUser: NSObject {
    public var userId: String?
    public var userEmail: String?
    public var tokenType: String?
    public var accessToken: String?
    public var server: String?
    public var headers: [String: String]?
}

// MARK: - WeatherWidget
public class KREWeatherComponent: NSObject, Decodable, NSCopying {
    var desc: String?
    var icon: String?
    var iconId: String?
    var temp: String?
    var wId: String?
    var location: [String: String]?
        
    public enum CodingKeys: String, CodingKey {
        case desc, icon, iconId, temp, wId, location
    }
    
    // MARK: - init
    public override init() {
        super.init()
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        desc = try? container.decode(String.self, forKey: .desc)
        icon = try? container.decode(String.self, forKey: .icon)
        iconId = try? container.decode(String.self, forKey: .iconId)
        temp = try? container.decode(String.self, forKey: .temp)
        wId = try? container.decode(String.self, forKey: .wId)
        location = try? container.decode([String: String].self, forKey: .location)
    }
    
    // MARK: - NSCopying
    public func copy(with zone: NSZone? = nil) -> Any {
        let copy = KREWeatherComponent()
        copy.desc = desc
        copy.icon = icon
        copy.iconId = iconId
        copy.temp = temp
        copy.wId = wId
        return copy
    }
}

public class KREWeatherHeader: NSObject, Decodable, NSCopying {
    // MARK: - init
    public var title: String?
    public var message: String?
    public var weather: KREWeatherComponent?
    
    public enum CodingKeys: String, CodingKey {
        case title, message, weather
    }
        
    // MARK: - init
    public override init() {
        super.init()
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try? container.decode(String.self, forKey: .title)
        message = try? container.decode(String.self, forKey: .message)
        weather = try? container.decode(KREWeatherComponent.self, forKey: .weather)
    }
    
    // MARK: - NSCopying
    public func copy(with zone: NSZone? = nil) -> Any {
        let copy = KREWeatherHeader()
        copy.title = title
        copy.message = message
        copy.weather = weather
        return copy
    }
}
