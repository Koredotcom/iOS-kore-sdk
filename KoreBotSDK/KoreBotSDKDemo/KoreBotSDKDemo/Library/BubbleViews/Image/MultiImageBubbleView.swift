//
//  MultiImageBubbleView.swift
//  KoreBotSDKDemo
//
//  Created by Srinivas Vasadi on 09/05/16.
//  Copyright © 2016 Kore. All rights reserved.
//

import UIKit

class MultiImageBubbleView : BubbleView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    var initialViewingIndex: Int!
    var viewingIndex: Int! {
        didSet(newViewingIndex) {
            if (self.viewingIndex != newViewingIndex) {
                self.collectionView.reloadData()
            }
        }
    }
    override var components:NSArray! {
        didSet {
            self.collectionView.reloadData()
        }
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    var COMPONENT_PADDING: CGFloat = 0.0
    var INNER_PADDING: CGFloat = 10.0
    var IMAGE_COMPONENT_HEIGHT: CGFloat = 80.0
    var MAX_CELLS: Int = 5
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.collectionView.registerNib(UINib.init(nibName: "ImageComponentCollectionViewCell", bundle:nil), forCellWithReuseIdentifier: "ImageComponentCollectionViewCell")
        self.viewingIndex = NSNotFound
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.collectionView.frame = self.bounds
    }
    
    
    override func intrinsicContentSize() -> CGSize {
        return CGSizeMake(BubbleViewMaxWidth, 200)
    }
    
    func visibleCells() -> NSArray {
        let indexPaths: NSArray = self.collectionView.indexPathsForVisibleItems()
        let cells: NSMutableArray = NSMutableArray()

        for indexPath in indexPaths {
            cells.addObject(self.collectionView.cellForItemAtIndexPath(indexPath as! NSIndexPath)!)
        }
        cells.sortUsingComparator { (object1, object2) -> NSComparisonResult in
            let cell1: ImageComponentCollectionViewCell = object1 as! ImageComponentCollectionViewCell
            let cell2: ImageComponentCollectionViewCell = object2 as! ImageComponentCollectionViewCell
            return cell1.index.compare(cell2.index)
        }

        return NSArray(array: cells)
    }
    
    // MARK: UICollectionViewDataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (self.components.count > MAX_CELLS) {
            return MAX_CELLS
        }
        return self.components.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell: ImageComponentCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("ImageComponentCollectionViewCell", forIndexPath:indexPath) as! ImageComponentCollectionViewCell
        
        cell.component = self.components[indexPath.row] as! ImageComponent
        //        cell.index = [indexPath.row]
        
        if ((indexPath.row == 4) && (self.components.count > MAX_CELLS)) {
            cell.plusCountLabel.hidden = false
            //            cell.plusCountLabel.text = [NSString stringWithFormat:@"+%lu", (long)self.components.count - MAX_CELLS]
            cell.dimmingView.hidden = false
        } else {
            cell.plusCountLabel.hidden = true
            cell.dimmingView.hidden = true
        }
        
        if (self.viewingIndex == NSNotFound) {
            cell.isViewing = false
        } else {
            //            cell.isViewing = indexPath.row == MIN(_viewingIndex, MAX_CELLS - 1)
        }
        
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        if ((self.didSelectComponentAtIndex) != nil) {
            self.didSelectComponentAtIndex(index: indexPath.row)
        }
    }
    
    /// MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsZero
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let numberOfComponents = self.components.count
        
        switch (numberOfComponents) {
        case 1:
            return CGSizeMake(collectionView.bounds.size.width, collectionView.bounds.size.height)
        case 2:
            return CGSizeMake(collectionView.bounds.size.width / 2, collectionView.bounds.size.height)
        case 3:
            switch (indexPath.row) {
            case 0:
                return CGSizeMake(collectionView.bounds.size.width, collectionView.bounds.size.height / 2)
                
            default:
                return CGSizeMake(collectionView.bounds.size.width / 2, collectionView.bounds.size.height / 2)
            }
        case 4:
            return CGSizeMake(collectionView.bounds.size.width / 2, collectionView.bounds.size.height / 2)
            
        default:
            switch (indexPath.row) {
            case 0:
                return CGSizeMake(collectionView.bounds.size.width / 2.0, collectionView.bounds.size.height / 3.0 * 2.0)
            case 1:
                return CGSizeMake(collectionView.bounds.size.width / 2.0, collectionView.bounds.size.height / 3.0 * 2.0)
            default:
                return CGSizeMake(collectionView.bounds.size.width / 3.0 , collectionView.bounds.size.height / 3.0)
            }
        }
    }
}