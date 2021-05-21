//
//  KAEmailCarouselView.swift
//  Widgets
//
//  Created by developer@kore.com on 24/05/17.
//  Copyright © 2017 Kore Inc. All rights reserved.
//
//

import UIKit

public class KADriveFilesCarouselView: UICollectionView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    // MARK: - properties
    public let cardPadding: CGFloat = 10.0
    public let cardLimit: Int = 100
    public var maxCardHeight: CGFloat = 0.0
    public var maxCardWidth: CGFloat = 0.0
    public var numberOfItems: Int = 0
    public var pageIndex = 0
    
    public var objects: Array<KADriveFileInfo> = Array<KADriveFileInfo>() {
        didSet {
            self.numberOfItems = min(objects.count, cardLimit)
            
            var maxHeight: CGFloat = 0.0
            for i in 0..<self.numberOfItems {
                let driveFileInfo = objects[i]
                let height = getExpectedHeight(for: driveFileInfo, width: maxCardWidth - cardPadding)
                if (height > maxHeight) {
                    maxHeight = height
                }
            }
            self.maxCardHeight = maxHeight
            self.reloadData()
        }
    }
    
    public var buttonAction: ((_ buttonInfo: KAButtonInfo?) -> Void)?
    
    // MARK: -
    public override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
    }
    
    convenience init () {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = UICollectionView.ScrollDirection.horizontal
        flowLayout.minimumInteritemSpacing = 10.0
        flowLayout.minimumLineSpacing = 10.0
        flowLayout.sectionInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        
        self.init(frame: CGRect.zero, collectionViewLayout: flowLayout)
        self.backgroundColor = UIColor.clear
        self.clipsToBounds = false
        self.bounces = true
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator = false
        self.dataSource = self
        self.delegate = self
        
        self.register(KADriveFileCollectionViewCell.self, forCellWithReuseIdentifier: KADriveFileCollectionViewCell.cellReuseIdentifier)
        self.register(KADriveFilesHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "KADriveFilesHeaderView")
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK:- datasource
    public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.numberOfItems
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: KADriveFileCollectionViewCell.cellReuseIdentifier, for: indexPath) as? KADriveFileCollectionViewCell else {
            return UICollectionViewCell(frame: .zero)
        }
        
        let object = objects[indexPath.row]
        cell.cardView.driveFileObject = object
        cell.cardView.configure(with: object)
        
        if (indexPath.row == 0) {
            cell.cardView.isFirst = true
        } else {
            cell.cardView.isFirst = false
        }
        
        if (indexPath.row == self.numberOfItems - 1) {
            cell.cardView.isLast = true
        } else {
            cell.cardView.isLast = false
        }
        
        cell.cardView.buttonAction =  { [unowned self] (button) in
            self.buttonAction?(button)
        }
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cardCell = cell as? KADriveFileCollectionViewCell {
            cardCell.cardView.updateLayer()
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let object = objects[indexPath.row]
        if let buttons = object.buttons, buttons.count > 0 {
            let button = buttons.first
            self.buttonAction?(button)
        }
    }
    
    // MARK: - UICollectionViewDelegateContactFlowLayout
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: maxCardWidth, height: maxCardHeight - 1.0)
    }
    
    public func prepareForReuse() {
        self.objects.removeAll()
        self.reloadData()
        self.pageIndex = 0
    }
    
    // MARK:- Scroll view delegate
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {

    }
    
    // MARK: - expected height of KRECard
    public func getExpectedHeight(for driveFileInfo: KADriveFileInfo, width: CGFloat) -> CGFloat {
        var height: CGFloat = 0.0
        
        let fileView = KADriveFileView(frame: .zero)
        height += fileView.getExpectedHeight(for: driveFileInfo, width: width)
        return height
    }
}
