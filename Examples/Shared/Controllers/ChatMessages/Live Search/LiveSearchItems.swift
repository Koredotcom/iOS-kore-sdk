//
//  LiveSearchItems.swift
//  KoreBotSDKDemo
//
//  Created by Kartheek.Pagidimarri on 14/10/20.
//  Copyright © 2020 Kore. All rights reserved.
//

import UIKit

class LiveSearchItems: NSObject, Decodable {
    public var templateType: String?
    public var template: TemplateElements?
    
    
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
        template = try? container.decode(TemplateElements.self, forKey: .template)
        
    }
}

class TemplateElements: NSObject, Decodable {
    public var originalQuery: String?
    public var cleanQuery: String?
    
    public var facets: TemplateFacets?
    public var results: [TemplateResultElements]?
    
    
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
        results = try? container.decode([TemplateResultElements].self, forKey: .results)
    }
}

class TemplateResultElements: NSObject, Decodable {
    public var contentType: String?
    public var question: String?
    public var answer: String?
    public var title: String?
    public var url: String?
    public var imageUrl: String?
    public var searchResultPreview: String?
    public var taskName: String?
    public var postBackPayload: TemplatePastBackPayload?
    public var name: String?
    public var payload: String?
    public var externalFileUrl : String?
    public var pageTitle: String?
    public var pageSearchResultPreview : String?
    public var pagePreview : String?
    public var pageImageUrl : String?
    public var pageUrl : String?
    public var faqQuestion : String?
    public var faqAnswer : String?
    
    public var fileTitle : String?
    public var filePreview : String?
    public var fileimageUrl : String?
    public var fileUrl : String?
    
    public var product : String?
    public var category : String?
    public var dataImageUrl : String?
    public var dataUrl : String?
    public var childBotName: String?

    enum ColorCodeKeys: String, CodingKey {
        case contentType = "contentType"
        case question = "question"
        case answer = "answer"
        case title = "title"
        case url = "url"
        case imageUrl = "imageUrl"
        case searchResultPreview = "searchResultPreview"
        case taskName = "taskName"
        case postBackPayload = "postBackPayload"
        case name = "name"
        case payload = "payload"
        case externalFileUrl = "externalFileUrl"
        case pageTitle = "page_title"
        case pageSearchResultPreview = "pageSearchResultPreview"
        case pagePreview = "page_preview"
        case pageImageUrl = "page_image_url"
        case pageUrl = "page_url"
        case faqQuestion = "faq_question"
        case faqAnswer = "faq_answer"
        
        case fileTitle = "file_title"
        case filePreview = "file_preview"
        case fileimageUrl = "file_image_url"
        case fileUrl = "file_url"
        
        case product = "product"
        case category = "category"
        case dataImageUrl = "data_image_url"
        case dataUrl = "data_url"
        case childBotName = "childBotName"
        
    }
    
    // MARK: - init
    public override init() {
        super.init()
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ColorCodeKeys.self)
        contentType = try? container.decode(String.self, forKey: .contentType)
        question = try? container.decode(String.self, forKey: .question)
        answer = try? container.decode(String.self, forKey: .answer)
        title = try? container.decode(String.self, forKey: .title)
        url = try? container.decode(String.self, forKey: .url)
        imageUrl = try? container.decode(String.self, forKey: .imageUrl)
        searchResultPreview = try? container.decode(String.self, forKey: .searchResultPreview)
        taskName = try? container.decode(String.self, forKey: .taskName)
        postBackPayload = try? container.decode(TemplatePastBackPayload.self, forKey: .postBackPayload)
        name = try? container.decode(String.self, forKey: .name)
        payload = try? container.decode(String.self, forKey: .payload)
        externalFileUrl = try? container.decode(String.self, forKey: .externalFileUrl)
        pageTitle = try? container.decode(String.self, forKey: .pageTitle)
        pageSearchResultPreview = try? container.decode(String.self, forKey: .pageSearchResultPreview)
        pagePreview = try? container.decode(String.self, forKey: .pagePreview)
        pageImageUrl = try? container.decode(String.self, forKey: .pageImageUrl)
        pageUrl = try? container.decode(String.self, forKey: .pageUrl)
        faqQuestion = try? container.decode(String.self, forKey: .faqQuestion)
        faqAnswer = try? container.decode(String.self, forKey: .faqAnswer)
        
        fileTitle = try? container.decode(String.self, forKey: .fileTitle)
        filePreview = try? container.decode(String.self, forKey: .filePreview)
        fileimageUrl = try? container.decode(String.self, forKey: .fileimageUrl)
        fileUrl = try? container.decode(String.self, forKey: .fileUrl)
        
        product = try? container.decode(String.self, forKey: .product)
        category = try? container.decode(String.self, forKey: .category)
        dataImageUrl = try? container.decode(String.self, forKey: .dataImageUrl)
        dataUrl = try? container.decode(String.self, forKey: .dataUrl)
        childBotName = try? container.decode(String.self, forKey: .childBotName)
    }
}

class TemplatePastBackPayload: NSObject, Decodable {
    public var type: String?
    public var payload: String?
    
    enum ColorCodeKeys: String, CodingKey {
        case type = "type"
        case payload = "payload"
    }
    
    // MARK: - init
    public override init() {
        super.init()
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ColorCodeKeys.self)
        type = try? container.decode(String.self, forKey: .type)
        payload = try? container.decode(String.self, forKey: .payload)
    }
}

class TemplateFacets: NSObject, Decodable {
    public var all_results: Int?
    public var faq: Int?
    public var web: Int?
    public var task: Int?
    public var data: Int?
    public var file: Int?
    

    
    enum ColorCodeKeys: String, CodingKey {
        case all_results = "all results"
        case faq = "faq"
        case web = "web"
        case task = "task"
        case data = "data"
        case file = "file"
    }
    
    // MARK: - init
    public override init() {
        super.init()
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ColorCodeKeys.self)
        all_results = try? container.decode(Int.self, forKey: .all_results)
        faq = try? container.decode(Int.self, forKey: .faq)
        web = try? container.decode(Int.self, forKey: .web)
        task = try? container.decode(Int.self, forKey: .task)
        data = try? container.decode(Int.self, forKey: .data)
        file = try? container.decode(Int.self, forKey: .file)
    }
}