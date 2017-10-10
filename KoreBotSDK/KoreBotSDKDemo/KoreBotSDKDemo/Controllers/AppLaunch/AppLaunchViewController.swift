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
    @IBOutlet weak var chatButton: UIButton!
    // MARK: life-cycle events
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let chatBotName: String = SDKConfiguration.botConfig.chatBotName
        self.chatButton.setTitle(String(format: "Chat with %@", chatBotName), for: .normal)
        setInitialState()
        self.automaticallyAdjustsScrollViewInsets = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setInitialState()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    // MARK: known user
    @IBAction func chatButtonAction(_ sender: UIButton!) {
        self.chatButton.isUserInteractionEnabled = false
        
        let clientId: String = SDKConfiguration.botConfig.clientId
        let clientSecret: String = SDKConfiguration.botConfig.clientSecret
        let isAnonymous: Bool = SDKConfiguration.botConfig.isAnonymous
        let chatBotName: String = SDKConfiguration.botConfig.chatBotName
        let botId: String = SDKConfiguration.botConfig.botId

        var identity: String! = nil
        if (isAnonymous) {
            identity = self.getUUID()
        } else {
            identity = SDKConfiguration.botConfig.identity
        }
        
        if clientId.indexOfCharacter(char: "<") == -1 && clientSecret.indexOfCharacter(char: "<") == -1 && chatBotName.indexOfCharacter(char: "<") == -1 && botId.indexOfCharacter(char: "<") == -1 && identity.indexOfCharacter(char: "<") == -1 {
            let activityIndicatorView: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
            activityIndicatorView.center = view.center
            view.addSubview(activityIndicatorView)
            activityIndicatorView.startAnimating()
            
            let botInfo: NSDictionary = ["chatBot": chatBotName, "taskBotId": botId]
            
            self.getJwTokenWithClientId(clientId, clientSecret: clientSecret, identity: identity, isAnonymous: isAnonymous, success: { [weak self] (jwToken) in
                
                let dataStoreManager: DataStoreManager = DataStoreManager.sharedManager
                let context: NSManagedObjectContext = dataStoreManager.coreDataManager.workerContext
                context.perform {
                    let resources: Dictionary<String, AnyObject> = ["threadId": botId as AnyObject, "subject": chatBotName as AnyObject, "messages":[] as AnyObject]
                    dataStoreManager.deleteThreadIfRequired(with: botId, completionBlock: { (success) in
                        
                    let thread: KREThread = dataStoreManager.insertOrUpdateThread(dictionary: resources, withContext: context)
                    try! context.save()
                    dataStoreManager.coreDataManager.saveChanges()
                    print(thread.threadId!)
                    
                    let botClient: BotClient = BotClient(botInfoParameters: botInfo)
                    if (ServerConfigs.BOT_SERVER.characters.count > 0) {
                        botClient.setKoreBotServerUrl(url: ServerConfigs.BOT_SERVER)
                    }
                    botClient.connectWithJwToken(jwToken, success: { [weak self] (client) in
                        activityIndicatorView.stopAnimating()
                        self?.chatButton.isUserInteractionEnabled = true
                        
//                        let botViewController = ChatMessagesViewController(thread: thread)
//                        botViewController.botClient = client
//                        botViewController.title = SDKConfiguration.botConfig.chatBotName
                        
                        let botViewController = ChatWindowViewController(thread: thread)
                        botViewController.botClient = client
                        botViewController.title = SDKConfiguration.botConfig.chatBotName
                        
                        //Addition fade in animation
                        let transition = CATransition()
                        transition.duration = 0.5
                        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                        transition.type = kCATransitionFade
                        self?.navigationController?.view.layer.add(transition, forKey: nil)
                    
                        self!.navigationController?.pushViewController(botViewController, animated: false)
                    }, failure: { (error) in
                        activityIndicatorView.stopAnimating()
                        self?.chatButton.isUserInteractionEnabled = true
                    })
                })
                }
            }, failure: { (error) in
                activityIndicatorView.stopAnimating()
                self.chatButton.isUserInteractionEnabled = true
            })
        } else {
            self.showAlert(title: "Bot SDK Demo", message: "YOU MUST SET 'clientId', 'clientSecret', 'chatBotName', 'identity' and 'botId'. Please check the documentation.")
            self.chatButton.isUserInteractionEnabled = true
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
        
        let operationManager: AFHTTPRequestOperationManager = AFHTTPRequestOperationManager.init(baseURL: URL.init(string: ServerConfigs.JWT_SERVER) as URL!)
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
        chatButton.alpha = 1.0
        chatButton.isEnabled = true
    }
    
    func getUUID() -> String {
        let date: Date = Date()
        return String(format: "email%ld%@", date.timeIntervalSince1970, "@domain.com")
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
