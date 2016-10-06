//
//  MessageModel.swift
//  KoreBotSDK
//
//  Created by Srinivas Vasadi on 30/05/16.
//  Copyright © 2016 Kore. All rights reserved.
//

import UIKit
import Mantle

public class MessageModel: MTLModel, MTLJSONSerializing {
    // MARK: properties
    public var type: String?
    public var clientId: String?
    public var component: ComponentModel?
    public var botInfo: AnyObject?
    
    // MARK: MTLJSONSerializing methods
    public static func jsonKeyPathsByPropertyKey() -> [AnyHashable : Any]! {
        return ["type":"type",
                "component":"cInfo"]
    }
    public static func componentJSONTransformer() -> ValueTransformer {
        return ValueTransformer.mtl_JSONDictionaryTransformer(withModelClass: ComponentModel.self)
    }
}

public class BotMessageModel: MTLModel, MTLJSONSerializing {
    // MARK: properties
    public var type: String?
    public var iconUrl: String?
    public var messages: Array<MessageModel> = [MessageModel]()
    public var createdOn: Date?

    // MARK: MTLJSONSerializing methods
    public static func jsonKeyPathsByPropertyKey() -> [AnyHashable : Any]! {
        return ["type":"type",
                "iconUrl":"icon",
                "messages":"message",
                "createdOn":"createdOn"]
    }
    
    public static func messagesJSONTransformer() -> ValueTransformer {
        return ValueTransformer.mtl_JSONArrayTransformer(withModelClass: MessageModel.self)
    }
    
    public static func createdOnJSONTransformer() -> ValueTransformer {
        return MTLValueTransformer.reversibleTransformer(forwardBlock: { (dateString) in
            return self.dateFormatter().date(from: dateString as! String)
            }, reverse: { (date) in
                return nil
        })
    }
    
    public static func dateFormatter() -> DateFormatter {
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale.system
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return dateFormatter
    }
}

public class Ack: MTLModel, MTLJSONSerializing {
    // MARK: properties
    public var status: Bool = false
    public var clientId: String?
    
    // MARK: MTLJSONSerializing methods
    public static func jsonKeyPathsByPropertyKey() -> [AnyHashable : Any]! {
        return ["status":"ok",
                "clientId":"replyto"]
    }
}
