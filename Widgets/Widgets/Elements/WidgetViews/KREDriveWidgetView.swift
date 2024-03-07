//
//  KREDriveWidgetView.swift
//  KoreBotSDK
//
//  Created by Srinivas Vasadi on 05/01/2020.
//  Copyright © 2019 Srinivas Vasadi. All rights reserved.
//

import UIKit

// MARK: - KREDriveWidgetView
public class KREDriveWidgetView: KREWidgetView {
    // MARK: - properites
    public lazy var tableView: KRETableView = {
        let tableView = KRETableView(frame: .zero, style: .plain)
        tableView.backgroundColor = UIColor.clear
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.alwaysBounceHorizontal = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isScrollEnabled = false
        tableView.layer.cornerRadius = 8.0
        tableView.tableFooterView = UIView(frame: .zero)
        return tableView
    }()

    var elements: [KREDriveFileInfo]?
    let documentInformationCellIdentifier = "KREDocumentInformationCell"
    let widgetViewCellIdentifier = "KREWidgetViewCell"
    let buttonTemplateCellIdentifier = "KREButtonTemplateCellIdentifier"

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
        tableView.register(KREDocumentInformationCell.self, forCellReuseIdentifier: documentInformationCellIdentifier)
        tableView.register(KREButtonTemplateCell.self, forCellReuseIdentifier: buttonTemplateCellIdentifier)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: widgetViewCellIdentifier)
        addSubview(tableView)
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[tableView]|", options:[], metrics: nil, views: ["tableView": tableView]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[tableView]|", options:[], metrics: nil, views: ["tableView": tableView]))
    }

    // MARK: - KREWidgetView methods
    override public var widget: KREWidget? {
        didSet {
            
        }
    }
    
    override public var widgetComponent: KREWidgetComponent? {
        didSet {
            if let fileSearchElements = widgetComponent?.elements as? [KREDriveFileInfo] {
                elements = fileSearchElements
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
        widgetComponent = nil
        widget = nil
        tableView.reloadData()
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension KREDriveWidgetView: UITableViewDelegate, UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = elements?.count ?? 0
        switch widgetViewType {
        case .trim:
            return min(MAX_ELEMENTS + 1, count)
        case .full:
            return count
        }
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var element = elements?[indexPath.row]
        var cellIdentifier = documentInformationCellIdentifier
        var templateType = KRETemplateType.fileSearch
        
        switch widgetViewType {
        case .trim:
            switch indexPath.row {
            case 0..<MAX_ELEMENTS:
                let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
                if let cell = cell as? KREDocumentInformationCell, let driveFileInfo = element as? KREDriveFileInfo {
                    cell.cardView.driveFileObject = driveFileInfo
                    cell.cardView.configure(with: driveFileInfo)
                    cell.selectionStyle = .none
                }
                cell.layoutSubviews()
                return cell
            default:
                let cellIdentifier = buttonTemplateCellIdentifier
                let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
                if let cell = cell as? KREButtonTemplateCell {
                    cell.title = NSLocalizedString("View more", comment: "View more")
                }
                cell.layoutSubviews()
                return cell
            }
        case .full:
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
            if let cell = cell as? KREDocumentInformationCell, let driveFileInfo = element as? KREDriveFileInfo {
                cell.cardView.driveFileObject = driveFileInfo
                cell.cardView.configure(with: driveFileInfo)
                cell.selectionStyle = .none
            }
            cell.layoutSubviews()
            return cell
        }
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch widgetViewType {
        case .trim:
            switch indexPath.row {
            case 0..<MAX_ELEMENTS:
                if let element = elements?[indexPath.row] {
                    viewDelegate?.elementAction(for: element, in: widget)
                }
            default:
                viewDelegate?.viewMoreElements(for: widgetComponent, in: widget)
            }
        case .full:
            if let element = elements?[indexPath.row] {
                viewDelegate?.elementAction(for: element, in: widget)
            }
        }
    }
    
    // MARK: - UITableViewDelegateSource
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
}

// MARK: - KRETableView
public class KRETableView: UITableView {
    override public var contentSize: CGSize {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }

    override public var intrinsicContentSize: CGSize {
        layoutIfNeeded()
        let size = CGSize(width: UIView.noIntrinsicMetric, height: contentSize.height)
        return size
    }
}
