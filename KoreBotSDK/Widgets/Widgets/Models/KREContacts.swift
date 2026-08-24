//
//  KREContacts.swift
//  KoraSDK
//
//  Created by Sowmya Ponangi on 02/07/18.
//  Copyright © 2018 Srinivas Vasadi. All rights reserved.
//

import UIKit

open class KREContacts: NSObject, Decodable {
    public var lN: String?
    public var fN: String?
    public var emailId: String?
    public var id: String?
    public var color: String?
    public var role: String?
    public var privilege: Int32?
    public var label: String?
    public var name: String?
    public var koraUserId: String?
    public var phone: [String]?
    public var title: String?
    public var emailUrl: String?
    public var contactUrl: String?
    public var icon: String?
    public var identity: KREIdentity?

    public var fullName: String {
        let cFirstName = fN?.trimmingCharacters(in: .whitespaces) ?? ""
        let cLastName = lN?.trimmingCharacters(in: .whitespaces) ?? ""
        var fullName = "\(cFirstName) \(cLastName)"
        fullName = fullName.trimmingCharacters(in: .whitespaces)
        
        if fullName.count == 0, let emailId = emailId {
            return emailId
        }
        if fullName.count == 0, let name = name {
            return name
        }
        return fullName
    }
    
    public var initials: String {
        let cFirstName = fN?.trimmingCharacters(in: .whitespaces) ?? ""
        let cLastName = lN?.trimmingCharacters(in: .whitespaces) ?? ""
        var initials = ""
        
        if cFirstName.count > 0 && cLastName.count > 0 {
            let firstNameIndex = cFirstName.index(cFirstName.startIndex, offsetBy: 1)
            let lastNameIndex = cLastName.index(cFirstName.startIndex, offsetBy: 1)
            initials = "\(cFirstName.prefix(upTo: firstNameIndex))\(cLastName.prefix(upTo: lastNameIndex))"
        } else if cFirstName.count > 0 && cLastName.count == 0 {
            let firstNameIndex = cFirstName.index(cFirstName.startIndex, offsetBy: 1)
            initials = "\(cFirstName.prefix(upTo: firstNameIndex))"
        } else if cFirstName.count == 0 && cLastName.count > 0 {
            let lastNameIndex = cLastName.index(cFirstName.startIndex, offsetBy: 1)
            initials = "\(cLastName.prefix(upTo: lastNameIndex))"
        } else if let name = name?.trimmingCharacters(in: .whitespaces), name.count > 0 {
            let nameIndex = name.index(cFirstName.startIndex, offsetBy: 1)
            initials = "\(name.prefix(upTo: nameIndex))"
        } else if let emailId = emailId?.trimmingCharacters(in: .whitespaces), emailId.count > 0 {
            let emailIdIndex = emailId.index(emailId.startIndex, offsetBy: 1)
            initials = "\(emailId.prefix(upTo: emailIdIndex))"
        } else {
            initials = "@"
        }
        return initials
    }
    
    public var contactTitle: String {
        let cFirstName = fN?.trimmingCharacters(in: .whitespaces) ?? ""
        let cLastName = lN?.trimmingCharacters(in: .whitespaces) ?? ""
        var contactTitle = ""
        if let label = label {
            switch label {
            case "person":
                if cFirstName.count > 0, cLastName.count > 0 {
                    contactTitle = "\(cFirstName) \(cLastName)"
                } else if cFirstName.count > 0 {
                    contactTitle = cFirstName
                } else if cLastName.count > 0 {
                    contactTitle = cLastName
                }
            default:
                contactTitle = name ?? ""
            }
        }
        return contactTitle
    }
    
    // MARK: -
    public enum ContactKeys: String, CodingKey {
        case lN = "lN"
        case fN = "fN"
        case color = "color"
        case emailId = "emailId"
        case role = "role"
        case id = "id"
        case privilege = "privilege"
        case label = "label"
        case name = "name"
        case koraUserId = "koraUserId"
        case phone = "phone"
        case title = "title"
        case emailUrl = "emailUrl"
        case contactUrl = "contactUrl"
        case icon = "icon"
    }

    // MARK: - init
    public override init() {
        super.init()
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ContactKeys.self)
        lN = try? container.decode(String.self, forKey: .lN)
        fN = try? container.decode(String.self, forKey: .fN)
        emailId = try? container.decode(String.self, forKey: .emailId)
        color = try? container.decode(String.self, forKey: .color)
        role = try? container.decode(String.self, forKey: .role)
        id = try? container.decode(String.self, forKey: .id)
        privilege = try? container.decode(Int32.self, forKey: .privilege)
        label = try? container.decode(String.self, forKey: .label)
        name = try? container.decode(String.self, forKey: .name)
        koraUserId = try? container.decode(String.self, forKey: .koraUserId)
        phone = try? container.decode([String].self, forKey: .phone)
        title = try? container.decode(String.self, forKey: .title)
        emailUrl = try? container.decode(String.self, forKey: .emailUrl)
        contactUrl = try? container.decode(String.self, forKey: .contactUrl)
        icon = try? container.decode(String.self, forKey: .icon)
    }
}
