//
//  Component.swift
//  KoreBotSDKDemo
//
//  Created by Srinivas Vasadi on 09/05/16.
//  Copyright © 2016 Kore. All rights reserved.
//

import Foundation
import UIKit

enum ComponentKind : Int {
    case unknown = 1, text = 2, image = 3
}

class Component : NSObject {
    var componentKind: ComponentKind = .unknown
    var message: Message!
    var group: ComponentGroup!
}

class TextComponent : Component {
    var text: NSString!
}


class ImageComponent : Component {
    var imageFile: String!
}
