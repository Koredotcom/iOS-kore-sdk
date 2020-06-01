//
//  NewListData.swift
//  KoreBotSDKDemo
//
//  Created by MatrixStream_01 on 12/05/20.
//  Copyright © 2020 Kore. All rights reserved.
//

import Foundation
struct Welcome: Codable {
    let type: String
    let payload: Payload
}

// MARK: - Payload
struct Payload: Codable {
    let templateType: String
    let seeMore: Bool
    let moreCount: Int
    let text, heading: String
    let buttons: [Button]
    let elements: [Element]
    let moreData: MoreData
    
    enum CodingKeys: String, CodingKey {
        case templateType = "template_type"
        case seeMore, moreCount, text, heading, buttons, elements, moreData
    }
}

// MARK: - Button
struct Button: Codable {
    let title, type, payload: String
}

// MARK: - Element
struct Element: Codable {
    let title: String
    let imageURL: String
    let subtitle, value: String
    let defaultAction: ElementDefaultAction
    
    enum CodingKeys: String, CodingKey {
        case title
        case imageURL = "image_url"
        case subtitle, value
        case defaultAction = "default_action"
    }
}

// MARK: - ElementDefaultAction
struct ElementDefaultAction: Codable {
    let title: String?
    let fallbackURL: String?
    let type: String?
    let url: String?
    
    enum CodingKeys: String, CodingKey {
        case title
        case fallbackURL = "fallback_url"
        case type, url
    }
}

// MARK: - MoreData
struct MoreData: Codable {
    let tab1: [Tab]
    let tab2: [Tab]
    
    enum CodingKeys: String, CodingKey {
        case tab1 = "Tab1"
        case tab2 = "Tab2"
    }
}

// MARK: - Tab1
struct Tab: Codable {
    let title: String
    let imageURL: String
    let subtitle, value: String
    let defaultAction: Tab1DefaultAction
    
    enum CodingKeys: String, CodingKey {
        case title
        case imageURL = "image_url"
        case subtitle, value
        case defaultAction = "default_action"
    }
}

// MARK: - Tab1DefaultAction
struct Tab1DefaultAction: Codable {
    let title: String?
    let fallbackURL: String?
    let type: String?
    let url: String?
    
    enum CodingKeys: String, CodingKey {
        case title
        case fallbackURL = "fallback_url"
        case type, url
    }
}
