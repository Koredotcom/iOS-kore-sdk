////
////  SDKConfiguration.swift
////  KoreBotSDKDemo
////
////  Created by developer@kore.com on 12/16/16.
////  Copyright © 2016 Kore Inc. All rights reserved.
////
//
//import UIKit
//import KoreBotSDK
//
//class SDKConfiguration: NSObject {
//
//    struct dataStoreConfig {
//        static let resetDataStoreOnConnect = true // This should be either true or false. Conversation with the bot will be persisted, if it is false.
//    }
//
//    struct botConfig {
//        static let clientId = "cs-9d910f71-bc6e-5bce-ba56-e46410b260e8" // Copy this value from Bot Builder SDK Settings ex. cs-5250bdc9-6bfe-5ece-92c9-ab54aa2d4285
//
//        static let clientSecret = "1wKImL2f3HjluJLdmKGcCSdhEHhUyujx8msUM5kT2iU=" // Copy this value from Bot Builder SDK Settings ex. Wibn3ULagYyq0J10LCndswYycHGLuIWbwHvTRSfLwhs=
//
//        static let botId =  "st-f3d99f7e-bd6f-5752-848a-e10fb2a0bb23" // Copy this value from Bot Builder -> Channels -> Web/Mobile Client  ex. st-acecd91f-b009-5f3f-9c15-7249186d827d
//
//        static let chatBotName = "9.1 Sanity Bot" // Copy this value from Bot Builder -> Channels -> Web/Mobile Client  ex. "Demo Bot"
//
//        static let identity = "paladiprashanth95@gmail.com"// This should represent the subject for JWT token. This can be an email or phone number, in case of known user, and in case of anonymous user, this can be a randomly generated unique id.
//
//        static let isAnonymous = false // This should be either true (in case of known-user) or false (in-case of anonymous user).
//
//        static let isWebhookEnabled = true // This should be either true (in case of Webhook connection) or false (in-case of Socket connection).
//    }
//
//    struct serverConfig {
//        static let JWT_SERVER = String(format: "https://mk2r2rmj21.execute-api.us-east-1.amazonaws.com/dev/") // Replace it with the actual JWT server URL, if required. Refer to developer documentation for instructions on hosting JWT Server.
//
//        static func koreJwtUrl() -> String {
//            return String(format: "%@users/sts", JWT_SERVER)
//        }
//
//        static let BOT_SERVER = String(format: "https://qa1-bots.kore.ai")
//        public static let KORE_SERVER = String(format: "https://bots.kore.ai/")
//    }
//
//    struct widgetConfig {
//        static let clientId = "<client-id>" // Copy this value from Bot Builder SDK Settings ex. cs-5250bdc9-6bfe-5ece-92c9-ab54aa2d4285
//
//        static let clientSecret = "<client-secret>" // Copy this value from Bot Builder SDK Settings ex. Wibn3ULagYyq0J10LCndswYycHGLuIWbwHvTRSfLwhs=
//
//        static let botId =  "<bot-id>" // Copy this value from Bot Builder -> Channels -> Web/Mobile Client  ex. st-acecd91f-b009-5f3f-9c15-7249186d827d
//
//        static let chatBotName = "<bot-name>" // Copy this value from Bot Builder -> Channels -> Web/Mobile Client  ex. "Demo Bot"
//
//        static let identity = "<identity-email> or <random-id>"// This should represent the subject for JWT token. This can be an email or phone number, in case of known user, and in case of anonymous user, this can be a randomly generated unique id.
//
//        static let isAnonymous = true // This should be either true (in case of known-user) or false (in-case of anonymous user).
//
//        static let isPanelView = false // This should be either true (in case of Show Panel) or false (in-case of Hide Panel).
//    }
//
//    // googleapi speech API_KEY
//    struct speechConfig {
//        static let API_KEY = "<speech_api_key>"
//    }
//}


//
//  SDKConfiguration.swift
//  KoreBotSDKDemo
//
//  Created by developer@kore.com on 12/16/16.
//  Copyright © 2016 Kore Inc. All rights reserved.
//

//import UIKit
//import KoreBotSDK
//
//class SDKConfiguration: NSObject {
//
//    struct dataStoreConfig {
//        static let resetDataStoreOnConnect = true // This should be either true or false. Conversation with the bot will be persisted, if it is false.
//    }
//
//    struct botConfig {
//        static let clientId = "cs-40cf8610-ef67-533c-b061-84af1fef1a79" // Copy this value from Bot Builder SDK Settings ex. cs-5250bdc9-6bfe-5ece-92c9-ab54aa2d4285
//
//        static let clientSecret = "EnQYptKNQJdMMLrNuLaKXCdZSDHMA9SiP72ddM0TgOM=" // Copy this value from Bot Builder SDK Settings ex. Wibn3ULagYyq0J10LCndswYycHGLuIWbwHvTRSfLwhs=
//
//        static let botId =  "st-bb738a13-0846-5d48-aca5-779437c4b022" // Copy this value from Bot Builder -> Channels -> Web/Mobile Client  ex. st-acecd91f-b009-5f3f-9c15-7249186d827d
//
//        static let chatBotName = "Airforce 9.1" // Copy this value from Bot Builder -> Channels -> Web/Mobile Client  ex. "Demo Bot"
//
//        static let identity = "paladiprashanth95@gmail.com"// This should represent the subject for JWT token. This can be an email or phone number, in case of known user, and in case of anonymous user, this can be a randomly generated unique id.
//
//        static let isAnonymous = false // This should be either true (in case of known-user) or false (in-case of anonymous user).
//
//        static let isWebhookEnabled = true // This should be either true (in case of Webhook connection) or false (in-case of Socket connection).
//    }
//
//    struct serverConfig {
//        static let JWT_SERVER = String(format: "https://mk2r2rmj21.execute-api.us-east-1.amazonaws.com/dev/") // Replace it with the actual JWT server URL, if required. Refer to developer documentation for instructions on hosting JWT Server.
//
//        static func koreJwtUrl() -> String {
//            return String(format: "%@users/v2/sts", JWT_SERVER)
//        }
//
//        static let BOT_SERVER = String(format: "https://qa1-bots.kore.ai")
//        public static let KORE_SERVER = String(format: "https://bots.kore.ai/")
//    }
//
//    struct widgetConfig {
//        static let clientId = "<client-id>" // Copy this value from Bot Builder SDK Settings ex. cs-5250bdc9-6bfe-5ece-92c9-ab54aa2d4285
//
//        static let clientSecret = "<client-secret>" // Copy this value from Bot Builder SDK Settings ex. Wibn3ULagYyq0J10LCndswYycHGLuIWbwHvTRSfLwhs=
//
//        static let botId =  "<bot-id>" // Copy this value from Bot Builder -> Channels -> Web/Mobile Client  ex. st-acecd91f-b009-5f3f-9c15-7249186d827d
//
//        static let chatBotName = "<bot-name>" // Copy this value from Bot Builder -> Channels -> Web/Mobile Client  ex. "Demo Bot"
//
//        static let identity = "<identity-email> or <random-id>"// This should represent the subject for JWT token. This can be an email or phone number, in case of known user, and in case of anonymous user, this can be a randomly generated unique id.
//
//        static let isAnonymous = true // This should be either true (in case of known-user) or false (in-case of anonymous user).
//
//        static let isPanelView = false // This should be either true (in case of Show Panel) or false (in-case of Hide Panel).
//    }
//
//    // googleapi speech API_KEY
//    struct speechConfig {
//        static let API_KEY = "<speech_api_key>"
//    }
//}


//import UIKit
//import KoreBotSDK
//
//class SDKConfiguration: NSObject {
//
//    struct dataStoreConfig {
//        static let resetDataStoreOnConnect = true // This should be either true or false. Conversation with the bot will be persisted, if it is false.
//    }
//
//    struct botConfig {
//        static let clientId = "cs-d7008dd8-1261-5775-8494-0540a840155a" // Copy this value from Bot Builder SDK Settings ex. cs-5250bdc9-6bfe-5ece-92c9-ab54aa2d4285
//
//        static let clientSecret = "E9yTROT1J12H5qwpm22Pna3nsGA+iziKwtBgJO6lGto=" // Copy this value from Bot Builder SDK Settings ex. Wibn3ULagYyq0J10LCndswYycHGLuIWbwHvTRSfLwhs=
//
//        static let botId =  "st-9bcf3959-5393-5de6-9af5-23b976bd7176" // Copy this value from Bot Builder -> Channels -> Web/Mobile Client  ex. st-acecd91f-b009-5f3f-9c15-7249186d827d
//
//        static let chatBotName = "Airforce_9.1" // Copy this value from Bot Builder -> Channels -> Web/Mobile Client  ex. "Demo Bot"
//
//        static let identity = "prashanth.paladi@kore.com"// This should represent the subject for JWT token. This can be an email or phone number, in case of known user, and in case of anonymous user, this can be a randomly generated unique id.
//
//        static let isAnonymous = false // This should be either true (in case of known-user) or false (in-case of anonymous user).
//
//        static let isWebhookEnabled = true // This should be either true (in case of Webhook connection) or false (in-case of Socket connection).
//    }
//
//    struct serverConfig {
//        static let JWT_SERVER = String(format: "https://mk2r2rmj21.execute-api.us-east-1.amazonaws.com/dev/") // Replace it with the actual JWT server URL, if required. Refer to developer documentation for instructions on hosting JWT Server.
//
//        static func koreJwtUrl() -> String {
//            return String(format: "%@users/sts", JWT_SERVER)
//        }
//
//        static let BOT_SERVER = String(format: "https://staging-bots.korebots.com")
//        public static let KORE_SERVER = String(format: "https://bots.kore.ai/")
//    }
//
//    struct widgetConfig {
//        static let clientId = "<client-id>" // Copy this value from Bot Builder SDK Settings ex. cs-5250bdc9-6bfe-5ece-92c9-ab54aa2d4285
//
//        static let clientSecret = "<client-secret>" // Copy this value from Bot Builder SDK Settings ex. Wibn3ULagYyq0J10LCndswYycHGLuIWbwHvTRSfLwhs=
//
//        static let botId =  "<bot-id>" // Copy this value from Bot Builder -> Channels -> Web/Mobile Client  ex. st-acecd91f-b009-5f3f-9c15-7249186d827d
//
//        static let chatBotName = "<bot-name>" // Copy this value from Bot Builder -> Channels -> Web/Mobile Client  ex. "Demo Bot"
//
//        static let identity = "<identity-email> or <random-id>"// This should represent the subject for JWT token. This can be an email or phone number, in case of known user, and in case of anonymous user, this can be a randomly generated unique id.
//
//        static let isAnonymous = true // This should be either true (in case of known-user) or false (in-case of anonymous user).
//
//        static let isPanelView = false // This should be either true (in case of Show Panel) or false (in-case of Hide Panel).
//    }
//
//    // googleapi speech API_KEY
//    struct speechConfig {
//        static let API_KEY = "<speech_api_key>"
//    }
//}


import UIKit
import KoreBotSDK

class SDKConfiguration: NSObject {

    struct dataStoreConfig {
        static let resetDataStoreOnConnect = true // This should be either true or false. Conversation with the bot will be persisted, if it is false.
    }

    struct botConfig {
        static let clientId = "cs-bcd0fb97-9e4a-5f93-8d01-feb8ea889b41" // Copy this value from Bot Builder SDK Settings ex. cs-5250bdc9-6bfe-5ece-92c9-ab54aa2d4285

        static let clientSecret = "9inbWqBzFag/RdAqqElRZ/obcruMtSFPlq415PtRcBE=" // Copy this value from Bot Builder SDK Settings ex. Wibn3ULagYyq0J10LCndswYycHGLuIWbwHvTRSfLwhs=

        static let botId =  "st-6e9f5e9d-58b2-5a52-9423-60eb6b90f37f" // Copy this value from Bot Builder -> Channels -> Web/Mobile Client  ex. st-acecd91f-b009-5f3f-9c15-7249186d827d

        static let chatBotName = "Air New" // Copy this value from Bot Builder -> Channels -> Web/Mobile Client  ex. "Demo Bot"

        static let identity = "paladiprashanth95@gmail.com"// This should represent the subject for JWT token. This can be an email or phone number, in case of known user, and in case of anonymous user, this can be a randomly generated unique id.

        static let isAnonymous = false // This should be either true (in case of known-user) or false (in-case of anonymous user).

        static let isWebhookEnabled = true // This should be either true (in case of Webhook connection) or false (in-case of Socket connection).
    }

    struct serverConfig {
        static let JWT_SERVER = String(format: "https://mk2r2rmj21.execute-api.us-east-1.amazonaws.com/dev/") // Replace it with the actual JWT server URL, if required. Refer to developer documentation for instructions on hosting JWT Server.

        static func koreJwtUrl() -> String {
            return String(format: "%@users/v2/sts", JWT_SERVER)
        }

        static let BOT_SERVER = String(format: "https://installer-503-use1.korebots.com")
        public static let KORE_SERVER = String(format: "https://bots.kore.ai/")
    }

    struct widgetConfig {
        static let clientId = "<client-id>" // Copy this value from Bot Builder SDK Settings ex. cs-5250bdc9-6bfe-5ece-92c9-ab54aa2d4285

        static let clientSecret = "<client-secret>" // Copy this value from Bot Builder SDK Settings ex. Wibn3ULagYyq0J10LCndswYycHGLuIWbwHvTRSfLwhs=

        static let botId =  "<bot-id>" // Copy this value from Bot Builder -> Channels -> Web/Mobile Client  ex. st-acecd91f-b009-5f3f-9c15-7249186d827d

        static let chatBotName = "<bot-name>" // Copy this value from Bot Builder -> Channels -> Web/Mobile Client  ex. "Demo Bot"

        static let identity = "<identity-email> or <random-id>"// This should represent the subject for JWT token. This can be an email or phone number, in case of known user, and in case of anonymous user, this can be a randomly generated unique id.

        static let isAnonymous = true // This should be either true (in case of known-user) or false (in-case of anonymous user).

        static let isPanelView = false // This should be either true (in case of Show Panel) or false (in-case of Hide Panel).
    }

    // googleapi speech API_KEY
    struct speechConfig {
        static let API_KEY = "<speech_api_key>"
    }
}
