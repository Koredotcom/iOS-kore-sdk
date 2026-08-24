//
//  KREListWidgetView.swift
//  KoraApp
//
//  Created by Anoop Dhiman on 06/12/17.
//  Copyright © 2017 Kore. All rights reserved.
//

import UIKit
import Charts

public class KREListWidgetView: KREWidgetView {
    // MARK: - properites
    public lazy var stackView: KREStackView = {
        let stackView = KREStackView(frame: .zero)
        stackView.axis = .vertical
        stackView.separatorColor = .paleLilacFour
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.automaticallyHidesLastSeparator = true
        return stackView
    }()
    
    public var updateSubviews:(() -> Void)?
    var elements: [KREListItem]?
    
    public weak var widgetViewDelegate: KREWidgetViewDelegate?
    public var actionHandler:((KREAction) -> Void)?
    
    public var metrics: [String: CGFloat] = ["left": 15.0, "right": 10.0, "top": 0.0, "bottom": 0.0]

    // MARK: - init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        addSubview(stackView)
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(left)-[stackView]-(right)-|", options:[], metrics: metrics, views: ["stackView": stackView]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(top)-[stackView]-(bottom)-|", options:[], metrics: metrics, views: ["stackView": stackView]))
    }
        
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
                    let listView = KREListItemView(frame: .zero)
                    listView.translatesAutoresizingMaskIntoConstraints = false
                    if let listItem = element as? KREListItem {
                        listView.populateListItemView(listItem)
                        listView.buttonActionHandler = { [weak self] (action) in
                            self?.viewDelegate?.elementAction(for: action, in: self?.widget)
                        }
                        
                        listView.menuActionHandler = { [weak self] (actions) in
                            self?.viewDelegate?.populateActions(actions, in: self?.widget)
                        }

                        listView.revealActionHandler = { [weak self] in
                            self?.stackView.layoutIfNeeded()
                            self?.updateSubviews?()
                        }
                        
                        listView.layoutSubviews()
                        stackView.addRow(listView)

                        guard let defaultAction = listItem.defaultAction else {
                            continue
                        }

                        stackView.setTapHandler(forRow: listView) { [weak self] (listView) in
                            self?.viewDelegate?.elementAction(for: defaultAction, in: self?.widget)
                        }
                    }
                default:
                    let buttonView = KRESeeMoreView(frame: .zero)
                    buttonView.translatesAutoresizingMaskIntoConstraints = false
                    buttonView.title = "See more"
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
            if let listItems = widgetComponent?.elements as? [KREListItem] {
                elements = listItems
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
