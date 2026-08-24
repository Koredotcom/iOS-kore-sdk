//
//  KREComponent+CoreDataProperties.swift
//  KoreBotSDKDemo
//
//  Created by developer@kore.com on 21/11/16.
//  Copyright © 2016 Kore Inc. All rights reserved.
//

import Foundation
import CoreData


extension KREComponent {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<KREComponent> {
        return NSFetchRequest<KREComponent>(entityName: "KREComponent")
    }

    @NSManaged public var componentDesc: String?
    @NSManaged public var componentId: String?
    @NSManaged public var componentInfo: String?
    @NSManaged public var message: KREMessage?

}
