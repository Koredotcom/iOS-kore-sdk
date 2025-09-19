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

![SDKConfiguration setup](https://github.com/Koredotcom/iOS-kore-sdk/blob/master/sdk_configuration.png)


Client id - Copy this id from Bot Builder SDK Settings.
 ```
 static let clientId = "<client-id>"
 ```

Client secret - copy this value from Bot Builder SDK Settings.
 ```
static let clientSecret = "<client-secret>"
 ```

User identity - this should represent the subject for JWT token that could be an email or phone number in case of known user. In case of anonymous user, this can be a randomly generated unique id.
 ```
static let identity = "<user@example.com>"
 ```

Bot name - copy this value from Bot Builder -> Channels -> Web/Mobile SDK config.
 ```
static let chatBotName = "<bot-name>"
 ```

Bot Id - copy this value from Bot Builder -> Channels -> Web/Mobile SDK config.
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


## Integrating into your app
#### 1. Setup KoreBotSDK
###### a. Using SPM
          dependencies: [
              .package(url: "https://github.com/Koredotcom/iOS-kore-sdk", .upToNextMajor(from: "3.0.9"))
          ]
###### b. In your ViewController add below lines
        1. import KoreBotSDK 
        2. let botConnect = BotConnect() 
        3. Add below lines in button action method
        
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
        
        // MARK: Show Bot window
        botConnect.show()
        
        // MARK: Close Or Minimize Callbacks
        botConnect.closeOrMinimizeEvent = { (eventDic) in
           if let dic = eventDic {
               print(dic)
           }
       }
       
###### c. Customized templates injection:
            // To override existing template or add new template
          botConnect.addCustomTemplates(numbersOfViews: [SampleView1.self],customerTemplaateTypes: ["link"])
        
###### d. Add below permissions in info.plist
        Privacy - Camera Usage Description         ---      Allow access to camera.
        Privacy - Microphone Usage Description     ---      Allow access to microphone.
        Privacy - Photo Library Usage Description  ---      Allow access to photo library.
        Privacy - Speech Recognition Usage Description  --- Speech recognition will be used to determine which words you speak into this device's microphone.

###### a. Using CocoaPods
         Add the following to your Podfile:
         pod 'KoreBotSDK', :git => 'https://github.com/Koredotcom/iOS-kore-sdk.git’
    
         post_install do |installer|
         installer.pods_project.targets.each do |target|
         target.build_configurations.each do |config|
            config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
               end
            end
         end

        Run "pod install" in your project folder.
    
###### b. In your ViewController add below lines
        1. import KoreBotSDK 
        2. let botConnect = BotConnect() 
        3. Add below lines in button action method
        
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
        
        // MARK: Show Bot window
        botConnect.show()
        
        // MARK: Close Or Minimize Callbacks
        botConnect.closeOrMinimizeEvent = { (eventDic) in
           if let dic = eventDic {
               print(dic)
           }
       }
  
###### c. Customized templates injection:
            // To override existing template or add new template
          botConnect.addCustomTemplates(numbersOfViews: [SampleView1.self],customerTemplaateTypes: ["link"])
                
###### d. Add below permissions in info.plist
        Privacy - Camera Usage Description         ---      Allow access to camera.
        Privacy - Microphone Usage Description     ---      Allow access to microphone.
        Privacy - Photo Library Usage Description  ---      Allow access to photo library.
        Privacy - Speech Recognition Usage Description  --- Speech recognition will be used to determine which words you speak into this device's microphone.
    
## SDK V3
   * Use this branch https://github.com/Koredotcom/iOS-kore-sdk/tree/SDKV3
   
## How to integrate KoreBotSDK withoutUI
   * Use this branch https://github.com/Koredotcom/iOS-kore-sdk/tree/KoreLibrary
   
## How to enable API based (webhook channel) message communication
###### a. Enable the webhook channel by following the below link
          https://developer.kore.ai/docs/bots/channel-enablement/adding-webhook-channel/
          
###### b. In your ViewController add below lines
        1. import KoreBotSDK 
        2. let botConnect = BotConnect() 
        3. Add below lines in button action method
        
        let clientId = "<client-id>" // Copy this value from Bot Builder SDK Settings.
        let clientSecret = "<client-secret>" // Copy this value from Bot Builder SDK Settings.
        let botId =  "<bot-id>" // Copy this value from Bot Builder -> Channels -> Web/Mobile Client.
        let chatBotName = "bot-name" // Copy this value from Bot Builder -> Channels -> Web/Mobile Client.
        let identity = "<identity-email> or <random-id>" // This should represent the subject for JWT token. This can be an email or phone number, in case of known user, and in case of anonymous user, this can be a randomly generated unique id.
        let isAnonymous = true // This should be either true (in case of known-user) or false (in-case of anonymous user).
        let isWebhookEnabled = true  // This should be either true (in case of Webhook connection) or false (in-case of Socket connection).
        let customData : [String: Any] = [:]
        let queryParameters: [[String: Any]] = [] //[["ConnectionMode":"Start_New_Resume_Agent"],["q2":"ios"],["q3":"1"]]
        let customJWToken: String = ""  //This should represent the subject for send own JWToken.
        let JWT_SERVER = String(format: "http://<jwt-server-host>/") // Replace it with the actual JWT server URL, if required. Refer to developer documentation for instructions on hosting JWT Server.
        let BOT_SERVER = String(format: "https://bots.kore.ai")
        let Branding_SERVER = String(format: "https://bots.kore.ai")
        
        // MARK: Set Bot Config
        botConnect.initialize(clientId, clientSecret: clientSecret, botId: botId, chatBotName: chatBotName, identity: identity, isAnonymous: isAnonymous, isWebhookEnabled: isWebhookEnabled, JWTServerUrl: JWT_SERVER, BOTServerUrl: BOT_SERVER, BrandingUrl: Branding_SERVER, customData: customData, queryParameters: queryParameters, customJWToken: customJWToken)
        
        // MARK: Show Bot window
        botConnect.show()
        
        // MARK: Close Or Minimize Callbacks
        botConnect.closeOrMinimizeEvent = { (eventDic) in
           if let dic = eventDic {
               print(dic)
           }
       }

License
----
Copyright © Kore, Inc. MIT License; see LICENSE for further details.
