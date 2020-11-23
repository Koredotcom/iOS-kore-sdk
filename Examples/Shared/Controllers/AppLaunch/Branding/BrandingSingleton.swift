//
//  BrandingSingleton.swift
//  KoreBotSDKDemo
//
//  Created by Kartheek.Pagidimarri on 12/11/20.
//  Copyright © 2020 Kore. All rights reserved.
//

import UIKit

class BrandingSingleton: NSObject {
    
    // MARK: Shared Instance
    static let shared = BrandingSingleton()
    
    // MARK: Local Variable
    var widgetBorderColor: String?
    var widgetTextColor: String?
    var buttonInactiveBgColor: String?
    var buttonInactiveTextColor: String?
    var widgetBgColor: String?
    var botchatTextColor: String?
    var buttonActiveBgColor: String?
    var buttonActiveTextColor: String?
    var userchatBgColor: String?
    var theme: String?
    var botName: String?
    var botchatBgColor: String?
    var userchatTextColor: String?
    var widgetDividerColor: String?
    
    var bankLogo: String?
    var widgetBgImage: String?
    var widgetBodyColor: String?
    var widgetFooterColor: String?
    var widgetHeaderColor: String?
    
    var hamburgerOptions: Dictionary<String, Any>?
    var brandingInfoModel: BrandingModel?
}
