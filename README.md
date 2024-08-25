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

## Running the Demo app
#### a. Using Swift Packge Manager
    * Open KoreSDKSampleApp.xcodeproj in Xcode.
    * Run the KoreSDKSampleApp.app in xcode


## Integrating into your app
#### 1. Setup KoreBotSDK
###### a. Using Swift Packge Manager
        Add local Package(KoreSDKSampleAppPackage) into your project.
        ###### In ViewController add below lines
        1. import KoreBotSDK 
        2. let botConnect = BotConnect() 
        3. Add below lines in button action method
        
        let clientId = "cs-1e845b00-81ad-5757-a1e7-d0f6fea227e9" // Copy this value from Bot Builder SDK Settings ex. cs-5250bdc9-6bfe-5ece-92c9-ab54aa2d4285
        let clientSecret = "5OcBSQtH/k6Q/S6A3bseYfOee02YjjLLTNoT1qZDBso=" // Copy this value from Bot Builder SDK Settings ex. Wibn3ULagYyq0J10LCndswYycHGLuIWbwHvTRSfLwhs=
        let botId =  "st-b9889c46-218c-58f7-838f-73ae9203488c" // Copy this value from Bot Builder -> Channels -> Web/Mobile Client  ex. st-acecd91f-b009-5f3f-9c15-7249186d827d
        let chatBotName = "SDKBot" // Copy this value from Bot Builder -> Channels -> Web/Mobile Client  ex. "Demo Bot"
        let identity = "rajasekhar.balla@kore.com"// This should represent the subject for JWT token. This can be an email or phone number, in case of known user, and in case of anonymous user, this can be a randomly generated unique id.
        let isAnonymous = true // This should be either true (in case of known-user) or false (in-case of anonymous user).
        let isWebhookEnabled = false // This should be either true (in case of Webhook connection) or false (in-case of Socket connection).
        let customData : [String: Any] = [:]
        let JWT_SERVER = String(format: "https://mk2r2rmj21.execute-api.us-east-1.amazonaws.com/dev/") // Replace it with the actual JWT server URL, if required. Refer to developer documentation for instructions on hosting JWT Server.
        let BOT_SERVER = String(format: "https://bots.kore.ai")
        let Branding_SERVER = String(format: "https://bots.kore.ai")
        
        // MARK: Set Bot Config
        botConnect.initialize(clientId, clientSecret: clientSecret, botId: botId, chatBotName: chatBotName, identity: identity, isAnonymous: isAnonymous, isWebhookEnabled: isWebhookEnabled, JWTServerUrl: JWT_SERVER, BOTServerUrl: BOT_SERVER, BrandingUrl: Branding_SERVER, customData: customData)
        
        // MARK: Bot Connect
        botConnect.show()
        
    
#### 2. Add below lines to get the permissions in info.plist
        a) Privacy - Speech Recognition Usage Description ---  Speech recognition will be used to determine which words you speak into this device's microphone.
        b) Privacy - Microphone Usage Description ---  Allow access to microphone.
        c) Privacy - Photo Library Usage Description ---  Allow access to photo library.
        d) Privacy - Camera Usage Description  ---  Allow access to camera.
   

License
----
Copyright © Kore, Inc. MIT License; see LICENSE for further details.
