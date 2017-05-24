# Kore Bot SDK
Kore offers Bots SDKs as a set of platform-specific client libraries that provide a quick and convenient way to integrate Kore Bots chat capability into custom applications.

With just few lines of code, you can embed our Kore chat widget into your applications to enable end-users to interact with your applications using Natural Language. For more information, refer to https://developer.kore.com/docs/bots/kore-web-sdk/ 

# Kore Bot SDK for iOS developers

Kore Bot SDK for iOS enables you to talk to Kore bots over a web socket. This repo also comes with the code for sample application that developers can modify according to their Bot configuration.

# Setting up
### Prerequisites
* Service to generate JWT (JSON Web Tokens)- SDK uses this to send the user identity to Kore Platform.
* SDK app credentials 
	* Login to the Bots platform
	* Navigate to the Bot builder
	* Search and click on the bot 
	* Enable *Web / Mobile Client* channel against the bot as shown in the screen below.	
	![Add bot to Web/Mobile Client channel](https://github.com/Koredotcom/iOS-kore-sdk/blob/master/channels.png)
	
	* create new or use existing SDK app to obtain client id and client secret
	![Obtain Client id and Client secret](https://github.com/Koredotcom/iOS-kore-sdk/blob/master/web-mobile-client-channel.png)




## Instructions

### Configuration changes

* Setting up clientId, clientSecret, botId, chatBotName and identity in KoreBotSDK/KoreBotSDKDemo/SDKConfiguration
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
static let BOT_SERVER = "https://bots.kore.com/";
 ```

Anonymous user - if not anonymous, assign same identity (such as email or phone number) while making a connection
 ```
static bool isAnonymous = false; 
 ```

BOT_SPEECH_SERVER URL
 ```
static let BOT_SPEECH_SERVER = "wss://speech.kore.ai/speechcntxt/ws/speech";
 ```

JWT_SERVER URL - specify the server URL for JWT token generation. This token is used to authorize the SDK client. Refer to documentation on how to setup the JWT server for token generation - e.g. https://jwt-token-server.example.com/
 ```
static let JWT_SERVER = "<jwt-token-server-url>";

```

### Running the Demo app
	* Download or clone the repository.
	* Run "pod install" in the KoreBotSDK project folder.
    * Open KoreBotSDK.xworkspace in Xcode.
    * Run the KoreBotSDKDemo.app in xcode

## Integrating into your app
#### 1. Initialize CocoaPods
    Run pod install in your project folder.
    pod 'KoreBotSDK'
    
#### 2. Iniitializing the Bot client
    import KoreBotSDK
    var self.botClient: BotClient!
    let botInfo: NSDictionary = ["chatBot":"<bot-name>", "taskBotId":"<bot-identifier>"]
    self.botClient = BotClient(botInfoParameters: botInfo)

#### 3. JWT genration
    a. You need to have secure token service hosted in your environment which returns the JWT token.
    b. Generate JWT in your enviornment.

NOTE: Please refer about JWT signing and verification at - https://developer.kore.com/docs/bots/kore-web-sdk/

#### 4. Connect with JWT
    self.botClient.connectWithJwToken(jwToken, success: { (client) in
        // listen to RTM events
 
        }, failure: { (error) in

    })

#### 5. Send message
    botClient.sendMessage("Tweet hello", options: [])
    
#### 6. Listen to events
    self.botClient.onMessage = { [weak self] (object) in
    }
    self.botClient.onMessageAck = { (ack) in
    }
    self.botClient.connectionDidClose = { (code) in
    }
    self.botClient.connectionDidEnd = { (code, reason, error) in
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
                botClient.connectionWillOpen = { () in
                    
                }
                
                botClient.connectionDidOpen = { () in
                    
                }
                
                botClient.onConnectionError = { (error) in
                    
                }
                
                botClient.onMessage = { (object) in
                    
                }
                
                botClient.onMessageAck = { (ack) in
                    
                }
                
                botClient.connectionDidClose = { (code) in
                    
                }
                
                botClient.connectionDidEnd = { (code, reason, error) in
                    
                }
            }, failure: { (error) in

        })

























License
----
Copyright © Kore, Inc. MIT License; see LICENSE for further details.



 
