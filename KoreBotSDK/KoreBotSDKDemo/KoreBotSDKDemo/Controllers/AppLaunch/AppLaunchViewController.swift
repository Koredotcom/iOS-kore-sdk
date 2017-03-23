//
//  AppLaunchViewController.swift
//  KoreBotSDKDemo
//
//  Created by developer@kore.com on 09/05/16.
//  Copyright © 2016 Kore Inc. All rights reserved.
//

import UIKit
import AFNetworking
import KoreBotSDK
import CoreData

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
        if clientId.indexOfCharacter(char: "<") == -1 && clientSecret.indexOfCharacter(char: "<") == -1 {
            let activityIndicatorView: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
            activityIndicatorView.center = view.center
            view.addSubview(activityIndicatorView)
            activityIndicatorView.startAnimating()
            
            let chatBotName: String = SDKConfiguration.botConfig.chatBotName
            let taskBotId: String = SDKConfiguration.botConfig.taskBotId
            let botInfo: NSDictionary = ["chatBot": chatBotName, "taskBotId": taskBotId]

            self.getJwTokenWithClientId(clientId, clientSecret: clientSecret, identity: identity, isAnonymous: true, success: { [weak self] (jwToken) in
                
                let dataStoreManager: DataStoreManager = DataStoreManager.sharedManager
                let context: NSManagedObjectContext = dataStoreManager.coreDataManager.workerContext
                context.perform {
                    let resources: Dictionary<String, AnyObject> = ["threadId": taskBotId as AnyObject, "subject": chatBotName as AnyObject, "messages":[] as AnyObject]
                    let thread: KREThread = dataStoreManager.insertOrUpdateThread(dictionary: resources, withContext: context)
                    try! context.save()
                    dataStoreManager.coreDataManager.saveChanges()
                    print(thread.threadId!)
                    
                    let botClient: BotClient = BotClient(botInfoParameters: botInfo)
                    botClient.connectWithJwToken(jwToken, success: { (client) in
                        activityIndicatorView.stopAnimating()
                        let botViewController: ChatMessagesViewController = ChatMessagesViewController(thread: thread)
                        botViewController.botClient = client
                        botViewController.title = SDKConfiguration.botConfig.chatBotName
                        self!.navigationController?.pushViewController(botViewController, animated: true)
                    }, failure: { (error) in
                        activityIndicatorView.stopAnimating()
                    })
                }
            }, failure: { (error) in
                activityIndicatorView.stopAnimating()
            })
        } else {
            self.showAlert(title: "Bot SDK Demo", message: "YOU MUST SET 'clientId', 'clientSecret'. Please check the documentation.")
        }
    }
    
    // MARK: authenticated user
    @IBAction func authenticateButtonAction(_ sender: UIButton!) {
        let clientId: String = SDKConfiguration.botConfig.clientId
        let clientSecret: String = SDKConfiguration.botConfig.clientSecret
        let identity: String = SDKConfiguration.botConfig.identity
        if clientId.indexOfCharacter(char: "<") == -1 && clientSecret.indexOfCharacter(char: "<") == -1 {
            let activityIndicatorView: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
            activityIndicatorView.center = view.center
            view.addSubview(activityIndicatorView)
            activityIndicatorView.startAnimating()
            
            let chatBotName: String = SDKConfiguration.botConfig.chatBotName
            let taskBotId: String = SDKConfiguration.botConfig.taskBotId
            let botInfo: NSDictionary = ["chatBot": chatBotName, "taskBotId": taskBotId]
            
            self.getJwTokenWithClientId(clientId, clientSecret: clientSecret, identity: identity, isAnonymous: false, success: { [weak self] (jwToken) in
                
                let dataStoreManager: DataStoreManager = DataStoreManager.sharedManager
                let context: NSManagedObjectContext = dataStoreManager.coreDataManager.workerContext
                context.perform {
                    let resources: Dictionary<String, AnyObject> = ["threadId": taskBotId as AnyObject, "subject": chatBotName as AnyObject, "messages":[] as AnyObject]
                    let thread: KREThread = dataStoreManager.insertOrUpdateThread(dictionary: resources, withContext: context)
                    try! context.save()
                    dataStoreManager.coreDataManager.saveChanges()
                    print(thread.threadId!)
                    
                    let botClient: BotClient = BotClient(botInfoParameters: botInfo)
                    botClient.connectWithJwToken(jwToken, success: { (client) in
                        activityIndicatorView.stopAnimating()
                        let botViewController: ChatMessagesViewController = ChatMessagesViewController(thread: thread)
                        botViewController.botClient = client
                        botViewController.title = SDKConfiguration.botConfig.chatBotName
                        self!.navigationController?.pushViewController(botViewController, animated: true)
                    }, failure: { (error) in
                        activityIndicatorView.stopAnimating()
                    })
                }
            }, failure: { (error) in
                activityIndicatorView.stopAnimating()
            })
        } else {
            self.showAlert(title: "Bot SDK Demo", message: "YOU MUST SET 'clientId', 'clientSecret'. Please check the documentation.")
        }
    }
    
    // MARK: get JWT token request
    // NOTE: Invokes a webservice and gets the JWT token.
    //       Developer has to host a webservice, which generates the JWT and that should be called from this method.
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
    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func setInitialState() {
        authenticateButton.alpha = 1.0
        authenticateButton.isEnabled = true
        
        signInButton.alpha = 1.0
        signInButton.isEnabled = true
    }
}

extension String {
    public func indexOfCharacter(char: Character) -> Int? {
        if let idx = characters.index(of: char) {
            return characters.distance(from: startIndex, to: idx)
        }
        return -1
    }
}
