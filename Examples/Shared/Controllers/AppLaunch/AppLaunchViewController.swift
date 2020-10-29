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
import Foundation

class AppLaunchViewController: UIViewController {
    
    @IBOutlet weak var imgView: UIImageView!
    // MARK: properties
    @IBOutlet weak var chatButton: UIButton!
    @IBOutlet weak var identityTF: UITextField!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    var sessionManager: AFHTTPSessionManager?
    var kaBotClient = KABotClient()
    let botClient = BotClient()
    var user: KREUser?
    let activityIndicatorView: UIActivityIndicatorView = UIActivityIndicatorView(style: .white)

    // MARK: life-cycle events
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //let chatBotName: String = SDKConfiguration.botConfig.chatBotName
        //self.chatButton.setTitle(String(format: "%@", chatBotName), for: .normal)
        setInitialState()
        self.automaticallyAdjustsScrollViewInsets = false
        imgView.contentMode = .scaleAspectFit
        
        identityTF.text = SDKConfiguration.botConfig.identity
        
        NotificationCenter.default.addObserver(self, selector: #selector(ChatMessagesViewController.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ChatMessagesViewController.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        getThemeColorApi()
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        let keyboardUserInfo: NSDictionary = NSDictionary(dictionary: (notification as NSNotification).userInfo!)
        let keyboardFrameEnd: CGRect = ((keyboardUserInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue?)!.cgRectValue)
        let options = UIView.AnimationOptions(rawValue: UInt((keyboardUserInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as! NSNumber).intValue << 16))
        let durationValue = keyboardUserInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber
        let duration = durationValue.doubleValue
        
        var keyboardHeight = keyboardFrameEnd.size.height;
        if #available(iOS 11.0, *) {
            keyboardHeight -= self.view.safeAreaInsets.bottom
        } else {
            // Fallback on earlier versions
        };
        self.bottomConstraint.constant = keyboardHeight + 35
        UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
            self.view.layoutIfNeeded()
        }, completion: { (Bool) in
            
        })
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        let keyboardUserInfo: NSDictionary = NSDictionary(dictionary: (notification as NSNotification).userInfo!)
        let durationValue = keyboardUserInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber
        let duration = durationValue.doubleValue
        let options = UIView.AnimationOptions(rawValue: UInt((keyboardUserInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as! NSNumber).intValue << 16))
            self.bottomConstraint.constant = 20
        UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
            self.view.layoutIfNeeded()
        }, completion: { (Bool) in
            
        })
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
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
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
            identity = identityTF.text! //SDKConfiguration.botConfig.identity //kk
            dynamicIdentity = identity
        }
        identityTF.resignFirstResponder()
        
        let clientIdForWidget: String = SDKConfiguration.widgetConfig.clientId
        let clientSecretForWidget: String = SDKConfiguration.widgetConfig.clientSecret
        let isAnonymousForWidget: Bool = SDKConfiguration.widgetConfig.isAnonymous
        let chatBotNameForWidget: String = SDKConfiguration.widgetConfig.chatBotName
        let botIdForWidget: String = SDKConfiguration.widgetConfig.botId
        var identityForWidget: String! = nil
        if (isAnonymousForWidget) {
            identityForWidget = self.getUUID()
        } else {
            identityForWidget = identityTF.text! //SDKConfiguration.widgetConfig.identity //kk
        }
        
        let dataStoreManager: DataStoreManager = DataStoreManager.sharedManager
        dataStoreManager.deleteThreadIfRequired(with: botId, completionBlock: { (success) in
            print("Delete Sucess")
        })
        
        if !clientId.hasPrefix("<") && !clientSecret.hasPrefix("<") && !chatBotName.hasPrefix("<") && !botId.hasPrefix("<") && !identity.hasPrefix("<") && identityTF.text != "" {
            //let activityIndicatorView: UIActivityIndicatorView = UIActivityIndicatorView(style: .white)
            activityIndicatorView.center = chatButton.center
            view.addSubview(activityIndicatorView)
            activityIndicatorView.startAnimating()
//             kaBotClient.tryConnect()
            kaBotClient.connect(block: { [weak self] (client, thread) in
              
                if !SDKConfiguration.widgetConfig.isPanelView {
                    self?.navigateToChatViewController(client: client, thread: thread)
                }else{
                    if !clientIdForWidget.hasPrefix("<") && !clientSecretForWidget.hasPrefix("<") && !chatBotNameForWidget.hasPrefix("<") && !botIdForWidget.hasPrefix("<") && !identityForWidget.hasPrefix("<") {
                        
                        self?.getWidgetJwTokenWithClientId(clientIdForWidget, clientSecret: clientSecretForWidget, identity: identityForWidget, isAnonymous: isAnonymousForWidget, success: { [weak self] (jwToken) in
                            
                           self?.navigateToChatViewController(client: client, thread: thread)
                        
                        }, failure: { (error) in
                                print(error)
                         self?.activityIndicatorView.stopAnimating()
                         self?.chatButton.isUserInteractionEnabled = true
                        })
                        
                    }else{
                        self!.showAlert(title: "Bot SDK Demo", message: "YOU MUST SET WIDGET 'clientId', 'clientSecret', 'chatBotName', 'identity' and 'botId'. Please check the documentation.")
                        self?.activityIndicatorView.stopAnimating()
                        self?.chatButton.isUserInteractionEnabled = true
                    }
                }
                
            }) { (error) in
                self.activityIndicatorView.stopAnimating()
                self.chatButton.isUserInteractionEnabled = true
            }
        } else {
            self.showAlert(title: "Bot SDK Demo", message: "YOU MUST SET 'clientId', 'clientSecret', 'chatBotName', 'identity' and 'botId'. Please check the documentation.")
            self.chatButton.isUserInteractionEnabled = true
        }
    }
    
    func navigateToChatViewController(client: BotClient?, thread: KREThread?){
        activityIndicatorView.stopAnimating()
        self.chatButton.isUserInteractionEnabled = true

        let botViewController = ChatMessagesViewController(thread: thread)
        botViewController.botClient = client
        botViewController.title = SDKConfiguration.botConfig.chatBotName

        //Addition fade in animation
        let transition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.fade
        self.navigationController?.view.layer.add(transition, forKey: nil)

        self.navigationController?.pushViewController(botViewController, animated: false)
    }
    
    // MARK: get JWT token request
    // NOTE: Invokes a webservice and gets the JWT token.
    //       Developer has to host a webservice, which generates the JWT and that should be called from this method.
    func getJwTokenWithClientId(_ clientId: String!, clientSecret: String!, identity: String!, isAnonymous: Bool!, success:((_ jwToken: String?) -> Void)?, failure:((_ error: Error) -> Void)?) {
        
        // Session Configuration
        let configuration = URLSessionConfiguration.default
        
        //Manager
        sessionManager = AFHTTPSessionManager.init(baseURL: URL.init(string: SDKConfiguration.serverConfig.JWT_SERVER) as URL?, sessionConfiguration: configuration)

        // NOTE: You must set your URL to generate JWT.
        let urlString: String = SDKConfiguration.serverConfig.koreJwtUrl()
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
        
        sessionManager?.responseSerializer = AFJSONResponseSerializer.init()
        sessionManager?.requestSerializer = requestSerializer
        sessionManager?.post(urlString, parameters: parameters, headers: nil, progress: nil, success: { (sessionDataTask, responseObject) in
            if (responseObject is NSDictionary) {
                let dictionary: NSDictionary = responseObject as! NSDictionary
                let jwToken: String = dictionary["jwt"] as! String
                success?(jwToken)
            } else {
                let error: NSError = NSError(domain: "bot", code: 100, userInfo: [:])
                failure?(error)
            }
        }) { (sessionDataTask, error) in
            failure?(error)
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
        var id: String?
        let userDefaults = UserDefaults.standard
        if let UUID = userDefaults.string(forKey: "UUID") {
            id = UUID
        } else {
            let date: Date = Date()
            id = String(format: "email%ld%@", date.timeIntervalSince1970, "@domain.com")
            userDefaults.set(id, forKey: "UUID")
        }
        return id!
    }
}
extension AppLaunchViewController{
    func getWidgetJwTokenWithClientId(_ clientId: String!, clientSecret: String!, identity: String!, isAnonymous: Bool!, success:((_ jwToken: String?) -> Void)?, failure:((_ error: Error) -> Void)?) {
           
           // Session Configuration
           let configuration = URLSessionConfiguration.default
           
           //Manager
           sessionManager = AFHTTPSessionManager.init(baseURL: URL.init(string: SDKConfiguration.serverConfig.JWT_SERVER) as URL?, sessionConfiguration: configuration)

           // NOTE: You must set your URL to generate JWT.
           let urlString: String = SDKConfiguration.serverConfig.koreJwtUrl()
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
           
           
           sessionManager?.responseSerializer = AFJSONResponseSerializer.init()
           sessionManager?.requestSerializer = requestSerializer
           sessionManager?.post(urlString, parameters: parameters, headers: nil, progress: nil, success: { (sessionDataTask, responseObject) in
               if (responseObject is NSDictionary) {
                   let dictionary: NSDictionary = responseObject as! NSDictionary
                   let jwToken: String = dictionary["jwt"] as! String
                   self.initializeWidgetManager(widgetJWTToken: jwToken)
                   success?(jwToken)
                   
               } else {
                   let error: NSError = NSError(domain: "bot", code: 100, userInfo: [:])
                   failure?(error)
               }
           }) { (sessionDataTask, error) in
               failure?(error)
           }
       
       }
    
    func initializeWidgetManager(widgetJWTToken: String) {
    
     let widgetManager = KREWidgetManager.shared
     let user = KREUser()
     user.userId = SDKConfiguration.widgetConfig.botId //userId
     user.accessToken = widgetJWTToken
     user.server = SDKConfiguration.serverConfig.KORE_SERVER
     user.tokenType = "bearer"
     user.userEmail = identityTF.text! //SDKConfiguration.widgetConfig.identity //kk
     user.headers = ["X-KORA-Client": KoraAssistant.shared.applicationHeader]
     widgetManager.initialize(with: user)
     self.user = user
         
     widgetManager.sessionExpiredAction = { (error) in
         DispatchQueue.main.async {
            // NotificationCenter.default.post(name: NSNotification.Name(rawValue: KoraNotification.EnforcementNotification), object: ["type": KoraNotification.EnforcementType.userSessionDidBecomeInvalid])
         }
       }
    }
    
    func getThemeColorApi(){
//        let url = URL(string: "https://demo.kore.ai/bankingsolution-config/ws.ph")!
//        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
//            guard let unwrappedData = data else { return }
//            do {
//                let str = try (JSONSerialization.jsonObject(with: unwrappedData, options: []) as? [String: AnyObject])!
//                print(str)
//                themeColor = UIColor.init(hexString: str["header_color"] as? String ?? "#149C3F")
//                UserDefaults.standard.set(str["header_color"] ?? "#149C3F", forKey: themeColorUserDefaults)
//                headerTitle = str["header_title"] as? String ?? SDKConfiguration.widgetConfig.chatBotName
//                backgroudImage = str["back_img"] as? String ?? ""
//                leftImage = str["top_left_icon"] as? String ?? ""
//            } catch {
//                print("json error: \(error)")
//                themeColor = UIColor.init(hexString: "#2881DF")
//                UserDefaults.standard.set("#2881DF", forKey: themeColorUserDefaults)
//                headerTitle = SDKConfiguration.botConfig.chatBotName
//                backgroudImage =  ""
//                leftImage =  ""
//            }
//        }
//        task.resume()
        
        themeColor = UIColor.init(hexString: "#2881DF")
        UserDefaults.standard.set("#2881DF", forKey: themeColorUserDefaults)
        headerTitle = SDKConfiguration.botConfig.chatBotName
        backgroudImage =  ""
        leftImage =  ""
    }
}

extension AppLaunchViewController : UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (string == " ") {
            return false
        }
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
