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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setInitialState()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    // MARK: button action
    @IBAction func signInButtonAction(_ sender: UIButton!) {
        
        // -------------------------------------------------------------- //
        // INFO: YOU MUST SET 'clientId'
        let clientId: String = SDKConfiguration.botConfig.demoClientId
        
        if clientId.characters.count > 0 {
            let activityIndicatorView: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
            activityIndicatorView.center = view.center
            view.addSubview(activityIndicatorView)
            activityIndicatorView.startAnimating()

            let botInfo: NSDictionary = ["chatBot": SDKConfiguration.botConfig.chatBotName, "taskBotId":SDKConfiguration.botConfig.taskBotId]

            let botClient: BotClient = BotClient(botInfoParameters: botInfo)
            botClient.connectAsAnonymousUser(clientId, success: { [weak self] (client) in
                activityIndicatorView.stopAnimating()

                let botViewController: ChatMessagesViewController = ChatMessagesViewController()
                botViewController.botClient = client
                botViewController.title = SDKConfiguration.botConfig.chatBotName
                self!.navigationController?.pushViewController(botViewController, animated: true)

                }, failure: { (error) in
                    activityIndicatorView.stopAnimating()

            })
        } else {
            print("YOU MUST SET 'clientId', Please check documentation.")
        }
        // -------------------------------------------------------------- //
    }
    
    @IBAction func authenticateButtonAction(_ sender: UIButton!) {
        var status: Bool = false
        let accessToken = UserDefaults.standard.value(forKey: "TOKEN_FOR_AUTHORIZATION") as! String
        let userId: String = UserDefaults.standard.value(forKey: "USER_ID") as! String

        if (accessToken.characters.count > 0 && userId.characters.count > 0) {
            status = true
            authenticateButton.isEnabled = false

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
        authenticateButton.isEnabled = true
        
        signInButton.alpha = 1.0
        signInButton.isEnabled = true
    }
}
