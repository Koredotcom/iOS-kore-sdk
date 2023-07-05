# Kore Bot SDK
Kore offers Bots SDKs as a set of platform-specific client libraries that provide a quick and convenient way to integrate Kore Bots chat capability into custom applications.

With just few lines of code, you can embed our Kore chat widget into your applications to enable end-users to interact with your applications using Natural Language. For more information, refer to https://developer.kore.ai/docs/bots/kore-web-sdk/ 

# Kore Bot SDK for iOS developers

Kore Bot SDK for iOS enables you to talk to Kore bots over a web socket. This repo also comes with the code for sample application that developers can modify according to their Bot configuration.

# Setting up
### Prerequisites
* Service to generate JWT (JSON Web Tokens)- SDK uses this to send the user identity to Kore Platform.
* SDK app credentials 
    * Login to the Bots platform
    * Navigate to the Bot builder
    * Search and click on the bot 
    * Go to channels
    * Enable *Web / Mobile Client* channel against the bot as shown in the screen below.    
    ![Add bot to Web/Mobile Client channel](https://github.com/Koredotcom/iOS-kore-sdk/blob/master/channels.png)
    
    * create new or use existing SDK app to obtain client id and client secret
    ![Obtain Client id and Client secret](https://github.com/Koredotcom/iOS-kore-sdk/blob/master/web-mobile-client-channel.png)

## Instructions

## Running the Demo app
#### a. Using Cocoa Pods
    * Download or clone the repository.
    * Run "pod install" in the Examples/CocoapodsDemo project folder.
    * Open Examples/CocoapodsDemo/KoreBotSDKDemo.xcworkspace in Xcode.
    * Run the KoreBotSDKDemo.app in xcode

#### b. Using Carthage
    * Download or clone the repository.
    * Run "carthage update --platform iOS" in the Examples/CarthageDemo project folder.
    * Open Examples/CarthageDemo/KoreBotSDKDemo.xcodeproj in Xcode.
    * Run the KoreBotSDKDemo.app in Xcode

## Integrating into your app
#### 1. Setup KoreBotSDK
###### a. Using CocoaPods
    Add the following to your Podfile:
    pod 'KoreBotSDK', :git => 'https://github.com/Koredotcom/iOS-kore-sdk.git’, :branch => 'KoreLibrary'
    
    Run pod install in your project folder.
###### b. Using Carthage
    Add the following to your Cartfile:
    github "Koredotcom/iOS-kore-sdk" "master"
    
    Run "carthage update --platform iOS" in your project folder.
    
#### 2. Initializing the Bot client
    import KoreBotSDK
    
    let botInfo: [String: Any] = ["chatBot": "<bot-name>", "taskBotId": "<bot-id>"]
    let botClient: BotClient = BotClient()
    botClient.initialize(botInfoParameters: botInfo, customData: [:])
    
    //Setting the server Url
    let botServerUrl: String = "https://bots.kore.ai"
    botClient.setKoreBotServerUrl(url: botServerUrl)

#### 3. JWT generation
    a. You need to have secure token service hosted in your environment which returns the JWT token.
    b. Generate JWT in your enviornment.
To integrate jwt signing in code refer to KoreBotSDKDemo App. - https://github.com/Koredotcom/iOS-kore-sdk/blob/master/Examples/Shared/Controllers/AppLaunch/AppLaunchViewController.swift

NOTE: Please refer about JWT signing and verification at - https://developer.kore.com/docs/bots/kore-web-sdk/

#### 4. Connect with JWT
    self.botClient.connectWithJwToken(jwtToken, intermediary: { [weak self] (client) in
            self?.botClient.connect(isReconnect: false)
        }, success: { (client) in
            print("\(String(describing: client))")
        }, failure: { (error) in
            print("\(String(describing: error))")
        })

#### 5. Send message
    self.botClient.sendMessage("hello", options: [:])
    
#### 6. Listen to events
    self.botClient.onMessage = {  (object) in
        print("botResponse: \(object ?? [:])")
    }
    self.botClient.onMessageAck = { (ack) in
        //"ack" type as "Ack"
    }
    self.botClient.connectionDidClose = { (code, reason) in
        //"code" type as "Int", "reason" type as "String"
    }
    self.botClient.connectionDidFailWithError = { (error) in
        //"error" type as "NSError"
    }
    
#### 7. Subscribe to push notifications
    self.botClient.subscribeToNotifications(deviceToken, success: { (staus) in
        // do something
    }, failure: { (error) in
    })
    
#### 8. Unsubscribe to push notifications
    self.botClient.unsubscribeToNotifications(deviceToken, success: { (staus) in
        // do something
    }, failure: { (error) in
    })

#### 9. getHistory - fetches all the history that the bot has previously based on last messageId whenever the bot is reconnected.
    self.botClient.getHistory(offset: 0, success: { (responseObj) in
        // do something
    }, failure: { (error) in
    })
    

License
----
Copyright © Kore, Inc. MIT License; see LICENSE for further details.
