//
//  AutoSuggestionModel.swift
//  KoreBotSDKDemo
//
//  Created by Kartheek.Pagidimarri on 15/06/21.
//  Copyright © 2021 Kore. All rights reserved.
//

import UIKit

class AutoSuggestionModel: NSObject, Decodable {
    
    public var requestId: String?
    public var originalQuery: String?
    public var autoComplete: AutoComplete?
    
    enum ColorCodeKeys: String, CodingKey {
        case requestId = "requestId"
        case originalQuery = "originalQuery"
        case autoComplete = "autoComplete"
    }
    
    // MARK: - init
    public override init() {
        super.init()
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ColorCodeKeys.self)
        requestId = try? container.decode(String.self, forKey: .requestId)
        originalQuery = try? container.decode(String.self, forKey: .originalQuery)
        autoComplete = try? container.decode(AutoComplete.self, forKey: .autoComplete)
        
    }
}

class AutoComplete: NSObject, Decodable {
    
    public var querySuggestions: [String]?
    public var typeAheads: [String]?
    
    enum ColorCodeKeys: String, CodingKey {
        case querySuggestions = "querySuggestions"
        case typeAheads = "typeAheads"
    }
    
    // MARK: - init
    public override init() {
        super.init()
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ColorCodeKeys.self)
        querySuggestions = try? container.decode([String].self, forKey: .querySuggestions)
        typeAheads = try? container.decode([String].self, forKey: .typeAheads)
    }
}
