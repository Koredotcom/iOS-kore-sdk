//
//  KREStandardWidgetView.swift
//  KoreBotSDK
//
//  Created by Srinivas Vasadi on 05/01/2020.
//  Copyright © 2019 Srinivas Vasadi. All rights reserved.
//

import UIKit
import AFNetworking

// MARK: - KREStandardWidgetView
public class KREStandardWidgetView: KREWidgetView {
    // MARK: - properites
    let bundle = Bundle(for: KREStandardWidgetView.self)
    var elements: [KRECommonWidgetData]?

    public lazy var stackView: KREStackView = {
        let stackView = KREStackView(frame: .zero)
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.automaticallyHidesLastSeparator = true
        return stackView
    }()
    let noDataCellIdentifier = "KREWidgetNoDataTableViewCell"
    let loginCellIdentifier = "KREWidgetLoginTableViewCell"
    let widgetViewCellIdentifier = "KREGenericWidgetViewCell"
    let customWidgetCellIdentifier = "KRECustomWidgetViewCell"
    let customWidgetCircleCellIdentifier = "KRECustomWidgetCircleViewCell"
    let widgetHeaderViewIdentifier = "KREWidgetHeaderView"
    let widgetFooterViewIdentifier = "KREWidgetFooterView"
    let buttonTemplateCellIdentifier = "KREButtonTemplateCellIdentifier"
    
    // MARK: - init
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    // MARK: - setup
    func setup() {
        addSubview(stackView)
        
        let views = ["stackView": stackView]
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[stackView]|", options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[stackView]|", options: [], metrics: nil, views: views))
    }

    // MARK: -
    public override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return subviews.contains {
            !$0.isHidden && $0.point(inside: convert(point, to: $0), with: event)
        }
    }
        
    func getWidgets(forceReload: Bool = false, completion block: ((Bool) -> Void)? = nil) {
        guard let widget = widget else {
            return
        }
        
        KREWidgetManager.shared.fetchWidget(widget, forceReload: forceReload) { [weak self] (success) in
            DispatchQueue.main.async {
                self?.populateWidget()
                block?(success)
            }
        }
    }
    
    // MARK: -
    func populateWidget() {
        stackView.removeAllRows()
        switch widget?.widgetState {
        case .loading?:
            let cell = KRECustomWidgetView(frame: .zero)
            cell.translatesAutoresizingMaskIntoConstraints = false
            cell.loadingDataState()
            stackView.addRow(cell)
        case .loaded?, .refreshed?, .refreshing?:
            let numberOfRows = min(MAX_ELEMENTS + 1, elements?.count ?? 1)
            for index in 0..<numberOfRows {
                switch index {
                case 0..<MAX_ELEMENTS:
                    let element = elements?[index]
                    let cell = KRECustomWidgetView(frame: .zero)
                    cell.translatesAutoresizingMaskIntoConstraints = false
                    if let widgetData = element as? KRECommonWidgetData {
                        cell.loadedDataState()
                        cell.headingLabel.text = widgetData.title
                        cell.titleLabel.text = widgetData.sub_title
                        cell.descriptionLabel.text = widgetData.text
                        var titles = [String]()
                        for button in widgetData.button ?? [] {
                            titles.append(button.title ?? "")
                        }
                        if widgetData.button?.count ?? 0 > 0 {
                            cell.utterancesView.actions = widgetData.button ?? []
                            cell.utterancesView.isHidden = false
                        } else {
                            cell.utterancesView.isHidden = true
                        }
                        if let urlString = widgetData.icon, urlString != "url" {
                            let escapedString = urlString.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed) ?? ""
                            if let url = URL(string: escapedString) {
                                cell.profileImageView.contentMode = .scaleAspectFit
                                cell.profileImageView.setImageWith(url, placeholderImage: UIImage(named: "defaultSkillIcon"))
                                cell.profileImageView.isHidden = false
                            } else {
                                cell.profileImageView.isHidden = true
                            }
                        } else {
                            cell.profileImageView.isHidden = true
                        }
                        cell.profileImageView.layer.cornerRadius = 40.0
                        cell.profileImageView.clipsToBounds = true
                        if widgetData.actions?.count ?? 0 > 0 {
                            cell.moreButton.isHidden = false
                        } else {
                            cell.moreButton.isHidden = true
                        }
                        cell.utterancesView.utteranceClickAction = { [weak self] (action) in
                            self?.viewDelegate?.elementAction(for: action, in: self?.widget)
                        }
                        cell.moreSelectionHandler = { [weak self] (cell) in
                            self?.viewDelegate?.elementAction(for: widgetData, in: self?.widget)
                        }
                        
                        cell.profileImageView.backgroundColor = .clear
                        cell.layoutSubviews()
                        stackView.addRow(cell)
                        
                        guard let defaultAction = widgetData.defaultAction else {
                            continue
                        }

                        stackView.setTapHandler(forRow: cell) { [weak self] (view) in
                            self?.viewDelegate?.elementAction(for: defaultAction, in: self?.widget)
                        }
                    }
                default:
                    let buttonView = KREButtonView()
                    buttonView.translatesAutoresizingMaskIntoConstraints = false
                    buttonView.title = "View more"
                    stackView.addRow(buttonView)
                    
                    stackView.setTapHandler(forRow: buttonView) { [weak self] (view) in
                        self?.viewDelegate?.viewMoreElements(for: self?.widgetComponent, in: self?.widget)
                    }
                }
            }
        default:
            break
        }
        layoutSubviews()
    }
    
    // MARK: - KREWidgetView methods
    override public var widget: KREWidget? {
        didSet {

        }
    }
    
    override public var widgetComponent: KREWidgetComponent? {
        didSet {
            if let standardWidgetElements = widgetComponent?.elements as? [KRECommonWidgetData] {
                elements = standardWidgetElements
            } else {
                elements = nil
            }

            populateWidget()
        }
    }
    
    override public func startShimmering() {
        
    }
    
    override public func stopShimmering() {
        
    }
    
    override public func prepareForReuse() {
        super.prepareForReuse()
        widgetComponent = nil
        widget = nil
        populateWidget()
    }
}
