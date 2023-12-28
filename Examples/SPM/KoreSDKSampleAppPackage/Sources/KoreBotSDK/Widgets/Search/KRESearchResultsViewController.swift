//
//  KRESearchResultsViewController.swift
//  KoreBotSDK
//
//  Created by Srinivas Vasadi on 06/01/2020.
//  Copyright © 2019 Srinivas Vasadi. All rights reserved.
//

import UIKit


// MARK: -
public class KRESearchResultsViewController: UIViewController {
    // MARK: - properties
    let bundle = Bundle(for: KRESearchResultsViewController.self)
    let searchElementViewCellIdentifier = "KRESearchElementViewCell"
    public var elementDidSelectAction:((Decodable?, KRESearchResultType) -> Void)?
    public var elementDidSelectActionKnowledgeCollection:((KREKnowledgeCollectionElementData?, KRESearchResult?) -> Void)?
    private let cellHeight: CGFloat = 37.0
    public var selectedIndex: Int = 0
    public var searchResult: KRESearchResult? {
        didSet {
            populateSearchResults()
        }
    }
    public var element: KRESearchResultElement?

    public lazy var resultsView: KRESearchResultsView = {
        let resultsView = KRESearchResultsView(frame: .zero)
        resultsView.translatesAutoresizingMaskIntoConstraints = false
        resultsView.backgroundColor = .clear
        resultsView.resultsViewType = .full
        return resultsView
    }()
    
    lazy var flowLayout: UICollectionViewFlowLayout = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: 1.0, height: 1.0)
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumInteritemSpacing = 13.0
        flowLayout.minimumLineSpacing = 1
        flowLayout.sectionInset = UIEdgeInsets(top: 0.0, left: 14.0, bottom: 0.0, right: 15.0)
        return flowLayout
    }()
    
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = UIColor.clear
        collectionView.bounces = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()

    lazy var bgView: UIView = {
        let bgView = UIView(frame: .zero)
        bgView.translatesAutoresizingMaskIntoConstraints = false
        bgView.backgroundColor = UIColor.clear
        return bgView
    }()
    
    let prototypeCell = KRESearchElementViewCell()
        
    // MARK: - init
    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: -
    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        collectionView.register(KRESearchElementViewCell.self, forCellWithReuseIdentifier: searchElementViewCellIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        view.addSubview(collectionView)
        view.addSubview(resultsView)
        view.addSubview(bgView)
        bgView.addSubview(collectionView)
        let metrics: [String: Any] = ["cellHeight": cellHeight]
        let views: [String: Any] = ["resultsView": resultsView, "collectionView": collectionView, "bgView": bgView]
        bgView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[collectionView(cellHeight)]", options: [], metrics: metrics, views: views))
        bgView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[collectionView]|", options: [], metrics: metrics, views: views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[bgView(50)]", options: [], metrics: metrics, views: views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[resultsView]|", options: [], metrics: nil, views: views))
        if #available(iOS 11, *) {
            let guide = view.safeAreaLayoutGuide
            resultsView.topAnchor.constraint(equalTo: guide.topAnchor, constant: 54).isActive = true
        } else {
            let standardSpacing: CGFloat = 0.0
            resultsView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: 54).isActive = true
        }

        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[resultsView]|", options: [], metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[collectionView]|", options: [], metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[bgView]|", options: [], metrics: nil, views: views))
        resultsView.elementDidSelectAction = { [weak self] (element, resultType) in
            self?.elementDidSelectAction?(element, resultType)
        }
        resultsView.elementDidSelectActionKnowledgeCollection = { [weak self] (element, results) in
            self?.elementDidSelectActionKnowledgeCollection?(element, results)
        }
        
        scrollToSearchResultElement(element)
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationItems()
    }
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
       
    // MARK: -
    func populateSearchResults() {
        resultsView.result = searchResult
    }
    
    func setupNavigationItems() {
        let image = UIImage(named: "backIcon", in: bundle, compatibleWith: nil)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(closeButtonAction))
        navigationItem.leftBarButtonItem?.tintColor = UIColor.gunmetal
        navigationController?.navigationBar.barTintColor = UIColor.white
    }
    
    func scrollToSection(_ section: Int, animated: Bool = true) {
       let indexPath = IndexPath(item: 0, section: section)
        resultsView.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        
//        let indexPath = IndexPath(item: 0, section: section)
//        let rect = resultsView.tableView.rectForRow(at: indexPath)
//        let rectInScreen = resultsView.tableView.convert(rect, to: resultsView.tableView.superview)
//        var delta =  rectInScreen.origin.y
//        if animated {
//            UIView.animate(withDuration: 2, delay: 0, options: UIView.AnimationOptions.curveLinear, animations: {
//                var positionToMove = delta + self.resultsView.tableView.contentOffset.y - 40
//                self.resultsView.tableView.setContentOffset(CGPoint(x: 0, y: positionToMove), animated: true)
//            }, completion: nil)
//        } else {
//            var positionToMove = delta + self.resultsView.tableView.contentOffset.y - 40
//            resultsView.tableView.setContentOffset(CGPoint(x: 0, y: positionToMove), animated: false)
//        }
    }
    
    func scrollToSearchResultElement(_ searchResultElement: KRESearchResultElement?) {
        guard let element = element, let section = searchResult?.elements?.index(of: element) else {
            return
        }
        
        selectedIndex = section
        scrollToSection(section, animated: false)
    }
        
    // MARK: -
    @objc func closeButtonAction() {
        navigationController?.dismiss(animated: true, completion: nil)
    }
}

// MARK: -
extension KRESearchResultsViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    // MARK:- datasource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searchResult?.elements?.count ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let collectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: searchElementViewCellIdentifier, for: indexPath)
        let elements = searchResult?.elements
        if let cell = collectionViewCell as? KRESearchElementViewCell, let element = elements?[indexPath.row] {
            var title = ""
            title = (element.title ?? "") + " (\((element.count ?? 0)))"
            if element.resultType == .knowledgeCollection {
                if let knowledgeCollectionElement = element.knowledgeCollElement as? KREKnowledgeCollectionElement {
                    let count = ((knowledgeCollectionElement.definitive?.count ?? 0) + (knowledgeCollectionElement.suggestive?.count ?? 0))
                    title = (element.title ?? "") + " (\(count))"
                }
            }
            cell.title = title
            if selectedIndex == indexPath.row {
                cell.titleLabel.textColor = UIColor.white
                cell.backgroundColor = UIColor.lightRoyalBlue
            } else {
                cell.titleLabel.textColor = UIColor.dark
                cell.backgroundColor = UIColor.white
            }
        }
        collectionViewCell.layoutSubviews()
        return collectionViewCell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        collectionView.performBatchUpdates({
            collectionView.layoutIfNeeded()
        }) { (finished) in
            collectionView.reloadData()
        }
        
        scrollToSection(selectedIndex, animated: true)
    }
    
    // MARK: - UICollectionViewDelegateContactFlowLayout
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let elements = searchResult?.elements
        if let element = elements?[indexPath.row] {
            var title = ""
            title = (element.title ?? "") + " (\((element.count ?? 0)))"
            if element.resultType == .knowledgeCollection {
                if let knowledgeCollectionElement = element.knowledgeCollElement as? KREKnowledgeCollectionElement {
                    let count = ((knowledgeCollectionElement.definitive?.count ?? 0) + (knowledgeCollectionElement.suggestive?.count ?? 0))
                    title = (element.title ?? "") + " (\(count))"
                }
            }

            prototypeCell.title = title
            let widthForItem = prototypeCell.widthForCell(string: title, height: cellHeight)
            return CGSize(width: widthForItem, height: cellHeight)
        }
        
        return CGSize.zero
    }
}

// MARK: - KRESearchElementViewCell
public class KRESearchElementViewCell: UICollectionViewCell {
    public lazy var titleLabel: UILabel = {
        let titleLabel = UILabel(frame: .zero)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.backgroundColor = .clear
        titleLabel.textAlignment = .left
        titleLabel.font = UIFont.textFont(ofSize: 14.0, weight: .medium)
        titleLabel.clipsToBounds = true
        return titleLabel
    }()
    
    // MARK: - init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    
    func setup() {
        backgroundColor = UIColor.white
        contentView.addSubview(titleLabel)
        
        titleLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        titleLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)

        let layer: CALayer = self.layer
        layer.masksToBounds = true
        layer.cornerRadius = 8.0
        layer.borderColor  = UIColor(hex: 0xEDEDEF).cgColor
        layer.borderWidth = 1.0
        backgroundColor = UIColor(hex: 0xEDEDEF)
        
        let views: [String: Any] = ["titleLabel": titleLabel]
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[titleLabel]-|", options: [], metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[titleLabel]|", options: [], metrics: nil, views: views))
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
    }
    
    // MARK: -
    func widthForCell(string: String?, height: CGFloat) -> CGFloat {
        titleLabel.text = string
        var width: CGFloat = titleLabel.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: height)).width
        width += 16.0
        return width
    }
}
