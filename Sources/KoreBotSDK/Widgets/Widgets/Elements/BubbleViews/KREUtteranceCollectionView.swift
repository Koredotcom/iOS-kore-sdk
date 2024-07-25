//
//  KREUtteranceCollectionView.swift
//  KoreBotSDK
//
//  Created by Srinivas Vasadi on 12/03/19.
//  Copyright © 2019 Srinivas Vasadi. All rights reserved.
//

import UIKit

public class KREUtteranceCollectionView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    public var utterances: [KREAction]? {
        didSet {
            collectionView.reloadData()
        }
    }
    var collectionView: UICollectionView!
    var widget: KREWidget?
    var prototypeCell = KREUtteranceCollectionViewCell()
    public var actionHandler: ((KREAction) -> Void)?
    var collectionViewHeightConstraint: NSLayoutConstraint!

    private let cellHeight: CGFloat = 44.0
    private let minItemSpacing: CGFloat = 8.0
    private let itemWidth: CGFloat = 1.0
    private let headerHeight: CGFloat = 1.0

    // MARK:- init
    override public init (frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    convenience public init () {
        self.init(frame: .zero)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    //MARK:- removing refernces to elements
    public func prepareForReuse() {
        utterances = nil
    }
    
    // MARK:- setup collectionView
    func setup() {
        backgroundColor = UIColor.clear

        // configure layout
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: 1.0, height: 1.0)
        flowLayout.scrollDirection = UICollectionView.ScrollDirection.horizontal
        flowLayout.minimumInteritemSpacing = 10.0
        flowLayout.sectionInset = UIEdgeInsets(top: 0.0, left: 13.0, bottom: 0.0, right: 0.0)
        flowLayout.minimumLineSpacing = 1
        
        // collectionView initialization
        collectionView = UICollectionView(frame: bounds, collectionViewLayout: flowLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = UIColor.clear
        collectionView.bounces = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        addSubview(collectionView)
        
        collectionView.semanticContentAttribute = .forceLeftToRight
        
        // register
        collectionView.register(KREUtteranceCollectionViewCell.self, forCellWithReuseIdentifier: "KREUtteranceCollectionViewCell")
        
        let views: [String: Any] = ["collectionView": collectionView]
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[collectionView]|", options:[], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[collectionView]|", options:[], metrics: nil, views: views))
        
        collectionViewHeightConstraint = NSLayoutConstraint.init(item: collectionView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: cellHeight)
        collectionViewHeightConstraint.isActive = true
        addConstraint(collectionViewHeightConstraint)
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
    }
    
    // MARK: -
    public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return utterances?.count ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "KREUtteranceCollectionViewCell", for: indexPath)
        if let collectionViewCell = cell as? KREUtteranceCollectionViewCell, let utterance = utterances?[indexPath.row] {
            collectionViewCell.textLabel.text = utterance.title
        }
        cell.layoutIfNeeded()
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? KREUtteranceCollectionViewCell,
            let action = utterances?[indexPath.row] as? KREAction {
             actionHandler?(action)
        }
    }
    
    // MARK: - UICollectionViewDelegateContactFlowLayout
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var width: CGFloat = 0.0
        if let utterance = utterances?[indexPath.row] {
            width = prototypeCell.widthForCell(string: utterance.title, height: cellHeight)
        }
        return CGSize(width: width, height: cellHeight)
    }
    
    // MARK: - deinit
    deinit {

    }
}

// MARK: - KREUtteranceCollectionViewCell
public class KREUtteranceCollectionViewCell: UICollectionViewCell {
    // MARK: -
    var textLabel = UILabel()
    
    // MARK: - init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    // MARK: -
    func setup() {
        backgroundColor = UIColor.paleGrey
        layer.cornerRadius = 8.0

        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.textColor = UIColor.lightRoyalBlue
        textLabel.textAlignment = NSTextAlignment.center
        textLabel.font = UIFont.textFont(ofSize: 15.0, weight: .medium)
        textLabel.clipsToBounds = true
        contentView.addSubview(textLabel)
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[textLabel]-|", options: [], metrics: nil, views: ["textLabel": textLabel]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[textLabel]-|", options: [], metrics: nil, views: ["textLabel": textLabel]))
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
    }
    
    // MARK: -
    func widthForCell(string: String?, height: CGFloat) -> CGFloat {
        textLabel.text = string
        let width = textLabel.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: height)).width
        return width + 16.0
    }
}


// MARK: - KREActionCollectionView
public class KREActionCollectionView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    public var actions: [KREAction]? {
        didSet {
            collectionView.reloadData()
        }
    }
    var widget: KREWidget?
    var collectionView: UICollectionView!
    public var titleLabel: UILabel = {
        let textLabel = UILabel(frame: .zero)
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.textColor = UIColor.lightGreyBlue
        textLabel.font = UIFont.textFont(ofSize: 14.0, weight: .medium)
        textLabel.clipsToBounds = true
        return textLabel
    }()
    var prototypeCell = KREUtteranceCollectionViewCell()
    var utteranceClickAction: ((KREAction?) -> Void)?
    var collectionViewHeightConstraint: NSLayoutConstraint!
    
    let cellHeight: CGFloat = 36.0
    
    // MARK:- init
    override public init (frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    convenience public init () {
        self.init(frame: .zero)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    //MARK:- removing refernces to elements
    public func prepareForReuse() {
        titleLabel.text = nil
        actions = nil
    }
    
    // MARK:- setup collectionView
    func setup() {
        backgroundColor = UIColor.clear
        addSubview(titleLabel)
        
        // configure layout
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = UICollectionView.ScrollDirection.horizontal
        flowLayout.minimumInteritemSpacing = 10.0
        flowLayout.minimumLineSpacing = 1
        
        // collectionView initialization
        collectionView = UICollectionView(frame: bounds, collectionViewLayout: flowLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = UIColor.clear
        collectionView.bounces = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        addSubview(collectionView)
        
        collectionView.semanticContentAttribute = .unspecified
        
        // register
        collectionView.register(KREUtteranceCollectionViewCell.self, forCellWithReuseIdentifier: "KREUtteranceCollectionViewCell")
        
        let views: [String: Any] = ["collectionView": collectionView, "titleLabel": titleLabel]
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-5-[collectionView]-5-|", options:[], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[titleLabel]|", options:[], metrics: nil, views: views))
        let yConstraint = NSLayoutConstraint(item: collectionView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0.0)
        addConstraint(yConstraint)
        collectionView.semanticContentAttribute = .forceRightToLeft

        collectionViewHeightConstraint = NSLayoutConstraint.init(item: collectionView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: cellHeight)
        collectionViewHeightConstraint.isActive = true
        addConstraint(collectionViewHeightConstraint)
    }
    
    
    override public func layoutSubviews() {
        super.layoutSubviews()
    }
    
    // MARK: -
    public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return actions?.count ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "KREUtteranceCollectionViewCell", for: indexPath)
        if let collectionViewCell = cell as? KREUtteranceCollectionViewCell, let action = actions?[indexPath.row] {
            collectionViewCell.textLabel.text = action.title
            collectionViewCell.textLabel.textColor = .white
            if let themeColor = widget?.themeColor {
                collectionViewCell.contentView.backgroundColor = UIColor(hexString: themeColor)
            } else {
                collectionViewCell.contentView.backgroundColor = UIColor.lightRoyalBlue
            }
            collectionViewCell.contentView.layer.shadowColor = UIColor.gunmetal.cgColor
            collectionViewCell.contentView.layer.borderColor = UIColor.veryLightBlue.cgColor
            collectionViewCell.contentView.layer.cornerRadius = 4.0
            collectionViewCell.contentView.layer.shadowRadius = 7.0
            collectionViewCell.contentView.layer.masksToBounds = false
            collectionViewCell.contentView.layer.borderWidth = 0.5
            collectionViewCell.contentView.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
            collectionViewCell.contentView.layer.shadowOpacity = 0.1
        }
        cell.layoutIfNeeded()
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? KREUtteranceCollectionViewCell, let action = actions?[indexPath.row] {
            utteranceClickAction?(action)
        }
    }
    
    // MARK: - UICollectionViewDelegateContactFlowLayout
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var width: CGFloat = 0.0
        if let utterance = actions?[indexPath.row].title {
            width = prototypeCell.widthForCell(string: utterance, height: cellHeight)
        }
        return CGSize(width: width, height: cellHeight)
    }
    
    // MARK: - deinit
    deinit {
        actions = nil
    }
}
