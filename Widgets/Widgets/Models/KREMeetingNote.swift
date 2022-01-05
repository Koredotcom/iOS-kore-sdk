//
//  KREMeetingNote.swift
//  KoreBotSDK
//
//  Created by Srinivas Vasadi on 12/04/20.
//  Copyright © 2019 Srinivas Vasadi. All rights reserved.
//

import UIKit

public class KREMeetingNote: NSObject, Decodable {
    public var title: String?
    public var eventId: String?
    public var startTime: Int64?
    public var endTime: Int64?
    public var color: String?
    public var attendees: [KRECalendarAttendee]?
    public var isAllDay: Bool?
    public var meetingNoteId: String?
    public var meetingId: String?
    public var organizer: String?
    public var defaultAction: KREAction?
    public var nNotes: Int?
    
    public enum DurationKeys: String, CodingKey {
        case startTime = "start"
        case endTime = "end"
    }
    
    public enum CalendarEventKeys: String, CodingKey {
        case title = "title"
        case eventId = "eventId"
        case duration = "duration"
        case color = "color"
        case attendees = "attendees"
        case isAllDay = "isAllDay"
        case meetingId = "meetingId"
        case meetingNoteId = "meetingNoteId"
        case organizer = "organizer"
        case defaultAction = "defaultAction"
        case nNotes = "nNotes"
    }
    
    required public init(from decoder: Decoder) throws {
        super.init()
        let container = try decoder.container(keyedBy: CalendarEventKeys.self)
        title = try? container.decode(String.self, forKey: .title)
        eventId = try? container.decode(String.self, forKey: .eventId)
        color = try? container.decode(String.self, forKey: .color)
        attendees = try? container.decode([KRECalendarAttendee].self, forKey: .attendees)
        isAllDay = try? container.decode(Bool.self, forKey: .isAllDay)
        meetingNoteId = try? container.decode(String.self, forKey: .meetingNoteId)
        meetingId = try? container.decode(String.self, forKey: .meetingId)
        organizer = try? container.decode(String.self, forKey: .organizer)
        defaultAction = try? container.decode(KREAction.self, forKey: .defaultAction)
        nNotes = try? container.decode(Int.self, forKey: .nNotes)

        if let durationContainer = try? container.nestedContainer(keyedBy: DurationKeys.self, forKey: .duration) {
            startTime = try? durationContainer.decode(Int64.self, forKey: .startTime)
            endTime = try? durationContainer.decode(Int64.self, forKey: .endTime)
        }
    }
}
