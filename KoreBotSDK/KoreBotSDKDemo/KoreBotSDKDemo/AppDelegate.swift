//
//  AppDelegate.swift
//  KoreBotSDKDemo
//
//  Created by Srinivas Vasadi on 20/05/16.
//  Copyright © 2016 Kore. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    // MARK: app delegate methos
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        if let window = window {
            window.backgroundColor = UIColor.white

            let appLaunchViewController: AppLaunchViewController = AppLaunchViewController(nibName: "AppLaunchViewController", bundle: nil)
            let navigationController: UINavigationController = UINavigationController(rootViewController: appLaunchViewController)

            window.rootViewController = navigationController
            window.makeKeyAndVisible()
        }
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
    }
}

