//
//  KREImagesCollectionView.swift
//  Widgets
//
//  Created by developer@kore.com on 16/11/16.
//  Copyright © 2016 Kore Inc. All rights reserved.
//

import UIKit

public class KREImageCollectionViewCell: UICollectionViewCell {
    // MARK:- init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK:- image view
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "frozen")
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 4
        iv.layer.masksToBounds = true
        iv.backgroundColor = UIColor.brown
        return iv
    }()
    
    // MARK:- set up views
    func setupViews() {
        addSubview(imageView)
        imageView.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.width)
    }
}

public class KREImagesCollectionView: UIView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    fileprivate let cellId = "imageCellId"
    
    // MARK:- init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK:- views

    let appsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 1
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        return collectionView
    }()
    
    let topDividerLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.4, alpha: 0.4)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let bottomDividerLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.4, alpha: 0.4)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK:- set up views
    func setupViews() {
        backgroundColor = UIColor.clear
        
        addSubview(appsCollectionView)
        addSubview(bottomDividerLineView)
        addSubview(topDividerLineView)
        
        appsCollectionView.dataSource = self
        appsCollectionView.delegate = self
        
        appsCollectionView.register(KREImageCollectionViewCell.self, forCellWithReuseIdentifier: cellId)
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-14-[v0]|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": topDividerLineView]))
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-14-[v0]|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": bottomDividerLineView]))
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[v0]|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": appsCollectionView]))
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0(0.5)][v1][v2(0.5)]|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["v0": topDividerLineView, "v1": appsCollectionView, "v2": bottomDividerLineView]))
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 15
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: frame.height - 6, height: frame.height - 6)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 1, bottom: 0, right: 1)
    }
}

public class KREImagesViewCell: UITableViewCell {
    // MARK:- init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK:- image view
    let imagesCollectionView: KREImagesCollectionView = {
        let imagesCollectionView = KREImagesCollectionView()
        imagesCollectionView.translatesAutoresizingMaskIntoConstraints = false
        return imagesCollectionView
    }()
    
    // MARK:- set up views
    func setupViews() {
        contentView.addSubview(imagesCollectionView)
        
        let views = ["imagesCollectionView": imagesCollectionView]
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[imagesCollectionView]|", options: [], metrics: nil, views: views));
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[imagesCollectionView]|", options: [], metrics: nil, views: views));

    }
}
