//
//  UIViewController+KoreBotSDK.swift
//  KoreBotSDK
//
//  Created by Srinivas Vasadi on 04/07/19.
//  Copyright © 2019 Srinivas Vasadi. All rights reserved.
//

import UIKit

public extension UIViewController {
    // MARK: -
    public var isModal: Bool {
        if let index = navigationController?.viewControllers.index(of: self), index > 0 {
            return false
        } else if presentingViewController != nil {
            return true
        } else if navigationController?.presentingViewController?.presentedViewController == navigationController  {
            return true
        } else if tabBarController?.presentingViewController is UITabBarController {
            return true
        } else {
            return false
        }
    }
}

public extension UIViewController {
    public func topMostViewController() -> UIViewController? {
        if presentedViewController == nil {
            return self
        } else if let navigationController = presentedViewController as? UINavigationController {
            let lastViewController = navigationController.viewControllers.last
            return lastViewController?.topMostViewController()
        }
        
        let presentedViewController = self.presentedViewController
        return presentedViewController?.topMostViewController()
    }
    
    public func needsToDimiss() -> Bool {
        return false
    }
    
    public func dismissAllPresentedViewControllers(completion block:(() -> Void)?) {
        guard let _ = presentingViewController else {
            block?()
            return
        }
        
        let group = DispatchGroup()
        if let navigationController = self as? UINavigationController {
            let presentedViewControllers = navigationController.viewControllers.filter({ $0.presentingViewController != nil})
            let vcgroup = DispatchGroup()
            for viewController in presentedViewControllers {
                vcgroup.enter()
                viewController.dismiss(animated: true, completion:{
                    vcgroup.leave()
                })
            }
            
            group.enter()
            vcgroup.notify(queue: DispatchQueue.main) {
                if let _ = navigationController.presentingViewController {
                    navigationController.dismiss(animated: true, completion:{
                        if let _ = navigationController.presentingViewController {
                            navigationController.presentingViewController?.dismissAllPresentedViewControllers(completion: {
                                group.leave()
                            })
                        } else {
                            group.leave()
                        }
                    })
                } else {
                    group.leave()
                }
            }
        } else {
            group.enter()
            if let _ = presentingViewController?.presentingViewController {
                if let _ = presentingViewController {
                    presentingViewController?.dismissAllPresentedViewControllers(completion: {
                        group.leave()
                    })
                } else {
                    group.leave()
                }
            } else {
                dismiss(animated: true, completion:{
                    group.leave()
                })
            }
        }
        group.notify(queue: DispatchQueue.main) {
            block?()
        }
    }
    
    public func dismissAllViewControllers(block: (() -> Void)?) {
        guard let _ = presentedViewController else {
            block?()
            return
        }
        let group = DispatchGroup()
        
        if let navigationController = self as? UINavigationController {
            let presentedViewControllers = navigationController.viewControllers.filter({ $0.presentedViewController != nil })
            
            let vcgroup = DispatchGroup()
            for viewController in presentedViewControllers {
                vcgroup.enter()
                viewController.dismiss(animated: true, completion:{
                    vcgroup.leave()
                })
            }
            
            group.enter()
            vcgroup.notify(queue: DispatchQueue.main) {
                if let _ = navigationController.presentingViewController {
                    navigationController.dismiss(animated: true, completion:{
                        if let _ = navigationController.presentingViewController {
                            navigationController.presentingViewController?.dismissAllViewControllers(block: {
                                group.leave()
                            })
                        } else {
                            group.leave()
                        }
                    })
                } else {
                    group.leave()
                }
            }
        } else {
            group.enter()
            if let _ = presentingViewController?.presentingViewController {
                if let _ = presentingViewController {
                    presentingViewController?.dismissAllViewControllers(block: {
                        group.leave()
                    })
                } else {
                    group.leave()
                }
            } else {
                self.dismiss(animated: true, completion:{
                    group.leave()
                })
            }
        }
        group.notify(queue: DispatchQueue.main) {
            block?()
        }
    }
}
