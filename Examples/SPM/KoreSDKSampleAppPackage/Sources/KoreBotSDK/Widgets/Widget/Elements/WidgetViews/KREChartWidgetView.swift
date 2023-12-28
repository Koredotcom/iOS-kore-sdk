//
//  KREChartWidgetView.swift
//  KoraApp
//
//  Created by Anoop Dhiman on 06/12/17.
//  Copyright © 2017 Kore. All rights reserved.
//

import UIKit
import Charts

public class KREChartWidgetView: KREWidgetView {
    // MARK: - properites
    public lazy var tableView: KRETableView = {
        let tableView = KRETableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .whiteTwo
        tableView.separatorColor = .clear
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.alwaysBounceHorizontal = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isScrollEnabled = false
        tableView.layer.cornerRadius = 8.0
        return tableView
    }()
    
    var elements: [Decodable]?
    let pieChartViewCellIdentifier = "KREPieChartViewCell"
    let barChartViewCellIdentifier = "KREBarChartViewCell"
    let lineChartViewCellIdentifier = "KRELineChartViewCell"
    let widgetViewCellIdentifier = "KREWidgetViewCell"

    lazy var titleStrikeThroughAttributes: [NSAttributedString.Key: Any] = {
        return [.font: UIFont.textFont(ofSize: 14.0, weight: .bold), .foregroundColor: UIColor.blueyGrey]
    }()
    
    lazy var taskTitleAttributes: [NSAttributedString.Key: Any] = {
        return [.font: UIFont.textFont(ofSize: 14.0, weight: .bold), .foregroundColor: UIColor.gunmetal]
    }()
    
    public weak var widgetViewDelegate: KREWidgetViewDelegate?
    
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
        tableView.register(KREPieChartViewCell.self, forCellReuseIdentifier: pieChartViewCellIdentifier)
        tableView.register(KRELineChartViewCell.self, forCellReuseIdentifier: lineChartViewCellIdentifier)
        tableView.register(KREBarChartViewCell.self, forCellReuseIdentifier: barChartViewCellIdentifier)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: widgetViewCellIdentifier)
        addSubview(tableView)
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[tableView]|", options:[], metrics: nil, views: ["tableView": tableView]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[tableView]|", options:[], metrics: nil, views: ["tableView": tableView]))
    }
    
    func getWidgets(forceReload: Bool = false, completion block: ((Bool) -> Void)? = nil) {
        guard let widget = widget else {
            return
        }
        
        KREWidgetManager.shared.fetchWidget(widget, forceReload: forceReload) { [weak self] (success) in
            DispatchQueue.main.async {
                self?.reloadWidget()
                block?(success)
            }
        }
    }

    func populateWidget() {
        let widgetFilter = widget?.filters?.first
        widgetComponent = widgetFilter?.component
        tableView.reloadData()
    }

    func reloadWidget() {
        guard let widget = widget else {
            return
        }
        
        switch widget.widgetState {
        case .refreshing, .loading:
            break
        case .loaded, .refreshed:
            populateWidget()
        case .noData:
            break
        case .requestFailed:
            break
        case .noNetwork:
            break
        case .none:
            break
        }
    }
    
    // MARK: -
    func populatePieChartData(in cell: KREPieChartViewCell, with chartData: KREPieChartData) {
        // chartData population
        cell.templateView.populatePieChartData(chartData)
        cell.buttonCollectionView.buttonsLayout = chartData.buttonsLayout
        
        // buttons
        var canShowButtons: Bool = false
        if let buttons = chartData.buttons {
            cell.buttonCollectionView.actions = buttons
            canShowButtons = true
        }
        cell.buttonCollectionView.isHidden = !canShowButtons
    }

    // MARK: - KREWidgetView methods
    override public var widget: KREWidget? {
        didSet {
            getWidgets()
        }
    }

    override public var widgetComponent: KREWidgetComponent? {
        didSet {
            if let objects = widgetComponent?.elements {
                elements = objects
            } else {
                elements = nil
            }
            
            tableView.reloadData()
            layoutIfNeeded()
        }
    }
    
    override public func startShimmering() {
        
    }
    
    override public func stopShimmering() {
        
    }
    
    override public func prepareForReuse() {
        super.prepareForReuse()
        elements = nil
        tableView.reloadData()
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension KREChartWidgetView: UITableViewDelegate, UITableViewDataSource {
    // MARK: - UITableViewDataSource
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return min(MAX_ELEMENTS + 1, elements?.count ?? 0)
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var element = elements?[indexPath.row]
        switch widget?.templateType {
        case "piechart":
            let cell = tableView.dequeueReusableCell(withIdentifier: pieChartViewCellIdentifier, for: indexPath)
            if let cell = cell as? KREPieChartViewCell, let chartData = element as? KREPieChartData {
                populatePieChartData(in: cell, with: chartData)
                cell.buttonCollectionView.buttonAction = { [weak self] (buttonTemplate) in
                    self?.viewDelegate?.elementAction(for: buttonTemplate, in: self?.widget)
                }
            }
            
            cell.selectionStyle = .none
            cell.contentView.layoutSubviews()
            return cell
        case "linechart":
            let cell = tableView.dequeueReusableCell(withIdentifier: lineChartViewCellIdentifier, for: indexPath)
            if let cell = cell as? KRELineChartViewCell, let chartData = element as? KRELineChartData {
                cell.templateView.populateLineChart(chartData)
            }
            
            cell.selectionStyle = .none
            cell.contentView.layoutSubviews()
            return cell
        case "barchart":
            let cell = tableView.dequeueReusableCell(withIdentifier: barChartViewCellIdentifier, for: indexPath)
            if let cell = cell as? KREBarChartViewCell, let chartData = element as? KREBarChartData {
                cell.templateView.populateChartData(chartData)
            }
            
            cell.selectionStyle = .none
            cell.contentView.layoutSubviews()
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: widgetViewCellIdentifier, for: indexPath)
            return cell
        }
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    // MARK: - UITableViewDelegateSource
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
}
