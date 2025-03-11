//
//  ChatBubbleModel.swift
//  KoreBotSDKDemo
//
//  Created by Kartheek Pagidimarri on 25/08/23.
//  Copyright © 2023 Kore. All rights reserved.
//

import UIKit

public class ChatBubble : NSObject , Decodable {
    public var style : String?
    public var icon : Icon?
    public var minimise : Minimise?
    public var sound : String?
    public var alignment : String?
    public var animation : String?
    public var expand_animation : String?
    public var primary_color : String?
    public var secondary_color : String?

    enum CodingKeys: String, CodingKey {
        case style = "style"
        case icon = "icon"
        case minimise = "minimise"
        case sound = "sound"
        case alignment = "alignment"
        case animation = "animation"
        case expand_animation = "expand_animation"
        case primary_color = "primary_color"
        case secondary_color = "secondary_color"
    }
    // MARK: - init
    public override init() {
        super.init()
    }
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        style = try? container.decode(String.self, forKey: .style)
        icon = try? container.decode(Icon.self, forKey: .icon)
        minimise = try? container.decode(Minimise.self, forKey: .minimise)
        sound = try? container.decode(String.self, forKey: .sound)
        alignment = try? container.decode(String.self, forKey: .alignment)
        animation = try? container.decode(String.self, forKey: .animation)
        expand_animation = try? container.decode(String.self, forKey: .expand_animation)
        primary_color = try? container.decode(String.self, forKey: .primary_color)
        secondary_color = try? container.decode(String.self, forKey: .secondary_color)
    }
    
    public func updateWith(configModel: ChatBubble) -> ChatBubble{
        self.style = (configModel.style == nil || configModel.style == "")  ? style : configModel.style
        self.icon = (configModel.icon == nil)  ? icon : configModel.icon
        self.minimise = (configModel.minimise == nil)  ? minimise : configModel.minimise
        self.sound = (configModel.sound == nil || configModel.sound == "")  ? sound : configModel.sound
        self.alignment = (configModel.alignment == nil || configModel.alignment == "")  ? alignment : configModel.alignment
        self.animation = (configModel.animation == nil || configModel.animation == "")  ? animation : configModel.animation
        self.expand_animation = (configModel.expand_animation == nil || configModel.expand_animation == "")  ? expand_animation : configModel.expand_animation
        self.primary_color = (configModel.primary_color == nil || configModel.primary_color == "")  ? primary_color : configModel.primary_color
        self.secondary_color = (configModel.secondary_color == nil || configModel.secondary_color == "")  ? secondary_color : configModel.secondary_color
        return self
    }

}

public class Minimise : NSObject , Decodable {
    public var show : String?
    public var theme : String?
    public var icon : Icon?
    
    enum CodingKeys: String, CodingKey {
        case show = "show"
        case icon = "icon"
        case theme = "theme"
    }
    // MARK: - init
    public override init() {
        super.init()
    }
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        show = try? container.decode(String.self, forKey: .show)
        icon = try? container.decode(Icon.self, forKey: .icon)
        theme = try? container.decode(String.self, forKey: .theme)
    }
    
    public func updateWith(configModel: Minimise) -> Minimise{
        self.show = (configModel.show == nil || configModel.show == "")  ? show : configModel.show
        self.icon = (configModel.icon == nil)  ? icon : configModel.icon
        self.theme = (configModel.theme == nil || configModel.theme == "")  ? theme : configModel.theme
        return self
    }

}
