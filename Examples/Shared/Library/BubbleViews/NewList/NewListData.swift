//
//  NewListData.swift
//  KoreBotSDKDemo
//
//  Created by Kartheek Pagidimarri on 12/05/20.
//  Copyright © 2020 Kore. All rights reserved.
//

import UIKit

public class Componentss: NSObject, Decodable {
      public var template_type: String?
      public var text: String?
      public var elements: [ComponentElements]?
      public var buttons: [ComponentItemAction]?
      public var moreData: ComponentMoreData?
      public var heading: String?
      public var format: String?
      public var startDate: String?
      public var endDate: String?
      public var text_message: String?
      public var title: String?
      public var quickReplies: [QuickRepliesWelcomeData]?
      public var moreCount: Int?
      public var seeMore: Bool?
      public var image_url: String?
      public var subtitle: String?
      public var smileyArrays: [SmileyArraysAction]?
      public var messageTodisplay: String?
      public var starArrays: [SmileyArraysAction]?
      public var feedbackView: String?
    public var experienceFeedback:[ExperienceFeedback]?
    public var feedbackList:[FeedbackList]?
    public var feedbackListHeading: String?
    
    
    enum ColorCodeKeys: String, CodingKey {
            case template_type = "template_type"
            case text = "text"
            case elements = "elements"
            case buttons = "buttons"
            case moreData = "moreData"
            case heading = "heading"
            case format = "format"
            case startDate = "startDate"
            case endDate = "endDate"
            case text_message = "text_message"
            case title = "title"
            case quickReplies = "quick_replies"
            case moreCount = "moreCount"
            case seeMore = "seeMore"
            case image_url = "image_url"
            case subtitle = "subtitle"
            case smileyArrays = "smileyArrays"
            case messageTodisplay = "messageTodisplay"
            case starArrays = "starArrays"
            case feedbackView = "view"
            case experienceFeedback = "experienceContent"
        case feedbackList = "feedbackList"
        case feedbackListHeading = "feedbackListHeading"
       }
       
       // MARK: - init
       public override init() {
           super.init()
       }
       
       required public init(from decoder: Decoder) throws {
           let container = try decoder.container(keyedBy: ColorCodeKeys.self)
           template_type = try? container.decode(String.self, forKey: .template_type)
           text = try? container.decode(String.self, forKey: .text)
           elements = try? container.decode([ComponentElements].self, forKey: .elements)
           buttons = try? container.decode([ComponentItemAction].self, forKey: .buttons)
           moreData = try? container.decode(ComponentMoreData.self, forKey: .moreData)
           heading = try? container.decode(String.self, forKey: .heading)
           format = try? container.decode(String.self, forKey: .format)
           startDate = try? container.decode(String.self, forKey: .startDate)
           endDate = try? container.decode(String.self, forKey: .endDate)
           text_message = try? container.decode(String.self, forKey: .text_message)
           title = try? container.decode(String.self, forKey: .title)
           quickReplies = try? container.decode([QuickRepliesWelcomeData].self, forKey: .quickReplies)
           moreCount = try? container.decode(Int.self, forKey: .moreCount)
           seeMore = try? container.decode(Bool.self, forKey: .seeMore)
           image_url = try? container.decode(String.self, forKey: .image_url)
           subtitle = try? container.decode(String.self, forKey: .subtitle)
           smileyArrays = try? container.decode([SmileyArraysAction].self, forKey: .smileyArrays)
           messageTodisplay = try? container.decode(String.self, forKey: .messageTodisplay)
           starArrays = try? container.decode([SmileyArraysAction].self, forKey: .starArrays)
           feedbackView = try? container.decode(String.self, forKey: .feedbackView)
           experienceFeedback = try? container.decode([ExperienceFeedback].self, forKey: .experienceFeedback)
         feedbackList = try? container.decode([FeedbackList].self, forKey: .feedbackList)
        feedbackListHeading = try? container.decode(String.self, forKey: .feedbackListHeading)
       }
}
// MARK: - Elements
public class ComponentElements: NSObject, Decodable {
    public var color: String?
    public var subtitle: String?
    public var title: String?
    public var value: String?
    public var imageURL: String?
    public var action: ComponentItemAction?
    
    enum ColorCodeKeys: String, CodingKey {
        case color = "color"
        case subtitle = "subtitle"
        case title = "title"
        case value = "value"
        case imageURL = "image_url"
        case action = "default_action"
    }
    
    // MARK: - init
    public override init() {
        super.init()
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ColorCodeKeys.self)
        color = try? container.decode(String.self, forKey: .color)
        subtitle = try? container.decode(String.self, forKey: .subtitle)
        title = try? container.decode(String.self, forKey: .title)
        //value = try? container.decode(String.self, forKey: .value)
        
        if let valueInteger = try? container.decodeIfPresent(Int.self, forKey: .value) {
                   value = String(valueInteger)
            } else if let valueString = try? container.decodeIfPresent(String.self, forKey: .value) {
                   value = valueString
            }
        
//        do {
//            let val = try container.decode(Int.self, forKey: .value)
//            value = String(val)
//        } catch DecodingError.typeMismatch {
//            value = try? container.decode(String.self, forKey: .value)
//        }
        imageURL = try? container.decode(String.self, forKey: .imageURL)
        action = try? container.decode(ComponentItemAction.self, forKey: .action)
    }
}


// MARK: - ItemAction
public class ComponentItemAction: NSObject, Decodable {
    // MARK: - properties
    public var payload: String?
    public var title: String?
    public var type: String?
    public var fallback_url: String?
    public var url: String?
    public var name: String?
    public var postback: PostbackAction?
    public var label: String?
    
    

    enum ActionKeys: String, CodingKey {
        case payload = "payload"
        case title = "title"
        case type = "type"
        case fallback_url = "fallback_url"
        case url = "url"
        case name = "name"
        case postback = "postback"
        case label = "label"
        
    }
    
    // MARK: - init
    public override init() {
        super.init()
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ActionKeys.self)
        payload = try? container.decode(String.self, forKey: .payload)
        title = try? container.decode(String.self, forKey: .title)
        type = try? container.decode(String.self, forKey: .type)
        fallback_url = try? container.decode(String.self, forKey: .fallback_url)
        url = try? container.decode(String.self, forKey: .url)
        name = try? container.decode(String.self, forKey: .name)
        postback  = try? container.decode(PostbackAction.self, forKey: .postback)
        label = try? container.decode(String.self, forKey: .label)
    }
}
// MARK: - MoreData
public class ComponentMoreData: NSObject, Decodable {
    // MARK: - properties
    public var tab1: [Tabs]?
    public var tab2: [Tabs]?

    enum ColorCodeKeys: String, CodingKey {
        case tab1 = "Tab1"
        case tab2 = "Tab2"
    }
    
    // MARK: - init
    public override init() {
        super.init()
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ColorCodeKeys.self)
        tab1 = try? container.decode([Tabs].self, forKey: .tab1)
        tab2 = try? container.decode([Tabs].self, forKey: .tab2)
    }
}
// MARK: - Tabs
public class Tabs: NSObject, Decodable {
    public var title: String?
    public var subtitle: String?
    public var image_url: String?
    public var value: String?
    public var imageURL: String?
    public var action: ComponentItemAction?
    
    enum ColorCodeKeys: String, CodingKey {
        case title = "title"
        case subtitle = "subtitle"
        case image_url = "image_url"
        case value = "value"
        case action = "default_action"
    }
    
    // MARK: - init
    public override init() {
        super.init()
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ColorCodeKeys.self)
        title = try? container.decode(String.self, forKey: .title)
        subtitle = try? container.decode(String.self, forKey: .subtitle)
        image_url = try? container.decode(String.self, forKey: .image_url)
        value = try? container.decode(String.self, forKey: .value)
        action = try? container.decode(ComponentItemAction.self, forKey: .action)
    }
}


// MARK: - Postback
public class PostbackAction: NSObject, Decodable {
    public var value: String?
    
    enum ColorCodeKeys: String, CodingKey {
        case value = "value"
    }
    
    // MARK: - init
    public override init() {
        super.init()
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ColorCodeKeys.self)
        value = try? container.decode(String.self, forKey: .value)
       
    }
}

// MARK: - Smileys Array
public class SmileyArraysAction: NSObject, Decodable {
    public var value: Int?
    public var smileyId: Int?
    public var starId: Int?
    
    enum ColorCodeKeys: String, CodingKey {
        case value = "value"
        case smileyId = "smileyId"
        case starId = "starId"
    }
    
    // MARK: - init
    public override init() {
        super.init()
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ColorCodeKeys.self)
        value = try? container.decode(Int.self, forKey: .value)
        smileyId = try? container.decode(Int.self, forKey: .smileyId)
        starId = try? container.decode(Int.self, forKey: .starId)
    }
}

// MARK: - Banking Feedback Array

public class ExperienceFeedback: NSObject, Decodable {
    public var empathyMessage: String?
    public var id: String?
    public var value: String?
    
    enum ColorCodeKeys: String, CodingKey {
        case empathyMessage = "empathyMessage"
        case id = "id"
        case value = "value"
    }
    
    // MARK: - init
    public override init() {
        super.init()
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ColorCodeKeys.self)
        empathyMessage = try? container.decode(String.self, forKey: .empathyMessage)
        id = try? container.decode(String.self, forKey: .id)
        value = try? container.decode(String.self, forKey: .value)
    }
}

public class FeedbackList: NSObject, Decodable {
    public var id: String?
    public var value: String?
    
    enum ColorCodeKeys: String, CodingKey {
        case id = "id"
        case value = "value"
    }
    
    // MARK: - init
    public override init() {
        super.init()
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ColorCodeKeys.self)
        id = try? container.decode(String.self, forKey: .id)
        value = try? container.decode(String.self, forKey: .value)
    }
}


