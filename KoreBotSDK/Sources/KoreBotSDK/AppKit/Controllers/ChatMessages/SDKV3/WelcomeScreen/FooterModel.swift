//
//  FooterModel.swift
//  KoreBotSDKDemo
//
//  Created by Kartheek Pagidimarri on 25/08/23.
//  Copyright © 2023 Kore. All rights reserved.
//

import UIKit

public class FooterModel: NSObject , Decodable {
    public var bg_color : String?
    public var layout : String?
    public var style : String?
    public var compose_bar : Compose_bar?
    public var buttons : Buttons?
    public var icons_color : String?
    
    enum CodingKeys: String, CodingKey {
        case bg_color = "bg_color"
        case layout = "layout"
        case style = "style"
        case compose_bar = "compose_bar"
        case buttons = "buttons"
        case icons_color = "icons_color"
    }
    // MARK: - init
    public override init() {
        super.init()
    }
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        bg_color = try? container.decode(String.self, forKey: .bg_color)
        layout = try? container.decode(String.self, forKey: .layout)
        style = try? container.decode(String.self, forKey: .style)
        compose_bar = try? container.decode(Compose_bar.self, forKey: .compose_bar)
        buttons = try? container.decode(Buttons.self, forKey: .buttons)
        icons_color = try? container.decode(String.self, forKey: .icons_color)
    }
    
    public func updateWith(configModel: FooterModel) -> FooterModel{
        self.bg_color = (configModel.bg_color == nil || configModel.bg_color == "")  ? bg_color : configModel.bg_color
        self.layout = (configModel.layout == nil || configModel.layout == "")  ? layout : configModel.layout
        self.style = (configModel.style == nil || configModel.style == "")  ? style : configModel.style
        self.compose_bar = (configModel.compose_bar == nil)  ? compose_bar : configModel.compose_bar
        self.buttons = (configModel.buttons == nil)  ? buttons : configModel.buttons
        self.icons_color = (configModel.icons_color == nil || configModel.icons_color == "")  ? icons_color : configModel.icons_color
        return self
    }

}

public class Compose_bar: NSObject , Decodable {
    public var bg_color : String?
    public var outline_color : String?
    public var placeholder : String?
    
    enum CodingKeys: String, CodingKey {
        case bg_color = "bg_color"
        case outline_color = "outline-color"
        case placeholder = "placeholder"
    }
    // MARK: - init
    public override init() {
        super.init()
    }
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        bg_color = try? container.decode(String.self, forKey: .bg_color)
        outline_color = try? container.decode(String.self, forKey: .outline_color)
        placeholder = try? container.decode(String.self, forKey: .placeholder)
    }
    public func updateWith(configModel: Compose_bar) -> Compose_bar{
        self.bg_color = (configModel.bg_color == nil || configModel.bg_color == "")  ? bg_color : configModel.bg_color
        self.outline_color = (configModel.outline_color == nil || configModel.outline_color == "")  ? outline_color : configModel.outline_color
        self.placeholder = (configModel.placeholder == nil || configModel.placeholder == "")  ? placeholder : configModel.placeholder
        return self
    }

}


public class Actions: NSObject , Decodable {
    public var title : String?
    public var type : String?
    public var value : String?
    public var icon : String?
    
    enum CodingKeys: String, CodingKey {
        case title = "title"
        case type = "type"
        case value = "value"
        case icon = "icon"
    }
    // MARK: - init
    public override init() {
        super.init()
    }
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try? container.decode(String.self, forKey: .title)
        type = try? container.decode(String.self, forKey: .type)
        value = try? container.decode(String.self, forKey: .value)
        icon = try? container.decode(String.self, forKey: .icon)
    }
    public func updateWith(configModel: Actions) -> Actions{
        self.title = (configModel.title == nil || configModel.title == "")  ? title : configModel.title
        self.type = (configModel.type == nil || configModel.type == "")  ? type : configModel.type
        self.value = (configModel.value == nil || configModel.value == "")  ? value : configModel.value
        self.icon = (configModel.icon == nil || configModel.icon == "")  ? icon : configModel.icon
        return self
    }
}

public class Menu: NSObject , Decodable {
    public var show : Bool?
    public var icon : String?
    public var actions : [Actions]?
    
    enum CodingKeys: String, CodingKey {
        case show = "show"
        case icon = "icon"
        case actions = "actions"
    }
    // MARK: - init
    public override init() {
        super.init()
    }
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        show = try? container.decode(Bool.self, forKey: .show)
        icon = try? container.decode(String.self, forKey: .icon)
        actions = try? container.decode([Actions].self, forKey: .actions)
    }

    public func updateWith(configModel: Menu) -> Menu{
        self.show = (configModel.show == nil)  ? show : configModel.show
        self.icon = (configModel.icon == nil || configModel.icon == "")  ? icon : configModel.icon
        self.actions = (configModel.actions == nil)  ? actions: configModel.actions
        return self
    }
}

public class Emoji: NSObject , Decodable {
    public var show : Bool?
    public var icon : String?
    
    enum CodingKeys: String, CodingKey {
        case show = "show"
        case icon = "icon"
    }
    // MARK: - init
    public override init() {
        super.init()
    }
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        show = try? container.decode(Bool.self, forKey: .show)
        icon = try? container.decode(String.self, forKey: .icon)
    }
    public func updateWith(configModel: Emoji) -> Emoji{
        self.show = (configModel.show == nil)  ? show : configModel.show
        self.icon = (configModel.icon == nil || configModel.icon == "")  ? icon : configModel.icon
        return self
    }
}


public class Microphone: NSObject , Decodable {
    public var show : Bool?
    public var icon : String?
    
    enum CodingKeys: String, CodingKey {
        case show = "show"
        case icon = "icon"
    }
    // MARK: - init
    public override init() {
        super.init()
    }
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        show = try? container.decode(Bool.self, forKey: .show)
        icon = try? container.decode(String.self, forKey: .icon)
    }

    public func updateWith(configModel: Microphone) -> Microphone{
        self.show = (configModel.show == nil)  ? show : configModel.show
        self.icon = (configModel.icon == nil || configModel.icon == "")  ? icon : configModel.icon
        return self
    }
}

public class Attachment: NSObject , Decodable {
    public var show : Bool?
    public var icon : String?
    
    enum CodingKeys: String, CodingKey {
        case show = "show"
        case icon = "icon"
    }
    // MARK: - init
    public override init() {
        super.init()
    }
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        show = try? container.decode(Bool.self, forKey: .show)
        icon = try? container.decode(String.self, forKey: .icon)
    }
    
    public func updateWith(configModel: Attachment) -> Attachment{
        self.show = (configModel.show == nil)  ? show : configModel.show
        self.icon = (configModel.icon == nil || configModel.icon == "")  ? icon : configModel.icon
        return self
    }
}
