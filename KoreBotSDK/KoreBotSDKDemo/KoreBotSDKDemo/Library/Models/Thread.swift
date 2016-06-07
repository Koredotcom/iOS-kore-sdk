//
//  Thread.swift
//  KoreBotSDKDemo
//
//  Created by Srinivas Vasadi on 09/05/16.
//  Copyright © 2016 Kore. All rights reserved.
//

import Foundation
enum ThreadKind: Int {
    case Chat = 1, Email = 2, Bot = 3
}

class Thread : NSObject {
    
    var subject: String!
    var bot: String!
    var threadKind: ThreadKind! = .Bot
    var messages: Array<Message>!

    // MARK: init
    override init() {
        super.init()
        self.messages = Array()
    }
    
    func loadThread(messages: NSArray) {
        
    }
    
    func addMessage(message: Message) {
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
                string.appendString(", ")
            }
            
            string.appendString(identity.uniqueNameInList(participants));
        }
        
        return string as String
    }
    
    func botIdentity() -> String {
        return ""
    }
}
