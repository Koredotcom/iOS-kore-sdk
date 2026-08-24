//
//  WelcomeScreenModel.swift
//  KoreBotSDKDemo
//
//  Created by Kartheek Pagidimarri on 25/08/23.
//  Copyright © 2023 Kore. All rights reserved.
//

import UIKit

public class WelcomeScreen: NSObject , Decodable {
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
    
    public func updateWith(configModel: WelcomeScreen) -> WelcomeScreen{
        self.show = (configModel.show == nil)  ? show : configModel.show
        self.layout = (configModel.layout == nil || configModel.layout == "")  ? layout : configModel.layout
        self.background = configModel.background != nil ? background?.updateWith(configModel: configModel.background!) : background
        self.bottom_background = configModel.bottom_background != nil ? bottom_background?.updateWith(configModel: configModel.bottom_background!) : bottom_background
        self.logo = configModel.logo != nil ? logo?.updateWith(configModel: configModel.logo!) : logo
        self.note = configModel.note != nil ? note?.updateWith(configModel: configModel.note!) : note
        self.starter_box = configModel.starter_box != nil ? starter_box?.updateWith(configModel: configModel.starter_box!) : starter_box
        self.sub_title = configModel.sub_title != nil ? sub_title?.updateWith(configModel: configModel.sub_title!) : sub_title
        //self.templates = configModel.templates != nil ? templates?.updateWith(configModel: configModel.templates!) : templates
        self.title = configModel.title != nil ? title?.updateWith(configModel: configModel.title!) : title
        self.top_fonts = configModel.top_fonts != nil ? top_fonts?.updateWith(configModel: configModel.top_fonts!) : top_fonts
        self.static_links = configModel.static_links != nil ? static_links?.updateWith(configModel: configModel.static_links!) : static_links
        self.promotional_content = configModel.promotional_content != nil ? promotional_content?.updateWith(configModel: configModel.promotional_content!) : promotional_content
        return self
    }
}

public class Background: NSObject , Decodable {
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
    
    public func updateWith(configModel: Background) -> Background{
        self.color = (configModel.color == nil || configModel.color == "")  ? color : configModel.color
        self.img = (configModel.img == nil || configModel.img == "")  ? img : configModel.img
        self.type = (configModel.type == nil || configModel.type == "")  ? type : configModel.type
        return self
    }
}

public class BottomBackground: NSObject , Decodable {
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
    public func updateWith(configModel: BottomBackground) -> BottomBackground{
        self.color = (configModel.color == nil || configModel.color == "")  ? color : configModel.color
        return self
    }
}

public class Logo: NSObject , Decodable {
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
    public func updateWith(configModel: Logo) -> Logo{
        self.logo_url = (configModel.logo_url == nil || configModel.logo_url == "")  ? logo_url : configModel.logo_url
        return self
    }
}

public class Note: NSObject , Decodable {
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
    public func updateWith(configModel: Note) -> Note{
        self.color = (configModel.color == nil || configModel.color == "")  ? color : configModel.color
        self.name = (configModel.name == nil || configModel.name == "")  ? name : configModel.name
        return self
    }
}

public class SubTitle: NSObject , Decodable {
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
    public func updateWith(configModel: SubTitle) -> SubTitle{
        self.color = (configModel.color == nil || configModel.color == "")  ? color : configModel.color
        self.name = (configModel.name == nil || configModel.name == "")  ? name : configModel.name
        return self
    }
}

public class Templates: NSObject , Decodable {
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
    
    public func updateWith(configModel: Templates) -> Templates{
        self.color = (configModel.color == nil || configModel.color == "")  ? color : configModel.color
        return self
    }
}

public class Title: NSObject , Decodable {
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
    
    public func updateWith(configModel: Title) -> Title{
        self.color = (configModel.color == nil || configModel.color == "")  ? color : configModel.color
        self.name = (configModel.name == nil || configModel.name == "")  ? name : configModel.name
        return self
    }
}

public class TopFonts: NSObject , Decodable {
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
    public func updateWith(configModel: TopFonts) -> TopFonts{
        self.color = (configModel.color == nil || configModel.color == "")  ? color : configModel.color
        return self
    }
}
public class StarterBox: NSObject , Decodable {
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
    
    public func updateWith(configModel: StarterBox) -> StarterBox{
        self.show = (configModel.show == nil)  ? show : configModel.show
        self.icon = configModel.icon != nil ? icon?.updateWith(configModel: configModel.icon!) : icon
        self.title = (configModel.title == nil || configModel.title == "")  ? title : configModel.title
        self.sub_text = (configModel.sub_text == nil || configModel.sub_text == "")  ? sub_text : configModel.sub_text
        self.start_conv_button =  configModel.start_conv_button != nil ? start_conv_button?.updateWith(configModel: configModel.start_conv_button!) : start_conv_button
        self.start_conv_text =  configModel.start_conv_text != nil ? start_conv_text?.updateWith(configModel: configModel.start_conv_text!) : start_conv_text
        self.quick_start_buttons =  configModel.quick_start_buttons != nil ? quick_start_buttons?.updateWith(configModel: configModel.quick_start_buttons!) : quick_start_buttons
        return self
    }
}

public class Icon: NSObject , Decodable {
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
    
    public func updateWith(configModel: Icon) -> Icon{
        self.show = (configModel.show == nil)  ? show : configModel.show
        self.user_icon = (configModel.user_icon == nil)  ? user_icon : configModel.user_icon
        self.bot_icon = (configModel.bot_icon == nil)  ? bot_icon : configModel.bot_icon
        self.agent_icon = (configModel.agent_icon == nil)  ? agent_icon : configModel.agent_icon
        self.icon_url = (configModel.icon_url == nil || configModel.icon_url == "")  ? icon_url : configModel.icon_url
        self.color = (configModel.color == nil || configModel.color == "")  ? color : configModel.color
        return self
    }
}

public class Start_conv_button: NSObject , Decodable {
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
    public func updateWith(configModel: Start_conv_button) -> Start_conv_button{
        self.color = (configModel.color == nil || configModel.color == "")  ? color : configModel.color
        return self
    }
}

public class Start_conv_text: NSObject , Decodable {
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
    public func updateWith(configModel: Start_conv_text) -> Start_conv_text{
        self.color = (configModel.color == nil || configModel.color == "")  ? color : configModel.color
        return self
    }
}

public class Quick_start_buttons: NSObject , Decodable {
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

    public func updateWith(configModel: Quick_start_buttons) -> Quick_start_buttons{
        self.show = (configModel.show == nil)  ? show : configModel.show
        self.style = (configModel.style == nil || configModel.style == "")  ? style : configModel.style
        //self.buttons = configModel.buttons != nil ? buttons?.updateWith(configModel: configModel.buttons!) : buttons
        self.input = (configModel.input == nil || configModel.input == "")  ? input : configModel.input
        self.action = configModel.action != nil ? action?.updateWith(configModel: configModel.action!) : action
        return self
    }
}

public class Static_links: NSObject , Decodable {
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
    
    public func updateWith(configModel: Static_links) -> Static_links{
        self.show = (configModel.show == nil)  ? show : configModel.show
        self.layout = (configModel.layout == nil || configModel.layout == "")  ? layout : configModel.layout
        //self.links = configModel.links != nil ? links?.updateWith(configModel: configModel.links!) : links
        return self
    }

}
public class Buttons: NSObject , Decodable {
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
    
    public func updateWith(configModel: Buttons) -> Buttons{
        self.title = (configModel.title == nil || configModel.title == "")  ? title : configModel.title
        self.action = configModel.action != nil ? action?.updateWith(configModel: configModel.action!) : action
        self.close = configModel.close != nil ? close?.updateWith(configModel: configModel.close!) : close
        self.expand = configModel.expand != nil ? expand?.updateWith(configModel: configModel.expand!) : expand
        self.help = configModel.help != nil ? help?.updateWith(configModel: configModel.help!) : help
        self.live_agent = configModel.live_agent != nil ? live_agent?.updateWith(configModel: configModel.live_agent!) : live_agent
        self.minimise = configModel.minimise != nil ? minimise?.updateWith(configModel: configModel.minimise!) : minimise
        self.reconnect = configModel.reconnect != nil ? reconnect?.updateWith(configModel: configModel.reconnect!) : reconnect
        self.menu = configModel.menu != nil ? menu?.updateWith(configModel: configModel.menu!) : menu
        self.emoji = configModel.emoji != nil ? emoji?.updateWith(configModel: configModel.emoji!) : emoji
        self.microphone = configModel.microphone != nil ? microphone?.updateWith(configModel: configModel.microphone!) : microphone
        self.attachment = configModel.attachment != nil ? attachment?.updateWith(configModel: configModel.attachment!) : attachment
        return self
    }

}
public class Action : NSObject , Decodable {
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
    public func updateWith(configModel: Action) -> Action{
        self.type = (configModel.type == nil || configModel.type == "")  ? type : configModel.type
        self.value = (configModel.value == nil || configModel.value == "")  ? value : configModel.value
        self.icon = (configModel.icon == nil || configModel.icon == "")  ? icon : configModel.icon
        return self
    }

}

public class Links : NSObject , Decodable {
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

    public func updateWith(configModel: Links) -> Links{
        self.title = (configModel.title == nil || configModel.title == "")  ? title : configModel.title
        self.descrip = (configModel.descrip == nil || configModel.descrip == "")  ? descrip : configModel.descrip
        self.action = configModel.action != nil ? action?.updateWith(configModel: configModel.action!) : action
        return self
    }
}

public class Close: NSObject , Decodable {
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
    public func updateWith(configModel: Close) -> Close{
        self.icon = (configModel.icon == nil || configModel.icon == "")  ? icon : configModel.icon
        self.show = (configModel.show == nil)  ? show : configModel.show
        return self
    }

}

public class Help : NSObject , Decodable {
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
    
    public func updateWith(configModel: Help) -> Help{
        self.show = (configModel.show == nil)  ? show : configModel.show
        self.action = configModel.action != nil ? action?.updateWith(configModel: configModel.action!) : action
        return self
    }

}

public class LiveAgent : NSObject , Decodable {
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
    
    public func updateWith(configModel: LiveAgent) -> LiveAgent{
        self.show = (configModel.show == nil)  ? show : configModel.show
        self.action = configModel.action != nil ? action?.updateWith(configModel: configModel.action!) : action
        return self
    }
}

public class Promotional_Content : NSObject , Decodable {
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

    public func updateWith(configModel: Promotional_Content) -> Promotional_Content{
        self.show = (configModel.show == nil)  ? show : configModel.show
        //self.promotions = configModel.promotions != nil ? promotions?.updateWith(configModel: configModel.promotions!) : promotions
        return self
    }
}
public class Promotions : NSObject , Decodable {
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

    public func updateWith(configModel: Promotions) -> Promotions{
        self.banner = (configModel.banner == nil)  ? banner : configModel.banner
        self.action = configModel.action != nil ? action?.updateWith(configModel: configModel.action!) : action
        return self
    }
}

