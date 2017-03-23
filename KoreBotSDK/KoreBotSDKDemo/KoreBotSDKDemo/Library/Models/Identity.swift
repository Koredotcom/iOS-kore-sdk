//
//  Identity.swift
//  KoreBotSDKDemo
//
//  Created by developer@kore.com on 27/05/16.
//  Copyright © 2016 Kore Inc. All rights reserved.
//

import UIKit


enum IdentityType: Int {
    case user = 1, bot = 2
}

class Identity: NSObject {
    var identityType: IdentityType!
    var identifier: String!
    var thumbnailImage: UIImage!
    var fullImage: UIImage!
    var color: NSString!
    
    var fullName: NSString!
    var shortName: NSString!
    var accountName: NSString!
    
    
    func identityDictionary(_ identifier: NSString) -> NSDictionary {
        return [:]
    }
    func identity(_ identity: NSString) -> Identity {
        return Identity()
    }
    func allUserIdentities() -> NSArray {
        return []
    }
    func allIdentities() -> NSArray {
        return []
    }
    
    func initials() -> String {
        return ""
    }
    
    func uniqueNameInList(_ identityList: NSArray) -> String {
        return ""
    }
}


class BotIdentity : Identity {
    var botName: String!
    var thumbnailImageName: String!
    var botCommands: NSArray!
    
    static func identityWithDictionary(_ dictionary: NSDictionary) -> BotIdentity {
        return BotIdentity()
    }
}

class UserIdentity : Identity {

    var firstName: String!
    var lastName: String!
    var imageFilename: String!
    var email: String!

    static func identityWithDictionary(_ dictionary: NSDictionary) -> UserIdentity {
        return UserIdentity()
    }
    
    func firstNameLastInitial() -> String {
        return ""
    }
}
