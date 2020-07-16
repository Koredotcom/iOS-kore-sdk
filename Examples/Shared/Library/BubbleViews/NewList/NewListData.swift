//
//  NewListData.swift
//  KoreBotSDKDemo
//
//  Created by Kartheek Pagidimarri on 12/05/20.
//  Copyright © 2020 Kore. All rights reserved.
//

import UIKit

public class Componentss: NSObject, Decodable {
      public var template_type: String?
      public var text: String?
      public var elements: [ComponentElements]?
      public var buttons: [ComponentItemAction]?
      public var moreData: ComponentMoreData?
      public var heading: String?
    
    enum ColorCodeKeys: String, CodingKey {
            case template_type = "template_type"
            case text = "text"
            case elements = "elements"
            case buttons = "buttons"
            case moreData = "moreData"
            case heading = "heading"
       }
       
       // MARK: - init
       public override init() {
           super.init()
       }
       
       required public init(from decoder: Decoder) throws {
           let container = try decoder.container(keyedBy: ColorCodeKeys.self)
           template_type = try? container.decode(String.self, forKey: .template_type)
           text = try? container.decode(String.self, forKey: .text)
           elements = try? container.decode([ComponentElements].self, forKey: .elements)
           buttons = try? container.decode([ComponentItemAction].self, forKey: .buttons)
           moreData = try? container.decode(ComponentMoreData.self, forKey: .moreData)
           heading = try? container.decode(String.self, forKey: .heading)
       }
}
// MARK: - Elements
public class ComponentElements: NSObject, Decodable {
    public var color: String?
    public var subtitle: String?
    public var title: String?
    public var value: String?
    public var imageURL: String?
    public var action: ComponentItemAction?
    
    enum ColorCodeKeys: String, CodingKey {
        case color = "color"
        case subtitle = "subtitle"
        case title = "title"
        case value = "value"
        case imageURL = "imageURL"
        case action = "default_action"
    }
    
    // MARK: - init
    public override init() {
        super.init()
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ColorCodeKeys.self)
        color = try? container.decode(String.self, forKey: .color)
        subtitle = try? container.decode(String.self, forKey: .subtitle)
        title = try? container.decode(String.self, forKey: .title)
        value = try? container.decode(String.self, forKey: .value)
        imageURL = try? container.decode(String.self, forKey: .imageURL)
        action = try? container.decode(ComponentItemAction.self, forKey: .action)
    }
}


// MARK: - ItemAction
public class ComponentItemAction: NSObject, Decodable {
    // MARK: - properties
    public var payload: String?
    public var title: String?
    public var type: String?
    public var fallback_url: String?

    enum ActionKeys: String, CodingKey {
        case payload = "payload"
        case title = "title"
        case type = "type"
        case fallback_url = "fallback_url"
        
    }
    
    // MARK: - init
    public override init() {
        super.init()
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ActionKeys.self)
        payload = try? container.decode(String.self, forKey: .payload)
        title = try? container.decode(String.self, forKey: .title)
        type = try? container.decode(String.self, forKey: .type)
        fallback_url = try? container.decode(String.self, forKey: .fallback_url)
    }
}
// MARK: - MoreData
public class ComponentMoreData: NSObject, Decodable {
    // MARK: - properties
    public var tab1: [Tabs]?
    public var tab2: [Tabs]?

    enum ColorCodeKeys: String, CodingKey {
        case tab1 = "Tab1"
        case tab2 = "Tab2"
    }
    
    // MARK: - init
    public override init() {
        super.init()
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ColorCodeKeys.self)
        tab1 = try? container.decode([Tabs].self, forKey: .tab1)
        tab2 = try? container.decode([Tabs].self, forKey: .tab2)
    }
}
// MARK: - Tabs
public class Tabs: NSObject, Decodable {
    public var title: String?
    public var subtitle: String?
    public var image_url: String?
    public var value: String?
    public var imageURL: String?
    public var action: ComponentItemAction?
    
    enum ColorCodeKeys: String, CodingKey {
        case title = "title"
        case subtitle = "subtitle"
        case image_url = "image_url"
        case value = "value"
        case action = "default_action"
    }
    
    // MARK: - init
    public override init() {
        super.init()
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ColorCodeKeys.self)
        title = try? container.decode(String.self, forKey: .title)
        subtitle = try? container.decode(String.self, forKey: .subtitle)
        image_url = try? container.decode(String.self, forKey: .image_url)
        value = try? container.decode(String.self, forKey: .value)
        action = try? container.decode(ComponentItemAction.self, forKey: .action)
    }
}
