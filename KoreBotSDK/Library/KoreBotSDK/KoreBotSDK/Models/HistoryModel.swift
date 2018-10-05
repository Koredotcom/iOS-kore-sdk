//
//  HistoryModel.swift
//  KoreBotSDK
//
//  Created by Sowmya Ponangi on 04/10/18.
//

import UIKit
import Mantle

open class HistoryModel: MTLModel, MTLJSONSerializing {
    @objc open var createdBy: String?
    @objc open var createdOn: Date?
    @objc open var lmodifiedOn: String?
    @objc open var resourceid: String?
    @objc open var tN: String?
    @objc open var type: String?
    @objc open var components: [Components]?
//    @objc open var channels: String?
    @objc open var botId: String?
    @objc open var messageId: String?
    
    
    open static func jsonKeyPathsByPropertyKey() -> [AnyHashable : Any]! {
        return ["createdBy":"createdBy",
                "createdOn":"createdOn",
                "lmodifiedOn":"lmodifiedOn",
                "resourceid":"resourceid",
                "tN":"tN",
                "type":"type",
                "components":"components",
                "botId":"botId",
                "messageId": "_id"
            ]
    }
    @objc open static func componentsJSONTransformer() -> ValueTransformer {
        return MTLJSONAdapter.arrayTransformer(withModelClass: Components.self)
    }
    @objc open static func createdOnJSONTransformer() -> ValueTransformer {
        return MTLValueTransformer.reversibleTransformer(forwardBlock: { (dateString) in
            return self.dateFormatter().date(from: dateString as! String)
        }, reverse: { (date) in
            return nil
        })
    }
    
    open static func dateFormatter() -> DateFormatter {
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return dateFormatter
    }
}
open class Components: MTLModel, MTLJSONSerializing {
    @objc open var data : [String: Any]?
    
    public static func jsonKeyPathsByPropertyKey() -> [AnyHashable : Any]! {
        return ["data": "data"]
    }
}
