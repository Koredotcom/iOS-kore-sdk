//
//  KREMessage+CoreDataProperties.swift
//  KoreBotSDKDemo
//
//  Created by developer@kore.com on 22/11/16.
//  Copyright © 2016 Kore Inc. All rights reserved.
//

import Foundation
import CoreData
import ObjectiveC


extension KREMessage {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<KREMessage> {
        return NSFetchRequest<KREMessage>(entityName: "KREMessage");
    }

    @NSManaged public var clientId: String?
    @NSManaged public var iconUrl: String?
    @NSManaged public var messageId: String?
    @NSManaged public var messageType: NSNumber?
    @NSManaged public var templateType: NSNumber?
    @NSManaged public var sentOn: NSDate?
    @NSManaged public var isSender: Bool
    @NSManaged public var author: KREContact?
    @NSManaged public var components: NSOrderedSet?
    @NSManaged public var thread: KREThread?
    @NSManaged public var messageIdIndex: NSNumber?

}

// MARK: Generated accessors for components
extension KREMessage {

    @objc(removeObjectFromComponentsAtIndex:)
    @NSManaged public func removeFromComponents(at idx: Int)


    @objc(removeComponentsAtIndexes:)
    @NSManaged public func removeFromComponents(at indexes: NSIndexSet)

    
    @objc(addComponents:)
    @NSManaged public func addToComponents(_ values: NSOrderedSet)

    
    @objc(removeComponents:)
    @NSManaged public func removeFromComponents(_ values: NSOrderedSet)

}

var MessageObjectHandle: UInt8 = 0
var cellHeightObjectHandle: UInt8 = 1

extension KREMessage {
    
    @objc(insertObject:inComponentsAtIndex:)
    public func insertIntoComponents(_value: KREComponent, at idx: Int){
        self.willChangeValue(forKey: "components")
        let tempSet = NSMutableOrderedSet(orderedSet: self.components!)
        tempSet.insert(_value, at: idx)
        self.components = tempSet
        self.didChangeValue(forKey: "components")
    }
    
    @objc(insertComponents:atIndexes:)
    public func insertIntoComponents(_values: [KREComponent], at indexes: NSIndexSet){
        self.willChangeValue(forKey: "components")
        let tempSet = NSMutableOrderedSet(orderedSet: self.components!)
        tempSet.insert(_values, at: indexes as IndexSet)
        self.components = tempSet
        self.didChangeValue(forKey: "components")
    }

    @objc(addComponentsObject:)
    public func addComponentsObject(_value: KREComponent)  {
        self.willChangeValue(forKey: "components")
        let tempSet = NSMutableOrderedSet(orderedSet: self.components!)
        tempSet.addObjects(from: [_value as Any])
        self.components = tempSet
        self.didChangeValue(forKey: "components")
    }
    
    @objc(removeComponentsObject:)
    public func removeComponentsObject(_value: KREComponent)  {
        self.willChangeValue(forKey: "components")
        let tempSet = NSMutableOrderedSet(orderedSet: self.components!)
        tempSet.remove(tempSet.index(of: _value) )
        self.components = tempSet
        self.didChangeValue(forKey: "components")
    }
    
    @objc(replaceObjectInComponentsAtIndex:withObject:)
    public func replaceComponents(at idx: Int, with value: KREComponent){
        self.willChangeValue(forKey: "components")
        let tempSet = NSMutableOrderedSet(orderedSet: self.components!)
        tempSet.replaceObject(at: idx, with: value)
        self.components = tempSet
        self.didChangeValue(forKey: "components")
    }

    @objc(replaceComponentsAtIndexes:withComponents:)
    public func replaceComponents(at indexes: NSIndexSet, with values: [KREComponent]){
        self.willChangeValue(forKey: "components")
        let tempSet = NSMutableOrderedSet(orderedSet: self.components!)
        tempSet.replaceObjects(at: indexes as IndexSet, with: values)
        self.components = tempSet
        self.didChangeValue(forKey: "components")
    }

    
    var showMore: Bool {
        get {
            return objc_getAssociatedObject(self, &MessageObjectHandle) as? Bool ?? false
        }
        
        set {
            objc_setAssociatedObject(self, &MessageObjectHandle, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var cellHeight: CGFloat {
        get {
            return objc_getAssociatedObject(self, &cellHeightObjectHandle) as? CGFloat ?? 0.0
        }
        
        set {
            objc_setAssociatedObject(self, &cellHeightObjectHandle, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

