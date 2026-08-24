//
//  KRECalendarEvent.swift
//  KoreBotSDK
//
//  Created by Srinivas Vasadi on 13/03/19.
//  Copyright © 2019 Srinivas Vasadi. All rights reserved.
//

import UIKit

public class KRECalendarEvent: NSObject, Decodable {
    public var htmlLink: String?
    public var title: String?
    public var elementId: String?
    public var eventId: String?
    public var date: String?
    public var startTime: Int64?
    public var endTime: Int64?
    public var cursorStartTime: Int64?
    public var cursorEndTime: Int64?
    public var location: String?
    public var color: String?
    public var attendees: [KRECalendarAttendee]?
    public var actions: [KREAction]?
    public var isAllDay: Bool?
    public var slotStartTime: String?
    public var slotEndTime: String?
    public var desc: String?
    public var isSelected: Bool = false
    public var meetJoin: JoinMeeting?
    public var mId: String?
    public var owner: KREContacts?
    public var kId: String?
    public var multiDay:Bool = false
    public var eventDates:[String:Date] = [:]
    public var datesFromToday:[String:Date] = [:]
    public var actionType = ""
    public var today: Date?
    public var defaultAction: KREAction?
    public var nNotes: Int?
    
    public enum DurationKeys: String, CodingKey {
        case startTime = "start"
        case endTime = "end"
    }
    
    public enum DataKeys: String, CodingKey {
        case duration = "duration"
        case color = "color"
        case desc = "description"
        case attendees = "attendees"
        case slotStartTime = "slot_start"
        case slotEndTime = "slot_end"
        case isAllDay = "isAllDay"
        case eventId = "eventId"
        case meetJoin = "meetJoin"
        case htmlLink = "htmlLink"
    }
    
    public enum CalendarEventKeys: String, CodingKey {
        case location = "location"
        case title = "title"
        case data = "data"
        case mId = "meetingId"
        case actions = "actions"
        case elementId = "id"
        case defaultAction = "default_action"
        case cursor = "cursor"
    }
    
    public enum KoraCalendarEventKeys: String, CodingKey {
        case htmlLink = "htmlLink"
        case title = "title"
        case eventId = "eventId"
        case startTime = "duration.start"
        case endTime = "duration.end"
        case location = "where"
        case color = "color"
        case attendees = "attendees"
        case slotStartTime = "slot_start"
        case slotEndTime = "slot_end"
        case duration = "duration"
        case desc = "description"
        case meetJoin = "meetJoin"
        case kId = "meetingNoteId"
        case mId = "mId"
        case isAllDay = "isAllDay"
        case nNotes = "nNotes"
    }
    
    public var asDictionary : [String:Any] {
        let mirror = Mirror(reflecting: self)
        let dict = Dictionary(uniqueKeysWithValues: mirror.children.lazy.map({ (label:String?,value:Any) -> (String,Any)? in
            guard label != nil else { return nil
                
            }
            return (label!,value)
        }).compactMap{ $0 })
        return dict
    }
    
    required public init(from decoder: Decoder) throws {
        super.init()
        let container = try decoder.container(keyedBy: CalendarEventKeys.self)
        title = try? container.decode(String.self, forKey: .title)
        location = try? container.decode(String.self, forKey: .location)
        actions = try? container.decode([KREAction].self, forKey: .actions)
        elementId = try? container.decode(String.self, forKey: .elementId)
        mId = try? container.decode(String.self, forKey: .mId)
        defaultAction = try? container.decode(KREAction.self, forKey: .defaultAction)

        if let dataContainer = try? container.nestedContainer(keyedBy: DataKeys.self, forKey: .data) {
            htmlLink = try? dataContainer.decode(String.self, forKey: .htmlLink)
            eventId = try? dataContainer.decode(String.self, forKey: .eventId)
            meetJoin = try? dataContainer.decode(JoinMeeting.self, forKey: .meetJoin)
            color = try? dataContainer.decode(String.self, forKey: .color)
            desc = try? dataContainer.decode(String.self, forKey: .desc)
            slotStartTime = try? dataContainer.decode(String.self, forKey: .slotStartTime)
            slotEndTime = try? dataContainer.decode(String.self, forKey: .slotEndTime)
            isAllDay = try? dataContainer.decode(Bool.self, forKey: .isAllDay)
            attendees = try? dataContainer.decode([KRECalendarAttendee].self, forKey: .attendees)
            if let durationContainer = try? dataContainer.nestedContainer(keyedBy: DurationKeys.self, forKey: .duration) {
                startTime = try? durationContainer.decode(Int64.self, forKey: .startTime)
                endTime = try? durationContainer.decode(Int64.self, forKey: .endTime)
            }
        } else  {
            let container = try decoder.container(keyedBy: KoraCalendarEventKeys.self)
            htmlLink = try? container.decode(String.self, forKey: .htmlLink)
            title = try? container.decode(String.self, forKey: .title)
            eventId = try? container.decode(String.self, forKey: .eventId)
            location = try? container.decode(String.self, forKey: .location)
            color = try? container.decode(String.self, forKey: .color)
            slotStartTime = try? container.decode(String.self, forKey: .slotStartTime)
            slotEndTime = try? container.decode(String.self, forKey: .slotEndTime)
            attendees = try? container.decode([KRECalendarAttendee].self, forKey: .attendees)
            desc = try? container.decode(String.self, forKey: .desc)
            meetJoin = try? container.decode(JoinMeeting.self, forKey: .meetJoin)
            kId = try? container.decode(String.self, forKey: .kId)
            mId = try? container.decode(String.self, forKey: .mId)
            isAllDay = try? container.decode(Bool.self, forKey: .isAllDay)
            nNotes = try? container.decode(Int.self, forKey: .nNotes)
            if let durationContainer = try? container.nestedContainer(keyedBy: DurationKeys.self, forKey: .duration) {
                startTime = try? durationContainer.decode(Int64.self, forKey: .startTime)
                endTime = try? durationContainer.decode(Int64.self, forKey: .endTime)
            }
        }
        cursorDateChanges(todayDate: Date())
    }

    open func cursorDateChanges(todayDate: Date) {

        if let startTime = startTime, let endTime = endTime, getTotalDays(startTime, endTime) > 1 {
            multiDay = true

            let comps = getStartAndEndDayComponents(startTime, endTime)
            var daysCount = 0.0
            var startDate = Calendar.current.date(from: comps.0)
            if var startDate = startDate, comps != nil {
                startDate = Calendar.current.startOfDay(for: startDate)
                let datesArray = dates(from: comps.0.date!, to: comps.1.date!)
                for day1 in datesArray{
                    let key = dateAccordingToNewFormat(Int64(startDate.timeIntervalSince1970 * 1000))
                    if let key = key {
                        eventDates[key] = startDate
                        let today = Calendar.current.startOfDay(for: todayDate)
                        if today > startDate{
                            datesFromToday[key] = startDate
                        }
                    }
                    startDate = startDate.date(byAddingDays: 1.0)
                }
            }
        }
    }

    func dates(from fromDate: Date, to toDate: Date) -> [Date] {
        var dates: [Date] = []
        var date = fromDate
        
        while date <= toDate {
            dates.append(date)
            guard let newDate = Calendar.current.date(byAdding: .day, value: 1, to: date) else { break }
            date = newDate
        }
        return dates
    }
    
    public func dateAccordingToNewFormat(_ newTime:Int64)->String? {
        if let startTime = newTime as? NSNumber {
            let timeInSeconds = Double(truncating: startTime) / 1000
            let dateTime = Date(timeIntervalSince1970: timeInSeconds)
            return dateTime.formatCalenderEvent(forConversationHeaderinKora: false)?.uppercased()
        }
        return nil
    }
    
    public func dateString(_ cursorDate:Date? = nil) -> String? {
        if let startTime = startTime as? NSNumber {
            let timeInSeconds = Double(truncating: startTime) / 1000
            let dateTime = Date(timeIntervalSince1970: timeInSeconds)
            return dateTime.formatCalenderEvent(forConversationHeaderinKora: false, cursorDate)?.uppercased()
        }
        return nil
    }

    public func dateStringByCursor(cursor: Int64) -> String? {
        if let startTime = cursor as? NSNumber {
            let timeInSeconds = Double(truncating: startTime) / 1000
            let dateTime = Date(timeIntervalSince1970: timeInSeconds)
//            return dateTime.formatCalenderEvent(forConversationHeaderinKora: false)?.uppercased()

            var resultStr = dateTime.formatCalendarEventToReadableString(dateTime)
            resultStr = resultStr.uppercased()
            return resultStr
        }
        return nil
    }

    
    public class func isTimeEqualToWholeDay(_ startMillis:Int64, _ endMillis:Int64) -> Bool{
        let milliSecondsof_23_59_00 = 86240000 // 23:59:00
        let milliSecondsof_23_59_59 = 86399000 // 23:59:59
        if (endMillis - startMillis) < milliSecondsof_23_59_59 && (endMillis - startMillis) > milliSecondsof_23_59_00 {
            return true
        }
        return false
    }

    public func isEventActiveOnGivenDate(_ givenDate:Date) -> Bool {
        var result = false
        if let start = self.startTime, let end = self.endTime {
            var startOfDate = Date(timeIntervalSince1970: Double(start)/1000.0)
            startOfDate = Calendar.current.startOfDay(for: startOfDate)

            var startOfEndDate = Date(timeIntervalSince1970: Double(end)/1000.0)
            startOfEndDate = Calendar.current.startOfDay(for: startOfEndDate)
            
            var startOfGivenDate = Calendar.current.startOfDay(for: givenDate)

            if startOfGivenDate == startOfDate || startOfGivenDate == startOfEndDate{
                return true
            }
            if startOfGivenDate < startOfDate || startOfGivenDate > startOfEndDate {
                return false
            }
            if startOfGivenDate >= startOfDate && startOfGivenDate <= startOfEndDate {
                return true
            }
//            let range = startOfDate...startOfEndDate
//            result =  range.contains(startOfGivenDate)
        }
        return result
    }

    public func getNewTimeFormatForDay(_ today:Date) -> (String, String, String){
        var resultStr : (String, String, String) = ("","","")
        
        if let eventStartTime = startTime, let eventEndTime = endTime {
            let milliSecondsof_23_59_00 = 86240000 // 23:59:00
            let milliSecondsof_23_59_59 = 86399000 // 23:59:59
            if (eventEndTime - eventStartTime) < milliSecondsof_23_59_59 && (eventEndTime - eventStartTime) > milliSecondsof_23_59_00 {
                resultStr = ("All Day","", "")
                return resultStr
            }

            let totalDays = getTotalDays(eventStartTime, eventEndTime)
            if totalDays > 0 &&  totalDays != 1{ // meeting is future event and it has multiple days in given time zone
                let localStartTime = getTimeinTimeZone(eventStartTime)
                let daysRemaining = getTotalDays(Int64(today.timeIntervalSince1970 * 1000) ,eventEndTime)
                
                if (totalDays - daysRemaining) == 0 {
                    let timeStr = KRECalendarEvent.milliSecondsToUTCDateHour(eventStartTime)
                    if let result = timeStr {
                        resultStr = ("From", "\(result)","Day (1/\(totalDays))")
                        if nil != isAllDay {
                            if isAllDay! {
                                resultStr = ("All Day", "","Day (1/\(totalDays))")
                            }
                        }
                    }
                }
                else
                    if daysRemaining > 0 && daysRemaining < totalDays && daysRemaining != 1 {
                        resultStr = ("All Day","", "Day (\(totalDays - daysRemaining + 1)/\(totalDays))")
                    }
                    else{ // last day
                        let eventEndTimeInSeconds = Double(truncating: eventEndTime as NSNumber) / 1000
                        var eventEndDate = Date(timeIntervalSince1970: eventEndTimeInSeconds)
                        let eventEndDateComponent = Calendar.current.dateComponents(in: TimeZone.current, from: eventEndDate)
                        let timeStr = KRECalendarEvent.milliSecondsToUTCDateHour( Int64(eventEndDateComponent.date!.timeIntervalSince1970*1000))
                        if let result = timeStr {
                            resultStr = ("Till", "\(result)", "Day (\(totalDays)/\(totalDays))")
                            if let allDay = isAllDay {
                                if allDay {
                                    resultStr = ("All Day", "","Day (\(totalDays)/\(totalDays))")
                                }
                            }
                        }
                }
            }
        }

        return resultStr
    }
    
    public func getTimeinTimeZone(_ time:Int64) -> DateComponents{
        let starttimeInSeconds = Double(truncating: time as NSNumber) / 1000
        var startDateTime = Date(timeIntervalSince1970: starttimeInSeconds)
        let todayStartDateTime = Calendar.current.startOfDay(for: startDateTime)
        
//        if time < Int64(todayStartDateTime.timeIntervalSince1970 * 1000){
            startDateTime = todayStartDateTime
//        }

        return Calendar.current.dateComponents(in: TimeZone.current, from: startDateTime)
    }
    
    public func getStartOfDayTimeinTimeZone(_ time:Int64) -> DateComponents{
        let starttimeInSeconds = Double(truncating: time as NSNumber) / 1000
        var startDateTime = Date(timeIntervalSince1970: starttimeInSeconds)
        startDateTime = Calendar.current.startOfDay(for: startDateTime)
        return Calendar.current.dateComponents(in: TimeZone.current, from: startDateTime)
    }

    public func getStartAndEndDayComponents(_ startTime:Int64, _ endTime:Int64)->(DateComponents, DateComponents){
        let startDateComponent =  getTimeinTimeZone(startTime)
        let endDateComponent =  getTimeinTimeZone(endTime)
        return (startDateComponent, endDateComponent)
    }
    public func getTotalDays(_ startTime:Int64, _ endTime:Int64)->Int{
        if (endTime - startTime) < 0 {
            return -1
        }
        let (startComponent, endComponent) = getStartAndEndDayComponents(startTime, endTime)
        let cal = Calendar.current
        if let startDate = startComponent.date, let endDate = endComponent.date {
            let components = cal.dateComponents([.day], from: startDate, to: endDate)
            if let dayDifference = components.day {
                return dayDifference + 1
            } else {
                return -1
            }
        }
        return -1
    }
    
    public static func getDateFromString(_ string: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale.current
        dateFormatter.calendar = Calendar.current
        dateFormatter.dateFormat = "EEE, d MMM"
        if let requiredDate = dateFormatter.date(from: string) {
            return requiredDate
        }
        dateFormatter.dateFormat = "EEE, d MMM, yyyy"
        if let requiredDate = dateFormatter.date(from: string) {
            return requiredDate
        }
        dateFormatter.dateFormat = "EEE, MMM d, yyyy"
        if let requiredDate = dateFormatter.date(from: string) {
            return requiredDate
        }
        return nil
    }
    
    public static func milliSecondsToUTCDateHour(_ millis:Int64) -> String? {
        if let millis = millis as? NSNumber {
            let deviceFormat = Date.getDeviceTimeFormat()
            let timeIn12HrFormat = millis.UTCToDateHour()
            if deviceFormat == 12 {
                return timeIn12HrFormat
            }
            else {
                
                let timeIn24HrFormat = Date.convert12HrTo24Hr(timeIn12HrFormat)
                return timeIn24HrFormat
//                let timeInSeconds = Double(truncating: millis) / 1000
//                let dateTime = Date(timeIntervalSince1970: timeInSeconds)
//                let dateFormatter = DateFormatter()
//                dateFormatter.dateFormat = "HH:mm"
//                return dateFormatter.string(from: dateTime)
            }
        }
        return nil
    }
    
    public func startTimeString() -> String? {
        if let startTime = startTime as? NSNumber {
            return startTime.UTCToDateHour()
        }
        return nil
    }
    
    public func endTimeString() -> String? {
        if let endTime = endTime as? NSNumber {
            return endTime.UTCToDateHour()
        }
        return nil
    }
    
    public func slotStartTimeString() -> String? {
        if let slotStartTime = slotStartTime as? NSNumber {
            return slotStartTime.UTCToDateHour()
        }
        return nil
    }
    
    public func slotEndTimeString() -> String? {
        if let slotEndTime = slotEndTime as? NSNumber {
            return slotEndTime.UTCToDateHour()
        }
        return nil
    }
    
    public func slotDateString() -> String? {
        if let startTime = startTime as? NSNumber{
            let timeInSeconds = Double(truncating: startTime) / 1000
            let slotDate = Date(timeIntervalSince1970: timeInSeconds)
            return slotDate.format(forConversationHeaderinKora: false)?.uppercased()
        }
        return nil
    }
}

// MARK: - KRECalendarAttendee
public class KRECalendarAttendee: NSObject, Decodable, Encodable {
    public var email: String?
    public var name: String?
    public var color: String?
    public var firstName: String?
    public var contactId: String?
    public var lastName: String?
    public var optional: Bool?
    public var status: String?
    public var selfUser: Bool?
    public var organizer: Bool?
    public var attendingStatus:Bool? = true
    public var attendeeId: String?

    public enum AttendeeKeys: String, CodingKey {
        case email = "email"
        case name = "name"
        case color = "color"
        case firstName = "firstName"
        case contactId = "id"
        case lastName = "lastName"
        case optional = "optional"
        case status = "status"
        case selfUser = "self"
        case organizer = "organizer"
        case attendingStatus = "attendingStatus"
    }
    
    public enum AttendeeKeysNotes: String, CodingKey {
        case email = "emailId"
        case name = "name"
        case color = "color"
        case firstName = "fN"
        case contactId = "id"
        case lastName = "lN"
        case optional = "optional"
        case status = "status"
        case selfUser = "self"
        case organizer = "organizer"
        case attendingStatus = "attendingStatus"
    }

    required public init(from decoder: Decoder) throws {
        if let container = try? decoder.container(keyedBy: AttendeeKeys.self) {
            email = try? container.decode(String.self, forKey: .email)
            name = try? container.decode(String.self, forKey: .name)
            color = try? container.decode(String.self, forKey: .color)
            firstName = try? container.decode(String.self, forKey: .firstName)
            contactId = try? container.decode(String.self, forKey: .contactId)
            lastName = try? container.decode(String.self, forKey: .lastName)
            optional = try? container.decode(Bool.self, forKey: .optional)
            status = try? container.decode(String.self, forKey: .status)
            selfUser = try? container.decode(Bool.self, forKey: .selfUser)
            organizer = try? container.decode(Bool.self, forKey: .organizer)
            attendingStatus = try? container.decode(Bool.self, forKey: .attendingStatus)
        } else {
            let container = try decoder.container(keyedBy: AttendeeKeysNotes.self)
            email = try? container.decode(String.self, forKey: .email)
            name = try? container.decode(String.self, forKey: .name)
            color = try? container.decode(String.self, forKey: .color)
            firstName = try? container.decode(String.self, forKey: .firstName)
            contactId = try? container.decode(String.self, forKey: .contactId)
            lastName = try? container.decode(String.self, forKey: .lastName)
            optional = try? container.decode(Bool.self, forKey: .optional)
            status = try? container.decode(String.self, forKey: .status)
            selfUser = try? container.decode(Bool.self, forKey: .selfUser)
            organizer = try? container.decode(Bool.self, forKey: .organizer)
            attendingStatus = try? container.decode(Bool.self, forKey: .attendingStatus)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: AttendeeKeys.self)
        try container.encode(email, forKey: .email)
        try container.encode(name, forKey: .name)
        try container.encode(color, forKey: .color)
        try container.encode(firstName, forKey: .firstName)
        try container.encode(lastName, forKey: .lastName)
        try container.encode(optional, forKey: .optional)
        try container.encode(contactId, forKey: .contactId)
        try container.encode(status, forKey: .status)
    }

}

// MARK:- Attendee
public class KRECalendarAttendeeNotes: KREContacts {
    public var firstName: String?
    public var contactId: String?
    public var lastName: String?
    public var optional: Bool?
    public var status: String?
    public var selfUser: Bool?
    public var organizer: Bool?
    public var attendingStatus:Bool? = true
    public var attendeeId: String?
    
    public enum AttendeeKeysNotes: String, CodingKey {
        case email = "emailId"
        case name = "name"
        case color = "color"
        case firstName = "fN"
        case contactId = "id"
        case lastName = "lN"
        case optional = "optional"
        case status = "status"
        case selfUser = "self"
        case organizer = "organizer"
        case attendingStatus = "attendingStatus"
    }
    
    required public init(from decoder: Decoder) throws {
        try super.init(from: decoder)

        let container = try decoder.container(keyedBy: AttendeeKeysNotes.self)
        firstName = try? container.decode(String.self, forKey: .firstName)
        contactId = try? container.decode(String.self, forKey: .contactId)
        lastName = try? container.decode(String.self, forKey: .lastName)
        optional = try? container.decode(Bool.self, forKey: .optional)
        status = try? container.decode(String.self, forKey: .status)
        selfUser = try? container.decode(Bool.self, forKey: .selfUser)
        organizer = try? container.decode(Bool.self, forKey: .organizer)
        attendingStatus = try? container.decode(Bool.self, forKey: .attendingStatus)
    }
}



//MARK: - JoinMeeting
public class JoinMeeting: NSObject, Decodable {
    public var dialIn: String?
    public var meetingUrl: String?
    public enum ActionKeys: String, CodingKey {
        case dialIn = "dialIn"
        case meetingUrl = "meetingUrl"
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ActionKeys.self)
        dialIn = try? container.decode(String.self, forKey: .dialIn)
        meetingUrl = try? container.decode(String.self, forKey: .meetingUrl)
    }
}

// MARK: -
public class KRETimeSlot: NSObject, Decodable, Encodable {
    public var startTime: Int64?
    public var endTime: Int64?
    
    public enum KRETimeSlotKeys: String, CodingKey {
        case startTime = "start"
        case endTime = "end"
    }
    
    required public init(from decoder: Decoder) throws {
        let durationContainer = try decoder.container(keyedBy: KRETimeSlotKeys.self)
        startTime = try? durationContainer.decode(Int64.self, forKey: .startTime)
        endTime = try? durationContainer.decode(Int64.self, forKey: .endTime)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: KRETimeSlotKeys.self)
        try container.encode(startTime, forKey: .startTime)
        try container.encode(endTime, forKey: .endTime)
    }
}

public class KREWorkHour: NSObject, Decodable {
    public var day: Int64?
    public var slots: [KRETimeSlot]?
    
    enum KREWorkHourKeys: String, CodingKey {
        case day = "day"
        case slots = "slots"
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: KREWorkHourKeys.self)
        day = try? container.decode(Int64.self, forKey: .day)
        slots = try? container.decode([KRETimeSlot].self, forKey: .slots)
    }
}

public class KREPickSlotElement: NSObject, Decodable {
    public var workingHours: [KREWorkHour]?
    public var quickSlots: [KRETimeSlot]?
    public var showMore: Bool?
    public var buttons: [KAButtonInfo]?
    
    enum PickSlotDataKeys: String, CodingKey {
        case workingHours = "working_hours"
        case quickSlots = "quick_slots"
        case showMore = "showMore"
        case buttons = "buttons"
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: PickSlotDataKeys.self)
        workingHours = try? container.decode([KREWorkHour].self, forKey: .workingHours)
        quickSlots = try? container.decode([KRETimeSlot].self, forKey: .quickSlots)
        showMore = try? container.decode(Bool.self, forKey: .showMore)
        buttons = try? container.decode([KAButtonInfo].self, forKey: .buttons)
    }
}

public class KREPickSlotData: NSObject, Decodable {
    public var elements: [KREPickSlotElement]?
    public var headerText: String?
    
    enum PickSlotDataKeys: String, CodingKey {
        case elements = "elements"
        case headerText = "text"
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: PickSlotDataKeys.self)
        elements = try? container.decode([KREPickSlotElement].self, forKey: .elements)
        headerText = try? container.decode(String.self, forKey: .headerText)
    }
}

// MARK: -
public extension Int64 {
    public func convertUTCtoDateHourString() -> String {
        let timeInSeconds = Double(integerLiteral: self) / 1000
        let dateTime = Date(timeIntervalSince1970: timeInSeconds)
        let dateString = dateTime.formatAsTime(using: dateTime)
        return dateString
    }
    
    public func convertUTCDayInWords() -> String {
        let timeInSeconds = Double(integerLiteral: self) / 1000
        let dateTime = Date(timeIntervalSince1970: timeInSeconds)
        let dateString = dateTime.formatAsDayShort(using: dateTime)
        return dateString
    }

    public func convertUTCDayInWordsWithYear() -> String {
        let timeInSeconds = Double(integerLiteral: self) / 1000
        let dateTime = Date(timeIntervalSince1970: timeInSeconds)
        let dateString = dateTime.formatAsDayShortDate(using: dateTime)
        return dateString
    }

    func convertUTCtoDateString() -> String {
        let timeInSeconds = Double(integerLiteral: self) / 1000
        let dateTime = Date(timeIntervalSince1970: timeInSeconds)
        
        let dateString = dateTime.formatAsDayShortDate(using: dateTime)
        let dateTomorrowString = Date().formatAsDayShort(using: Date().tomorrow)
        let dateTodayString = Date().formatAsDayShort(using: Date())
        if dateString == dateTomorrowString {
            return "Tomorrow"
        } else if dateString == dateTodayString {
            return "Today"
        }
        return dateString
    }
    
    public func date() -> Date {
        let timeInSeconds = Double(integerLiteral: self) / 1000
        return Date(timeIntervalSince1970: timeInSeconds)
    }
}

public extension Date {
    public var tomorrow: Date {
        let morrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())
        return morrow!
    }
    
    public var yesterday: Date {
        let yester = Calendar.current.date(byAdding: .day, value: -1, to: Date())
        return yester!
    }
}
