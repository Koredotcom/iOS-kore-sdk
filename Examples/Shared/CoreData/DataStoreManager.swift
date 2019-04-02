//
//  DataStoreManager.swift
//  KoreBotSDKDemo
//
//  Created by developer@kore.com on 21/11/16.
//  Copyright © 2016 Kore Inc. All rights reserved.
//

import UIKit
import CoreData
import KoreBotSDK

class DataStoreManager: NSObject {
    
    // MARK:- datastore manager shared instance
    var coreDataManager: CoreDataManager! = nil
    static var instance: DataStoreManager!
   

    // MARK:- datastore manager shared instance
    public static let sharedManager : DataStoreManager = {
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
    func insertOrUpdateContact(dictionary: Dictionary<String, AnyObject>, withContext context: NSManagedObjectContext) -> KREContact {
        
        let newItem = NSEntityDescription.insertNewObject(forEntityName: "KREContact", into: context) as! KREContact
        
        newItem.contactId = dictionary["id"] as! String?
        newItem.firstName = dictionary["firstName"] as! String?
        newItem.lastName = dictionary["lastName"] as! String?
        newItem.identity = dictionary["identity"] as! String?
        
        return newItem
    }
    
    func getContact(id: NSManagedObjectID, withContext context: NSManagedObjectContext) -> KREContact? {
        return context.object(with: id) as? KREContact
    }
    
    func deleteContact(id: NSManagedObjectID, withContext context: NSManagedObjectContext) {
        if let threadToDelete = getContact(id: id, withContext: context) {
            context.delete(threadToDelete)
        }
    }
    
    // MARK:- components
    func insertOrUpdateComponent(dictionary: Dictionary<String, AnyObject>, withContext context: NSManagedObjectContext) -> KREComponent {
        
        let newItem = NSEntityDescription.insertNewObject(forEntityName: "KREComponent", into: context) as! KREComponent
        
        newItem.componentId = dictionary["id"] as! String?
        newItem.componentDesc = dictionary["componentDesc"] as! String?
        
        return newItem
    }
    
    func getComponent(id: NSManagedObjectID, withContext context: NSManagedObjectContext) -> KREComponent? {
        return context.object(with: id) as? KREComponent
    }

    func deleteComponent(id: NSManagedObjectID, withContext context: NSManagedObjectContext) {
        if let threadToDelete = getComponent(id: id, withContext: context) {
            context.delete(threadToDelete)
        }
    }
    
    // MARK:- messages
    func insertOrUpdateMessage(dictionary: Dictionary<String, AnyObject>, withContext context: NSManagedObjectContext) -> KREMessage {
        
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
    
    func getMessage(id: NSManagedObjectID, withContext context: NSManagedObjectContext) -> KREMessage? {
        return context.object(with: id) as? KREMessage
    }
    
    func deleteMessage(id: NSManagedObjectID, withContext context: NSManagedObjectContext) {
        if let messageToDelete = getComponent(id: id, withContext: context) {
            context.delete(messageToDelete)
        }
    }
    
    // MARK:- threads
    func insertOrUpdateThread(dictionary: Dictionary<String, AnyObject>, withContext context: NSManagedObjectContext) -> KREThread {
        var thread: KREThread! = nil
        let request = NSFetchRequest<KREThread>(entityName: "KREThread")
        request.predicate = NSPredicate(format: "threadId == %@", dictionary["threadId"] as! String)
        let array: Array<KREThread> = try! context.fetch(request)
        if (array.count == 0) {
            thread = NSEntityDescription.insertNewObject(forEntityName: "KREThread", into: context) as? KREThread
            thread.threadId = dictionary["threadId"] as! String?
            thread.subject = dictionary["subject"] as! String?
            if ((dictionary["messages"]) != nil) {
                let messages: Array<Dictionary<String, AnyObject>> = dictionary["messages"] as! Array
                for object in messages {
                    let message: KREMessage = self.insertOrUpdateMessage(dictionary: object, withContext: context)
                    thread.addToMessages(_value: message)
                    message.thread = thread
                }
            }
        } else {
            thread = array.first
        }
        return thread
    }
    public func insertOrUpdateThread(dictionary: [String: Any]?, with block:((_ th: KREThread?) -> Void)?) {
        var thread: KREThread! = nil
        let request: NSFetchRequest<KREThread> = KREThread.fetchRequest()
        let dataStoreManager: DataStoreManager = DataStoreManager.sharedManager
        let context: NSManagedObjectContext = dataStoreManager.coreDataManager.workerContext
        if let threadId = dictionary?["threadId"] as? String {
            request.predicate = NSPredicate(format: "threadId == %@", threadId)
        }
        
        if let array = try? context.fetch(request), array.count > 0 {
            thread = array.first
            block?(thread)
        } else {
           
            thread = NSEntityDescription.insertNewObject(forEntityName: "KREThread", into: context) as? KREThread
            if let threadId = dictionary?["threadId"] {
                thread?.threadId = threadId as? String
            }
            if let subject = dictionary?["subject"] {
                thread?.subject = subject as? String
            }

            if let array = dictionary?["messages"] {
                let messages: Array<Dictionary<String, AnyObject>> = array as! Array
                for object in messages {
                    _ = self.insertOrUpdateMessage(dictionary: object, withContext: context)
                }
            }
            block?(thread)
        }
    }
    
    
    func getThread(id: NSManagedObjectID, withContext context: NSManagedObjectContext) -> KREThread? {
        return context.object(with: id) as? KREThread
    }
    
    // method delete or persist conversation history with bot based on 'SDKConfiguration.dataStoreConfig.resetDataStoreOnConnect'.
    func deleteThreadIfRequired(with threadId: String, completionBlock: ((_ staus: Bool) -> Void)?) {
        var success: Bool = false
        if (SDKConfiguration.dataStoreConfig.resetDataStoreOnConnect == true) {
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
        if (completionBlock != nil) {
            completionBlock!(success)
        }
    }
    
    // data management
    public func insertMessages(_ messages: [Message], in thread: KREThread!, completion block: (() -> Void)?) {
        let context = coreDataManager.workerContext
        context.perform { [weak self] in
            for message in messages {
                self?.createNewMessageIn(thread: thread, message: message, context: context)
            }
            try? context.save()
            self?.coreDataManager.saveChanges()
            block?()
        }
    }
    
    func insertThreads(threads: Array<Dictionary<String, AnyObject>>) {
        let context: NSManagedObjectContext = coreDataManager.workerContext
        context.perform {
            for object in threads {
                _ = self.insertOrUpdateThread(dictionary: object, withContext: context)
            }
            try! context.save()
        }
    }
    
    public func createNewMessageIn(thread: KREThread!, message: Message, context: NSManagedObjectContext) {
        let request: NSFetchRequest<KREMessage> = KREMessage.fetchRequest()
        request.predicate = NSPredicate(format: "messageId == %@", message.messageId ?? "")
        
        var nMessage: KREMessage?
        if let messages = try? context.fetch(request), messages.count > 0 {
            nMessage = messages.first
        } else {
            nMessage = NSEntityDescription.insertNewObject(forEntityName: "KREMessage", into: context) as? KREMessage
        }
        nMessage?.sentOn = message.sentDate as NSDate?
        nMessage?.isSender = true
        nMessage?.messageId = message.messageId
        
        if (message.messageType == .reply) {
            nMessage?.isSender = false
        }
        
        if (message.iconUrl != nil) {
            nMessage?.iconUrl = message.iconUrl
        }
        
        if message.components.count > 0, let nMessage = nMessage {
            let components: NSArray = message.components
            for component in components as! [Component] {
                let nComponent = NSEntityDescription.insertNewObject(forEntityName: "KREComponent", into: context) as! KREComponent
                nComponent.componentId = ""
                nComponent.componentDesc = component.payload as String?
                nMessage.addComponentsObject(_value: nComponent)
                nComponent.message = nMessage
                nMessage.templateType = component.componentType.rawValue as NSNumber?
                nMessage.thread = thread
//                thread.addToMessages(_value: nMessage)
            }
        }
    }

    func createNewMessageIn(thread: KREThread!, message: Message, completion block: ((_ staus: Bool) -> Void)?) {
        let context: NSManagedObjectContext = coreDataManager.workerContext
        context.perform { [weak self] in
            self?.createNewMessageIn(thread: thread, message: message, context: context)
            try? context.save()
            self?.coreDataManager.saveChanges()
            
            block?(true)
        }
    }
    
    // MARK: get messages count
    func getMessagesCount(completion block: ((_ count: Int) -> Void)?) {
        let context = coreDataManager.workerContext
        context.perform {
            let request: NSFetchRequest<KREMessage> = KREMessage.fetchRequest()
            var messagesCount = 0
            if let count = try? context.count(for: request) {
                messagesCount = count
            }
            DispatchQueue.main.async {
                block?(messagesCount)
            }
        }
    }
}
