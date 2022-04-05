//
//  TabFacetModel.swift
//  KoreBotSDKDemo
//
//  Created by Kartheek.Pagidimarri on 02/02/22.
//  Copyright © 2022 Kore. All rights reserved.
//

import UIKit

class TabFacetModel: NSObject, Decodable {

    public var multiselect: Bool?
    public var tabs: [FacetTabs]?
    enum ColorCodeKeys: String, CodingKey {
        case multiselect = "multiselect"
        case tabs = "tabs"
    }
    
    // MARK: - init
    public override init() {
        super.init()
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ColorCodeKeys.self)
        multiselect = try? container.decode(Bool.self, forKey: .multiselect)
        tabs = try? container.decode([FacetTabs].self, forKey: .tabs)
    }
}

class FacetTabs: NSObject, Decodable {
    public var bucketName: String?
    public var fieldValue: String?
    
    enum ColorCodeKeys: String, CodingKey {
        case bucketName = "bucketName"
        case fieldValue = "fieldValue"
    }
    
    // MARK: - init
    public override init() {
        super.init()
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ColorCodeKeys.self)
        bucketName = try? container.decode(String.self, forKey: .bucketName)
        fieldValue = try? container.decode(String.self, forKey: .fieldValue)
    }
}
