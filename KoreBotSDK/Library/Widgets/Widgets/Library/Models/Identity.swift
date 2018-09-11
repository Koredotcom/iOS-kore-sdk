//
//  Identity.swift
//  KoreBotSDKDemo
//
//  Created by developer@kore.com on 27/05/16.
//  Copyright © 2016 Kore Inc. All rights reserved.
//

import UIKit


public enum IdentityType: Int {
    case user = 1, bot = 2
}

public class Identity: NSObject {
    public var identityType: IdentityType!
    public var identifier: String!
    public var thumbnailImage: UIImage!
    public var fullImage: UIImage!
    public var color: NSString!
    
    public var fullName: NSString!
    public var shortName: NSString!
    public var accountName: NSString!
    
    
    public func identityDictionary(_ identifier: NSString) -> NSDictionary {
        return [:]
    }
    
    public func identity(_ identity: NSString) -> Identity {
        return Identity()
    }
    
    public func allUserIdentities() -> NSArray {
        return []
    }
    
    public func allIdentities() -> NSArray {
        return []
    }
    
    public func initials() -> String {
        return ""
    }
    
    public func uniqueNameInList(_ identityList: NSArray) -> String {
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
