//
//  KREImageTemplate.swift
//  KoreBotSDK
//
//  Created by Srinivas Vasadi on 13/03/19.
//  Copyright © 2019 Srinivas Vasadi. All rights reserved.
//

import UIKit

public class KREListItem: NSObject, Decodable {
    public var buttons: [KREButtonTemplate]?
    public var details: [KREListItemDetails]?
    public var value: KRETextItemValue?

    public var defaultAction: KREAction?
    public var image: KREImageTemplate?
    public var title: String?
    public var subTitle: String?
    public var buttonsLayout: KREButtonsLayout?
    
    public enum ListItemKeys: String, CodingKey {
        case buttons = "buttons"
        case details = "details"
        case defaultAction = "default_action"
        case image = "image"
        case title = "title"
        case subTitle = "subtitle"
        case value = "value"
        case buttonsLayout = "buttonsLayout"
    }
    
    public enum ValueKeys: String, CodingKey {
        case type = "type"
    }
    
    // MARK: - init
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ListItemKeys.self)
        buttons = try? container.decode([KREButtonTemplate].self, forKey: .buttons)
        details = try? container.decode([KREListItemDetails].self, forKey: .details)
        defaultAction = try? container.decode(KREAction.self, forKey: .defaultAction)
        image = try? container.decode(KREImageTemplate.self, forKey: .image)
        title = try? container.decode(String.self, forKey: .title)
        subTitle = try? container.decode(String.self, forKey: .subTitle)
        if let valueContainer = try? container.nestedContainer(keyedBy: ValueKeys.self, forKey: .value) {
            let type = try? valueContainer.decode(String.self, forKey: .type)
            switch type {
            case "menu":
                value = try? container.decode(KREMenuItemValue.self, forKey: .value)
            case "text":
                value = try? container.decode(KRETextItemValue.self, forKey: .value)
            case "url":
                value = try? container.decode(KRETextItemValue.self, forKey: .value)
            case "button":
                value = try? container.decode(KREButtonItemValue.self, forKey: .value)
            case "image":
                value = try? container.decode(KREImageItemValue.self, forKey: .value)
            default:
                break
            }
        }
        
        buttonsLayout = try? container.decode(KREButtonsLayout.self, forKey: .buttonsLayout)
    }
}

// MARK: - KREListItemDetails
public class KREListItemDetails: NSObject, Decodable {
    public var desc: String?
    public var image: KREImageTemplate?

    public enum ImageKeys: String, CodingKey {
        case desc = "description"
        case image = "image"
    }
    
    // MARK: - init
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ImageKeys.self)
        desc = try? container.decode(String.self, forKey: .desc)
        image = try? container.decode(KREImageTemplate.self, forKey: .image)
    }
}

// MARK: - KREListItemValue
public class KRETextItemValue: NSObject, Decodable {
    public var text: String?
    public var type: String?

    public enum ValueKeys: String, CodingKey {
        case type = "type"
        case text = "text"
    }
    
    // MARK: - init
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ValueKeys.self)
        type = try? container.decode(String.self, forKey: .type)
        text = try? container.decode(String.self, forKey: .text)
    }
}

public class KREMenuItemValue: KRETextItemValue {
    public var menuButtons: [KREButtonTemplate]?

    public enum MenuKeys: String, CodingKey {
        case menu = "menu"
    }
    
    // MARK: - init
    required public init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: MenuKeys.self)
        menuButtons = try? container.decode([KREButtonTemplate].self, forKey: .menu)
    }
}

public class KREURLItemValue: KRETextItemValue {
    public var title: String?
    public var link: String?

    public enum URLKeys: String, CodingKey {
        case title = "Title"
        case link = "link"
    }
    
    // MARK: - init
    required public init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: URLKeys.self)
        title = try? container.decode(String.self, forKey: .title)
        link = try? container.decode(String.self, forKey: .link)
    }
}

public class KREButtonItemValue: KRETextItemValue {
    public var button: KREButtonTemplate?

    public enum ButtonKeys: String, CodingKey {
        case button = "button"
    }
    
    // MARK: - init
    required public init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: ButtonKeys.self)
        button = try? container.decode(KREButtonTemplate.self, forKey: .button)
    }
}

public class KREImageItemValue: KRETextItemValue {
    public var image: KREImageTemplate?

    public enum ButtonKeys: String, CodingKey {
        case image = "image"
    }
    
    // MARK: - init
    required public init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: ButtonKeys.self)
        image = try? container.decode(KREImageTemplate.self, forKey: .image)
    }
}
