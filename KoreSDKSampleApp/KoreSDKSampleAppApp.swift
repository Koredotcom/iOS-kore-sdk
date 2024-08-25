//
//  KoreSDKSampleAppApp.swift
//  KoreSDKSampleApp
//
//  Created by Abdulrahman Alsammahi on 23/10/2023.
//

import SwiftUI
import KoreBotSDK

@main
struct KoreSDKSampleAppApp: App {
    
    let botConnect = BotConnect()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
            Button(action: {
                botConnectButtonAction()
            }, label: {
                Text("Bot Connect")
            })
        }
    }
    func botConnectButtonAction(){
        
        let customData: [String : Any] = ["user_id": "", "language": "", "platform": "ios"]
        botConnect.initialize("cs-16267e93-ae50-58f3-852a-6034d89b1cfa", clientSecret: "MARMSzQORkdqUvNiyV9dmFkYf73DfqoXrOEJ1o1n6Cw=", botId: "st-ab5a9721-28ec-5a68-9bd5-ccab1641bd66", chatBotName: "SDKBot", identity: "abc@kore.com", isAnonymous: true, isWebhookEnabled: false, JWTServerUrl: "https://gw.dev.baraq.com/koreai/api/", BOTServerUrl: "https://koreai.dev.baraq.com", BrandingUrl: "https://koreai.dev.baraq.com", customData: customData)
        
        //botConnect.initialize("cs-a8239f06-c548-5ac3-b9c4-3129f2fc5b89", clientSecret: "+oTGPYWMjQ8g4kixEJwh7p0nD4bd+sVcru/YdXxNN/k=", botId: "st-27172eec-8b47-5bc5-bd1b-842a99e92d29", chatBotName: "Agent Set up", identity: "abc@kore.com", isAnonymous: false, isWebhookEnabled: false, JWTServerUrl: "https://mk2r2rmj21.execute-api.us-east-1.amazonaws.com/dev/", BOTServerUrl: "https://platform.kore.ai", BrandingUrl: "https://koreai.dev.baraq.com", customData: customData)
        
        //botConnect.initialize("cs-5e679d2f-bedf-5e06-89b9-cd1ebf522e63", clientSecret: "Yrw7XUt2PdTBkFEmT9wthF2KrIgjSxKGwRNDkrWSoZw=", botId: "st-6b76b530-3c87-5eed-86cc-3b3916dd6e4e", chatBotName: "Agent Set up", identity: "abc@kore.com", isAnonymous: true, isWebhookEnabled: false, JWTServerUrl: "https://mk2r2rmj21.execute-api.us-east-1.amazonaws.com/dev/", BOTServerUrl: "https://platform.kore.ai", BrandingUrl: "https://koreai.dev.baraq.com", customData: customData)
        botConnect.show()
    }
}
