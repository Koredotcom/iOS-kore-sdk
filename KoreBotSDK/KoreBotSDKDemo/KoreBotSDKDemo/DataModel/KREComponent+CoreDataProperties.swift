//
//  KREComponent+CoreDataProperties.swift
//  KoreBotSDKDemo
//
//  Created by Srinivas Vasadi on 21/11/16.
//  Copyright © 2016 Kore. All rights reserved.
//

import Foundation
import CoreData


extension KREComponent {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<KREComponent> {
        return NSFetchRequest<KREComponent>(entityName: "KREComponent");
    }

    @NSManaged public var componentDesc: String?
    @NSManaged public var componentId: String?
    @NSManaged public var message: KREMessage?

}
