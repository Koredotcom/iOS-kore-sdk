//
//  AppLaunchViewController.swift
//  KoreBotSDKDemo
//
//  Created by Srinivas Vasadi on 09/05/16.
//  Copyright © 2016 Kore. All rights reserved.
//

import UIKit
import KoreBotSDK

class AppLaunchViewController: UIViewController {
    
    // MARK: properties
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var authenticateButton: UIButton!
    
    // MARK: life-cycle events
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setInitialState()
        self.automaticallyAdjustsScrollViewInsets = false
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        setInitialState()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden = true
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    // MARK: button action
    @IBAction func signInButtonAction(sender: UIButton!) {
        
        // -------------------------------------------------------------- //
        // INFO: YOU MUST SET 'clientId'
        let clientId: String = "5a37bf24-fea0-4e6b-a816-f9602db08149"
        if clientId.characters.count > 0 {
            let activityIndicatorView: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
            activityIndicatorView.center = view.center
            view.addSubview(activityIndicatorView)
            activityIndicatorView.startAnimating()
            
            BotClient.anonymousUserSignIn(clientId, success: { [weak self] (user, authInfo) in
                activityIndicatorView.stopAnimating()

                let botViewController:KoraBotChatMessagesViewController = KoraBotChatMessagesViewController(user: user, authInfo: authInfo)
                botViewController.title = "Kora"
                self!.navigationController?.pushViewController(botViewController, animated: true)

                }, failure: { (error) in
                    activityIndicatorView.stopAnimating()

            })
        } else {
            print("YOU MUST SET 'clientId', Please check documentation.")
        }
        // -------------------------------------------------------------- //
    }
    
    @IBAction func authenticateButtonAction(sender: UIButton!) {
        var status: Bool = false
        let accessToken = NSUserDefaults.standardUserDefaults().valueForKey("TOKEN_FOR_AUTHORIZATION") as! String
        let userId: String = NSUserDefaults.standardUserDefaults().valueForKey("USER_ID") as! String

        if (accessToken.characters.count > 0 && userId.characters.count > 0) {
            status = true
            authenticateButton.enabled = false

            let botsViewController:BotsViewController = BotsViewController(userId: userId, accessToken: accessToken)
            botsViewController.title = "Bots"
            self.navigationController?.pushViewController(botsViewController, animated: true)
        }
        
        if (!status) {
            print("YOU MUST CALL 'setAccessToken(:)' WITH VALID TOKEN, Please check documentation.")
        }
    }
    
    func setInitialState() {
        authenticateButton.alpha = 1.0
        authenticateButton.enabled = true
        
        signInButton.alpha = 1.0
        signInButton.enabled = true
    }
}
