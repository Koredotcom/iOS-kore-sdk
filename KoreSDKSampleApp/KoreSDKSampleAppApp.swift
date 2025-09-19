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
        botConnect.initialize("<client-id>", clientSecret: "<client-secret>", botId: "<bot-id>", chatBotName: "bot-name", identity: "<identity-email> or <random-id>", isAnonymous: true, isWebhookEnabled: false, JWTServerUrl: "http://<jwt-server-host>/", BOTServerUrl: "https://bots.kore.ai", BrandingUrl: "https://bots.kore.ai", customData: customData)
        
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
