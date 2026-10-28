//
//  SampleHeaderView.swift
//  KoreBotSDKDemo
//
//  Created by Pagidimarri Kartheek on 27/11/24.
//  Copyright © 2024 Kore. All rights reserved.
//

import Foundation
import UIKit
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
      backButton.isHidden = true
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
    
    var isAgentConnect = false
    
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
        var chatBotName = ""
        
        self.koreHeaderViewBranding = {[weak self] (headerBrandingModel) in
            guard let dic = headerBrandingModel else {
                return
            }
            var titleTxt = dic.title?.name
            if titleTxt == ""{
                titleTxt = "Kore BotSDK"
            }
            self?.textLabel.text = titleTxt
            chatBotName = self?.textLabel.text ?? ""
            if let textColor = dic.title?.color as? String {
                self?.textLabel.textColor = UIColor.init(hexString: textColor)
            }
            if let headerViewBgColor = dic.bg_color{
                self?.backgroundColor = UIColor.init(hexString: headerViewBgColor)
            }
        }
        
        self.callBackFromKoreSDK = {[weak self] (isAgentConnected) in
            if let isAgent_Connected = isAgentConnected, isAgent_Connected == true{
                self?.textLabel.text = "Agent Connected"
                self?.isAgentConnect = isAgent_Connected
            }else{
                self?.textLabel.text = chatBotName
                self?.isAgentConnect = false
            }
        }
    }
    
    @objc func backButtonAction(_ sender: AnyObject) {
        if isAgentConnect == true{  //koreAgentIsConnected
            let alert = UIAlertController(
                title: "Do you want to close the agent chat?",
                message: "",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
                self?.sendAgentChatCloseEvent?()
            })

            var responder: UIResponder? = self
            while let current = responder {
                if let viewController = current as? UIViewController {
                    viewController.present(alert, animated: true)
                    break
                }
                responder = current.next
            }
        
        }else{
            koreHeaderBackBtnAction?()
        }
        //MARK: Show popup actions for close, minimize, and cancel
        //koreHeaderBackBtnAction?()
        
        //MARK: Close the chat window without displaying a confirmation popup.
        //koreCloseChatWindow?()
        
        //MARK: Close the chat window without displaying a confirmation popup.
        //koreMinimiseChatWindow?()
    }
    
    @objc func reConnectButtonAction(_ sender: AnyObject) {
        
    }
}
