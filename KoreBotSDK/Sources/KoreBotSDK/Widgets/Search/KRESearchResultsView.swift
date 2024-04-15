//
//  KRESearchResultsView.swift
//  KoreBotSDK
//
//  Created by Srinivas Vasadi on 06/01/2020.
//  Copyright © 2019 Srinivas Vasadi. All rights reserved.
//

import UIKit

public enum KRESearchResultsViewType: Int {
    case trim, full
}

public class KRESearchResultsView: UIView {
    // MARK: - properties
    let bundle = Bundle.sdkModule
    let knowledgetCollectionIdentifier = "KREKnowledgeCollectionElementViewCell"
    let knowledgetElementIdentifier = "KREKnowledgeElementViewCell"
    let meetingNotesElementIdentifier = "KREMeetingNotesElementViewCell"
    let driveFileElementIdentifier = "KREDriveFileElementViewCell"
    let emailComponentIdentifier = "KREEmailComponentViewCell"
    let skillElementIdentifier = "KRESkillElementViewCell"
    let cellIdentifier = "UITableViewCell"
    let headerViewIdentifier = "KRESearchResultHeaderView"
    let footerViewIdentifier = "KRESearchResultFooterView"
    let authFooterViewIdentifier = "SkillAuthorizationFooterView"
    let kMaxRowHeight: CGFloat = 84.0
    let kMinimumElements = 1
    var resultsViewType = KRESearchResultsViewType.trim {
        didSet {
            updateSearchResultsView(with: resultsViewType)
        }
    }
    
    let titleAttributes = [NSAttributedString.Key.font: UIFont.textFont(ofSize: 13.0, weight: .medium), NSAttributedString.Key.foregroundColor: UIColor.charcoalGrey, .kern: 2.0] as [NSAttributedString.Key : Any]
    let subTitleAttributes = [NSAttributedString.Key.font: UIFont.textFont(ofSize: 13.0, weight: .medium), NSAttributedString.Key.foregroundColor: UIColor.battleshipGrey, .kern: -0.15] as [NSAttributedString.Key : Any]

    public var result: KRESearchResult? {
        didSet {
            tableView.reloadData()
            invalidateIntrinsicContentSize()
        }
    }
    
    public var optionsButtonAction:((_ title: String?, _ payload: String?) -> Void)?

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .equalCentering
        stackView.alignment = .fill
        stackView.spacing = 0.0
        return stackView
    }()
    
    public lazy var tableView: KRETableView = {
        let tableView = KRETableView(frame: CGRect.zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.singleLine
        tableView.separatorInset = .zero
        tableView.separatorColor = .lightGreyBlue
        return tableView
    }()
    
    public var viewMoreAction:((KRESearchResult?) -> Void)?
    public var elementAction:((KRESearchResultElement?, KRESearchResult?) -> Void)?
    public var elementDidSelectAction:((Decodable?, KRESearchResultType) -> Void)?
    public var elementDidSelectActionKnowledgeCollection:((KREKnowledgeCollectionElementData?, KRESearchResult?) -> Void)?

    // MARK: - init
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        
        tableView.register(KREKnowledgeCollectionElementViewCell.self, forCellReuseIdentifier: knowledgetCollectionIdentifier)
        tableView.register(KREKnowledgeElementViewCell.self, forCellReuseIdentifier: knowledgetElementIdentifier)
        tableView.register(KREMeetingNotesElementViewCell.self, forCellReuseIdentifier: meetingNotesElementIdentifier)
        tableView.register(KREDriveFileElementViewCell.self, forCellReuseIdentifier: driveFileElementIdentifier)
        tableView.register(KREEmailComponentViewCell.self, forCellReuseIdentifier: emailComponentIdentifier)
        tableView.register(KRESkillComponentTableViewCell.self, forCellReuseIdentifier: skillElementIdentifier)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.register(KRESearchResultHeaderView.self, forHeaderFooterViewReuseIdentifier: headerViewIdentifier)
        tableView.register(KRESearchResultFooterView.self, forHeaderFooterViewReuseIdentifier: footerViewIdentifier)
        tableView.register(SkillAuthorizationFooterView.self, forHeaderFooterViewReuseIdentifier: authFooterViewIdentifier)
        stackView.addArrangedSubview(tableView)
        addSubview(stackView)
        
        let views = ["stackView": stackView]
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[stackView]|", options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[stackView]|", options: [], metrics: nil, views: views))
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
        
        updateSearchResultsView(with: resultsViewType)
    }
    
    func updateSearchResultsView(with type: KRESearchResultsViewType) {
        switch type {
        case .full:
            tableView.isScrollEnabled = true
            tableView.showsVerticalScrollIndicator = true
            tableView.showsHorizontalScrollIndicator = true
        case .trim:
            tableView.isScrollEnabled = false
            tableView.showsVerticalScrollIndicator = false
            tableView.showsHorizontalScrollIndicator = false
        }
    }
    
    public func getExpectedHeight() -> CGFloat {
        var height: CGFloat = 0.0
        for section in 0..<tableView.numberOfSections {
            var fittingSize = UIView.layoutFittingCompressedSize
            for row in 0..<tableView.numberOfRows(inSection: section) {
                let cell = tableView(tableView, cellForRowAt: IndexPath(row: row, section: section))
                let size = cell.systemLayoutSizeFitting(fittingSize, withHorizontalFittingPriority: .defaultLow, verticalFittingPriority: .defaultHigh)
                height += size.height
            }
            if let headerView = tableView(tableView, viewForHeaderInSection: section) {
                let size = headerView.systemLayoutSizeFitting(fittingSize)
                height += size.height
            }
            
            if let count = result?.elements?.count, count > 0, section == count - 1 {
                if let footerView = tableView(tableView, viewForFooterInSection: section) {
                    let size = footerView.systemLayoutSizeFitting(fittingSize)
                    height += size.height
                }
            }
        }
        return height
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate methods
extension KRESearchResultsView: UITableViewDataSource, UITableViewDelegate {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return result?.elements?.count ?? 0
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let searchResultElement = result?.elements?[section] else {
            return 0
        }
        switch resultsViewType {
        case .full:
            if let elements = searchResultElement.elements {
                return searchResultElement.elements?.count ?? 0
            } else if let knowledgeCollElement = searchResultElement.knowledgeCollElement as? KREKnowledgeCollectionElement {
                return  (knowledgeCollElement.definitive?.count ?? 0) + (knowledgeCollElement.suggestive?.count ?? 0)
            } else {
                return 0
            }

        case .trim:
            if let elements = searchResultElement.elements {
                return min(kMinimumElements, searchResultElement.elements?.count ?? 0)
            } else if let knowledgeCollElement = searchResultElement.knowledgeCollElement as? KREKnowledgeCollectionElement {
                return min(kMinimumElements, (knowledgeCollElement.definitive?.count ?? 0) + (knowledgeCollElement.suggestive?.count ?? 0))
            } else {
                return 0
            }
        }
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let element = result?.elements?[indexPath.section] else {
            return tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        }
        switch element.resultType {
        case .knowledgeCollection:
            return configureKnowledgeCollectionViewCell(for: indexPath, with: element)
        case .article:
            return configureKnowledgeElementViewCell(for: indexPath, with: element)
        case .email:
            return configureEmailComponentViewCell(for: indexPath, with: element)
        case .files:
            return configureDriveFileElementViewCell(for: indexPath, with: element)
        case .meetingNotes:
            return configureMeetingNotesElementViewCell(for: indexPath, with: element)
        case .skill:
            return configureSkillElementViewCell(for: indexPath, with: element)
        case .none:
            return tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        }
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let element = result?.elements?[section]
        return configureHeaderView(for: section, with: element)
    }
    
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let element = result?.elements?[section]
        return configureFooterView(for: section, with: element)
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let resultElement = result?.elements?[indexPath.section] else {
            return
        }
        
        switch resultElement.resultType {
        case .knowledgeCollection:
            if let knowledgeCollElement = resultElement.knowledgeCollElement as? KREKnowledgeCollectionElement {
                if  indexPath.row <= (knowledgeCollElement.definitive?.count ?? 0) - 1 {
                    if let definitive = knowledgeCollElement.definitive?[indexPath.row] {
                        self.elementDidSelectActionKnowledgeCollection?(definitive, self.result)
                    }
                } else if (knowledgeCollElement.definitive?.count ?? 0) == 0 {
                    if let suggestive = knowledgeCollElement.suggestive?[(indexPath.row)] {
                        self.elementDidSelectActionKnowledgeCollection?(suggestive, self.result)
                    }
                } else if let suggestive = knowledgeCollElement.suggestive?[(indexPath.row % (knowledgeCollElement.definitive?.count ?? 0))] {
                    self.elementDidSelectActionKnowledgeCollection?(suggestive, self.result)
                }
            }
        default:
            if let element = resultElement.elements?[indexPath.row] {
                elementDidSelectAction?(element, resultElement.resultType)
            }
        }
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        switch resultsViewType {
        case .full:
            return CGFloat.leastNormalMagnitude
        case .trim:
            guard let count = result?.elements?.count, count > 0, section == count - 1 else {
                return CGFloat.leastNormalMagnitude
            }
            if let searchElement = result?.elements {
                if checkSeeAllResult(elements: searchElement) {
                    return UITableView.automaticDimension
                } else {
                    return CGFloat.leastNormalMagnitude
                }
            }
            return UITableView.automaticDimension
        }
    }
    
    func checkSeeAllResult(elements: [KRESearchResultElement]) -> Bool {
        var check = false
        for element in elements {
            if element.elements?.count ?? 0 > 1 {
                check = true
                break
            }
            if let knowCollectionElement = element.knowledgeCollElement as? KREKnowledgeCollectionElement {
                if knowCollectionElement.definitive?.count ?? 0 > 0 && knowCollectionElement.suggestive?.count ?? 0 > 0 {
                    check = true
                    break
                }
            }
        }
        return check
    }
    
    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return kMaxRowHeight
    }
    
    public func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 38.0
    }
    
    public func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        switch resultsViewType {
        case .full:
            return CGFloat.leastNormalMagnitude
        case .trim:
            guard let count = result?.elements?.count, count > 0, section == count - 1 else {
                return CGFloat.leastNormalMagnitude
            }
            return 38.0
        }
    }
}

// MARK: - configure cells
extension KRESearchResultsView {
    func configureKnowledgeCollectionViewCell(for indexPath: IndexPath, with resultElement: KRESearchResultElement) -> UITableViewCell {
        let knowledgeCollectionViewCell = tableView.dequeueReusableCell(withIdentifier: knowledgetCollectionIdentifier, for: indexPath)
        guard let element = resultElement.knowledgeCollElement as? KREKnowledgeCollectionElement
            , let cell = knowledgeCollectionViewCell as? KREKnowledgeCollectionElementViewCell else {
                return knowledgeCollectionViewCell
        }
        if  indexPath.row <= (element.definitive?.count ?? 0) - 1 {
            if let definitive = element.definitive?[indexPath.row] {
                cell.templateView.suggestedStackView.isHidden = true
                cell.templateView.populateTemplateView(definitive)
            }
        } else {
            if (element.definitive?.count ?? 0) == 0 {
                cell.templateView.suggestedStackView.isHidden = false
                if let suggestive = element.suggestive?[(indexPath.row)] {
                    cell.templateView.populateTemplateView(suggestive)
                }
            } else if let suggestive = element.suggestive?[(indexPath.row % (element.definitive?.count ?? 0))] {
                cell.templateView.suggestedStackView.isHidden = false
                cell.templateView.populateTemplateView(suggestive)
            }
        }
        return knowledgeCollectionViewCell
    }
    
    func mergeKnowledgeCollection(element: KREKnowledgeCollectionElement) {
        
    }
    
    func configureKnowledgeElementViewCell(for indexPath: IndexPath, with resultElement: KRESearchResultElement) -> UITableViewCell {
        let knowledgeElementViewCell = tableView.dequeueReusableCell(withIdentifier: knowledgetElementIdentifier, for: indexPath)
        guard let element = resultElement.elements?[indexPath.row],
            let cell = knowledgeElementViewCell as? KREKnowledgeElementViewCell else {
                return knowledgeElementViewCell
        }
        cell.knowledgeFooterView.isHidden = true
        cell.templateView.populateTemplateView(element)
        return cell
    }
    
    func configureMeetingNotesElementViewCell(for indexPath: IndexPath, with resultElement: KRESearchResultElement) -> UITableViewCell {
        let knowledgeCollectionViewCell = tableView.dequeueReusableCell(withIdentifier: meetingNotesElementIdentifier, for: indexPath)
        guard let element = resultElement.elements?[indexPath.row],
            let cell = knowledgeCollectionViewCell as? KREMeetingNotesElementViewCell else {
                return knowledgeCollectionViewCell
        }
        cell.templateView.populateTemplateView(element, totalElementCount: resultElement.elements?.count ?? 0)
        return cell
    }
    
    func configureSkillElementViewCell(for indexPath: IndexPath, with resultElement: KRESearchResultElement) -> UITableViewCell {
        let knowledgeCollectionViewCell = tableView.dequeueReusableCell(withIdentifier: skillElementIdentifier, for: indexPath)
        guard let element = resultElement.elements?[indexPath.row],
            let cell = knowledgeCollectionViewCell as? KRESkillComponentTableViewCell else {
                return knowledgeCollectionViewCell
        }
        cell.templateView.populateTemplateView(element, totalElementCount: resultElement.elements?.count ?? 0)
        return cell
    }

    func configureDriveFileElementViewCell(for indexPath: IndexPath, with resultElement: KRESearchResultElement) -> UITableViewCell {
        let driveFileElementViewCell = tableView.dequeueReusableCell(withIdentifier: driveFileElementIdentifier, for: indexPath)
        guard let element = resultElement.elements?[indexPath.row] as? KADriveFileInfo,
            let cell = driveFileElementViewCell as? KREDriveFileElementViewCell else {
            return driveFileElementViewCell
        }
        
        cell.templateView.populateTemplateView(element)
        return cell
    }
    
    func configureEmailComponentViewCell(for indexPath: IndexPath, with resultElement: KRESearchResultElement) -> UITableViewCell {
        let emailComponentViewCell = tableView.dequeueReusableCell(withIdentifier: emailComponentIdentifier, for: indexPath)
        guard let element = resultElement.elements?[indexPath.row] as? KAEmailCardInfo,
            let cell = emailComponentViewCell as? KREEmailComponentViewCell else {
                return emailComponentViewCell
        }
        cell.templateView.configure(with: element)
        return cell
    }
    
    func configureHeaderView(for section: Int, with resultElement: KRESearchResultElement?) -> UITableViewHeaderFooterView? {
        let headerAndFooterView = tableView.dequeueReusableHeaderFooterView(withIdentifier: headerViewIdentifier)
        guard let headerView = headerAndFooterView as? KRESearchResultHeaderView,
            let element = resultElement else {
                return headerAndFooterView
        }
        
        headerView.contentView.backgroundColor = .paleGrey
        headerView.iconImageView.backgroundColor = .clear
        headerView.titleLabel.backgroundColor = .clear
        
        let identity = profileIdentity(for: element)
        headerView.iconImageView.setProfileImage(for: identity, initials: true)

        headerView.titleLabel.attributedText = NSAttributedString(string: element.title?.uppercased() ?? "", attributes: titleAttributes)
        guard let searchResultElement = result?.elements?[section] else {
            return headerView
        }
        var moreText = ""
        switch element.resultType {
        case .knowledgeCollection:
             if let knowledgeCollElement = searchResultElement.knowledgeCollElement as? KREKnowledgeCollectionElement {
                let count = (knowledgeCollElement.definitive?.count ?? 0) + (knowledgeCollElement.suggestive?.count ?? 0) - 1
                if count == 0 {
                    moreText = ""
                    headerView.disclosureButton.isHidden = true
                } else {
                    moreText = "\(count) more"
                    headerView.disclosureButton.isHidden = false
                }
             }
        default:
            if (searchResultElement.count ?? 0) <= 1 {
                moreText == ""
                headerView.disclosureButton.isHidden = true
            } else {
                moreText = "\((searchResultElement.count ?? 0) - 1) more"
                headerView.disclosureButton.isHidden = false
            }
        }

        switch resultsViewType {
        case .full:
            headerView.disclosureButton.isHidden = true
        case .trim:
            headerView.subTitleLabel.attributedText = NSAttributedString(string: "\(moreText)", attributes: subTitleAttributes)
            headerView.tapGestureHandler = { [weak self] in
                self?.elementAction?(element, self?.result)
            }
        }
        return headerView
    }
    
    func configureFooterView(for section: Int, with resultElement: KRESearchResultElement?) -> UITableViewHeaderFooterView? {
        var footerView:KRESearchResultFooterView!
        if let result = result {
            if let authReq = result.isAuthRequired, authReq {
                footerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: authFooterViewIdentifier) as? SkillAuthorizationFooterView
                (footerView as? SkillAuthorizationFooterView)?.result = result
            }
            else {
                footerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: footerViewIdentifier) as? KRESearchResultFooterView
            }
        }
        footerView.setup()
        footerView.titleLabel.backgroundColor = .clear
        let titleAttributes = [NSAttributedString.Key.font: UIFont.textFont(ofSize: 12.0, weight: .medium), NSAttributedString.Key.foregroundColor: UIColor.battleshipGrey, .kern: 0.0] as [NSAttributedString.Key : Any]

        let text = NSLocalizedString("See All Results", comment: "See All Results")
        footerView.titleLabel.attributedText = NSAttributedString(string: text, attributes: titleAttributes)
        footerView.contentView.backgroundColor = .white
        footerView.tapGestureHandler = { [weak self] in
            self?.viewMoreAction?(self?.result)
        }
        return footerView
    }
    
    // MARK: -
    func profileIdentity(for element: KRESearchResultElement) -> KREIdentity {
        var color: String?
        var unicode = "\u{2d}"
        var imageUrl: String?
        
        switch element.resultType {
        case .meetingNotes:
            unicode = "\u{2d}"
            color = UIColor.cornflower.hex
        case .knowledgeCollection:
            unicode = "\u{e913}"
            color = UIColor.orangish.hex
        case .article:
            unicode = "\u{e91a}"
            color = UIColor.orangish.hex
        case .email:
            unicode = "\u{e95d}"
            color = UIColor.greenblue.hex
        case .files:
            unicode = "\u{e93d}"
            color = UIColor.aquaMarine.hex
        case .none:
            unicode = "\u{e926}"
            color = UIColor.greenblue.hex
        case .skill:
            unicode = "\u{e926}"
            color = UIColor.green.hex
            if var urlString = element.icon, var serverURL = KREWidgetManager.shared.user?.server {
                serverURL.removeLast()
                serverURL += urlString
                imageUrl = serverURL
            }
        }
        
        let identity = KREIdentity()
        identity.color = color
        identity.initials = unicode
        identity.imageUrl = imageUrl
        identity.font = UIFont.systemSymbolFont(ofSize: 15.0)
        return identity
    }
}

// MARK: - KRESearchResultHeaderView
public class KRESearchResultHeaderView: UITableViewHeaderFooterView {
    // MARK: - properties
    let bundle = Bundle.sdkModule
    
    public lazy var titleLabel: UILabel = {
        let titleLabel = UILabel(frame: .zero)
        titleLabel.textColor = .charcoalGrey
        titleLabel.numberOfLines = 0
        titleLabel.backgroundColor = .clear
        titleLabel.font = UIFont.textFont(ofSize: 13.0, weight: .regular)
        titleLabel.textAlignment = .left
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.sizeToFit()
        titleLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        return titleLabel
    }()
    
    public lazy var subTitleLabel: UILabel = {
        let subTitleLabel = UILabel(frame: .zero)
        subTitleLabel.textColor = .charcoalGrey
        subTitleLabel.numberOfLines = 0
        subTitleLabel.backgroundColor = .clear
        subTitleLabel.font = UIFont.textFont(ofSize: 13.0, weight: .regular)
        subTitleLabel.textAlignment = .left
        subTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subTitleLabel.sizeToFit()
        subTitleLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        return subTitleLabel
    }()

    public lazy var disclosureButton: UIButton = {
        let disclosureButton = UIButton(frame: .zero)
        disclosureButton.translatesAutoresizingMaskIntoConstraints = false
        let image = UIImage(named: "disclose", in: bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        disclosureButton.setImage(image, for: .normal)
        disclosureButton.tintColor = .lightGreyBlue
        disclosureButton.isUserInteractionEnabled = false
        return disclosureButton
    }()
    
    public lazy var iconImageView: KREIdentityImageView = {
        let iconImageView = KREIdentityImageView(frame: .zero)
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.contentMode = .scaleAspectFill
        return iconImageView
    }()
    
    public var tapGestureHandler:(() -> Void)?

    // MARK: - init
    override public init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override public func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        subTitleLabel.text = nil
    }
    
    // MARK: - setup
    func setup() {
        contentView.backgroundColor = .paleGrey
        contentView.addSubview(titleLabel)
        contentView.addSubview(subTitleLabel)
        contentView.addSubview(disclosureButton)
        contentView.addSubview(iconImageView)
        
        let views: [String: Any] = ["titleLabel": titleLabel, "iconImageView": iconImageView, "disclosureButton": disclosureButton, "subTitleLabel": subTitleLabel]
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[titleLabel(>=18)]-|", options: [], metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[subTitleLabel(>=18)]-|", options: [], metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-8-[iconImageView]-[titleLabel]-(4@250)-[subTitleLabel][disclosureButton]-2-|", options: [], metrics: nil, views: views))

        titleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        subTitleLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        subTitleLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)

        disclosureButton.widthAnchor.constraint(equalToConstant: 22.0).isActive = true
        disclosureButton.heightAnchor.constraint(equalToConstant: 22.0).isActive = true
        disclosureButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true

        iconImageView.widthAnchor.constraint(equalToConstant: 22.0).isActive = true
        iconImageView.heightAnchor.constraint(equalToConstant: 22.0).isActive = true
        iconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGestureRecognizer(_:)))
        addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func handleTapGestureRecognizer(_ sender: UITapGestureRecognizer) {
        tapGestureHandler?()
    }
}

// MARK: - KRESearchResultFooterView
public class KRESearchResultFooterView: UITableViewHeaderFooterView {
    // MARK: - properties
    let bundle = Bundle.sdkModule
    var verticalConstraints:[NSLayoutConstraint]?
    public lazy var seeAllResultsView: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    public lazy var titleLabel: UILabel = {
        let titleLabel = UILabel(frame: .zero)
        titleLabel.textColor = .charcoalGrey
        titleLabel.numberOfLines = 0
        titleLabel.backgroundColor = .clear
        titleLabel.font = UIFont.textFont(ofSize: 13.0, weight: .regular)
        titleLabel.textAlignment = .left
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.sizeToFit()
        titleLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        return titleLabel
    }()
    
    public lazy var disclosureButton: UIButton = {
        let disclosureButton = UIButton(frame: .zero)
        disclosureButton.translatesAutoresizingMaskIntoConstraints = false
        let image = UIImage(named: "disclose", in: bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        disclosureButton.setImage(image, for: .normal)
        disclosureButton.tintColor = .lightGreyBlue
        disclosureButton.isUserInteractionEnabled = false
        return disclosureButton
    }()
    
    public lazy var lineView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = UIColor.paleLilacFour
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    public var tapGestureHandler:(() -> Void)?
    
    // MARK: - init
    override public init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
//        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
//        setup()
    }
    
    override public func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
    }
    
    // MARK: - setup
    func setup() {
        contentView.backgroundColor = .white

        seeAllResultsView.addSubview(lineView)
        seeAllResultsView.addSubview(titleLabel)
        seeAllResultsView.addSubview(disclosureButton)
        contentView.addSubview(seeAllResultsView)

        let topViews: [String: Any] = ["seeAllResultsView": seeAllResultsView]
        verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[seeAllResultsView]|", options: [], metrics: nil, views: topViews)
        contentView.addConstraints(verticalConstraints!)
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[seeAllResultsView]|", options: [], metrics: nil, views: topViews))

        let views: [String: Any] = ["lineView": lineView, "titleLabel": titleLabel, "disclosureButton": disclosureButton]
        seeAllResultsView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[lineView]-6-[titleLabel(>=18)]-6-|", options: [], metrics: nil, views: views))
        seeAllResultsView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[titleLabel]-4-[disclosureButton]-2-|", options: [], metrics: nil, views: views))
        seeAllResultsView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[lineView]|", options: [], metrics: nil, views: views))

        titleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        disclosureButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        disclosureButton.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)

        disclosureButton.widthAnchor.constraint(equalToConstant: 22.0).isActive = true
        disclosureButton.heightAnchor.constraint(equalToConstant: 22.0).isActive = true
        disclosureButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor).isActive = true
        
        lineView.heightAnchor.constraint(equalToConstant: 1.0).isActive = true
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleShowMoreTapGestureRecognizer(_:)))
        seeAllResultsView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func handleShowMoreTapGestureRecognizer(_ sender: UITapGestureRecognizer) {
        tapGestureHandler?()
    }
}

public class SkillAuthorizationFooterView : KRESearchResultFooterView {
    public var result:KRESearchResult? = nil
    public lazy var authorizationView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = UIColor.init(hexString: "f6f6f8")
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    public lazy var authTitleLabel: UILabel = {
        let titleLabel = UILabel(frame: .zero)
        titleLabel.textColor = .charcoalGrey
        titleLabel.numberOfLines = 0
        titleLabel.backgroundColor = .clear
        titleLabel.font = UIFont.textFont(ofSize: 13.0, weight: .regular)
        titleLabel.textAlignment = .left
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.sizeToFit()
        titleLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        return titleLabel
    }()
    public lazy var authDiscloseButton: UIButton = {
        let disclosureButton = UIButton(frame: .zero)
        disclosureButton.translatesAutoresizingMaskIntoConstraints = false
        let image = UIImage(named: "disclose", in: bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        disclosureButton.setImage(image, for: .normal)
        disclosureButton.tintColor = .lightGreyBlue
        //        disclosureButton.isUserInteractionEnabled = false
        return disclosureButton
    }()
    public lazy var authLineView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = UIColor.paleLilacFour
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    public lazy var iconLabel: UILabel = {
        let iconLabel = UILabel(frame: .zero)
        iconLabel.font = UIFont.systemSymbolFont(ofSize: 17.0)
        iconLabel.textAlignment = .left
        iconLabel.text = "\u{e926}"
        iconLabel.textColor = .white
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        return iconLabel
    }()
    
    public lazy var iconView: UIView = {
        let iconView = UIView(frame: .zero)
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.backgroundColor = .red
        return iconView
    }()
    @objc func handleAuthTapGestureRecognizer(_ sender: UITapGestureRecognizer) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ShowSkillAuthorization"), object: nil)
    }
    
    override func setup() {
        super.setup()
        
        iconView.addSubview(iconLabel)
        iconView.layer.cornerRadius = 11.0
        iconView.layer.masksToBounds = false
        authorizationView.addSubview(iconView)
        
        authorizationView.addSubview(authLineView)
        authorizationView.addSubview(authDiscloseButton)
        authorizationView.addSubview(authTitleLabel)
        contentView.addSubview(authorizationView)
        if let auth = result?.isAuthRequired {
            if auth {
                authTitleLabel.text = result?.expiryMsg
                let topViews: [String: Any] = ["seeAllResultsView": seeAllResultsView, "authorizationView": authorizationView]
                if verticalConstraints != nil {
                    contentView.removeConstraints(verticalConstraints!)
                }
                verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-[seeAllResultsView]-5-[authorizationView]|", options: [], metrics: nil, views: topViews)
                contentView.addConstraints(verticalConstraints!)
                contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[authorizationView]|", options: [], metrics: nil, views: topViews))
                let authviews: [String: Any] = ["iconView": iconView, "authLineView": authLineView, "authTitleLabel": authTitleLabel, "authDiscloseButton": authDiscloseButton]
                authorizationView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[authLineView(1)]-10-[authTitleLabel(>=10)]-10-|", options: [], metrics: nil, views: authviews))
//                authorizationView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[iconView]-|", options: [], metrics: nil, views: authviews))
                authorizationView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[iconView]-10-[authTitleLabel]-4-[authDiscloseButton]-2-|", options: [], metrics: nil, views: authviews))
                authorizationView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[authLineView]|", options: [], metrics: nil, views: authviews))
                
                authDiscloseButton.widthAnchor.constraint(equalToConstant: 22.0).isActive = true
                authDiscloseButton.heightAnchor.constraint(equalToConstant: 22.0).isActive = true
                authDiscloseButton.centerYAnchor.constraint(equalTo: authTitleLabel.centerYAnchor).isActive = true
                let tapAuthGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleAuthTapGestureRecognizer(_:)))
                authorizationView.addGestureRecognizer(tapAuthGestureRecognizer)

                iconView.widthAnchor.constraint(equalToConstant: 22.0).isActive = true
                iconView.heightAnchor.constraint(equalToConstant: 22.0).isActive = true
                iconView.centerYAnchor.constraint(equalTo: authorizationView.centerYAnchor).isActive = true

//                iconLabel.widthAnchor.constraint(equalToConstant: 50.0).isActive = true
//                iconLabel.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
                iconLabel.centerXAnchor.constraint(equalTo: iconView.centerXAnchor).isActive = true
                iconLabel.centerYAnchor.constraint(equalTo: iconView.centerYAnchor).isActive = true
                
            }
        }
    }
}
