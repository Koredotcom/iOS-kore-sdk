//
//  QuickRepliesData.swift
//  KoreBotSDKDemo
//
//  Created by Kartheek Pagidimarri on 7/17/20.
//  Copyright © 2020 Kore. All rights reserved.
//

import UIKit

// MARK: - Quick Replies Welcome
public class QuickRepliesWelcomeData: NSObject, Decodable {
    public var content_type: String?
    public var payload: String?
    public var title: String?
    
    public var showMoreMessages: String?
    public var type: String?
    public var url: String?

    enum ColorCodeKeys: String, CodingKey {
        case content_type = "content_type"
        case payload = "payload"
        case title = "title"
        
        case showMoreMessages = "showMoreMessages"
        case type = "type"
        case url = "url"
    }
    
    // MARK: - init
    public override init() {
        super.init()
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ColorCodeKeys.self)
        content_type = try? container.decode(String.self, forKey: .content_type)
        payload = try? container.decode(String.self, forKey: .payload)
        title = try? container.decode(String.self, forKey: .title)
        
        showMoreMessages = try? container.decode(String.self, forKey: .showMoreMessages)
        type = try? container.decode(String.self, forKey: .type)
        url = try? container.decode(String.self, forKey: .url)
    }
}
