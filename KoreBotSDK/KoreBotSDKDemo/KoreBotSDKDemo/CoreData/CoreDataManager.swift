//
//  CoreDataManager.swift
//  KoreBotSDKDemo
//
//  Created by developer@kore.com on 18/11/16.
//  Copyright © 2016 Kore Inc. All rights reserved.
//

import UIKit
import CoreData

class CoreDataManager: NSObject {
    // MaRK: - init
    override init() {
        super.init()
        self.initializeCoreDataStack()
    }
    
    // MARK: - initialize core data stack
    private func initializeCoreDataStack() {
        self.saveChanges()
    }
    
    // MARK: - Core Data Stack
    private lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = Bundle.main.url(forResource: "DataModel", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("Bots.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "BOT_SDK_ERROR", code: 9999, userInfo: dict)
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
        }
        
        return coordinator
    }()
    
    // MARK: - context's
    lazy var privateContext: NSManagedObjectContext = {
        let coordinator = self.persistentStoreCoordinator
        var privateContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        privateContext.persistentStoreCoordinator = coordinator
        return privateContext
    }()
    
    lazy var mainContext: NSManagedObjectContext = {
        let coordinator = self.persistentStoreCoordinator
        var mainContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        mainContext.parent = self.privateContext
        return mainContext
    }()
    
    lazy var workerContext: NSManagedObjectContext = {
        let coordinator = self.persistentStoreCoordinator
        var workerContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        workerContext.parent = self.mainContext
        return workerContext
    }()
    
    // MARK: - save changes
    func saveChanges () {
        // save mainContext
        if mainContext.hasChanges {
            do {
                try mainContext.save()
            } catch {
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
        
        // save privateContext
        if privateContext.hasChanges {
            do {
                try privateContext.save()
            } catch {
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // MARK: - helpers
    private lazy var applicationDocumentsDirectory: NSURL = {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1] as NSURL
    }()
    
}
