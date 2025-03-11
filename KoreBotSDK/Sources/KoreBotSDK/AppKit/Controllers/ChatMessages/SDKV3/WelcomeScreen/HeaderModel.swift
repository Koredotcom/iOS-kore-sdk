//
//  HeaderModel.swift
//  KoreBotSDKDemo
//
//  Created by Kartheek Pagidimarri on 25/08/23.
//  Copyright © 2023 Kore. All rights reserved.
//

import UIKit

public class HeaderModel : NSObject , Decodable {
    public var bg_color : String?
    public var size : String?
    public var style : String?
    public var icon : Icon?
    public var title : Title?
    public var sub_title : Sub_title?
    public var buttons : Buttons?
    public var icons_color: String?
    
    enum CodingKeys: String, CodingKey {
        case bg_color = "bg_color"
        case size = "size"
        case style = "style"
        case icon = "icon"
        case title = "title"
        case sub_title = "sub_title"
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
        size = try? container.decode(String.self, forKey: .size)
        style = try? container.decode(String.self, forKey: .style)
        icon = try? container.decode(Icon.self, forKey: .icon)
        title = try? container.decode(Title.self, forKey: .title)
        sub_title = try? container.decode(Sub_title.self, forKey: .sub_title)
        buttons = try? container.decode(Buttons.self, forKey: .buttons)
        icons_color = try? container.decode(String.self, forKey: .icons_color) 
    }
    
    public func updateWith(configModel: HeaderModel) -> HeaderModel{
        self.bg_color = (configModel.bg_color == bg_color || configModel.bg_color == "")  ? bg_color : configModel.bg_color
        self.size = (configModel.size == nil || configModel.size == "")  ? size : configModel.size
        self.style = (configModel.style == nil || configModel.style == "")  ? style : configModel.style
        self.icon = (configModel.icon == nil)  ? icon : configModel.icon
        self.title = (configModel.title == nil)  ? title : configModel.title
        self.sub_title = (configModel.sub_title == nil)  ? sub_title : configModel.sub_title
        self.buttons = (configModel.buttons == nil)  ? buttons : configModel.buttons
        self.icons_color = (configModel.icons_color == nil || configModel.icons_color == "")  ? icons_color : configModel.icons_color
        return self
    }

}

public class Sub_title : NSObject , Decodable {
    public var name : String?
    public var color : String?

    enum CodingKeys: String, CodingKey {
        case name = "name"
        case color = "color"
    }
    // MARK: - init
    public override init() {
        super.init()
    }
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try? container.decode(String.self, forKey: .name)
        color = try? container.decode(String.self, forKey: .color)
    }

    public func updateWith(configModel: Sub_title) -> Sub_title{
        self.name = (configModel.name == name || configModel.name == "")  ? name : configModel.name
        self.color = (configModel.color == nil || configModel.color == "")  ? color : configModel.color
        return self
    }
}
