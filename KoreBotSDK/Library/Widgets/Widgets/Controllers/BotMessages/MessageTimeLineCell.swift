//
//  MessageTimeLineCell.swift
//  Widgets
//
//  Created by Srinivas Vasadi on 19/09/18.
//  Copyright © 2018 Kore. All rights reserved.
//

import UIKit

class MessageTimeLineCell: UITableViewCell {
    var subView: UIView = UIView(frame: .zero)
    var timeLineLabel: UILabel = UILabel(frame: .zero)
    var leftLineView: UIView = UIView(frame: .zero)
    var rightLineView: UIView = UIView(frame: .zero)

    // MARK: - init
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func initialize() {
        selectionStyle = .none
        clipsToBounds = true
        subView.backgroundColor = .clear
        subView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(subView)
        
        leftLineView.backgroundColor = UIColorRGB(0xB0B0B0)
        leftLineView.translatesAutoresizingMaskIntoConstraints = false
        subView.addSubview(leftLineView)
        
        rightLineView.backgroundColor = UIColorRGB(0xB0B0B0)
        rightLineView.translatesAutoresizingMaskIntoConstraints = false
        subView.addSubview(rightLineView)

        timeLineLabel.numberOfLines = 0
        timeLineLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLineLabel.font = UIFont.systemFont(ofSize: 12.0)
        timeLineLabel.backgroundColor = .clear
        timeLineLabel.textColor = UIColorRGB(0xB0B0B0)
        timeLineLabel.sizeToFit()
        subView.addSubview(timeLineLabel)
        subView.bringSubview(toFront: timeLineLabel)
        
        // Setting Constraints
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[subView]-|", options:[], metrics: nil, views:["subView":subView]))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[subView(31)]-|", options:[], metrics: nil, views:["subView":subView]))
        
        let views: [String: UIView] = ["timeLineLabel": timeLineLabel, "leftLineView": leftLineView, "rightLineView": rightLineView]
        subView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-2-[leftLineView]-9-[timeLineLabel]-9-[rightLineView]-2-|", options:[], metrics: nil, views:views))
        subView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-15-[leftLineView(1)]-15-|", options:[], metrics: nil, views:views))
        subView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-15-[rightLineView(1)]-15-|", options:[], metrics: nil, views:views))
        subView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[timeLineLabel]-|", options:[], metrics: nil, views:views))

        timeLineLabel.centerXAnchor.constraint(equalTo: subView.centerXAnchor).isActive = true
        timeLineLabel.centerYAnchor.constraint(equalTo: subView.centerYAnchor).isActive = true
    }
    
    func configure(with message: KREMessage?) {
        if let message = message, let sentOn = message.sentOn as Date? {
            let dateFormatter: DateFormatter = DateFormatter()
            dateFormatter.dateFormat = "h:mm a"
            timeLineLabel.text = String(format: "Conversation ended at \(dateFormatter.string(from: sentOn))");
        }
    }
    
}
