//
//  KREWidgetBubbleView.swift
//  KoreBotSDK
//
//  Created by Srinivas Vasadi on 12/03/19.
//  Copyright © 2019 Srinivas Vasadi. All rights reserved.
//

import UIKit

public protocol KREWidgetBubbleViewDelegate: NSObjectProtocol {
    func refreshWidget(_ widget: KREWidget)
}

open class KREWidgetBubbleView: UIView {
    // MARK: - properties
    let bundle = Bundle(for: KREWidgetBubbleView.self)
    var collectionViewIdentifier = "KRESegmentButtonsCollectionViewCell"
    let buttonMaxHeight: CGFloat = 42.0
    let titleHeight: CGFloat = 23.0
    let titleContainerHeight: CGFloat = 36.0
    var themeColor: UIColor?
    var delegate: KREWidgetBubbleViewDelegate?
    var widget: KREWidget? {
        didSet {
            populateBubbleView()
        }
    }
    public lazy var bubbleContainerView: UIStackView = {
        let bubbleContainerView = UIStackView(frame: .zero)
        bubbleContainerView.backgroundColor = UIColor.clear
        bubbleContainerView.translatesAutoresizingMaskIntoConstraints = false
        bubbleContainerView.axis = .vertical
        return bubbleContainerView
    }()
    var addActionHandler:(() -> Void)?
    var didSelectComponentAtIndex:((Int) -> Void)?
    let prototypeCell = KRESegmentButtonsCollectionViewCell()

    lazy var buttonTitleAttributes: [NSAttributedString.Key: Any] = {
        return [.font: UIFont.textFont(ofSize: 14.0, weight: .bold), .foregroundColor: UIColor.lightRoyalBlue, .kern: 1.87]
    }()
    lazy var filterSegmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(frame: .zero)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.apportionsSegmentWidthsByContent = false
        segmentedControl.layer.cornerRadius = 15.0
        segmentedControl.layer.borderWidth = 1.0
        segmentedControl.layer.masksToBounds = true
        segmentedControl.addTarget(self, action: #selector(filterDidChange(_:)), for: .valueChanged)
        return segmentedControl
    }()
    lazy var titleLabel: UILabel = {
        let titleLabel = UILabel(frame: .zero)
        titleLabel.backgroundColor = .clear
        titleLabel.font = UIFont.textFont(ofSize: 13.0, weight: .medium)
        titleLabel.numberOfLines = 0
        titleLabel.textColor = UIColor.dark
        titleLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        titleLabel.contentMode = .topLeft
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }()
    lazy var plusButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.setImage(UIImage(named: "addPanel"), for: .normal)
        button.backgroundColor = UIColor.paleGrey
        return button
    }()
    lazy var buttonsContainerView: UIView = {
        let buttonsContainerView = UIView(frame: .zero)
        buttonsContainerView.translatesAutoresizingMaskIntoConstraints = false
        return buttonsContainerView
    }()
    lazy var titleContainerView: UIView = {
        let titleContainerView = UIView(frame: .zero)
        titleContainerView.translatesAutoresizingMaskIntoConstraints = false
        return titleContainerView
    }()
    lazy var progressBar: KRELinearProgressBar = {
        let progressBar = KRELinearProgressBar(frame: .zero)
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        progressBar.backgroundColor = UIColor.silver
        progressBar.clipsToBounds = true
        return progressBar
    }()
    lazy var moveButton: UIButton = {
        let moveButton = UIButton(frame: .zero)
        let image = UIImage(named: "addPanel")
        moveButton.setImage(image, for: .normal)
        moveButton.contentMode = .scaleAspectFit
        moveButton.isHidden = false
        moveButton.translatesAutoresizingMaskIntoConstraints = false
        return moveButton
    }()
    
    // MARK: init
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
        clipsToBounds = true
        backgroundColor = UIColor.paleGrey

        addSubview(titleContainerView)

        bubbleContainerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(bubbleContainerView)
        
        // setting bubbleContainerView constraints
        let views: [String: UIView] = ["bubbleContainerView": bubbleContainerView, "titleContainerView": titleContainerView]
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[titleContainerView][bubbleContainerView]|", options:[], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[bubbleContainerView]|", options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[titleContainerView]|", options: [], metrics: nil, views: views))

        bubbleContainerView.addArrangedSubview(progressBar)
        bubbleContainerView.addArrangedSubview(buttonsContainerView)

        titleContainerView.backgroundColor = UIColor.white
        moveButton.addTarget(self, action: #selector(refreshWidget), for: .touchUpInside)
        titleContainerView.addSubview(moveButton)
        titleContainerView.addSubview(titleLabel)

        let titleAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont.textFont(ofSize: 15.0, weight: .medium)
            
        ]
        filterSegmentedControl.setTitleTextAttributes(titleAttributes, for: .selected)
        
        let normalTitleAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.foregroundColor: UIColor.black,
            NSAttributedString.Key.font: UIFont.textFont(ofSize: 15.0, weight: .medium)
        ]
        filterSegmentedControl.setTitleTextAttributes(normalTitleAttributes, for: .normal)
        
        filterSegmentedControl.backgroundColor = .paleGrey
        filterSegmentedControl.layer.cornerRadius = 6.0
        filterSegmentedControl.layer.cornerRadius = 6.0
        filterSegmentedControl.layer.masksToBounds = false
        filterSegmentedControl.layer.borderWidth = 0.5
        buttonsContainerView.addSubview(filterSegmentedControl)

        filterSegmentedControl.heightAnchor.constraint(equalToConstant: buttonMaxHeight).isActive = true
        titleContainerView.heightAnchor.constraint(equalToConstant: titleContainerHeight).isActive = true
        moveButton.heightAnchor.constraint(equalToConstant: titleContainerHeight).isActive = true
        moveButton.centerYAnchor.constraint(equalTo: titleContainerView.centerYAnchor).isActive = true
        progressBar.heightAnchor.constraint(equalToConstant: 0.0).isActive = true

        // setting buttonsContainerView constraints
        let buttonsContainerViews: [String: UIView] = ["filterSegmentedControl": filterSegmentedControl]
        buttonsContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[filterSegmentedControl]-4-|", options: [], metrics: nil, views: buttonsContainerViews))
        buttonsContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[filterSegmentedControl]-10-|", options: [], metrics: nil, views: buttonsContainerViews))
        
        // setting titleContainerView constraints
        let titleContainerViews: [String: UIView] = ["titleLabel": titleLabel, "moveButton": moveButton]
        titleContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[titleLabel]|", options: [], metrics: nil, views: titleContainerViews))
        titleContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[titleLabel][moveButton]-10-|", options: [], metrics: nil, views: titleContainerViews))
        
        progressBar.isLoading = true
        progressBar.isHidden = true
    }
    
    // MARK: - populate bubbleView
    open func populateBubbleView() {
        guard let widget = widget as? KREWidget else {
            startShimmering()
            return
        }
        
        stopShimmering()
        backgroundColor = UIColor.white
        titleContainerView.backgroundColor = UIColor.white
        
        if let title = widget.title {
            let attributedString = NSMutableAttributedString(string: title, attributes: [.font: UIFont.textFont(ofSize: 17.0, weight: .semibold), .foregroundColor: UIColor.dark, .kern: 1.0])
            titleLabel.attributedText = attributedString
        }
        if let color = widget.themeColor {
            themeColor = UIColor(hexString: color)
            progressBar.progressBarColor = UIColor(hexString: color)
        }
        
        populateFilters()
        if let widgetFilters = widget.filters {
            if widgetFilters.count > 1 {
                buttonsContainerView.isHidden = false
            } else {
                buttonsContainerView.isHidden = true
            }
            
            if let widgetFilter = widgetFilters.first as? KREWidgetFilter {
                let isLoading = widgetFilter.isLoading
                progressBar.isLoading = isLoading
                progressBar.isHidden = !isLoading
            } else {
                let isLoading = false
                progressBar.isLoading = isLoading
                progressBar.isHidden = !isLoading
            }
        }

        guard let filters = widget.filters as? [KREWidgetFilter] else {
            return
        }
        
        let selectedFilters = filters.filter { $0.isSelected == true}
        guard let widgetFilter = selectedFilters.first,
            let widgetComponent = widgetFilter.component,
            let elements = widgetComponent.elements else {
                return
        }
        
        layoutIfNeeded()
        invalidateIntrinsicContentSize()
    }
    
    @objc func refreshWidget() {
        addActionHandler?()
//        if let widget = widget as? KREWidget {
//            delegate?.refreshWidget(widget)
//        }
    }
    
    // MARK: - Method to be overridden
    open func prepareForReuse() {
        titleLabel.text = nil
        progressBar.isLoading = false
        progressBar.isHidden = true
        buttonsContainerView.isHidden = false
        invalidateIntrinsicContentSize()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    // MARK: -
    func populateFilters() {
        guard let filters = widget?.filters else {
            return
        }

        filterSegmentedControl.layer.borderColor = UIColor.veryLightBlue.cgColor
        if #available(iOS 13.0, *) {
           filterSegmentedControl.selectedSegmentTintColor = themeColor ?? UIColor.coralPink
        } else {
           filterSegmentedControl.tintColor = themeColor ?? UIColor.coralPink
        }
        
        filterSegmentedControl.removeAllSegments()
        
        for index in 0..<filters.count {
            let filter = filters[index]
            filterSegmentedControl.insertSegment(withTitle: filter.title, at: index, animated: false)
            if filter.isSelected {
                filterSegmentedControl.selectedSegmentIndex = index
            }
        }
    }
    
    @objc func filterDidChange(_ segmentedControl: UISegmentedControl) {
        filterSegmentedControl.layer.borderColor = UIColor.veryLightBlue.cgColor
        filterSegmentedControl.layer.cornerRadius = 6.0
        filterSegmentedControl.layer.masksToBounds = false
        filterSegmentedControl.layer.borderWidth = 0.5

        if let filters = widget?.filters {
            let selectedIndex = segmentedControl.selectedSegmentIndex
            let filter = filters[selectedIndex]
            
            let manager = KREWidgetManager.shared
            manager.updateSelectedWidgetFilter(filter, in: widget)
            
            populateBubbleView()
            didSelectComponentAtIndex?(selectedIndex)
            layoutSubviews()
            invalidateIntrinsicContentSize()
        }
    }
    
    // MARK: -
    func startShimmering() {

    }
    
    func stopShimmering() {

    }

    // MARK: - deinit
    deinit {
        
    }
}

// MARK: - KRECollectionViewCenteredFlowLayout
open class KRECollectionViewCenteredFlowLayout: UICollectionViewFlowLayout {
    open override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let layoutAttributesForElements = super.layoutAttributesForElements(in: rect) else {
            return nil
        }
        guard let collectionView = collectionView else {
            return layoutAttributesForElements
        }

        var representedElements: [UICollectionViewLayoutAttributes] = []
        var cells: [[UICollectionViewLayoutAttributes]] = [[]]
        var previousFrame: CGRect?
        if scrollDirection == .vertical {
            for layoutAttributes in layoutAttributesForElements {
                guard layoutAttributes.representedElementKind == nil else {
                    representedElements.append(layoutAttributes)
                    continue
                }
                let currentItemAttributes = layoutAttributes.copy() as! UICollectionViewLayoutAttributes
                if previousFrame != nil && !currentItemAttributes.frame.intersects(CGRect(x: -.greatestFiniteMagnitude, y: previousFrame!.origin.y, width: .infinity, height: previousFrame!.size.height)) {
                    cells.append([])
                }
                cells[cells.endIndex - 1].append(currentItemAttributes)
                previousFrame = currentItemAttributes.frame
            }

            return representedElements + cells.flatMap { group -> [UICollectionViewLayoutAttributes] in
                guard let section = group.first?.indexPath.section else {
                    return group
                }
                let evaluatedSectionInset = evaluatedSectionInsetForSection(at: section)
                let evaluatedMinimumInteritemSpacing = evaluatedMinimumInteritemSpacingForSection(at: section)
                var origin = (collectionView.bounds.width + evaluatedSectionInset.left - evaluatedSectionInset.right - group.reduce(0, { $0 + $1.frame.size.width }) - CGFloat(group.count - 1) * evaluatedMinimumInteritemSpacing) / 2
                return group.map {
                    $0.frame.origin.x = origin
                    origin += $0.frame.size.width + evaluatedMinimumInteritemSpacing
                    return $0
                }
            }
        } else {
            for layoutAttributes in layoutAttributesForElements {
                guard layoutAttributes.representedElementKind == nil else {
                    representedElements.append(layoutAttributes)
                    continue
                }
                let currentItemAttributes = layoutAttributes.copy() as! UICollectionViewLayoutAttributes
                if previousFrame != nil && !currentItemAttributes.frame.intersects(CGRect(x: previousFrame!.origin.x, y: -.greatestFiniteMagnitude, width: previousFrame!.size.width, height: .infinity)) {
                    cells.append([])
                }
                cells[cells.endIndex - 1].append(currentItemAttributes)
                previousFrame = currentItemAttributes.frame
            }

            return representedElements + cells.flatMap { group -> [UICollectionViewLayoutAttributes] in
                guard let section = group.first?.indexPath.section else {
                    return group
                }
                let evaluatedSectionInset = evaluatedSectionInsetForSection(at: section)
                let evaluatedMinimumInteritemSpacing = evaluatedMinimumInteritemSpacingForSection(at: section)
                var origin = (collectionView.bounds.height + evaluatedSectionInset.top - evaluatedSectionInset.bottom - group.reduce(0, { $0 + $1.frame.size.height }) - CGFloat(group.count - 1) * evaluatedMinimumInteritemSpacing) / 2
                return group.map {
                    $0.frame.origin.y = origin
                    origin += $0.frame.size.height + evaluatedMinimumInteritemSpacing
                    return $0
                }
            }
        }
    }
}

extension UICollectionViewFlowLayout {
    internal func evaluatedSectionInsetForSection(at section: Int) -> UIEdgeInsets {
        return (collectionView?.delegate as? UICollectionViewDelegateFlowLayout)?.collectionView?(collectionView!, layout: self, insetForSectionAt: section) ?? sectionInset
    }
    internal func evaluatedMinimumInteritemSpacingForSection(at section: Int) -> CGFloat {
        return (collectionView?.delegate as? UICollectionViewDelegateFlowLayout)?.collectionView?(collectionView!, layout: self, minimumInteritemSpacingForSectionAt: section) ?? minimumInteritemSpacing
    }
}
extension UIView {
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        mask.strokeColor = UIColor.charcoalGrey.cgColor
        layer.mask = mask
    }
}

