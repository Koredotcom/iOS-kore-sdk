//
//  OverrideKoreConfigModel.swift
//  KoreBotSDK
//
//  Created by Pagidimarri Kartheek on 08/04/25.
//

import UIKit

public class OverrideKoreConfig: NSObject , Decodable {
    public var emoji_short_cut : Bool?
    public var enable : Bool?
    public var typing_indicator_timeout : Int?
    public var history : OverrideKoreConfigHistory?
    
    enum CodingKeys: String, CodingKey {
        case emoji_short_cut = "emoji_short_cut"
        case enable = "enable"
        case typing_indicator_timeout = "typing_indicator_timeout"
        case history = "history"
    }
    // MARK: - init
    public override init() {
        super.init()
    }
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        emoji_short_cut = try? container.decode(Bool.self, forKey: .emoji_short_cut)
        enable = try? container.decode(Bool.self, forKey: .enable)
        typing_indicator_timeout = try? container.decode(Int.self, forKey: .typing_indicator_timeout)
        history = try? container.decode(OverrideKoreConfigHistory.self, forKey: .history)
    }
    
    public func updateWith(configModel: OverrideKoreConfig) -> OverrideKoreConfig{
        self.emoji_short_cut = (configModel.emoji_short_cut == nil)  ? emoji_short_cut : configModel.emoji_short_cut
        self.enable = (configModel.enable == nil)  ? enable : configModel.enable
        self.typing_indicator_timeout = (configModel.typing_indicator_timeout == nil)  ? typing_indicator_timeout : configModel.typing_indicator_timeout
        self.history = configModel.history != nil ? history?.updateWith(configModel: configModel.history!) : history
        return self
    }

}

public class OverrideKoreConfigHistory: NSObject , Decodable {
    public var paginated_scroll : PaginatedScroll?
    public var enable : Bool?
    public var recent : OverrideKoreConfigRecentHistory?

    
    enum CodingKeys: String, CodingKey {
        case paginated_scroll = "paginated_scroll"
        case enable = "enable"
        case recent = "recent"
    }
    // MARK: - init
    public override init() {
        super.init()
    }
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        paginated_scroll = try? container.decode(PaginatedScroll.self, forKey: .paginated_scroll)
        enable = try? container.decode(Bool.self, forKey: .enable)
        recent = try? container.decode(OverrideKoreConfigRecentHistory.self, forKey: .recent)
    }
    
    public func updateWith(configModel: OverrideKoreConfigHistory) -> OverrideKoreConfigHistory{
        self.paginated_scroll = configModel.paginated_scroll != nil ? paginated_scroll?.updateWith(configModel: configModel.paginated_scroll!) : paginated_scroll
        self.enable = (configModel.enable == nil)  ? enable : configModel.enable
        self.recent = configModel.recent != nil ? recent?.updateWith(configModel: configModel.recent!) : recent
        return self
    }

}

public class PaginatedScroll: NSObject , Decodable {
    public var batch_size : Int?
    public var enable : Bool?
    public var loading_label : String?

    
    enum CodingKeys: String, CodingKey {
        case batch_size = "batch_size"
        case enable = "enable"
        case loading_label = "loading_label"
    }
    // MARK: - init
    public override init() {
        super.init()
    }
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        batch_size = try? container.decode(Int.self, forKey: .batch_size)
        enable = try? container.decode(Bool.self, forKey: .enable)
        loading_label = try? container.decode(String.self, forKey: .loading_label)
    }
    
    public func updateWith(configModel: PaginatedScroll) -> PaginatedScroll{
        self.batch_size = (configModel.batch_size == nil)  ? batch_size : configModel.batch_size
        self.enable = (configModel.enable == nil)  ? enable : configModel.enable
        self.loading_label = (configModel.loading_label == nil || configModel.loading_label == "")  ? loading_label : configModel.loading_label
        return self
    }

}

public class OverrideKoreConfigRecentHistory: NSObject , Decodable {
    public var batch_size : Int?

    enum CodingKeys: String, CodingKey {
        case batch_size = "batch_size"
        
    }
    // MARK: - init
    public override init() {
        super.init()
    }
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        batch_size = try? container.decode(Int.self, forKey: .batch_size)
    }
    
    public func updateWith(configModel: OverrideKoreConfigRecentHistory) -> OverrideKoreConfigRecentHistory{
        self.batch_size = (configModel.batch_size == nil)  ? batch_size : configModel.batch_size
        return self
    }

}
