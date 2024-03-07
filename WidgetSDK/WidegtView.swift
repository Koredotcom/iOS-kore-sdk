//
//  WidegtView.swift
//  KoreBotSDK
//
//  Created by Kartheek Pagidimarri on 27/06/23.
//  Copyright © 2023 Kore. All rights reserved.
//

import UIKit
import AVFoundation
public protocol WidgetViewDelegate {
    func didselectWidegtView(item:KREPanelItem?)
}
public class WidegtView: UIView {
    public var viewDelegate: WidgetViewDelegate?
    var launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    var panelCollectionView: KAPanelCollectionView!
    public var sheetController: KABottomSheetController?
    var insets: UIEdgeInsets = .zero
    public var maxPanelHeight: CGFloat {
        var maxHeight = UIScreen.main.bounds.height
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        let delta: CGFloat = 15.0
        maxHeight -= statusBarHeight
        maxHeight -= delta
        return maxHeight
    }
    
    public var panelHeight: CGFloat {
        var maxHeight = maxPanelHeight
        maxHeight -= self.bounds.height - insets.bottom + 70.0
        return maxHeight
    }

    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupViews()
    }
    
    fileprivate func setupViews() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.processDynamicUpdates(_:)), name: KoraNotification.Widget.update.notification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.processPanelEvents(_:)), name: KoraNotification.Panel.event.notification, object: nil)
        
        
        self.configurePanelCollectionView()
        self.populatePanelItems()
        
    }
    
    func configurePanelCollectionView() {
        
        self.panelCollectionView = KAPanelCollectionView()
        self.panelCollectionView?.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.panelCollectionView!)
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[panelCollectionView]|", options:[], metrics:nil, views:["panelCollectionView" : self.panelCollectionView!]))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[panelCollectionView]|", options:[], metrics:nil, views:["panelCollectionView" : self.panelCollectionView!]))
        
        self.panelCollectionView.onPanelItemClickAction = { (item) in
        }
        
        self.panelCollectionView.retryAction = { [weak self] in
            self?.populatePanelItems()
        }
        
        self.panelCollectionView.panelItemHandler = { [weak self] (item, block) in
            self?.viewDelegate?.didselectWidegtView(item: item)
//            guard let weakSelf = self else {
//                return
//            }
//
//            switch item?.type {
//            case "action":
//                weakSelf.processActionPanelItem(item)
//            default:
//                if #available(iOS 11.0, *) {
//                    self?.insets = UIApplication.shared.delegate?.window??.safeAreaInsets ?? .zero
//                }
//                var inputViewHeight = 0.0
//                inputViewHeight = inputViewHeight + (self?.insets.bottom ?? 0.0) + (self?.bounds.height)!
//                let sizes: [SheetSize] = [.fixed(0.0), .fixed(weakSelf.panelHeight)]
//                if weakSelf.sheetController == nil {
//                    let panelItemViewController = KAPanelItemViewController()
//                    panelItemViewController.panelId = item?.id
//                    panelItemViewController.dismissAction = { [weak self] in
//                        self?.sheetController = nil
//                    }
//                    self.view.endEditing(true)
//
//                    let bottomSheetController = KABottomSheetController(controller: panelItemViewController, sizes: sizes)
//                    bottomSheetController.inputViewHeight = CGFloat(inputViewHeight)
//                    bottomSheetController.willSheetSizeChange = { [weak self] (controller, newSize) in
//                        switch newSize {
//                        case .fixed(weakSelf.panelHeight):
//                            controller.overlayColor = .clear
//                            panelItemViewController.showPanelHeader(true)
//                        default:
//                            controller.overlayColor = .clear
//                            panelItemViewController.showPanelHeader(false)
//                            bottomSheetController.closeSheet(true)
//
//                            self?.sheetController = nil
//                        }
//                    }
//                    bottomSheetController.modalPresentationStyle = .overCurrentContext
//                    weakSelf.present(bottomSheetController, animated: true, completion: block)
//                    weakSelf.sheetController = bottomSheetController
//                } else if let bottomSheetController = weakSelf.sheetController,
//                          let panelItemViewController = bottomSheetController.childViewController as? KAPanelItemViewController {
//                    panelItemViewController.panelId = item?.id
//
//                    if bottomSheetController.presentingViewController == nil {
//                        weakSelf.present(bottomSheetController, animated: true, completion: block)
//                    } else {
//                        block?()
//                    }
//                }
//            }
        }
    }
        func populatePanelItems() {
            let widgetManager = KREWidgetManager.shared
            panelCollectionView.startAnimating()
            widgetManager.getPanelItems { [weak self] (success, items, error) in
                DispatchQueue.main.async {
                    self!.panelCollectionView.stopAnimating(error)
                    guard let panelItems = items as? [KREPanelItem] else {
                        return
                    }
                    
                    self?.showHomePanel(completion: {
                        
                    })
                    //KoraApplication.sharedInstance.account?.validateTimeZone()
                    self!.panelCollectionView.items = panelItems
                    widgetManager.getPriorityWidgets(from: panelItems, block: nil)
                    NotificationCenter.default.post(name: KoraNotification.Panel.update.notification, object: nil)
                    
                    if let _ = error  {
                        
                    }
                }
            }
        }
        
        @objc func processDynamicUpdates(_ notification: Notification?) {
            guard let dictionary = notification?.object as? [String: Any],
                  let type = dictionary["t"] as? String, let _ = dictionary["uid"] as? String else {
                return
            }
            
            switch type {
            case "kaa":
                let panelItems = self.panelCollectionView.items
                guard let panelItem = panelItems?.filter({ $0.iconId == "announcement" }).first else {
                    return
                }
                
                let widgetManager = KREWidgetManager.shared
                widgetManager.getWidgets(in: panelItem, forceReload: true, update: { [weak self] (success, widget) in
                    DispatchQueue.main.async {
                        self?.updatePanel(with: panelItem)
                    }
                }, completion: nil)
            default:
                break
            }
        }
        
        @objc func processPanelEvents(_ notification: Notification?) {
            guard let dictionary = notification?.object as? [String: Any],
                  let type = dictionary["entity"] as? String else {
                return
            }
            
            switch type {
            case "panels":
                populatePanelItems()
                if let data = dictionary["data"] as? [String: Any] {
                    KREWidgetManager.shared.pinOrUnpinWidget(data)
                }
            default:
                break
            }
        }
        
        public func showHomePanel(_ isOnboardingInProgress: Bool = false, completion block:(()->Void)? = nil) {
            let panelItems = KREWidgetManager.shared.panelItems
            guard launchOptions == nil else {
                return
            }
            
            let panelBar = panelCollectionView
            switch panelBar!.panelState {
            case .loaded:
                guard let panelItem = panelItems?.filter({ $0.name == "Quick Summar" }).first else {
                    return
                }
                
                panelCollectionView.panelItemHandler?(panelItem) { [weak self] in
                    if !isOnboardingInProgress {
                        self?.startTryOut()
                    }
                    block?()
                }
                
            default:
                break
            }
        }
        
        func updatePanel(with panelItem: KREPanelItem) {
            guard let panelItemViewController = sheetController?.childViewController as? KAPanelItemViewController else {
                return
            }
            
            panelItemViewController.updatePanel(with: panelItem)
        }
        // MARK: - tryout
        public func startTryOut() {
            
        }
        // MARK: -
        func processActionPanelItem(_ item: KREPanelItem?) {
            if let uriString = item?.action?.uri, let url = URL(string: uriString + "?teamId=59196d5a0dd8e3a07ff6362b") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }


}
