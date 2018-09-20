//
//  DataStoreManager.swift
//  KoreBotSDKDemo
//
//  Created by developer@kore.com on 21/11/16.
//  Copyright © 2016 Kore Inc. All rights reserved.
//

import UIKit
import CoreData

open class DataStoreManager: NSObject {
    
    // MARK:- datastore manager shared instance
    public var coreDataManager: CoreDataManager! = nil
    static var instance: DataStoreManager!

    // MARK:- datastore manager shared instance
    open static let sharedManager : DataStoreManager = {
        if (instance == nil) {
            instance = DataStoreManager()
        }
        return instance
    }()
    
    // MARK:- init
    override init() {
        super.init()
        coreDataManager = CoreDataManager()
    }
    
    // MARK:- populate core data store
    func populateDataStore() {

    }
    
    // MARK:- contacts
    public func insertOrUpdateContact(dictionary: Dictionary<String, AnyObject>, withContext context: NSManagedObjectContext) -> KREContact {
        
        let newItem = NSEntityDescription.insertNewObject(forEntityName: "KREContact", into: context) as! KREContact
        
        newItem.contactId = dictionary["id"] as! String?
        newItem.firstName = dictionary["firstName"] as! String?
        newItem.lastName = dictionary["lastName"] as! String?
        newItem.identity = dictionary["identity"] as! String?
        
        return newItem
    }
    
    public func getContact(id: NSManagedObjectID, withContext context: NSManagedObjectContext) -> KREContact? {
        return context.object(with: id) as? KREContact
    }
    
    public func deleteContact(id: NSManagedObjectID, withContext context: NSManagedObjectContext) {
        if let threadToDelete = getContact(id: id, withContext: context) {
            context.delete(threadToDelete)
        }
    }
    
    // MARK:- components
    public func insertOrUpdateComponent(dictionary: Dictionary<String, AnyObject>, withContext context: NSManagedObjectContext) -> KREComponent {
        
        let newItem = NSEntityDescription.insertNewObject(forEntityName: "KREComponent", into: context) as! KREComponent
        
        newItem.componentId = dictionary["id"] as! String?
        newItem.componentDesc = dictionary["componentDesc"] as! String?
        
        return newItem
    }
    
    public func getComponent(id: NSManagedObjectID, withContext context: NSManagedObjectContext) -> KREComponent? {
        return context.object(with: id) as? KREComponent
    }

    public func deleteComponent(id: NSManagedObjectID, withContext context: NSManagedObjectContext) {
        if let threadToDelete = getComponent(id: id, withContext: context) {
            context.delete(threadToDelete)
        }
    }
    
    // MARK:- messages
    public func insertOrUpdateMessage(dictionary: Dictionary<String, AnyObject>, withContext context: NSManagedObjectContext) -> KREMessage {
        
        let newMessage = NSEntityDescription.insertNewObject(forEntityName: "KREMessage", into: context) as! KREMessage
        
        newMessage.clientId = dictionary["clientId"] as! String?
        newMessage.messageId = dictionary["id"] as! String?
        newMessage.isSender = dictionary["isSender"] as! Bool
        if ((dictionary["author"]) != nil) {
            let author: KREContact = insertOrUpdateContact(dictionary: dictionary["author"] as! Dictionary<String, AnyObject>, withContext: context)
            newMessage.author = author
        }
        
        if ((dictionary["components"]) != nil) {
            let components: Array<Dictionary<String, AnyObject>> = dictionary["components"] as! Array
            for object in components {
                let component: KREComponent = self.insertOrUpdateComponent(dictionary: object, withContext: context)
                newMessage.addComponentsObject(_value: component)
                component.message = newMessage
            }
        }
        
        if ((dictionary["from"]) != nil) {

        }
        
        return newMessage
    }
    
    public func getMessage(id: NSManagedObjectID, withContext context: NSManagedObjectContext) -> KREMessage? {
        return context.object(with: id) as? KREMessage
    }
    
    public func deleteMessage(id: NSManagedObjectID, withContext context: NSManagedObjectContext) {
        if let messageToDelete = getComponent(id: id, withContext: context) {
            context.delete(messageToDelete)
        }
    }
    
    // MARK:- threads
    public func insertOrUpdateThread(dictionary: [String: Any], with context: NSManagedObjectContext) -> KREThread? {
        guard let taskBotId = dictionary["taskBotId"] as? String, let chatBot = dictionary["chatBot"] as? String else {
            return nil
        }
        var thread: KREThread? = nil
        let request = NSFetchRequest<KREThread>(entityName: "KREThread")
        request.predicate = NSPredicate(format: "threadId == %@", taskBotId)
        if let array = try? context.fetch(request), array.count > 0 {
            thread = array.first
            return thread
        } else {
            thread = NSEntityDescription.insertNewObject(forEntityName: "KREThread", into: context) as? KREThread
            thread?.threadId = taskBotId
            thread?.subject = chatBot
            if let messages = dictionary["messages"] as? Array<[String: Any]> {
                for object in messages {
                    let message: KREMessage = self.insertOrUpdateMessage(dictionary: object as Dictionary<String, AnyObject>, withContext: context)
                    thread?.addToMessages(_value: message)
                    message.thread = thread
                }
            }
        }
        return thread
    }
    
    public func getThread(id: NSManagedObjectID, withContext context: NSManagedObjectContext) -> KREThread? {
        return context.object(with: id) as? KREThread
    }
    
    // method delete or persist conversation history with bot based on 'SDKConfiguration.dataStoreConfig.resetDataStoreOnConnect'.
    public func deleteThreadIfRequired(with threadId: String, resetDatastore reset: Bool, completion block: ((_ staus: Bool) -> Void)?) {
        var success: Bool = false
        if (reset == true) {
            var thread: KREThread! = nil
            let dataStoreManager: DataStoreManager = DataStoreManager.sharedManager
            let context: NSManagedObjectContext = dataStoreManager.coreDataManager.workerContext
            let request = NSFetchRequest<KREThread>(entityName: "KREThread")
            request.predicate = NSPredicate(format: "threadId == %@", threadId)
            let array: Array<KREThread> = try! context.fetch(request)
            if (array.count > 0) {
                thread = array.first
                context.delete(thread)
                do {
                    try context.save()
                    dataStoreManager.coreDataManager.saveChanges()
                    success = true
                } catch {

                }
            }
        } else {
            success = true
        }
        
        block?(success)
    }
    
    public func getLatestMessage(with block: ((_ message: KREMessage?) -> Void)?) {
        let request = NSFetchRequest<KREMessage>(entityName: "KREMessage")
        let sortDates = NSSortDescriptor(key: "sentOn", ascending: false)
        request.sortDescriptors = [sortDates]
        request.fetchLimit = 1
        let context = coreDataManager.workerContext
        var message: KREMessage?
        if let array = try? context.fetch(request), array.count > 0 {
            message = array.first
        }
        block?(message)
    }
    
    // data management
    public func insertMessages(messages: Array<Dictionary<String, AnyObject>>) {
        let context: NSManagedObjectContext = coreDataManager.workerContext
        context.perform {
            
            try? context.save()
        }
    }
    
    public func insertThreads(threads: Array<Dictionary<String, AnyObject>>) {
        let context: NSManagedObjectContext = coreDataManager.workerContext
        context.perform {
            for object in threads {
                if let thread = self.insertOrUpdateThread(dictionary: object, with: context) {
                    print(thread)
                }
            }
            try? context.save()
        }
    }
    
    public func createNewMessageIn(thread: KREThread, message: Message, completion block: ((_ staus: Bool) -> Void)?) {
        let context: NSManagedObjectContext = coreDataManager.workerContext
        context.perform { [unowned self] in
            let nMessage = NSEntityDescription.insertNewObject(forEntityName: "KREMessage", into: context) as! KREMessage
            nMessage.sentOn = message.sentDate as NSDate?
            nMessage.sortDay = self.date(for: message.sentDate, hour: nil, minute: nil, second: nil) as NSDate?
            nMessage.isSender = true
            nMessage.isSender = message.isSender
            nMessage.messageType = NSNumber(value: message.messageType.rawValue)
            nMessage.iconUrl = message.iconUrl
            
            for component in message.components {
                let nComponent = NSEntityDescription.insertNewObject(forEntityName: "KREComponent", into: context) as! KREComponent
                nComponent.componentId = ""
                nComponent.componentDesc = component.payload as String?
                nMessage.addComponentsObject(_value: nComponent)
                nComponent.message = nMessage
                nMessage.templateType = component.componentType.rawValue as NSNumber?
                nMessage.thread = thread
                thread.addToMessages(_value: nMessage)
            }

            try? context.save()
            self.coreDataManager.saveChanges()
            
            block?(true)
        }
    }
    
    // MARK: - date at beginning of day from 
    public func date(for inputDate: Date?, hour hourOffset: Int?, minute minuteOffset: Int?, second secondOffset: Int?, timezone status: Bool = true) -> Date? {
        if inputDate == nil {
            return nil
        }
        
        // use the user's current calendar and time zone
        var calendar = Calendar.current
        
        if status {
            let timeZone = TimeZone(abbreviation: "GMT")
            if let aZone = timeZone {
                calendar.timeZone = aZone
            }
        } else {
            calendar.timeZone = .current
        }
        
        // selectively convert the date components (year, month, day) of the input date
        var dateComponents: DateComponents? = nil
        if let aDate = inputDate {
            dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: aDate)
        }
        
        // set the time components manually
        if let hour = dateComponents?.hour, let hourOffset = hourOffset {
            dateComponents?.hour = hour + hourOffset
        } else {
            dateComponents?.hour = 0
        }
        if let minute = dateComponents?.minute, let minuteOffset = minuteOffset {
            dateComponents?.minute = minute + minuteOffset
        } else {
            dateComponents?.minute = 0
        }
        if let second = dateComponents?.second, let secondOffset = secondOffset {
            dateComponents?.second = second + secondOffset
        } else {
            dateComponents?.second = 0
        }
        
        // convert back
        var beginningOfDay: Date? = nil
        if let aComponents = dateComponents {
            beginningOfDay = calendar.date(from: aComponents)
        }
        return beginningOfDay
    }
}
