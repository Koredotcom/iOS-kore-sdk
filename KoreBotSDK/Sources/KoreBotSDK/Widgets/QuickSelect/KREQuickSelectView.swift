//
//  KREQuickSelectView.swift
//  Widgets
//
//  Created by developer@kore.com on 16/11/16.
//  Copyright © 2016 Kore Inc. All rights reserved.
//

import UIKit

public class Word: NSObject {
    static let titleCharLimit: Int = 40
    
    public var title: String?
    public var payload: String?
    public var imageURL: String?
    public var contentType: String?
    
    // MARK: - init
    public override init() {
        super.init()
    }
    
    public init(title: String, payload: String, imageURL: String) {
        super.init()
        self.title = truncateString(title, count: Word.titleCharLimit)
        self.payload = payload
        self.imageURL = imageURL
    }
    
    func truncateString(_ string: String, count: Int) -> String {
        var newString = string
        if newString.count > count {
            newString = newString.substring(to: newString.index(newString.startIndex, offsetBy: count))
        }
        return newString
    }
}

open class KREQuickSelectView: UIView {
    // MARK: - properties
    lazy var collectionView: UICollectionView = {
        let layout = TagFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: bounds, collectionViewLayout: layout)
        //let collectionView = UICollectionView(frame: bounds, collectionViewLayout: flowLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = UIColor.clear
        collectionView.bounces = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.isScrollEnabled = false
        collectionView.dataSource = self
        collectionView.delegate = self
        addSubview(collectionView)
        collectionView.semanticContentAttribute = .forceLeftToRight
        
        layout.minimumInteritemSpacing = 1.0
        layout.minimumLineSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 4.0, left: 10.0, bottom: 4.0, right: 10.0)
        
        return collectionView
    }()
    lazy var flowLayout: UICollectionViewFlowLayout = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: 1.0, height: cellHeight)
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumInteritemSpacing = 13.0
        flowLayout.minimumLineSpacing = 10
        flowLayout.sectionInset = UIEdgeInsets(top: 4.0, left: 10.0, bottom: 8.0, right: 10.0)
        return flowLayout
    }()
    
    public var bgColor = ""
    public var textColor = ""
    public var boarderColor = ""
    public var fontName = ""
    let cellHeight: CGFloat = 36.0
    let contentHeight: CGFloat = 44.0
    let prototypeCell = KRETokenCollectionViewCell()
    
    public var sendQuickReplyAction: ((_ text: String?, _ payload: String?) -> Void)?
    public var words: [Word]? {
        didSet {
            collectionView.performBatchUpdates({
                self.collectionView.reloadSections([0])
            }) { (success) in
                self.collectionView.collectionViewLayout.invalidateLayout()
            }
        }
    }
    
    // MARK: - init
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    convenience public init() {
        self.init(frame: .zero)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - removing refernces to elements
    public func prepareForDeinit() {
        collectionView.delegate = nil
        collectionView.dataSource = nil
    }
    
    public func reset() {
        words = [Word]()
    }
    
    lazy var lineView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = UIColor.paleGrey
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK:- setup collectionView
    func setup() {
        addSubview(lineView)
        backgroundColor = .clear
        collectionView.register(KRETokenCollectionViewCell.self, forCellWithReuseIdentifier: "KRETokenCollectionViewCell")
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        let views = ["collectionView": collectionView, "lineView": lineView]
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[collectionView]|", options: [], metrics: nil, views: views))
       
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[lineView]|", options: [], metrics: nil, views: views))
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[lineView(0.0)][collectionView]|", options: [], metrics: nil, views: views))
    }
    
    func maxContentWidth() -> CGFloat {
        if let collectionViewLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let sectionInset: UIEdgeInsets = collectionViewLayout.sectionInset
            return max(frame.size.width - sectionInset.left - sectionInset.right, 1.0)
        }
        return 1.0
    }
        
    override open var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: contentHeight)
    }
}

// MARK: -
extension KREQuickSelectView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    // MARK:- datasource
    @nonobjc public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return words?.count ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let collectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "KRETokenCollectionViewCell", for: indexPath)
        if let cell = collectionViewCell as? KRETokenCollectionViewCell,
            let word = words?[indexPath.row] {
            cell.labelText = word.title
            cell.imageURL = word.imageURL
            cell.layer.borderColor = UIColor.init(hexString: bgColor).cgColor //boarderColor
            cell.backgroundColor = UIColor.init(hexString: bgColor)
            cell.textColor = textColor
            cell.fontName = fontName
            cell.layer.borderWidth = 1.5
            cell.layer.cornerRadius = 5
            cell.krefocused = false
        }
        collectionViewCell.layoutIfNeeded()
        return collectionViewCell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? KRETokenCollectionViewCell {
            cell.krefocused = false
        }
        if let word = words?[indexPath.row] {
            sendQuickReplyAction?(word.title, word.payload)
        }
    }
    
    // MARK: - UICollectionViewDelegateContactFlowLayout
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var width: CGFloat = 1.0
        if let words = words, words.count > 0  {
            let word = words[indexPath.row]
            width = prototypeCell.widthForCell(string: word.title, withImage: (word.imageURL?.count ?? 0 > 0), height: cellHeight, fontName : fontName) ?? 1.0
        }
        return CGSize(width: min(maxContentWidth(), width), height: cellHeight)
    }
}

// MARK: - NewCollectionViewFlowLayout
extension KREQuickSelectView{
    class Row {
        var attributes = [UICollectionViewLayoutAttributes]()
        var spacing: CGFloat = 0

        init(spacing: CGFloat) {
            self.spacing = spacing
        }

        func add(attribute: UICollectionViewLayoutAttributes) {
            attributes.append(attribute)
        }

        func tagLayout(collectionViewWidth: CGFloat) {
            let padding = 2
            var offset = padding
            for attribute in attributes {
                attribute.frame.origin.x = CGFloat(offset)
                offset += Int(attribute.frame.width + spacing)
            }
        }
    }

    class TagFlowLayout: UICollectionViewFlowLayout {
        override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
            guard let attributes = super.layoutAttributesForElements(in: rect) else {
                return nil
            }

            var rows = [Row]()
            var currentRowY: CGFloat = -1

            for attribute in attributes {
                if currentRowY != attribute.frame.origin.y {
                    currentRowY = attribute.frame.origin.y
                    rows.append(Row(spacing: 10))
                }
                rows.last?.add(attribute: attribute)
            }

            rows.forEach { $0.tagLayout(collectionViewWidth: collectionView?.frame.width ?? 0) }
            return rows.flatMap { $0.attributes }
        }
    }

}
