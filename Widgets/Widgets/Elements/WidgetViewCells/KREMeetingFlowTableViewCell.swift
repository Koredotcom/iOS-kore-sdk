//
//  KREMeetingFlowTableViewCell.swift
//  KoreBotSDK
//
//  Created by Sukhmeet Singh on 16/06/20.
//

import UIKit

public class KREMeetingFlowTableViewCell: UITableViewCell {
    // MARK: - properties
    lazy var meetingFollowUpView: KREMeetingFollowUpView = {
        let meetingFollowUpView = KREMeetingFollowUpView(frame: .zero)
        meetingFollowUpView.translatesAutoresizingMaskIntoConstraints = false
        return meetingFollowUpView
    }()
    
    
    
    // MARK: - init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    
    public override func prepareForReuse() {
        super.prepareForReuse()
      //  listWidgetView.prepareForReuse()
    }
    
    // MARK: - setup
    public func initialize() {
        contentView.addSubview(meetingFollowUpView)
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[meetingFollowUpView]|", options: [], metrics: nil, views: ["meetingFollowUpView": meetingFollowUpView]))
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[meetingFollowUpView]|", options: [], metrics: nil, views: ["meetingFollowUpView": meetingFollowUpView]))
        meetingFollowUpView.testData()
    }
        
    override public func layoutSubviews() {
        super.layoutSubviews()
    }
    
    public func testData() {
        meetingFollowUpView.titleLabel.text = "Catch-Up"
        meetingFollowUpView.dateTimeLabel.text = "Oct 12, 9:30am - 10:00am\nOct 12, 10:30am - 11:00am\nOct 12, 11:30am - 12:00pm"
        meetingFollowUpView.noOFPeopleLabel.text = "4 People Responded"
        meetingFollowUpView.layoutSubviews()
    }

}
