//
//  BrandingModel.swift
//  KoreBotSDKDemo
//
//  Created by Kartheek.Pagidimarri on 12/11/20.
//  Copyright © 2020 Kore. All rights reserved.
//

import UIKit

class BrandingModel: NSObject , Decodable {
      public var widgetBorderColor: String?
      public var widgetTextColor: String?
      public var buttonInactiveBgColor: String?
      public var buttonInactiveTextColor: String?
      public var widgetBgColor: String?
      public var botchatTextColor: String?
      public var buttonActiveBgColor: String?
      public var buttonActiveTextColor: String?
      public var userchatBgColor: String?
      public var theme: String?
      public var botName: String?
      public var botchatBgColor: String?
      public var userchatTextColor: String?
      public var widgetDividerColor: String?
     
    public var bankLogo: String?
    public var widgetBgImage: String?
    public var widgetBodyColor: String?
    public var widgetFooterColor: String?
    public var widgetHeaderColor: String?
   
    
    enum ColorCodeKeys: String, CodingKey {
            case widgetBorderColor = "widgetBorderColor"
            case widgetTextColor = "widgetTextColor"
            case buttonInactiveBgColor = "buttonInactiveBgColor"
            case buttonInactiveTextColor = "buttonInactiveTextColor"
            case widgetBgColor = "widgetBgColor"
            case botchatTextColor = "botchatTextColor"
            case buttonActiveBgColor = "buttonActiveBgColor"
            case buttonActiveTextColor = "buttonActiveTextColor"
            case userchatBgColor = "userchatBgColor"
            case theme = "theme"
            case botName = "botName"
            case botchatBgColor = "botchatBgColor"
            case userchatTextColor = "userchatTextColor"
            case widgetDividerColor = "widgetDividerColor"
        
            case bankLogo = "bankLogo"
            case widgetBgImage = "widgetBgImage"
            case widgetBodyColor = "widgetBodyColor"
            case widgetFooterColor = "widgetFooterColor"
            case widgetHeaderColor = "widgetHeaderColor"
        
       }
       
       // MARK: - init
       public override init() {
           super.init()
       }
       
       required public init(from decoder: Decoder) throws {
           let container = try decoder.container(keyedBy: ColorCodeKeys.self)
           widgetBorderColor = try? container.decode(String.self, forKey: .widgetBorderColor)
           widgetTextColor = try? container.decode(String.self, forKey: .widgetTextColor)
           buttonInactiveBgColor = try? container.decode(String.self, forKey: .buttonInactiveBgColor)
           buttonInactiveTextColor = try? container.decode(String.self, forKey: .buttonInactiveTextColor)
           widgetBgColor = try? container.decode(String.self, forKey: .widgetBgColor)
           botchatTextColor = try? container.decode(String.self, forKey: .botchatTextColor)
           buttonActiveBgColor = try? container.decode(String.self, forKey: .buttonActiveBgColor)
           buttonActiveTextColor = try? container.decode(String.self, forKey: .buttonActiveTextColor)
           userchatBgColor = try? container.decode(String.self, forKey: .userchatBgColor)
           theme = try? container.decode(String.self, forKey: .theme)
           botName = try? container.decode(String.self, forKey: .botName)
           botchatBgColor = try? container.decode(String.self, forKey: .botchatBgColor)
           userchatTextColor = try? container.decode(String.self, forKey: .userchatTextColor)
           widgetDividerColor = try? container.decode(String.self, forKey: .widgetDividerColor)
        
           bankLogo = try? container.decode(String.self, forKey: .bankLogo)
           widgetBgImage = try? container.decode(String.self, forKey: .widgetBgImage)
           widgetBodyColor = try? container.decode(String.self, forKey: .widgetBodyColor)
           widgetFooterColor = try? container.decode(String.self, forKey: .widgetFooterColor)
           widgetHeaderColor = try? container.decode(String.self, forKey: .widgetHeaderColor)
        
       }
}

class ActiveTheme: NSObject , Decodable {
      public var botMessage: BotMessagee?
      public var buttons: Buttons?
      public var userMessage: BotMessagee?
      public var widgetBody: WidgetBody?
      public var widgetFooter: WidgetFooter?
      public var widgetHeader: WidgetHeader?
    
    enum ColorCodeKeys: String, CodingKey {
            case botMessage = "botMessage"
            case buttons = "buttons"
            case userMessage = "userMessage"
            case widgetBody = "widgetBody"
            case widgetFooter = "widgetFooter"
            case widgetHeader = "widgetHeader"
       }
       
       // MARK: - init
       public override init() {
           super.init()
       }
       
       required public init(from decoder: Decoder) throws {
           let container = try decoder.container(keyedBy: ColorCodeKeys.self)
           botMessage = try? container.decode(BotMessagee.self, forKey: .botMessage)
           buttons = try? container.decode(Buttons.self, forKey: .buttons)
           userMessage = try? container.decode(BotMessagee.self, forKey: .userMessage)
           widgetBody = try? container.decode(WidgetBody.self, forKey: .widgetBody)
           widgetFooter = try? container.decode(WidgetFooter.self, forKey: .widgetFooter)
           widgetHeader = try? container.decode(WidgetHeader.self, forKey: .widgetHeader)
       }
}

class BotMessagee: NSObject , Decodable {
    public var bordercolor: String?
    public var bubbleColor: String?
    public var fontcolor: String?
  
  enum ColorCodeKeys: String, CodingKey {
          case bordercolor = "borderColor"
          case bubbleColor = "bubbleColor"
          case fontcolor = "fontColor"
     }
     
     // MARK: - init
     public override init() {
         super.init()
     }
     
     required public init(from decoder: Decoder) throws {
         let container = try decoder.container(keyedBy: ColorCodeKeys.self)
         bordercolor = try? container.decode(String.self, forKey: .bordercolor)
         bubbleColor = try? container.decode(String.self, forKey: .bubbleColor)
         fontcolor = try? container.decode(String.self, forKey: .fontcolor)
     }
}


class Buttons: NSObject , Decodable {
      public var borderColor: String?
      public var defaultButtonColor: String?
      public var defaultFontColor: String?
      public var onHoverButtonColor: String?
      public var onHoverFontColor: String?
    
    enum ColorCodeKeys: String, CodingKey {
            case borderColor = "borderColor"
            case defaultButtonColor = "defaultButtonColor"
            case defaultFontColor = "defaultFontColor"
            case onHoverButtonColor = "onHoverButtonColor"
            case onHoverFontColor = "onHoverFontColor"
       }
       
       // MARK: - init
       public override init() {
           super.init()
       }
       
       required public init(from decoder: Decoder) throws {
           let container = try decoder.container(keyedBy: ColorCodeKeys.self)
           borderColor = try? container.decode(String.self, forKey: .borderColor)
           defaultButtonColor = try? container.decode(String.self, forKey: .defaultButtonColor)
           defaultFontColor = try? container.decode(String.self, forKey: .defaultFontColor)
           onHoverButtonColor = try? container.decode(String.self, forKey: .onHoverButtonColor)
           onHoverFontColor = try? container.decode(String.self, forKey: .onHoverFontColor)
       }
}

class WidgetBody: NSObject , Decodable {
      public var backGroundColor: String?
      public var backGroundImage: String?
      public var useBackgroundImage: Bool?
    
    enum ColorCodeKeys: String, CodingKey {
            case backGroundColor = "backgroundColor"
            case backGroundImage = "backgroundImage"
            case useBackgroundImage = "useBackgroundImage"
       }
       
       // MARK: - init
       public override init() {
           super.init()
       }
       
       required public init(from decoder: Decoder) throws {
           let container = try decoder.container(keyedBy: ColorCodeKeys.self)
           backGroundColor = try? container.decode(String.self, forKey: .backGroundColor)
           backGroundImage = try? container.decode(String.self, forKey: .backGroundImage)
           useBackgroundImage = try? container.decode(Bool.self, forKey: .useBackgroundImage)
       }
}

class WidgetFooter: NSObject , Decodable {
      public var backGroundColor: String?
      public var bordercolor: String?
      public var fontcolor: String?
      public var placeHolder: String?
     
    
    enum ColorCodeKeys: String, CodingKey {
            case backGroundColor = "backgroundColor"
            case bordercolor = "borderColor"
            case fontcolor = "fontColor"
            case placeHolder = "placeHolder"
       }
       
       // MARK: - init
       public override init() {
           super.init()
       }
       
       required public init(from decoder: Decoder) throws {
           let container = try decoder.container(keyedBy: ColorCodeKeys.self)
           backGroundColor = try? container.decode(String.self, forKey: .backGroundColor)
           bordercolor = try? container.decode(String.self, forKey: .bordercolor)
           fontcolor = try? container.decode(String.self, forKey: .fontcolor)
           placeHolder = try? container.decode(String.self, forKey: .placeHolder)
       }
}

class WidgetHeader: NSObject , Decodable {
      public var backGroundColor: String?
      public var bordercolor: String?
      public var fontcolor: String?
     
    
    enum ColorCodeKeys: String, CodingKey {
            case backGroundColor = "backgroundColor"
            case bordercolor = "borderColor"
            case fontcolor = "fontColor"
       }
       
       // MARK: - init
       public override init() {
           super.init()
       }
       
       required public init(from decoder: Decoder) throws {
           let container = try decoder.container(keyedBy: ColorCodeKeys.self)
           backGroundColor = try? container.decode(String.self, forKey: .backGroundColor)
           bordercolor = try? container.decode(String.self, forKey: .bordercolor)
           fontcolor = try? container.decode(String.self, forKey: .fontcolor)
       }
}

