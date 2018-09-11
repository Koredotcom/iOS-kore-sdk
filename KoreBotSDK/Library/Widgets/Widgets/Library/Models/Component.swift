//
//  Component.swift
//  KoreBotSDKDemo
//
//  Created by developer@kore.com on 09/05/16.
//  Copyright © 2016 Kore Inc. All rights reserved.
//

import Foundation
import UIKit

public enum ComponentType : Int {
    case text = 1, image = 2, options = 3, quickReply = 4, list = 5, carousel = 6, error = 7, chart = 8, table = 9, minitable = 10, responsiveTable = 11, menu = 12, picker = 13
}

open class Component : NSObject {
    public var componentType: ComponentType = .text
    public var message: Message?
    public var payload: String?
    
    public override init() {
        super.init()
    }
    
    public convenience init(_ type: ComponentType) {
        self.init()
        componentType = type
    }
}
