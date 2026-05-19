//
//  SampleHeaderView.swift
//  KoreBotSDKDemo
//
//  Created by Pagidimarri Kartheek on 27/11/24.
//  Copyright © 2024 Kore. All rights reserved.
//

import Foundation
import KoreBotSDK
class SampleHeaderView: KoreCustomHeaderView {
    
      public var backButton: UIButton = {
        let backButton = UIButton(frame: .zero)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.backgroundColor = UIColor.clear
        backButton.setImage(UIImage(named: "left", in: nil, compatibleWith: nil), for: .normal)
          backButton.addTarget(self, action: #selector(backButtonAction(_:)), for: .touchUpInside)
        return backButton
    }()
    
    lazy var textLabel: UILabel = {
        let textLabel = UILabel(frame: .zero)
        textLabel.font = UIFont.systemFont(ofSize: 14)
        textLabel.contentMode = .scaleAspectFit
        textLabel.isHidden = false
        textLabel.textColor = .black
        textLabel.textAlignment = .center
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        return textLabel
    }()
    
    override func initialize() {
         super.initialize()
        
        self.backgroundColor = .lightGray
        self.addSubview(backButton)
        self.addSubview(textLabel)
        textLabel.text = "Kore BotSDK"
        textLabel.font = UIFont.boldSystemFont(ofSize: 16)
        let views: [String: UIView] = ["backButton": backButton, "textLabel": textLabel]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[backButton(30)]", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[textLabel]|", options: [], metrics: nil, views: views))
        backButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        backButton.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        textLabel.heightAnchor.constraint(equalToConstant: 21).isActive = true
        textLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    }
    
    @objc func backButtonAction(_ sender: AnyObject) {
        koreHeaderBackBtnAction?()
    }
    
}
