//
//  KREWidgetsViewController.swift
//  KoreBotSDK
//
//  Created by Srinivas Vasadi on 06/03/19.
//  Copyright © 2019 Srinivas Vasadi. All rights reserved.
//

import UIKit
import CoreData
import SafariServices

public enum SectionType: Int {
    case weather = 0, widgets = 1
}

public protocol KREWidgetsViewControllerDelegate: class {
    func didUpdateProgress(for widget: KREWidget)
    func updateWidget(_ widget: KREWidget)
    func actionFromWidget(controller: UIViewController)
}

open class KREWidgetsViewController: UIViewController {
    // MARK: - properties
    let bundle = Bundle.sdkModule
    let widgetCellIdentifier = "KREWidgetBubbleCell"
    let maxWidgetElements = 4
    var shouldScrollToBottom: Bool = false
    var clearBackground = false
    var shouldReload: Bool = true
    public var server: String?
    
    public var panelId: String? {
        didSet {
            populatePanelItem()
        }
    }
    
    public weak var delegate: KREGenericWidgetViewDelegate? {
        didSet {
            summaryWidgetView.delegate = delegate
        }
    }
    
    public var requestHandler:((KREWidget, KREWidgetsViewControllerDelegate?) -> Void)?
    
    public lazy var summaryWidgetView: KRESummaryWidgetView = {
        let widgetView = KRESummaryWidgetView(frame: .zero)
        widgetView.backgroundColor = .clear
        widgetView.translatesAutoresizingMaskIntoConstraints = false
        return widgetView
    }()
        
    // MARK: -
    open override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.paleGrey
        
        setup()
        populatePanelItem()
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadWidgets(_:)), name: NSNotification.Name(rawValue: "ReloadWidgets"), object: nil)
    }

    @objc func reloadWidgets(_ notification: Notification) {
        if notification.object != nil {
            self.summaryWidgetView.collectionView.reloadData()
        } else {
            refreshPanelItem(forceReload: true)
        }
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshPanelItem(forceReload: true)
    }
    
    // MARK: -
    func setup() {                
        view.addSubview(summaryWidgetView)
        
        let views = ["widgetView": summaryWidgetView]
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[widgetView]|", options: [], metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[widgetView]|", options: [], metrics: nil, views: views))
    }
    
    public func populatePanelItem() {
        let widgetManager = KREWidgetManager.shared
        let panelItem = widgetManager.getPanelItem(with: panelId)
        summaryWidgetView.panelId = panelItem?.id
    }
    
    // MARK: -
    func refreshPanelItem(forceReload: Bool) {
        let widgetManager = KREWidgetManager.shared
        let panelItem = widgetManager.getPanelItem(with: panelId)
        guard let panelId = panelItem?.iconId else {
            return
        }
                
        summaryWidgetView.getWidgets(forceReload: forceReload)
    }
    
    // MARK: - deinit
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - KREWidgetBubbleViewDelegate
extension KREWidgetsViewController: KREWidgetBubbleViewDelegate {
    public func refreshWidget(_ widget: KREWidget) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let refreshActionTitle = NSLocalizedString("Refresh", comment: "Refresh")
        let refreshAction = UIAlertAction(title: refreshActionTitle, style: .default, handler: { [weak self] (action) in
            KREWidgetManager.shared.getWidget(widget) { (success, component, error) in
                
            }
        })
        alertController.addAction(refreshAction)
        
        let cancelActionTitle = NSLocalizedString("Cancel", comment: "Cancel")
        let cancelAction = UIAlertAction(title: cancelActionTitle, style: .cancel, handler: { (action) in
            
        })
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
}

// MARK: - KRESafariViewController
open class KRESafariViewController: SFSafariViewController, SFSafariViewControllerDelegate {
    // MARK: - properties
    @objc public var customData: [String: Any]?
    var dismissBlock: (([String: Any]?) -> (Void))?
    
    // MARK:  view life-cycle
    override open func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
    }
    
    // MARK: SFSafariViewControllerDelegate methods
    public func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        let options = customData
        dismissBlock?(options)
    }
    
    public func safariViewController(_ controller: SFSafariViewController, didCompleteInitialLoad didLoadSuccessfully: Bool) {
        
    }
}

// MARK: - KREWidgetFooterView
class KREWidgetFooterView: UITableViewHeaderFooterView {
    // MARK: - properties
    var editButton: UIButton = {
        var editButton = UIButton(frame: .zero)
        editButton.layer.cornerRadius = 4.0
        editButton.layer.borderColor = UIColor.lightRoyalBlue.cgColor
        editButton.layer.borderWidth = 2.0
        editButton.titleLabel?.font = UIFont.textFont(ofSize: 15, weight: .medium)
        editButton.setTitleColor(UIColor.lightRoyalBlue, for: .normal)
        editButton.setTitle("Edit", for: .normal)
        editButton.translatesAutoresizingMaskIntoConstraints = false
        return editButton
    }()
    
    // MARK: -
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        // content View
        let marginGuide = contentView.layoutMarginsGuide
        contentView.backgroundColor = .white
        
        // title label
        contentView.addSubview(editButton)
        editButton.layer.shadowColor = UIColor.charcoalGrey2.withAlphaComponent(0.16).cgColor
        editButton.layer.borderColor = UIColor.lightRoyalBlue.cgColor
        editButton.layer.cornerRadius = 4.0
        editButton.layer.shadowRadius = 7.0
        editButton.layer.masksToBounds = false
        editButton.layer.borderWidth = 2.0
        editButton.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        editButton.layer.shadowOpacity = 0.7
        let views: [String: Any] = ["editButton": editButton]
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-2-[editButton(44)]-31-|", options: [], metrics: nil, views: views))
        
        editButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor, constant: 0.0).isActive = true
        editButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 0.0).isActive = true
        editButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}


