//
//  KREFetchedResultsController.swift
//  KoreBotSDKDemo
//
//  Created by Srinivas Vasadi on 22/11/16.
//  Copyright © 2016 Kore. All rights reserved.
//

import UIKit
import CoreData

protocol KREFetchedResultsControllerDelegate {
    func fetchedControllerWillChangeContent()
    func fetchedControllerDidChangeContent()
}

class KREFetchedResultsController: NSFetchedResultsController<NSManagedObject>, NSFetchedResultsControllerDelegate {
    // MARK:- properties
    var kreDelegate: KREFetchedResultsControllerDelegate? {
        didSet {
            if (kreDelegate == nil) {
                self.delegate = nil
            } else {
                self.delegate = self
            }
        }
    }
    var tableView: UITableView?
    var animateChanges: Bool = true
    var ignoreUpdates: Bool = false
    var shouldReload: Bool = false
    var maybePreMoveUpdateIndexPath: IndexPath? = nil

    var insertedSectionIndexes: NSMutableIndexSet?
    var deletedSectionIndexes: NSMutableIndexSet?
    var insertedRowIndexPaths: Array<IndexPath>?
    var deletedRowIndexPaths: Array<IndexPath>?
    var updatedRowIndexPaths: Array<IndexPath>?

    
    // MARK:- init
    override init(fetchRequest: NSFetchRequest<NSManagedObject>, managedObjectContext context: NSManagedObjectContext, sectionNameKeyPath: String?, cacheName name: String?) {
        super.init(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: sectionNameKeyPath, cacheName: name)
        self.delegate = self
    }
    
    // MARK:- 
    func initSectionsAndRowsCache() {
        insertedSectionIndexes = NSMutableIndexSet()
        deletedSectionIndexes = NSMutableIndexSet()
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
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.kreDelegate?.fetchedControllerWillChangeContent()

        initSectionsAndRowsCache()
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if (self.shouldReload == true) {
            self.tableView?.reloadData()
        } else {
         
            UIView.performWithoutAnimation {
                self.tableView?.reloadData()
                self.tableView?.beginUpdates()
                self.tableView?.endUpdates()
            }
            self.kreDelegate?.fetchedControllerDidChangeContent()
            clearSectionsAndRowsCache()
        }
    }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
            switch (type) {
            case .insert:
                self.insertedSectionIndexes?.add(sectionIndex)
                break
            case .delete:
                self.deletedSectionIndexes?.add(sectionIndex)
                if let i = self.deletedRowIndexPaths?.index(where: {$0.section == sectionIndex}) {
                    self.deletedRowIndexPaths?.remove(at: i)
                }
                break
            default:
                break
            }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch (type) {
        case .insert:
            if (indexPath == nil && newIndexPath != nil) {
                if (self.insertedSectionIndexes?.contains((newIndexPath?.section)!) == true) {
                
                } else {
                    self.insertedRowIndexPaths?.append(newIndexPath!)
                }
            } else {
                self.shouldReload = true
            }
            break
        case .delete:
            if (indexPath != nil && newIndexPath != nil) {
                if (self.deletedSectionIndexes?.contains((indexPath?.section)!) == true) {

                } else {
                    self.deletedRowIndexPaths?.append(indexPath!)
                }
            } else {
                self.shouldReload = true
            }
            break
        case .update:
            if (indexPath! == self.maybePreMoveUpdateIndexPath) {
                self.maybePreMoveUpdateIndexPath = indexPath
            } else {
                self.shouldReload = true
            }
            break
        case .move:
            if (indexPath != nil && newIndexPath != nil) {
                if (indexPath! == self.maybePreMoveUpdateIndexPath) {
                    self.maybePreMoveUpdateIndexPath = nil
                } else {

                }
                self.deletedRowIndexPaths?.append(indexPath!)
                self.insertedRowIndexPaths?.append(newIndexPath!)
            } else {
                self.shouldReload = true
            }
            break
        }
    }
    
    // MARK:- deinit
    deinit {
        clearSectionsAndRowsCache()
    }
}
