//
//  BotConnect.swift
//  KoreBotSDKFrameWork
//
//  Created by Kartheek.Pagidimarri on 17/05/21.
//  Copyright © 2021 Kartheek.Pagidimarri. All rights reserved.
//

import UIKit
import Alamofire
import KoreBotSDK
import CoreData
import Foundation

public class BotConnect: NSObject {
    
    let sessionManager: Session = {
        let configuration = URLSessionConfiguration.af.default
        configuration.timeoutIntervalForRequest = 30
        return Session(configuration: configuration)
    }()
    var kaBotClient = KABotClient()
    let botClient = BotClient()
    var user: KREUser?
    let navigationController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController
    
    // MARK: - init
    public override init() {
        super.init()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc public func show(){
        let clientId: String = SDKConfiguration.botConfig.clientId
        let clientSecret: String = SDKConfiguration.botConfig.clientSecret
        let isAnonymous: Bool = SDKConfiguration.botConfig.isAnonymous
        let chatBotName: String = SDKConfiguration.botConfig.chatBotName
        let botId: String = SDKConfiguration.botConfig.botId
        messageIdIndex = 5000
        messageIdIndexForHistory = 5000
        appEnterBackground = false
        reloadTabV = true
        
        var identity: String! = nil
        if (isAnonymous) {
            identity = self.getUUID()
        } else {
            identity = SDKConfiguration.botConfig.identity
        }
        
        
        let clientIdForWidget: String = SDKConfiguration.widgetConfig.clientId
        let clientSecretForWidget: String = SDKConfiguration.widgetConfig.clientSecret
        let isAnonymousForWidget: Bool = SDKConfiguration.widgetConfig.isAnonymous
        let chatBotNameForWidget: String = SDKConfiguration.widgetConfig.chatBotName
        let botIdForWidget: String = SDKConfiguration.widgetConfig.botId
        var identityForWidget: String! = nil
        if (isAnonymousForWidget) {
            identityForWidget = self.getUUID()
        } else {
            identityForWidget = SDKConfiguration.widgetConfig.identity
        }
        
        
        let dataStoreManager: DataStoreManager = DataStoreManager.sharedManager
//        dataStoreManager.deleteThreadIfRequired(with: botId, completionBlock: { (success) in
//            RCTLogInfo("Delete Sucess")
//        })
        dataStoreManager.removeAllCoreData()
        
        if !clientId.hasPrefix("<") && !clientSecret.hasPrefix("<") && !chatBotName.hasPrefix("<") && !botId.hasPrefix("<") && !identity.hasPrefix("<")  {
            
            self.showLoader()
            kaBotClient.connect(block: { [weak self] (client, thread) in
                
                if !SDKConfiguration.widgetConfig.isPanelView {
                     self?.withOutBrandingData(client: client, thread: thread)
                }else{
                    if !clientIdForWidget.hasPrefix("<") && !clientSecretForWidget.hasPrefix("<") && !chatBotNameForWidget.hasPrefix("<") && !botIdForWidget.hasPrefix("<") && !identityForWidget.hasPrefix("<") {
                        
                        self?.getWidgetJwTokenWithClientId(clientIdForWidget, clientSecret: clientSecretForWidget, identity: identityForWidget, isAnonymous: isAnonymousForWidget, success: { [weak self] (jwToken) in
                            
                            self?.withOutBrandingData(client: client, thread: thread)
                            
                        }, failure: { (error) in
                            RCTLogInfo(error.localizedDescription)
                            self!.stopLoader()
                        })
                        
                    }else{
                        self!.stopLoader()
                        self!.showAlert(title: "IDFC", message: "YOU MUST SET WIDGET 'clientId', 'clientSecret', 'chatBotName', 'identity' and 'botId'. Please check the documentation.")
                    }
                }
                
            }) { (error) in
                RCTLogInfo(error.localizedDescription)
                self.stopLoader()
                Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { (_) in
                    if error.localizedDescription == "The Internet connection appears to be offline."{
                        self.showAlert(title: "IDFC", message: "No internet connection")
                    }else if error.localizedDescription == "The operation couldn’t be completed. (RTM error 0.)"{
                        self.showAlert(title: "IDFC", message: "Your session has expired. Please re-login.")
                    }else{
                        self.showAlert(title: "IDFC", message: "Please try again")
                    }
                    
                }
                
            }
            
        } else {
            self.stopLoader()
            self.showAlert(title: "IDFC", message: "YOU MUST SET BOT 'clientId', 'clientSecret', 'chatBotName', 'identity' and 'botId'. Please check the documentation.")
            
        }
    }
    
    func brandingApis(client: BotClient?, thread: KREThread?){
        self.kaBotClient.brandingApiRequest(authInfoAccessToken,success: { [weak self] (brandingArray) in
            RCTLogInfo("brandingArray : \(brandingArray)")
            if brandingArray.count > 0{
                brandingShared.hamburgerOptions = (((brandingArray as AnyObject).object(at: 0) as AnyObject).object(forKey: "hamburgermenu") as Any) as? Dictionary<String, Any>
            }
            if brandingArray.count>1{
                let brandingDic = (((brandingArray as AnyObject).object(at: 1) as AnyObject).object(forKey: "brandingwidgetdesktop") as Any)
                let jsonDecoder = JSONDecoder()
                guard let jsonData = try? JSONSerialization.data(withJSONObject: brandingDic as Any , options: .prettyPrinted),
                      let brandingValues = try? jsonDecoder.decode(BrandingModel.self, from: jsonData) else {
                    return
                }
                let brandingShared = BrandingSingleton.shared
                brandingShared.brandingInfoModel = brandingValues
                UserDefaults.standard.set("#9B1E26", forKey: "ThemeColor")
                themeColor = UIColor.init(hexString: "#9B1E26")
                Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { (_) in
                    self?.navigateToChatViewController(client: client, thread: thread)
                }
                
            }
        }, failure: { (error) in
            RCTLogInfo(error.localizedDescription)
            self.getOfflineBrandingData(client: client, thread: thread)
            
        })
    }
    
    func getOfflineBrandingData(client: BotClient?, thread: KREThread?){
        if let path = Bundle.main.path(forResource: "brandingValues", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let brandingArray = jsonResult as? NSArray {
                    // do stuff
                    RCTLogInfo("jsonResult: \(jsonResult)")
                    if brandingArray.count > 0{
                        brandingShared.hamburgerOptions = (((brandingArray as AnyObject).object(at: 0) as AnyObject).object(forKey: "hamburgermenu") as Any) as? Dictionary<String, Any>
                    }
                    if brandingArray.count>1{
                        let brandingDic = (((brandingArray as AnyObject).object(at: 1) as AnyObject).object(forKey: "brandingwidgetdesktop") as Any)
                        let jsonDecoder = JSONDecoder()
                        guard let jsonData = try? JSONSerialization.data(withJSONObject: brandingDic as Any , options: .prettyPrinted),
                              let brandingValues = try? jsonDecoder.decode(BrandingModel.self, from: jsonData) else {
                            return
                        }
                        let brandingShared = BrandingSingleton.shared
                        brandingShared.brandingInfoModel = brandingValues
                        UserDefaults.standard.set("#56070C", forKey: "ThemeColor")
                        themeColor = UIColor.init(hexString: "#56070C")
                        
                        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { (_) in
                            self.navigateToChatViewController(client: client, thread: thread)
                        }
                        
                    }
                    
                }
            } catch {
                // handle error
                self.stopLoader()
            }
        }else{
            let brandingShared = BrandingSingleton.shared
            let brandingValues = BrandingModel()
            brandingShared.brandingInfoModel = brandingValues
            UserDefaults.standard.set("#56070C", forKey: "ThemeColor")
            themeColor = UIColor.init(hexString: "#56070C")
            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { (_) in
                self.navigateToChatViewController(client: client, thread: thread)
            }
        }
    }
    
    func withOutBrandingData(client: BotClient?, thread: KREThread?){
        let brandingShared = BrandingSingleton.shared
        let brandingValues = BrandingModel()
        brandingShared.brandingInfoModel = brandingValues
        UserDefaults.standard.set("#56070C", forKey: "ThemeColor")
        themeColor = UIColor.init(hexString: "#56070C")
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { (_) in
            self.navigateToChatViewController(client: client, thread: thread)
        }
    }
    
    
    // MARK: Navigate Kore Chat Window
    func navigateToChatViewController(client: BotClient?, thread: KREThread?){
        self.stopLoader()
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
    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        //**
        let titleAttributes = [NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Medium", size: 17.0), NSAttributedString.Key.foregroundColor: UIColor.black]
        let titleString = NSAttributedString(string: alertController.title!, attributes: titleAttributes as [NSAttributedString.Key : Any])
        let messageAttributes = [NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Medium", size: 14.0), NSAttributedString.Key.foregroundColor: UIColor.black]
        let messageString = NSAttributedString(string: alertController.message!, attributes: messageAttributes as [NSAttributedString.Key : Any])
        alertController.setValue(titleString, forKey: "attributedTitle")
        alertController.setValue(messageString, forKey: "attributedMessage")
        if #available(iOS 13.0, *) {
            alertController.overrideUserInterfaceStyle  = .light
        }
        //     **
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        UIApplication.shared.keyWindow?.rootViewController?.present(alertController, animated: true, completion: nil)
        
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
    
    func showLoader(){
        let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)
        
        let messageAttributes = [NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Medium", size: 17.0), NSAttributedString.Key.foregroundColor: UIColor.black]
        let messageString = NSAttributedString(string: alert.message!, attributes: messageAttributes as [NSAttributedString.Key : Any])
        alert.setValue(messageString, forKey: "attributedMessage")
        if #available(iOS 13.0, *) {
            alert.overrideUserInterfaceStyle  = .light
        }
        
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.gray
        loadingIndicator.startAnimating();
        
        alert.view.addSubview(loadingIndicator)
        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    func stopLoader(){
        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: false, completion: nil)
    }
    
    // MARK: Kore Widgets
    func getWidgetJwTokenWithClientId(_ clientId: String!, clientSecret: String!, identity: String!, isAnonymous: Bool!, success:((_ jwToken: String?) -> Void)?, failure:((_ error: Error) -> Void)?) {
        
        //        // Session Configuration
        //        let configuration = URLSessionConfiguration.default
        //
        //        //Manager
        //        sessionManager = AFHTTPSessionManager.init(baseURL: URL.init(string: SDKConfiguration.serverConfig.JWT_SERVER) as URL?, sessionConfiguration: configuration)
        //
        //        // NOTE: You must set your URL to generate JWT.
        //        let urlString: String = SDKConfiguration.serverConfig.koreJwtUrl()
        //        let requestSerializer = AFJSONRequestSerializer()
        //        requestSerializer.httpMethodsEncodingParametersInURI = Set.init(["GET"]) as Set<String>
        //        requestSerializer.setValue("Keep-Alive", forHTTPHeaderField:"Connection")
        //
        //        // Headers: {"alg": "RS256","typ": "JWT"}
        //        requestSerializer.setValue("RS256", forHTTPHeaderField:"alg")
        //        requestSerializer.setValue("JWT", forHTTPHeaderField:"typ")
        //
        //        let parameters: NSDictionary = ["clientId": clientId as String,
        //                                        "clientSecret": clientSecret as String,
        //                                        "identity": identity as String,
        //                                        "aud": "https://idproxy.kore.com/authorize",
        //                                        "isAnonymous": isAnonymous as Bool]
        //
        //
        //        sessionManager?.responseSerializer = AFJSONResponseSerializer.init()
        //        sessionManager?.requestSerializer = requestSerializer
        //        sessionManager?.post(urlString, parameters: parameters, headers: nil, progress: nil, success: { (sessionDataTask, responseObject) in
        //            if (responseObject is NSDictionary) {
        //                let dictionary: NSDictionary = responseObject as! NSDictionary
        //                let jwToken: String = dictionary["jwt"] as! String
        //                self.initializeWidgetManager(widgetJWTToken: jwToken)
        //                success?(jwToken)
        //
        //            } else {
        //                let error: NSError = NSError(domain: "bot", code: 100, userInfo: [:])
        //                failure?(error)
        //            }
        //        }) { (sessionDataTask, error) in
        //            failure?(error)
        //        }
        
    }
    
    func initializeWidgetManager(widgetJWTToken: String) {
        let widgetManager = KREWidgetManager.shared
        let user = KREUser()
        user.userId = SDKConfiguration.widgetConfig.botId //userId
        user.accessToken = widgetJWTToken
        user.server = SDKConfiguration.serverConfig.KORE_SERVER
        user.tokenType = "bearer"
        user.userEmail = SDKConfiguration.widgetConfig.identity
        user.headers = ["X-KORA-Client": KoraAssistant.shared.applicationHeader]
        widgetManager.initialize(with: user)
        self.user = user
        
        widgetManager.sessionExpiredAction = { (error) in
            DispatchQueue.main.async {
                // NotificationCenter.default.post(name: NSNotification.Name(rawValue: KoraNotification.EnforcementNotification), object: ["type": KoraNotification.EnforcementType.userSessionDidBecomeInvalid])
            }
        }
    }
}

