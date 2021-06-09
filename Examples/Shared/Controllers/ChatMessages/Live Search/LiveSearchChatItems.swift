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
    public var searchFacets : [TemplateSearchFacets]?
    
    enum ColorCodeKeys: String, CodingKey {
        case originalQuery = "originalQuery"
        case cleanQuery = "cleanQuery"
        case facets = "facets"
        case results = "results"
        case searchFacets = "searchFacets"
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
        searchFacets = try? container.decode([TemplateSearchFacets].self, forKey: .searchFacets)
    }
}

class TemplateChatResultElements: NSObject, Decodable {
    public var faq: [TemplateResultElements]?
    public var page: [TemplateResultElements]?
    public var task: [TemplateResultElements]?
    public var document: [TemplateResultElements]?
    public var files: [TemplateResultElements]?

    
    
    enum ColorCodeKeys: String, CodingKey {
        case faq = "faq"
        case page = "page"
        case task = "task"
        case document = "document"
        case files = "object"
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
        document = try? container.decode([TemplateResultElements].self, forKey: .document)
        files = try? container.decode([TemplateResultElements].self, forKey: .files)
    }
}

class TemplateSearchFacets: NSObject, Decodable {
    public var fieldName: String?
    public var facetName: String?
    public var facetType: String?
    public var buckets: [SearchFacetsBuckets]?
    
    
    enum ColorCodeKeys: String, CodingKey {
        case fieldName = "fieldName"
        case facetName = "facetName"
        case facetType = "facetType"
        case buckets = "buckets"
    }
    
    // MARK: - init
    public override init() {
        super.init()
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ColorCodeKeys.self)
        fieldName = try? container.decode(String.self, forKey: .fieldName)
        facetName = try? container.decode(String.self, forKey: .facetName)
        facetType = try? container.decode(String.self, forKey: .facetType)
        buckets = try? container.decode([SearchFacetsBuckets].self, forKey: .buckets)
    }
}

class SearchFacetsBuckets: NSObject, Decodable {
    public var key: String?
    public var doc_count: Int?
   
    enum ColorCodeKeys: String, CodingKey {
        case key = "key"
        case doc_count = "doc_count"
      
    }
    
    // MARK: - init
    public override init() {
        super.init()
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ColorCodeKeys.self)
        key = try? container.decode(String.self, forKey: .key)
        doc_count = try? container.decode(Int.self, forKey: .doc_count)
    }
}
