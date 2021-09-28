//
//  KAPanelItemViewController.swift
//  KoraSDK
//
//  Created by Srinivas Vasadi on 13/11/19.
//  Copyright © 2019 Srinivas Vasadi. All rights reserved.
//

import UIKit
import KoreBotSDK
import AlamofireImage

public class KAFullPanelView : UIView {
    
    var isAbleToTouchLower = true
    var disableTouchesToAllSubviews = false
    override public func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        
        if disableTouchesToAllSubviews {
            return nil
        }
        
        if let view = super.hitTest(point, with: event) {
            if isAbleToTouchLower && view == self { return nil }
            return view
        }
        return nil
    }
}


public class KAPanelItemViewController: UIViewController {
    // MARK: - properties
    let bundle = Bundle(for: KAPanelItemViewController.self)
    let serverUrl = SDKConfiguration.serverConfig.JWT_SERVER
    lazy var stackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.axis = .vertical
        stackView.distribution = UIStackView.Distribution.fill
        stackView.alignment = UIStackView.Alignment.fill
        stackView.spacing = 6.0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    lazy var contentView: UIView = {
        let contentView = UIView(frame: .zero)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        return contentView
    }()
    public lazy var panelHeader: KAPanelHeaderView = {
        var panelHeader = KAPanelHeaderView(frame: .zero)
        panelHeader.translatesAutoresizingMaskIntoConstraints = false
        return panelHeader
    }()
    lazy var widgetViewControllerDelegate: KREWidgetViewControllerDelegate = {
        let widgetViewControllerDelegate = KREWidgetViewControllerDelegate()
        return widgetViewControllerDelegate
    }()
        
    public var panelId: String? {
        didSet {
            let widgetManager = KREWidgetManager.shared
            panelItem = widgetManager.getPanelItem(with: panelId)
        }
    }
    private var panelItem: KREPanelItem? {
        didSet {
            if panelItem?.widgets?.count ?? 0 > 1 {
                panelHeader.reoderButton.isHidden = false
            } else {
                panelHeader.reoderButton.isHidden = true
            }
            populatePanelItem()
        }
    }
    public weak var widgetViewDelegate: KREGenericWidgetViewDelegate?
    public lazy var widgetsViewController = KAWidgetsViewController()
    public var onPushAction:(() -> Void)? {
        didSet {
            panelItemNavigationController?.onPushAction = onPushAction
        }
    }
    public var onPopAction:(() -> Void)? {
        didSet {
            panelItemNavigationController?.onPopAction = onPopAction
        }
    }
    public var dismissAction:(() -> Void)?
    
    weak var panelItemNavigationController: KAPanelItemNavigationController?
   // weak var account = KoraApplication.sharedInstance.account

    // MARK: - viewcontroller life-cycle
    
    override open func loadView() {
        self.view = KAFullPanelView(frame: UIScreen.main.bounds)
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        setup()
        
        addWidgetsViewController()
        
        NotificationCenter.default.addObserver(self, selector: #selector(closePanel(_:)), name: NSNotification.Name(rawValue: "ClosePanel"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(processPanelUpdates(_:)), name: KoraNotification.Panel.update.notification, object: nil)
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: -
    func setup() {
        view.backgroundColor = UIColor.clear
        
        view.addSubview(stackView)
        view.addSubview(contentView)
        
        let views : [String: Any] = ["stackView": stackView, "contentView": contentView]
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[stackView]|", options: [], metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[contentView]|", options: [], metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat:"V:|[stackView][contentView]|", options: [], metrics: nil, views: views))
        
        stackView.addArrangedSubview(panelHeader)
    }
    
    func populatePanelItem() {
        if let iconId = panelItem?.iconId, let image = UIImage(named: iconId + "Panel", in: bundle, compatibleWith: nil) {
            panelHeader.iconImageView.contentMode = .center
            panelHeader.iconImageView.image = image
        } else if let urlString = panelItem?.icon, urlString != "url", let url = URL(string: urlString) {
//            panelHeader.iconImageView.setImageWith(URLRequest(url: url), placeholderImage: UIImage(named: "done_icon", in: bundle, compatibleWith: nil), success: { (urlRequest, response, image) in
//                self.panelHeader.iconImageView.contentMode = .scaleAspectFill
//                self.panelHeader.iconImageView.image = image
//                self.panelIconMask(self.panelHeader.iconImageView)
//            }) { (urlRequest, response, error) in
//
//            }
            panelHeader.iconImageView.contentMode = .scaleAspectFit
            panelHeader.iconImageView.af.setImage(withURL: url, placeholderImage: UIImage(named: "done_icon", in: bundle, compatibleWith: nil))
        }

        if let color = panelItem?.theme {
            panelHeader.iconImageView.backgroundColor = UIColor(hexString: color)
        } else {
            panelHeader.iconImageView.backgroundColor = .lightGreyBlue
        }
        panelHeader.titleLabel.text = panelItem?.name
        panelHeader.closeButton.addTarget(self, action: #selector(closeButtonAction(_:)), for: .touchUpInside)
        panelHeader.reoderButton.addTarget(self, action: #selector(editButtonAction(_:)), for: .touchUpInside)

        panelHeader.actionHandler = { [weak self] in
            self?.closeButtonAction()
        }
        
        widgetsViewController.panelId = panelItem?.id
        panelItemNavigationController?.popToRootViewController(animated: true)
    }
    
    func panelIconMask(_ forView:UIView) {
        let path = UIBezierPath.init(roundedRect: forView.bounds, cornerRadius: forView.bounds.height/2)
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.fillRule = CAShapeLayerFillRule.evenOdd
        forView.layer.mask = shapeLayer
    }
    
    func updatePanel(with item: KREPanelItem?) {
        guard item?.panelId == panelItem?.id else {
            return
        }
        
        panelItem = item
    }
        
    func addWidgetsViewController() {
        widgetsViewController.delegate = widgetViewControllerDelegate
        
        let navigationController = KAPanelItemNavigationController(rootViewController: widgetsViewController)
        navigationController.onPushAction = onPushAction
        navigationController.onPopAction = onPopAction
        navigationController.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController.navigationBar.shadowImage = UIImage()
        navigationController.navigationBar.isTranslucent = false
        navigationController.navigationBar.isHidden = true
        addChild(navigationController)
        
        let currentView: UIView = navigationController.view
        currentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(currentView)
        
        let views: [String: Any] = ["currentView": navigationController.view]
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[currentView]|", options: [], metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[currentView]|", options: [], metrics: nil, views: views))
        
        navigationController.view.layoutIfNeeded()
        view.layoutSubviews()
        
        panelItemNavigationController = navigationController
        widgetViewControllerDelegate.navigationController = navigationController
        widgetViewControllerDelegate.targetViewController = self
    }
    
    public func showPanelHeader(_ show: Bool) {

    }
    
    // MARK: -
    
    @objc func closePanel(_ notification:Notification) {
        closeButtonAction(nil)
    }
    
    @objc func closeButtonAction(_ sender: UIButton? = nil) {
        dismiss(animated: false, completion: nil)
        dismissAction?()
    }
    
    @objc func editButtonAction(_ sender: UIButton? = nil) {
        //widgetViewControllerDelegate.editButtonAction(in: panelItem)
    }

    @objc func processPanelUpdates(_ notification: Notification?) {
        widgetsViewController.panelId = panelItem?.id
    }
    
    // MARK: - deinit
    deinit {

    }
}

// MARK: -
internal class KAPanelItemNavigationController: UINavigationController {
    // MARK: - properties
    public var onPushAction:(() -> Void)?
    public var onPopAction:(() -> Void)?

    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        onPushAction?()
        return super.pushViewController(viewController, animated: animated)
    }
    
    override func popViewController(animated: Bool) -> UIViewController? {
        onPopAction?()
        return super.popViewController(animated: animated)
    }
}
