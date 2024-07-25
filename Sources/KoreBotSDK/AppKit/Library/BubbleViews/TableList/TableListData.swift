//
//  TableListData.swift
//  KoreBotSDKDemo
//
//  Created by Kartheek Pagidimarri on 7/15/20.
//  Copyright © 2020 Kore. All rights reserved.
//

import UIKit

public class TableListData: NSObject, Decodable {
      public var template_type: String?
      public var title: String?
      //public var description: String?
      public var headerOptions: HeaderOptions?
      public var elements: [TableListElements]?
     
    
    enum ColorCodeKeys: String, CodingKey {
            case template_type = "template_type"
            case title = "title"
            //case description = "description"
            case headerOptions = "headerOptions"
            case elements = "elements"
            
       }
       
       // MARK: - init
       public override init() {
           super.init()
       }
       
       required public init(from decoder: Decoder) throws {
           let container = try decoder.container(keyedBy: ColorCodeKeys.self)
           template_type = try? container.decode(String.self, forKey: .template_type)
           title = try? container.decode(String.self, forKey: .title)
           //description = try? container.decode(String.self, forKey: .description)
           headerOptions = try? container.decode(HeaderOptions.self, forKey: .headerOptions)
           elements = try? container.decode([TableListElements].self, forKey: .elements)
           
       }
}
// MARK: - Header Options
public class HeaderOptions: NSObject, Decodable {
    // MARK: - properties
    public var type: String?
    public var text: String?

    enum ColorCodeKeys: String, CodingKey {
        case type = "type"
        case text = "text"
    }
    
    // MARK: - init
    public override init() {
        super.init()
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ColorCodeKeys.self)
        type = try? container.decode(String.self, forKey: .type)
        text = try? container.decode(String.self, forKey: .text)
    }
}
// MARK: - Elements
public class TableListElements: NSObject, Decodable {
    public var sectionHeader: String?
    public var sectionHeaderDesc: String?
    public var rowItems: [TableListElementRows]?
    
    
    enum ColorCodeKeys: String, CodingKey {
        case sectionHeader = "sectionHeader"
        case sectionHeaderDesc = "sectionHeaderDesc"
        case rowItems = "rowItems"
        
    }
    
    // MARK: - init
    public override init() {
        super.init()
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ColorCodeKeys.self)
        sectionHeader = try? container.decode(String.self, forKey: .sectionHeader)
        sectionHeaderDesc = try? container.decode(String.self, forKey: .sectionHeaderDesc)
        rowItems = try? container.decode([TableListElementRows].self, forKey: .rowItems)
        
    }
}
// MARK: - Elements Rows
public class TableListElementRows: NSObject, Decodable {
    public var title: TableListElementRowTitle?
    public var value: TableListElementRowValue?
    public var action: ComponentItemAction?
    public var bgcolor: String?
    
    
    enum ColorCodeKeys: String, CodingKey {
        case title = "title"
        case value = "value"
        case action = "default_action"
        case bgcolor = "bgcolor"
        
    }
    
    // MARK: - init
    public override init() {
        super.init()
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ColorCodeKeys.self)
        title = try? container.decode(TableListElementRowTitle.self, forKey: .title)
        value = try? container.decode(TableListElementRowValue.self, forKey: .value)
        action = try? container.decode(ComponentItemAction.self, forKey: .action)
        bgcolor = try? container.decode(String.self, forKey: .bgcolor)
        
    }
}
// MARK: - Elements Row Title
public class TableListElementRowTitle: NSObject, Decodable {
    public var image: TableListElementRowTitleImage?
    public var type: String?
    public var text: TableListElementRowTitleText?
    public var rowColor: String?
    public var url: TableListElementRowTitleUrl?
    
    
    enum ColorCodeKeys: String, CodingKey {
        case image = "image"
        case type = "type"
        case text = "text"
        case rowColor = "rowColor"
        case url = "url"
        
    }
    
    // MARK: - init
    public override init() {
        super.init()
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ColorCodeKeys.self)
        image = try? container.decode(TableListElementRowTitleImage.self, forKey: .image)
        type = try? container.decode(String.self, forKey: .type)
        text = try? container.decode(TableListElementRowTitleText.self, forKey: .text)
        rowColor = try? container.decode(String.self, forKey: .rowColor)
        url = try? container.decode(TableListElementRowTitleUrl.self, forKey: .url)
    }
}

// MARK: - Elements Row Title Image
public class TableListElementRowTitleImage: NSObject, Decodable {
    public var image_type: String?
    public var image_src: String?
    public var radius: Double?
    public var size: String?
    
    
    enum ColorCodeKeys: String, CodingKey {
        case image_type = "image_type"
        case image_src = "image_src"
        case radius = "radius"
        case size = "size"
        
    }
    
    // MARK: - init
    public override init() {
        super.init()
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ColorCodeKeys.self)
        image_type = try? container.decode(String.self, forKey: .image_type)
        image_src = try? container.decode(String.self, forKey: .image_src)
        radius = try? container.decode(Double.self, forKey: .radius)
        size = try? container.decode(String.self, forKey: .size)
        
    }
}

// MARK: - Elements Row Title Text
public class TableListElementRowTitleText: NSObject, Decodable {
    public var title: String?
    public var subtitle: String?
    public var payload: String?
    
    enum ColorCodeKeys: String, CodingKey {
        case title = "title"
        case subtitle = "subtitle"
        case payload = "payload"
    }
    
    // MARK: - init
    public override init() {
        super.init()
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ColorCodeKeys.self)
        title = try? container.decode(String.self, forKey: .title)
        subtitle = try? container.decode(String.self, forKey: .subtitle)
        payload = try? container.decode(String.self, forKey: .payload)
    }
}

// MARK: - Elements Row Title Url
public class TableListElementRowTitleUrl: NSObject, Decodable {
    public var title: String?
    public var subtitle: String?
    public var link: String?
    public var textDecoration: String?
    
    
    
    enum ColorCodeKeys: String, CodingKey {
        case title = "title"
        case subtitle = "subtitle"
        case link = "link"
        case textDecoration = "text-decoration"
    }
    
    // MARK: - init
    public override init() {
        super.init()
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ColorCodeKeys.self)
        title = try? container.decode(String.self, forKey: .title)
        subtitle = try? container.decode(String.self, forKey: .subtitle)
        link = try? container.decode(String.self, forKey: .link)
        textDecoration = try? container.decode(String.self, forKey: .textDecoration)
    }
}

// MARK: - Elements Row Value
public class TableListElementRowValue: NSObject, Decodable {
    public var type: String?
    public var url: TableListElementRowValueUrl?
    public var layout: TableListElementRowValueLayOut?
    public var text: String?
    
    
    enum ColorCodeKeys: String, CodingKey {
        case type = "type"
        case url = "url"
        case layout = "layout"
        case text = "text"
        
    }
    
    // MARK: - init
    public override init() {
        super.init()
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ColorCodeKeys.self)
        type = try? container.decode(String.self, forKey: .type)
        url = try? container.decode(TableListElementRowValueUrl.self, forKey: .url)
        layout = try? container.decode(TableListElementRowValueLayOut.self, forKey: .layout)
        text =  try? container.decode(String.self, forKey: .text)
    }
}

// MARK: - Elements Row Value Url
public class TableListElementRowValueUrl: NSObject, Decodable {
    public var link: String?
    public var title: String?

    enum ColorCodeKeys: String, CodingKey {
        case link = "link"
        case title = "title"
    }
    
    // MARK: - init
    public override init() {
        super.init()
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ColorCodeKeys.self)
        link = try? container.decode(String.self, forKey: .link)
        title = try? container.decode(String.self, forKey: .title)
    }
}

// MARK: - Elements Row Value Url
public class TableListElementRowValueLayOut: NSObject, Decodable {
    public var align: String?
    public var color: String?
    public var colSize: String?

    enum ColorCodeKeys: String, CodingKey {
        case align = "align"
        case color = "color"
        case colSize = "colSize"
    }
    
    // MARK: - init
    public override init() {
        super.init()
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ColorCodeKeys.self)
        align = try? container.decode(String.self, forKey: .align)
        color = try? container.decode(String.self, forKey: .color)
        colSize = try? container.decode(String.self, forKey: .colSize)
    }
}

