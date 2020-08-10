//
//  KREWidgetPersistentStoreManager.swift
//  KoreBotSDK
//
//  Created by Srinivas Vasadi on 08/03/19.
//  Copyright © 2019 Srinivas Vasadi. All rights reserved.
//

import UIKit
import CoreData

public class KREWidgetPersistentStoreManager: NSObject {

}

// MARK: -
extension KREWidgetManager {
    // MARK: - widget components
    public func insertOrUpdateWidgetComponent(for widgetFilter: KREWidgetFilter?, in widget: KREWidget?, pagination: Bool = false, with dictionary: [String: Any]?) {
        guard let widgetFilter = widgetFilter,
            let dictionary = dictionary else {
                return
        }
        let jsonDecoder = JSONDecoder()
        if let componentsData = try? JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted) {
            let nWidgetComponent = try? jsonDecoder.decode(KREWidgetComponent.self, from: componentsData)
            
            let jsonDecoder = JSONDecoder()
            var widgetElements: [Decodable] = [Decodable]()
            
            if let templateType = widget?.templateType as? String {
                switch templateType {
                case "chartList", "standard", "custom_style":
                    if let elements = dictionary["elements"] as? Array<[String: Any]>,
                        let data = try? JSONSerialization.data(withJSONObject: elements, options: .prettyPrinted),
                        let commonWidgets = try? jsonDecoder.decode([KRECommonWidgetData].self, from: data) {
                        widgetElements.append(contentsOf: commonWidgets)
                    }
                case "summaryCard":
                    if let elements = dictionary["elements"] as? Array<[String: Any]>,
                        let data = try? JSONSerialization.data(withJSONObject: elements, options: .prettyPrinted),
                        let utterances = try? jsonDecoder.decode([KREAction].self, from: data) {
                        widgetElements.append(contentsOf: utterances)
                    }
                case "task_list":
                    if let elements = dictionary["elements"] as? Array<[String: Any]>,
                        let data = try? JSONSerialization.data(withJSONObject: elements, options: .prettyPrinted),
                        let taskList = try? jsonDecoder.decode([KRETaskListItem].self, from: data) {
                        widgetElements.append(contentsOf: taskList)
                    }
                case "announcement_list":
                    if let elements = dictionary["elements"] as? Array<[String: Any]>,
                        let data = try? JSONSerialization.data(withJSONObject: elements, options: .prettyPrinted),
                        let knowledgeItems = try? jsonDecoder.decode([KREKnowledgeItem].self, from: data) {
                        knowledgeItems.forEach { (knowledgeItem) in
                            knowledgeItem.isAnnounement = true
                        }
                        widgetElements.append(contentsOf: knowledgeItems)
                    }
                case "knowledge_list":
                    if let elements = dictionary["elements"] as? Array<[String: Any]>,
                        let data = try? JSONSerialization.data(withJSONObject: elements, options: .prettyPrinted),
                        let knowledgeItems = try? jsonDecoder.decode([KREKnowledgeItem].self, from: data) {
                        knowledgeItems.forEach { (knowledgeItem) in
                            knowledgeItem.isAnnounement = false
                        }
                        
                        widgetElements.append(contentsOf: knowledgeItems)
                    }
                case "calendar_events":
                    if let elements = dictionary["elements"] as? Array<[String: Any]>,
                        let data = try? JSONSerialization.data(withJSONObject: elements, options: .prettyPrinted),
                        let calendarEvents = try? jsonDecoder.decode([KRECalendarEvent].self, from: data) {
                        widgetElements.append(contentsOf: calendarEvents)
                    }
                case "file_list":
                    if let elements = dictionary["elements"] as? Array<[String: Any]>,
                        let data = try? JSONSerialization.data(withJSONObject: elements, options: .prettyPrinted),
                        let driveFileInfo = try? jsonDecoder.decode([KREDriveFileInfo].self, from: data) {
                        widgetElements.append(contentsOf: driveFileInfo)
                    }
                case "piechart":
                    if let templateType = dictionary["templateType"] as? String, templateType == "piechart" {
                        if let data = try? JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted),
                            let chartData = try? jsonDecoder.decode(KREPieChartData.self, from: data) {
                            widgetElements.append(chartData)
                        }
                    }
                case "linechart":
                    if let templateType = dictionary["templateType"] as? String, templateType == "linechart" {
                        if let data = try? JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted),
                            let chartData = try? jsonDecoder.decode(KRELineChartData.self, from: data) {
                            widgetElements.append(chartData)
                        }
                    }
                case "barchart":
                    if let templateType = dictionary["templateType"] as? String, templateType == "barchart" {
                        if let data = try? JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted),
                            let chartData = try? jsonDecoder.decode(KREBarChartData.self, from: data) {
                            widgetElements.append(chartData)
                        }
                    }
                case "List":
                    if let elements = dictionary["elements"] as? Array<[String: Any]>,
                        let data = try? JSONSerialization.data(withJSONObject: elements, options: .prettyPrinted),
                        let listItems = try? jsonDecoder.decode([KREListItem].self, from: data) {
                        widgetElements.append(contentsOf: listItems)
                    }
                case "meeting_notes":
                    if let elements = dictionary["elements"] as? Array<[String: Any]>,
                        let data = try? JSONSerialization.data(withJSONObject: elements, options: .prettyPrinted),
                        let allElements = try? jsonDecoder.decode([KREMeetingNote].self, from: data) {
                        widgetElements.append(contentsOf: allElements)
                    }
                case "headLines":
                    break
                default:
                    break
                }
            }
            
            if let templateType = dictionary["templateType"] as? String, templateType == "loginURL" {
                if let elementData = try? JSONSerialization.data(withJSONObject: dictionary["login"], options: .prettyPrinted) {
                    let loginWidgetData = try? jsonDecoder.decode(KRELogInData.self, from: elementData)
                    widgetElements.append(loginWidgetData)
                }
                nWidgetComponent?.elements = widgetElements
                widgetFilter.component = nWidgetComponent
            } else if pagination {
                widgetFilter.component?.elements?.append(contentsOf: widgetElements)
                widgetFilter.component?.hasMore = nWidgetComponent?.hasMore
            } else {
                nWidgetComponent?.elements = widgetElements
                widgetFilter.component = nWidgetComponent
            }
            
            if widgetFilter.isSelected == nil {
                widgetFilter.isSelected = false
            }
            
            widget?.lastUpdatedDate = Date() as NSDate

            if let hookDicionary = dictionary["hook"] as? [String: Any], let hookData = try? JSONSerialization.data(withJSONObject: hookDicionary, options: .prettyPrinted),
                let hook = try? jsonDecoder.decode(Hook.self, from: hookData) {
                widgetFilter.hook = hook
            }
        }
    }
    
    
    public func updateWidgetFilter(_ widetFilter: KREWidgetFilter?, completion block:(() -> Void)?) {
        block?()
    }
    
    public func updateWidgetFilter(_ widgetFilter: KREWidgetFilter?, isLoading: Bool) {
        widgetFilter?.isLoading = isLoading
    }
    
    public func updateSelectedWidgetFilter(for widget: KREWidget?) {
        guard var allFilters = widget?.filters as? [KREWidgetFilter] else {
            return
        }
        
        let selectedFilters = allFilters.filter { $0.isSelected == true}
        if selectedFilters.count ?? 0 > 0 {
            return
        }
        
        for filter in allFilters {
            filter.isSelected = false
        }
        
        let filters = allFilters.filter({ $0.component?.elements?.count ?? 0 > 0 })
        if let filter = filters.first {
            filter.isSelected = true
        } else if let filter = allFilters.first {
            filter.isSelected = true
        }
    }
    
    public func updateSelectedWidgetFilter(_ filter: KREWidgetFilter?, in widget: KREWidget?) {
        guard let widget = widget, let filter = filter else {
            return
        }
        
        guard var filters = widget.filters as? [KREWidgetFilter] else {
            return
        }
        
        for index in 0..<filters.count {
            if filters[index].filterId == filter.filterId {
                filters[index].isSelected = true
            } else {
                filters[index].isSelected = false
            }
        }
        
        widget.filters = filters
    }
    
    public func insertOrUpdatePanelItems(with dictionary: [String: Any]?) {
        guard let panelsData = dictionary?["panels"] as? Array<[String: Any]> else {
            return
        }
        
        let jsonDecoder = JSONDecoder()
        guard let jsonData = try? JSONSerialization.data(withJSONObject: panelsData , options: .prettyPrinted),
            let allItems = try? jsonDecoder.decode([KREPanelItem].self, from: jsonData) else {
                return
        }

        let items = allItems.filter({ $0.type != "action" })
        if panelItems == nil {
            panelItems = items
        } else if items.count > 0 {
            // update panel items
            for item in items {
                let results = panelItems?.filter({$0.id == item.id })
                if let panelItem = results?.first {
                    var widgets = [KREWidget]()
                    for widget in item.widgets ?? [] {
                        if let eWidget = panelItem.widgets?.filter({ $0._id == widget._id }).first {
                            eWidget.pinned = widget.pinned
                            widgets.append(eWidget)
                            continue
                        } else {
                            widgets.append(widget)
                        }
                    }
                    item.widgets = widgets
                    item.selectionState = panelItem.selectionState
                }
            }
            panelItems = items
        }
    }
}


// MARK: - sorting
extension KREWidgetManager {
    public func sortMeetingNotes(_ elements: [KREMeetingNote]?) -> [(key: Date, value: [KREMeetingNote])]? {
        guard let elements = elements, elements.count > 0 else {
            return nil
        }
        
        var segregatedDates = [Date: [KREMeetingNote]]()
        for item in elements {
            guard let startTime = item.startTime else {
                continue
            }
            
            let calendar = Calendar.current
            let startKey = calendar.startOfDay(for: Date(milliseconds: startTime))
            let containsKey = segregatedDates.contains { (arg0) -> Bool in
                let (key, value) = arg0
                if key == startKey {
                    return true
                } else {
                    return false
                }
            }
            
            if !containsKey {
                segregatedDates[startKey] = [KREMeetingNote]()
            }
            segregatedDates[startKey]?.append(item)
        }
        return segregatedDates.sorted { (arg0, arg1) -> Bool in
            let (key1, value1) = arg0
            let (key2, value2) = arg1
            return key1 > key2
        }
    }
}
