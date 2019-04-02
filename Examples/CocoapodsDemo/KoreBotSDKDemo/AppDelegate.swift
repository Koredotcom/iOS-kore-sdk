//
//  AppDelegate.swift
//  KoreBotSDKDemo
//
//  Created by developer@kore.com on 20/05/16.
//  Copyright © 2016 Kore Inc. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    // MARK: app delegate methos
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        if let window = window {
            window.backgroundColor = UIColor.white

            let appLaunchViewController: AppLaunchViewController = AppLaunchViewController(nibName: "AppLaunchViewController", bundle: nil)
            let navigationController: UINavigationController = UINavigationController(rootViewController: appLaunchViewController)

            window.rootViewController = navigationController
            window.makeKeyAndVisible()
        }
        startMonitoringForReachability()
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        stopMonitoringForReachability()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
//        startMonitoringForReachability()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        startMonitoringForReachability()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
    }
    @objc func startMonitoringForReachability() {
        let networkReachabilityManager = AFNetworkReachabilityManager.shared()
        networkReachabilityManager.setReachabilityStatusChange({ (status) in
            print("Network reachability: \(AFNetworkReachabilityManager.shared().localizedNetworkReachabilityStatusString())")
            switch status {
            case AFNetworkReachabilityStatus.reachableViaWWAN, AFNetworkReachabilityStatus.reachableViaWiFi:
                self.establishBotConnection()
                break
            case AFNetworkReachabilityStatus.notReachable:
                fallthrough
            default:
                break
            }
            
            KABotClient.shared.setReachabilityStatusChange(status)
        })
        networkReachabilityManager.startMonitoring()
    }
    @objc func stopMonitoringForReachability() {
        AFNetworkReachabilityManager.shared().stopMonitoring()
    }
    
    // MARK: - establish BotSDK connection
    func establishBotConnection() {
        KABotClient.shared.tryConnect()
    }
}

