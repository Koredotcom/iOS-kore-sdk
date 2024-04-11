//
//  HeaderModel.swift
//  KoreBotSDKDemo
//
//  Created by Kartheek Pagidimarri on 25/08/23.
//  Copyright © 2023 Kore. All rights reserved.
//

import UIKit

class HeaderModel : NSObject , Decodable {
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

}

class Sub_title : NSObject , Decodable {
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

}
