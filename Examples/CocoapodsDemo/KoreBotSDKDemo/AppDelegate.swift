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
            //let appLaunchViewController: AppLaunchViewController = AppLaunchViewController(nibName: "AppLaunchViewController", bundle: Bundle.sdkModule)
            initailizeKoreBotConfig()
            //
            let chatMessagesViewController: ChatMessagesViewController = ChatMessagesViewController()
            chatMessagesViewController.isShowHeaderView = true
            
            let secondVC: SecondVC = SecondVC(nibName: "SecondVC", bundle: nil)
            let appLaunchViewController: ViewController = ViewController(nibName: "ViewController", bundle: nil)
            
            appLaunchViewController.tabBarItem = UITabBarItem(tabBarSystemItem: .favorites, tag: 0)
            secondVC.tabBarItem = UITabBarItem(tabBarSystemItem: .downloads, tag: 1)
            chatMessagesViewController.tabBarItem = UITabBarItem(tabBarSystemItem: .history, tag: 2)
            
            
            let tabController = UITabBarController()
            let controllers = [appLaunchViewController, chatMessagesViewController, secondVC]
            tabController.viewControllers = controllers
            tabController.viewControllers = controllers.map { UINavigationController(rootViewController: $0)}
            tabController.selectedIndex = 0
            
            self.window!.rootViewController = tabController
            self.window?.makeKeyAndVisible()
        }
        return true
    }
    
    func initailizeKoreBotConfig() {
        
        let botConnect = BotConnect()
        let clientId = "cs-1e845b00-81ad-5757-a1e7-d0f6fea227e9" // Copy this value from Bot Builder SDK Settings ex. cs-5250bdc9-6bfe-5ece-92c9-ab54aa2d4285
        let clientSecret = "5OcBSQtH/k6Q/S6A3bseYfOee02YjjLLTNoT1qZDBso=" // Copy this value from Bot Builder SDK Settings ex. Wibn3ULagYyq0J10LCndswYycHGLuIWbwHvTRSfLwhs=
        let botId =  "st-b9889c46-218c-58f7-838f-73ae9203488c" // Copy this value from Bot Builder -> Channels -> Web/Mobile Client  ex. st-acecd91f-b009-5f3f-9c15-7249186d827d
        let chatBotName = "SDKBot" // Copy this value from Bot Builder -> Channels -> Web/Mobile Client  ex. "Demo Bot"
        let identity = "rajasekhar.balla@kore.com"// This should represent the subject for JWT token. This can be an email or phone number, in case of known user, and in case of anonymous user, this can be a randomly generated unique id.
        let isAnonymous = true // This should be either true (in case of known-user) or false (in-case of anonymous user).
        let isWebhookEnabled = false // This should be either true (in case of Webhook connection) or false (in-case of Socket connection).
        let customData : [String: Any] = [:]
        let queryParameters: [[String: Any]] = [] //[["ConnectionMode":"Start_New_Resume_Agent"],["q2":"ios"],["q3":"1"]]
        let customJWToken: String = ""  //This should represent the subject for send own JWToken.
        let JWT_SERVER = String(format: "https://mk2r2rmj21.execute-api.us-east-1.amazonaws.com/dev/") // Replace it with the actual JWT server URL, if required. Refer to developer documentation for instructions on hosting JWT Server.
        let BOT_SERVER = String(format: "https://bots.kore.ai")
        let Branding_SERVER = String(format: "https://bots.kore.ai")
        
        // MARK: Set Bot Config
        botConnect.initialize(clientId, clientSecret: clientSecret, botId: botId, chatBotName: chatBotName, identity: identity, isAnonymous: isAnonymous, isWebhookEnabled: isWebhookEnabled, JWTServerUrl: JWT_SERVER, BOTServerUrl: BOT_SERVER, BrandingUrl: Branding_SERVER, customData: customData, queryParameters: queryParameters, customJWToken: customJWToken)
        
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


