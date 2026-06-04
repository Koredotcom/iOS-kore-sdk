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
    
    public var reConnectButton: UIButton = {
      let backButton = UIButton(frame: .zero)
      backButton.translatesAutoresizingMaskIntoConstraints = false
      backButton.backgroundColor = UIColor.clear
      backButton.setImage(UIImage(named: "retry", in: nil, compatibleWith: nil), for: .normal)
        backButton.addTarget(self, action: #selector(reConnectButtonAction(_:)), for: .touchUpInside)
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
        self.addSubview(reConnectButton)
        textLabel.text = "Kore BotSDK"
        textLabel.font = UIFont.boldSystemFont(ofSize: 16)
        let views: [String: UIView] = ["backButton": backButton, "textLabel": textLabel, "reConnectButton":reConnectButton]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[backButton(30)]", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[textLabel]|", options: [], metrics: nil, views: views))
        backButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        backButton.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        textLabel.heightAnchor.constraint(equalToConstant: 21).isActive = true
        textLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[reConnectButton(30)]-10-|", options: [], metrics: nil, views: views))
        reConnectButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        reConnectButton.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        self.koreHeaderViewBranding = {[weak self] (brandingDic) in
            guard let dic = brandingDic else {
                return
            }
            if let text = dic["headerViewTitle"] as? String {
                self?.textLabel.text = text
            }
            if let textColor = dic["headerViewTitleTextColor"] as? String {
                self?.textLabel.textColor = UIColor.init(hexString: textColor)
            }
            if let headerViewBgColor = dic["headerViewBgColor"] as? String {
                self?.backgroundColor = UIColor.init(hexString: headerViewBgColor)
            }
        }
    }
    
    @objc func backButtonAction(_ sender: AnyObject) {
        //MARK: Show popup actions for close, minimize, and cancel
        koreHeaderBackBtnAction?()
        
        //MARK: Show popup for closing the chat window
        //koreCloseChatWindow?()
        
        //MARK: Show popup for minimizing the chat window
        //koreMinimiseChatWindow?()
    }
    
    @objc func reConnectButtonAction(_ sender: AnyObject) {
        startNewSession?()
    }
    
    
}
