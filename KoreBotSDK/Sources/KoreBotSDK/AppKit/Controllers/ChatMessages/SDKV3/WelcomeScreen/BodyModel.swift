//
//  BodyModel.swift
//  KoreBotSDKDemo
//
//  Created by Kartheek Pagidimarri on 25/08/23.
//  Copyright © 2023 Kore. All rights reserved.
//

import UIKit

class Body: NSObject , Decodable {
    public var background : Background?
    public var font : Font?
    public var user_message : User_message?
    public var bot_message : Bot_message?
    public var agent_message : Agent_message?
    public var time_stamp : Time_stamp?
    public var icon : Icon?
    public var bubble_style : String?
    public var primaryColor : String?
    public var primaryHoverColor : String?
    public var secondaryColor : String?
    public var secondaryHoverColor : String?
    public var img : String?
    
    enum CodingKeys: String, CodingKey {
        case background = "background"
        case font = "font"
        case user_message = "user_message"
        case bot_message = "bot_message"
        case agent_message = "agent_message"
        case time_stamp = "time_stamp"
        case icon = "icon"
        case bubble_style = "bubble_style"
        case primaryColor = "primaryColor"
        case primaryHoverColor = "primaryHoverColor"
        case secondaryColor = "secondaryColor"
        case secondaryHoverColor = "secondaryHoverColor"
        case img = "img"
    }
    // MARK: - init
    public override init() {
        super.init()
    }
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        background = try? container.decode(Background.self, forKey: .background)
        font = try? container.decode(Font.self, forKey: .font)
        user_message = try? container.decode(User_message.self, forKey: .user_message)
        bot_message = try? container.decode(Bot_message.self, forKey: .bot_message)
        agent_message = try? container.decode(Agent_message.self, forKey: .agent_message)
        time_stamp = try? container.decode(Time_stamp.self, forKey: .time_stamp)
        icon = try? container.decode(Icon.self, forKey: .icon)
        bubble_style = try? container.decode(String.self, forKey: .bubble_style)
        primaryColor = try? container.decode(String.self, forKey: .primaryColor)
        primaryHoverColor = try? container.decode(String.self, forKey: .primaryHoverColor)
        secondaryColor = try? container.decode(String.self, forKey: .secondaryColor)
        secondaryHoverColor = try? container.decode(String.self, forKey: .secondaryHoverColor)
        img = try? container.decode(String.self, forKey: .img)
    }

}

class Font : NSObject , Decodable {
    public var family : String?
    public var size : String?
    public var style : String?

    enum CodingKeys: String, CodingKey {
        case family = "family"
        case size = "size"
        case style = "style"
    }
    // MARK: - init
    public override init() {
        super.init()
    }
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        family = try? container.decode(String.self, forKey: .family)
        size = try? container.decode(String.self, forKey: .size)
        style = try? container.decode(String.self, forKey: .style)
    }

}

class User_message : NSObject , Decodable {
    public var bg_color : String?
    public var color : String?

    enum CodingKeys: String, CodingKey {
        case bg_color = "bg_color"
        case color = "color"
    }
    // MARK: - init
    public override init() {
        super.init()
    }
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        bg_color = try? container.decode(String.self, forKey: .bg_color)
        color = try? container.decode(String.self, forKey: .color)
    }

}

class Bot_message : NSObject , Decodable {
    public var bg_color : String?
    public var color : String?

    enum CodingKeys: String, CodingKey {
        case bg_color = "bg_color"
        case color = "color"
    }
    // MARK: - init
    public override init() {
        super.init()
    }
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        bg_color = try? container.decode(String.self, forKey: .bg_color)
        color = try? container.decode(String.self, forKey: .color)
    }

}

class Agent_message : NSObject , Decodable {
    public var bg_color : String?
    public var color : String?
    public var separator : String?
    public var icon : Icon?
    public var title : Title?
    public var sub_title : Sub_title?

    enum CodingKeys: String, CodingKey {
        case bg_color = "bg_color"
        case color = "color"
        case separator = "separator"
        case icon = "icon"
        case title = "title"
        case sub_title = "sub_title"
    }
    // MARK: - init
    public override init() {
        super.init()
    }
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        bg_color = try? container.decode(String.self, forKey: .bg_color)
        color = try? container.decode(String.self, forKey: .color)
        separator = try? container.decode(String.self, forKey: .separator)
        icon = try? container.decode(Icon.self, forKey: .icon)
        title = try? container.decode(Title.self, forKey: .title)
        sub_title = try? container.decode(Sub_title.self, forKey: .sub_title)
    }

}

class Time_stamp : NSObject , Decodable {
    public var show : Bool?
    public var show_type : String?
    public var position : String?
    public var separator : String?
    public var color : String?
    public var timeformat: String?
    public var date_format: String?
    
    enum CodingKeys: String, CodingKey {
        case show = "show"
        case show_type = "show_type"
        case position = "position"
        case separator = "separator"
        case color = "color"
        case timeformat = "time_format"
        case date_format = "date_format"
    }
    // MARK: - init
    public override init() {
        super.init()
    }
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        show = try? container.decode(Bool.self, forKey: .show)
        show_type = try? container.decode(String.self, forKey: .show_type)
        position = try? container.decode(String.self, forKey: .position)
        separator = try? container.decode(String.self, forKey: .separator)
        color = try? container.decode(String.self, forKey: .color)
        timeformat = try? container.decode(String.self, forKey: .timeformat)
        date_format = try? container.decode(String.self, forKey: .date_format)
    }

}
