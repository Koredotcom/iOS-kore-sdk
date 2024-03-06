//
//  KREChartListWidgetView.swift
//  KoreBotSDK
//
//  Created by Srinivas Vasadi on 05/01/2020.
//  Copyright © 2019 Srinivas Vasadi. All rights reserved.
//

import UIKit

// MARK: - KREChartListWidgetView
public class KREChartListWidgetView: KREWidgetView {
    // MARK: - properites
    let bundle = Bundle.sdkModule
    var isScrolling: Bool = false
    
    public lazy var tableView: KRETableView = {
        let tableView = KRETableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = UIColor.clear
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.alwaysBounceHorizontal = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.bounces = false
        tableView.isScrollEnabled = false
        tableView.separatorColor = .clear
        tableView.tableFooterView = UIView(frame: .zero)
        return tableView
    }()

    public override var MAX_ELEMENTS: Int {
        return 2
    }
    let widgetViewCellIdentifier = "KREWidgetViewCell"
    let customWidgetCircleCellIdentifier = "KRECustomWidgetCircleViewCell"
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
        tableView.register(KREButtonTemplateCell.self, forCellReuseIdentifier: buttonTemplateCellIdentifier)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: widgetViewCellIdentifier)
        tableView.register(KRECustomWidgetDashboardTableViewCell.self, forCellReuseIdentifier: customWidgetCircleCellIdentifier)
        addSubview(tableView)
        
        let views = ["tableView": tableView]
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[tableView]|", options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[tableView]|", options: [], metrics: nil, views: views))
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
                self?.reloadWidget(widget)
                block?(success)
            }
        }
    }
    
    func reloadWidget(_ widget: KREWidget?) {
        guard let widget = widget else {
            return
        }
        
        switch widget.widgetState {
        case .loaded, .refreshed:
            tableView.reloadData()
        case .refreshing, .loading:
            tableView.reloadData()
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
    
    func scrollToTop() {
        let indexPath = IndexPath(row: 0, section: 0)
        guard indexPath.section < tableView.numberOfSections,
            indexPath.row < tableView.numberOfRows(inSection: indexPath.section) else {
            return
        }

        tableView.scrollToRow(at: indexPath, at: .top, animated: false)
    }
    
    // MARK: -
    func populateWidget() {
        reloadWidget(widget)
    }

    // MARK: - KREWidgetView methods
    override public var widget: KREWidget? {
        didSet {
            getWidgets()
            reloadWidget(widget)
            scrollToTop()
        }
    }
    
    override public var widgetComponent: KREWidgetComponent? {
        didSet {
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
        tableView.reloadData()
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension KREChartListWidgetView: UITableViewDelegate, UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = widgetComponent?.elements?.count ?? 0
        return 1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cellIdentifier = customWidgetCircleCellIdentifier
        switch widget?.widgetState {
        case .loading?:
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
            if let _ = cell as? KRECustomWidgetDashboardTableViewCell {

            }
            return cell
        case .loaded?, .refreshed?, .refreshing?:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
                let element = widgetComponent?.elements?[indexPath.row]
                if let cell = cell as? KRECustomWidgetDashboardTableViewCell, let widgetData = element as? KRECommonWidgetData {
                    cell.bubbleView.bottomSheetData = widgetComponent?.elements
                    cell.bubbleView.layoutIfNeeded()
                    cell.bubbleView.layoutSubviews()
                }
                cell.layoutSubviews()
                return cell
            default:
                cellIdentifier = buttonTemplateCellIdentifier
                let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
                if let cell = cell as? KREButtonTemplateCell {
                    cell.title = NSLocalizedString("View more", comment: "View more")
                }
                cell.layoutSubviews()
                return cell
            }
        default:
            cellIdentifier = widgetViewCellIdentifier
            return tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        }
    }

    @objc func buttonAction(_ sender: UIButton) {

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
