//
//  MultiImageBubbleView.swift
//  KoreBotSDKDemo
//
//  Created by developer@kore.com on 09/05/16.
//  Copyright © 2016 Kore Inc. All rights reserved.
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
        
        self.collectionView.register(UINib.init(nibName: "ImageComponentCollectionViewCell", bundle:nil), forCellWithReuseIdentifier: "ImageComponentCollectionViewCell")
        self.viewingIndex = NSNotFound
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.collectionView.frame = self.bounds
    }
    
    
    override var intrinsicContentSize : CGSize {
        return CGSize(width: BubbleViewMaxWidth, height: 200)
    }
    
    func visibleCells() -> NSArray {
        let indexPaths: NSArray = self.collectionView.indexPathsForVisibleItems as NSArray
        let cells: NSMutableArray = NSMutableArray()

        for indexPath in indexPaths {
            cells.add(self.collectionView.cellForItem(at: indexPath as! IndexPath)!)
        }
        cells.sort (comparator: { (object1, object2) -> ComparisonResult in
            let cell1: ImageComponentCollectionViewCell = object1 as! ImageComponentCollectionViewCell
            let cell2: ImageComponentCollectionViewCell = object2 as! ImageComponentCollectionViewCell
            return cell1.index.compare(cell2.index)
        })

        return NSArray(array: cells)
    }
    
    // MARK: UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (self.components.count > MAX_CELLS) {
            return MAX_CELLS
        }
        return self.components.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell: ImageComponentCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageComponentCollectionViewCell", for:indexPath) as! ImageComponentCollectionViewCell
        
        cell.component = self.components.object(at: (indexPath as NSIndexPath).row) as! Component
        //        cell.index = [indexPath.row]
        
        if (((indexPath as NSIndexPath).row == 4) && (self.components.count > MAX_CELLS)) {
            cell.plusCountLabel.isHidden = false
            //            cell.plusCountLabel.text = [NSString stringWithFormat:@"+%lu", (long)self.components.count - MAX_CELLS]
            cell.dimmingView.isHidden = false
        } else {
            cell.plusCountLabel.isHidden = true
            cell.dimmingView.isHidden = true
        }
        
        if (self.viewingIndex == NSNotFound) {
            cell.isViewing = false
        } else {
            //            cell.isViewing = indexPath.row == MIN(_viewingIndex, MAX_CELLS - 1)
        }
        
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if ((self.didSelectComponentAtIndex) != nil) {
            self.didSelectComponentAtIndex((indexPath as NSIndexPath).row)
        }
    }
    
    /// MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numberOfComponents = self.components.count
        
        switch (numberOfComponents) {
        case 1:
            return CGSize(width: collectionView.bounds.size.width, height: collectionView.bounds.size.height)
        case 2:
            return CGSize(width: collectionView.bounds.size.width / 2, height: collectionView.bounds.size.height)
        case 3:
            switch ((indexPath as NSIndexPath).row) {
            case 0:
                return CGSize(width: collectionView.bounds.size.width, height: collectionView.bounds.size.height / 2)
                
            default:
                return CGSize(width: collectionView.bounds.size.width / 2, height: collectionView.bounds.size.height / 2)
            }
        case 4:
            return CGSize(width: collectionView.bounds.size.width / 2, height: collectionView.bounds.size.height / 2)
            
        default:
            switch ((indexPath as NSIndexPath).row) {
            case 0:
                return CGSize(width: collectionView.bounds.size.width / 2.0, height: collectionView.bounds.size.height / 3.0 * 2.0)
            case 1:
                return CGSize(width: collectionView.bounds.size.width / 2.0, height: collectionView.bounds.size.height / 3.0 * 2.0)
            default:
                return CGSize(width: collectionView.bounds.size.width / 3.0 , height: collectionView.bounds.size.height / 3.0)
            }
        }
    }
}
