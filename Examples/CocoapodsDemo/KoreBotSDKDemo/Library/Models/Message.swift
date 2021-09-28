//
//  Message.swift
//  KoreBotSDKDemo
//
//  Created by developer@kore.com on 09/05/16.
//  Copyright © 2016 Kore Inc. All rights reserved.
//

import Foundation

enum MessageType : Int {
    case `default` = 1, reply = 2
}

class Message : NSObject {
    var messageType: MessageType = .default
    var sender: String!
    var iconUrl: String!
    var sentDate: Date!
    var components: NSMutableArray!
    var thread: Thread!
    var messageId: String?
    var messageIdIndex: NSNumber!

    override init() {
        super.init()
        self.components = NSMutableArray()
    }
    
    func addComponent(_ component: Component) {
        component.message = self;
        self.components.add(component)
    }
    
    func sameSenderAsMessage(_ compareMessage: Message) -> Bool {
        return false
    }
    
    func senderIdentity() -> Identity {
        return Identity()
    }
    
    func messageAsString() -> String {
        return ""
    }
    
    func componentCount() -> Int {
        return 0
    }
}
