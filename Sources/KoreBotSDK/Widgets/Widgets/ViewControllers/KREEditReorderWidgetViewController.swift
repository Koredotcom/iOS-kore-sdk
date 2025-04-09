
//  KREReorderWidgetViewController.swift
//  KoreBotSDK
//
//  Created by Sukhmeet Singh on 29/05/19.
//

import UIKit

open class KREEditReorderWidgetViewController: UIViewController {
    // MARK: -
    let bundle = Bundle.sdkModule
    public var widgets = [KREWidget]()
    lazy var loaderView: KRELoaderView = {
        var loaderView = KRELoaderView(frame: .zero)
        loaderView.translatesAutoresizingMaskIntoConstraints = false
        loaderView.isHidden = false
        loaderView.lineWidth = 2.0
        loaderView.tintColor = UIColor.lightRoyalBlue
        return loaderView
    }()
    public var panelItem: KREPanelItem?
    var doneBarButtonItem: UIBarButtonItem?
    var widgetReorderImage: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.backgroundColor = .white
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    public var panelId: String?
    var parameters: [String: Any]?
    lazy var reOrderTitleView: UIView = {
        let titleView = UIView(frame: .zero)
        titleView.backgroundColor = UIColor.clear
        titleView.translatesAutoresizingMaskIntoConstraints = false
        return titleView
    }()
    var reorderImageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.backgroundColor = .white
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    lazy var widgetLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.backgroundColor = UIColor.clear
        label.textColor = UIColor.lightGreyBlue
        label.clipsToBounds = true
        label.text = NSLocalizedString("Hold and drag", comment: "Hold and drag")
        label.font = UIFont.systemFont(ofSize: 14.0, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    lazy var widgetLabelContinuation: UILabel = {
        let label = UILabel(frame: .zero)
        label.backgroundColor = UIColor.clear
        label.textColor = UIColor.lightGreyBlue
        label.clipsToBounds = true
        label.text = NSLocalizedString("to reorder widgets", comment: "to reorder widgets")
        label.font = UIFont.systemFont(ofSize: 14.0, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    lazy private var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.separatorColor = UIColor.lightGreyBlue
        tableView.backgroundColor = .white
        tableView.bounces = false
        tableView.isEditing = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.preservesSuperviewLayoutMargins = false
        tableView.separatorInset = UIEdgeInsets.zero
        tableView.layoutMargins = UIEdgeInsets.zero
        return tableView
    }()
    
    public var reorderIds = [String]()
    lazy var titleAttributes: [NSAttributedString.Key: Any] = {
        return [.font: UIFont.textFont(ofSize: 17.0, weight: .regular), .foregroundColor: UIColor.black, .kern: 1.0]
    }()
    
    var reorderWidget:((_ element: Any?) -> Void)?
    
    // MARK: -
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        tableView.register(KREReOrderWidgetTitleCell.self, forCellReuseIdentifier: "KREReOrderWidgetTitleCell")
        view.addSubview(tableView)
        
        widgetReorderImage.image = UIImage(named: "undrawTask", in: bundle, compatibleWith: nil)
        view.addSubview(widgetReorderImage)
        
        view.addSubview(reOrderTitleView)
        reorderImageView.image = UIImage(named: "move", in: bundle, compatibleWith: nil)
        reOrderTitleView.addSubview(reorderImageView)
        reOrderTitleView.addSubview(widgetLabel)
        reOrderTitleView.addSubview(widgetLabelContinuation)
        
        let reOrderTitleViews = ["widgetLabel": widgetLabel, "reorderImageView": reorderImageView, "widgetLabelContinuation": widgetLabelContinuation]
        reOrderTitleView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[widgetLabel]|", options:[], metrics: nil, views: reOrderTitleViews))
        reOrderTitleView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[reorderImageView]|", options:[], metrics: nil, views: reOrderTitleViews))
        reOrderTitleView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[widgetLabelContinuation]|", options:[], metrics: nil, views: reOrderTitleViews))
        
        reOrderTitleView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[widgetLabel]-[reorderImageView]-[widgetLabelContinuation]", options:[], metrics: nil, views: reOrderTitleViews))
        reorderImageView.widthAnchor.constraint(equalToConstant: 24.0).isActive = true
        //        widgetLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -16.0).isActive = true
        
        let views = ["widgetReorderImage": widgetReorderImage, "tableView": tableView, "reOrderTitleView": reOrderTitleView]
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[widgetReorderImage(175)]-16-[reOrderTitleView]-21-[tableView]", options:[], metrics:nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[tableView]|", options:[], metrics:nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[reOrderTitleView]|", options:[], metrics:nil, views: views))
        
        let topSpacing: CGFloat = 21.0
        if #available(iOS 11, *) {
            let guide = view.safeAreaLayoutGuide
            widgetReorderImage.topAnchor.constraint(equalTo: guide.topAnchor, constant: topSpacing).isActive = true
            tableView.bottomAnchor.constraint(equalTo: guide.bottomAnchor).isActive = true
        } else {
            widgetReorderImage.topAnchor.constraint(equalTo: topLayoutGuide.topAnchor, constant: topSpacing).isActive = true
            tableView.bottomAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor).isActive = true
        }
        
        widgetReorderImage.widthAnchor.constraint(equalToConstant: 188.0).isActive = true
        widgetReorderImage.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0.0).isActive = true
        setupNavigationItems()
        for widget in widgets {
            if widget.title?.count == 0 {
                widgets = widgets.filter{$0 != widget}
                reorderIds = reorderIds.filter{$0 != widget._id}
            }
        }
    }
    
    override open func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
    }
    
    // MARK: -
    func setupNavigationItems() {
        let image = UIImage(named: "backIcon", in: bundle, compatibleWith: nil)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(closeButtonAction))
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.gunmetal
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        doneBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(doneAction(_:)))
        doneBarButtonItem?.isEnabled = false
        doneBarButtonItem?.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.textFont(ofSize: 16.0, weight: .bold), NSAttributedString.Key.foregroundColor: UIColor.lightRoyalBlue], for: UIControl.State.normal)
        self.navigationItem.rightBarButtonItem = doneBarButtonItem
    }
    
    @objc func doneAction(_ sender: UIButton) {
        let driveManager = KREDriveListManager()
        if reorderIds.count > 0 {
            if let panelId = panelId, let parameters = self.parameters {
                driveManager.panelWidgetLayot(parameters: parameters, panelId: panelId , with: { [weak self] (status, componentElements) in
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ReloadWidgets"), object: self?.reorderIds)
                        self?.reorderPanelItem(reorderIds: self?.reorderIds ?? [])
                        self?.closeButtonAction()
                    }
                })
            }
        }
    }
    
    func reorderPanelItem(reorderIds: [String]) {
        var widgets = [KREWidget]()
        widgets.removeAll()
            for object in (reorderIds ?? []) {
                if let widget = self.panelItem?.widgets?.filter({$0._id == object }).first { widgets.append(widget)
                }
            }
            if let widgetsPanel = self.panelItem?.widgets {
                for widget in widgetsPanel {
                    if !widgets.contains(widget) {
                        widgets.insert(widget, at: 0)
                    }
                }
            }
        self.panelItem?.widgets = widgets
    }
    
    @objc func closeButtonAction() {
        if isModal {
            dismiss(animated: true, completion: nil)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    // MARK: -
    func updateSortOrder() {
        
    }
}

extension KREEditReorderWidgetViewController: UITableViewDelegate, UITableViewDataSource {
    open func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return widgets.count
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "KREReOrderWidgetTitleCell", for: indexPath)
        if let reorderCell = cell as? KREReOrderWidgetTitleCell, let widget = widgets[indexPath.row] as? KREWidget {
            reorderCell.informationLabel.attributedText = NSMutableAttributedString(string: widget.title ?? "" , attributes: titleAttributes)
        }
        return cell
    }
    
    open func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let widget = widgets[indexPath.row]
        if widget.templateType == "SystemHealth" {
            return false
        } else {
            return true
        }
    }
    
    open func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    open func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    open func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        var reorderCompare = reorderIds
        let movedObject = self.reorderIds[sourceIndexPath.row]
        reorderIds.remove(at: sourceIndexPath.row)
        reorderIds.insert(movedObject, at: destinationIndexPath.row)
        parameters = ["sortOrder": reorderIds]
        if reorderCompare != reorderIds {
            doneBarButtonItem?.isEnabled = true
        } 
        updateSortOrder()
    }
    
    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let widget = widgets[indexPath.row]
        switch widget.templateType {
        case "SystemHealth":
            return CGFloat.leastNormalMagnitude
        default:
            return UITableView.automaticDimension
        }
    }
    
    open func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    open func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    open func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    open  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0
    }
    
    open  func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0
    }
}

// MARK: - KREReOrderWidgetTitleCell
class KREReOrderWidgetTitleCell: UITableViewCell {
    var informationLabel: UILabel = {
        let informationLabel: UILabel = UILabel(frame: .zero)
        informationLabel.translatesAutoresizingMaskIntoConstraints = false
        informationLabel.textAlignment = .center
        informationLabel.textColor = UIColor.coolGrey
        return informationLabel
    }()
    
    // MARK: - init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    // MARK: - setup
    func setup() {
        backgroundColor = UIColor.white
        contentView.addSubview(informationLabel)
        
        let informationLabelLeadingConstraint = NSLayoutConstraint(item: informationLabel, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1.0, constant: 15.0)
        informationLabelLeadingConstraint.priority = .defaultHigh
        
        let informationLabelTrailingConstraint = NSLayoutConstraint(item: informationLabel, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1.0, constant: 0.0)
        informationLabelTrailingConstraint.priority = .defaultLow
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-16-[informationLabel]-15-|", options: [], metrics: nil, views: ["informationLabel": informationLabel]))
        contentView.addConstraints([informationLabelLeadingConstraint, informationLabelTrailingConstraint])
    }
}
