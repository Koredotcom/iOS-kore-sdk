//
//  KREMeetingNotesElementViewCell.swift
//  KoreBotSDK
//
//  Created by Srinivas Vasadi on 08/01/2020.
//  Copyright © 2019 Srinivas Vasadi. All rights reserved.
//

import UIKit

public class KREMeetingNotesViewCell: UITableViewCell {
    // MARK: - properties
    let bundle = Bundle.sdkModule
    lazy var meetingNotesView: KREMeetingNotesView = {
        let meetingNotesView = KREMeetingNotesView(frame: .zero)
        meetingNotesView.translatesAutoresizingMaskIntoConstraints = false
        return meetingNotesView
    }()
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.backgroundColor = .clear
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 0.0
        return stackView
    }()
    
    // MARK: - init
    override public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override public func prepareForReuse() {
        super.prepareForReuse()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        meetingNotesView.layoutSubviews()
    }
    
    // MARK: - setup
    func setup() {
        selectionStyle = .none
        contentView.addSubview(stackView)
        
        let views = ["stackView": stackView]
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[stackView]|", options: [], metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[stackView]|", options: [], metrics: nil, views: views))
        
        stackView.addArrangedSubview(meetingNotesView)
    }
}
