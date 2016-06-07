//
//  Identity.swift
//  KoreBotSDKDemo
//
//  Created by Srinivas Vasadi on 27/05/16.
//  Copyright © 2016 Kore. All rights reserved.
//

import UIKit


enum IdentityType: Int {
    case User = 1, Bot = 2
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
    
    
    func identityDictionary(identifier: NSString) -> NSDictionary {
        return [:]
    }
    func identity(identity: NSString) -> Identity {
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
    
    func uniqueNameInList(identityList: NSArray) -> String {
        return ""
    }
}


class BotIdentity : Identity {
    var botName: String!
    var thumbnailImageName: String!
    var botCommands: NSArray!
    
    static func identityWithDictionary(dictionary: NSDictionary) -> BotIdentity {
        return BotIdentity()
    }
}

class UserIdentity : Identity {

    var firstName: String!
    var lastName: String!
    var imageFilename: String!
    var email: String!

    static func identityWithDictionary(dictionary: NSDictionary) -> UserIdentity {
        return UserIdentity()
    }
    
    func firstNameLastInitial() -> String {
        return ""
    }
}
