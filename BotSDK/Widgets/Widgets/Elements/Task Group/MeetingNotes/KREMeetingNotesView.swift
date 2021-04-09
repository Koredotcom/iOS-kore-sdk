//
//  KREMeetingNotesView.swift
//  KoreBotSDK
//
//  Created by Prabhakar Katlakunta on 5/8/20.
//

import UIKit

public class KREMeetingNotesView: UIView {
    // MARK: -
    let bundle = Bundle(for: KREMeetingNotesView.self)
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
    
    lazy var horizontalStack : UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.backgroundColor = .clear
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 0.0
        return stackView
    }()
    
    lazy var verticalLine : UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.lightRoyalBlue
        return view
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
        addNotesContainerView()
        addSubview(stackView)
        addSubview(verticalLine)

        if #available(iOS 11.0, *) {
            stackView.setCustomSpacing(7.0, after: titleLabel)
            stackView.setCustomSpacing(6.0, after: dateTimeContainerView)
            stackView.setCustomSpacing(6.0, after: notesContainerView)
        }
        
        let stackviews = ["stackView": stackView, "verticalLine":verticalLine]
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[verticalLine(2.0)]-10-[stackView]-|", options: [], metrics: nil, views: stackviews))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-15-[stackView]-13-|", options: [], metrics: nil, views: stackviews))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-20-[verticalLine(20)]", options: [], metrics: nil, views: stackviews))
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
    
    public func populateView(_ object: Decodable?) {
        guard let meetingNote = object as? KREMeetingNote else {
            return
        }
        
        titleLabel.text = meetingNote.title ?? NSLocalizedString("No title", comment: "Notes")
        dateTimeLabel.text = slotTimeConversion(meetingNote)
        if let nNotes = meetingNote.nNotes, nNotes > 0 {
            switch nNotes {
            case 1:
                notesLabel.text = String(format: NSLocalizedString("Notes from %ld Attendee", comment: "Notes"), nNotes)
            default:
                notesLabel.text = String(format: NSLocalizedString("Notes from %ld Attendees", comment: "Notes"), nNotes)
            }
        } else {
            notesLabel.text = NSLocalizedString("No Notes", comment: "No Notes")
        }
        
        if let color = meetingNote.color {
            let color = UIColor(hexString: color)
            verticalLine.backgroundColor = color
        }
        
        var attendeeText = String()
        if let attendeesCount = meetingNote.attendees?.count, attendeesCount > 0 {
            if let firstAttendee = meetingNote.attendees?.first {
                if let name = firstAttendee.name {
                    attendeeText = name
                } else if let email = firstAttendee.email {
                    attendeeText = email.lowercased()
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
        }
    }
    
    func slotTimeConversion(_ element: KREMeetingNote) -> String {
        guard let startTime = element.startTime, let endTime = element.endTime else {
            return ""
        }
        
        let startTimeInWords = startTime.convertUTCDayInWords()
        let startTimeStamp = startTime.convertUTCtoDateHourString()
        let endTimeInWords = endTime.convertUTCDayInWords()
        let endTimeStamp = endTime.convertUTCtoDateHourString()
        
        if element.isAllDay == true {
            return "\(startTimeInWords), 12:00 AM - 11:59 PM"
        }
        
        let startDate = startTime.date()
        let endDate = endTime.date()
        let calendar = Calendar.current
        if calendar.isDate(startDate, inSameDayAs: endDate) {
            return "\(startTimeInWords), \(startTimeStamp) to \(endTimeStamp)"
        } else {
            return "\(startTimeInWords), \(startTimeStamp) to \(endTimeInWords) \(endTimeStamp)"
        }
    }
}
