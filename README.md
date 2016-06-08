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
    
#### 2. Iniitializing the RTM client
    import KoreBotSDK
    var self.botClient: BotClient!
    let token: String = "bearer Y6w*******************"
    let botInfo: NSDictionary = ["chatBot":"Kora","taskBotId":"st-******"]
    self.botClient = BotClient(token: token, botInfoParameters: botInfo)

#### 4. Send message
    botClient.sendMessage("Tweet hello", options: [])
    
#### 5. Listen to events
    self.botClient.onMessage = { [weak self] (object) in
    }
    self.botClient.onMessageAck = { (ack) in
    }
    self.botClient.connectionDidClose = { (code) in
    }
    self.botClient.connectionDidEnd = { (code, reason, error) in
    }
    
#### 6. Subscribe to push notifications
    self.botClient.subscribeToNotifications(deviceToken, success: { (staus) in
        // do something
    }, failure: { (error) in
    })
    
#### 7. Unsubscribe to push notifications
    self.botClient.unsubscribeToNotifications(deviceToken, success: { (staus) in
        // do something
    }, failure: { (error) in
    })

#### 8. Anonymous user login
    let clientId: String = "YOUR_SDK_CLIENTID"
    BotClient.anonymousUserSignIn(clientId, success: { [weak self] (user, authInfo) in
        // Obtain the accessToken from auth info
        let accessToken: String = String(format: "%@ %@", authInfo.tokenType!, authInfo.accessToken!)
    }, failure: { (error) in
    });
     self.botClient.rtmConnection({ (connection) in {
        // listen to RTM events
     }

#### 9. Logged in user
    a. You need to have secure token service hosted in your environment which returns the JWT token.
    b. Replace "jwtUrl" variable value with your STS endpoint in constants.swift file
    c. self.botClient.rtmConnection({ (connection) in {
        // listen to RTM events
     }
    
    



























License
----
Copyright © Kore, Inc. MIT License; see LICENSE for further details.



 
