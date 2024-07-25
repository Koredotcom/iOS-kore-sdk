//
//  KREKnowledgeFooterView.swift
//  KoreBotSDK
//
//  Created by Sukhmeet Singh on 21/01/20.
//

import UIKit

public class KREKnowledgeFooterView: UIView {
    // MARK: - init
   
    // MARK: - properties
    var imageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = UIColor.clear
        imageView.contentMode = .center
        return imageView
    }()

    var titleLabel: UILabel = {
        let titleLabel = UILabel(frame: .zero)
        titleLabel.font = UIFont.textFont(ofSize: 12.0, weight: .regular)
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor.charcoalGrey
        titleLabel.text = "Admin FAQs"
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }()

    var matchLabel: UILabel = {
        let matchLabel = UILabel(frame: .zero)
        matchLabel.font = UIFont.textFont(ofSize: 12.0, weight: .regular)
        matchLabel.numberOfLines = 0
        matchLabel.textAlignment = .center
        matchLabel.textColor = UIColor.battleshipGrey
        matchLabel.text = "99% matching"
        matchLabel.translatesAutoresizingMaskIntoConstraints = false
        return matchLabel
    }()

    
    @objc override init(frame: CGRect) {
        super.init(frame: frame)
        setupUi()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @objc func setupUi() {
        addSubview(imageView)
        addSubview(titleLabel)
        addSubview(matchLabel)
        
        let views: [String: Any] = ["imageView": imageView, "titleLabel": titleLabel, "matchLabel": matchLabel]
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[imageView(15)]-10-[titleLabel]", options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[matchLabel]-|", options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[matchLabel]-|", options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[imageView(15)]", options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[titleLabel]|", options: [], metrics: nil, views: views))
    }
    
}
