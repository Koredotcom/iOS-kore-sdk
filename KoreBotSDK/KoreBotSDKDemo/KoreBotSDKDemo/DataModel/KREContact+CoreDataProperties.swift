//
//  KREContact+CoreDataProperties.swift
//  KoreBotSDKDemo
//
//  Created by developer@kore.com on 21/11/16.
//  Copyright © 2016 Kore Inc. All rights reserved.
//

import Foundation
import CoreData


extension KREContact {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<KREContact> {
        return NSFetchRequest<KREContact>(entityName: "KREContact");
    }

    @NSManaged public var contactId: String?
    @NSManaged public var firstName: String?
    @NSManaged public var identity: String?
    @NSManaged public var lastName: String?

}
