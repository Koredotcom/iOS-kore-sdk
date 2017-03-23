//
//  KREQuickSelectView.swift
//  Widgets
//
//  Created by developer@kore.com on 16/11/16.
//  Copyright © 2016 Kore Inc. All rights reserved.
//

import UIKit

public class KREQuickSelectView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    var wordList = WordList()
    var collectionView: KRECollectionView! = nil
    var flowLayout:UICollectionViewFlowLayout! = nil
    var prototypeCell: KRETokenCollectionViewCell! = nil
    public var sendQuickReplyAction: ((_ text: String?) -> Void)!

    let cellHeight: CGFloat = 41
    // MARK:- init
    override init (frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    convenience init () {
        self.init(frame:CGRect.zero)
    }
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("This class does not support NSCoding")
    }
    
    // MARK:- setup collectionView
    func setup() {
        
        prototypeCell = KRETokenCollectionViewCell()
        
        // configure layout
        flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize.zero
        flowLayout.scrollDirection = UICollectionViewScrollDirection.horizontal
        flowLayout.minimumInteritemSpacing = 5
        flowLayout.minimumLineSpacing = 1
        flowLayout.sectionInset = UIEdgeInsetsMake(0.0, 10.0, 0.0, 10.0)

        
        // collectionView initialization
        collectionView = KRECollectionView(frame: self.bounds, collectionViewLayout: flowLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = UIColor.clear
        collectionView.bounces = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        self.addSubview(collectionView)
        
        // register
        self.collectionView.register(KRETokenCollectionViewCell.self, forCellWithReuseIdentifier: "KRETokenCollectionViewCell")
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        let views = ["collectionView":collectionView!]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[collectionView]|", options:[], metrics:nil, views:views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[collectionView]|", options:[], metrics:nil, views:views))
    }
    
    public func setWordsList(words:NSArray) {
        self.wordList.words = words as! [String];
        self.collectionView.reloadData()
    }
    
    // MARK:- datasource
    @nonobjc public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.wordList.words.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "KRETokenCollectionViewCell", for: indexPath) as! KRETokenCollectionViewCell
        cell.labelText = wordList.words[(indexPath as NSIndexPath).row]
                cell.krefocused = false

        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell: KRETokenCollectionViewCell = collectionView.cellForItem(at: indexPath) as! KRETokenCollectionViewCell
        if(self.sendQuickReplyAction != nil){
            self.sendQuickReplyAction(cell.labelText)
        }
        cell.krefocused = true
    }
    
    // MARK: - UICollectionViewDelegateContactFlowLayout
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let string: String = wordList.words[(indexPath as NSIndexPath).row]
        let widthForItem: CGFloat = prototypeCell.widthForCell(string: string)
        return CGSize(width: min(self.maxContentWidth(), widthForItem), height: cellHeight);
    }
    

    func maxContentWidth() -> CGFloat {
        let collectionViewLayout: UICollectionViewFlowLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout

        let sectionInset: UIEdgeInsets = collectionViewLayout.sectionInset
        return self.frame.size.width - sectionInset.left - sectionInset.right;
    }
}
