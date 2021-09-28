//
//  CustomCollectionViewLayout.swift
//  CustomCollectionLayout
//
//  Created by JOSE MARTINEZ on 15/12/2014.
//  Copyright (c) 2014 brightec. All rights reserved.
//

import UIKit

class CustomCollectionViewLayout: UICollectionViewLayout {
    var shouldPinFirstRow = false
    var itemAttributes = [[UICollectionViewLayoutAttributes]]()
    var contentSize: CGSize = .zero

    override func prepare() {
        guard let collectionView = collectionView else {
            return
        }
        if collectionView.numberOfSections == 0 {
            return
        }
    
        if itemAttributes.count != collectionView.numberOfSections {
            generateItemAttributes(collectionView: collectionView)
            return
        }
        
        if shouldPinFirstRow {
            for section in 0..<collectionView.numberOfSections {
                for item in 0..<collectionView.numberOfItems(inSection: section) {
                    if section != 0 && item != 0 {
                        continue
                    }
                    
                    let attributes = layoutAttributesForItem(at: IndexPath(item: item, section: section))!
                    if section == 0 {
                        var frame = attributes.frame
                        frame.origin.y = collectionView.contentOffset.y
                        attributes.frame = frame
                    }
                }
            }
        }
    }

    override var collectionViewContentSize: CGSize {
        return contentSize
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return itemAttributes[indexPath.section][indexPath.row]
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var attributes = [UICollectionViewLayoutAttributes]()
        for section in itemAttributes {
            let filteredArray = section.filter { obj -> Bool in
                return rect.intersects(obj.frame)
            }

            attributes.append(contentsOf: filteredArray)
        }

        return attributes
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override func invalidateLayout() {
        super.invalidateLayout()
        itemAttributes = []
    }
}

// MARK: - Helpers
extension CustomCollectionViewLayout {

    func generateItemAttributes(collectionView: UICollectionView) {
        var column = 0
        var xOffset: CGFloat = 0
        var yOffset: CGFloat = 0
        var contentWidth: CGFloat = 0
        let collectionDelegate: UICollectionViewDelegateFlowLayout = collectionView.delegate as! UICollectionViewDelegateFlowLayout
        itemAttributes = []

        for section in 0..<collectionView.numberOfSections {
            var sectionAttributes: [UICollectionViewLayoutAttributes] = []
            let numberOfColumns = collectionView.numberOfItems(inSection: section)
            let sectionInsets = collectionDelegate.collectionView!(collectionView, layout: self, insetForSectionAt: section)
            let interItemSpacing = collectionDelegate.collectionView!(collectionView, layout: self, minimumInteritemSpacingForSectionAt: section)
            
            xOffset += sectionInsets.left
            
            for index in 0..<numberOfColumns {
                let indexPath = IndexPath(item: index, section: section)
                var itemSize = collectionDelegate.collectionView!(collectionView, layout: self, sizeForItemAt: indexPath)
                
                if itemSize.width == -1 {
                    itemSize.width = contentWidth - sectionInsets.left - sectionInsets.right
                }
                
                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                attributes.frame = CGRect(x: xOffset, y: yOffset, width: itemSize.width, height: itemSize.height).integral
                
                if section == 0 {
                    // First cell should be on top
                    attributes.zIndex = 1024
                }
                if shouldPinFirstRow && section == 0 {
                    var frame = attributes.frame
                    frame.origin.y = collectionView.contentOffset.y
                    attributes.frame = frame
                }
                
                sectionAttributes.append(attributes)

                if column == numberOfColumns - 1 {
                    if xOffset > contentWidth {
                        contentWidth = xOffset + itemSize.width + sectionInsets.right
                    }

                    column = 0
                    xOffset = 0
                    yOffset += itemSize.height
                }else{
                    xOffset += itemSize.width + interItemSpacing
                    column += 1
                }
            }

            itemAttributes.append(sectionAttributes)
        }

        if let attributes = itemAttributes.last?.last {
            contentSize = CGSize(width: contentWidth, height: attributes.frame.maxY)
        }
    }
}
