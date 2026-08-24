//
//  ComponentModel.swift
//  KoreBotSDK
//
//  Created by developer@kore.com on 30/05/16.
//  Copyright © 2016 Kore Inc. All rights reserved.
//

import UIKit
import ObjectMapper

open class ComponentModel: Mappable {
    
    // MARK: - properties
    @objc open var type: String?
    @objc open var body: String?
    @objc open var payload: Any?
    
    // MARK: -
    public init() {
        
    }
    
    public required init?(map: Map) {
        
    }
    
    public func mapping(map: Map) {
        type <- map["type"]
        body <- map["body"]
        payload <- map["payload"]
    }
}
