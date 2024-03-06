//
//  KREButtonCollectionView.swift
//  KoreBotSDK
//
//  Created by Srinivas Vasadi on 05/01/2020.
//  Copyright © 2019 Srinivas Vasadi. All rights reserved.
//

import UIKit

public class KREButtonCollectionView: UIView {
    // MARK: - properties
    public var actions: [KREButtonTemplate]? {
        didSet {
            collectionView.reloadData()
        }
    }

    public var buttonsLayout: KREButtonsLayout? {
        didSet {
            collectionView.reloadData()
        }
    }
    
    public lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = UICollectionView.ScrollDirection.horizontal
        flowLayout.minimumInteritemSpacing = 10.0
        flowLayout.minimumLineSpacing = 1

        let collectionView = UICollectionView(frame: bounds, collectionViewLayout: flowLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = UIColor.clear
        collectionView.bounces = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()
        
    let prototypeCell = KREButtonCollectionViewCell()
    public var buttonAction: ((KREButtonTemplate?) -> Void)?
    
    let cellHeight: CGFloat = 32.0
    let cellIdentifier = "KREButtonCollectionViewCell"
    
    // MARK:- init
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    // MARK: -
    public func prepareForReuse() {
        actions = nil
        collectionView.reloadData()
    }
    
    // MARK: - setup
    func setup() {
        backgroundColor = .clear
        
        collectionView.register(KREButtonCollectionViewCell.self, forCellWithReuseIdentifier: "KREButtonCollectionViewCell")
        collectionView.dataSource = self
        collectionView.delegate = self
        addSubview(collectionView)
        
        let views: [String: Any] = ["collectionView": collectionView]
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[collectionView]|", options:[], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[collectionView]|", options:[], metrics: nil, views: views))
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
    }
    
    // MARK: -
    func configureCell(_ cell: KREButtonCollectionViewCell, for action: KREButtonTemplate) {
        cell.layer.shadowColor = UIColor.paleGrey2.cgColor
        cell.layer.borderColor = UIColor.paleGrey2.cgColor
        cell.layer.cornerRadius = 4.0
        cell.layer.shadowRadius = 7.0
        cell.layer.masksToBounds = false
        cell.layer.borderWidth = 1.0
        cell.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        cell.layer.shadowOpacity = 0.1
        
        // image
        var canShowImage: Bool = false
        if let imageTemplate = action.image, let imageType = imageTemplate.imageType {
            switch imageType {
            case "image":
                if let urlString = imageTemplate.source, let url = URL(string: urlString) {
                    cell.imageView.af.setImage(withURL: url, placeholderImage: UIImage(named: "placeholder_image"))
                    canShowImage = true
                }
            default:
                break
            }
        }
        cell.imageView.isHidden = !canShowImage

        if let title = action.title?.uppercased() {
            let attributedText = NSMutableAttributedString(string: title, attributes: [.font: UIFont.textFont(ofSize: 12.0, weight: .regular), .foregroundColor: UIColor.lightRoyalBlue, .kern: 1.0])
            cell.titleLabel.attributedText = attributedText
        }
        
        cell.titleLabel.textColor = UIColor.lightRoyalBlue
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension KREButtonCollectionView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch buttonsLayout?.style {
        case "fitToWidth":
            return actions?.count ?? 0
        default:
            return actions?.count ?? 0
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath)
        if let cell = cell as? KREButtonCollectionViewCell,
            let action = actions?[indexPath.row] {
            configureCell(cell, for: action)
        }
        cell.layoutIfNeeded()
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? KREButtonCollectionViewCell, let action = actions?[indexPath.row] {
            buttonAction?(action)
        }
    }
    
    // MARK: - UICollectionViewDelegateContactFlowLayout
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch buttonsLayout?.style {
        case "fitToWidth":
            let limit = buttonsLayout?.count ?? 1
            return CGSize(width: (collectionView.bounds.width -  CGFloat(limit * 10)) / CGFloat(limit) , height: cellHeight)
        default:
            var width: CGFloat = 0.0
            var hasImage: Bool = false
            
            if let action = actions?[indexPath.row], let imageTemplate = action.image, let imageType = imageTemplate.imageType {
                switch imageType {
                case "image":
                    if let urlString = imageTemplate.source, let _ = URL(string: urlString) {
                        hasImage = true
                    }
                default:
                    break
                }
            }
            if let title = actions?[indexPath.row].title?.uppercased() {
                let attributedText = NSMutableAttributedString(string: title, attributes: [.font: UIFont.textFont(ofSize: 12.0, weight: .regular), .foregroundColor: UIColor.lightGreyBlue, .kern: 1.0])
                width = prototypeCell.widthForCell(string: attributedText, hasImage: hasImage, height: cellHeight)
            }
            return CGSize(width: width, height: cellHeight)
        }
    }
}
