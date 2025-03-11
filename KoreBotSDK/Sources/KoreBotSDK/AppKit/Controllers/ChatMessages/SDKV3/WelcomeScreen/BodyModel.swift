//
//  BodyModel.swift
//  KoreBotSDKDemo
//
//  Created by Kartheek Pagidimarri on 25/08/23.
//  Copyright © 2023 Kore. All rights reserved.
//

import UIKit

public class Body: NSObject , Decodable {
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
    
    public func updateWith(configModel: Body) -> Body{
        self.background = (configModel.background == nil)  ? background : configModel.background
        self.font = (configModel.font == nil)  ? font : configModel.font
        self.user_message = (configModel.user_message == nil)  ? user_message : configModel.user_message
        self.bot_message = (configModel.bot_message == nil)  ? bot_message : configModel.bot_message
        self.agent_message = (configModel.agent_message == nil)  ? agent_message : configModel.agent_message
        self.time_stamp = (configModel.time_stamp == nil)  ? time_stamp : configModel.time_stamp
        self.icon = (configModel.icon == nil)  ? icon : configModel.icon
        self.bubble_style = (configModel.bubble_style == nil || configModel.bubble_style == "")  ? bubble_style : configModel.bubble_style
        self.primaryColor = (configModel.primaryColor == nil || configModel.primaryColor == "")  ? primaryColor : configModel.primaryColor
        self.primaryHoverColor = (configModel.primaryHoverColor == nil || configModel.primaryHoverColor == "")  ? primaryHoverColor : configModel.primaryHoverColor
        self.secondaryColor = (configModel.secondaryColor == nil || configModel.secondaryColor == "")  ? secondaryColor : configModel.secondaryColor
        self.secondaryHoverColor = (configModel.secondaryHoverColor == nil || configModel.secondaryHoverColor == "")  ? secondaryHoverColor : configModel.secondaryHoverColor
        self.img = (configModel.img == nil || configModel.img == "")  ? img : configModel.img
        return self
    }

}

public class Font : NSObject , Decodable {
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
    
    public func updateWith(configModel: Font) -> Font{
        self.family = (configModel.family == nil || configModel.family == "")  ? family : configModel.family
        self.size = (configModel.size == nil || configModel.size == "")  ? size : configModel.size
        self.style = (configModel.style == nil || configModel.style == "")  ? style : configModel.style
        return self
    }

}

public class User_message : NSObject , Decodable {
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
    public func updateWith(configModel: User_message) -> User_message{
        self.bg_color = (configModel.bg_color == nil || configModel.bg_color == "")  ? bg_color : configModel.bg_color
        self.color = (configModel.color == nil || configModel.color == "")  ? color : configModel.color
        return self
    }

}

public class Bot_message : NSObject , Decodable {
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
    public func updateWith(configModel: Bot_message) -> Bot_message{
        self.bg_color = (configModel.bg_color == nil || configModel.bg_color == "")  ? bg_color : configModel.bg_color
        self.color = (configModel.color == nil || configModel.color == "")  ? color : configModel.color
        return self
    }
}

public class Agent_message : NSObject , Decodable {
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
    
    public func updateWith(configModel: Agent_message) -> Agent_message{
        self.bg_color = (configModel.bg_color == nil || configModel.bg_color == "")  ? bg_color : configModel.bg_color
        self.color = (configModel.color == nil || configModel.color == "")  ? color : configModel.color
        self.separator = (configModel.separator == nil || configModel.separator == "")  ? separator : configModel.separator
        self.icon = (configModel.icon == nil)  ? icon : configModel.icon
        self.title = (configModel.title == nil)  ? title : configModel.title
        self.sub_title = (configModel.sub_title == nil)  ? sub_title : configModel.sub_title
        return self
    }

}

public class Time_stamp : NSObject , Decodable {
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
    public func updateWith(configModel: Time_stamp) -> Time_stamp{
        self.show = (configModel.show == nil)  ? show : configModel.show
        self.show_type = (configModel.show_type == nil || configModel.show_type == "")  ? show_type : configModel.show_type
        self.position = (configModel.position == nil || configModel.position == "")  ? position : configModel.position
        self.separator = (configModel.separator == nil || configModel.separator == "")  ? separator : configModel.separator
        self.color = (configModel.color == nil || configModel.color == "")  ? color : configModel.color
        self.timeformat = (configModel.timeformat == nil || configModel.timeformat == "")  ? timeformat : configModel.timeformat
        self.date_format = (configModel.date_format == nil || configModel.date_format == "")  ? date_format : configModel.date_format
        return self
    }

}
