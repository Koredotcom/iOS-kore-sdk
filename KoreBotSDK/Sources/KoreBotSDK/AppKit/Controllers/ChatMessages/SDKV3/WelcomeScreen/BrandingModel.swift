//
//  BrandingModel.swift
//  KoreBotSDKDemo
//
//  Created by Kartheek.Pagidimarri on 12/11/20.
//  Copyright © 2020 Kore. All rights reserved.
//

import UIKit

class BrandingModel: NSObject , Decodable {
    
    public var body: Body?
    public var chat_bubble: ChatBubble?
    public var footer: FooterModel?
    public var general: General?
    public var header: HeaderModel?
    public var welcome_screen: WelcomeScreen?
   
    enum ColorCodeKeys: String, CodingKey {
           case body = "body"
           case chat_bubble = "chat_bubble"
           case footer = "footer"
           case general = "general"
           case header = "header"
           case welcome_screen = "welcome_screen"
        
       }
       
       // MARK: - init
       public override init() {
           super.init()
       }
       
       required public init(from decoder: Decoder) throws {
           let container = try decoder.container(keyedBy: ColorCodeKeys.self)
           body = try? container.decode(Body.self, forKey: .body)
           chat_bubble = try? container.decode(ChatBubble.self, forKey: .chat_bubble)
           footer = try? container.decode(FooterModel.self, forKey: .footer)
           general = try? container.decode(General.self, forKey: .general)
           header = try? container.decode(HeaderModel.self, forKey: .header)
           welcome_screen = try? container.decode(WelcomeScreen.self, forKey: .welcome_screen)
       }
}


class General : NSObject , Decodable {
    public var bot_icon : String?
    public var size : String?
    public var themeType : String?
    public var generalColors: GeneralColors?

    enum CodingKeys: String, CodingKey {
        case bot_icon = "bot_icon"
        case size = "size"
        case themeType = "themeType"
        case generalColors = "colors"
    }
    // MARK: - init
    public override init() {
        super.init()
    }
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        bot_icon = try? container.decode(String.self, forKey: .bot_icon)
        size = try? container.decode(String.self, forKey: .size)
        themeType = try? container.decode(String.self, forKey: .themeType)
        generalColors = try? container.decode(GeneralColors.self, forKey: .generalColors)
    }

}

class GeneralColors : NSObject , Decodable {
    public var primaryColor : String?
    public var primary_text : String?
    public var secondaryColor : String?
    public var secondary_text : String?
    public var useColorPaletteOnly : Bool?

    enum CodingKeys: String, CodingKey {
        case primaryColor = "primary"
        case primary_text = "primary_text"
        case secondaryColor = "secondary"
        case secondary_text = "secondary_text"
        case useColorPaletteOnly = "useColorPaletteOnly"
    }
    // MARK: - init
    public override init() {
        super.init()
    }
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        primaryColor = try? container.decode(String.self, forKey: .primaryColor)
        primary_text = try? container.decode(String.self, forKey: .primary_text)
        secondaryColor = try? container.decode(String.self, forKey: .secondaryColor)
        secondary_text = try? container.decode(String.self, forKey: .secondary_text)
        useColorPaletteOnly = try? container.decode(Bool.self, forKey: .useColorPaletteOnly)
    }

}

