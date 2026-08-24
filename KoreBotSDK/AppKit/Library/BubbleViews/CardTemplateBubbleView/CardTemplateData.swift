//
//  CardTemplateData.swift
//  KoreBotSDKFrameWork
//
//  Created by Kartheek Pagidimarri on 31/07/23.
//  Copyright © 2023 Kartheek.Pagidimarri. All rights reserved.
//

import UIKit

public class CardTemplateData: NSObject, Decodable {
    public var template_type: String?
    public var cards: [Cards]?
   
    public enum ListItemKeys: String, CodingKey {
        case template_type = "template_type"
        case cards = "cards"
    }

    // MARK: - init
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ListItemKeys.self)
        template_type = try? container.decode(String.self, forKey: .template_type)
        cards = try? container.decode([Cards].self, forKey: .cards)
    }
}

public class Cards: NSObject, Decodable {
    public var cardHeading: CardHeading?
    public var cardDescription: [CardDescription]?
    public var cardContentStyles: CardContentStyles?
    public var buttons: [CardButtons]?
    public var type: String?
    public var cardType: String?
    public var cardStyles: CardContentStyles?
    
    public enum ListItemKeys: String, CodingKey {
        case cardHeading = "cardHeading"
        case cardDescription = "cardDescription"
        case cardContentStyles = "cardContentStyles"
        case buttons = "buttons"
        case type = "type"
        case cardType = "cardType"
        case cardStyles = "cardStyles"
    }

    // MARK: - init
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ListItemKeys.self)
        cardHeading = try? container.decode(CardHeading.self, forKey: .cardHeading)
        cardDescription = try? container.decode([CardDescription].self, forKey: .cardDescription)
        cardContentStyles = try? container.decode(CardContentStyles.self, forKey: .cardContentStyles)
        buttons = try? container.decode([CardButtons].self, forKey: .buttons)
        type = try? container.decode(String.self, forKey: .type)
        cardType = try? container.decode(String.self, forKey: .cardType)
        cardStyles = try? container.decode(CardContentStyles.self, forKey: .cardStyles)
    }
}

public class CardHeading: NSObject, Decodable {
    public var title: String?
    public var desc: String?
    public var icon: String?
    public var cardDescription: CardDescription?
    public var headerStyles : HeaderStyles?
    public var iconSize : String?
    public var iconShape : String?
    public var headerExtraInfo : HeaderExtraInfo?
   
    public enum ListItemKeys: String, CodingKey {
        case title = "title"
        case cardDescription = "cardDescription"
        case desc = "description"
        case icon = "icon"
        case headerStyles = "headerStyles"
        case iconSize = "iconSize"
        case iconShape = "iconShape"
        case headerExtraInfo = "headerExtraInfo"
    }

    // MARK: - init
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ListItemKeys.self)
        title = try? container.decode(String.self, forKey: .title)
        cardDescription = try? container.decode(CardDescription.self, forKey: .cardDescription)
        desc = try? container.decode(String.self, forKey: .desc)
        icon = try? container.decode(String.self, forKey: .icon)
        headerStyles = try? container.decode(HeaderStyles.self, forKey: .headerStyles)
        iconSize = try? container.decode(String.self, forKey: .iconSize)
        iconShape = try? container.decode(String.self, forKey: .iconShape)
        headerExtraInfo = try? container.decode(HeaderExtraInfo.self, forKey: .headerExtraInfo)
    }
}

public class CardDescription: NSObject, Decodable {
    public var title: String?
    public var icon: String?
    public var descr: String?

    public enum ListItemKeys: String, CodingKey {
        case title = "title"
        case icon = "icon"
        case descr = "description"
    }

    // MARK: - init
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ListItemKeys.self)
        title = try? container.decode(String.self, forKey: .title)
        icon = try? container.decode(String.self, forKey: .icon)
        descr = try? container.decode(String.self, forKey: .descr)
    }
}

public class CardContentStyles: NSObject, Decodable {
    public var border: String?
    public var background_color: String?
    public var border_left : String?
    public var border_top : String?

    public enum ListItemKeys: String, CodingKey {
        case border = "border"
        case background_color = "background-color"
         case border_left = "border-left"
        case border_top = "border-top"
    }

    // MARK: - init
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ListItemKeys.self)
        border = try? container.decode(String.self, forKey: .border)
        background_color = try? container.decode(String.self, forKey: .background_color)
        border_left = try? container.decode(String.self, forKey: .border_left)
        border_top = try? container.decode(String.self, forKey: .border_top)
    }
}
public class HeaderStyles: NSObject, Decodable {
    public var border: String?
    public var colorr : String?
    public var background_color : String?
    public var font_weight : String?


    public enum ListItemKeys: String, CodingKey {
        case border = "border"
        case colorr = "color"
        case background_color = "background-color"
        case font_weight = "font-weight"

    }

    // MARK: - init
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ListItemKeys.self)
        border = try? container.decode(String.self, forKey: .border)
        colorr = try? container.decode(String.self, forKey: .colorr)
        background_color = try? container.decode(String.self, forKey: .background_color)
        font_weight = try? container.decode(String.self, forKey: .font_weight)

    }
}

public class CardButtons: NSObject, Decodable {
    public var title: String?
    public var type: String?
    public var payload: String?
    public var linkurl: String?
    public var buttonStyles: HeaderStyles?

    public enum ListItemKeys: String, CodingKey {
        case title = "title"
        case type = "type"
        case buttonStyles = "buttonStyles"
        case payload = "payload"
        case linkurl = "url"
    }

    // MARK: - init
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ListItemKeys.self)
        title = try? container.decode(String.self, forKey: .title)
        type = try? container.decode(String.self, forKey: .type)
        buttonStyles = try? container.decode(HeaderStyles.self, forKey: .buttonStyles)
        payload = try? container.decode(String.self, forKey: .payload)
        linkurl = try? container.decode(String.self, forKey: .linkurl)
    }
}

public class HeaderExtraInfo: NSObject, Decodable {
    public var title: String?
    public var type: String?
    public var icon: String?
    public var dropdownOptions: [DropdownOptions]?
   

    public enum ListItemKeys: String, CodingKey {
        case title = "title"
        case type = "type"
        case icon = "icon"
        case dropdownOptions = "dropdownOptions"
    }

    // MARK: - init
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ListItemKeys.self)
        title = try? container.decode(String.self, forKey: .title)
        type = try? container.decode(String.self, forKey: .type)
        icon = try? container.decode(String.self, forKey: .icon)
        dropdownOptions = try? container.decode([DropdownOptions].self, forKey: .dropdownOptions)
    }
}

