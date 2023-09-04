//
//  ViewController.swift
//  KoreBotSDKDemo
//
//  Created by Kartheek Pagidimarri on 08/06/23.
//  Copyright © 2023 Kore. All rights reserved.
//

import UIKit
import KoreBotSDK
let botconnect = BotConnect()

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
           // Do any additional setup after loading the view.
        setBotConfig()
    }
    
    func setBotConfig(){
        
        let clientId = "cs-1e845b00-81ad-5757-a1e7-d0f6fea227e9" // Copy this value from Bot Builder SDK Settings ex. cs-5250bdc9-6bfe-5ece-92c9-ab54aa2d4285
        
        let clientSecret = "5OcBSQtH/k6Q/S6A3bseYfOee02YjjLLTNoT1qZDBso=" // Copy this value from Bot Builder SDK Settings ex. Wibn3ULagYyq0J10LCndswYycHGLuIWbwHvTRSfLwhs=
        
        let botId = "st-b9889c46-218c-58f7-838f-73ae9203488c" // Copy this value from Bot Builder -> Channels -> Web/Mobile Client  ex. st-acecd91f-b009-5f3f-9c15-7249186d827d
        
        let chatBotName = "SDKBot" // Copy this value from Bot Builder -> Channels -> Web/Mobile Client  ex. "Demo Bot"
        
        let identity = "rajasekhar.balla@kore.com"// This should represent the subject for JWT token. This can be an email or phone number, in case of known user, and in case of anonymous user, this can be a randomly generated unique id.
        
        let isAnonymous = false; // This should be either true (in case of known-user) or false (in-case of anonymous user).
        
        let isWebhookEnabled = false // This should be either true (in case of Webhook connection) or false (in-case of Socket connection).
        
        let JWT_SERVER = "https://mk2r2rmj21.execute-api.us-east-1.amazonaws.com/dev/" // Replace it with the actual JWT server URL, if required. Refer to developer documentation for instructions on hosting JWT Server.
        
        let BOT_SERVER = "https://bankassist.kore.ai"
        
        botconnect.initialize(clientId, clientSecret: clientSecret, botId: botId, chatBotName: chatBotName, identity: identity, isAnonymous: isAnonymous,isWebhookEnabled: isWebhookEnabled, JWTServerUrl: JWT_SERVER, BOTServerUrl: BOT_SERVER)
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func connectBtn(_ sender: Any) {
        botconnect.show()
    }
    
}
