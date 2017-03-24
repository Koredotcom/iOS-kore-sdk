# Overview
    This SDK allows you to talk to Bots over a web socket.

# Prerequisites
    - SDK app credentials (Create your SDk app in bot admin console to aquire the client id, client secret, bot identifier.
    - jwt assertion generation methodology. ex: service which will be used in the assertion function injected as part of obtaining the connection.

# Set clientId, clientSecret, botId, chatBotName and identity in KoreBotSDK/KoreBotSDKDemo/SDKConfiguration.
# Set JWT_SERVER in ServerConfigs at KoreBotSDK/KoreBotSDKDemo/SDKConfiguration.
# Running the Demo app
    Run "pod install" in the KoreBotSDK project folder.
    Open KoreBotSDK.xworkspace in Xcode.
    Run the app in xcode

# Integrating into your app
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



 
