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

Google Speech API KEY
 ```
static let API_KEY = "<speech_api_key>"
 ```

JWT_SERVER URL - specify the server URL for JWT token generation. This token is used to authorize the SDK client. Refer to documentation on how to setup the JWT server for token generation - e.g. https://jwt-token-server.example.com/
 ```
static let JWT_SERVER = "<jwt-token-server-url>";
```

## Running the Demo app
	* Download or clone the repository.
	* Run "pod install" in the KoreBotSDK project folder.
	* Open KoreBotSDK.xworkspace in Xcode.
	* Run the KoreBotSDKDemo.app in xcode
	
	Please refer to Build Fixes if you encounter errors running the app.

## Integrating into your app
#### 1. Initialize CocoaPods
	Add the following to your Podfile:
	pod 'KoreBotSDK'
	
	Or to get latest pod changes use:
	pod 'KoreBotSDK', :git => 'https://github.com/Koredotcom/iOS-kore-sdk.git’
	
	Run pod install in your project folder.
    
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

## Build Fixes:
	When running the app, may get few errors due to google api sdk. Please follow these steps:
	* Make sure you are on latest cocoapods and xcode version.
	* Replace any of the following failing import statements:
	
		#import "google/cloud/speech/v1beta1/CloudSpeech.pbobjc.h"
		#import "google/api/Annotations.pbobjc.h"
		#import "google/longrunning/Operations.pbobjc.h"
		#import "google/rpc/Status.pbobjc.h"
		#import "google/protobuf/Duration.pbobjc.h"

	    with the corresponding imports:
	
		#import "CloudSpeech.pbobjc.h"
		#import "Annotations.pbobjc.h"
		#import "Operations.pbobjc.h"
		#import "Status.pbobjc.h"
		#import "Duration.pbobjc.h"
		
		
	Please refer to following link for more information on errors due to google sdk:
	https://github.com/GoogleCloudPlatform/ios-docs-samples/blob/master/speech/Swift/Speech-gRPC-Streaming/BUILDFIXES

License
----
Copyright © Kore, Inc. MIT License; see LICENSE for further details.
