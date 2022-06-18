//
//  MessageModel.swift
//  KoreBotSDK
//
//  Created by developer@kore.com on 30/05/16.
//  Copyright © 2016 Kore Inc. All rights reserved.
//

import UIKit
import ObjectMapper

open class MessageModel: Mappable {
    // MARK: properties
    open var type: String?
    open var clientId: String?
    open var component: ComponentModel?
    open var cInfo: NSDictionary?
    open var botInfo: Any?
    
    // MARK: -
    public init() {
        
    }
    
    public required init?(map: Map) {
        
    }
    
    public func mapping(map: Map) {
        type <- map["type"]
        component <- map["component"]
        cInfo <- map["cInfo"]
    }
}

open class BotMessageModel: Mappable {
    // MARK: properties
    open var type: String?
    open var iconUrl: String?
    open var messages: Array<MessageModel> = [MessageModel]()
    open var createdOn: Date?
    open var messageId: String?
    
    // MARK: -
    public init() {
        
    }
    
    public required init?(map: Map) {
        
    }
    
    public func mapping(map: Map) {
        type <- map["type"]
        iconUrl <- map["icon"]
        messages <- map["message"]
        messageId <- map["messageId"]
        
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        createdOn <- (map["createdOn"], DateFormatterTransform(dateFormatter: dateFormatter))
    }
}

open class Ack: Mappable {
    // MARK: properties
    open var status: Bool = false
    open var clientId: String?
    
    // MARK: -
    public required init?(map: Map) {
        
    }
    
    public func mapping(map: Map) {
        status <- map["ok"]
        clientId <- map["replyto"]
    }
}


// MARK: - BotMessage
open class BotMessages: Mappable {
    open var createdBy: String?
    open var createdOn: Date?
    open var lmodifiedOn: String?
    open var resourceid: String?
    open var tN: String?
    open var type: String?
    open var components: [BotMessageComponents]?
    //    open var channels: String?
    open var botId: String?
    open var messageId: String?
    
    // MARK: -
    public required init?(map: Map) {
        
    }
    
    public func mapping(map: Map) {
        
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        createdBy <- map["createdBy"]
        createdOn <- (map["createdOn"],  DateFormatterTransform(dateFormatter: dateFormatter))
        lmodifiedOn <- map["lmodifiedOn"]
        resourceid <- map["resourceid"]
        tN <- map["tN"]
        type <- map["type"]
        components <- map["components"]
        botId <- map["botId"]
        messageId <- map["_id"]
    }
}

// MARK: - BotMessageComponents
open class BotMessageComponents: Mappable {
    open var data: [String: Any]?
    
    // MARK: -
    public required init?(map: Map) {
        
    }
    
    public func mapping(map: Map) {
        data <- map["data"]
    }
}
