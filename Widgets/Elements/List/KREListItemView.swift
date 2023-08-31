//
//  KREListItemView.swift
//  KoreBotSDK
//
//  Created by Srinivas Vasadi on 05/01/2020.
//  Copyright © 2019 Srinivas Vasadi. All rights reserved.
//

import UIKit

public class KREListItemView: UIView {
    // MARK: - properties
    let bundle = Bundle(for: KREListItemView.self)
    let constant: CGFloat = 40.0
    
    // MARK: - views
    public lazy var titleLabel: UILabel = {
        let titleLabel = UILabel(frame: .zero)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.textFont(ofSize: 16.0, weight: .bold)
        titleLabel.textColor = UIColor.charcoalGrey
        titleLabel.layer.masksToBounds = true
        titleLabel.textAlignment = .left
        titleLabel.sizeToFit()
        return titleLabel
    }()
    
    public lazy var subTitleLabel: UILabel = {
        var subTitleLabel: UILabel = UILabel(frame: .zero)
        subTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subTitleLabel.font = UIFont.textFont(ofSize: 13.0, weight: .regular)
        subTitleLabel.textColor = UIColor.gunmetal
        subTitleLabel.lineBreakMode = .byWordWrapping
        subTitleLabel.numberOfLines = 0
        subTitleLabel.sizeToFit()
        return subTitleLabel
    }()
    
    public lazy var actionLabel: UILabel = {
        var actionLabel: UILabel = UILabel(frame: .zero)
        actionLabel.translatesAutoresizingMaskIntoConstraints = false
        actionLabel.font = UIFont.textFont(ofSize: 16.0, weight: .heavy)
        actionLabel.textColor = UIColor.gunmetal
        actionLabel.textAlignment = .left
        actionLabel.lineBreakMode = .byWordWrapping
        actionLabel.numberOfLines = 0
        return actionLabel
    }()

    public lazy var buttonCollectionView: KREButtonCollectionView = {
        let buttonCollectionView = KREButtonCollectionView(frame: .zero)
        buttonCollectionView.translatesAutoresizingMaskIntoConstraints = false
        return buttonCollectionView
    }()
    
    public lazy var imageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    public lazy var menuButton: UIButton = {
        let menuButton = UIButton(frame: .zero)
        menuButton.translatesAutoresizingMaskIntoConstraints = false
        menuButton.backgroundColor = UIColor.whiteTwo
        menuButton.setImage(UIImage(named: "menuInactive", in: bundle, compatibleWith: nil), for: .normal)
        menuButton.setImage(UIImage(named: "menuActive", in: bundle, compatibleWith: nil), for: .selected)
        menuButton.addTarget(self, action: #selector(menuButtonActionHandler(_:)), for: .touchUpInside)
        return menuButton
    }()
    
    public lazy var revealButton: UIButton = {
        let revealButton = UIButton(frame: .zero)
        revealButton.translatesAutoresizingMaskIntoConstraints = false
        revealButton.backgroundColor = UIColor.whiteTwo
        revealButton.setImage(UIImage(named: "revealUp", in: bundle, compatibleWith: nil), for: .normal)
        revealButton.setImage(UIImage(named: "revealDown", in: bundle, compatibleWith: nil), for: .selected)
        revealButton.addTarget(self, action: #selector(revealButtonHandler(_:)), for: .touchUpInside)
        return revealButton
    }()
    
    public lazy var actionButtonView: UIView = {
        let actionButtonView = UIView(frame: .zero)
        actionButtonView.backgroundColor = UIColor.paleGrey2
        actionButtonView.layer.cornerRadius = 4.0
        actionButtonView.translatesAutoresizingMaskIntoConstraints = false
        return actionButtonView
    }()
    
    public lazy var actionButton: UIButton = {
        let actionButton = UIButton(frame: .zero)
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        actionButton.titleLabel?.font = UIFont.textFont(ofSize: 12.0, weight: .regular)
        actionButton.titleLabel?.lineBreakMode = .byWordWrapping
        actionButton.titleLabel?.textAlignment = .center
        actionButton.layer.cornerRadius = 4.0
        actionButton.backgroundColor = .paleGrey2
        actionButton.setTitleColor(.lightRoyalBlue, for: .normal)
        actionButton.titleLabel?.layer.masksToBounds = true
        actionButton.titleLabel?.numberOfLines = 1
        actionButton.addTarget(self, action: #selector(actionButtonHandler(_:)), for: .touchUpInside)
        return actionButton
    }()
    
    public lazy var actionImageView: UIButton = {
        let actionImageView = UIButton(frame: .zero)
        actionImageView.translatesAutoresizingMaskIntoConstraints = false
        actionImageView.layer.cornerRadius = 4.0
        actionImageView.backgroundColor = .paleGrey2
        actionImageView.contentMode = .center
        actionImageView.addTarget(self, action: #selector(actionImageViewHandler(_:)), for: .touchUpInside)
        return actionImageView
    }()
    
    // MARK: - stackviews
    public lazy var headerStackView: UIStackView = {
        let headerStackView = UIStackView(frame: .zero)
        headerStackView.translatesAutoresizingMaskIntoConstraints = false
        headerStackView.axis = .horizontal
        headerStackView.distribution = .fill
        headerStackView.alignment = .leading
        headerStackView.spacing = 16.0
        return headerStackView
    }()
    
    public lazy var itemStackView: UIStackView = {
        let itemStackView = UIStackView(frame: .zero)
        itemStackView.translatesAutoresizingMaskIntoConstraints = false
        itemStackView.axis = .horizontal
        itemStackView.distribution = .fill
        itemStackView.alignment = .leading
        itemStackView.spacing = 2.0
        return itemStackView
    }()
    
    public lazy var rightStackView: UIStackView = {
        let rightStackView = UIStackView(frame: .zero)
        rightStackView.axis = .vertical
        rightStackView.distribution = .fill
        rightStackView.alignment = .trailing
        rightStackView.spacing = 12.0
        rightStackView.translatesAutoresizingMaskIntoConstraints = false
        return rightStackView
    }()
    
    public lazy var leftStackView: UIStackView = {
        let leftStackView = UIStackView(frame: .zero)
        leftStackView.axis = .vertical
        leftStackView.distribution = .fill
        leftStackView.alignment = .leading
        leftStackView.spacing = 12.0
        leftStackView.translatesAutoresizingMaskIntoConstraints = false
        return leftStackView
    }()
    
    public lazy var detailsStackView: KREStackView = {
        let detailsStackView = KREStackView(frame: .zero)
        detailsStackView.axis = .vertical
        detailsStackView.hidesSeparatorsByDefault = true
        detailsStackView.translatesAutoresizingMaskIntoConstraints = false
        detailsStackView.spacing = 6.0
        return detailsStackView
    }()
    
    public lazy var titleStackView: UIStackView = {
        let titleStackView = UIStackView(frame: .zero)
        titleStackView.translatesAutoresizingMaskIntoConstraints = false
        titleStackView.axis = .vertical
        titleStackView.distribution = .fill
        titleStackView.alignment = .top
        titleStackView.spacing = 4.0
        return titleStackView
    }()

    public lazy var stackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .top
        stackView.spacing = 6.0
        return stackView
    }()

    public lazy var listItemStackView: KREStackView = {
        let detailsStackView = KREStackView(frame: .zero)
        detailsStackView.axis = .vertical
        detailsStackView.hidesSeparatorsByDefault = true
        detailsStackView.translatesAutoresizingMaskIntoConstraints = false
        detailsStackView.spacing = 16.0
        return detailsStackView
    }()

    public weak var listItem: KREListItem?
    public var buttonActionHandler:((KREAction?) -> Void)?
    public var menuActionHandler:(([KREAction]) -> Void)?
    public var revealActionHandler:(() -> Void)?
    public var viewMoreAction:(() -> Void)?
    public var updateSubviews:(() -> Void)?
    
    let metrics: [String: CGFloat] = ["left": 0.0, "right": 8.0, "top": 13.0, "bottom": 3.0]

    // MARK: - init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    public func prepareForReuse() {
        titleLabel.text = nil
        subTitleLabel.text = nil
        headerStackView.spacing = 10.0
        imageView.image = nil
    }
    
    // MARK: - setup
    func setup() {
        clipsToBounds = true
        backgroundColor = .clear
        actionButtonView.addSubview(actionButton)
        
        addSubview(listItemStackView)
        listItemStackView.addRow(itemStackView)
        addSubview(buttonCollectionView)
        itemStackView.addArrangedSubview(leftStackView)
        itemStackView.addArrangedSubview(rightStackView)
        
        // headerStackView
        imageView.heightAnchor.constraint(equalToConstant: constant).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: constant).isActive = true
        headerStackView.addArrangedSubview(imageView)
        
        titleStackView.addArrangedSubview(titleLabel)
        titleStackView.addArrangedSubview(subTitleLabel)
        headerStackView.addArrangedSubview(titleStackView)
        
        // leftStackView
        leftStackView.addArrangedSubview(headerStackView)
        leftStackView.addArrangedSubview(detailsStackView)
        
        // rightStackView
        menuButton.isHidden = true
        menuButton.heightAnchor.constraint(equalToConstant: constant).isActive = true
        menuButton.widthAnchor.constraint(equalToConstant: constant).isActive = true
        rightStackView.addArrangedSubview(menuButton)
        
        let actionViews: [String: UIView] = ["actionButton": actionButton]
        actionButtonView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[actionButton]-|", options: [], metrics: metrics, views: actionViews))
        actionButtonView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[actionButton]-|", options: [], metrics: metrics, views: actionViews))
        actionButtonView.centerYAnchor.constraint(equalTo: actionButton.centerYAnchor).isActive = true

        actionImageView.isHidden = true
        actionImageView.heightAnchor.constraint(equalToConstant: 32.0).isActive = true
        actionImageView.widthAnchor.constraint(equalToConstant: 26.0).isActive = true
        rightStackView.addArrangedSubview(actionImageView)
        
        actionButtonView.isHidden = true
        actionButton.heightAnchor.constraint(equalToConstant: 32.0).isActive = true
        rightStackView.addArrangedSubview(actionButtonView)
        
        actionLabel.isHidden = true
        actionLabel.heightAnchor.constraint(equalToConstant: 32.0).isActive = true
        rightStackView.addArrangedSubview(actionLabel)

        revealButton.isHidden = true
        revealButton.heightAnchor.constraint(equalToConstant: constant).isActive = true
        revealButton.widthAnchor.constraint(equalToConstant: constant).isActive = true
        rightStackView.addArrangedSubview(revealButton)

        // itemStackView
        let views: [String: UIView] = ["itemStackView": listItemStackView]
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(left)-[itemStackView]-(right)-|", options: [], metrics: metrics, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(top)-[itemStackView]-(bottom)-|", options: [], metrics: metrics, views: views))
                
        // priorities
        actionButtonView.heightAnchor.constraint(equalToConstant: 32.0).isActive = true
        buttonCollectionView.heightAnchor.constraint(equalToConstant: 32.0).isActive = true

        titleStackView.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        titleStackView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        rightStackView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        rightStackView.setContentHuggingPriority(.defaultHigh, for: .horizontal)

        leftStackView.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        leftStackView.setContentHuggingPriority(.defaultHigh, for: .horizontal)

        buttonCollectionView.buttonAction = { [weak self] (action) in
            self?.buttonActionHandler?(action)
        }
    }
    
    // MARK: -
    public func populateListItemView(_ listItem: KREListItem) {
        self.listItem = listItem
        titleLabel.text = listItem.title
        
        let attributes = [NSAttributedString.Key.font: UIFont.textFont(ofSize: 13.0, weight: .regular), NSAttributedString.Key.foregroundColor: UIColor.gunmetal]
        subTitleLabel.attributedText = NSAttributedString(string: listItem.subTitle ?? "", attributes: attributes)
        
        // image
        var canShowImage: Bool = false
        if let imageTemplate = listItem.image, let imageType = imageTemplate.imageType {
            switch imageType {
            case "image":
                if let urlString = imageTemplate.source, let url = URL(string: urlString) {
                    imageView.af.setImage(withURL: url, placeholderImage: UIImage(named: "placeholder_image"))
                    canShowImage = true
                }
                if let cornerRadius = imageTemplate.radius {
                    imageView.layer.cornerRadius = cornerRadius
                    imageView.layer.masksToBounds = true
                }
            default:
                break
            }
        }
        imageView.isHidden = !canShowImage
        
        revealButton.isHidden = true
        actionButtonView.isHidden = true
        menuButton.isHidden = true
        actionLabel.isHidden = true
        
        // values
        let value = listItem.value
        if value?.type == "menu" {
            menuButton.isHidden = false
        }
        
        if value?.type == "button",
            let buttonItem = value as? KREButtonItemValue,
            let button = buttonItem.button {
            actionButtonView.isHidden = false
            actionButton.setTitle(button.title, for: .normal)
        }
        
        if value?.type == "text" {
            actionLabel.isHidden = false
            actionLabel.text = value?.text
        }
            
        if value?.type == "url", let urlItem = value as? KREURLItemValue {
            actionButtonView.isHidden = false
            actionButton.setTitle(urlItem.title, for: .normal)
        }
        
        actionImageView.isHidden = true
        if value?.type == "image", let imageItem = value as? KREImageItemValue {
            if let imageTemplate = imageItem.image, let imageType = imageTemplate.imageType {
                switch imageType {
                case "image":
                    if let urlString = imageTemplate.source, let url = URL(string: urlString) {
                        let image = UIImage(named: "seeMore", in: bundle, compatibleWith: nil)
                        actionImageView.setImage(image, for: .normal)
                        actionImageView.isHidden = false
                    }
                default:
                    break
                }
            }
        }
        
        // populate list item details
        var canShowDetails: Bool = false
        if let details = listItem.details, details.count > 0 {
            populateListDetails(details)
        }
        
        if let buttons = listItem.buttons, buttons.count > 0 {
            revealButton.isHidden = false
        }
        
        buttonCollectionView.buttonsLayout = listItem.buttonsLayout
        
        layoutSubviews()
        updateSubviews?()
    }
    
    public func populateListDetails(_ details: [KREListItemDetails]) {
        detailsStackView.removeAllRows()
        for element in details {
            let detailView = KREListItemDetailView(frame: .zero)
            detailView.translatesAutoresizingMaskIntoConstraints = false
            detailView.descLabel.text = element.desc
            var isHidden = true
            if let imageTemplate = element.image, let imageType = imageTemplate.imageType {
                switch imageType {
                case "image":
                    if let urlString = imageTemplate.source, let url = URL(string: urlString) {
                        detailView.iconImageView.af.setImage(withURL: url, placeholderImage: UIImage(named: "placeholder_image"))
                        isHidden = false
                    }
                default:
                    break
                }
            }
            detailView.iconImageView.isHidden = isHidden
            detailsStackView.addRow(detailView)
        }
    }
    
    public func showOrHideButtons() {
        guard let buttons = listItem?.buttons else {
            return
        }
        
        if listItemStackView.containsRow(buttonCollectionView) {
            listItemStackView.removeRow(buttonCollectionView)
        } else {
            listItemStackView.addRow(buttonCollectionView)
            buttonCollectionView.actions = buttons
        }
        
        layoutSubviews()
        updateSubviews?()
    }
    
    public func loadingDataState() {
        titleLabel.text = ""
        subTitleLabel.text = ""
        titleLabel.textColor = .paleGrey
        titleLabel.backgroundColor = .paleGrey
        subTitleLabel.textColor = .paleGrey
        subTitleLabel.backgroundColor = .paleGrey
        imageView.backgroundColor = .paleGrey
        menuButton.isHidden = true
    }
    
    public func loadedDataState() {
        titleLabel.textColor = .charcoalGrey
        titleLabel.backgroundColor = .clear
        subTitleLabel.textColor = .gunmetal
        subTitleLabel.backgroundColor = .clear
        imageView.backgroundColor = .clear
        menuButton.isHidden = false
    }
    
    // MARK: -
    @objc func actionButtonHandler(_ button: UIButton) {
        if let buttonValue = listItem?.value as? KREButtonItemValue {
            buttonActionHandler?(buttonValue.button)
        }
    }
    
    @objc func actionImageViewHandler(_ button: UIButton) {
        if let imageValue = listItem?.value as? KREImageItemValue {
            buttonActionHandler?(imageValue.image)
        }
    }
        
    @objc func revealButtonHandler(_ button: UIButton) {
        revealButton.isSelected = !revealButton.isSelected
        showOrHideButtons()
        revealActionHandler?()
    }
    
    @objc func menuButtonActionHandler(_ button: UIButton) {
        var canShowButtons = buttonCollectionView.isHidden
        if let menuItemValue = listItem?.value as? KREMenuItemValue {
            if let menuButtons = menuItemValue.menuButtons {
                menuActionHandler?(menuButtons)
            }
        }
    }
        
    // MARK: - deinit
    deinit {
        
    }
}
