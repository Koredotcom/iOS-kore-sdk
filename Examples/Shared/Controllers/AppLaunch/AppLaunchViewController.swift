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
    @IBOutlet weak var careMarkButton: UIButton!
    @IBOutlet weak var pfizerButton: UIButton!
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
        
//        kaBotClient.getSearchInterfaceResults(success: { (serarchInterfaceDic) in
//            print(serarchInterfaceDic)
//
//            let jsonDecoder = JSONDecoder()
//            guard let jsonData = try? JSONSerialization.data(withJSONObject: serarchInterfaceDic as Any , options: .prettyPrinted),
//                let allItems = try? jsonDecoder.decode(SearchInterfaceModel.self, from: jsonData) else {
//                    return
//            }
//            print(allItems)
//
//        }) { (error) in
//            print(error)
//        }
        
        
        
//        kaBotClient.getResultViewSettings(success: { (serarchInterfaceDic) in
//            print(serarchInterfaceDic)
//
//            let jsonDecoder = JSONDecoder()
//            guard let jsonData = try? JSONSerialization.data(withJSONObject: serarchInterfaceDic as Any , options: .prettyPrinted),
//                let allItems = try? jsonDecoder.decode(GetResultViewSettingModel.self, from: jsonData) else {
//                    return
//            }
//            print(allItems)
//
//        }) { (error) in
//            print(error)
//        }
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
        print("sender.tag....\(sender.tag)")
        if sender.tag == 1{
            self.chatButton.isUserInteractionEnabled = false
            self.careMarkButton.isUserInteractionEnabled = true
            self.pfizerButton.isUserInteractionEnabled = true
//            SDKConfiguration.botConfig.clientId = "cs-3c6514cd-3904-5145-8a83-cf469529de29"
//            SDKConfiguration.botConfig.clientSecret = "XoBPDcb3hJpcLzu5hxPV/Fh4VNh8cPKezWI0irPgil0="
//            SDKConfiguration.botConfig.botId =  "st-db7c8d37-fa7d-5d9a-9e30-e332566a7389"
//            SDKConfiguration.botConfig.searchIndexID =  "sidx-3fc74f2c-9bb1-5946-b2c2-a7e43c72082e"
//            SDKConfiguration.botConfig.chatBotName = "July 14"
            
//            SDKConfiguration.botConfig.clientId = "cs-cd5db130-8296-55ba-8307-7a87d4ec8fff"
//            SDKConfiguration.botConfig.clientSecret = "ozk5oqlrWerwpZ6odW9wkKr4WHBebTYDYIqP7LBqP4s="
//            SDKConfiguration.botConfig.botId =  "st-ba8e817a-0bcd-5855-bd91-eb2be2fdec30"
//            SDKConfiguration.botConfig.searchIndexID =  "sidx-8fb06646-1d82-56bb-9901-e27fc84611e0"
//            SDKConfiguration.botConfig.chatBotName = "May 20" //dev
            
//                        SDKConfiguration.botConfig.clientId = "cs-27605f21-7313-5141-8c34-7be052f8c451"
//                        SDKConfiguration.botConfig.clientSecret = "rsAQtkCD9RJ4eSyQWJMjAsBrb+30ISBQX+EeCuX45o0="
//                        SDKConfiguration.botConfig.botId =  "st-4e7e2c60-8dd8-5df6-abce-24c709613fb8"
//                        SDKConfiguration.botConfig.searchIndexID =  "sidx-fa7d0b2c-3965-52bb-918a-ed84b8d96c31"
//                        SDKConfiguration.botConfig.chatBotName = "App_maneesh" //dev
            
           // //findlySidx = "sidx-24471eaf-88c7-5789-9cfc-4a17e7e94a9e"
            
//            SDKConfiguration.botConfig.clientId = "cs-ec0f96bd-fe44-5724-bbd7-681ef518510d"
//            SDKConfiguration.botConfig.clientSecret = "DdBJMuVfpk6xkieZuNxP3PzREpPoYHnmCAZSywVM7cY="
//            SDKConfiguration.botConfig.botId =  "st-9c915712-360f-5e37-80ba-dc2728bea035"
//            SDKConfiguration.botConfig.searchIndexID =  "sidx-d9e0b3b3-4e64-58ec-9338-9cb98d1a977b"
//            SDKConfiguration.botConfig.chatBotName = "july8" //qa
            
//            SDKConfiguration.botConfig.clientId = "cs-e24fbff3-d40a-5787-91a9-67267fb0b4af"
//            SDKConfiguration.botConfig.clientSecret = "++IOWwGALuxbkCbYwiyljE0GF+vTNcWsnQCS+aFI5Mg="
//            SDKConfiguration.botConfig.botId =  "st-a9ce27ac-3454-55ad-9c82-e50e31c07009"
//            SDKConfiguration.botConfig.searchIndexID =  "sidx-28c300e9-13d9-5d99-ae48-392767bb1ee3"
//            SDKConfiguration.botConfig.chatBotName = "Mobile" //qa
            
            
//            SDKConfiguration.botConfig.clientId = "cs-30d2773b-0131-5e3f-b6d5-ed93cbae67c6"
//            SDKConfiguration.botConfig.clientSecret = "UdsX+q2hBSNVttzDoARy05zCluj9b0Ns0f2LRjmFwow="
//            SDKConfiguration.botConfig.botId =  "st-1847ca83-3ea9-519d-bfe4-7c993c8bc477"
//            SDKConfiguration.botConfig.searchIndexID =  "sidx-810d6e38-b522-54d3-8f2b-cdee7667fb34"
//            SDKConfiguration.botConfig.chatBotName = "Covid Help"
            
//            SDKConfiguration.botConfig.clientId = "cs-90e90c39-ea7c-54c7-a9f4-f5ff472e8a83"
//            SDKConfiguration.botConfig.clientSecret = "Yjz/buTJ6Vzj62PgDXhQk2Sc6WyjEpr5WP0gUFCNQJI="
//            SDKConfiguration.botConfig.botId =  "st-5716445a-aaa1-52ac-8e31-2fea9532b64f"
//            SDKConfiguration.botConfig.searchIndexID =  "sidx-3124cae8-4a4c-572e-9907-5cdb33d472b1"
//            SDKConfiguration.botConfig.chatBotName = "dec29Regression"
            
            SDKConfiguration.botConfig.clientId = "cs-59dc4ca7-73e6-5ffa-8df5-0baa4f10ef5a"
            SDKConfiguration.botConfig.clientSecret = "8iuc6uUWZGTWFDmScR6njiYVZiu1tacfizGspWuja0Q="
            SDKConfiguration.botConfig.botId =  "st-e531fc73-2662-5a8f-a584-8a5bfb0d9d02"
            SDKConfiguration.botConfig.searchIndexID =  "sidx-419a7a6b-744a-53e9-9772-58fec0a45f61"
            SDKConfiguration.botConfig.chatBotName = "regressionjan31"
            
        }else if sender.tag == 2{
            self.chatButton.isUserInteractionEnabled = true
            self.careMarkButton.isUserInteractionEnabled = false
            self.pfizerButton.isUserInteractionEnabled = true
            SDKConfiguration.botConfig.clientId = "cs-0b9dcc51-26f3-53ed-b9d9-65888e5aaaeb"
            SDKConfiguration.botConfig.clientSecret = "97KKpL/OF4ees3Z69voceE1nm5FnelhxrtrwOJuRMPA="
            SDKConfiguration.botConfig.botId =  "st-bd231a03-1ab7-58fb-8862-c19416471cdb"
            SDKConfiguration.botConfig.searchIndexID =  "sidx-6fff8b04-f206-565c-bb02-fb13ae366fd3"
            SDKConfiguration.botConfig.chatBotName = "careMark"
            //findlySidx = "sidx-6fff8b04-f206-565c-bb02-fb13ae366fd3"
        }else if sender.tag == 3{
            self.chatButton.isUserInteractionEnabled = true
            self.careMarkButton.isUserInteractionEnabled = true
            self.pfizerButton.isUserInteractionEnabled = false
            SDKConfiguration.botConfig.clientId = "cs-549d8874-cf8c-5715-bce1-cb83ec4faedb"
            SDKConfiguration.botConfig.clientSecret = "ZLnSvXa5fhxrRM8znYbhWOVN/yDNH8vikdIivggA6WI="
            SDKConfiguration.botConfig.botId =  "st-8dbd1e15-1f88-5ff7-9c23-e30ac1d38212"
            SDKConfiguration.botConfig.searchIndexID =  "sidx-d9006b59-6c8c-5a78-bcbd-00e3e0ceb9aa"
            SDKConfiguration.botConfig.chatBotName = "Pfizer"
            //findlySidx = "sidx-d9006b59-6c8c-5a78-bcbd-00e3e0ceb9aa"
        }
        
        
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
            
            if sender.tag == 1{
                activityIndicatorView.center = chatButton.center
            }else if sender.tag == 2{
                activityIndicatorView.center = careMarkButton.center
            }else if sender.tag == 3{
                activityIndicatorView.center = pfizerButton.center
            }
            view.addSubview(activityIndicatorView)
            activityIndicatorView.startAnimating()
//             kaBotClient.tryConnect()
            kaBotClient.connect(block: { [weak self] (client, thread) in
              
                if !SDKConfiguration.widgetConfig.isPanelView {
                    //self?.navigateToChatViewController(client: client, thread: thread)
                    
                    self?.kaBotClient.getSearchInterfaceResults(success: { (serarchInterfaceDic) in
                        print(serarchInterfaceDic)

                        let jsonDecoder = JSONDecoder()
                        guard let jsonData = try? JSONSerialization.data(withJSONObject: serarchInterfaceDic as Any , options: .prettyPrinted),
                            let allItems = try? jsonDecoder.decode(SearchInterfaceModel.self, from: jsonData) else {
                                return
                        }
                        print(allItems)
                        serachInterfaceItems = allItems
                        
                        self!.kaBotClient.getResultViewSettings(success: { (serarchInterfaceDic) in
                            print(serarchInterfaceDic)

                            let jsonDecoder = JSONDecoder()
                            guard let jsonData = try? JSONSerialization.data(withJSONObject: serarchInterfaceDic as Any , options: .prettyPrinted),
                                let allItems = try? jsonDecoder.decode(GetResultViewSettingModel.self, from: jsonData) else {
                                    return
                            }
                            print(allItems)
                            resultViewSettingItems = allItems
                            self?.navigateToChatViewController(client: client, thread: thread)

                        }) { (error) in
                            print(error)
                            self?.activityIndicatorView.stopAnimating()
                            self?.chatButton.isUserInteractionEnabled = true
                            self?.careMarkButton.isUserInteractionEnabled = true
                            self?.pfizerButton.isUserInteractionEnabled = true
                        }

                    }) { (error) in
                        print(error)
                        self?.activityIndicatorView.stopAnimating()
                        self?.chatButton.isUserInteractionEnabled = true
                        self?.careMarkButton.isUserInteractionEnabled = true
                        self?.pfizerButton.isUserInteractionEnabled = true
                    }
                }else{
                    if !clientIdForWidget.hasPrefix("<") && !clientSecretForWidget.hasPrefix("<") && !chatBotNameForWidget.hasPrefix("<") && !botIdForWidget.hasPrefix("<") && !identityForWidget.hasPrefix("<") {
                        
                        self?.getWidgetJwTokenWithClientId(clientIdForWidget, clientSecret: clientSecretForWidget, identity: identityForWidget, isAnonymous: isAnonymousForWidget, success: { [weak self] (jwToken) in
                            
                           self?.navigateToChatViewController(client: client, thread: thread)
                        
                        }, failure: { (error) in
                                print(error)
                         self?.activityIndicatorView.stopAnimating()
                         self?.chatButton.isUserInteractionEnabled = true
                         self?.careMarkButton.isUserInteractionEnabled = true
                         self?.pfizerButton.isUserInteractionEnabled = true
                        })
                        
                    }else{
                        self!.showAlert(title: "Bot SDK Demo", message: "YOU MUST SET WIDGET 'clientId', 'clientSecret', 'chatBotName', 'identity' and 'botId'. Please check the documentation.")
                        self?.activityIndicatorView.stopAnimating()
                        self?.chatButton.isUserInteractionEnabled = true
                        self?.careMarkButton.isUserInteractionEnabled = true
                        self?.pfizerButton.isUserInteractionEnabled = true
                    }
                }
                
            }) { (error) in
                self.activityIndicatorView.stopAnimating()
                self.chatButton.isUserInteractionEnabled = true
                self.careMarkButton.isUserInteractionEnabled = true
                self.pfizerButton.isUserInteractionEnabled = true
            }
        } else {
            self.showAlert(title: "Bot SDK Demo", message: "YOU MUST SET 'clientId', 'clientSecret', 'chatBotName', 'identity' and 'botId'. Please check the documentation.")
            self.chatButton.isUserInteractionEnabled = true
            self.careMarkButton.isUserInteractionEnabled = true
            self.pfizerButton.isUserInteractionEnabled = true
        }
    }
    
    func navigateToChatViewController(client: BotClient?, thread: KREThread?){
        activityIndicatorView.stopAnimating()
        self.chatButton.isUserInteractionEnabled = true
        self.careMarkButton.isUserInteractionEnabled = true
        self.pfizerButton.isUserInteractionEnabled = true

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
        
        let parameters: NSDictionary = ["clientId": clientId as String,
                                        "clientSecret": clientSecret as String,
                                        "identity": identity as String,
                                        "aud": "https://idproxy.kore.com/authorize",
                                        "isAnonymous": isAnonymous as Bool]
        
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
        careMarkButton.alpha = 1.0
        careMarkButton.isEnabled = true
        pfizerButton.alpha = 1.0
        pfizerButton.isEnabled = true
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
           
           requestSerializer.setValue("RS256", forHTTPHeaderField:"alg")
           requestSerializer.setValue("JWT", forHTTPHeaderField:"typ")
           
           let parameters: NSDictionary = ["clientId": clientId as String,
                                           "clientSecret": clientSecret as String,
                                           "identity": identity as String,
                                           "aud": "https://idproxy.kore.com/authorize",
                                           "isAnonymous": isAnonymous as Bool]
           
           
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
