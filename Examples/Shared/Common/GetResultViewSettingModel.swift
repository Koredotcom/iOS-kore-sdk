//
//  GetResultViewSettingModel.swift
//  KoreBotSDKDemo
//
//  Created by Kartheek.Pagidimarri on 20/05/21.
//  Copyright © 2021 Kore. All rights reserved.
//

import UIKit

public class GetResultViewSettingModel: NSObject, Decodable {

    public var settings: [Settings]?
    
       enum ColorCodeKeys: String, CodingKey {
            case settings = "settings"
       }
       
       // MARK: - init
       public override init() {
           super.init()
       }
       
       required public init(from decoder: Decoder) throws {
       let container = try decoder.container(keyedBy: ColorCodeKeys.self)
           settings = try? container.decode([Settings].self, forKey: .settings)
       }
}

public class Settings: NSObject, Decodable {

       public var _id: String?
       public var view: String?
       public var maxResultsAllowed: Int?
       public var interface: String?
       public var resultClassification: ResultClassification?
       public var appearance: [Appearance]?
       public var facets: Facets?
       
       enum ColorCodeKeys: String, CodingKey {
            case _id = "_id"
           case view = "view"
           case maxResultsAllowed = "maxResultsAllowed"
           case interface = "interface"
           case resultClassification = "resultClassification"
           case appearance = "appearance"
           case facets = "facets"
       }
       
       // MARK: - init
       public override init() {
           super.init()
       }
       
       required public init(from decoder: Decoder) throws {
       let container = try decoder.container(keyedBy: ColorCodeKeys.self)
           _id = try? container.decode(String.self, forKey: ._id)
           view = try? container.decode(String.self, forKey: .view)
           maxResultsAllowed = try? container.decode(Int.self, forKey: .maxResultsAllowed)
           interface = try? container.decode(String.self, forKey: .interface)
           resultClassification = try? container.decode(ResultClassification.self, forKey: .resultClassification)
           appearance = try? container.decode([Appearance].self, forKey: .appearance)
           facets = try? container.decode(Facets.self, forKey: .facets)
           
       }
}

public class ResultClassification: NSObject, Decodable {
    
    public var isEnabled: Bool?
    public var sourceType: String?
    
    
    enum ColorCodeKeys: String, CodingKey {
         case isEnabled = "isEnabled"
        case sourceType = "sourceType"
    }
    
    // MARK: - init
    public override init() {
        super.init()
    }
    
    required public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: ColorCodeKeys.self)
        isEnabled = try? container.decode(Bool.self, forKey: .isEnabled)
        sourceType = try? container.decode(String.self, forKey: .sourceType)
    }

}

public class Facets: NSObject, Decodable {
    
    public var isEnabled: Bool?
    public var aligned: String?
    
    
    enum ColorCodeKeys: String, CodingKey {
         case isEnabled = "isEnabled"
        case aligned = "aligned"
    }
    
    // MARK: - init
    public override init() {
        super.init()
    }
    
    required public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: ColorCodeKeys.self)
        isEnabled = try? container.decode(Bool.self, forKey: .isEnabled)
        aligned = try? container.decode(String.self, forKey: .aligned)
    }

}

public class Appearance: NSObject, Decodable {
    
    public var template: Template?
    public var type: String?
    
    
    enum ColorCodeKeys: String, CodingKey {
         case template = "template"
        case type = "type"
    }
    
    // MARK: - init
    public override init() {
        super.init()
    }
    
    required public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: ColorCodeKeys.self)
        template = try? container.decode(Template.self, forKey: .template)
        type = try? container.decode(String.self, forKey: .type)
    }

}

public class Template: NSObject, Decodable {
    
    public var appearanceType: String?
    public var type: String?
    public var layout: Layout?
    public var mapping: Mapping?
    
    
    enum ColorCodeKeys: String, CodingKey {
         case appearanceType = "appearanceType"
         case type = "type"
         case layout = "layout"
         case mapping = "mapping"
    }
    
    // MARK: - init
    public override init() {
        super.init()
    }
    
    required public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: ColorCodeKeys.self)
        appearanceType = try? container.decode(String.self, forKey: .appearanceType)
        type = try? container.decode(String.self, forKey: .type)
        layout = try? container.decode(Layout.self, forKey: .layout)
        mapping = try? container.decode(Mapping.self, forKey: .mapping)
    }

}

public class Layout: NSObject, Decodable {
    
    public var behaviour: String?
    public var isClickable: Bool?
    public var layoutType: String?
    public var textAlignment: String?
    
    
    enum ColorCodeKeys: String, CodingKey {
         case behaviour = "behaviour"
         case isClickable = "isClickable"
         case layoutType = "layoutType"
         case textAlignment = "textAlignment"
    }
    
    // MARK: - init
    public override init() {
        super.init()
    }
    
    required public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: ColorCodeKeys.self)
        behaviour = try? container.decode(String.self, forKey: .behaviour)
        isClickable = try? container.decode(Bool.self, forKey: .isClickable)
        layoutType = try? container.decode(String.self, forKey: .layoutType)
        textAlignment = try? container.decode(String.self, forKey: .textAlignment)
    }

}

public class Mapping: NSObject, Decodable {
    
    public var descrip: String?
    public var heading: String?
    public var img: String?
    public var url: String?
    
    
    enum ColorCodeKeys: String, CodingKey {
         case descrip = "description"
         case heading = "heading"
         case img = "img"
         case url = "url"
    }
    
    // MARK: - init
    public override init() {
        super.init()
    }
    
    required public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: ColorCodeKeys.self)
        descrip = try? container.decode(String.self, forKey: .descrip)
        heading = try? container.decode(String.self, forKey: .heading)
        img = try? container.decode(String.self, forKey: .img)
        url = try? container.decode(String.self, forKey: .url)
    }

}
