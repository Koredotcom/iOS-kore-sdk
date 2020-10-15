//
//  LiveSearchChatItems.swift
//  KoreBotSDKDemo
//
//  Created by Kartheek.Pagidimarri on 15/10/20.
//  Copyright © 2020 Kore. All rights reserved.
//

import UIKit

class LiveSearchChatItems: NSObject, Decodable {
    public var templateType: String?
    public var template: TemplateChatElements?
    
    
    enum ColorCodeKeys: String, CodingKey {
        case templateType = "templateType"
        case template = "template"
    }
    
    // MARK: - init
    public override init() {
        super.init()
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ColorCodeKeys.self)
        templateType = try? container.decode(String.self, forKey: .templateType)
        template = try? container.decode(TemplateChatElements.self, forKey: .template)
        
    }
}
class TemplateChatElements: NSObject, Decodable {
    public var originalQuery: String?
    public var cleanQuery: String?
    
    public var facets: TemplateFacets?
    public var results: TemplateChatResultElements?
    
    
    enum ColorCodeKeys: String, CodingKey {
        case originalQuery = "originalQuery"
        case cleanQuery = "cleanQuery"
        case facets = "facets"
        case results = "results"
    }
    
    // MARK: - init
    public override init() {
        super.init()
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ColorCodeKeys.self)
        originalQuery = try? container.decode(String.self, forKey: .originalQuery)
        cleanQuery = try? container.decode(String.self, forKey: .cleanQuery)
        facets = try? container.decode(TemplateFacets.self, forKey: .facets)
        results = try? container.decode(TemplateChatResultElements.self, forKey: .results)
    }
}

class TemplateChatResultElements: NSObject, Decodable {
    public var faq: [TemplateResultElements]?
    public var page: [TemplateResultElements]?
    public var task: [TemplateResultElements]?
   
    
    
    enum ColorCodeKeys: String, CodingKey {
        case faq = "faq"
        case page = "page"
        case task = "task"
    }
    
    // MARK: - init
    public override init() {
        super.init()
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ColorCodeKeys.self)
        faq = try? container.decode([TemplateResultElements].self, forKey: .faq)
        page = try? container.decode([TemplateResultElements].self, forKey: .page)
        task = try? container.decode([TemplateResultElements].self, forKey: .task)
    }
}

