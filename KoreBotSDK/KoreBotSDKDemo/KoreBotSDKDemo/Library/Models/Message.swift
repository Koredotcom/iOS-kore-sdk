//
//  Message.swift
//  KoreBotSDKDemo
//
//  Created by Srinivas Vasadi on 09/05/16.
//  Copyright © 2016 Kore. All rights reserved.
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
    var groupedComponents: NSMutableArray!
    var thread: Thread!
        
    override init() {
        super.init()
        self.groupedComponents = NSMutableArray()
    }
    
    func addComponent(_ component: Component, currentGroup: inout ComponentGroup!) {
        component.message = self;
        
        switch (component.componentKind) {
        case .image:
            if (currentGroup != nil && (currentGroup.componentKind() == component.componentKind)) {
                // Add it to the current group
                currentGroup.components.add(component)
                component.group = currentGroup
            } else {
                // is it NOT the same
                
                if (currentGroup != nil) {
                    // add the current group if it exists
                    self.groupedComponents.add(currentGroup)
                }
                
                // create a new group, remember its kind, and add the component to it
                currentGroup = ComponentGroup()
                currentGroup.components.add(component)
                component.group = currentGroup;
            }
            break;
            
        default:
            // did we already have a group? If so then add it
            if (currentGroup != nil) {
                self.groupedComponents.add(currentGroup)
                currentGroup = nil
            }
            
            let group: ComponentGroup = ComponentGroup()
            group.components.add(component)
            component.group = group
            
            self.groupedComponents.add(group)
            break;
        }
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
