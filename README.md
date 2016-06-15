# Overview
    This SDK allows you to talk to Bots over a web socket.

# Prerequisites
    - SDK app credentials (Create your SDk app in bot admin console to aquire the client id and client secret.
    - jwt assertion generation methodology. ex: service which will be used in the assertion function injected as part of obtaining the connection.
    
# Running the Demo app
    Run pod install in the KoreBotSDKDemo project folder.
    Open KoreBotSDKDemo.xworkspace in Xcode.
    Run the app in xcode

# Integrating into your app
#### 1. Initialize CocoaPods
    Run pod install in your project folder.
    pod 'KoreBotSDK'
    
#### 2. Iniitializing the Bot client
    import KoreBotSDK
    var self.botClient: BotClient!
    let token: String = "bearer Y6w*******************"
    let botInfo: NSDictionary = ["chatBot":"Kora","taskBotId":"st-******"]
    self.botClient = BotClient(botInfoParameters: botInfo)

#### 3. Logged in user
    a. You need to have secure token service hosted in your environment which returns the JWT token.
    b. Replace "jwtUrl" variable value with your STS endpoint in constants.swift file
    c. self.botClient.connectAsAuthenticatedUser(jwtToken, success: { [weak self] (botClient) in
            // listen to RTM events

            }, failure: { (error) in

        })

#### 4. Anonymous user login
    let clientId: String = "YOUR_SDK_CLIENTID"
    self.botClient.connectAsAnonymousUser(clientId, success: { [weak self] (client) in
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
    a. As a logged in user
        self.botClient.connectAsAuthenticatedUser(jwtToken, success: { [weak self] (botClient) in
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

    b. As a anonymous user
        self.botClient.connectAsAnonymousUser(clientId, success: { [weak self] (botClient) in
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



 
