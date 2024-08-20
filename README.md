# Kore Bot SDK
Kore offers Bots SDKs as a set of platform-specific client libraries that provide a quick and convenient way to integrate Kore Bots chat capability into custom applications.

With just few lines of code, you can embed our Kore chat widget into your applications to enable end-users to interact with your applications using Natural Language. For more information, refer to https://developer.kore.ai/docs/bots/kore-web-sdk/ 

# Kore Bot SDK for iOS developers

Kore Bot SDK for iOS enables you to talk to Kore bots over a web socket. This repo also comes with the code for sample application that developers can modify according to their Bot configuration.

# Requirements

* Mac OS (12.0 or later)
* Minimum Xcode version 13.3.1
* iOS 12.0+

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

### Configuration changes

* If you are using Cocoapods project Setting up clientId, clientSecret, botId, chatBotName and identity in Examples/CocoapodsDemo/KoreBotSDKDemo/ViewController.swift

![SDKConfiguration setup](https://github.com/Koredotcom/iOS-kore-sdk/blob/Appkit/sdk_configuration.png)

(or)

If you are using SPM project Setting up clientId, clientSecret, botId, chatBotName and identity in Examples/SwiftPackageManagerDemo/KoreBotSDKDemo/ViewController.swift

![SDKConfiguration setup](https://github.com/Koredotcom/iOS-kore-sdk/blob/Appkit/sdk_configuration.png)

Client id - Copy this id from Bot Builder SDK Settings ex. cs-5250bdc9-6bfe-5ece-92c9-ab54aa2d4285
 ```
 static let clientId = "<client-id>"
 ```

Client secret - copy this value from Bot Builder SDK Settings ex. Wibn3ULagYyq0J10LCndswYycHGLuIWbwHvTRSfLwhs=
 ```
static let clientSecret = "<client-secret>"
 ```

User identity - this should represent the subject for JWT token that could be an email or phone number in case of known user. In case of anonymous user, this can be a randomly generated unique id.
 ```
static let identity = "<user@example.com>"
 ```

Bot name - copy this value from Bot Builder -> Channels -> Web/Mobile SDK config  ex. "Demo Bot"
 ```
static let chatBotName = "<bot-name>"
 ```

Bot Id - copy this value from Bot Builder -> Channels -> Web/Mobile SDK config  ex. st-acecd91f-b009-5f3f-9c15-7249186d827d
 ```
static let botId = "<bot-id>"
 ```

BOT_SERVER URL- replace it with your server URL, if required
 ```
static let BOT_SERVER = "https://bots.kore.ai";
 ```

Anonymous user - if not anonymous, assign same identity (such as email or phone number) while making a connection
 ```
static bool isAnonymous = false; 
 ```

JWT_SERVER URL - specify the server URL for JWT token generation. This token is used to authorize the SDK client. Refer to documentation on how to setup the JWT server for token generation - e.g. https://jwt-token-server.example.com/
 ```
static let JWT_SERVER = "<jwt-token-server-url>";
```

Enable the webhook channel - This should be either true (in case of Webhook connection) or false (in-case of Socket connection).
  ```
 static bool isWebhookEnabled = false; 
  ```
## Running the Demo app
#### a. Using Cocoa Pods
    * Download or clone the repository.
    * Run "pod install" in the Examples/CocoapodsDemo project folder.
    * Open Examples/CocoapodsDemo/KoreBotSDKDemo.xcworkspace in Xcode.
    * Run the KoreBotSDKDemo.app in xcode

#### b. Using SPM
    * Download or clone the repository.
    * Open Examples/SwiftPackageManagerDemo/KoreBotSDKDemo.xcodeproj in Xcode.
    * Run the KoreBotSDKDemo.app in Xcode

   
## Integrating into your app
#### 1. Setup KoreBotSDK
###### a. Using SPM
        Add local Package(KoreBotSDK) from download project into your project.
###### b. In your ViewController add below lines
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
        

###### a. Using CocoaPods
         Add the following to your Podfile:
        pod 'KoreBotSDK', :git => 'https://github.com/Koredotcom/iOS-kore-sdk.git’, :branch => 'KoreLibrary'
    
         post_install do |installer|
         installer.pods_project.targets.each do |target|
         target.build_configurations.each do |config|
            config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
               end
            end
         end

        Run "pod install" in your project folder.
    
###### b. In your ViewController add below lines
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
