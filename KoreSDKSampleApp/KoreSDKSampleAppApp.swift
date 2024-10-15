//
//  KoreSDKSampleAppApp.swift
//  KoreSDKSampleApp
//
//  Created by Abdulrahman Alsammahi on 23/10/2023.
//

import SwiftUI
import KoreBotSDK
import UserNotifications
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
        
        botConnect.show()
        
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if granted {
                print("Permission granted")
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
        
        botConnect.locaNotificationEvent = { (eventDic) in
           if let dic = eventDic {
               print(dic)
               if let text = dic["text"] as? String{
                   scheduleTimeBasedNotification(notificationtext: text)
               }
               
           }
       }
        
    }
    
    func scheduleTimeBasedNotification(notificationtext: String) {
        // 1. Request permission to display alerts and play sounds.
        // 2. Create the content for the notification
        let content = UNMutableNotificationContent()
        content.title = "Baraq"
        content.body = notificationtext
        content.sound = UNNotificationSound.default

        // 3. Set up a trigger for the notification
        // For example, 10 seconds from now
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: (0.1), repeats: false)

        // 4. Create the request
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        // 5. Add the request to the notification center
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("Notification scheduled")
            }
        }
    }
}
