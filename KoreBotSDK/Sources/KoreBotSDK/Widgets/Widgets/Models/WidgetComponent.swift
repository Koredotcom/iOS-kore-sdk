//
//  WidgetComponent.swift
//  Pods
//
//  Created by Sukhmeet Singh on 17/10/19.
//


import UIKit

public class WidgetComponent: NSObject, Decodable {
    public var buttons: [KREButtonTemplate]?
    public var elements: [KRETaskListItem]?
    public var hasMore: Bool?
    public var icon: String?
    public var iconId: String?
    public var multiActions: Array<[String: Any]>?
    public var placeholder: String?
    public var provider: String?
    public var previewLength: Int64?
    public var text: String?
    
    public enum SummaryKeys: String, CodingKey {
        case icon, iconId, text, placeholder
    }
    
    public enum CodingKeys: String, CodingKey {
        case summary, placeholder, hasMore, buttons, elements
        case previewLength = "preview_length"
    }
    
    // MARK: - init
    public override init() {
        super.init()
    }
    
    required public init(from decoder: Decoder) throws {
        let dataContainer = try decoder.container(keyedBy: CodingKeys.self)
        placeholder = try? dataContainer.decode(String.self, forKey: .placeholder)
        previewLength = try? dataContainer.decode(Int64.self, forKey: .previewLength)
        hasMore = try? dataContainer.decode(Bool.self, forKey: .hasMore)
        
        elements = try? dataContainer.decode([KRETaskListItem].self, forKey: .elements)
        buttons = try? dataContainer.decode([KREButtonTemplate].self, forKey: .buttons)
        
        if let summaryContainer = try? dataContainer.nestedContainer(keyedBy: SummaryKeys.self, forKey: .summary) {
            text = try? summaryContainer.decode(String.self, forKey: .text)
            icon = try? summaryContainer.decode(String.self, forKey: .icon)
            iconId = try? summaryContainer.decode(String.self, forKey: .iconId)
        }
        
    }
}
