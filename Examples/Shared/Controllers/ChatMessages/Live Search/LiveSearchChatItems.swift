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
    public var requestId: String?
    
    enum ColorCodeKeys: String, CodingKey {
        case templateType = "templateType"
        case template = "template"
        case requestId = "requestId"
    }
    
    // MARK: - init
    public override init() {
        super.init()
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ColorCodeKeys.self)
        templateType = try? container.decode(String.self, forKey: .templateType)
        template = try? container.decode(TemplateChatElements.self, forKey: .template)
        requestId = try? container.decode(String.self, forKey: .requestId)
        
    }
}
class TemplateChatElements: NSObject, Decodable {
    public var originalQuery: String?
    public var cleanQuery: String?
    public var totalNumOfResults: Int?
    
    public var facets: [TemplateSearchFacets]?//TemplateFacets?
    public var results: TemplateChatResultElements?
    public var searchFacets : [TemplateSearchFacets]?
    public var tabFacet : TabFacets?
    
    enum ColorCodeKeys: String, CodingKey {
        case originalQuery = "originalQuery"
        case cleanQuery = "cleanQuery"
        case facets = "facets"
        case results = "results"
        case searchFacets = "searchFacets"
        case totalNumOfResults = "totalNumOfResults"
        case tabFacet = "tabFacet"
    }
    
    // MARK: - init
    public override init() {
        super.init()
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ColorCodeKeys.self)
        originalQuery = try? container.decode(String.self, forKey: .originalQuery)
        cleanQuery = try? container.decode(String.self, forKey: .cleanQuery)
        facets = try? container.decode([TemplateSearchFacets].self, forKey: .facets)
        results = try? container.decode(TemplateChatResultElements.self, forKey: .results)
        searchFacets = try? container.decode([TemplateSearchFacets].self, forKey: .searchFacets)
        totalNumOfResults = try? container.decode(Int.self, forKey: .totalNumOfResults)
        tabFacet = try? container.decode(TabFacets.self, forKey: .tabFacet)
    }
}

class TemplateChatResultElements: NSObject, Decodable {
    public var faq: TemplateChatResultElementDic?
    public var page: TemplateChatResultElementDic?
    public var task: TemplateChatResultElementDic?
    public var document: TemplateChatResultElementDic?
    public var file: TemplateChatResultElementDic?
    public var data: TemplateChatResultElementDic?

    
    
    enum ColorCodeKeys: String, CodingKey {
        case faq = "faq"
        case page = "web"
        case task = "task"
        case document = "document"
        case file = "file"
        case data = "default_group"
    }
    
    // MARK: - init
    public override init() {
        super.init()
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ColorCodeKeys.self)
        faq = try? container.decode(TemplateChatResultElementDic.self, forKey: .faq)
        page = try? container.decode(TemplateChatResultElementDic.self, forKey: .page)
        task = try? container.decode(TemplateChatResultElementDic.self, forKey: .task)
        document = try? container.decode(TemplateChatResultElementDic.self, forKey: .document)
        file = try? container.decode(TemplateChatResultElementDic.self, forKey: .file)
        data = try? container.decode(TemplateChatResultElementDic.self, forKey: .data)
    }
}


class TemplateChatResultElementDic: NSObject, Decodable {
    public var data: [TemplateResultElements]?
    public var doc_count: Int?
    
    enum ColorCodeKeys: String, CodingKey {
        case data = "data"
        case doc_count = "doc_count"
    }
    
    // MARK: - init
    public override init() {
        super.init()
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ColorCodeKeys.self)
        data = try? container.decode([TemplateResultElements].self, forKey: .data)
        doc_count = try? container.decode(Int.self, forKey: .doc_count)
    }
}




class TemplateSearchFacets: NSObject, Decodable {
    public var fieldName: String?
    public var facetName: String?
    public var facetType: String?
    public var buckets: [SearchFacetsBuckets]?
    public var name: String?
    public var multiselect: Bool?
    
    
    enum ColorCodeKeys: String, CodingKey {
        case fieldName = "fieldName"
        case facetName = "facetName"
        case facetType = "facetType"
        case buckets = "buckets"
        case name = "name"
        case multiselect = "multiselect"
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
        name = try? container.decode(String.self, forKey: .name)
        multiselect = try? container.decode(Bool.self, forKey: .multiselect)
    }
}

class SearchFacetsBuckets: NSObject, Decodable {
    public var key: String?
    public var doc_count: Int?
    public var name: String?
   
    enum ColorCodeKeys: String, CodingKey {
        case key = "key"
        case doc_count = "doc_count"
       case name = "name"
    }
    
    // MARK: - init
    public override init() {
        super.init()
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ColorCodeKeys.self)
        key = try? container.decode(String.self, forKey: .key)
        doc_count = try? container.decode(Int.self, forKey: .doc_count)
        name = try? container.decode(String.self, forKey: .name)
    }
}
class TabFacets: NSObject, Decodable {
    public var fieldName: String?
    public var buckets: [SearchFacetsBuckets]?
   
    enum ColorCodeKeys: String, CodingKey {
        case fieldName = "fieldName"
        case buckets = "buckets"
      
    }
    
    // MARK: - init
    public override init() {
        super.init()
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ColorCodeKeys.self)
        fieldName = try? container.decode(String.self, forKey: .fieldName)
        buckets = try? container.decode([SearchFacetsBuckets].self, forKey: .buckets)
    }
}

