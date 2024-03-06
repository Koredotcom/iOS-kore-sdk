//
//  KREImageTemplate.swift
//  KoreBotSDK
//
//  Created by Srinivas Vasadi on 13/03/19.
//  Copyright © 2019 Srinivas Vasadi. All rights reserved.
//

import UIKit

public class KREListItemsViewController: UIViewController {
    // MARK: - properties
    let bundle = Bundle.sdkModule
    let widgetCellIdentifier = "KREWidgetViewCell"
    let listItemViewCellIdentifier = "KREListItemViewCell"
    public var widget: KREWidget?
    public var panelItem: KREPanelItem?
    public weak var delegate: KREGenericWidgetViewDelegate?
    
    public var widgetComponent: KREWidgetComponent? {
        didSet {
            tableView.reloadData()
        }
    }
    
    public var metrics: [String: CGFloat] = ["left": 15.0, "right": 10.0, "top": 0.0, "bottom": 0.0]

    public lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.separatorColor = .lightGreyBlue
        tableView.backgroundColor = .white
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        tableView.separatorColor = .lightGreyBlue
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        view.addSubview(tableView)
        
        let views = ["tableView": tableView]
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(left)-[tableView]-(right)-|", options: [], metrics: metrics, views: views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(top)-[tableView]-(bottom)-|", options: [], metrics: metrics, views: views))

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: widgetCellIdentifier)
        tableView.register(KREListItemViewCell.self, forCellReuseIdentifier: listItemViewCellIdentifier)
        
        setNavigationBarItems()
    }
    
    // MARK: -
    func updateSubviews() {
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    // MARK: -
    func setNavigationBarItems() {
        let image = UIImage(named: "backIcon", in: bundle, compatibleWith: nil)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(closeButtonAction))
        navigationItem.leftBarButtonItem?.tintColor = UIColor.gunmetal
        navigationController?.navigationBar.barTintColor = UIColor.white
    }
    
    @objc func closeButtonAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension KREListItemsViewController: UITableViewDataSource, UITableViewDelegate {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return widgetComponent?.elements?.count ?? 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = listItemViewCellIdentifier
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        if let cell = cell as? KREListItemViewCell, let listItem = widgetComponent?.elements?[indexPath.row] as? KREListItem {
            let listView = cell.templateView
            listView.populateListItemView(listItem)
            listView.buttonActionHandler = { [weak self] (action) in
                self?.delegate?.elementAction(for: action, in: self?.widget, in: self?.panelItem)
                self?.dismiss(animated: false, completion: nil)
            }
            
            listView.menuActionHandler = { [weak self] (actions) in
                self?.delegate?.populateActions(actions, in: self?.widget, in: self?.panelItem)
            }

            listView.revealActionHandler = { [weak self] in
                self?.updateSubviews()
            }
        }
        return cell
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let listItem = widgetComponent?.elements?[indexPath.row] as? KREListItem else {
            return
        }
        
        if let action = listItem.defaultAction {
            delegate?.elementAction(for: action, in: widget, in: panelItem)
            self.dismiss(animated: false, completion: nil)
        }
    }
}
