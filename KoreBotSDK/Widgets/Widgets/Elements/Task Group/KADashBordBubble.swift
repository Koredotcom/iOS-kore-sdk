//
//  KADashBordBubble.swift
//  KoreBotSDK
//
//  Created by Sukhmeet Singh on 20/11/19.
//

import UIKit

open class KADashBordBubble: UIView {
    var collectionViewHeightConstraint: NSLayoutConstraint!
    var collectionViewIdentifier = "KREPanelDashBoardCollectionViewCell"
   open lazy var bottomSheetCollectionView: UICollectionView = {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 10.0
        layout.minimumLineSpacing = 1.0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()

    public var bottomSheetData: [Any]? {
        didSet {
            self.bottomSheetCollectionView.reloadData()
        }
    }

    public init() {
        super.init(frame: CGRect.zero)
        initialize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    // MARK: - initialize
    public func initialize() {
        addSubview(bottomSheetCollectionView)
        bottomSheetCollectionView.backgroundColor = .white
        bottomSheetCollectionView.delegate = self
        bottomSheetCollectionView.dataSource = self
        bottomSheetCollectionView.register(KREPanelDashBoardCollectionViewCell.self, forCellWithReuseIdentifier: collectionViewIdentifier)
        let views = ["bottomSheetCollectionView": bottomSheetCollectionView]
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[bottomSheetCollectionView]|", options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[bottomSheetCollectionView]|", options: [], metrics: nil, views: views))
//        collectionViewHeightConstraint = NSLayoutConstraint.init(item: bottomSheetCollectionView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 100)
//        bottomSheetCollectionView.addConstraint(collectionViewHeightConstraint)
//        collectionViewHeightConstraint.isActive = true

    }
    
    override open var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: 140)
    }

}

extension KADashBordBubble: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return bottomSheetData?.count ?? 0
    }
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let collectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: collectionViewIdentifier, for: indexPath)
        if let cell = collectionViewCell as? KREPanelDashBoardCollectionViewCell  {
            //Take notes
            if let dataToShow = bottomSheetData?[indexPath.row] as? KRECommonWidgetData {
                cell.backgroundColor = .white
                cell.countLabel.text = dataToShow.text
                cell.countLabel.clipsToBounds = true
                cell.countLabel.layer.cornerRadius = 30
                if let color = dataToShow.theme {
                    cell.countLabel.backgroundColor = UIColor(hexString: color)
                }
                cell.nameLabel.text = dataToShow.title
                cell.nameLabel.backgroundColor = .clear
            }
        }
        return collectionViewCell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
    
    
    // MARK: - UICollectionViewDelegateContactFlowLayout
    
    fileprivate var sectionInsets: UIEdgeInsets {
        return .zero
    }
    
    fileprivate var itemsPerRow: CGFloat {
        return 4
    }
    
    fileprivate var interitemSpace: CGFloat {
        return 5.0
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAt indexPath: IndexPath) -> CGSize {
        let sectionPadding = sectionInsets.left * (itemsPerRow + 1)
        let interitemPadding = max(0.0, itemsPerRow - 1) * interitemSpace
        let availableWidth = collectionView.bounds.width - sectionPadding - interitemPadding
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: 80, height: 120)
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return interitemSpace
    }
    
}

open class KREPanelDashBoardCollectionViewCell: UICollectionViewCell {
    // MARK: - properties
    open var countLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.textFont(ofSize: 14.0, weight: .regular)
        label.textColor = UIColor.charcoalGrey
        label.textAlignment = NSTextAlignment.center
        label.numberOfLines = 1
        return label
    }()
    
    open var nameLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.textFont(ofSize: 14.0, weight: .regular)
        label.textColor = UIColor.charcoalGrey
        label.textAlignment = NSTextAlignment.center
        label.numberOfLines = 2
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        intialize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        intialize()
    }
    
    func intialize() {
        backgroundColor = UIColor.clear
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(nameLabel)
        contentView.addSubview(countLabel)
        
        let views: [String: Any] = ["nameLabel": nameLabel, "countLabel": countLabel]
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[countLabel(60)]-15-|", options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[countLabel(60)]-9-[nameLabel]", options: [], metrics: nil, views: views))
        nameLabel.widthAnchor.constraint(equalToConstant: 90.0).isActive = true
        nameLabel.centerXAnchor.constraint(equalTo: countLabel.centerXAnchor, constant: 0.0).isActive = true
        countLabel.layer.cornerRadius = 40
    }
}

