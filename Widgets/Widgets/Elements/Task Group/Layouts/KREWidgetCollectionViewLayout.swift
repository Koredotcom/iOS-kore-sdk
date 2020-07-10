//
//  KREWidgetCollectionViewLayout.swift
//  KoreBotSDK
//
//  Created by Srinivas Vasadi on 27/04/2020.
//  Copyright © 2019 Srinivas Vasadi. All rights reserved.
//

import UIKit

protocol KREWidgetCollectionViewLayoutDelegate: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, numberOfColumnsInSection section: Int) -> Int
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, estimatedHeightForItemAt indexPath: IndexPath) -> CGFloat
}

public class KREWidgetCollectionViewLayout: UICollectionViewLayout {
    // MARK: - properties
    var columnHeights = [[CGFloat]]()
    var headerAttributes = [UICollectionViewLayoutAttributes]()
    var footerAttributes = [UICollectionViewLayoutAttributes]()
    var preferredItemAttributes = [IndexPath: UICollectionViewLayoutAttributes]()
    var allItemAttributes = [IndexPath: UICollectionViewLayoutAttributes]()
    
    weak var delegate: KREWidgetCollectionViewLayoutDelegate?
    
    // MARK: - init
    override init() {
        super.init()
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    // MARK: -
    func commonInit() {
        sectionInset = UIEdgeInsets.zero
        numberOfColumns = 2
        minimumInteritemSpacing = 8.0
        minimumLineSpacing = 8.0
        headerReferenceSize = CGSize.zero
        footerReferenceSize = CGSize.zero
        estimatedItemHeight = 100.0
    }
    
    // MARK: -
    var numberOfSections: Int {
        guard let collectionView = collectionView else {
            return 0
        }
        return collectionView.dataSource?.numberOfSections?(in: collectionView) ?? 0
    }
    
    var sectionInset: UIEdgeInsets = .zero {
        didSet {
            invalidateLayout()
        }
    }
    
    func sectionInsets(inSection section: Int) -> UIEdgeInsets {
        guard let delegate = delegate, let collectionView = collectionView else {
            return sectionInset
        }
        return delegate.collectionView(collectionView, layout: self, insetForSectionAt: section)
    }
    
    var numberOfColumns: Int = 1 {
        didSet {
            invalidateLayout()
        }
    }
    
    func numberOfColumns(inSection section: Int) -> Int {
        guard let delegate = delegate, let collectionView = collectionView else {
            return numberOfColumns
        }
        
        return delegate.collectionView(collectionView, layout: self, numberOfColumnsInSection: section)
    }
    
    var minimumInteritemSpacing: CGFloat = 0.0 {
        didSet {
            invalidateLayout()
        }
    }
    
    func minimumInteritemSpacing(inSection section: Int) -> CGFloat {
        guard let delegate = delegate, let collectionView = collectionView else {
            return minimumInteritemSpacing
        }
        
        return delegate.collectionView(collectionView, layout: self, minimumInteritemSpacingForSectionAt: section)
        
    }
    
    var minimumLineSpacing: CGFloat = 0.0 {
        didSet {
            invalidateLayout()
        }
    }
    
    func minimumLineSpacing(inSection section: Int) -> CGFloat {
        guard let delegate = delegate, let collectionView = collectionView else {
            return minimumLineSpacing
        }
        
        return delegate.collectionView(collectionView, layout: self, minimumLineSpacingForSectionAt: section)
    }

    var headerReferenceSize: CGSize = .zero {
        didSet {
            invalidateLayout()
        }
    }
    
    func headerReferenceSize(inSection section: Int) -> CGSize {
        guard let delegate = delegate, let collectionView = collectionView else {
            return headerReferenceSize
        }
        
        return delegate.collectionView(collectionView, layout: self, referenceSizeForHeaderInSection: section)
    }
    
    var footerReferenceSize: CGSize = .zero {
        didSet {
            invalidateLayout()
        }
    }
    
    func footerReferenceSize(inSection section: Int) -> CGSize {
        guard let delegate = delegate, let collectionView = collectionView else {
            return headerReferenceSize
        }
        
        return delegate.collectionView(collectionView, layout: self, referenceSizeForFooterInSection: section)
    }
    
    var estimatedItemHeight: CGFloat = 0.0 {
        didSet {
            invalidateLayout()
        }
    }
    
    func estimatedItemHeightForItem(at indexPath: IndexPath?) -> CGFloat {
        guard let delegate = delegate,
            let collectionView = collectionView,
            let indexPath = indexPath else {
                return estimatedItemHeight
        }
        
        return delegate.collectionView(collectionView, layout: self, estimatedHeightForItemAt: indexPath)
    }
    
    //  MARK: -
    override public func prepare() {
        super.prepare()
        resetColumnHeights()
        
        for section in 0..<numberOfSections {
            prepareSection(section)
        }
    }
    
    func resetColumnHeights() {
        allItemAttributes.removeAll()
        columnHeights.removeAll()
        headerAttributes.removeAll()
        footerAttributes.removeAll()
        
        for section in 0..<numberOfSections {
            let numberOfColumns = self.numberOfColumns(inSection: section)
            var sectionColumnHeights = [CGFloat](repeating: 0, count: numberOfColumns)

            columnHeights.append(sectionColumnHeights)
        }
    }
    
    func prepareSection(_ section: Int) {
        guard let collectionView = collectionView else {
            return
        }
        
        let numberOfColumns = self.numberOfColumns(inSection: section)
        var reverseTetrisPoint = allSectionHeights().reduce(0, +)
        
        let topInset = sectionInsets(inSection: section).top
        for column in 0..<numberOfColumns {
            appendHeight(topInset, toColumn: column, inSection: section)
        }
        
        let headerSize = headerReferenceSize(inSection: section)
        if headerSize.height > 0 {
            let headerAttributes = UICollectionViewLayoutAttributes(
                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                with: IndexPath(item: 0, section: section))
            headerAttributes.frame = CGRect(x: 0, y: reverseTetrisPoint, width: headerSize.width, height: headerSize.height)
            for column in 0..<numberOfColumns {
                appendHeight(headerSize.height, toColumn: column, inSection: section)
            }
            self.headerAttributes[section] = headerAttributes
        }
        
        let leftInset = sectionInsets(inSection: section).left
        let rightInset = sectionInsets(inSection: section).right
        let cellContentAreaWidth = collectionView.frame.width - (leftInset + rightInset)
        let numberOfGutters = CGFloat(numberOfColumns - 1)
        let singleGutterWidth = minimumInteritemSpacing(inSection: section)
        let totalGutterWidth = singleGutterWidth * numberOfGutters
        let minimumLineSpacing = self.minimumLineSpacing(inSection: section)
        let itemCount = collectionView.numberOfItems(inSection: section)
        let itemWidth = CGFloat(floorf(Float((cellContentAreaWidth - totalGutterWidth) / CGFloat(numberOfColumns))))
        
        for item in 0..<itemCount {
            let indexPath = IndexPath(item: item, section: section)
            let shortestColumnIndex = shortestColumn(inSection: section)
            let xOffset = (leftInset + ((itemWidth + singleGutterWidth) * CGFloat(shortestColumnIndex)))
            let yOffset = reverseTetrisPoint + shortestColumnHeight(inSection: section)
            
            var itemHeight = estimatedItemHeightForItem(at: indexPath)
            
            if preferredItemAttributes[indexPath] != nil {
                let preferredAttributes = preferredItemAttributes[indexPath] as? UICollectionViewLayoutAttributes
                itemHeight = preferredAttributes?.size.height ?? 0.0
            }
            
            let cellAttributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            cellAttributes.frame = CGRect(x: xOffset, y: yOffset, width: itemWidth, height: itemHeight)
            
            appendHeight((cellAttributes.frame.height + minimumLineSpacing), toColumn: shortestColumnIndex, inSection: section)
            allItemAttributes[indexPath] = cellAttributes
        }
        
        let bottomInset = sectionInsets(inSection: section).bottom
        for column in 0..<numberOfColumns {
            appendHeight(bottomInset, toColumn: column, inSection: section)
        }
        
        reverseTetrisPoint = allSectionHeights().reduce(0, +)
        
        let footerSize = footerReferenceSize(inSection: section)
        if footerSize.height > 0 {
            let footerAttributes = UICollectionViewLayoutAttributes(
                forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                with: IndexPath(item: 0, section: section))
            footerAttributes.frame = CGRect(x: 0, y: reverseTetrisPoint, width: footerSize.width, height: footerSize.height)
            
            for column in 0..<numberOfColumns {
                appendHeight(footerSize.height, toColumn: column, inSection: section)
            }
            self.footerAttributes[section] = footerAttributes
        }
    }
    
    override public func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var layoutAttributesForElementsInRect: [UICollectionViewLayoutAttributes] = []
        allItemAttributes.values.forEach { (layoutAttributes) in
            if rect.intersects(layoutAttributes.frame) {
                layoutAttributesForElementsInRect.append(layoutAttributes)
            }
        }
        
        headerAttributes.forEach { (layoutAttributes) in
            if rect.intersects(layoutAttributes.frame) {
                layoutAttributesForElementsInRect.append(layoutAttributes)
            }
        }
        
        footerAttributes.forEach { (layoutAttributes) in
            if rect.intersects(layoutAttributes.frame) {
                layoutAttributesForElementsInRect.append(layoutAttributes)
            }
        }
        
        return layoutAttributesForElementsInRect
    }
    
    override public func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return allItemAttributes[indexPath] as? UICollectionViewLayoutAttributes
    }
    
    override public func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if (elementKind == UICollectionView.elementKindSectionHeader) {
            return headerAttributes[indexPath.section] as? UICollectionViewLayoutAttributes
        }

        if (elementKind == UICollectionView.elementKindSectionFooter) {
            return footerAttributes[indexPath.section] as? UICollectionViewLayoutAttributes
        }

        return nil
    }

    override public var collectionViewContentSize: CGSize {
        guard let collectionView = collectionView else {
            return CGSize.zero
        }
        
        var contentSize = collectionView.bounds.size
        contentSize.height = allSectionHeights().reduce(0, +)
        return contentSize
    }

    func columnHeights(inSection section: Int) -> [CGFloat] {
        return columnHeights[section]
    }

    func shortestColumnHeight(inSection section: Int) -> CGFloat {
        return columnHeights(inSection: section).min() ?? 0.0
    }

    func shortestColumn(inSection section: Int) -> Int {
        let shortestColumnHeight = self.shortestColumnHeight(inSection: section)
        return columnHeights(inSection: section).firstIndex(of: shortestColumnHeight) ?? NSNotFound
    }
    
    func largestColumnHeight(inSection section: Int) -> CGFloat {
        return columnHeights(inSection: section).max() ?? 0.0
    }

    func largestColumn(inSection section: Int) -> Int {
        let largestColumnHeight = self.largestColumnHeight(inSection: section)
        return columnHeights(inSection: section).firstIndex(of: largestColumnHeight) ?? NSNotFound
    }

    func appendHeight(_ height: CGFloat, toColumn column: Int, inSection section: Int) {
        let existing = columnHeights[section][column]
        let updated = existing + height
        columnHeights[section][column] = updated
    }
    
    func sectionHeight(_ section: Int) -> CGFloat {
        let sectionHeight = largestColumnHeight(inSection: section)
        return sectionHeight
    }

    func allSectionHeights() -> [CGFloat] {
        var sectionHeights = [CGFloat](repeating: 0, count: numberOfSections)
        for section in 0..<numberOfSections {
            let section1 = sectionHeight(section)
            sectionHeights.append(section1)
        }
        return sectionHeights
    }

    override public func shouldInvalidateLayout(forPreferredLayoutAttributes preferredAttributes: UICollectionViewLayoutAttributes, withOriginalAttributes originalAttributes: UICollectionViewLayoutAttributes) -> Bool {
        if preferredAttributes.representedElementCategory == .cell {
            preferredItemAttributes[preferredAttributes.indexPath] = preferredAttributes
        }

        return true
    }

    override public func invalidationContext(forPreferredLayoutAttributes preferredAttributes: UICollectionViewLayoutAttributes, withOriginalAttributes originalAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutInvalidationContext {
        let context = super.invalidationContext(forPreferredLayoutAttributes: preferredAttributes,
            withOriginalAttributes: originalAttributes)
        context.invalidateEverything
        return context
    }


    // MARK: - invalidation
    override public func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        guard let collectionView = collectionView else {
            return false
        }
        
        return !(newBounds.size.equalTo(collectionView.frame.size))
    }
}

