//
//  ChatMessagesViewController+Siri.swift
//  KoraSDK
//
//  Created by Srinivas Vasadi on 05/11/19.
//  Copyright © 2019 Srinivas Vasadi. All rights reserved.
//

import UIKit
import Foundation
import CoreData
import CoreSpotlight
import SafariServices
import KoreBotSDK
import AFNetworking
import Mantle
import GhostTypewriter

extension ChatMessagesViewController {
    // MARK: - populate states
    public func configureState() {
        
    }
    
    // MARK: - notifications
    func registerForSiriShowScreenNotifications() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: SIRI_SHOW_SCREEN_CONSTANTS.SIRI_SHOW_SCREEN_MEETINGS), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleSiriShowScreenNotification(_:)), name: NSNotification.Name(rawValue: SIRI_SHOW_SCREEN_CONSTANTS.SIRI_SHOW_SCREEN_MEETINGS), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: SIRI_SHOW_SCREEN_CONSTANTS.SIRI_SHOW_SCREEN_TASK), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleSiriShowScreenNotification(_:)), name: NSNotification.Name(rawValue: SIRI_SHOW_SCREEN_CONSTANTS.SIRI_SHOW_SCREEN_TASK), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: SIRI_SHOW_SCREEN_CONSTANTS.SIRI_SHOW_SCREEN_KNOWLEDGE), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleSiriShowScreenNotification(_:)), name: NSNotification.Name(rawValue: SIRI_SHOW_SCREEN_CONSTANTS.SIRI_SHOW_SCREEN_KNOWLEDGE), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: SIRI_SHOW_SCREEN_CONSTANTS.SIRI_SHOW_SCREEN_NEW_ANNOUNCEMENT), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleSiriShowScreenNotification(_:)), name: NSNotification.Name(rawValue: SIRI_SHOW_SCREEN_CONSTANTS.SIRI_SHOW_SCREEN_NEW_ANNOUNCEMENT), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: SIRI_SHOW_SCREEN_CONSTANTS.SIRI_SHOW_SCREEN_SHOW_MY_ANNOUNCEMENT), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleSiriShowScreenNotification(_:)), name: NSNotification.Name(rawValue: SIRI_SHOW_SCREEN_CONSTANTS.SIRI_SHOW_SCREEN_SHOW_MY_ANNOUNCEMENT), object: nil)
    }
    
    @objc func handleSiriShowScreenNotification(_ notification: Notification) {
        if notification.name.rawValue == SIRI_SHOW_SCREEN_CONSTANTS.SIRI_SHOW_SCREEN_MEETINGS {
            sendTextMessage("Schedule a meeting", options: nil)
//            composeWidgetAction()
        } else if notification.name.rawValue == SIRI_SHOW_SCREEN_CONSTANTS.SIRI_SHOW_SCREEN_TASK {
            sendTextMessage("Assign tasks", options: nil)
//            composeWidgetAction()
        } else if notification.name.rawValue == SIRI_SHOW_SCREEN_CONSTANTS.SIRI_SHOW_SCREEN_KNOWLEDGE {
            sendTextMessage("create knowledge", options: nil)
//            activityViewController.addNewInformation()
        } else if notification.name.rawValue == SIRI_SHOW_SCREEN_CONSTANTS.SIRI_SHOW_SCREEN_NEW_ANNOUNCEMENT {
            sendTextMessage("create announcements", options: nil)
//            activityViewController.showNewAnnouncement()
        } else if notification.name.rawValue == SIRI_SHOW_SCREEN_CONSTANTS.SIRI_SHOW_SCREEN_SHOW_MY_ANNOUNCEMENT {
            sendTextMessage("show announcements", options: nil)
//            rightWidgetAction()
        }
    }
}

// MARK: - KABotlientDelegate methods
extension ChatMessagesViewController: KABotClientDelegate {
    public func botConnection(with connectionState: BotClientConnectionState) {
        self.connectionState = connectionState
        
        switch connectionState {
        case .NO_NETWORK, .CONNECTING:
            break
        default:
            break
        }
    }
    
    // MARK: show tying status view
    public func startTypingStatus() {
        let serverUrl = SDKConfiguration.serverConfig.JWT_SERVER
        setTypingStatusView(active: true)
        
        var dotColor = UIColor.lightRoyalBlue
        if let hexString = account?.currentSkill?.iconColor {
            dotColor = UIColor(hexString: hexString)
        }
        
        if let urlString = account?.currentSkill?.icon {
            typingStatusView.startTypingStatus(using: (serverUrl + urlString), dotColor: dotColor)
        } else {
            typingStatusView.startTypingStatus()
        }
        
        messageInputBar.disableSpeechButtons()
    }
    
    public func stopTypingStatus() {
        typingStatusView.stopTypingStatus()
        setTypingStatusView(active: false)
        messageInputBar.enableSpeechButtons()
    }
        
    public func onReceiveMessage(of templateType: TemplateType) {
        guard TemplateType.uiTemplates.contains(templateType) else {
            return
        }
        
        setFocusInMessageInputBar(false)
    }
    
    public func showFeedbackDialog(_ hiddenDialog: HiddenDialog?) {
        guard let featureId = hiddenDialog?.featureId else {
            setFeedbackView(false)
            return
        }
                
        guard let results = account?.features?.filter({ $0.id == featureId }),
            let feature = results.first else {
                return
        }
        
        switch hiddenDialog?.event {
        case "endOfDialog":
            prevHiddenDialog = hiddenDialog
            setFeedbackView(true, for: feature)
        default:
            setFeedbackView(false)
        }
    }
}
