//
//  AppLaunchViewController.swift
//  KoreBotSDKDemo
//
//  Created by Srinivas Vasadi on 09/05/16.
//  Copyright © 2016 Kore. All rights reserved.
//

import UIKit
import KoreBotSDK
import AFNetworking

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
    
    // MARK: anonymous user
    @IBAction func signInButtonAction(_ sender: UIButton!) {
        let clientId: String = SDKConfiguration.botConfig.clientId
        let clientSecret: String = SDKConfiguration.botConfig.clientSecret
        let identity: String = SDKConfiguration.botConfig.identity
        if clientId.characters.count > 0 && clientSecret.characters.count > 0 {
            let activityIndicatorView: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
            activityIndicatorView.center = view.center
            view.addSubview(activityIndicatorView)
            activityIndicatorView.startAnimating()

            let botInfo: NSDictionary = ["chatBot": SDKConfiguration.botConfig.chatBotName, "taskBotId":SDKConfiguration.botConfig.taskBotId]
            self.getJwTokenWithClientId(clientId, clientSecret: clientSecret, identity: identity, isAnonymous: true, success: { [weak self] (jwToken) in
                activityIndicatorView.stopAnimating()
                
                let botClient: BotClient = BotClient(botInfoParameters: botInfo)
                botClient.connectWithJwToken(jwToken, success: { (client) in
                    let botViewController: ChatMessagesViewController = ChatMessagesViewController()
                    botViewController.botClient = client
                    botViewController.title = SDKConfiguration.botConfig.chatBotName
                    self!.navigationController?.pushViewController(botViewController, animated: true)
                }, failure: { (error) in
                    
                })
            }, failure: { (error) in
                activityIndicatorView.stopAnimating()
            })
        } else {
            print("YOU MUST SET 'clientId', 'clientSecret', Please check documentation.")
        }
    }
    
    // MARK: authenticated user
    @IBAction func authenticateButtonAction(_ sender: UIButton!) {
        let clientId: String = SDKConfiguration.botConfig.clientId
        let clientSecret: String = SDKConfiguration.botConfig.clientSecret
        let identity: String = SDKConfiguration.botConfig.identity
        if clientId.characters.count > 0 && clientSecret.characters.count > 0 {
            let activityIndicatorView: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
            activityIndicatorView.center = view.center
            view.addSubview(activityIndicatorView)
            activityIndicatorView.startAnimating()
            
            let botInfo: NSDictionary = ["chatBot": SDKConfiguration.botConfig.chatBotName, "taskBotId":SDKConfiguration.botConfig.taskBotId]
            self.getJwTokenWithClientId(clientId, clientSecret: clientSecret, identity: identity, isAnonymous: false, success: { [weak self] (jwToken) in
                activityIndicatorView.stopAnimating()
                
                let botClient: BotClient = BotClient(botInfoParameters: botInfo)
                botClient.connectWithJwToken(jwToken, success: { (client) in
                    let botViewController: ChatMessagesViewController = ChatMessagesViewController()
                    botViewController.botClient = client
                    botViewController.title = SDKConfiguration.botConfig.chatBotName
                    self!.navigationController?.pushViewController(botViewController, animated: true)
                }, failure: { (error) in
                    
                })
                }, failure: { (error) in
                    activityIndicatorView.stopAnimating()
            })
        } else {
            print("YOU MUST SET 'clientId', 'clientSecret', Please check documentation.")
        }
    }
    
    // MARK: request
    func getJwTokenWithClientId(_ clientId: String!, clientSecret: String!, identity: String!, isAnonymous: Bool!, success:((_ jwToken: String?) -> Void)?, failure:((_ error: Error) -> Void)?) {
        // NOTE: You must set your URL to generate JWT. 
        let urlString: String = ServerConfigs.koreJwtUrl()
        let requestSerializer = AFJSONRequestSerializer()
        requestSerializer.httpMethodsEncodingParametersInURI = Set.init(["GET"]) as Set<String>
        requestSerializer.setValue("Keep-Alive", forHTTPHeaderField:"Connection")
        
        // Headers: {"alg": "RS256","typ": "JWT"}
        requestSerializer.setValue("RS256", forHTTPHeaderField:"alg")
        requestSerializer.setValue("JWT", forHTTPHeaderField:"typ")
        
        let parameters: NSDictionary = ["clientId": clientId,
                                        "clientSecret": clientSecret,
                                        "identity": identity,
                                        "aud": "https://idproxy.kore.com/authorize",
                                        "isAnonymous": isAnonymous]
        
        let operationManager: AFHTTPRequestOperationManager = AFHTTPRequestOperationManager.init(baseURL: URL.init(string: ServerConfigs.KORE_SERVER) as URL!)
        operationManager.responseSerializer = AFJSONResponseSerializer.init()
        operationManager.requestSerializer = requestSerializer
        operationManager.post(urlString, parameters: parameters, success: { (operation, responseObject) in
            if (responseObject is NSDictionary) {
                let dictionary: NSDictionary = responseObject as! NSDictionary
                let jwToken: String = dictionary["jwt"] as! String
                success?(jwToken)
            } else {
                let error: NSError = NSError(domain: "bot", code: 100, userInfo: [:])
                failure?(error)
            }
        }) { (operation, error) in
            failure?(error!)
        }
    }
    
    func setInitialState() {
        authenticateButton.alpha = 1.0
        authenticateButton.isEnabled = true
        
        signInButton.alpha = 1.0
        signInButton.isEnabled = true
    }
}
