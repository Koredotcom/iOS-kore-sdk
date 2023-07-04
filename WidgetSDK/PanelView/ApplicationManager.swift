//
//  ApplicationManager.swift
//  KoraSDK
//
//  Created by Srinivas Vasadi on 03/03/20.
//  Copyright © 2020 Srinivas Vasadi. All rights reserved.
//

import UIKit

public enum Theme: Int {
    case kora, bmc
    
    public var color: UIColor {
        switch self {
        case .kora:
            return .lightRoyalBlue
        case .bmc:
            return .scarlet
        }
    }
    
    public var barStyle: UIBarStyle {
        switch self {
        case .kora:
            return .default
        case .bmc:
            return .default
        }
    }
}

public enum Trait: Int {
    case kora, bmc
    
    // MARK: -
    public var name: String {
        switch self {
        case .kora:
            return NSLocalizedString("Kora", comment: "Kora")
        case .bmc:
            return NSLocalizedString("BMC Assistant", comment: "BMC Assistant")
        }
    }
    
    public var utterance: String {
        switch self {
        case .kora:
            return NSLocalizedString("Kora", comment: "Kora")
        case .bmc:
            return NSLocalizedString("BMC Assistant", comment: "BMC Assistant")
        }
    }
}

// MARK: - ApplicationManager
public class ApplicationManager: NSObject {
    
}
