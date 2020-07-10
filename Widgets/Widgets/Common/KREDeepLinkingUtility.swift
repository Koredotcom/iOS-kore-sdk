//
//  KREDeepLinkingUtility.swift
//  KoreBotSDK
//
//  Created by Sukhmeet Singh on 28/11/19.
//

import UIKit

class KREDeepLinkingUtility: NSObject {
    func openGoogleDrive(_ driveId: String) {
        let encodeAddress = "\(driveId)".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
        let addressUrlStr = "googledrive://?\(encodeAddress)"
        
        if let addressUrl = URL(string: addressUrlStr) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(addressUrl, options: [:], completionHandler: { (success) in
                    if !success {
                    }
                })
            } else {
                if UIApplication.shared.openURL(addressUrl) {
                    
                } else {
                    
                }
            }
        }
    }
}
