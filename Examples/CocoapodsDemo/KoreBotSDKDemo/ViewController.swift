//
//  ViewController.swift
//  KoreBotSDKDemo
//
//  Created by Kartheek Pagidimarri on 08/06/23.
//  Copyright © 2023 Kore. All rights reserved.
//

import UIKit
import KoreBotSDK

class ViewController: UIViewController {
    
    let botClient: BotClient = BotClient()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let botInfo: [String: Any] = ["chatBot": "<bot-name>", "taskBotId": "<bot-id>"]
        
        botClient.initialize(botInfoParameters: botInfo, customData: [:])
        //Setting the server Url
        let botServerUrl: String = "https://bots.kore.ai"
        botClient.setKoreBotServerUrl(url: botServerUrl)
        
        let jwtToken = "<jwt-token>"
        self.botClient.connectWithJwToken(jwtToken, intermediary: { [weak self] (client) in
            self?.botClient.connect(isReconnect: false)
        }, success: { (client) in
            print("\(String(describing: client))")
        }, failure: { (error) in
            print("\(String(describing: error))")
        })
        
        configureBotClient()
    }
    
    func configureBotClient() {
        
        self.botClient.onMessage = { (object) in
            print("botResponse: \(object ?? [:])")
        }
        self.botClient.onMessageAck = { (ack) in
            //"ack" type as "Ack"
        }
        self.botClient.connectionDidClose = { (code, reason) in
            //"code" type as "Int", "reason" type as "String"
            print("Close \(String(describing: reason))")
        }
        self.botClient.connectionDidFailWithError = { (error) in
            //"error" type as "NSError"
            print("error \(String(describing: error))")
        }
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
        self.botClient.sendMessage("hello", options: [:])
    }
    
}
