//
//  WidgetConnect.swift
//  KoreBotSDKFrameWork
//
//  Created by Kartheek.Pagidimarri on 17/05/21.
//  Copyright © 2021 Kartheek.Pagidimarri. All rights reserved.
//

import UIKit
import AFNetworking

open class WidgetConnect: NSObject {
    
    var sessionManager: AFHTTPSessionManager?
    var user: KREUser?
    let navigationController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController
    
    // MARK: - init
    public override init() {
        super.init()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func show(_ clientId: String, success:((_ statusStr: String?) -> Void)?, failure:((_ error: Error) -> Void)?){
        let clientIdForWidget: String = WidgetSDKConfiguration.widgetConfig.clientId
        let clientSecretForWidget: String = WidgetSDKConfiguration.widgetConfig.clientSecret
        let isAnonymousForWidget: Bool = WidgetSDKConfiguration.widgetConfig.isAnonymous
        let chatBotNameForWidget: String = WidgetSDKConfiguration.widgetConfig.chatBotName
        let botIdForWidget: String = WidgetSDKConfiguration.widgetConfig.botId
        var identityForWidget: String! = nil
        if (isAnonymousForWidget) {
            identityForWidget = self.getUUID()
        } else {
            identityForWidget = WidgetSDKConfiguration.widgetConfig.identity
        }
        
        let statusStr = clientId
        if !statusStr.hasPrefix("<"){
            if !clientIdForWidget.hasPrefix("<") && !clientSecretForWidget.hasPrefix("<") && !chatBotNameForWidget.hasPrefix("<") && !botIdForWidget.hasPrefix("<") && !identityForWidget.hasPrefix("<") {
                
                self.getWidgetJwTokenWithClientId(clientIdForWidget, clientSecret: clientSecretForWidget, identity: identityForWidget, isAnonymous: isAnonymousForWidget, success: { [weak self] (jwToken) in
                    
                    success?(statusStr)
                }, failure: { (error) in
                    print(error)
                    let error: NSError = NSError(domain: "bot", code: 100, userInfo: [:])
                    failure?(error)
                })
                
            }else{
                self.showAlert(title: "Kore.ai", message: "YOU MUST SET WIDGET 'clientId', 'clientSecret', 'chatBotName', 'identity' and 'botId'. Please check the documentation.")
            }
        }else{
            let error: NSError = NSError(domain: "bot", code: 100, userInfo: [:])
            failure?(error)
        }
    
    }
    
   
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        //**
        let titleAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15.0), NSAttributedString.Key.foregroundColor: UIColor.black]
        let titleString = NSAttributedString(string: alertController.title!, attributes: titleAttributes as [NSAttributedString.Key : Any])
        let messageAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15.0), NSAttributedString.Key.foregroundColor: UIColor.black]
        let messageString = NSAttributedString(string: alertController.message!, attributes: messageAttributes as [NSAttributedString.Key : Any])
        alertController.setValue(titleString, forKey: "attributedTitle")
        alertController.setValue(messageString, forKey: "attributedMessage")
        //**
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
        
    // MARK: Kore Widgets
    func getWidgetJwTokenWithClientId(_ clientId: String!, clientSecret: String!, identity: String!, isAnonymous: Bool!, success:((_ jwToken: String?) -> Void)?, failure:((_ error: Error) -> Void)?) {
        
        // Session Configuration
        let configuration = URLSessionConfiguration.default
        
        //Manager
        sessionManager = AFHTTPSessionManager.init(baseURL: URL.init(string: WidgetSDKConfiguration.serverConfig.JWT_SERVER) as URL?, sessionConfiguration: configuration)
        
        // NOTE: You must set your URL to generate JWT.
        let urlString: String = WidgetSDKConfiguration.serverConfig.koreJwtUrl()
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
        user.userId = WidgetSDKConfiguration.widgetConfig.botId //userId
        user.accessToken = widgetJWTToken
        user.server = "\(WidgetSDKConfiguration.serverConfig.WIDGET_SERVER)/"
        user.tokenType = "bearer"
        user.userEmail = WidgetSDKConfiguration.widgetConfig.identity
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

