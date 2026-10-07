//
//  ViewController.swift
//  ArtemisExample
//
//  Created by Pagidimarri Kartheek on 06/10/26.
//

import UIKit
import ArtemisUISDK

class ViewController: UIViewController {
    
    // Uses the same runtime configuration as the SwiftUI example.
    private let configuration = SDKConfiguration(
           environment: "dev",
           connection: ConnectionConfig(projectId: "019ebab0-737a-7661-9c02-d8d416320a1c", endpoint: "https://agents-dev.kore.ai", apiKey: "pk_3721dc52d9b95534fa402c680387afee04b9c9b569a9c508"),
           channel: ChannelConfig(channelId: "019eee30-53a9-7961-afb1-e9303a8c989f")
       )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Artemis Example"
    }
    
    
    @IBAction func tapsOnConnectBtnAction(_ sender: Any) {
        guard presentedViewController == nil else { return }
        
        // The SDK initializes and connects when the chat appears, and disposes
        // the connection when the user closes the chat screen.
        AgentChatUI.show(
            in: self,
            configuration: configuration,
            title: "Agent Chat"
        )
    }
}
