//
//  Component.swift
//  KoreBotSDKDemo
//
//  Created by developer@kore.com on 09/05/16.
//  Copyright © 2016 Kore Inc. All rights reserved.
//

import Foundation
import UIKit

enum ComponentType : Int {
    case text = 1, image = 2, options = 3, quickReply = 4, list = 5, carousel = 6, error = 7, chart = 8, table = 9, minitable = 10, responsiveTable = 11, menu = 12
}

class Component : NSObject {
    var componentType: ComponentType = .text
    var message: Message?
    var payload: String?
    var text: String?

    override init() {
        super.init()
    }
    
    convenience init(_ type: ComponentType) {
        self.init()
        componentType = type
    }
}
