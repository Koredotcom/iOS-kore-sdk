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
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // -------------------------------------------------------------- //
        // INFO: YOU MUST CALL 'setAccessToken(:)' WITH VALID TOKEN
        let token: String = "bearer Y6w_0YGDSEbamsjTlKRg7qfyJVkI_aovwDHP-puBN61AYKU_1lvcJMJ5bXlk-8K2"
        Common.setAccessToken(token)
        
        let userId: String = "u-73364365-f98d-571d-8e8e-022186cde3bc"
        Common.setUserId(userId)
        // -------------------------------------------------------------- //
        
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        if let window = window {
            window.backgroundColor = UIColor.whiteColor()

            let appLaunchViewController: AppLaunchViewController = AppLaunchViewController(nibName: "AppLaunchViewController", bundle: nil)
            let navigationController: UINavigationController = UINavigationController(rootViewController: appLaunchViewController)

            window.rootViewController = navigationController
            window.makeKeyAndVisible()
        }
        return true
    }
    
    func applicationWillResignActive(application: UIApplication) {
        
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        
    }
    
    func applicationWillTerminate(application: UIApplication) {
        
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        
    }
}

