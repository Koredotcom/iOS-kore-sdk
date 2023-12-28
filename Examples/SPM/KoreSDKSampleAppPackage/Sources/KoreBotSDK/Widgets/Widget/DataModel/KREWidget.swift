//
//  KREWidget+CoreDataProperties.swift
//  KoreBotSDK
//
//  Created by Srinivas Vasadi on 04/04/19.
//  Copyright © 2019 Srinivas Vasadi. All rights reserved.
//
//

import Foundation

public enum WidgetState {
    case loading
    case loaded
    case refreshed
    case refreshing
    case noNetwork
    case noData
    case requestFailed
    case none
}

public class KREWidget: NSObject, Decodable, NSCopying {
    // MARK: - properties
    public var hook: Hook?
    public var baseHook: Hook?
    public var cacheInterval: String?
    public var lastUpdatedDate: NSDate?
    public var refreshInterval: String?
    public var sortOrder: Int16 = -1
    public var summary: String?
    public var summaryPlaceholder: String?
    public var themeColor: String?
    public var title: String?
    public var trigger: String?
    public var templateType: String?
    public var type: String?
    public var elements: [KRESummaryElement]?
    public var utterances: [KREAction]?
    public var widgetId: String?
    public var filters: [KREWidgetFilter]?
    public var utterancesHeader: String?
    public var widgetState: WidgetState = .none
    public var priority: Bool?
    public var lastSyncDate: Date?
    public var previewLength: Int = 3
    public var offset: Int = 0
    public var pinned: Bool?
    public var _id: String?
    public weak var dataSource: KREWidgetViewDataSource?
    
    public enum WidgetKeys: String, CodingKey {
        case hook = "hook"
        case cacheInterval = "cache_interval"
        case filters = "filters"
        case widgetId = "id"
        case title = "title"
        case refreshInterval = "refresh_interval"
        case summaryPlaceholder = "summary_placeholder"
        case themeColor = "theme"
        case type = "type"
        case utterances = "utterances"
        case utterancesHeader = "utterances_header"
        case priority = "priority"
        case templateType = "templateType"
        case previewLength = "previewLength"
        case pinned = "pinned"
        case elements = "elements"
        case _id = "_id"
        case trigger = "trigger"
    }
    
    // MARK: - init
    public override init() {
        super.init()
    }
    
    public func copy(with zone: NSZone? = nil) -> Any {
        let copy = KREWidget()
        copy.baseHook = baseHook
        copy.hook = hook
        copy.pinned = pinned
        copy.cacheInterval = cacheInterval
        copy.lastUpdatedDate = lastUpdatedDate
        copy.refreshInterval = refreshInterval
        copy.sortOrder = sortOrder
        copy.summary = summary
        copy.summaryPlaceholder = summaryPlaceholder
        copy.themeColor = themeColor
        copy.title = title
        copy.type = type
        copy.utterances = utterances
        copy.widgetId = widgetId
        copy.filters = filters
        copy.utterancesHeader = utterancesHeader
        copy.templateType = templateType
        copy.previewLength = previewLength
        copy.offset = offset
        copy._id = _id
        copy.trigger = trigger
        copy.widgetState = widgetState
        return copy
    }

    required public init(from decoder: Decoder) throws {
        let dataContainer = try decoder.container(keyedBy: WidgetKeys.self)
        baseHook = try? dataContainer.decode(Hook.self, forKey: .hook)
        hook = try? dataContainer.decode(Hook.self, forKey: .hook)
        cacheInterval = try? dataContainer.decode(String.self, forKey: .cacheInterval)
        refreshInterval = try? dataContainer.decode(String.self, forKey: .refreshInterval)
        summaryPlaceholder = try? dataContainer.decode(String.self, forKey: .summaryPlaceholder)
        filters = try? dataContainer.decode([KREWidgetFilter].self, forKey: .filters)
        if filters == nil {
            let filter = KREWidgetFilter()
            filter.hook = hook
            filter.baseHook = hook
            filters?.append(filter)
        }
        elements = try? dataContainer.decode([KRESummaryElement].self, forKey: .elements)
        themeColor = try? dataContainer.decode(String.self, forKey: .themeColor)
        trigger = try? dataContainer.decode(String.self, forKey: .trigger)
        type = try? dataContainer.decode(String.self, forKey: .type)
        _id = try? dataContainer.decode(String.self, forKey: ._id)
        utterancesHeader = try? dataContainer.decode(String.self, forKey: .utterancesHeader)
        widgetId = try? dataContainer.decode(String.self, forKey: .widgetId)
        title = try? dataContainer.decode(String.self, forKey: .title)
        priority = try? dataContainer.decode(Bool.self, forKey: .priority)
        utterances = try? dataContainer.decode([KREAction].self, forKey: .utterances)
        pinned = try? dataContainer.decode(Bool.self, forKey: .pinned)
        templateType = try? dataContainer.decode(String.self, forKey: .templateType)
        if let value = try? dataContainer.decode(Int.self, forKey: .previewLength) {
            previewLength = value
        }
    }
}

// MARK: -
public class KRESummaryElement: KREAction, NSCopying {
    public var _id: String?
    public var hook: Hook?
    public var icon: String?
    public var placeHolder: String?
    
    public enum SummaryElementKeys: String, CodingKey {
        case placeHolder = "paceHolder"
        case _id = "_id"
        case hook = "hook"
        case icon = "icon"
    }
    
    // MARK: - init
    public override init() {
        super.init()
    }
    
    required public init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: SummaryElementKeys.self)
        placeHolder = try? container.decode(String.self, forKey: .placeHolder)
        hook = try? container.decode(Hook.self, forKey: .hook)
        _id = try? container.decode(String.self, forKey: ._id)
        icon = try? container.decode(String.self, forKey: .icon)
    }
    
    public func copy(with zone: NSZone? = nil) -> Any {
        let copy = KRESummaryElement()
        copy.placeHolder = placeHolder
        copy.payload = payload
        copy.title = title
        return copy
    }
}
