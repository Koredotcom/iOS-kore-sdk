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
    public static func JSONKeyPathsByPropertyKey() -> [NSObject : AnyObject]! {
        return ["type":"type",
                "component":"cInfo"]
    }
    public static func componentJSONTransformer() -> NSValueTransformer {
        return NSValueTransformer.mtl_JSONDictionaryTransformerWithModelClass(ComponentModel)
    }
}

public class BotMessageModel: MTLModel, MTLJSONSerializing {
    // MARK: properties
    public var type: String?
    public var messages: Array<MessageModel> = [MessageModel]()
    
    // MARK: MTLJSONSerializing methods
    public static func JSONKeyPathsByPropertyKey() -> [NSObject : AnyObject]! {
        return ["type":"type",
                "messages":"message"]
    }
    
    public static func messagesJSONTransformer() -> NSValueTransformer {
        return NSValueTransformer.mtl_JSONArrayTransformerWithModelClass(MessageModel)
    }
}

public class Ack: MTLModel, MTLJSONSerializing {
    // MARK: properties
    public var status: Bool = false
    public var clientId: String?
    
    // MARK: MTLJSONSerializing methods
    public static func JSONKeyPathsByPropertyKey() -> [NSObject : AnyObject]! {
        return ["status":"ok",
                "clientId":"replyto"]
    }
}