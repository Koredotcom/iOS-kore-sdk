//
//  AppDelegate.swift
//  KoreBotSDKDemo
//
//  Created by developer@kore.com on 20/05/16.
//  Copyright © 2016 Kore Inc. All rights reserved.
//

import UIKit
import KoreBotSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    // MARK: app delegate methos
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        if let window = window {
            window.backgroundColor = UIColor.white

            //let appLaunchViewController = AppLaunchViewController(nibName: "AppLaunchViewController", bundle: Bundle.sdkModule)
            let appLaunchViewController: ViewController = ViewController(nibName: "ViewController", bundle: nil)
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

