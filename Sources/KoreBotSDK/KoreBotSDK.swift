//
//  KoreBotSDK.swift
//  KoreBotSDK
//
//  Created by developer@kore.com on 09/05/16.
//  Copyright © 2016 Kore Inc. All rights reserved.
//

import Foundation
import UIKit

public class KoreBotSDK: NSObject {
    
    // MARK:- init
    public override init() {
        super.init()
    }
}

public extension Bundle {
#if SWIFT_PACKAGE
    static var sdkModule = Bundle.module
    static func xib(named name: String) -> UINib? {
        if let path = Bundle.module.path(forResource: name, ofType: "nib") {
            return UINib(nibName: name, bundle: Bundle.module)
        }
        return nil
    }
#else
    static var sdkModule = KREResourceLoader.shared.resourceBundle()
    static func xib(named name: String) -> UINib? {
        if let path = sdkModule.path(forResource: name, ofType: "nib") {
            return UINib(nibName: name, bundle: sdkModule)
        }
        return nil
    }
#endif
    
}

@objc public class KREResourceLoader: NSObject {
    public static let shared = KREResourceLoader()
    
    // MARK: - init
    override init() {
        super.init()
    }
    
    @objc public func resourceBundle() -> Bundle {
        let bundleName = "KoreBotSDK"
        let appBundle = Bundle(for: KREResourceLoader.self)
        if let bundleUrl = appBundle.url(forResource: bundleName, withExtension: "bundle"),
           let bundle = Bundle(url: bundleUrl) {
            return bundle
        } else {
            return appBundle
        }
    }
}
