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

### Configuration changes

* Setting up clientId, clientSecret, botId, chatBotName and identity in KoreBotSDK/KoreBotSDKDemo/SDKConfiguration.swift
![SDKConfiguration setup](https://github.com/Koredotcom/iOS-kore-sdk/blob/master/sdk_configuration.png)

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
static let BOT_SERVER = "https://bots.kore.ai/";
 ```

Anonymous user - if not anonymous, assign same identity (such as email or phone number) while making a connection
 ```
static bool isAnonymous = false; 
 ```

JWT_SERVER URL - specify the server URL for JWT token generation. This token is used to authorize the SDK client. Refer to documentation on how to setup the JWT server for token generation - e.g. https://jwt-token-server.example.com/
 ```
static let JWT_SERVER = "<jwt-token-server-url>";
```

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
    pod 'KoreBotSDK'
    
    Or to get latest pod changes use:
    pod 'KoreBotSDK', :git => 'https://github.com/Koredotcom/iOS-kore-sdk.git’
    
    Run pod install in your project folder.
###### b. Using Carthage
    Add the following to your Cartfile:
    github "Koredotcom/iOS-kore-sdk" "master"
    
    Run "carthage update --platform iOS" in your project folder.
    
#### 2. Initializing the Bot client
    import KoreBotSDK
    let botInfo: NSDictionary = ["chatBot":"<bot-name>", "taskBotId":"<bot-identifier>"]
    let botClient: BotClient = BotClient(botInfoParameters: botInfo)

#### 3. JWT generation
    a. You need to have secure token service hosted in your environment which returns the JWT token.
    b. Generate JWT in your enviornment.
To integrate jwt signing in code refer to KoreBotSDKDemo App. - https://github.com/Koredotcom/iOS-kore-sdk/blob/master/KoreBotSDK/KoreBotSDKDemo/KoreBotSDKDemo/Controllers/AppLaunch/AppLaunchViewController.swift

NOTE: Please refer about JWT signing and verification at - https://developer.kore.com/docs/bots/kore-web-sdk/

#### 4. Connect with JWT
    botClient.connectWithJwToken(jwToken, success: { (client) in
        // listen to RTM events
 
    }, failure: { (error) in
        
    })

#### 5. Send message
    botClient.sendMessage("Tweet hello", options: [])
    
#### 6. Listen to events
    self.botClient.onMessage = { [weak self] (object) in
        //"object" type as "BotMessageModel"
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

#### 9. Example
    self.botClient.connectWithJwToken(jwtToken, success: { (client) in
        client.connectionDidOpen = { () in
            
        }
        
        client.connectionReady = { () in
            
        }
        
        client.connectionDidClose = { (code) in
            
        }
        
        client.connectionDidFailWithError = { (error) in
            
        }
        
        client.onMessage = { (object) in
            
        }
        
        client.onMessageAck = { (ack) in
            
        }
    }, failure: { (error) in
        
    })
#### 10. getHistory - fetches all the history that the bot has previously based on last messageId whenever the bot is reconnected.
    self.botClient.getHistory(offset: 0, success: { (responseObj) in
        // do something
    }, failure: { (error) in
    })
    

# Native BotSDK integration in React Native Application
## Steps to integrate :

1) Drag and drop "Common","Controllers","CoreData","Datamodel","Library" and "Resources" into KoreBotSDKDemo folder which is available in Master Branch
2) Add Pod('KoreBotSDK', :build_type => :dynamic_framework, :path => '../BotSDK/') in Podfile
3) At root directory cd ios/ && pod install

## Bridge Creation in React Native Application

4) Create a Native Module “RNViewManager.swift” for Bridge

```
import Foundation
import React
 
class RNViewManager: NSObject {
    var bridge: RCTBridge?
    
    static let sharedInstance = RNViewManager()
    
    func createBridgeIfNeeded() -> RCTBridge {
        if bridge == nil {
            bridge = RCTBridge.init(delegate: self, launchOptions: nil)
        }
        return bridge!
    }
    
    func viewForModule(_ moduleName: String, initialProperties: [String : Any]?) -> RCTRootView {
        let viewBridge = createBridgeIfNeeded()
        let rootView: RCTRootView = RCTRootView(
            bridge: viewBridge,
            moduleName: moduleName,
            initialProperties: initialProperties)
        return rootView
    }
}
 
extension RNViewManager: RCTBridgeDelegate {
    func sourceURL(for bridge: RCTBridge!) -> URL! {
        #if DEBUG
            return URL(string: "http://localhost:8081/index.bundle?platform=ios")
        #else
            return Bundle.main.url(forResource: "main", withExtension: "jsbundle")
        #endif
    }
}
```
5) Create a TestConnectNativeModule.swift class 

```
import Foundation
import React
 
import AFNetworking
import KoreBotSDK
import CoreData
 
@objc(TestConnectNativeModule)
class TestConnectNativeModule: NSObject {
    
    var sessionManager: AFHTTPSessionManager?
    var kaBotClient = KABotClient()
    let botClient = BotClient()
    var user: KREUser?
    let navigationController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController
    
     @objc
    static func requiresMainQueueSetup() -> Bool {
        return true
    }
    
    @objc
    func goToKoreChatViewController (_ reactTag: NSNumber) {
        DispatchQueue.main.async {
            if let _ = RNViewManager.sharedInstance.bridge?.uiManager.view(forReactTag: reactTag) {
                self.show()
            }
        }
    }
    
    // MARK: Initialize Kore SDK
    @objc
    func initialize (_ botID: NSString, bot_name: NSString, client_id: NSString, client_secret: NSString, identity: NSString) {
        DispatchQueue.main.async {
            print("initializeKoreBot: \(botID),\(bot_name),\(client_id),\(client_secret), \(identity)")
                       
        }
    }
}

// MARK: Show KoreSDK
extension TestConnectNativeModule{
 func show(){
//Connect With JWT
botClient.connectWithJwToken(jwToken, success: { (client) in
    // listen to RTM events
 
       }, failure: { (error) in
    
    })
  }
 
}

```

6) Create a TestConnectNative.m class which should extend ”TestConnectNative, TestConnectNativeModule, NSObject”

```
#import <React/RCTBridgeModule.h>
 
@interface RCT_EXTERN_REMAP_MODULE(TestConnectNative, TestConnectNativeModule, NSObject)
 
 
RCT_EXTERN_METHOD(goToKoreChatViewController: (nonnull NSNumber *)reactTag)
RCT_EXTERN_METHOD(initializeKoreBot: (NSString *)bot_id bot_name:(NSString *)bot_name client_id:(NSString *)client_id client_secret:(NSString *)client_secret identity:(NSString *)identity)
 
@end

```
7) Add below  SceneDeledate class Or AppDelegate class for Adding Navigationcontroller to Reactnative Screen

```
self.window = window
        // Set initial view controller from Main storyboard as root view controller of UIWindow
        self.window?.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
        // Present window to screen
        
        let rootView = RNViewManager.sharedInstance.viewForModule(
                   "DemoIntegrateRN",
                   initialProperties: ["message_from_native": ""])
               
        let reactNativeVC = UIViewController()
        reactNativeVC.view = rootView
        let navigationController = UINavigationController(rootViewController: reactNativeVC)
        self.window?.rootViewController = navigationController
        self.window?.makeKeyAndVisible()
```

## Inflating Native Module into React Native .js File

- By the above code you have successfully created a Bridge Module in Native iOS now you have into call the native methods from react native class for that kindly follow as below

- Fetching the native module in react native class

```
const testConnectNative = NativeModules.TestConnectNative;
```

## Initializing The Bot

- To initialize the bot we need to have a botid, botName, identity, clientid and  client secret that can be obtained from Bot builder.

- When user opens the application(React Native) kindly initialize the bot by calling

````
testConnectNative.initialize(bot_id, bot_name, client_id, client_secret, identity);
````

## Chatbot Screen

- When user want to chat with our chat bot by clicking the chat icon provided in screen kindly call this method from react native class

````
DispatchQueue.main.async {
            if let _ = RNViewManager.sharedInstance.bridge?.uiManager.view(forReactTag: reactTag) {
                self.show()
            }
        }

````

- chat window will be presented to the user 

## Appname-Bridging-header.h

- Create bridge header class and Add Below code

```
#import <React/RCTBridgeModule.h>
#import <React/RCTViewManager.h>
#import <React/RCTBridge.h>
#import <React/RCTUIManager.h>
 
 
#import <AFNetworking/AFNetworking.h>
#import <AFNetworking/UIImageView+AFNetworking.h>
 
#import "KREAttributedLabel.h"
#import "KRELayoutManager.h"
#import "KREUtilities.h"
#import "NSMutableAttributedString+KREUtils.h"
#import "KRETypingActivityIndicator.h"
#import "KRETypingStatusView.h"

```

## Run the packager

- To run react native part, you need to first start the development server. To do this, run the following command in the root directory  `npm start`
- From the native app and clicking the button to navigate to react native part, it should load the JavaScript code from the development server and display react native screens.
- Go to ios folder and double click `DemoIntegrateRN.xcworkspace` to run the project.


License
----
Copyright © Kore, Inc. MIT License; see LICENSE for further details.





