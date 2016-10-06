//
//  MessageModel.swift
//  KoreBotSDK
//
//  Created by Srinivas Vasadi on 30/05/16.
//  Copyright © 2016 Kore. All rights reserved.
//

import UIKit
import Mantle

open class MessageModel: MTLModel, MTLJSONSerializing {
    // MARK: properties
    open var type: String?
    open var clientId: String?
    open var component: ComponentModel?
    open var botInfo: AnyObject?
    
    // MARK: MTLJSONSerializing methods
    open static func jsonKeyPathsByPropertyKey() -> [AnyHashable : Any]! {
        return ["type":"type",
                "component":"cInfo"]
    }
    open static func componentJSONTransformer() -> ValueTransformer {
        return ValueTransformer.mtl_JSONDictionaryTransformer(withModelClass: ComponentModel.self)
    }
}

open class BotMessageModel: MTLModel, MTLJSONSerializing {
    // MARK: properties
    open var type: String?
    open var iconUrl: String?
    open var messages: Array<MessageModel> = [MessageModel]()
    open var createdOn: Date?

    // MARK: MTLJSONSerializing methods
    open static func jsonKeyPathsByPropertyKey() -> [AnyHashable : Any]! {
        return ["type":"type",
                "iconUrl":"icon",
                "messages":"message",
                "createdOn":"createdOn"]
    }
    
    open static func messagesJSONTransformer() -> ValueTransformer {
        return ValueTransformer.mtl_JSONArrayTransformer(withModelClass: MessageModel.self)
    }
    
    open static func createdOnJSONTransformer() -> ValueTransformer {
        return MTLValueTransformer.reversibleTransformer(forwardBlock: { (dateString) in
            return self.dateFormatter().date(from: dateString as! String)
            }, reverse: { (date) in
                return nil
        })
    }
    
    open static func dateFormatter() -> DateFormatter {
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return dateFormatter
    }
}

open class Ack: MTLModel, MTLJSONSerializing {
    // MARK: properties
    open var status: Bool = false
    open var clientId: String?
    
    // MARK: MTLJSONSerializing methods
    open static func jsonKeyPathsByPropertyKey() -> [AnyHashable : Any]! {
        return ["status":"ok",
                "clientId":"replyto"]
    }
}
