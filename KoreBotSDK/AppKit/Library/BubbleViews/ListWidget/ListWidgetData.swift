//
//  ListWidgetData.swift
//  Pods
//
//  Created by Pagidimarri Kartheek on 13/05/25.
//

import UIKit
public class ListWidgetElements: NSObject, Decodable {
    public var title: String?
    public var subtitle: String?
    public var icon: String?
    public var buttons: [DropdownOptions]?
    public var buttonsLayout: ButtonsLayout?
    public var default_action: DefaultAction?
    public var elementValue: ElementValue?
    public var elementDetails: [ElementDetails]?
    
    public enum ListItemKeys: String, CodingKey {
        case title = "title"
        case subtitle = "subtitle"
        case icon = "icon"
        case buttons = "buttons"
        case buttonsLayout = "buttonsLayout"
        case default_action = "default_action"
        case elementValue = "value"
        case elementDetails = "details"
    }

    // MARK: - init
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ListItemKeys.self)
        title = try? container.decode(String.self, forKey: .title)
        subtitle = try? container.decode(String.self, forKey: .subtitle)
        icon = try? container.decode(String.self, forKey: .icon)
        buttons = try? container.decode([DropdownOptions].self, forKey: .buttons)
        buttonsLayout = try? container.decode(ButtonsLayout.self, forKey: .buttonsLayout)
        default_action = try? container.decode(DefaultAction.self, forKey: .default_action)
        elementValue = try? container.decode(ElementValue.self, forKey: .elementValue)
        elementDetails = try? container.decode([ElementDetails].self, forKey: .elementDetails)
    }
}

public class DefaultAction: NSObject, Decodable {
    public var payload: String?
    public var type: String?
  
    public enum ListItemKeys: String, CodingKey {
        case payload = "payload"
        case type = "type"
    }

    // MARK: - init
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ListItemKeys.self)
        payload = try? container.decode(String.self, forKey: .payload)
        type = try? container.decode(String.self, forKey: .type)
    }
}
public class ElementValue: NSObject, Decodable {
    public var text: String?
    public var type: String?
    public var menu: [DropdownOptions]?
    
    public enum ListItemKeys: String, CodingKey {
        case text = "text"
        case type = "type"
        case menu = "menu"
    }

    // MARK: - init
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ListItemKeys.self)
        text = try? container.decode(String.self, forKey: .text)
        type = try? container.decode(String.self, forKey: .type)
        menu = try? container.decode([DropdownOptions].self, forKey: .menu)
    }
}
public class ElementDetails: NSObject, Decodable {
    public var descr: String?
    public var elementImage: ImageDetails?
    
    
    public enum ListItemKeys: String, CodingKey {
        case descr = "description"
        case elementImage = "image"
    }

    // MARK: - init
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ListItemKeys.self)
        descr = try? container.decode(String.self, forKey: .descr)
        elementImage = try? container.decode(ImageDetails.self, forKey: .elementImage)
    }
}

public class ImageDetails: NSObject, Decodable {
    public var image_src: String?
    public var image_type: String?
    
    
    public enum ListItemKeys: String, CodingKey {
        case image_src = "image_src"
        case image_type = "image_type"
    }

    // MARK: - init
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ListItemKeys.self)
        image_src = try? container.decode(String.self, forKey: .image_src)
        image_type = try? container.decode(String.self, forKey: .image_type)
    }
}
