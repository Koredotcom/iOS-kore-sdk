//
//  KREImageTemplate.swift
//  KoreBotSDK
//
//  Created by Srinivas Vasadi on 13/03/19.
//  Copyright © 2019 Srinivas Vasadi. All rights reserved.
//

import UIKit

public class KREImageTemplate: KREAction {
    public var imageType: String?
    public var source: String?
    public var radius: CGFloat?
    public var size: String?

    public enum ImageKeys: String, CodingKey {
        case imageType = "image_type"
        case source = "image_src"
        case radius = "radius"
        case size = "size"
    }
    
    // MARK: - init
    required public init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: ImageKeys.self)
        imageType = try? container.decode(String.self, forKey: .imageType)
        source = try? container.decode(String.self, forKey: .source)
        radius = try? container.decode(CGFloat.self, forKey: .radius)
        size = try? container.decode(String.self, forKey: .size)
    }
}

// MARK: - KREHeaderOptions
public class KREHeaderOptions: NSObject, Decodable {
    public var button: KREButtonTemplate?
    public var image: KREImageTemplate?
    public var menu: KREButtonTemplate?
    public var type: String?

    public enum ImageKeys: String, CodingKey {
        case button = "button"
        case image = "image"
        case menu = "menu"
        case type = "type"
    }
    
    // MARK: - init
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ImageKeys.self)
        button = try? container.decode(KREButtonTemplate.self, forKey: .button)
        image = try? container.decode(KREImageTemplate.self, forKey: .image)
        menu = try? container.decode(KREButtonTemplate.self, forKey: .menu)
        type = try? container.decode(String.self, forKey: .type)
    }
}
