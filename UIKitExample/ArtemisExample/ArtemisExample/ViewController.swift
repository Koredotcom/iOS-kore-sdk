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
        connection: ConnectionConfig(projectId: "your-project-id", endpoint: "https://runtime.example.com", apiKey: "pk_your_public_key"),
        channel: ChannelConfig(channelId: "your-channel-id")
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
