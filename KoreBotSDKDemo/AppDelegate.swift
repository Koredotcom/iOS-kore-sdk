//
//  AppDelegate.swift
//  KoreBotSDKDemo
//
//  Created by Kartheek.Pagidimarri on 04/05/21.
//  Copyright © 2021 Kartheek.Pagidimarri. All rights reserved.
//

import UIKit
import KoreBotSDKFrameWork

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    // MARK: app delegate methos
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        if let window = window {
            if #available(iOS 13.0, *) {
                    // prefer a light interface style with this:
                window.overrideUserInterfaceStyle = .light
            }
            window.backgroundColor = UIColor.white
            //let appLaunchViewController: AppLaunchViewController = AppLaunchViewController()
            let appLaunchViewController: ViewController = ViewController()
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

