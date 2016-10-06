//
//  ComponentGroup.swift
//  KoreBotSDKDemo
//
//  Created by Srinivas Vasadi on 09/05/16.
//  Copyright © 2016 Kore. All rights reserved.
//

import Foundation

class ComponentGroup : NSObject {
    var components: NSMutableArray!

    override init() {
        super.init()
        self.components = NSMutableArray()
    }

    func componentKind() -> ComponentKind {
        if (self.components.count > 0) {
            let component: Component = self.components.firstObject as! Component
            return component.componentKind
        }
        return .unknown
    }

    func message() -> Message {
        if (self.components.count > 0) {
            let component: Component = self.components.firstObject as! Component
            return component.message
        }
        return Message()
    }
}
