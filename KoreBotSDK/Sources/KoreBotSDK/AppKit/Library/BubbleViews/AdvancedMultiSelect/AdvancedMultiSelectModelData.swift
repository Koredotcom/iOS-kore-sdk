//
//  AdvancedMultiSelectModelData.swift
//  KoreBotSDKDemo
//
//  Created by Kartheek Pagidimarri on 12/10/23.
//  Copyright © 2023 Kore. All rights reserved.
//

import UIKit

public class AdvancedMultiSelectCollection: NSObject, Decodable {
    public var title: String?
    public var descrip: String?
    public var value: String?
    public var image_url: String?
    
    enum ColorCodeKeys: String, CodingKey {
        case title = "title"
        case descrip = "description"
        case value = "value"
        case image_url = "image_url"
    }
    
    // MARK: - init
    public override init() {
        super.init()
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ColorCodeKeys.self)
        title = try? container.decode(String.self, forKey: .title)
        descrip = try? container.decode(String.self, forKey: .descrip)
        value = try? container.decode(String.self, forKey: .value)
        image_url = try? container.decode(String.self, forKey: .image_url)
    }
}
