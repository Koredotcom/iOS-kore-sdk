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
