//
//  KREMeetingNotesTemplateView.swift
//  KoreBotSDK
//
//  Created by Srinivas Vasadi on 07/01/2020.
//  Copyright © 2019 Srinivas Vasadi. All rights reserved.
//

import UIKit

public class KREMeetingNotesTemplateView: UIView {
    // MARK: - properties
    let bundle = Bundle.sdkModule
    public lazy var titleLabel: UILabel = {
        var titleLabel: UILabel = UILabel(frame: .zero)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.textFont(ofSize: 16.0, weight: .medium)
        titleLabel.textColor = UIColor.dark
        titleLabel.numberOfLines = 1
        titleLabel.textAlignment = .left
        titleLabel.lineBreakMode = .byTruncatingTail
        return titleLabel
    }()
    
    public lazy var dateTimeContainerView: UIView = {
        let container = UIView(frame: .zero)
        container.translatesAutoresizingMaskIntoConstraints = false
        return container
    }()
    
    public lazy var participantsContainerView: UIView = {
        let container = UIView(frame: .zero)
        container.translatesAutoresizingMaskIntoConstraints = false
        return container
    }()
    
    public lazy var notesContainerView: UIView = {
        let container = UIView(frame: .zero)
        container.translatesAutoresizingMaskIntoConstraints = false
        return container
    }()
    
    public lazy var dateTimeImageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "timer", in: bundle, compatibleWith: nil)
        return imageView
    }()
    
    public lazy var dateTimeLabel: UILabel = {
        let dateTimeLabel = UILabel(frame: .zero)
        dateTimeLabel.backgroundColor = UIColor.clear
        dateTimeLabel.textColor = UIColor.charcoalGrey
        dateTimeLabel.font = UIFont.textFont(ofSize: 13.0, weight: .medium)
        dateTimeLabel.numberOfLines = 1
        dateTimeLabel.isUserInteractionEnabled = true
        dateTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        return dateTimeLabel
    }()
    
    public lazy var notesLabel: UILabel = {
        var locaLabel: UILabel = UILabel(frame: .zero)
        locaLabel.translatesAutoresizingMaskIntoConstraints = false
        locaLabel.font = UIFont.textFont(ofSize: 13.0, weight: .medium)
        locaLabel.textColor = UIColor.charcoalGrey
        return locaLabel
    }()
    
    public lazy var notesImageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "notes", in: bundle, compatibleWith: nil)
        return imageView
    }()
    
    public lazy var participantsImageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "attendee")
        return imageView
    }()
    
    public lazy var participantsLabel: UILabel = {
        var participantsLabel: UILabel = UILabel(frame: .zero)
        participantsLabel.translatesAutoresizingMaskIntoConstraints = false
        participantsLabel.font = UIFont.textFont(ofSize: 13.0, weight: .medium)
        participantsLabel.textColor = UIColor.charcoalGrey
        return participantsLabel
    }()
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.backgroundColor = .clear
        stackView.distribution = .equalSpacing
        stackView.alignment = .fill
        stackView.spacing = 0.0
        return stackView
    }()
    
    // MARK: - init
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    // MARK: - setup
    public func setup() {
        stackView.addArrangedSubview(titleLabel)
        addDateTimeContainerView()
        addParticipantsContainerView()
        addNotesContainerView()
        addSubview(stackView)
        
        if #available(iOS 11.0, *) {
            stackView.setCustomSpacing(7.0, after: titleLabel)
            stackView.setCustomSpacing(6.0, after: dateTimeContainerView)
            stackView.setCustomSpacing(6.0, after: participantsContainerView)
            stackView.setCustomSpacing(6.0, after: notesContainerView)
        }
        
        let views = ["stackView": stackView]
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-13-[stackView]-13-|", options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-13-[stackView]-13-|", options: [], metrics: nil, views: views))
    }
    
    func addDateTimeContainerView() {
        dateTimeContainerView.addSubview(dateTimeImageView)
        dateTimeContainerView.addSubview(dateTimeLabel)
        
        let views = ["dateTimeImageView": dateTimeImageView, "dateTimeLabel": dateTimeLabel]
        dateTimeContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[dateTimeImageView]-14-[dateTimeLabel]|", options: [], metrics: nil, views: views))
        dateTimeContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[dateTimeImageView]|", options: [], metrics: nil, views: views))
        dateTimeContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[dateTimeLabel]|", options: [], metrics: nil, views: views))
        dateTimeImageView.widthAnchor.constraint(equalToConstant: 19.0).isActive = true
        stackView.addArrangedSubview(dateTimeContainerView)
    }
    
    func addParticipantsContainerView() {
        participantsContainerView.addSubview(participantsImageView)
        participantsContainerView.addSubview(participantsLabel)
        
        let views = ["participantsImageView": participantsImageView, "participantsLabel": participantsLabel]
        participantsContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[participantsImageView]-14-[participantsLabel]|", options: [], metrics: nil, views: views))
        participantsContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[participantsImageView]|", options: [], metrics: nil, views: views))
        participantsContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[participantsLabel]|", options: [], metrics: nil, views: views))
        participantsImageView.widthAnchor.constraint(equalToConstant: 19.0).isActive = true
        stackView.addArrangedSubview(participantsContainerView)
    }
    
    func addNotesContainerView() {
        notesContainerView.addSubview(notesImageView)
        notesContainerView.addSubview(notesLabel)
        
        let views = ["notesImageView": notesImageView, "notesLabel": notesLabel]
        notesContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[notesImageView]-14-[notesLabel]|", options: [], metrics: nil, views: views))
        notesContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[notesImageView]|", options: [], metrics: nil, views: views))
        notesContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[notesLabel]|", options: [], metrics: nil, views: views))
        notesImageView.widthAnchor.constraint(equalToConstant: 19.0).isActive = true
        stackView.addArrangedSubview(notesContainerView)
    }
    
    public func populateTemplateView(_ object: Decodable?, totalElementCount: Int) {
        guard let calendarEvent = object as? KRECalendarEvent else {
            return
        }
        
        titleLabel.text = calendarEvent.title
        dateTimeLabel.text = slotTimeConversion(object)
        notesLabel.text = "Notes from \(totalElementCount) People"
        var attendeeText = String()
        if let attendeesCount = calendarEvent.attendees?.count, attendeesCount > 0 {
            if let firstAttendee = calendarEvent.attendees?.first {
                if let name = firstAttendee.name {
                    attendeeText = name
                    participantsContainerView.isHidden = false
                } else if let email = firstAttendee.email {
                    attendeeText = email.lowercased()
                    participantsContainerView.isHidden = false
                } else {
                    participantsContainerView.isHidden = true
                }
                if (attendeesCount - 1 > 0) {
                    let attendeeCountStr = "\(String(describing: attendeesCount - 1))"
                    if attendeesCount <= 2 {
                        attendeeText = attendeeText + " and " + attendeeCountStr + " other"
                    } else {
                        attendeeText = attendeeText + " and " + attendeeCountStr + " others"
                    }
                }
            }
            participantsLabel.text = attendeeText
        }
    }
    
    func slotTimeConversion(_ element: Decodable?) -> String {
        if let calendarEvent = element as? KRECalendarEvent{
            guard let startTimeInWords = calendarEvent.startTime?.convertUTCDayInWords() else{
                return ""
            }
            guard let startTimeStamp = calendarEvent.startTime?.convertUTCtoDateHourString() else {
                return ""
            }
            guard let endTimeInWords = calendarEvent.endTime?.convertUTCDayInWords() else {
                return ""
            }
            guard let endTimeStamp = calendarEvent.endTime?.convertUTCtoDateHourString() else {
                return ""
            }
            
            if let allDay = calendarEvent.isAllDay {
                if allDay{
                    return startTimeInWords
                }
            }
            
            if KRECalendarEvent.isTimeEqualToWholeDay(calendarEvent.startTime!, calendarEvent.endTime!) {
                return "\(startTimeInWords) - \(endTimeInWords)"
            }
            let milliSecondsof_23_59_59:Int64 = 86399000
            let milliSecondsof_23_59_00:Int64 = 86240000
            let difftime:Int64 = Int64((calendarEvent.endTime! - calendarEvent.startTime!) % milliSecondsof_23_59_59)
            
            if difftime > milliSecondsof_23_59_00 && difftime < milliSecondsof_23_59_59 {
                return "\(startTimeInWords) - \(endTimeInWords)"
            }
            if calendarEvent.multiDay {
                return "\(startTimeInWords), \(startTimeStamp) - \(endTimeInWords), \(endTimeStamp)"
            }
            
            if Int64(calendarEvent.endTime! - calendarEvent.startTime!) < milliSecondsof_23_59_59 {
                return "\(startTimeInWords), \(startTimeStamp) to \(endTimeStamp)"
            }
            
        }
        return ""
    }

}
