//
//  ChatMessagesViewController+Widgets.swift
//  KoraSDK
//
//  Created by Srinivas Vasadi on 28/10/19.
//  Copyright © 2019 Srinivas Vasadi. All rights reserved.
//

import UIKit
import KoreBotSDK
import MessageUI

public enum WidgetId: String {
    case upcomingTasksWidgetId = "upcomingTasks"
    case overdueTasksWidgetId = "overdueTasks"
    case files = "cloudFiles"
    case upcomingMeetings = "upcomingMeetings"
    case article = "Article"
    case announcement = "Announcement"
}

// MARK: - KREGenericWidgetViewDelegate methods
class KREWidgetViewControllerDelegate: NSObject, KREGenericWidgetViewDelegate {
    
    public func addSnackBar(text: String) {
        let snackBar = KRESnackBarViewController()
        snackBar.feedbackContainerView.titleLabel.text = text
        let controller = targetViewController?.topMostViewController()
        snackBar.modalPresentationStyle = .overCurrentContext
        controller?.present(snackBar, animated: true, completion: nil)
    }
    
    // MARK: - properties
    var targetViewController: UIViewController?
    var navigationController: UINavigationController?
    
    // Mark: - init
    override init() {
        super.init()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - KREWidgetViewDelegate methods
    public func elementAction(for component: Decodable, in widget: KREWidget?, in panel: KREPanelItem?) {
        if let element = component as? KRETaskListItem {
            taskElementAction(for: element, in: widget)
        } else if let element = component as? KRECalendarEvent {
            if element.actionType == "notes" {
                addMeetingNotes(element: element)
            } else if element.actionType == "joinin" {
                joinInAction(element: element)
            } else if element.actionType == "dialin" {
                dialInAction(element: element)
            } else {
                calendarElementAction(for: element, in: widget)
            }
        } else if let element = component as? KREKnowledgeItem {
            knowledgeElementAction(for: element, in: widget)
        } else if let element = component as? KREDriveFileInfo {
            cloudFileAction(for: element, in: widget)
        } else if let element = component as? KREHashTag {
            hashTagAction(for: element, in: widget)
        } else if let element = component as? KREAction {
            performAction(element, in: widget, panelItem: panel)
        } else if let element = component as? KREButtonTemplate {
            performAction(element, in: widget, panelItem: panel)
        } else if let element = component as? KRECommonWidgetData {
            commonWidgetElementAction(for: element, in: widget, panelItem: panel)
        } else if let element = component as? KRELogInData  {
            loginWidgetElementAction(for: element, in: widget, panelItem: panel)
        } else if let element = component as? KREMeetingNote  {
            openMeetingNotes(element: element)
        }
    }
    
    public func didSelectElement(_ component: Decodable, in widget: KREWidget?, in panel: KREPanelItem?) {
        if let element = component as? KRECalendarEvent {
            openMeetingDetails(element: element)
        }
    }
    
    func didLoadWidgetView(with widget: KREWidget, in panel: KREPanelItem?) {
        switch panel?.iconId {
        case "home":
            break
        default:
            break
        }
    }
    
    public func addWidgetElement(in widget: KREWidget, completion block:((Bool) -> Void)?) {
        guard let widgetId = widget.widgetId else {
            return
        }
        
        switch widgetId {
        case WidgetId.announcement.rawValue, WidgetId.article.rawValue:
            let loaderView = KRELoaderView()
            loaderView.lineWidth = 2.0
            loaderView.tintColor = UIColor.lightRoyalBlue
            loaderView.frame = CGRect(x: Double(UIScreen.main.bounds.size.width / 2) - KALOADER_WIDTH / 2, y: Double(UIScreen.main.bounds.size.height / 2) - KALOADER_WIDTH / 2, width: KALOADER_WIDTH, height: KALOADER_WIDTH)
            navigationController?.view.addSubview(loaderView)
            navigationController?.view.bringSubviewToFront(loaderView)
            loaderView.startAnimation()
            
            let account = KoraApplication.sharedInstance.account
            account?.updateAccount(completion: { (networkUpdateSuccess, error) in
                loaderView.removeFromSuperview()
                switch widgetId {
                case WidgetId.announcement.rawValue:
                    self.addAnnouncementAction(widget: widget)
                case WidgetId.article.rawValue:
                    self.addKnowledgeAction(widget: widget, completion: block)
                default:
                    break
                }
            })
        case WidgetId.overdueTasksWidgetId.rawValue, WidgetId.upcomingTasksWidgetId.rawValue:
            addNewElement(in: widget, completion: block)
        default:
            break
        }
    }
    
    func viewMoreElements(for component: KREWidgetComponent?, in widget: KREWidget?, in panel: KREPanelItem?) {
        switch widget?.templateType {
        case "file_list":
            let driveListViewController = KREDriveListViewController()
            driveListViewController.widgetComponent = component
            
            let nvc = UINavigationController(rootViewController: driveListViewController)
            nvc.modalPresentationStyle = .fullScreen
            navigationController?.present(nvc, animated: true, completion: nil)
        case "task_list":
            taskViewMoreAction(for: component, in: widget)
        case "knowledge_list", "announcement_list":
            knowledgeViewMoreAction(for: component, in: widget, in: panel)
        case "standard", "custom_style":
            customWidgetViewMoreAction(for: component, in: widget, in: panel)
        case "List":
            listWidgetViewMoreAction(for: component, in: widget, in: panel)
        case "calendar_events":
            calendarWidgetViewMoreAction(for: component, in: widget, in: panel)
        case "meeting_notes":
            meetingNotesWidgetViewMoreAction(for: component, in: widget, in: panel)
        default:
            break
        }
    }
    
    func editButtonAction(in panel: KREPanelItem?) {
        var wigetIds = [String]()
        if let widgets = panel?.widgets {
            for widget in widgets {
                wigetIds.append(widget._id ?? "")
            }
        }
        let reorderWidgetView = KREEditReorderWidgetViewController()
        reorderWidgetView.panelItem = panel
        reorderWidgetView.panelId = panel?.id
        if let widgets = panel?.widgets {
            reorderWidgetView.widgets = widgets
        }
        reorderWidgetView.reorderIds = wigetIds
        
        let nvc = UINavigationController(rootViewController: reorderWidgetView)
        nvc.modalPresentationStyle = .fullScreen
        navigationController?.present(nvc, animated: true, completion: nil)
    }
    
    // MARK: - widget element actions
    func calendarElementAction(for element: KRECalendarEvent, in widget: KREWidget?) {
        widgetActionUi(component: element)
    }
    
    func taskElementAction(for element: KRETaskListItem, in widget: KREWidget?) {
        widgetActionUi(component: element)
    }
    
    func commonWidgetElementAction(for element: KRECommonWidgetData, in widget: KREWidget?, panelItem: KREPanelItem?) {
        if let defaultAction = element.defaultAction, let actionType = defaultAction.type {
            switch actionType.lowercased() {
            case "web_url", "iframe_web_url", "url":
                if let urlString = defaultAction.url, let url = URL(string: urlString) {
                    navigationController?.openExternalUrl(url: url)
                }
            case "postback":
                utteranceAction(for: defaultAction, in: widget, panelItem: panelItem)
            default:
                break
            }
        } else if element.actions?.count ?? 0 > 0 {
            widgetActionUiForCommonWidget(component: element, panel: panelItem, widget: widget)
        }
    }
    
    func loginWidgetElementAction(for element: KRELogInData, in widget: KREWidget?, panelItem: KREPanelItem?) {
        let loginActionController = KALoginPanelViewController()
        loginActionController.panelItem = panelItem
        loginActionController.urlStr = element.url
        let nvc = UINavigationController(rootViewController: loginActionController)
        nvc.modalPresentationStyle = .fullScreen
        navigationController?.present(nvc, animated: true, completion: nil)
    }
    
    func knowledgeElementAction(for knowledge: KREKnowledgeItem, in widget: KREWidget?) {
        guard let knowledgeId = knowledge.knowledgeId else {
            return
        }
        if knowledge.isAnnounement == true {
            let announcementDetailsViewController = KAAnnouncementDetailsViewController(knowledgeId: knowledgeId)
            if let pnvc = navigationController?.presentedViewController as? UINavigationController {
                pnvc.pushViewController(announcementDetailsViewController, animated: true)
            } else {
                let nvc = UINavigationController(rootViewController: announcementDetailsViewController)
                nvc.modalPresentationStyle = .fullScreen
                navigationController?.present(nvc, animated: true, completion: nil)
            }
        } else {
            let informationDetailsViewController = KAInformationDetailsViewController(knowledgeId: knowledgeId)
            if let pnvc = navigationController?.presentedViewController as? UINavigationController {
                pnvc.pushViewController(informationDetailsViewController, animated: true)
            } else {
                let nvc = UINavigationController(rootViewController: informationDetailsViewController)
                nvc.modalPresentationStyle = .fullScreen
                navigationController?.present(nvc, animated: true, completion: nil)
            }
        }
    }
    
    func cloudFileAction(for element: KREDriveFileInfo, in widget: KREWidget?) {
        guard let urlAction = element.defaultAction?.url else {
            return
        }
        navigationController?.openDriveUrl(urlString: urlAction, fileType: element.fileType ?? "")
    }
    
    func hashTagAction(for element: KREHashTag, in widget: KREWidget?) {
        if let hashTag = element.name {
            var params: [String: Any] =  [String: Any]()
            params["utterance"] = "find the articles with " + "#\(hashTag)"
            params["options"] = ["refresh": true]
            NotificationCenter.default.post(name: KREMessageAction.navigateToComposeBar.notification, object: params)
            //            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func utteranceAction(for element: KREAction, in widget: KREWidget?, panelItem: KREPanelItem?) {
        if let actionTag = element.utterance {
            let account = KoraApplication.sharedInstance.account
            if let skillId = account?.currentSkill?.skillId, let panelSkillId = panelItem?.skillId {
                if skillId == panelSkillId {
                    var params: [String: Any] =  [String: Any]()
                    params["utterance"] = actionTag
                    params["options"] = ["refresh": true]
                    NotificationCenter.default.post(name: KREMessageAction.navigateToComposeBar.notification, object: params)
                } else {
                    var params: [String: Any] =  [String: Any]()
                    if let trigger = widget?.trigger {
                        params["utterance"] = trigger + " " + actionTag
                    } else if let trigger = panelItem?.trigger {
                        params["utterance"] = trigger + " " + actionTag
                    } else {
                        params["utterance"] = actionTag
                    }
                    params["options"] = ["refresh": true]
                    NotificationCenter.default.post(name: KREMessageAction.navigateToComposeBar.notification, object: params)
                }
            } else {
                var params: [String: Any] =  [String: Any]()
                if let trigger = widget?.trigger {
                    params["utterance"] = trigger + " " + actionTag
                } else if let trigger = panelItem?.trigger {
                    params["utterance"] = trigger + " " + actionTag
                } else {
                    params["utterance"] = actionTag
                }
                params["options"] = ["refresh": true]
                NotificationCenter.default.post(name: KREMessageAction.navigateToComposeBar.notification, object: params)
            }
        } else if let payload = element.payload {
            let account = KoraApplication.sharedInstance.account
            if let skillId = account?.currentSkill?.skillId, let panelSkillId = panelItem?.skillId {
                if skillId == panelSkillId {
                    var params: [String: Any] =  [String: Any]()
                    params["utterance"] = payload
                    params["options"] = ["refresh": true]
                    NotificationCenter.default.post(name: KREMessageAction.navigateToComposeBar.notification, object: params)
                } else {
                    var params: [String: Any] =  [String: Any]()
                    if let trigger = widget?.trigger {
                        params["utterance"] = trigger + " " + payload
                    } else if let trigger = panelItem?.trigger {
                        params["utterance"] = trigger + " " + payload
                    } else {
                        params["utterance"] = payload
                    }
                    params["options"] = ["refresh": true]
                    NotificationCenter.default.post(name: KREMessageAction.navigateToComposeBar.notification, object: params)
                }
            } else if payload == "open_bell_notifications" {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ShowBellNotificationScreen"), object: nil)
            } else {
                var params: [String: Any] =  [String: Any]()
                if let trigger = widget?.trigger {
                    params["utterance"] = trigger + " " + payload
                } else if let trigger = panelItem?.trigger {
                    params["utterance"] = trigger + " " + payload
                } else {
                    params["utterance"] = payload
                }
                params["options"] = ["refresh": true]
                NotificationCenter.default.post(name: KREMessageAction.utteranceHandler.notification, object: params)
            }
        }
    }
    
    func utteranceButtonAction(for element: KREButtonTemplate, in widget: KREWidget?, panelItem: KREPanelItem?) {
        if let actionTag = element.utterance {
            let account = KoraApplication.sharedInstance.account
            if let skillId = account?.currentSkill?.skillId , let panelSkillId = panelItem?.skillId {
                if skillId == panelSkillId {
                    var params: [String: Any] =  [String: Any]()
                    params["utterance"] = actionTag
                    params["options"] = ["refresh": true]
                    NotificationCenter.default.post(name: KREMessageAction.navigateToComposeBar.notification, object: params)
                } else {
                    var params: [String: Any] =  [String: Any]()
                    if let trigger = widget?.trigger {
                        params["utterance"] = trigger + " " + actionTag
                    } else if let trigger = panelItem?.trigger {
                        params["utterance"] = trigger + " " + actionTag
                    } else {
                        params["utterance"] = actionTag
                    }
                    params["options"] = ["refresh": true]
                    NotificationCenter.default.post(name: KREMessageAction.navigateToComposeBar.notification, object: params)
                }
            } else {
                var params: [String: Any] =  [String: Any]()
                if let trigger = widget?.trigger {
                    params["utterance"] = trigger + " " + actionTag
                } else if let trigger = panelItem?.trigger {
                    params["utterance"] = trigger + " " + actionTag
                } else {
                    params["utterance"] = actionTag
                }
                params["options"] = ["refresh": true]
                NotificationCenter.default.post(name: KREMessageAction.navigateToComposeBar.notification, object: params)
            }
        } else if let actionTag = element.payload {
            let account = KoraApplication.sharedInstance.account
            if let skillId = account?.currentSkill?.skillId , let panelSkillId = panelItem?.skillId {
                if skillId == panelSkillId {
                    var params: [String: Any] =  [String: Any]()
                    params["utterance"] = actionTag
                    params["options"] = ["refresh": true]
                    NotificationCenter.default.post(name: KREMessageAction.navigateToComposeBar.notification, object: params)
                } else {
                    var params: [String: Any] =  [String: Any]()
                    if let trigger = widget?.trigger {
                        params["utterance"] = trigger + " " + actionTag
                    } else if let trigger = panelItem?.trigger {
                        params["utterance"] = trigger + " " + actionTag
                    } else {
                        params["utterance"] = actionTag
                    }
                    params["options"] = ["refresh": true]
                    NotificationCenter.default.post(name: KREMessageAction.navigateToComposeBar.notification, object: params)
                }
            } else {
                var params: [String: Any] =  [String: Any]()
                if let trigger = widget?.trigger {
                    params["utterance"] = trigger + " " + actionTag
                } else if let trigger = panelItem?.trigger {
                    params["utterance"] = trigger + " " + actionTag
                } else {
                    params["utterance"] = actionTag
                }
                params["options"] = ["refresh": true]
                NotificationCenter.default.post(name: KREMessageAction.navigateToComposeBar.notification, object: params)
            }
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "DismissFullViewController"), object: nil)
    }
    
    func taskViewMoreAction(for element: Decodable, in widget: KREWidget?) {
        let selectedFilters = widget?.filters?.filter { $0.isSelected == true}
        guard let widgetFilter = selectedFilters?.first, let widgetComponent = widgetFilter.component else {
            return
        }
        let taskListViewController = KRETaskListViewController()
        taskListViewController.objects = widgetComponent.elements ?? []
        taskListViewController.widgetComponent = widgetComponent
        taskListViewController.widget = widget
        
        let nvc = UINavigationController(rootViewController: taskListViewController)
        nvc.modalPresentationStyle = .fullScreen
        navigationController?.present(nvc, animated: true, completion: nil)
    }
    
    func hashTagViewMoreAction(for element: Decodable, in widget: KREWidget?) {
        let selectedFilters = widget?.filters?.filter { $0.isSelected == true}
        guard let widgetFilter = selectedFilters?.first, let widgetComponent = widgetFilter.component else {
            return
        }
        let hashTagListViewController = KREHashtagFullViewController()
        if let hashTags = widgetComponent.elements as? [KREHashTag] {
            hashTagListViewController.hashTags = hashTags
        }
        
        let nvc = UINavigationController(rootViewController: hashTagListViewController)
        nvc.modalPresentationStyle = .fullScreen
        navigationController?.present(nvc, animated: true, completion: nil)
    }
    
    func knowledgeViewMoreAction(for element: Decodable, in widget: KREWidget?, in panelItem: KREPanelItem?) {
        let selectedFilters = widget?.filters?.filter { $0.isSelected == true}
        guard let widgetFilter = selectedFilters?.first, let _ = widgetFilter.component else {
            return
        }
        let knowledgeWidgetViewController = KREKnowledgeWidgetViewController()
        knowledgeWidgetViewController.widget = widget
        knowledgeWidgetViewController.delegate = self
        
        let nvc = UINavigationController(rootViewController: knowledgeWidgetViewController)
        nvc.modalPresentationStyle = .fullScreen
        navigationController?.present(nvc, animated: true, completion: nil)
    }
    
    func customWidgetViewMoreAction(for element: Decodable, in widget: KREWidget?, in panelItem: KREPanelItem?) {
        let selectedFilters = widget?.filters?.filter { $0.isSelected == true}
        guard let widgetFilter = selectedFilters?.first, let widgetComponent = widgetFilter.component else {
            return
        }
        let customWidgetFullViewController = KACustomWidgetFullListViewController()
        if let widgetData = widgetComponent.elements as? [KRECommonWidgetData] {
            customWidgetFullViewController.widgetData = widgetData
        }
        customWidgetFullViewController.widget = widget
        customWidgetFullViewController.panelItem = panelItem
        
        let nvc = UINavigationController(rootViewController: customWidgetFullViewController)
        nvc.modalPresentationStyle = .fullScreen
        navigationController?.present(nvc, animated: true, completion: nil)
    }
    
    func listWidgetViewMoreAction(for component: KREWidgetComponent?, in widget: KREWidget?, in panelItem: KREPanelItem?) {
        let listItemsViewController = KREListItemsViewController()
        listItemsViewController.widgetComponent = component
        listItemsViewController.widget = widget
        listItemsViewController.panelItem = panelItem
        listItemsViewController.delegate = self
        
        let nvc = UINavigationController(rootViewController: listItemsViewController)
        nvc.modalPresentationStyle = .fullScreen
        navigationController?.present(nvc, animated: true, completion: nil)
    }
    
    func calendarWidgetViewMoreAction(for component: KREWidgetComponent?, in widget: KREWidget?, in panelItem: KREPanelItem?) {
        let calendarListViewController = KRECalendarListViewController()
        calendarListViewController.panelItem = panelItem
        calendarListViewController.widget = widget
        calendarListViewController.widgetComponent = component
        calendarListViewController.delegate = self
        
        let nvc = UINavigationController(rootViewController: calendarListViewController)
        nvc.modalPresentationStyle = .fullScreen
        navigationController?.present(nvc, animated: true, completion: nil)
    }
    
    func meetingNotesWidgetViewMoreAction(for component: KREWidgetComponent?, in widget: KREWidget?, in panelItem: KREPanelItem?) {
        let meetingNotesWidgetViewController = KREMeetingNotesWidgetViewController()
        meetingNotesWidgetViewController.panelItem = panelItem
        meetingNotesWidgetViewController.widget = widget
        meetingNotesWidgetViewController.widgetComponent = component
        meetingNotesWidgetViewController.delegate = self
        
        let nvc = UINavigationController(rootViewController: meetingNotesWidgetViewController)
        nvc.modalPresentationStyle = .fullScreen
        navigationController?.present(nvc, animated: true, completion: nil)
    }
    
    func addKnowledgeAction(widget: KREWidget?, completion block:((Bool) -> Void)?) {
        let account = KoraApplication.sharedInstance.account
        let fremmium = KREFremimumAlertViewController()
        if let roles = account?.userInfo?.roles, roles.count > 0, roles.contains("admin"){
            fremmium.feedbackContainerView.bottomCollectionView.utterances = ["Upgrade", "Learn More"]
            
        } else {
            fremmium.feedbackContainerView.bottomCollectionView.utterances = ["Request for upgrade", "Learn More"]
            
        }
        fremmium.feedbackContainerView.bottomCollectionView.actionHandler = {[weak self] (button) in
            fremmium.timerDismiss()
            fremmium.dismissAction = nil
            if button == "Learn More" {
                let urlString = "https://staging-site.kore.ai/newkora/pricing_draft_2/"
                self?.openLimitAction(urlString: urlString)
            } else if button == "Request for upgrade" {
                self?.openRequestToProgrssAction()
            } else if button == "Upgrade" {
                self?.showAlertToAdmin()
            }
        }
        
        
        guard let usage = account?.usageLimit else {
            self.addKnowledge(completion: block)
            return
        }
        
        let limit = usage.filter {$0.type == "articles"}.first
        
        if limit?.showFremiumForAnnouncmentAndKnowledge(usageLimits: usage) == KoraFremmiumConditions.noMore {
            fremmium.timerToDismiss = true
            fremmium.feedbackContainerView.titleLabel.text = "Your admin will need to upgrade your account if you want to create more articles/announcements"
            fremmium.feedbackContainerView.leftImage.image = UIImage(named: "alertSign")
            if let roles = account?.userInfo?.roles, roles.count > 0, roles.contains("admin"){
                fremmium.feedbackContainerView.bottomCollectionView.utterances = ["Upgrade", "Learn More"]
                
            } else {
                
                fremmium.feedbackContainerView.bottomCollectionView.utterances = ["Request for upgrade", "Learn More"]
            }
            fremmium.feedbackContainerView.bottomCollectionView.actionHandler = {[weak self] (button) in
                fremmium.dismissAction = nil
                if button == "Learn More" {
                    let urlString = "https://staging-site.kore.ai/newkora/pricing_draft_2/"
                    self?.openLimitAction(urlString: urlString)
                } else if button == "Request for upgrade" {
                    self?.openRequestToProgrssAction()
                } else if button == "Upgrade" {
                    fremmium.dismissAction = nil
                    self?.showAlertToAdmin()
                }
            }
            
            fremmium.modalPresentationStyle = .overCurrentContext
            let controller = targetViewController?.topMostViewController()
            fremmium.modalPresentationStyle = .overCurrentContext
            controller?.present(fremmium, animated: true, completion: nil)
        } else if limit?.showFremiumForAnnouncmentAndKnowledge(usageLimits: usage) == KoraFremmiumConditions.limitShow {
            if let countDifference = limit?.countAnnouncementAndKnowledgeRemainnig(usageLimits: usage) {
                fremmium.feedbackContainerView.titleLabel.text = "Your can create \(countDifference) more articles or announcements under the Free account"
            }
            fremmium.feedbackContainerView.leftImage.image = UIImage(named: "alertIcon")
            if let roles = account?.userInfo?.roles, roles.count > 0, roles.contains("admin"){
                fremmium.feedbackContainerView.bottomCollectionView.utterances = ["Upgrade", "Learn More"]
                
            } else {
                
                fremmium.feedbackContainerView.bottomCollectionView.utterances = ["Request for upgrade", "Learn More"]
            }
            fremmium.feedbackContainerView.bottomCollectionView.actionHandler = {[weak self] (button) in
                fremmium.timerDismiss()
                fremmium.dismissAction = nil
                if button == "Learn More" {
                    let urlString = "https://staging-site.kore.ai/newkora/pricing_draft_2/"
                    self?.openLimitAction(urlString: urlString)
                } else if button == "Request for upgrade" {
                    self?.openRequestToProgrssAction()
                } else if button == "Upgrade" {
                    fremmium.dismissAction = nil
                    self?.showAlertToAdmin()
                }
            }
            fremmium.modalPresentationStyle = .overCurrentContext
            let controller = targetViewController?.topMostViewController()
            fremmium.modalPresentationStyle = .overCurrentContext
            controller?.present(fremmium, animated: true, completion: nil)
            
            fremmium.dismissAction = { [weak self] in
                self?.addKnowledge(completion: block)
            }
        } else {
            self.addKnowledge(completion: block)
        }
        
    }
    
    func addAnnouncementAction(widget: KREWidget?) {
        let account = KoraApplication.sharedInstance.account
        let fremmium = KREFremimumAlertViewController()
        if let roles = account?.userInfo?.roles, roles.count > 0, roles.contains("admin"){
            fremmium.feedbackContainerView.bottomCollectionView.utterances = ["Upgrade", "Learn More"]
        } else {
            fremmium.feedbackContainerView.bottomCollectionView.utterances = ["Request for upgrade", "Learn More"]
            
        }
        fremmium.feedbackContainerView.bottomCollectionView.actionHandler = {[weak self] (button) in
            fremmium.dismissAction = nil
            if button == "Learn More" {
                let urlString = "https://staging-site.kore.ai/newkora/pricing_draft_2/"
                self?.openLimitAction(urlString: urlString)
            } else if button == "Request for upgrade" {
                self?.openRequestToProgrssAction()
            } else if button == "Upgrade" {
                fremmium.dismissAction = nil
                self?.showAlertToAdmin()
            }
        }
        
        guard let usage = account?.usageLimit else {
            self.addAnnouncement()
            return
        }
        
        let limit = (usage.filter {$0.type == "announcements"}).first
        
        if limit?.showFremiumForAnnouncmentAndKnowledge(usageLimits: usage) == KoraFremmiumConditions.noMore {
            fremmium.timerToDismiss = true
            fremmium.feedbackContainerView.titleLabel.text = "Your admin will need to upgrade your account if you want to create more articles/announcements"
            fremmium.feedbackContainerView.leftImage.image = UIImage(named: "alertSign")
            fremmium.modalPresentationStyle = .overCurrentContext
            let controller = targetViewController?.topMostViewController()
            fremmium.modalPresentationStyle = .overCurrentContext
            controller?.present(fremmium, animated: true, completion: nil)
        } else  if limit?.showFremiumForAnnouncmentAndKnowledge(usageLimits: usage) == KoraFremmiumConditions.limitShow {
            if let count = limit?.countAnnouncementAndKnowledgeRemainnig(usageLimits: usage) {
                fremmium.feedbackContainerView.titleLabel.text = "Your can create \(count) more articles or announcements under the Free account"
            }
            fremmium.feedbackContainerView.leftImage.image = UIImage(named: "alertIcon")
            if let roles = account?.userInfo?.roles, roles.count > 0, roles.contains("admin"){
                fremmium.feedbackContainerView.bottomCollectionView.utterances = ["Upgrade", "Learn More"]
                
            } else {
                fremmium.feedbackContainerView.bottomCollectionView.utterances = ["Request for upgrade", "Learn More"]
            }
            fremmium.feedbackContainerView.bottomCollectionView.actionHandler = {[weak self] (button) in
                fremmium.timerDismiss()
                fremmium.dismissAction = nil
                if button == "Learn More" {
                    let urlString = "https://staging-site.kore.ai/newkora/pricing_draft_2/"
                    fremmium.dismissAction = nil
                    self?.openLimitAction(urlString: urlString)
                } else if button == "Request for upgrade" {
                    fremmium.dismissAction = nil
                    self?.openRequestToProgrssAction()
                } else if button == "Upgrade" {
                    fremmium.dismissAction = nil
                    self?.showAlertToAdmin()
                }
            }
            fremmium.modalPresentationStyle = .overCurrentContext
            let controller = targetViewController?.topMostViewController()
            fremmium.modalPresentationStyle = .overCurrentContext
            controller?.present(fremmium, animated: true, completion: nil)
            
            fremmium.dismissAction = { [weak self] in
                self?.addAnnouncement()
            }
        } else {
            self.addAnnouncement()
        }
    }
    
    func addKnowledge(completion block:((Bool) -> Void)?) {
        let addNewInformationViewController = KREAddInformationViewController()
        addNewInformationViewController.addInformationActionHandler = { (parameters) in
            if let _ = parameters?["kId"] {
                block?(true)
            } else {
                block?(false)
            }
        }
        if let pnvc = navigationController?.presentedViewController as? UINavigationController {
            pnvc.pushViewController(addNewInformationViewController, animated: true)
        } else {
            let nvc = UINavigationController(rootViewController: addNewInformationViewController)
            nvc.modalPresentationStyle = .fullScreen
            navigationController?.present(nvc, animated: true, completion: nil)
        }
    }
    
    func addAnnouncement() {
        let addAnnouncementViewController = KAAddAnnouncementViewController()
        addAnnouncementViewController.addInformationActionHandler = { (_) in
            
        }
        addAnnouncementViewController.isAnnouncement = true
        if let pnvc = self.navigationController?.presentedViewController as? UINavigationController {
            pnvc.pushViewController(addAnnouncementViewController, animated: true)
        } else {
            let nvc = UINavigationController(rootViewController: addAnnouncementViewController)
            nvc.modalPresentationStyle = .fullScreen
            self.navigationController?.present(nvc, animated: true, completion: nil)
        }
    }
    
    
    func getElementsinKnowledgeAnnouncement(widget: KREWidget?) -> Int {
        var selectedFilters = widget?.filters?.filter { $0.isSelected == true}
        if widget?.templateType == "knowledge_list" {
            selectedFilters = widget?.filters?.filter { $0.filterId == "byYou"}
        }
        if let widgetFilter = selectedFilters?.first, let component = widgetFilter.component {
            if let countElement = component.elements?.count {
                return countElement
            } else {
                return 0
            }
        } else {
            return 0
        }
    }
    
    func openLimitAction(urlString: String) {
        guard let meetingUrl = URL(string: urlString) else { return  }
        if  UIApplication.shared.canOpenURL(meetingUrl) {
            UIApplication.shared.open(meetingUrl, options: [:])
        }
    }
    
    func openRequestToProgrssAction() {
        let account = KoraApplication.sharedInstance.account
        if MFMailComposeViewController.canSendMail() {
            let mailComposeViewController = MFMailComposeViewController()
            mailComposeViewController.modalPresentationStyle = .fullScreen
            mailComposeViewController.mailComposeDelegate = self
            mailComposeViewController.setSubject("Humble Request: Can we upgrade so I can get more space?")
            mailComposeViewController.setMessageBody("Hi! Thanks for setting me up with Kora - I’m hooked! Let’s upgrade, so I can add and share more knowledge using Kora.", isHTML: true)
            mailComposeViewController.setToRecipients([(account?.adminAccount?.emailId ?? "")])
            let controller = targetViewController?.topMostViewController()
            controller?.present(mailComposeViewController, animated: true, completion: nil)
        } else {
            let alertController: UIAlertController = UIAlertController(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", preferredStyle: .alert)
            let noAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(noAction)
            let controller = targetViewController?.topMostViewController()
            controller?.present(alertController, animated: true, completion: nil)
            return
        }
    }
    
    func showAlertToAdmin() {
        let alertController: UIAlertController = UIAlertController(title: "", message: "Go to Enterprise Admin console - billing page in web browser to take necessary action", preferredStyle: .alert)
        let noAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(noAction)
        let controller = targetViewController?.topMostViewController()
        controller?.present(alertController, animated: true, completion: nil)
    }
    
    func openMeetingDetails(element: KRECalendarEvent) {
        let viewController = navigationController?.topMostViewController()
        let meetingDetailViewController = KREMeetingDetailViewController()
        meetingDetailViewController.element = element
        meetingDetailViewController.activityHandler = { (activityInfo) in
            KoraAssistant.shared.updateAnalytics(activityInfo: activityInfo)
        }

        let nvc = UINavigationController(rootViewController: meetingDetailViewController)
        nvc.modalPresentationStyle = .fullScreen
        viewController?.present(nvc, animated: true, completion: nil)
    }
    
    func addMeetingNotes(element: KRECalendarEvent) {
        let viewController = navigationController?.topMostViewController()
        let widgetActionController = KREMeetingNotesViewController()
        widgetActionController.calendarEvent = element
        
        let nvc = UINavigationController(rootViewController: widgetActionController)
        nvc.modalPresentationStyle = .fullScreen
        viewController?.present(nvc, animated: true, completion: nil)
    }
    
    func openMeetingNotes(element: KREMeetingNote) {
        let viewController = navigationController?.topMostViewController()
        let notesPreviewScreenViewController = KRENotesPreviewScreenViewController()
        notesPreviewScreenViewController.meetingNoteId = element.meetingNoteId
        
        let nvc = UINavigationController(rootViewController: notesPreviewScreenViewController)
        nvc.modalPresentationStyle = .fullScreen
        viewController?.present(nvc, animated: true, completion: nil)
    }
    
    func joinInAction(element: KRECalendarEvent) {
        guard let meeting = element.meetJoin?.meetingUrl else{
            return
        }
        guard let meetingUrl = URL(string: meeting) else { return  }
        if  UIApplication.shared.canOpenURL(meetingUrl) {
            UIApplication.shared.open(meetingUrl, options: [:])
        }
    }
    
    func dialInAction(element: KRECalendarEvent) {
        guard let phone = element.meetJoin?.dialIn else{
            return
        }
        let phoneUrl = URL(string: "telprompt://\(phone)")
        let phoneFallbackUrl = URL(string: "tel://\(phone)")
        if let url = phoneUrl, UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: { (success) in
                if (!success) {
                    debugPrint("Error message: Failed to open the url")
                }
            })
        } else if let url = phoneFallbackUrl, UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: { (success) in
                if (!success) {
                    debugPrint("Error message: Failed to open the url")
                }
            })
        } else {
            let alertController = UIAlertController(title: "Error!", message: "Phone calls are not configured on your device.", preferredStyle: .alert)
            let noAction = UIAlertAction(title: "Ok", style: .cancel, handler: {
                UIAlertAction  in
            })
            alertController.addAction(noAction)
            // self.present(alertController, animated: true, completion: nil)
            
            debugPrint("Error message: Your device can not do phone calls")
        }
    }
    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    func calculateTimeDifference(date1: Date, date2: Date) -> Int {
        let cal = Calendar.current
        let components = cal.dateComponents([.second], from: date1, to: date2)
        if let diffSeconds = components.second {
            // counter = diffSeconds
            return diffSeconds
        } else {
            return 0
        }
    }
    func widgetActionUi(component: Any) {
        var actions: [(String, UIAlertAction.Style, KREAction?)] = []
        var actionString = [(String, KREAction?)]()
        var title = ""
        var elementAction: [KREAction]?
        // Element Sepration
        if let element = component as? KRECalendarEvent {
            for action in element.actions ?? [] {
                action.elementId = element.elementId ?? ""
            }
            elementAction = element.actions ?? []
            let startOfToday = Calendar.current.startOfDay(for: Date())
            var diffDays = 0
            if let today = element.today {
                let startOfCalendarToday = Calendar.current.startOfDay(for: today)
                diffDays = Calendar.current.dateComponents([.day], from: startOfToday, to: startOfCalendarToday).day!
            }
            
            for button in element.actions ?? [] {
                if diffDays > 0 {
                    if button.title == "Dial-In" || button.title == "Join Meeting" || button.title == "Take Notes" {
                        continue
                    }
                }
                actionString.append((button.title ?? "", button))
            }
            title = element.title ?? ""
        } else if let element = component as? KREDriveFileInfo {
            guard let urlAction = element.defaultAction?.url else {
                return
            }
            navigationController?.openDriveUrl(urlString: urlAction, fileType: element.fileType ?? "")
        } else if let element = component as? KRETaskListItem {
            for action in element.actions ?? [] {
                action.elementId = element.taskId ?? ""
            }
            
            elementAction = element.actions ?? []
            for button in element.actions ?? [] {
                actionString.append((button.title ?? "", button))
            }
            title = element.title ?? ""
        } else if let _ = component as? KREButtonTemplate {
        } else if let _ = component as? KREKnowledgeItem {
        } else if let element = component as? KRECommonWidgetData {
            elementAction = element.actions ?? []
            for button in element.actions ?? [] {
                actionString.append((button.title ?? "", button))
            }
            title = element.title ?? ""
        }
        for (utterance, action) in actionString {
            actions.append((utterance, UIAlertAction.Style.default, action))
        }
        actions.append(("Cancel", UIAlertAction.Style.cancel, nil))
        
        guard let viewController = navigationController?.topMostViewController() else {
            return
        }
        
        Alerts.showActionsheet(viewController: viewController, title: title, message: "", actions: actions, panels: nil, widget: nil) { [weak self] (index, action) in
            if index == actionString.count {
                print("Cancel")
            } else {
                var params: [String: Any] =  [String: Any]()
                if let _ = elementAction {
                    if action?.type == "view_details" {
                        if let element = component as? KRECalendarEvent {
                            self?.openMeetingDetails(element: element)
                            return
                        }
                    } else if action?.type == "dial" {
                        if let element = component as? KRECalendarEvent {
                            self?.dialInAction(element: element)
                            return
                        }
                    } else if action?.type == "open_form" {
                        if let element = component as? KRECalendarEvent {
                            self?.addMeetingNotes(element: element)
                            return
                        }
                    } else if action?.type == "url", let url = action?.url {
                        guard let url = URL(string: url), UIApplication.shared.canOpenURL(url) else {
                            return
                        }
                        UIApplication.shared.open(url, options: [:]) { (success) in
                        }
                        return
                    } else {
                        params["utterance"] = action?.utterance
                        if (action?.elementId.count ?? 0) > 0 {
                            params["options"] = ["params":["ids": [action?.elementId]], "refresh": true]
                        } else {
                            params["options"] = ["refresh": true]
                        }
                    }
                }
                NotificationCenter.default.post(name: KREMessageAction.utteranceHandler.notification, object: params)
            }
        }
    }
    
    func widgetActionUiForCommonWidget(component: Any, panel: KREPanelItem?, widget: KREWidget?) {
        var actions: [(String, UIAlertAction.Style, KREAction?)] = []
        var actionString = [(String, KREAction)]()
        var title = ""
        var elementAction: [KREAction]?
        // Element Sepration
        if let element = component as? KRECalendarEvent {
            for action in element.actions ?? [] {
                action.elementId = element.elementId ?? ""
            }
            elementAction = element.actions ?? []
            let startOfToday = Calendar.current.startOfDay(for: Date())
            var diffDays = 0
            if let today = element.today {
                let startOfCalendarToday = Calendar.current.startOfDay(for: today)
                diffDays = Calendar.current.dateComponents([.day], from: startOfToday, to: startOfCalendarToday).day!
            }
            
            for button in element.actions ?? [] {
                if diffDays > 0 {
                    if button.title == "Dial-In" || button.title == "Join Meeting" || button.title == "Take Notes" {
                        continue
                    }
                }
                actionString.append((button.title ?? "", button))
            }
            title = element.title ?? ""
        } else if let element = component as? KREDriveFileInfo {
            guard let urlAction = element.defaultAction?.url else {
                return
            }
            navigationController?.openDriveUrl(urlString: urlAction, fileType: element.fileType ?? "")
        } else if let element = component as? KRETaskListItem {
            for action in element.actions ?? [] {
                action.elementId = element.taskId ?? ""
            }
            
            elementAction = element.actions ?? []
            for button in element.actions ?? [] {
                actionString.append((button.title ?? "", button))
            }
            title = element.title ?? ""
        } else if let _ = component as? KREButtonTemplate {
        } else if let _ = component as? KREKnowledgeItem {
        } else if let element = component as? KRECommonWidgetData {
            elementAction = element.actions ?? []
            for button in element.actions ?? [] {
                actionString.append((button.title ?? "", button))
            }
            title = element.title ?? ""
        }
        for (utterance, action) in actionString {
            actions.append((utterance, UIAlertAction.Style.default, action))
        }
        actions.append(("Cancel", UIAlertAction.Style.cancel, nil))
        
        guard let navigationController = navigationController else {
            return
        }
        
        Alerts.showActionsheet(viewController: navigationController, title: title, message: "", actions: actions, panels: panel, widget: widget) { [weak self] (index, action)  in
            if index == actionString.count {
                print("Cancel")
            } else {
                if let elementAction = elementAction {
                    if elementAction[index].type == "view_details" {
                        if let element = component as? KRECalendarEvent {
                            self?.openMeetingDetails(element: element)
                            return
                        }
                    } else if elementAction[index].type == "dial" {
                        if let element = component as? KRECalendarEvent {
                            self?.dialInAction(element: element)
                            return
                        }
                    } else if elementAction[index].type == "open_form" {
                        if let element = component as? KRECalendarEvent {
                            self?.addMeetingNotes(element: element)
                            return
                        }
                    } else if elementAction[index].type == "url", let url = elementAction[index].url {
                        guard let url = URL(string: url), UIApplication.shared.canOpenURL(url) else {
                            return
                        }
                        UIApplication.shared.open(url, options: [:]) { (success) in
                        }
                        return
                    } else {
                        self?.utteranceAction(for: elementAction[index], in: widget, panelItem: panel)
                    }
                }
            }
        }
    }
    
    func populateActions(_ actions: [KREAction]?, in widget: KREWidget?, in panel: KREPanelItem?) {
        var alertActions: [(String, UIAlertAction.Style, KREAction)] = []
        for action in actions ?? [] {
            alertActions.append(((action.title ?? "", UIAlertAction.Style.default, action)))
        }
        
        alertActions.append(("Cancel", UIAlertAction.Style.cancel, KREAction()))
        
        guard let navigationController = navigationController else {
            return
        }
        
        Alerts.showActionsheet(viewController: navigationController, title: nil, message: nil, actions: alertActions, panels: panel, widget: widget) { [weak self] (index, action)  in
            guard index != actions?.count else {
                return
            }
            
            guard let action = actions?[index] else {
                return
            }
            
            switch action.type {
            case "url":
                guard let urlString = action.url, let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) else {
                    return
                }
                UIApplication.shared.open(url, options: [:]) { (success) in
                }
            default:
                self?.utteranceAction(for: action, in: widget, panelItem: panel)
            }
        }
    }
    
    // MARK: -
    func performAction(_ action: KREAction?, in widget: KREWidget?, panelItem: KREPanelItem?) {
        switch action?.type {
        case "url":
            guard let urlString = action?.url, let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) else {
                return
            }
            KoraAssistant.shared.updateAnalytics(activityInfo: action?.activityInfo)
            UIApplication.shared.open(url, options: [:]) { (success) in
            }
        case "dial":
            guard let phone = action?.dial else {
                return
            }
            let phoneUrl = URL(string: "telprompt://\(phone)")
            let phoneFallbackUrl = URL(string: "tel://\(phone)")
            if let url = phoneUrl, UIApplication.shared.canOpenURL(url) {
                KoraAssistant.shared.updateAnalytics(activityInfo: action?.activityInfo)
                UIApplication.shared.open(url, options: [:], completionHandler: { (success) in
                    if (!success) {
                        debugPrint("Error message: Failed to open the url")
                    }
                })
            } else if let url = phoneFallbackUrl, UIApplication.shared.canOpenURL(url) {
                KoraAssistant.shared.updateAnalytics(activityInfo: action?.activityInfo)
                UIApplication.shared.open(url, options: [:], completionHandler: { (success) in
                    if (!success) {
                        debugPrint("Error message: Failed to open the url")
                    }
                })
            } else {
                let alertController = UIAlertController(title: "Error message:", message: "Your device can not do phone calls", preferredStyle: .alert)
                let noAction = UIAlertAction(title: "Ok", style: .cancel, handler: {
                    UIAlertAction  in
                })
                alertController.addAction(noAction)
                navigationController?.present(alertController, animated: true, completion: nil)
            }            
        default:
            if let action = action {
                utteranceAction(for: action, in: widget, panelItem: panelItem)
            }
        }
    }
    
    // MARK: -
    func addNewElement(in widget: KREWidget?, completion block:((Bool) -> Void)?) {
        switch widget?.templateType {
        case "task_list":
            var params: [String: Any] =  [String: Any]()
            params["utterance"] = NSLocalizedString("Create a task", comment: "Task")
            params["options"] = ["refresh": true]
            NotificationCenter.default.post(name: KREMessageAction.utteranceHandler.notification, object: params)
            block?(true)
        default:
            break
        }
    }
}

// MARK: - KREWidgetsViewControllerDelegate methods
extension ChatMessagesViewController: KREWidgetsViewControllerDelegate {
    public func didUpdateProgress(for widget: KREWidget) {
        
    }
    
    public func updateWidget(_ widget: KREWidget) {
        
    }
    
    public func actionFromWidget(controller: UIViewController) {
        let addNewInformationViewController = KREAddInformationViewController()
        let navigationController = UINavigationController(rootViewController: addNewInformationViewController)
        navigationController.modalPresentationStyle = .fullScreen
        controller.navigationController?.present(navigationController, animated: true, completion: nil)
        controller.present(navigationController, animated: true, completion: nil)
    }
    
}

// MARK: - Alerts
class Alerts {
    static func showActionsheet(viewController: UIViewController, title: String?, message: String?, actions: [(String, UIAlertAction.Style, KREAction?)], panels: KREPanelItem?, widget: KREWidget?, completion: @escaping (_ index: Int, _ action: KREAction?) -> Void) {
        let alertViewController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        for (index, (title, style, action)) in actions.enumerated() {
            let alertAction = UIAlertAction(title: title, style: style) { (_) in
                if let action = action {
                    completion(index, action)
                } else {
                    completion(index, nil)
                }
            }
            alertViewController.addAction(alertAction)
        }
        viewController.present(alertViewController, animated: true, completion: nil)
    }
}
// MARK: - MFMailComposeViewControllerDelegate
extension KREWidgetViewControllerDelegate: MFMailComposeViewControllerDelegate{
    // MARK: - MFMailComposeViewController delegate
    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
