//
//  KRECarouselView.swift
//  Widgets
//
//  Created by developer@kore.com on 24/05/17.
//  Copyright © 2017 Kore Inc. All rights reserved.
//
//

import UIKit

public class KRECarouselView: UICollectionView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    // MARK: - properties
    static public let cardPadding: CGFloat = 10.0
    static public let cardLimit: Int = 100
    public var maxCardHeight: CGFloat = 0.0
    public var maxCardWidth: CGFloat = 0.0
    public var numberOfItems: Int = 0
    public var pageIndex = 0
    
    public var cards: [KRECardInfo] = [KRECardInfo]() {
        didSet {
            self.numberOfItems = min(cards.count, KRECarouselView.cardLimit)
            
            var maxHeight: CGFloat = 0.0
            for i in 0..<self.numberOfItems {
                let cardInfo = cards[i]
                let height = getExpectedHeight(cardInfo: cardInfo, width: maxCardWidth - KRECarouselView.cardPadding)
                if height > maxHeight {
                    maxHeight = height
                }
            }
            self.maxCardHeight = maxHeight
            self.reloadData()
        }
    }
    
    public var optionsAction: ((_ title: String?, _ payload: String?) -> Void)?
    public var linkAction: ((_ text: String?) -> Void)?
    public var userIntent:((_ action: Any?) -> Void)?
    public var userIntentAction: ((_ title: String?, _ customData: [String: Any]?) -> Void)?
    
    // MARK: - init
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
        
        self.register(KRECardCollectionViewCell.self, forCellWithReuseIdentifier: KRECardCollectionViewCell.cellReuseIdentifier)
        self.register(KACardCollectionViewCell.self, forCellWithReuseIdentifier: KACardCollectionViewCell.cellReuseIdentifier)
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: KRECardCollectionViewCell.cellReuseIdentifier, for: indexPath) as! KRECardCollectionViewCell
        let cardInfo = cards[indexPath.row]
        cell.cardView.configureForCardInfo(cardInfo: cardInfo)
        
        if indexPath.row == 0 {
            cell.cardView.isFirst = true
        } else {
            cell.cardView.isFirst = false
        }
        if indexPath.row == self.numberOfItems - 1 {
            cell.cardView.isLast = true
        } else {
            cell.cardView.isLast = false
        }
        cell.cardView.optionsAction = { [weak self] (title, payload) in
            self?.optionsAction?(title, payload)
        }
        cell.cardView.linkAction = {[weak self] (text) in
            self?.linkAction?(text)
        }
        cell.cardView.userIntent = { [weak self] (object) in
            self?.userIntent?(object)
        }
        cell.cardView.userIntentAction = { [weak self] (title, customData) in
            self?.userIntentAction?(title, customData)
        }
        cell.cardView.layoutSubviews()
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let cardCell = cell as! KRECardCollectionViewCell
        cardCell.cardView.updateLayer()
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cardInfo = cards[indexPath.row]
        if (cardInfo.defaultAction != nil){
            let defaultAction = cardInfo.defaultAction
            if defaultAction?.actionType == .webURL {
                self.linkAction?(defaultAction?.payload)
            } else if defaultAction?.actionType == .postback || defaultAction?.actionType == .postback_disp_payload {
                self.optionsAction?(defaultAction?.title, defaultAction?.payload)
            } else if defaultAction?.actionType == .user_intent {
                self.userIntent?(defaultAction)
            }
        }
    }
    
    // MARK: - UICollectionViewDelegateContactFlowLayout
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: maxCardWidth, height: maxCardHeight - 1.0)
    }
    
    public func prepareForReuse() {
        self.cards.removeAll()
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
    public func getExpectedHeight(cardInfo: KRECardInfo, width: CGFloat) -> CGFloat {
        var height: CGFloat = 0.0
        
        // imageView height
        if cardInfo.isImagePresent {
            height += width * 0.5
        }
        
        if let count = cardInfo.options?.count {
            height += KRECardView.kMaxRowHeight * CGFloat(min(count, KRECardView.buttonLimit))
        }
        
        let attrString: NSMutableAttributedString = KRECardView.getAttributedString(cardInfo: cardInfo)
        let limitingSize: CGSize = CGSize(width: width - 20.0, height: CGFloat.greatestFiniteMagnitude)
        let rect: CGRect = attrString.boundingRect(with: limitingSize, options: NSStringDrawingOptions.usesLineFragmentOrigin, context: nil)
        height += rect.size.height + 32.0
        
        return height
    }
}
