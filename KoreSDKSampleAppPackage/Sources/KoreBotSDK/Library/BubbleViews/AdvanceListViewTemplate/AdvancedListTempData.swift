//
//  AdvancedListData.swift
//  KoreBotSDKFrameWork
//
//  Created by Kartheek Pagidimarri on 19/07/23.
//  Copyright © 2023 Kartheek.Pagidimarri. All rights reserved.
//

import UIKit
public class AdvancedListTempData: NSObject, Decodable {
    public var title: String?
    public var desc: String?
    public var descriptionIcon: String?
    public var descriptionIconAlignment: String?
    public var icon: String?
    public var headerOptions: [ListHeaderOptions]?
    public var optionsData: [OptionsData]?
    public var view: String?
    public var buttons: [DropdownOptions]?
    public var buttonAligment: String?
    public var textInformation: [DropdownOptions]?
    public var tableListData: [AdvancedTableListData]?
    public var isAccordian: Bool?
    public var isCollapsed: Bool?
    public var iconSize: String?
    public var imageSize: String?
    public var iconShape:String?
    public var elementStyles:ButtonStyles?
    public var titleStyles :ButtonStyles?
    public var descriptionStyles :ButtonStyles?
    public var buttonsLayout: ButtonsLayout?
    
    public enum ListItemKeys: String, CodingKey {
        case title = "title"
        case desc = "description"
        case descriptionIcon = "descriptionIcon"
        case descriptionIconAlignment = "descriptionIconAlignment"
        case icon = "icon"
        case headerOptions = "headerOptions"
        case optionsData = "optionsData"
        case view = "view"
        case buttons = "buttons"
        case buttonAligment = "buttonAligment"
        case textInformation = "textInformation"
        case tableListData = "tableListData"
        case isAccordian = "isAccordian"
        case isCollapsed = "isCollapsed"
        case iconSize = "iconSize"
        case imageSize = "imageSize"
        case iconShape = "iconShape"
        case elementStyles = "elementStyles"
        case titleStyles = "titleStyles"
        case descriptionStyles = "descriptionStyles"
        case buttonsLayout = "buttonsLayout"
    }

    // MARK: - init
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ListItemKeys.self)
        title = try? container.decode(String.self, forKey: .title)
        desc = try? container.decode(String.self, forKey: .desc)
        descriptionIcon = try? container.decode(String.self, forKey: .descriptionIcon)
        descriptionIconAlignment = try? container.decode(String.self, forKey: .descriptionIconAlignment)
        icon = try? container.decode(String.self, forKey: .icon)
        headerOptions = try? container.decode([ListHeaderOptions].self, forKey: .headerOptions)
        optionsData = try? container.decode([OptionsData].self, forKey: .optionsData)
        view = try? container.decode(String.self, forKey: .view)
        buttons = try? container.decode([DropdownOptions].self, forKey: .buttons)
        buttonAligment = try? container.decode(String.self, forKey: .buttonAligment)
        textInformation = try? container.decode([DropdownOptions].self, forKey: .textInformation)
        tableListData = try? container.decode([AdvancedTableListData].self, forKey: .tableListData)
        isAccordian = try? container.decode(Bool.self, forKey: .isAccordian)
        isCollapsed = try? container.decode(Bool.self, forKey: .isCollapsed)
        iconSize = try? container.decode(String.self, forKey: .iconSize)
        imageSize = try? container.decode(String.self, forKey: .imageSize)
        iconShape = try? container.decode(String.self, forKey: .iconShape)
        elementStyles = try? container.decode(ButtonStyles.self, forKey: .elementStyles)
        titleStyles = try? container.decode(ButtonStyles.self, forKey: .titleStyles)
        descriptionStyles = try? container.decode(ButtonStyles.self, forKey: .descriptionStyles)
        buttonsLayout = try? container.decode(ButtonsLayout.self, forKey: .buttonsLayout)
    }
}
public class ListHeaderOptions: NSObject, Decodable {
    public var contenttype: String?
    public var title: String?
    public var value: String?
    public var type: String?
    public var payload: String?
    public var buttonStyles: ButtonStyles?
    public var styles: ButtonStyles?
    public var headerurl: String?
    public var dropdownOptions: [DropdownOptions]?
    public var icon: String?
    
    
    public enum ListItemKeys: String, CodingKey {
        case contenttype = "contenttype"
        case title = "title"
        case type = "type"
        case payload = "payload"
        case buttonStyles = "buttonStyles"
        case headerurl = "url"
        case dropdownOptions = "dropdownOptions"
        case icon = "icon"
        case value = "value"
        case styles = "styles"
    }

    // MARK: - init
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ListItemKeys.self)
        contenttype = try? container.decode(String.self, forKey: .contenttype)
        title = try? container.decode(String.self, forKey: .title)
        type = try? container.decode(String.self, forKey: .type)
        payload = try? container.decode(String.self, forKey: .payload)
        buttonStyles = try? container.decode(ButtonStyles.self, forKey: .buttonStyles)
        headerurl = try? container.decode(String.self, forKey: .headerurl)
        dropdownOptions = try? container.decode([DropdownOptions].self, forKey: .dropdownOptions)
        icon = try? container.decode(String.self, forKey: .icon)
        value = try? container.decode(String.self, forKey: .value)
        styles = try? container.decode(ButtonStyles.self, forKey: .styles)
    }
}


public class ButtonStyles: NSObject, Decodable {
    
    public var color: String?
    public var bground: String?
    public var btnBorder: String?
    
    public enum ListItemKeys: String, CodingKey {
        case color = "color"
        case bground = "background"
        case btnBorder = "border"
    }
    // MARK: - init
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ListItemKeys.self)
        color = try? container.decode(String.self, forKey: .color)
        bground = try? container.decode(String.self, forKey: .bground)
        btnBorder = try? container.decode(String.self, forKey: .btnBorder)
    }
}

public class OptionsData: NSObject, Decodable {
    
    public var id: String?
    public var label: String?
    public var type: String?
    public var value: String?
    
    public enum ListItemKeys: String, CodingKey {
        case id = "id"
        case label = "label"
        case type = "type"
        case value = "value"
    }
    // MARK: - init
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ListItemKeys.self)
        id = try? container.decode(String.self, forKey: .id)
        label = try? container.decode(String.self, forKey: .label)
        type = try? container.decode(String.self, forKey: .type)
        value = try? container.decode(String.self, forKey: .value)
    }
}

public class DropdownOptions: NSObject, Decodable {
    public var contenttype: String?
    public var title: String?
    public var type: String?
    public var payload: String?
    public var buttonStyles: ButtonStyles?
    public var headerurl: String?
    public var icon: String?
    public var descr: String?
    public var iconSize: String?
    public var btnType: String?
    
    public enum ListItemKeys: String, CodingKey {
        case contenttype = "contenttype"
        case title = "title"
        case type = "type"
        case payload = "payload"
        case buttonStyles = "buttonStyles"
        case headerurl = "url"
        case icon = "icon"
        case descr = "description"
        case iconSize = "iconSize"
        case btnType = "btnType"
    }

    // MARK: - init
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ListItemKeys.self)
        contenttype = try? container.decode(String.self, forKey: .contenttype)
        title = try? container.decode(String.self, forKey: .title)
        type = try? container.decode(String.self, forKey: .type)
        payload = try? container.decode(String.self, forKey: .payload)
        buttonStyles = try? container.decode(ButtonStyles.self, forKey: .buttonStyles)
        headerurl = try? container.decode(String.self, forKey: .headerurl)
        icon = try? container.decode(String.self, forKey: .icon)
        descr = try? container.decode(String.self, forKey: .descr)
        iconSize = try? container.decode(String.self, forKey: .iconSize)
        btnType = try? container.decode(String.self, forKey: .btnType)
    }
}

public class AdvancedTableListData: NSObject, Decodable {
    public var rowData: [DropdownOptions]?
    public enum ListItemKeys: String, CodingKey {
        case rowData = "rowData"
    }
    // MARK: - init
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ListItemKeys.self)
        rowData = try? container.decode([DropdownOptions].self, forKey: .rowData)
    }
}
public class ButtonsLayout: NSObject, Decodable {
    public var buttonAligment: String?
    public var displayLimit: DisplayLimit?
    
    public enum ListItemKeys: String, CodingKey {
        case buttonAligment = "buttonAligment"
        case displayLimit = "displayLimit"
    }
    // MARK: - init
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ListItemKeys.self)
        buttonAligment = try? container.decode(String.self, forKey: .buttonAligment)
        displayLimit = try? container.decode(DisplayLimit.self, forKey: .displayLimit)
    }
}
public class DisplayLimit: NSObject, Decodable {
    public var displayCount: String?
    public enum ListItemKeys: String, CodingKey {
        case displayCount = "count"
    }
    // MARK: - init
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ListItemKeys.self)
        displayCount = try? container.decode(String.self, forKey: .displayCount)
    }
}

