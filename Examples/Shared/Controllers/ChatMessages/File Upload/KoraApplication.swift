//
//  KoraApplication.swift
//  KoraSDK
//
//  Created by Srinivas Vasadi on 07/11/18.
//  Copyright © 2018 Srinivas Vasadi. All rights reserved.
//

import UIKit
import CoreData

open class KoraApplication: NSObject {
    // MARK: -
    var psc: NSPersistentStoreCoordinator?
    var mainContext: NSManagedObjectContext?
    @objc public static var sharedInstance = KoraApplication()
   @objc open var account: KAAccount?
    
    
    // MARK: - Kora User Core Data Stack
    @objc public func initialiseCoreDataStack() -> Bool {
        let bundle = Bundle(for: KoraApplication.self)
        var currentModelName: String?
        let pathToDataModelVersionInfoPlist = bundle.path(forResource: "VersionInfo", ofType: "plist", inDirectory: "KoraDataModel.momd")
        if let path = pathToDataModelVersionInfoPlist, let dataModelVersionInfo = NSDictionary(contentsOfFile: path) {
            currentModelName = dataModelVersionInfo["NSManagedObjectModel_CurrentVersionName"] as? String
        }
        
        var destinationModel: NSManagedObjectModel?
        if let currentModelName = currentModelName, currentModelName.count > 0, let modelPath = bundle.path(forResource: currentModelName, ofType: "mom", inDirectory: "KoraDataModel.momd") {
            let modelUrl = URL(fileURLWithPath: modelPath)
            destinationModel = NSManagedObjectModel(contentsOf: modelUrl)
        } else if let modelUrl = bundle.url(forResource: "KoraDataModel", withExtension: "momd") {
            destinationModel = NSManagedObjectModel(contentsOf: modelUrl)
        }
        
        // create the store for required configuration
        let containerUrl = getContainerURL()
        var koraDirectoryUrl: URL?
        if let directoryUrl = containerUrl?.appendingPathComponent("Kora") {
            do {
                try FileManager.default.createDirectory(atPath: directoryUrl.path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                debugPrint("Kora directory unable to create at source location : \(directoryUrl)")
            }
            koraDirectoryUrl = directoryUrl
            _ = addSkipBackupAttributeToItem(at: directoryUrl)
        }
        
        guard let sourceUrl = koraDirectoryUrl?.appendingPathComponent("KoraUserDB.sqlite") else {
            return false
        }
        
        // check if migration is required for user info store
        let metaData = try? NSPersistentStoreCoordinator.metadataForPersistentStore(ofType: persistentStoreOfType, at: sourceUrl)
        
        if let sourceMetaData = metaData, sourceMetaData.keys.count > 0, let versionHashes = sourceMetaData["NSStoreModelVersionHashes"] as? [String: Any], versionHashes.keys.count > 0 {
            let isCompatible = destinationModel?.isConfiguration(withName: "KoraUser", compatibleWithStoreMetadata: sourceMetaData) ?? false
            debugPrint("Migration of KoraUserDB.sqlite required: %@", isCompatible ? "NO" : "YES")
        }
        
        var wasMigrationSuccessful: Bool = false
        if let persistentStoreCoordinator = persistentStoreCoordinator(with: destinationModel, at: sourceUrl) {
            psc = persistentStoreCoordinator
            _ = addSkipBackupAttributeToItem(at: sourceUrl)
            
            mainContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
            mainContext?.persistentStoreCoordinator = psc
            wasMigrationSuccessful = true
        }
        return wasMigrationSuccessful
    }
    
    public func persistentStoreCoordinator(with destinationModel: NSManagedObjectModel?, at sourceUrl: URL?) -> NSPersistentStoreCoordinator? {
        guard let model = destinationModel else {
            return nil
        }
        
        do {
            let psc = NSPersistentStoreCoordinator(managedObjectModel: model)
            let _ = try psc.addPersistentStore(ofType: persistentStoreOfType, configurationName: "KoraUser", at: sourceUrl, options: persistentStoreOptions)
            return psc
        } catch {
            debugPrint("Error adding store to the coordinator: %@", error)
            let nsError = error as NSError?
            if let code = nsError?.code {
                switch code {
                case NSPersistentStoreIncompatibleSchemaError:
                    if let url = sourceUrl {
                        do {
                            try FileManager.default.removeItem(at: url)
                            debugPrint("removed store coordinator at source location : %@", NSPersistentStoreIncompatibleSchemaError)
                        } catch {
                            
                        }
                    }
                default:
                    break
                }
            }
        }
        return nil
    }
    
    @objc public func isStackInitialised() -> Bool {
        if let _ = psc, let _ = mainContext {
            return true
        }
        return false
    }
    
    @objc public func getContainerURL() -> URL? {
        let containerURL: URL? = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last
        return containerURL
    }
    
    // MARK: -
    public func addSkipBackupAttributeToItem(at url: URL) -> Bool {
        var resourceValues = URLResourceValues()
        resourceValues.isExcludedFromBackup = true
        do {
            var sourceUrl = URL(string: url.absoluteString)
            try sourceUrl?.setResourceValues(resourceValues)
            return true
        } catch {
            debugPrint("Error excluding \(url.lastPathComponent) from backup \(error)")
        }
        return false
    }
    
    // MARK: -
    var requirePersistentStoreEncryption: Bool {
        return false
    }
    
    var persistentStoreOfType: String {
        return NSSQLiteStoreType
    }
    
    var persistentStoreOptions: [String : Any]? {
        return [NSSQLitePragmasOption: ["journal_mode": "WAL"], NSInferMappingModelAutomaticallyOption: true, NSMigratePersistentStoresAutomaticallyOption: true]
    }
    
    @objc public func prepareNewAccount(userInfo: [String : Any]?, auth authInfo: [String : Any]?, completion block: ((Bool, Error?) -> Void)?) {
            account = KAAccount()
       }
}


