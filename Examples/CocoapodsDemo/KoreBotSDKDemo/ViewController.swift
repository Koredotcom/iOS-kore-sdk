//
//  ViewController.swift
//  KoreBotSDKDemo
//
//  Created by Kartheek Pagidimarri on 10/01/24.
//  Copyright © 2024 Kore. All rights reserved.
//

import UIKit
import KoreBotSDK

class ViewController: UIViewController {
    
    let botConnect = BotConnect()
    enum BotEventReason: Int {
        case connected = 1
        case tokenExpired = 2
        case disconnected = 3
        case connectionError = 4
        case closedByUser = 5
        case minimizedByUser = 6
        case connectionLost = 7
        case networkReconnected = 8
        case deepLink = 9
        case startNewSession = 10
        case connectionClosed = 11
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     
     // MARK: Custom Template Injection
     //botConnect.addCustomTemplates(numbersOfViews: [LinkTemplateBubbleview.self],customerTemplaateTypes: ["link"])
     */
    
    @IBAction func connectBtnAction(_ sender: Any) {
        let clientId = "<client-id>" // Copy this value from Bot Builder SDK Settings.
        let clientSecret = "<client-secret>" // Copy this value from Bot Builder SDK Settings.
        let botId =  "<bot-id>" // Copy this value from Bot Builder -> Channels -> Web/Mobile Client.
        let chatBotName = "bot-name" // Copy this value from Bot Builder -> Channels -> Web/Mobile Client.
        let identity = "<identity-email> or <random-id>" // This should represent the subject for JWT token. This can be an email or phone number, in case of known user, and in case of anonymous user, this can be a randomly generated unique id.
        let isAnonymous = true // This should be either true (in case of known-user) or false (in-case of anonymous user).
        let isWebhookEnabled = false // This should be either true (in case of Webhook connection) or false (in-case of Socket connection).
        let customData : [String: Any] = [:]
        let queryParameters: [[String: Any]] = [] //[["ConnectionMode":"Start_New_Resume_Agent"],["q2":"ios"],["q3":"1"]]
        let customJWToken: String = ""  //This should represent the subject for send own JWToken.
        let JWT_SERVER = String(format: "http://<jwt-server-host>/") // Replace it with the actual JWT server URL, if required. Refer to developer documentation for instructions on hosting JWT Server.
        let BOT_SERVER = String(format: "https://bots.kore.ai")
        let Branding_SERVER = String(format: "https://bots.kore.ai")
        
        
        // MARK: Set Bot Config
        botConnect.initialize(clientId, clientSecret: clientSecret, botId: botId, chatBotName: chatBotName, identity: identity, isAnonymous: isAnonymous, isWebhookEnabled: isWebhookEnabled, JWTServerUrl: JWT_SERVER, BOTServerUrl: BOT_SERVER, BrandingUrl: Branding_SERVER, customData: customData, queryParameters: queryParameters, customJWToken: customJWToken)
        
        
        
        // MARK: Local Branding
        if let path = Bundle.main.path(forResource: "localbranding", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                
                let jsonDecoder = JSONDecoder()
                guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonResult as Any , options: .prettyPrinted),
                      let activeTheme = try? jsonDecoder.decode(ActiveTheme.self, from: jsonData) else {
                    return
                }
                botConnect.setBrandingConfig(configTheme: activeTheme)
            } catch {
            }
        }
        
        //MARK: Add custom headerview
        //        botConnect.addCustomHeaderView(headerView: SampleHeaderView())
        
        //MARK: Add custom composebarview
        //        let customFooterView = SampleFooterView()
        //       botConnect.addCustomFooterComposeBarView(footerView: customFooterView, growingTxtV: customFooterView.textV)
        
        //MARK: Add custom Audio composebarview
        //        botConnect.addCustomFooterAudioComposeBar(footerView: SampleAudioComposeView())
        
        //MARK: set bubbleview dateformat
        //        botConnect.setBubbleDateFormat = "MMMM d 'at' h:mm a"
        
        //MARK: Set the variable to enable or disable reconnection inside the sdk
        //        self.botConnect.reConnectionBySDK = false
        
        // MARK: Show Bot window
        botConnect.show()
        
        // MARK: - Bot Connection State
        //let botConnectionState = self.botConnect.socketConnectionStateDescription()
        //print(botConnectionState)  // e.g. "Connected",Disconnected, "Closed" ,"None"
        
        // MARK: Callbacks Evetns
        botConnect.closeOrMinimizeEvent = { eventDic in
            guard
                let dic = eventDic,
                let reasonValue = dic["event_reason"] as? Int,
                let reason = BotEventReason(rawValue: reasonValue)
            else {
                return
            }
            print(dic)
            switch reason {
            case .connected:
                print("Bot connected successfully")
            case .tokenExpired:
                print("Token expired")
                
            case .disconnected:
                print("Bot disconnected successfully")
                
            case .connectionError:
                print("Bot connection error")
                
            case .closedByUser:
                print("Bot closed by the user")
                
            case .minimizedByUser:
                print("Bot minimized by the user")
                
            case .connectionLost:
                print("Network connectivity issue. Attempt reconnect if needed.")
                
            case .networkReconnected:
                print("Network connectivity has been restored.")
//                let customJWToken: String = ""  //This should represent the subject for send own JWToken.
//                self.botConnect.setCustom_JwToken(customJWToken: customJWToken, customData: customData, queryParameters: queryParameters)
//                self.botConnect.socketConnect(isReconnect: false)
                
            case .deepLink:
                print("Deeplink")
                
            case .startNewSession:
                print("startNewSession")
//                let customJWToken: String = ""  //This should represent the subject for send own JWToken.
//                self.botConnect.setCustom_JwToken(customJWToken: customJWToken, customData: customData, queryParameters: queryParameters)
//                self.botConnect.socketConnect(isReconnect: true)
                
            case .connectionClosed:
                  print("connectionClosed")
            }
        }
        
    }
}
