//
//  KREButtonTemplate.swift
//  KoreBotSDK
//
//  Created by Srinivas Vasadi on 13/03/19.
//  Copyright © 2019 Srinivas Vasadi. All rights reserved.
//

import UIKit

public class KREButtonTemplate: KREAction {
    public var action_type: String?
    public var api: String?
    public var hasMore: String?
    public var template_type: String?
    public var theme: String?
    public var image: KREImageTemplate?
    
    public enum ButtonKeys: String, CodingKey {
        case action_type = "action_type"
        case api = "api"
        case title = "title"
        case hasMore = "hasMore"
        case template_type = "template_type"
        case theme = "theme"
        case type = "type"
        case utterance = "utterance"
        case payload = "payload"
        case image = "image"
    }
    
    required public init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: ButtonKeys.self)
        title = try? container.decode(String.self, forKey: .title)
        action_type = try? container.decode(String.self, forKey: .action_type)
        api = try? container.decode(String.self, forKey: .api)
        hasMore = try? container.decode(String.self, forKey: .hasMore)
        template_type = try? container.decode(String.self, forKey: .template_type)
        template_type = try? container.decode(String.self, forKey: .template_type)
        theme = try? container.decode(String.self, forKey: .theme)
        type = try? container.decode(String.self, forKey: .type)
        utterance = try? container.decode(String.self, forKey: .utterance)
        payload = try? container.decode(String.self, forKey: .payload)
        image = try? container.decode(KREImageTemplate.self, forKey: .image)
    }
}

// MARK: - KASkillMessage
public class KASkillMessage: NSObject, Decodable {
    public var name: String?
    public var iconColor: String?
    public var color: String?
    public var icon: String?
    public var skillId: String?
    public var text: String?
    public var trigger: String?
    public var typingIndicator: Bool?
    
    public enum PayloadKeys: String, CodingKey {
        case text = "text"
        case skill = "skill"
    }
    
    public enum SkillKeys: String, CodingKey {
        case color = "color"
        case icon = "icon"
        case iconColor = "iconColor"
        case skillId = "id"
        case name = "name"
        case trigger = "trigger"
        case typingIndicator = "typingIndicator"
    }

    public override init() {
    }

    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: PayloadKeys.self)
        text = try? container.decode(String.self, forKey: .text)

        if let skillContainer = try? container.nestedContainer(keyedBy: SkillKeys.self, forKey: .skill) {
            color = try? skillContainer.decode(String.self, forKey: .color)
            icon = try? skillContainer.decode(String.self, forKey: .icon)
            iconColor = try? skillContainer.decode(String.self, forKey: .iconColor)
            name = try? skillContainer.decode(String.self, forKey: .name)
            skillId = try? skillContainer.decode(String.self, forKey: .skillId)
            trigger = try? skillContainer.decode(String.self, forKey: .trigger)
            typingIndicator = try? skillContainer.decode(Bool.self, forKey: .typingIndicator)
        } else {
            let container = try decoder.container(keyedBy: SkillKeys.self)
            color = try? container.decode(String.self, forKey: .color)
            icon = try? container.decode(String.self, forKey: .icon)
            iconColor = try? container.decode(String.self, forKey: .iconColor)
            name = try? container.decode(String.self, forKey: .name)
            skillId = try? container.decode(String.self, forKey: .skillId)
            trigger = try? container.decode(String.self, forKey: .trigger)
            typingIndicator = try? container.decode(Bool.self, forKey: .typingIndicator)
        }
    }
}

// MARK: - KASkillMessage
public class KAEndDialogueMessage: NSObject, Decodable {
    public var event: String?
    public var templateType: String?
    public var text: String?

    public enum PayloadKeys: String, CodingKey {
        case text = "text"
        case event = "event"
        case templateType = "template_type"
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: PayloadKeys.self)
        text = try? container.decode(String.self, forKey: .text)
        event = try? container.decode(String.self, forKey: .event)
        templateType = try? container.decode(String.self, forKey: .templateType)
    }
}

public class KREMultiActions: NSObject, Decodable {
    public var show: String?
    public var title: String?
    public var type: String?
    public var utterance: String?
    
    public enum ButtonKeys: String, CodingKey {
        case show = "show"
        case title = "title"
        case type = "type"
        case utterance = "utterance"
    }
    
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ButtonKeys.self)
        show = try? container.decode(String.self, forKey: .show)
        title = try? container.decode(String.self, forKey: .title)
        type = try? container.decode(String.self, forKey: .type)
        utterance = try? container.decode(String.self, forKey: .utterance)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: ButtonKeys.self)
        try container.encode(title, forKey: .title)
        try container.encode(show, forKey: .show)
        try container.encode(type, forKey: .type)
        try container.encode(utterance, forKey: .utterance)
    }
}

// MARK: - KREHeaderOptions
public class KREButtonsLayout: NSObject, Decodable {
    public var count: Int16?
    public var style: String?

    public enum LayoutKeys: String, CodingKey {
        case displayLimitContainer = "displayLimitContainer"
        case style = "style"
        case count = "count"
    }
    
    // MARK: - init
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: LayoutKeys.self)
        if let displayLimitContainer = try? container.nestedContainer(keyedBy: LayoutKeys.self, forKey: .displayLimitContainer) {
            count = try? container.decode(Int16.self, forKey: .count)
        }
        style = try? container.decode(String.self, forKey: .style)
    }
}
