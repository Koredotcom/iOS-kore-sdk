//
//  KREPanels.swift
//  KoreBotSDK
//
//  Created by Sukhmeet Singh on 17/10/19.
//

import UIKit

// MARK: - KREPanelItem
public class KREPanelItem: NSObject, Decodable {
    public var icon: String?
    public var iconId: String?
    public var name: String?
    public var widgets: [KREWidget]?
    public var theme: String?
    public var trigger: String?
    public var skillId: String?
    public var type: String?
    public var panelId: String?
    public var id: String?
    public var selectionState = false
    public var action: KREPanelItemAction?
    
    enum ColorCodeKeys: String, CodingKey {
        case icon = "icon"
        case iconId = "iconId"
        case name = "name"
        case widgets = "widgets"
        case theme =  "theme"
        case trigger = "trigger"
        case skillId = "skillId"
        case type = "type"
        case panelId = "panelId"
        case id = "_id"
        case action = "action"
    }
    
    // MARK: - init
    public override init() {
        super.init()
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ColorCodeKeys.self)
        icon = try? container.decode(String.self, forKey: .icon)
        iconId = try? container.decode(String.self, forKey: .iconId)
        name = try? container.decode(String.self, forKey: .name)
        theme = try? container.decode(String.self, forKey: .theme)
        widgets = try? container.decode([KREWidget].self, forKey: .widgets)
        trigger = try? container.decode(String.self, forKey: .trigger)
        skillId = try? container.decode(String.self, forKey: .skillId)
        type = try? container.decode(String.self, forKey: .type)
        panelId = try? container.decode(String.self, forKey: .panelId)
        id = try? container.decode(String.self, forKey: .id)
        action = try? container.decode(KREPanelItemAction.self, forKey: .action)
    }
}

// MARK: - KREPanelItemAction
public class KREPanelItemAction: NSObject, Decodable {
    // MARK: - properties
    public var subType: String?
    public var uri: String?
    public var url: String?

    enum ActionKeys: String, CodingKey {
        case subType = "subType"
        case uri = "uri"
        case url = "url"
    }
    
    // MARK: - init
    public override init() {
        super.init()
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ActionKeys.self)
        subType = try? container.decode(String.self, forKey: .subType)
        uri = try? container.decode(String.self, forKey: .uri)
        url = try? container.decode(String.self, forKey: .url)
    }
}
