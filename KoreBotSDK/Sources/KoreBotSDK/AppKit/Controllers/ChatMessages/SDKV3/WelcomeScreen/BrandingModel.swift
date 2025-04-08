//
//  BrandingModel.swift
//  KoreBotSDKDemo
//
//  Created by Kartheek.Pagidimarri on 12/11/20.
//  Copyright © 2020 Kore. All rights reserved.
//

import UIKit

public class BrandingModel: NSObject , Decodable {
    
    public var body: Body?
    public var chat_bubble: ChatBubble?
    public var footer: FooterModel?
    public var general: General?
    public var header: HeaderModel?
    public var welcome_screen: WelcomeScreen?
    public var override_kore_config: OverrideKoreConfig?
   
    enum ColorCodeKeys: String, CodingKey {
           case body = "body"
           case chat_bubble = "chat_bubble"
           case footer = "footer"
           case general = "general"
           case header = "header"
           case welcome_screen = "welcome_screen"
          case override_kore_config = "override_kore_config"
        
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
           override_kore_config = try? container.decode(OverrideKoreConfig.self, forKey: .override_kore_config)
       }
    
    public func updateWith(configModel: BrandingModel)-> BrandingModel{
        self.body = configModel.body != nil ? body?.updateWith(configModel: configModel.body!) : body
        self.chat_bubble = configModel.chat_bubble != nil ? chat_bubble?.updateWith(configModel: configModel.chat_bubble!) : chat_bubble
        self.footer = configModel.footer != nil ? footer?.updateWith(configModel: configModel.footer!) : footer
        self.general = configModel.general != nil ? general?.updateWith(configModel: configModel.general!) : general
        self.header = configModel.header != nil ? header?.updateWith(configModel: configModel.header!) : header
        self.welcome_screen = configModel.welcome_screen != nil ? welcome_screen?.updateWith(configModel: configModel.welcome_screen!) : welcome_screen
        self.override_kore_config = configModel.override_kore_config != nil ? override_kore_config?.updateWith(configModel: configModel.override_kore_config!) : override_kore_config
        return self
    }
}


public class General : NSObject , Decodable {
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
    
    public func updateWith(configModel: General) -> General{
        self.bot_icon = (configModel.bot_icon == nil || configModel.bot_icon == "")  ? bot_icon : configModel.bot_icon
        self.size = (configModel.size == nil || configModel.size == "")  ? size : configModel.size
        self.themeType = (configModel.themeType == nil || configModel.themeType == "")  ? themeType : configModel.themeType
        self.generalColors = (configModel.generalColors == nil)  ? generalColors : configModel.generalColors
        return self
    }

}

public class GeneralColors : NSObject , Decodable {
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
    
    public func updateWith(configModel: GeneralColors) -> GeneralColors{
        self.primaryColor = (configModel.primaryColor == nil || configModel.primaryColor == "")  ? primaryColor : configModel.primaryColor
        self.primary_text = (configModel.primary_text == nil || configModel.primary_text == "")  ? primary_text : configModel.primary_text
        self.secondaryColor = (configModel.secondaryColor == nil || configModel.secondaryColor == "")  ? secondaryColor : configModel.secondaryColor
        self.secondary_text = (configModel.secondary_text == nil || configModel.secondary_text == "")  ? secondary_text : configModel.secondary_text
        self.useColorPaletteOnly = (configModel.useColorPaletteOnly == nil)  ? useColorPaletteOnly : configModel.useColorPaletteOnly
        return self
    }

}

