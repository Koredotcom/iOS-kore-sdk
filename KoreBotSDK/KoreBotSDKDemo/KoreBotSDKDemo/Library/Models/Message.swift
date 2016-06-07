//
//  Message.swift
//  KoreBotSDKDemo
//
//  Created by Srinivas Vasadi on 09/05/16.
//  Copyright © 2016 Kore. All rights reserved.
//

import Foundation

enum MessageType : Int {
    case Default = 1, Reply = 2
}

class Message : NSObject {
    var messageType: MessageType = .Default
    var sender: String!
    var sentDate: NSDate!
    var groupedComponents: NSMutableArray!
    var thread: Thread!
        
    override init() {
        super.init()
        self.groupedComponents = NSMutableArray()
    }
    
    func addComponent(component: Component, inout currentGroup: ComponentGroup!) {
        component.message = self;
        
        switch (component.componentKind) {
        case .Image:
            if (currentGroup != nil && (currentGroup.componentKind() == component.componentKind)) {
                // Add it to the current group
                currentGroup.components.addObject(component)
                component.group = currentGroup
            } else {
                // is it NOT the same
                
                if (currentGroup != nil) {
                    // add the current group if it exists
                    self.groupedComponents.addObject(currentGroup)
                }
                
                // create a new group, remember its kind, and add the component to it
                currentGroup = ComponentGroup()
                currentGroup.components.addObject(component)
                component.group = currentGroup;
            }
            break;
            
        default:
            // did we already have a group? If so then add it
            if (currentGroup != nil) {
                self.groupedComponents.addObject(currentGroup)
                currentGroup = nil;
            }
            
            let group: ComponentGroup = ComponentGroup()
            group.components.addObject(component)
            component.group = group
            
            self.groupedComponents.addObject(group)
            break;
        }
    }
    
    func sameSenderAsMessage(compareMessage: Message) -> Bool {
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