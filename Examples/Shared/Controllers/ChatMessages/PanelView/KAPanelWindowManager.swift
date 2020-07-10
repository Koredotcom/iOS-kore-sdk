//
//  KAPanelWindowManager.swift
//  KoraSDK
//
//  Created by Srinivas Vasadi on 29/10/19.
//  Copyright © 2019 Srinivas Vasadi. All rights reserved.
//

import UIKit
import KoreBotSDK

public class KAPanelWindowManager {
    public var panelContainerWindow: KAPanelContainerWindow?
    public static let shared = KAPanelWindowManager()

    var panelFrame: CGRect {
        set {
            let rootViewController = panelContainerWindow?.rootViewController
            guard let sheetController = rootViewController as? BottomSheetController else {
                return
            }
        }
        get {
            let rootViewController = panelContainerWindow?.rootViewController
            guard let sheetController = rootViewController as? BottomSheetController else {
                return .zero
            }
            
            let containerView = sheetController.containerView
            return containerView.frame
        }
    }
    
    public func changeKeyWindow(rootViewController: UIViewController?) {
        if let rootViewController = rootViewController {
            panelContainerWindow = KAPanelContainerWindow()
            guard let panelContainerWindow = panelContainerWindow, rootViewController is KABasePanelViewController else {
                return
            }
            
            panelContainerWindow.frame = UIApplication.shared.keyWindow?.frame ?? UIScreen.main.bounds
            panelContainerWindow.backgroundColor = .clear
            panelContainerWindow.windowLevel = UIWindow.Level.statusBar + 1
            panelContainerWindow.rootViewController = rootViewController
            panelContainerWindow.makeKeyAndVisible()
        } else if let isKeyWindow = UIApplication.shared.keyWindow?.isKeyWindow, !isKeyWindow == false {
            panelContainerWindow?.rootViewController = nil
            panelContainerWindow = nil
            UIApplication.shared.keyWindow?.makeKeyAndVisible()
        }
    }
}

// MARK: - KABasePanelViewController
public class KABasePanelViewController: UIViewController {
    override open func loadView() {
        super.loadView()
        
        view = KAPanelContainerView()
        view.backgroundColor = .clear
        
        if let delegatingView = view as? KAPanelContainerView {
            delegatingView.touchDelegate = presentingViewController?.view
        }
    }
    
    public func dismissPopupView() {

    }
}

// MARK: - KAPanelContainerView
public class KAPanelContainerView: UIView {
    weak var touchDelegate: UIView? = nil

    override public func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let view = super.hitTest(point, with: event) else {
            return nil
        }

        guard view === self, let point = touchDelegate?.convert(point, from: self) else {
            return view
        }

        return touchDelegate?.hitTest(point, with: event)
    }
}

// MARK: - KAPanelContainerWindow
public class KAPanelContainerWindow: UIWindow {
    override public func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if let view = super.hitTest(point, with: event), view != self {
            return view
        }
        return nil
    }
}

// MARK: - KAWidgetsViewController
public class KAWidgetsViewController: KREWidgetsViewController {
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
}
