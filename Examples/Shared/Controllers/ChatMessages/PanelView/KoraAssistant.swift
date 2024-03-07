//
//  KoraAssistant.swift
//  KoraSDK
//
//  Created by Srinivas Vasadi on 27/03/18.
//  Copyright © 2018 Srinivas Vasadi. All rights reserved.
//

import UIKit
import KoreBotSDK

public class KoraAssistant: NSObject {
    // MARK: - properties
    public static var shared = KoraAssistant()
    
    public var theme: Theme = .kora
    public var trait: Trait = .kora
    
    public var version: String?
    
    public var applicationHeader: String {
        let timezoneIdentifier = TimeZone.current.identifier
        var header = "channel=iOS;"
        if let version = version {
            header += "version=\(version);"
        }
        header += "tz=\(timezoneIdentifier)"
        return header
    }
    
    // MARK: -
    public func updateAnalytics(activityInfo: KREActivityInfo?, completion block:((Bool)->Void)? = nil) {
        guard let activityInfo = activityInfo else {
            return
        }
        
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = .prettyPrinted
        guard let data = try? jsonEncoder.encode(activityInfo),
            let parameters = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
                block?(false)
                return
        }
        
        updateAnalytics(with: parameters) { (sucess) in
            debugPrint("sucess: \(sucess)")
        }
    }
    
    public func updateAnalytics(with parameters: [String: Any]?, completion block:((Bool)->Void)?) {
//        let account = KoraApplication.sharedInstance.account
//        let _ = account?.doPostKoraActivity(parameters: parameters, completion: { (responseObject, error) in
//            debugPrint("response Object: \(responseObject)")
//            let success = (error == nil) ? true : false
//            block?(success)
//        })
    }
}
