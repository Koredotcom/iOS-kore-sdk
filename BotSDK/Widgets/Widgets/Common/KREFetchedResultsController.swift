//
//  KREFetchedResultsController.swift
//  KoreBotSDK
//
//  Created by Srinivas Vasadi on 11/03/19.
//  Copyright © 2019 Srinivas Vasadi. All rights reserved.
//

import UIKit
import CoreData

public protocol KREFetchedResultsControllerDelegate {
    func fetchedControllerWillChangeContent()
    func fetchedControllerDidChangeContent()
}

open class KREFetchedResultsController: NSFetchedResultsController<NSManagedObject>, NSFetchedResultsControllerDelegate {
    // MARK:- properties
    public var name: String?
    public var kreDelegate: KREFetchedResultsControllerDelegate? {
        didSet {
            if (kreDelegate == nil) {
                delegate = nil
            } else {
                delegate = self
            }
        }
    }
    public weak var tableView: UITableView?
    public weak var collectionView: UICollectionView?
    public var ignoreUpdates: Bool = false
    public var shouldReload: Bool = false
    public var animateChanges: Bool = true
    var maybePreMoveUpdateIndexPath: IndexPath? = nil
    var insertedSectionIndexes: IndexSet?
    var deletedSectionIndexes: IndexSet?
    var insertedRowIndexPaths: Array<IndexPath>?
    var deletedRowIndexPaths: Array<IndexPath>?
    var updatedRowIndexPaths: Array<IndexPath>?
    
    // MARK:- init
    override public init(fetchRequest: NSFetchRequest<NSManagedObject>, managedObjectContext context: NSManagedObjectContext, sectionNameKeyPath: String?, cacheName name: String?) {
        super.init(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: sectionNameKeyPath, cacheName: name)
        delegate = self
    }
        
    // MARK:-
    func initSectionsAndRowsCache() {
        insertedSectionIndexes = IndexSet()
        deletedSectionIndexes = IndexSet()
        insertedRowIndexPaths = Array<IndexPath>()
        deletedRowIndexPaths = Array<IndexPath>()
        updatedRowIndexPaths = Array<IndexPath>()
    }
    
    func clearSectionsAndRowsCache() {
        insertedRowIndexPaths = nil
        deletedSectionIndexes = nil
        insertedSectionIndexes = nil
        deletedRowIndexPaths = nil
        updatedRowIndexPaths = nil
    }
    
    // MARK: - Fetched Results Controller Delegate Methods
    public func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        kreDelegate?.fetchedControllerWillChangeContent()
        
        initSectionsAndRowsCache()
    }
    
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if (tableView != nil) {
            if (shouldReload == true) {
                tableView?.reloadData()
            } else {
                tableView?.beginUpdates()
                
                tableView?.deleteSections(deletedSectionIndexes!, with: animateChanges ? .fade : .none)
                tableView?.insertSections(insertedSectionIndexes!, with: animateChanges ? .fade : .none)
                
                tableView?.deleteRows(at: deletedRowIndexPaths!, with: animateChanges ? .fade : .none)
                tableView?.insertRows(at: insertedRowIndexPaths!, with: animateChanges ? .top : .none)
                tableView?.reloadRows(at: updatedRowIndexPaths!, with: animateChanges ? .automatic : .none)
                
                tableView?.endUpdates()
            }
        }
        
        if (collectionView != nil) {
            if (shouldReload == true) {
                collectionView?.reloadData()
            }
        }
        
        kreDelegate?.fetchedControllerDidChangeContent()
        clearSectionsAndRowsCache()
    }
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch (type) {
        case .insert:
            insertedSectionIndexes?.insert(sectionIndex)
            break
        case .delete:
            deletedSectionIndexes?.insert(sectionIndex)
            if let i = deletedRowIndexPaths?.index(where: {$0.section == sectionIndex}) {
                deletedRowIndexPaths?.remove(at: i)
            }
            break
        default:
            break
        }
    }
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch (type) {
        case .insert:
            if (indexPath == nil && newIndexPath != nil) {
                if (insertedSectionIndexes?.contains((newIndexPath?.section)!) == true) {
                    
                } else {
                    insertedRowIndexPaths?.append(newIndexPath!)
                }
            } else {
                shouldReload = true
            }
            break
        case .delete:
            if (indexPath != nil && newIndexPath != nil) {
                if (deletedSectionIndexes?.contains((indexPath?.section)!) == true) {
                    
                } else {
                    deletedRowIndexPaths?.append(indexPath!)
                }
            } else {
                shouldReload = true
            }
            break
        case .update:
            if (indexPath! == maybePreMoveUpdateIndexPath) {
                maybePreMoveUpdateIndexPath = indexPath
            } else {
                shouldReload = true
            }
            break
        case .move:
            if (indexPath != nil && newIndexPath != nil) {
                if (indexPath! == maybePreMoveUpdateIndexPath) {
                    maybePreMoveUpdateIndexPath = nil
                } else {
                    
                }
                deletedRowIndexPaths?.append(indexPath!)
                insertedRowIndexPaths?.append(newIndexPath!)
            } else {
                shouldReload = true
            }
            break
        }
    }
    
    // MARK:- deinit
    deinit {
        clearSectionsAndRowsCache()
        kreDelegate = nil
        tableView = nil
    }
}
