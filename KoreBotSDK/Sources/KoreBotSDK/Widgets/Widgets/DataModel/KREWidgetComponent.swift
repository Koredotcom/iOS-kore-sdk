//
//  KREWidgetComponent+CoreDataProperties.swift
//  KoreBotSDK
//
//  Created by Srinivas Vasadi on 25/03/19.
//  Copyright © 2019 Srinivas Vasadi. All rights reserved.
//
//

import Foundation

public class KREWidgetComponent: NSObject, Decodable, NSCopying {
    // MARK: - properties
    public var buttons: [KREButtonTemplate]?
    public var elements: [Decodable]?
    public var hasMore: Bool?
    public var multiActions: [KREAction]?
    public var placeholder: String?
    public var provider: String?
    public var previewLength: Int64?
    public var cursor: Cursor?
    public var header: KREWeatherHeader?
    public var templateType: String?
    public var login: KRELogInData?
    
    public enum CodingKeys: String, CodingKey {
        case placeholder, hasMore, buttons, elements, cursor, header, templateType, login
        case previewLength = "preview_length"
        case multiActions = "multi_actions"
    }

    // MARK: - init
    public override init() {
        super.init()
    }

    required public init(from decoder: Decoder) throws {
        let dataContainer = try decoder.container(keyedBy: CodingKeys.self)
        placeholder = try? dataContainer.decode(String.self, forKey: .placeholder)
        previewLength = try? dataContainer.decode(Int64.self, forKey: .previewLength)
        hasMore = try? dataContainer.decode(Bool.self, forKey: .hasMore)
        buttons = try? dataContainer.decode([KREButtonTemplate].self, forKey: .buttons)
        multiActions = try? dataContainer.decode([KREAction].self, forKey: .multiActions)
        cursor = try? dataContainer.decode(Cursor.self, forKey: .cursor)
        header = try? dataContainer.decode(KREWeatherHeader.self, forKey: .header)
        templateType = try? dataContainer.decode(String.self, forKey: .templateType)
        login = try? dataContainer.decode(KRELogInData.self, forKey: .login)
        elements = [Decodable]()
    }
    
    public func copy(with zone: NSZone? = nil) -> Any {
        let copy = KREWidgetComponent()
        copy.buttons = buttons
        copy.elements = elements
        copy.hasMore = hasMore
        copy.multiActions = multiActions
        copy.placeholder = placeholder
        copy.previewLength = previewLength
        copy.provider = provider
        copy.templateType = templateType
        copy.login = login
        return copy
    }
}

public class Cursor: NSObject, Decodable, NSCopying {
    // MARK: - properties
    public var start: Int64?
    public var end: Int64?

    public enum CodingKeys: String, CodingKey {
        case start = "start"
        case end = "end"
    }
    
    // MARK: - init
    public override init() {
        super.init()
    }

    required public init(from decoder: Decoder) throws {
        let dataContainer = try decoder.container(keyedBy: CodingKeys.self)
        start = try? dataContainer.decode(Int64.self, forKey: .start)
        end = try? dataContainer.decode(Int64.self, forKey: .end)
    }
    
    // MARK: - NSCopying
    public func copy(with zone: NSZone? = nil) -> Any {
        let copy = Cursor()
        copy.start = start
        copy.end = end
        return copy
    }
}

public class Hook: NSObject, Decodable, NSCopying {
    // MARK: - properties
    public var api: String?
    public var method: String?
    public var params: [String: String]?
    public var error: Error?
    public var fields: [KREInputField]?

    public enum CodingKeys: String, CodingKey {
        case api = "api"
        case body = "body"
        case method = "method"
        case params = "params"
        case fields = "fields"
    }
    
    // MARK: - init
    public override init() {
        super.init()
    }

    required public init(from decoder: Decoder) throws {
        let dataContainer = try decoder.container(keyedBy: CodingKeys.self)
        api = try? dataContainer.decode(String.self, forKey: .api)
        method = try? dataContainer.decode(String.self, forKey: .method)
        params = try? dataContainer.decode([String: String].self, forKey: .params)
        if let badgeContainer = try? dataContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .body) {
            fields = try? badgeContainer.decode([KREInputField].self, forKey: .fields)
        }
    }
    
    // MARK: - NSCopying
    public func copy(with zone: NSZone? = nil) -> Any {
        let copy = Hook()
        copy.api = api
        copy.fields = fields
        copy.method = method
        copy.params = params
        copy.fields = fields
        return copy
    }
}

// MARK: - KREInputFields
public class KREInputField: NSObject, Decodable, NSCopying {
    public var dataType: String?
    public var defaultValue: String?
    public var fieldType: String?
    public var label: String?
    public var visibility: String?
    
    public enum InputFieldKeys: String, CodingKey {
        case dataType = "dataType"
        case defaultValue = "defaultValue"
        case fieldType = "fieldType"
        case label = "label"
        case visibility = "visibility"
    }
    
    // MARK: - init
    public override init() {
        super.init()
    }

    required public init(from decoder: Decoder) throws {
        let dataContainer = try decoder.container(keyedBy: InputFieldKeys.self)
        let container = try decoder.container(keyedBy: InputFieldKeys.self)
        dataType = try? container.decode(String.self, forKey: .dataType)
        defaultValue = try? container.decode(String.self, forKey: .defaultValue)
        fieldType = try? container.decode(String.self, forKey: .fieldType)
        label = try? container.decode(String.self, forKey: .label)
        visibility = try? container.decode(String.self, forKey: .visibility)
    }
    
    public func copy(with zone: NSZone? = nil) -> Any {
        let copy = KREInputField()
        copy.dataType = dataType
        copy.defaultValue = defaultValue
        copy.fieldType = fieldType
        copy.label = label
        copy.visibility = visibility
        return copy
    }
}
