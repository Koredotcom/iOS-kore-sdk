//
//  KREWidgetFilter+CoreDataProperties.swift
//  KoreBotSDK
//
//  Created by Srinivas Vasadi on 30/07/19.
//  Copyright © 2019 Srinivas Vasadi. All rights reserved.
//
//

import Foundation

public class KREWidgetFilter: NSObject, Decodable, NSCopying {
    // MARK: - properties
    public var baseHook: Hook?
    public var hook: Hook?
    public var filterId: String?
    public var isSelected: Bool = false
    public var title: String?
    public var isLoading: Bool = false
    public var errorCode: Int64 = 0
    public var requestStatus: Bool = false
    public var component: KREWidgetComponent?
    public var widget: KREWidget?
    public var offset: Int = 0
    
    public enum WidgetFilterKeys: String, CodingKey {
        case hook = "hook"
        case filterId = "id"
        case title = "title"
    }
    
    // MARK: - init
    public override init() {
        super.init()
    }

    required public init(from decoder: Decoder) throws {
        let dataContainer = try decoder.container(keyedBy: WidgetFilterKeys.self)
        baseHook = try? dataContainer.decode(Hook.self, forKey: .hook)
        hook = try? dataContainer.decode(Hook.self, forKey: .hook)
        filterId = try? dataContainer.decode(String.self, forKey: .filterId)
        title = try? dataContainer.decode(String.self, forKey: .title)
    }
  
    // MARK: - NSCopying
    public func copy(with zone: NSZone? = nil) -> Any {
        let copy = KREWidgetFilter()
        copy.isSelected = isSelected
        copy.hook = hook
        copy.title = title
        copy.isLoading = isLoading
        copy.component = component
        copy.widget = widget
        copy.errorCode = errorCode
        copy.requestStatus = requestStatus
        copy.offset = offset
        return copy
    }
}
