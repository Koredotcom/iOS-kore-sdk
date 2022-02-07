//
//  KREMeetingDataSource.swift
//  KoreBotSDK
//
//  Created by Sukhmeet Singh on 31/10/19.
//

import UIKit

public class KREMeetingDataSource: NSObject {
    // MARK: - properties
    public var objects: [KRECalendarEvent] = [KRECalendarEvent]()
    public var allevntsDictDateStr: [String: [KRECalendarEvent]]?
    public var numberOfSection = 0
    public var cursor: Cursor?
    public var dateTimeKeys = [String]()
    
    func parseDataMeeting(objects: [KRECalendarEvent]) -> Int {
        var countElements = 0
        var keysArr: [NSNumber]?
        let calendarElements = objects
        let filteredEvents = calendarElements.filter({ $0.dateString() != nil && $0.startTime != nil })
        let calenderEventDictUTC:[NSNumber: [KRECalendarEvent]] = Dictionary(grouping: filteredEvents, by: { $0.startTime }) as? [NSNumber: [KRECalendarEvent]] ?? [:]
        
        var allevntsDictDate = [String: [KRECalendarEvent]]()
        if let cursorStartDate = cursor?.start, let cursorEndDate = cursor?.end {
            var compareDate = Date(timeIntervalSince1970: Double(cursorStartDate)/1000.0 )
            compareDate = Calendar.current.startOfDay(for: compareDate)
            var endDate = Date(timeIntervalSince1970: Double(cursorEndDate)/1000.0 )
            endDate = Calendar.current.startOfDay(for: endDate)
            
            while compareDate <= endDate {
                var groupEvents = [KRECalendarEvent]()
                for calEvent in filteredEvents{
                    if let calEvent = calEvent as? KRECalendarEvent{
                        if calEvent.isEventActiveOnGivenDate(compareDate) {
                            groupEvents.append(calEvent)
                        }
                    }
                }
                
                groupEvents.sort { (event1, event2) -> Bool in
                    if let start1 = event1.startTime, let start2 = event2.startTime{
                        return start1 < start2
                    }
                    return false
                }
                
                let event = filteredEvents[0]
                let key = event.dateStringByCursor(cursor: Int64(compareDate.timeIntervalSince1970*1000))
                if let key = key, groupEvents.count > 0 {
                    allevntsDictDate[key] = groupEvents
                }
                compareDate = Calendar.current.date(byAdding: .day, value: 1, to: compareDate)!
            }
        }
        if allevntsDictDate.keys.count > 0 {
            
            let result = allevntsDictDate.keys.sorted { (arg0, arg1) -> Bool in
                let key1 = arg0
                let key2 = arg1
                
                if key1 == "TODAY" {
                    return true
                }
                if key2 == "TODAY" {
                    return false
                }
                
                guard let date1 = KRECalendarEvent.getDateFromString(key1),
                    let date2 = KRECalendarEvent.getDateFromString(key2) else {
                        return false
                }
                return date1 < date2
            }
            dateTimeKeys = result
        }
        allevntsDictDateStr = allevntsDictDate
        
        /*
         Sorting the elements insode the dict according to start time
         */
        for key in allevntsDictDateStr!.keys {
            if var eventArray = allevntsDictDateStr![key] as? [KRECalendarEvent] {
                eventArray.sort { (event1:KRECalendarEvent, event2:KRECalendarEvent) -> Bool in
                    return (event1.startTime! - event2.startTime!) < 0
                }
                allevntsDictDateStr![key] = eventArray
            }
        }
        
        var widgets = [KREWidget]()
        let jsonDecoder = JSONDecoder()
        var upcomingMeetingElement = [KRECalendarEvent]()
        var todayMeetingElement = [KRECalendarEvent]()
        
        if let allEventDict = allevntsDictDateStr {
            if let todayEventElements = allEventDict["TODAY"] {
                for element in todayEventElements {
                    let startTime = Double((element.startTime ?? 0) / 1000)
                    let startDate = Date(timeIntervalSince1970: TimeInterval(NSNumber(value: startTime ?? 0)))
                    let endTime = Double((element.endTime ?? 0) / 1000)
                    let endDate = Date(timeIntervalSince1970: TimeInterval(NSNumber(value: endTime ?? 0)))
                    
                    let (h,m,s) = secondsToHoursMinutesSeconds(seconds: calculateTimeDifference(date1: Date(), date2: startDate))
                    if h == 0 {
                        if m <= 5 && m >= 0 && s >= 0 {
                            //Add in upComing Meetings
                            upcomingMeetingElement.append(element)
                        } else {
                            if Date() >= startDate && Date() <= endDate {
                                upcomingMeetingElement.append(element)
                            } else {
                                todayMeetingElement.append(element)
                            }
                        }
                        
                    } else if Date() >= startDate && Date() <= endDate {
                        upcomingMeetingElement.append(element)
                    }
                    else {
                        todayMeetingElement.append(element)
                    }
                }
                if upcomingMeetingElement.count > 0 {
                    //Add upcoming widget
                    countElements = countElements + 1
                }
                if todayMeetingElement.count > 0 {
                    //Add today upcoming meeting element
                    countElements = countElements + 1
                }
            }
            for key in allEventDict.keys {
                if key == "TODAY" {
                    continue
                }
                countElements = countElements + 1
            }
        }
        if let _ = allevntsDictDate["TODAY"] {
            dateTimeKeys.removeFirst()
            allevntsDictDate.removeValue(forKey: "TODAY")
        }
        var timeArray = [String]()
        if upcomingMeetingElement.count > 0 {
            timeArray.append("Next Inline...")
            allevntsDictDate["Next Inline..."] = upcomingMeetingElement
        }
        if todayMeetingElement.count > 0 {
            timeArray.append("Later Today")
            allevntsDictDate["Later Today"] = todayMeetingElement
        }
        timeArray.append(contentsOf: dateTimeKeys)
        dateTimeKeys = timeArray
        allevntsDictDateStr = allevntsDictDate
        numberOfSection = countElements
        return dateTimeKeys.count
    }
    
    func numberOfRows(in section: Int) -> Int {
        let eventDictKey = dateTimeKeys[section]
        if let eventArr = allevntsDictDateStr?[eventDictKey] as? [KRECalendarEvent] {
            return eventArr.count
        }
        return 1
    }
    
    func conditionForNoData() -> Bool {
        if dateTimeKeys.count == 0 {
            return true
        } else {
            return false
        }
    }
    
    func calendarEvent(for indexPath: IndexPath) -> KRECalendarEvent? {
        if dateTimeKeys.count <= indexPath.section  {
            return nil
        }
        let eventDictKey = dateTimeKeys[indexPath.section]
        if let eventArr = allevntsDictDateStr?[eventDictKey] as? [KRECalendarEvent] {
            if eventArr.count <= indexPath.row  {
                return nil
            }
            return eventArr[indexPath.row]
        } else {
            return nil
        }
    }
        
    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    func calculateTimeDifference(date1: Date, date2: Date) -> Int {
        let cal = Calendar.current
        let components = cal.dateComponents([.second], from: date1, to: date2)
        if let diffSeconds = components.second {
            // counter = diffSeconds
            return diffSeconds
        } else {
            return 0
        }
    }
    
}
