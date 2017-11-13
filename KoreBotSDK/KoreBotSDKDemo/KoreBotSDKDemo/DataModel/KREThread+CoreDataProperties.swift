//
//  KREThread+CoreDataProperties.swift
//  KoreBotSDKDemo
//
//  Created by developer@kore.com on 21/11/16.
//  Copyright © 2016 Kore Inc. All rights reserved.
//

import Foundation
import CoreData


extension KREThread {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<KREThread> {
        return NSFetchRequest<KREThread>(entityName: "KREThread");
    }

    @NSManaged public var subject: String?
    @NSManaged public var threadId: String?
    @NSManaged public var messages: NSOrderedSet?

}

// MARK: Generated accessors for messages
extension KREThread {


    @objc(removeObjectFromMessagesAtIndex:)
    @NSManaged public func removeFromMessages(at idx: Int)

    @objc(removeMessagesAtIndexes:)
    @NSManaged public func removeFromMessages(at indexes: NSIndexSet)

    @objc(addMessages:)
    @NSManaged public func addToMessages(_ values: NSOrderedSet)

    @objc(removeMessages:)
    @NSManaged public func removeFromMessages(_ values: NSOrderedSet)

    
}

extension KREThread {
    @objc(addMessagesObject:)
    public func addToMessages(_value: KREMessage){
        self.willChangeValue(forKey: "messages")
        let tempSet = NSMutableOrderedSet(orderedSet: self.messages!)
        tempSet.addObjects(from: [_value as Any])
        self.messages = tempSet
        self.didChangeValue(forKey: "messages")
    }
    
    @objc(insertObject:inMessagesAtIndex:)
    public func insertIntoMessages(_value: KREMessage, at idx: Int){
        self.willChangeValue(forKey: "messages")
        let tempSet = NSMutableOrderedSet(orderedSet: self.messages!)
        tempSet.insert(_value, at: idx)
        self.messages = tempSet
        self.didChangeValue(forKey: "messages")
    }
    
    @objc(insertMessages:atIndexes:)
    public func insertIntoMessages(_values: [KREMessage], at indexes: NSIndexSet){
        self.willChangeValue(forKey: "messages")
        let tempSet = NSMutableOrderedSet(orderedSet: self.messages!)
        tempSet.insert(_values, at: indexes as IndexSet)
        self.messages = tempSet
        self.didChangeValue(forKey: "messages")
    }
    

    @objc(removeMessagesObject:)
    public func removeMessagesObject(_value: KREMessage)  {
        self.willChangeValue(forKey: "messages")
        let tempSet = NSMutableOrderedSet(orderedSet: self.messages!)
        tempSet.remove(tempSet.index(of: _value) )
        self.messages = tempSet
        self.didChangeValue(forKey: "messages")
    }
    
    @objc(replaceMessagesAtIndexes:withMessages:)
    public func replaceMessages(at indexes: NSIndexSet, with values: [KREMessage]){
        self.willChangeValue(forKey: "messages")
        let tempSet = NSMutableOrderedSet(orderedSet: self.messages!)
        tempSet.replaceObjects(at: indexes as IndexSet, with: values)
        self.messages = tempSet
        self.didChangeValue(forKey: "messages")

    }
    
    @objc(replaceObjectInMessagesAtIndex:withObject:)
    public func replaceMessages(at idx: Int, with value: KREMessage){
        self.willChangeValue(forKey: "messages")
        let tempSet = NSMutableOrderedSet(orderedSet: self.messages!)
        tempSet.replaceObject(at: idx, with: value)
        self.messages = tempSet
        self.didChangeValue(forKey: "messages")
    }
}

