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

public class ActiveTheme: NSObject , Decodable {
      public var botName : String?
      public var botMessage: BotMessagee?
      public var buttons: Buttons?
      public var userMessage: BotMessagee?
      public var widgetBody: WidgetBody?
      public var widgetFooter: WidgetFooter?
      public var widgetHeader: WidgetHeader?
      public var generalAttributes: GeneralAttributes?
    
    enum ColorCodeKeys: String, CodingKey {
            case botMessage = "botMessage"
            case buttons = "buttons"
            case userMessage = "userMessage"
            case widgetBody = "widgetBody"
            case widgetFooter = "widgetFooter"
            case widgetHeader = "widgetHeader"
            case generalAttributes = "generalAttributes"
            case botName = "botName"
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
           generalAttributes = try? container.decode(GeneralAttributes.self, forKey: .generalAttributes)
           botName = try? container.decode(String.self, forKey: .botName)
       }
    
    public func updateWith(configModel: ActiveTheme)-> ActiveTheme{
        self.botMessage = configModel.botMessage != nil ? botMessage?.updateWith(configModel: configModel.botMessage!) : botMessage
        self.buttons = configModel.buttons != nil ? buttons?.updateWith(configModel: configModel.buttons!) : buttons
        self.userMessage = configModel.userMessage != nil ? userMessage?.updateWith(configModel: configModel.userMessage!) : userMessage
        self.widgetBody = configModel.widgetBody != nil ? widgetBody?.updateWith(configModel: configModel.widgetBody!) : widgetBody
        self.widgetFooter = configModel.widgetFooter != nil ? widgetFooter?.updateWith(configModel: configModel.widgetFooter!) : widgetFooter
        self.widgetHeader = configModel.widgetHeader != nil ? widgetHeader?.updateWith(configModel: configModel.widgetHeader!) : widgetHeader
        self.generalAttributes = configModel.generalAttributes != nil ? generalAttributes?.updateWith(configModel: configModel.generalAttributes!) : generalAttributes
        self.botName = (configModel.botName == nil || configModel.botName == "")  ? botName : configModel.botName
        return self
    }
}



public class BotMessagee: NSObject , Decodable {
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
    
    public func updateWith(configModel: BotMessagee) -> BotMessagee{
        self.bordercolor = (configModel.bordercolor == nil || configModel.bordercolor == "")  ? bordercolor : configModel.bordercolor
        self.bubbleColor = (configModel.bubbleColor == nil || configModel.bubbleColor == "")  ? bubbleColor : configModel.bubbleColor
        self.fontcolor = (configModel.fontcolor == nil || configModel.fontcolor == "")  ? fontcolor : configModel.fontcolor
        return self
    }
}


public class Buttons: NSObject , Decodable {
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
    
    public func updateWith(configModel: Buttons) -> Buttons{
        self.borderColor = (configModel.borderColor == nil || configModel.borderColor == "")  ? borderColor : configModel.borderColor
        self.defaultButtonColor = (configModel.defaultButtonColor == nil || configModel.defaultButtonColor == "")  ? defaultButtonColor : configModel.defaultButtonColor
        self.defaultFontColor = (configModel.defaultFontColor == nil || configModel.defaultFontColor == "")  ? defaultFontColor : configModel.defaultFontColor
        self.onHoverButtonColor = (configModel.onHoverButtonColor == nil || configModel.onHoverButtonColor == "")  ? onHoverButtonColor : configModel.onHoverButtonColor
        self.onHoverFontColor = (configModel.onHoverFontColor == nil || configModel.onHoverFontColor == "")  ? onHoverFontColor : configModel.onHoverFontColor
        return self
    }
}

public class WidgetBody: NSObject , Decodable {
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
    
    public func updateWith(configModel: WidgetBody) -> WidgetBody{
        self.backGroundColor = (configModel.backGroundColor == nil || configModel.backGroundColor == "")  ? backGroundColor : configModel.backGroundColor
        self.backGroundImage = (configModel.backGroundImage == nil || configModel.backGroundImage == "")  ? backGroundImage : configModel.backGroundImage
        self.useBackgroundImage = (configModel.useBackgroundImage == nil)  ? useBackgroundImage : configModel.useBackgroundImage
        return self
    }
}

public class WidgetFooter: NSObject , Decodable {
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
    
    public func updateWith(configModel: WidgetFooter) -> WidgetFooter{
        self.backGroundColor = (configModel.backGroundColor == nil || configModel.backGroundColor == "")  ? backGroundColor : configModel.backGroundColor
        self.bordercolor = (configModel.bordercolor == nil || configModel.bordercolor == "")  ? bordercolor : configModel.bordercolor
        self.fontcolor = (configModel.fontcolor == nil || configModel.fontcolor == "")  ? fontcolor : configModel.fontcolor
        self.placeHolder = (configModel.placeHolder == nil || configModel.placeHolder == "")  ? placeHolder : configModel.placeHolder
        return self
    }
}

public class WidgetHeader: NSObject , Decodable {
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
    
    public func updateWith(configModel: WidgetHeader) -> WidgetHeader{
        self.backGroundColor = (configModel.backGroundColor == nil || configModel.backGroundColor == "")  ? backGroundColor : configModel.backGroundColor
        self.bordercolor = (configModel.bordercolor == nil || configModel.bordercolor == "")  ? bordercolor : configModel.bordercolor
        self.fontcolor = (configModel.fontcolor == nil || configModel.fontcolor == "")  ? fontcolor : configModel.fontcolor
        return self
    }
}

public class GeneralAttributes: NSObject , Decodable {
      public var bubbleShape: String?
      public var bordercolor: String?
    
    enum ColorCodeKeys: String, CodingKey {
            case bubbleShape = "bubbleShape"
            case bordercolor = "borderColor"
       }
       
       // MARK: - init
       public override init() {
           super.init()
       }
       
       required public init(from decoder: Decoder) throws {
           let container = try decoder.container(keyedBy: ColorCodeKeys.self)
           bubbleShape = try? container.decode(String.self, forKey: .bubbleShape)
           bordercolor = try? container.decode(String.self, forKey: .bordercolor)
       }
    public func updateWith(configModel: GeneralAttributes) -> GeneralAttributes{
        self.bubbleShape = (configModel.bubbleShape == nil || configModel.bubbleShape == "")  ? bubbleShape : configModel.bubbleShape
        self.bordercolor = (configModel.bordercolor == nil || configModel.bordercolor == "")  ? bordercolor : configModel.bordercolor
        return self
    }
}
