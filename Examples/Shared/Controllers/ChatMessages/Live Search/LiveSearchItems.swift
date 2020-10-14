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
    
    public var facets: String?
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
        facets = try? container.decode(String.self, forKey: .facets)
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
