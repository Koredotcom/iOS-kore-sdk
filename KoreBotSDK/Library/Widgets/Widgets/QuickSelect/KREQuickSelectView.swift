//
//  KREQuickSelectView.swift
//  Widgets
//
//  Created by developer@kore.com on 16/11/16.
//  Copyright © 2016 Kore Inc. All rights reserved.
//

import UIKit

public class Word: NSObject {
    static let titleCharLimit: Int = 20
    
    var title: String!
    var payload: String!
    var imageURL: String!
    
    public init(title: String, payload: String, imageURL: String) {
        super.init()
        self.title = truncateString(title, count: Word.titleCharLimit)
        self.payload = payload
        self.imageURL = imageURL
    }
    
    func truncateString(_ string: String, count: Int) -> String{
        var tmpString = string
        if(tmpString.characters.count > count){
            tmpString = tmpString.substring(to: tmpString.index(tmpString.startIndex, offsetBy: count))
        }
        return tmpString
    }
}

public class KREQuickSelectView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    var wordList: [Word]!
    var collectionView: KRECollectionView! = nil
    var flowLayout:UICollectionViewFlowLayout! = nil
    var prototypeCell: KRETokenCollectionViewCell! = nil
    public var sendQuickReplyAction: ((_ text: String?) -> Void)!

    let cellHeight: CGFloat = 40
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
    
    //MARK:- removing refernces to elements
    public func prepareForDeinit(){
        self.collectionView.delegate = nil
        self.collectionView.dataSource = nil
    }
    
    // MARK:- setup collectionView
    func setup() {
        self.backgroundColor = UIColor.clear
        wordList = [Word]()
        prototypeCell = KRETokenCollectionViewCell()
        
        // configure layout
        flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize.zero
        flowLayout.scrollDirection = UICollectionViewScrollDirection.horizontal
        flowLayout.minimumInteritemSpacing = 8.0
        flowLayout.minimumLineSpacing = 1
        flowLayout.sectionInset = UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0)

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
    
    public func setWordsList(words:Array<Word>) {
        self.wordList = words
        self.collectionView.reloadData()
    }
    
    // MARK:- datasource
    @nonobjc public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.wordList.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "KRETokenCollectionViewCell", for: indexPath) as! KRETokenCollectionViewCell
        let word = wordList[(indexPath as NSIndexPath).row]
        cell.labelText = word.title
        cell.imageURL = word.imageURL
        cell.krefocused = false
        cell.layoutIfNeeded()
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell: KRETokenCollectionViewCell = collectionView.cellForItem(at: indexPath) as! KRETokenCollectionViewCell
        if(self.sendQuickReplyAction != nil){
            let word = wordList[(indexPath as NSIndexPath).row]
            self.sendQuickReplyAction(word.payload)
        }
        cell.krefocused = false
    }
    
    // MARK: - UICollectionViewDelegateContactFlowLayout
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let word = wordList[(indexPath as NSIndexPath).row]
        let widthForItem: CGFloat = self.prototypeCell.widthForCell(string: word.title, withImage: (word.imageURL.characters.count != 0), height: cellHeight)
        return CGSize(width: min(self.maxContentWidth(), widthForItem), height: cellHeight)
    }
    
    func maxContentWidth() -> CGFloat {
        let collectionViewLayout: UICollectionViewFlowLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        let sectionInset: UIEdgeInsets = collectionViewLayout.sectionInset
        return self.frame.size.width - sectionInset.left - sectionInset.right;
    }
    
    deinit {
        self.wordList = nil
        self.collectionView = nil
        self.flowLayout = nil
        self.prototypeCell = nil
    }
}
