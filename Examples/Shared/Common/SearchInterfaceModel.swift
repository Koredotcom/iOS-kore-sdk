//
//  SearchInterfaceModel.swift
//  KoreBotSDKDemo
//
//  Created by Kartheek.Pagidimarri on 20/05/21.
//  Copyright © 2021 Kore. All rights reserved.
//

import UIKit

public class SearchInterfaceModel: NSObject, Decodable {
    
    public var _id: String?
    public var createdBy: String?
    public var indexPipelineId: String?
    public var experienceConfig: ExperienceConfig?
    public var lModifiedBy: String?
    public var widgetConfig: WidgetConfig?
    public var interactionsConfig: InteractionsConfig?

    enum ColorCodeKeys: String, CodingKey {
         case _id = "_id"
         case createdBy = "createdBy"
         case indexPipelineId = "indexPipelineId"
         case experienceConfig = "experienceConfig"
         case lModifiedBy = "lModifiedBy"
         case widgetConfig = "widgetConfig"
         case interactionsConfig = "interactionsConfig"
     
    }
    
    // MARK: - init
    public override init() {
        super.init()
    }
    
    required public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: ColorCodeKeys.self)
    _id = try? container.decode(String.self, forKey: ._id)
    createdBy = try? container.decode(String.self, forKey: .createdBy)
    indexPipelineId = try? container.decode(String.self, forKey: .indexPipelineId)
    //buttons = try? container.decode([ComponentItemAction].self, forKey: .buttons)
    experienceConfig = try? container.decode(ExperienceConfig.self, forKey: .experienceConfig)
    lModifiedBy = try? container.decode(String.self, forKey: .lModifiedBy)
    widgetConfig = try? container.decode(WidgetConfig.self, forKey: .widgetConfig)
    interactionsConfig = try? container.decode(InteractionsConfig.self, forKey: .interactionsConfig)
    }

}

public class ExperienceConfig: NSObject, Decodable {
    
    public var searchBarPosition: String?
    
    enum ColorCodeKeys: String, CodingKey {
         case searchBarPosition = "searchBarPosition"
    }
    
    // MARK: - init
    public override init() {
        super.init()
    }
    
    required public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: ColorCodeKeys.self)
    searchBarPosition = try? container.decode(String.self, forKey: .searchBarPosition)
    }

}

public class WidgetConfig: NSObject, Decodable {
    
    public var searchBarFillColor: String?
    public var searchBarBorderColor: String?
    public var searchBarPlaceholderText: String?
    public var searchBarPlaceholderTextColor: String?
    public var searchButtonEnabled: Bool?
    public var buttonText: String?
    public var buttonTextColor: String?
    public var buttonFillColor: String?
    public var buttonBorderColor: String?
    public var buttonPlacementPosition: String?
    public var searchBarIcon: String?
    //public var userSelectedColors: String?
    
    enum ColorCodeKeys: String, CodingKey {
         case searchBarFillColor = "searchBarFillColor"
        case searchBarBorderColor = "searchBarBorderColor"
        case searchBarPlaceholderText = "searchBarPlaceholderText"
        case searchBarPlaceholderTextColor = "searchBarPlaceholderTextColor"
        case searchButtonEnabled = "searchButtonEnabled"
        case buttonText = "buttonText"
        case buttonTextColor = "buttonTextColor"
        case buttonFillColor = "buttonFillColor"
        case buttonBorderColor = "buttonBorderColor"
        case buttonPlacementPosition = "buttonPlacementPosition"
        case searchBarIcon = "searchBarIcon"
        case searchBarPosition = "searchBarPosition"
        //case userSelectedColors = "userSelectedColors"
    }
    
    // MARK: - init
    public override init() {
        super.init()
    }
    
    required public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: ColorCodeKeys.self)
        searchBarFillColor = try? container.decode(String.self, forKey: .searchBarFillColor)
        searchBarBorderColor = try? container.decode(String.self, forKey: .searchBarBorderColor)
        searchBarPlaceholderText = try? container.decode(String.self, forKey: .searchBarPlaceholderText)
        searchBarPlaceholderTextColor = try? container.decode(String.self, forKey: .searchBarPlaceholderTextColor)
        searchButtonEnabled = try? container.decode(Bool.self, forKey: .searchButtonEnabled)
        buttonText = try? container.decode(String.self, forKey: .buttonText)
        buttonTextColor = try? container.decode(String.self, forKey: .buttonTextColor)
        buttonFillColor = try? container.decode(String.self, forKey: .buttonFillColor)
        buttonBorderColor = try? container.decode(String.self, forKey: .buttonBorderColor)
        buttonPlacementPosition = try? container.decode(String.self, forKey: .buttonPlacementPosition)
        searchBarIcon = try? container.decode(String.self, forKey: .searchBarIcon)
        //userSelectedColors = try? container.decode(String.self, forKey: .userSelectedColors)
        
        
    }

}

public class InteractionsConfig: NSObject, Decodable {
    
    public var welcomeMsg: String?
    public var welcomeMsgColor: String?
    public var showSearchesEnabled: Bool?
    public var showSearches: String?
    public var autocompleteOpt: Bool?
    public var welcomeMsgEmoji: String?
    public var querySuggestionsLimit: Int?
    public var liveSearchResultsLimit: Int?
    public var feedbackExperience: FeedbackExperience?
    
    
    enum ColorCodeKeys: String, CodingKey {
         case welcomeMsg = "welcomeMsg"
         case welcomeMsgColor = "welcomeMsgColor"
         case showSearchesEnabled = "showSearchesEnabled"
         case showSearches = "showSearches"
         case autocompleteOpt = "autocompleteOpt"
         case welcomeMsgEmoji = "welcomeMsgEmoji"
         case querySuggestionsLimit = "querySuggestionsLimit"
         case liveSearchResultsLimit = "liveSearchResultsLimit"
         case feedbackExperience = "feedbackExperience"
    }
    
    // MARK: - init
    public override init() {
        super.init()
    }
    
    required public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: ColorCodeKeys.self)
        welcomeMsg = try? container.decode(String.self, forKey: .welcomeMsg)
        welcomeMsgColor = try? container.decode(String.self, forKey: .welcomeMsgColor)
        showSearchesEnabled = try? container.decode(Bool.self, forKey: .showSearchesEnabled)
        showSearches = try? container.decode(String.self, forKey: .showSearches)
        autocompleteOpt = try? container.decode(Bool.self, forKey: .autocompleteOpt)
        welcomeMsgEmoji = try? container.decode(String.self, forKey: .welcomeMsgEmoji)
        querySuggestionsLimit = try? container.decode(Int.self, forKey: .querySuggestionsLimit)
        liveSearchResultsLimit = try? container.decode(Int.self, forKey: .liveSearchResultsLimit)
        feedbackExperience = try? container.decode(FeedbackExperience.self, forKey: .feedbackExperience)
    }

}

public class FeedbackExperience: NSObject, Decodable {
    
    public var resultLevel: Bool?
    public var queryLevel: Bool?
    
    
    enum ColorCodeKeys: String, CodingKey {
         case resultLevel = "resultLevel"
        case queryLevel = "queryLevel"
    }
    
    // MARK: - init
    public override init() {
        super.init()
    }
    
    required public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: ColorCodeKeys.self)
        resultLevel = try? container.decode(Bool.self, forKey: .resultLevel)
        queryLevel = try? container.decode(Bool.self, forKey: .queryLevel)
    }

}
