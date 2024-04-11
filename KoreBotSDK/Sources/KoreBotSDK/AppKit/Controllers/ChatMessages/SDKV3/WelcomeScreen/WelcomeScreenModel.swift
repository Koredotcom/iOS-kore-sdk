//
//  WelcomeScreenModel.swift
//  KoreBotSDKDemo
//
//  Created by Kartheek Pagidimarri on 25/08/23.
//  Copyright © 2023 Kore. All rights reserved.
//

import UIKit

class WelcomeScreen: NSObject , Decodable {
    public var show: Bool?
    public var layout: String?
    public var background: Background?
    public var bottom_background: BottomBackground?
    public var logo: Logo?
    public var note: Note?
    public var starter_box: StarterBox?
    public var sub_title: SubTitle?
    public var templates: [Templates]?
    public var title: Title?
    public var top_fonts: TopFonts?
    
    public var static_links : Static_links?
    public var promotional_content: Promotional_Content?
    
    enum ColorCodeKeys: String, CodingKey {
        case show = "show"
        case layout = "layout"
        case background = "background"
        case bottom_background = "bottom_background"
        case logo = "logo"
        case note = "note"
        case starter_box = "starter_box"
        case sub_title = "sub_title"
        case templates = "templates"
        case title = "title"
        case top_fonts = "top_fonts"
        case static_links = "static_links"
        case promotional_content = "promotional_content"
        
    }
    
    // MARK: - init
    public override init() {
        super.init()
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ColorCodeKeys.self)
        show = try? container.decode(Bool.self, forKey: .show)
        layout = try? container.decode(String.self, forKey: .layout)
        background = try? container.decode(Background.self, forKey: .background)
        bottom_background = try? container.decode(BottomBackground.self, forKey: .bottom_background)
        logo = try? container.decode(Logo.self, forKey: .logo)
        note = try? container.decode(Note.self, forKey: .note)
        starter_box = try? container.decode(StarterBox.self, forKey: .starter_box)
        sub_title = try? container.decode(SubTitle.self, forKey: .sub_title)
        templates = try? container.decode([Templates].self, forKey: .templates)
        title = try? container.decode(Title.self, forKey: .title)
        top_fonts = try? container.decode(TopFonts.self, forKey: .top_fonts)
        static_links = try? container.decode(Static_links.self, forKey: .static_links)
        promotional_content = try? container.decode(Promotional_Content.self, forKey: .promotional_content)
    }
}

class Background: NSObject , Decodable {
    public var color: String?
    public var type: String?
    public var img: String?
    
    
    enum ColorCodeKeys: String, CodingKey {
        case color = "color"
        case img = "img"
        case type = "type"
    }
    // MARK: - init
    public override init() {
        super.init()
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ColorCodeKeys.self)
        color = try? container.decode(String.self, forKey: .color)
        img = try? container.decode(String.self, forKey: .img)
        type = try? container.decode(String.self, forKey: .type)
    }
}

class BottomBackground: NSObject , Decodable {
    public var color: String?
    enum ColorCodeKeys: String, CodingKey {
        case color = "color"
    }
    // MARK: - init
    public override init() {
        super.init()
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ColorCodeKeys.self)
        color = try? container.decode(String.self, forKey: .color)
    }
}

class Logo: NSObject , Decodable {
    public var logo_url: String?
    enum ColorCodeKeys: String, CodingKey {
        case logo_url = "logo_url"
    }
    // MARK: - init
    public override init() {
        super.init()
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ColorCodeKeys.self)
        logo_url = try? container.decode(String.self, forKey: .logo_url)
    }
}

class Note: NSObject , Decodable {
    public var color: String?
    public var name: String?
    
    enum ColorCodeKeys: String, CodingKey {
        case color = "color"
        case name = "name"
    }
    // MARK: - init
    public override init() {
        super.init()
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ColorCodeKeys.self)
        color = try? container.decode(String.self, forKey: .color)
        name = try? container.decode(String.self, forKey: .name)
    }
}

class SubTitle: NSObject , Decodable {
    public var color: String?
    public var name: String?
    
    enum ColorCodeKeys: String, CodingKey {
        case color = "color"
        case name = "name"
    }
    // MARK: - init
    public override init() {
        super.init()
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ColorCodeKeys.self)
        color = try? container.decode(String.self, forKey: .color)
        name = try? container.decode(String.self, forKey: .name)
    }
}

class Templates: NSObject , Decodable {
    public var color: String?
    enum ColorCodeKeys: String, CodingKey {
        case color = "color"
    }
    // MARK: - init
    public override init() {
        super.init()
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ColorCodeKeys.self)
        color = try? container.decode(String.self, forKey: .color)
    }
}

class Title: NSObject , Decodable {
    public var color: String?
    public var name: String?
    
    enum ColorCodeKeys: String, CodingKey {
        case color = "color"
        case name = "name"
    }
    // MARK: - init
    public override init() {
        super.init()
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ColorCodeKeys.self)
        color = try? container.decode(String.self, forKey: .color)
        name = try? container.decode(String.self, forKey: .name)
    }
}

class TopFonts: NSObject , Decodable {
    public var color: String?
    enum ColorCodeKeys: String, CodingKey {
        case color = "color"
    }
    // MARK: - init
    public override init() {
        super.init()
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ColorCodeKeys.self)
        color = try? container.decode(String.self, forKey: .color)
    }
}
class StarterBox: NSObject , Decodable {
    public var show : Bool?
    public var icon : Icon?
    public var title : String?
    public var sub_text : String?
    public var start_conv_button : Start_conv_button?
    public var start_conv_text : Start_conv_text?
    public var quick_start_buttons : Quick_start_buttons?
   
    
    enum ColorCodeKeys: String, CodingKey {
        case show = "show"
        case icon = "icon"
        case title = "title"
        case sub_text = "sub_text"
        case start_conv_button = "start_conv_button"
        case start_conv_text = "start_conv_text"
        case quick_start_buttons = "quick_start_buttons"
       
    }
    // MARK: - init
    public override init() {
        super.init()
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ColorCodeKeys.self)
        show = try? container.decode(Bool.self, forKey: .show)
        icon = try? container.decode(Icon.self, forKey: .icon)
        title = try? container.decode(String.self, forKey: .title)
        sub_text = try? container.decode(String.self, forKey: .sub_text)
        start_conv_button = try? container.decode(Start_conv_button.self, forKey: .start_conv_button)
        start_conv_text = try? container.decode(Start_conv_text.self, forKey: .start_conv_text)
        quick_start_buttons = try? container.decode(Quick_start_buttons.self, forKey: .quick_start_buttons)
       
    }
}

class Icon: NSObject , Decodable {
    public var show : Bool?
    public var user_icon : Bool?
    public var bot_icon : Bool?
    public var agent_icon : Bool?
    public var icon_url: String?
    public var color: String?
    
    
    enum ColorCodeKeys: String, CodingKey {
        case show = "show"
        case user_icon = "user_icon"
        case bot_icon = "bot_icon"
        case agent_icon = "agent_icon"
        case icon_url = "icon_url"
        case color = "color"
    }
    // MARK: - init
    public override init() {
        super.init()
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ColorCodeKeys.self)
        show = try? container.decode(Bool.self, forKey: .show)
        user_icon = try? container.decode(Bool.self, forKey: .user_icon)
        bot_icon = try? container.decode(Bool.self, forKey: .bot_icon)
        agent_icon = try? container.decode(Bool.self, forKey: .agent_icon)
        icon_url = try? container.decode(String.self, forKey: .icon_url)
        color = try? container.decode(String.self, forKey: .color)
    }
}

class Start_conv_button: NSObject , Decodable {
    public var color : String?

    enum ColorCodeKeys: String, CodingKey {
        case color = "color"
    }
    // MARK: - init
    public override init() {
        super.init()
    }
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ColorCodeKeys.self)
        color = try? container.decode(String.self, forKey: .color)
    }

}

class Start_conv_text: NSObject , Decodable {
    public var color : String?

    enum ColorCodeKeys: String, CodingKey {
        case color = "color"
    }
    // MARK: - init
    public override init() {
        super.init()
    }

    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ColorCodeKeys.self)
        color = try? container.decode(String.self, forKey: .color)
    }

}

class Quick_start_buttons: NSObject , Decodable {
    public var show : Bool?
    public var style : String?
    public var buttons : [Buttons]?
    public var input : String?
    public var action : Action?
    enum ColorCodeKeys: String, CodingKey {
        case show = "show"
        case style = "style"
        case buttons = "buttons"
        case input = "input"
        case action = "action"
    }
    // MARK: - init
    public override init() {
        super.init()
    }
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ColorCodeKeys.self)
        show =  try? container.decode(Bool.self, forKey: .show)
        style =  try? container.decode(String.self, forKey: .style)
        buttons =  try? container.decode([Buttons].self, forKey: .buttons)
        input =  try? container.decode(String.self, forKey: .input)
        action =  try? container.decode(Action.self, forKey: .action)
    }

}

class Static_links: NSObject , Decodable {
    public var show : Bool?
    public var layout : String?
    public var links : [Links]?

    enum ColorCodeKeys: String, CodingKey {
        case show = "show"
        case layout = "layout"
        case links = "links"
    }
    // MARK: - init
    public override init() {
        super.init()
    }
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ColorCodeKeys.self)
        show =  try? container.decode(Bool.self, forKey: .show)
        layout =  try? container.decode(String.self, forKey: .layout)
        links =  try? container.decode([Links].self, forKey: .links)
    }

}
class Buttons: NSObject , Decodable {
    public var title : String?
    public var action : Action?
    
    public var close: Close?
    public var expand: Close?
    public var help: Help?
    public var live_agent: LiveAgent?
    public var minimise: Close?
    public var reconnect: Close?
    
    public var menu : Menu?
    public var emoji : Emoji?
    public var microphone : Microphone?
    public var attachment : Attachment?
    
    enum CodingKeys: String, CodingKey {
        case title = "title"
        case action = "action"
        case close = "close"
        case expand = "expand"
        case help = "help"
        case live_agent = "live_agent"
        case minimise = "minimise"
        case reconnect = "reconnect"
        
        case menu = "menu"
        case emoji = "emoji"
        case microphone = "microphone"
        case attachment = "attachment"
    }
    // MARK: - init
    public override init() {
        super.init()
    }
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try? container.decode(String.self, forKey: .title)
        action = try? container.decode(Action.self, forKey: .action)
        
        close = try? container.decode(Close.self, forKey: .close)
        expand = try? container.decode(Close.self, forKey: .expand)
        help = try? container.decode(Help.self, forKey: .help)
        live_agent = try? container.decode(LiveAgent.self, forKey: .live_agent)
        minimise = try? container.decode(Close.self, forKey: .minimise)
        reconnect = try? container.decode(Close.self, forKey: .reconnect)
        
        menu = try? container.decode(Menu.self, forKey: .menu)
        emoji = try? container.decode(Emoji.self, forKey: .emoji)
        microphone = try? container.decode(Microphone.self, forKey: .microphone)
        attachment = try? container.decode(Attachment.self, forKey: .attachment)
    }

}
class Action : NSObject , Decodable {
    public var type : String?
    public var value : String?
    public var icon : String?

    enum CodingKeys: String, CodingKey {
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
        type = try? container.decode(String.self, forKey: .type)
        value = try? container.decode(String.self, forKey: .value)
        icon = try? container.decode(String.self, forKey: .icon)
    }

}

class Links : NSObject , Decodable {
    public var title : String?
    public var descrip : String?
    public var action : Action?

    enum CodingKeys: String, CodingKey {
        case title = "title"
        case descrip = "description"
        case action = "action"
    }
    // MARK: - init
    public override init() {
        super.init()
    }
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try? container.decode(String.self, forKey: .title)
        descrip = try? container.decode(String.self, forKey: .descrip)
        action = try? container.decode(Action.self, forKey: .action)
    }

}

class Close: NSObject , Decodable {
    public var icon : String?
    public var show : Bool?
    enum CodingKeys: String, CodingKey {
        case icon = "icon"
        case show = "show"
    }
    // MARK: - init
    public override init() {
        super.init()
    }
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        icon = try? container.decode(String.self, forKey: .icon)
        show = try? container.decode(Bool.self, forKey: .show)
    }

}

class Help : NSObject , Decodable {
    public var show : Bool?
    public var action : Action?

    enum CodingKeys: String, CodingKey {
        case show = "show"
        case action = "action"
    }
    // MARK: - init
    public override init() {
        super.init()
    }
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        show = try? container.decode(Bool.self, forKey: .show)
        action = try? container.decode(Action.self, forKey: .action)
    }

}

class LiveAgent : NSObject , Decodable {
    public var show : Bool?
    public var action : Action?

    enum CodingKeys: String, CodingKey {
        case show = "show"
        case action = "action"
    }
    // MARK: - init
    public override init() {
        super.init()
    }
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        show = try? container.decode(Bool.self, forKey: .show)
        action = try? container.decode(Action.self, forKey: .action)
    }

}

class Promotional_Content : NSObject , Decodable {
    public var show : Bool?
    public var promotions : [Promotions]?

    enum ColorCodeKeys: String, CodingKey {
        case show = "show"
        case promotions = "promotions"
    }
    // MARK: - init
    public override init() {
        super.init()
    }
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ColorCodeKeys.self)
        show =  try? container.decode(Bool.self, forKey: .show)
        promotions =  try? container.decode([Promotions].self, forKey: .promotions)
    }

}
class Promotions : NSObject , Decodable {
    public var banner : String?
    public var action : Action?

    enum ColorCodeKeys: String, CodingKey {
        case banner = "banner"
        case action = "action"
    }
    // MARK: - init
    public override init() {
        super.init()
    }
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ColorCodeKeys.self)
        banner =  try? container.decode(String.self, forKey: .banner)
        action =  try? container.decode(Action.self, forKey: .action)
    }

}

