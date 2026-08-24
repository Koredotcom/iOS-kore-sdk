//
//  KAEmailCarouselView.swift
//  Widgets
//
//  Created by developer@kore.com on 24/05/17.
//  Copyright © 2017 Kore Inc. All rights reserved.
//
//

import UIKit

public class KAEmailCarouselView: UICollectionView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    
    static public let cardPadding: CGFloat = 10.0
    static public let cardLimit: Int = 100
    public var maxCardHeight: CGFloat = 0.0
    public var maxCardWidth: CGFloat = 0.0
    public var numberOfItems: Int = 0
    public var pageIndex = 0
    
    public var objects: Array<KAEmailCardInfo> = Array<KAEmailCardInfo>() {
        didSet {
            self.numberOfItems = min(objects.count, KAEmailCarouselView.cardLimit)
            
            var maxHeight: CGFloat = 0.0
            for i in 0..<self.numberOfItems {
                let cardInfo = objects[i]
                let height = getExpectedHeight(for: cardInfo, width: maxCardWidth - KAEmailCarouselView.cardPadding)
                if (height > maxHeight) {
                    maxHeight = height
                }
            }
            self.maxCardHeight = maxHeight
            self.reloadData()
        }
    }
    
    public var buttonAction: ((_ buttonInfo: KAButtonInfo?) -> Void)!
    
    public override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
    }
    
    convenience init () {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = UICollectionView.ScrollDirection.horizontal
        flowLayout.minimumInteritemSpacing = 10.0
        flowLayout.minimumLineSpacing = 10.0
        flowLayout.sectionInset = UIEdgeInsets(top: 0.0, left: 45.0, bottom: 0.0, right: 45.0)
        
        self.init(frame: CGRect.zero, collectionViewLayout: flowLayout)
        self.backgroundColor = UIColor.clear
        self.clipsToBounds = false
        self.bounces = true
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator = false
        self.dataSource = self
        self.delegate = self
        
        self.register(KAEmailCardCollectionViewCell.self, forCellWithReuseIdentifier: KAEmailCardCollectionViewCell.cellReuseIdentifier)
        self.register(KAEmailCardHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "KAEmailCardHeaderView")
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK:- datasource
    public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.numberOfItems
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: KAEmailCardCollectionViewCell.cellReuseIdentifier, for: indexPath) as! KAEmailCardCollectionViewCell
        let object = objects[indexPath.row]
        cell.cardView.emailObject = object
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
        
        cell.cardView.buttonAction =  { [weak self] (payload) in
            if (self?.buttonAction != nil){
                self?.buttonAction(payload)
            }
        }
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let cardCell = cell as! KAEmailCardCollectionViewCell
        cardCell.cardView.updateLayer()
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let emailObject = objects[indexPath.row]
        if (emailObject.buttons.count > 0) {
            let button: KAButtonInfo = emailObject.buttons[0]
            if (self.buttonAction != nil) {
                self.buttonAction(button)
            }
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
        
        // Ensure the scrollview is the one on the collectionView we care are working with
        if (scrollView == self) {
            var newPage = self.pageIndex
            let pageWidth = Float(maxCardWidth + 10.0)
            let targetXContentOffset = Float(targetContentOffset.pointee.x)
            let contentWidth = Float(self.contentSize.width)
                
            if velocity.x == 0 {
                newPage = Int(floor((targetXContentOffset - pageWidth / 2) / pageWidth) + 1.0)
            } else {
                newPage = velocity.x > 0 ? newPage + 1 : newPage - 1
                if newPage < 0 {
                    newPage = 0
                }
                let lastPage = Int(floor(contentWidth / pageWidth) - 1.0)
                if newPage > lastPage {
                    newPage = lastPage
                }
            }
            self.pageIndex = newPage
            let point = CGPoint (x: CGFloat(Float(newPage) * pageWidth), y: targetContentOffset.pointee.y)
            targetContentOffset.pointee = point
        }
    }
    
    // MARK: - expected height of KRECard
    public func getExpectedHeight(for emailObject: KAEmailCardInfo, width: CGFloat) -> CGFloat {
        var height: CGFloat = 0.0
        
        let count: Int = min(emailObject.buttons.count, KAEmailCardView.buttonLimit)
        height += KAEmailCardView.kMaxRowHeight * CGFloat(count)
        
        height += KAEmailCardView.kMaxHeight        
        return height
    }
}
