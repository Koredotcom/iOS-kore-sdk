//
//  Message.swift
//  KoreBotSDKDemo
//
//  Created by developer@kore.com on 09/05/16.
//  Copyright © 2016 Kore Inc. All rights reserved.
//

import Foundation

public enum MessageType : Int {
    case `default` = 1, timeline = 2
}

public class Message : NSObject {
    public var messageType: MessageType = .default
    public var sender: String?
    public var iconUrl: String?
    public var sentDate: Date?
    public var components: [Component] = [Component]()
    public var thread: Thread?
    public var isSender: Bool = true
    public var hideComposeBar = false
    
    override public init() {
        super.init()
    }
    
    public func addComponent(_ component: Component) {
        component.message = self
        self.components.append(component)
    }
    
    public func sameSenderAsMessage(_ compareMessage: Message) -> Bool {
        return false
    }
    
    public func senderIdentity() -> Identity {
        return Identity()
    }
    
    public func messageAsString() -> String {
        return ""
    }
    
    public func componentCount() -> Int {
        return 0
    }
}
