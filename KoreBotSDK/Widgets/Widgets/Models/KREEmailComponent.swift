//
//  KREEmailComponent.swift
//  KoreBotSDK
//
//  Created by Srinivas Vasadi on 07/01/2020.
//  Copyright © 2019 Srinivas Vasadi. All rights reserved.
//

import UIKit

// MARK: - Email object
public class KAEmailCardInfo: NSObject, Decodable, Encodable {
    public var from: String?
    public var to: [String]?
    public var cc: [String]?
    public var subject: String?
    public var desc: String?
    public var attachments: [String]?
    public var date: String?
    public var source: String?
    public var msgId: String?
    public var buttons: [KAButtonInfo] = [KAButtonInfo]()

    enum CodingKeys: String, CodingKey {
        case from, to, cc, subject, desc, date, attachments, buttons, components, source, msgId
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(from, forKey: .from)
        try container.encode(to, forKey: .to)
        try container.encode(cc, forKey: .cc)
        try container.encode(subject, forKey: .subject)
        try container.encode(desc, forKey: .desc)
        try container.encode(date, forKey: .date)
        try container.encode(attachments, forKey: .attachments)
        try container.encode(buttons, forKey: .buttons)
        try container.encode(source, forKey: .source)
        try container.encode(msgId, forKey: .msgId)
    }

    required public init(from decoder: Decoder) throws {
        if let values = try? decoder.container(keyedBy: CodingKeys.self){
            from = try? values.decode(String.self, forKey: .from)
            to = try? values.decode([String].self, forKey: .to)
            cc = try? values.decode([String].self, forKey: .cc)
            subject = try? values.decode(String.self, forKey: .subject)
            desc = try? values.decode(String.self, forKey: .desc)
            date = try? values.decode(String.self, forKey: .date)
            attachments = try? values.decode([String].self, forKey: .attachments)
            do {
                buttons = try values.decode([KAButtonInfo].self, forKey: .buttons)
            } catch {
                debugPrint(error.localizedDescription)
            }
            source = try? values.decode(String.self, forKey: .source)
            msgId = try? values.decode(String.self, forKey: .msgId)
        }
    }
}

// MARK: - Button object
public class KAButtonInfo: NSObject, Decodable, Encodable {
    public var action: String?
    public var payload: String?
    public var title: String?
    public var type: String?
    public var dweb: String?
    public var mob: String?
    public var fileType: String?
    enum CodingKeys: String, CodingKey {
        case action, payload, title, type, customData
    }
    
    enum CustomData: String, CodingKey {
        case redirectUrl
    }
    
    enum RedirectUrl: String, CodingKey {
        case dweb, mob
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(action, forKey: .action)
        try container.encode(payload, forKey: .payload)
        try container.encode(title, forKey: .title)
        try container.encode(type, forKey: .type)
        
        var customData = container.nestedContainer(keyedBy: CustomData.self, forKey: .customData)
        var redirectUrl = customData.nestedContainer(keyedBy: RedirectUrl.self, forKey: .redirectUrl)
        try redirectUrl.encode(dweb, forKey: .dweb)
        try redirectUrl.encode(mob, forKey: .mob)
    }

    required public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        do {
            action = try values.decode(String.self, forKey: .action)
        } catch {
            debugPrint(error.localizedDescription)
        }
        do {
            payload = try values.decode(String.self, forKey: .payload)
        } catch {
            debugPrint(error.localizedDescription)
        }
        do {
            title = try values.decode(String.self, forKey: .title)
        } catch {
            debugPrint(error.localizedDescription)
        }
        do {
            type = try values.decode(String.self, forKey: .type)
        } catch {
            debugPrint(error.localizedDescription)
        }
        do {
            let customData = try values.nestedContainer(keyedBy: CustomData.self, forKey: .customData)
            let redirectUrl = try customData.nestedContainer(keyedBy: RedirectUrl.self, forKey: .redirectUrl)
            dweb = try redirectUrl.decode(String.self, forKey: .dweb)
            mob = try redirectUrl.decode(String.self, forKey: .mob)
        } catch {
            debugPrint(error.localizedDescription)
        }
    }
}
