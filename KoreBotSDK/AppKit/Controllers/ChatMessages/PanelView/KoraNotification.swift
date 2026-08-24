//
//  KoraNotification.swift
//  KoraSDK
//
//   Created by Kartheek on 30/06/20.
//  Copyright © 2019 Srinivas Vasadi. All rights reserved.
//

import UIKit

public class KoraNotification: NSObject {
    public enum Widget: Int {
        case update, event
        
        public var description: String {
            switch self {
            case .event:
                return "Event"
            case .update:
                return "Update"
            }
        }
        
        public var notification: NSNotification.Name {
            switch self {
            case .update:
                return NSNotification.Name(rawValue: Widget.update.description)
            case .event:
                return NSNotification.Name(rawValue: Widget.event.description)
            }
        }
    }
    
    public enum Panel: Int {
        case update, event
        
        public var description: String {
            switch self {
            case .event:
                return "Event"
            case .update:
                return "Update"
            }
        }
        
        public var notification: NSNotification.Name {
            switch self {
            case .update:
                return NSNotification.Name(rawValue: Widget.update.description)
            case .event:
                return NSNotification.Name(rawValue: Widget.event.description)
            }
        }
    }
}

func KALocalized(_ string: String) -> String {
    return NSLocalizedString(string, comment: string)
}
