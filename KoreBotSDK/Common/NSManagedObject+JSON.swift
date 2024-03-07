//
//  NSManagedObject+JSON.swift
//  KoreBotSDK
//
//  Created by Srinivas Vasadi on 08/03/19.
//  Copyright © 2019 Srinivas Vasadi. All rights reserved.
//

import UIKit
import CoreData

public extension NSManagedObject {
    // MARK: - dateFormatter
    class func dateFormatter() -> DateFormatter? {
        var dateFormatter: DateFormatter?
        if dateFormatter == nil {
            dateFormatter = DateFormatter()
            dateFormatter?.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            dateFormatter?.locale = NSLocale.system
        }
        return dateFormatter
    }
    
    // MARK: -
    public func safeSetValues(for keyedValues:[String : Any], WSMap map: [String : Any]) {
        let attributes = entity.attributesByName
        for (attribute, _) in attributes {
            if let actualAttribute = map[attribute] as? String {
                var finalValue: Any? = nil
                
                if let value = keyedValues[actualAttribute] {
                    if value is NSNull {
                        continue
                    }
                    
                    let attributeType = attributes[attribute]?.attributeType
                    if attributeType == .stringAttributeType, let value = value as? NSNumber {
                        finalValue = value.stringValue
                    } else if (attributeType == .integer16AttributeType || attributeType == .integer32AttributeType || attributeType == .integer64AttributeType || attributeType == .booleanAttributeType), let value = value as? String {
                        finalValue = Int(value)
                    } else if (attributeType == .floatAttributeType), let value = value as? String {
                        finalValue = Double(value)
                    } else if attributeType == .stringAttributeType, let value = value as? String {
                        finalValue = value
                    }
                    setValue(finalValue, forKey: attribute)
                }
            }
        }
    }
    
    public func safeSetValues(for keyedValues:[String : Any], WSMap map: [String : Any], dateFormatter: DateFormatter) {
        let attributes = entity.attributesByName
        for (attribute, _) in attributes {
            if let actualAttribute = map[attribute] as? String {
                var finalValue: Any? = nil
                
                if let value = keyedValues[actualAttribute], let attributeType = attributes[attribute]?.attributeType {
                    if  value is NSNull {
                        continue
                    }
                    if attributeType == .stringAttributeType, let value = value as? NSNumber {
                        finalValue = value.stringValue
                    } else if (attributeType == .integer16AttributeType || attributeType == .integer32AttributeType || attributeType == .integer64AttributeType || attributeType == .booleanAttributeType), let value = value as? String {
                        finalValue = Int(value)
                    } else if attributeType == .floatAttributeType, let value = value as? String {
                        finalValue = Double(value)
                    } else if attributeType == .dateAttributeType, let value = value as? String {
                        finalValue = dateFormatter.date(from: value)
                    } else if attributeType == .stringAttributeType, let value = value as? String {
                        finalValue = value
                    }
                    setValue(finalValue, forKey: attribute)
                }
            }
        }
    }
    
    public func safeSetValue(_ value: Any, forKey attribute: String) {
        let attributes = entity.attributesByName
        if let attributeType = attributes[attribute]?.attributeType {
            var finalValue: Any? = value
            if  value is NSNull {
                return
            }
            if attributeType == .stringAttributeType, let value = value as? NSNumber {
                finalValue = value.stringValue
            } else if (attributeType == .integer16AttributeType || attributeType == .integer32AttributeType || attributeType == .integer64AttributeType || attributeType == .booleanAttributeType), let value = value as? String {
                finalValue = Int(value)
            } else if attributeType == .floatAttributeType, let value = value as? String {
                finalValue = Double(value)
            } else if attributeType == .dateAttributeType, let value = value as? String, let dateFormatter = NSManagedObject.dateFormatter() {
                finalValue = dateFormatter.date(from: value)
            }
            setValue(finalValue, forKey: attribute)
        }
    }
}
