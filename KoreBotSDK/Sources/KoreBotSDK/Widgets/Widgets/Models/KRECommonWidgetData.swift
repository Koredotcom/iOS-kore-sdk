//
//  KRECommonWidgetData.swift
//  KoreBotSDK
//
//  Created by Sukhmeet Singh on 19/11/19.
//

import UIKit

public class KRECommonWidgetData: NSObject, Decodable {
    public var title: String?
    public var sub_title: String?
    public var text: String?
    public var defaultAction: KREAction?
    public var button: [KREButtonTemplate]?
    public var icon: String?
    public var actions: [KREAction]?
    public var theme: String?
    
    enum CommonWidgetInfoKeys: String, CodingKey {
        case title = "title"
        case sub_title = "sub_title"
        case button = "button"
        case icon = "icon"
        case actions = "actions"
        case text = "text"
        case theme = "theme"
        case defaultAction = "default_action"
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CommonWidgetInfoKeys.self)
        title = try? container.decode(String.self, forKey: .title)
        sub_title = try? container.decode(String.self, forKey: .sub_title)
        icon = try? container.decode(String.self, forKey: .icon)
        button = try? container.decode([KREButtonTemplate].self, forKey: .button)
        actions = try? container.decode([KREAction].self, forKey: .actions)
        text = try? container.decode(String.self, forKey: .text)
        theme = try? container.decode(String.self, forKey: .theme)
        defaultAction = try? container.decode(KREAction.self, forKey: .defaultAction)
    }
}


public class KRELogInData: NSObject, Decodable {
    public var title: String?
    public var text: String?
    public var url: String?
    
    enum LoginWidgetInfoKeys: String, CodingKey {
        case title = "title"
        case url = "url"
        case text = "text"
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: LoginWidgetInfoKeys.self)
        title = try? container.decode(String.self, forKey: .title)
        text = try? container.decode(String.self, forKey: .text)
        url = try? container.decode(String.self, forKey: .url)
    }
}
