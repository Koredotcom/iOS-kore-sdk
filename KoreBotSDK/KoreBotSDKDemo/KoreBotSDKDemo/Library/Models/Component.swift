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
    case Unknown = 1, Text = 2, Image = 3
}

class Component : NSObject {
    var componentKind: ComponentKind = .Unknown
    var message: Message!
    var group: ComponentGroup!
}

class TextComponent : Component {
    var text: NSString!
}


class ImageComponent : Component {
    var imageFile: String!
}