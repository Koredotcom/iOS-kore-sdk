//
//  Thread.swift
//  KoreBotSDKDemo
//
//  Created by developer@kore.com on 09/05/16.
//  Copyright © 2016 Kore Inc. All rights reserved.
//

import Foundation
enum ThreadKind: Int {
    case chat = 1, email = 2, bot = 3
}

class Thread : NSObject {
    
    var subject: String!
    var bot: String!
    var threadKind: ThreadKind! = .bot
    var messages: Array<Message>!

    // MARK: init
    override init() {
        super.init()
        self.messages = Array()
    }
    
    func loadThread(_ messages: NSArray) {
        
    }
    
    func addMessage(_ message: Message) {
        message.thread = self;
        self.messages.append(message)
    }
    
    func participants() -> NSArray {
        return []
    }
    
    func threadParticipantsString() -> String {
        var participants: Array<Identity> = self.participants() as! Array<Identity>
        let string: NSMutableString = NSMutableString()
        
        if (participants.count == 1) {
            let identity: Identity = participants[0]
            return identity.fullName as String
        }
        
        // Now check for duplicate first name
        for identity in participants {
            if (string.length > 0) {
                string.append(", ")
            }
            
            string.append(identity.uniqueNameInList(participants as NSArray));
        }
        
        return string as String
    }
    
    func botIdentity() -> String {
        return ""
    }
}
