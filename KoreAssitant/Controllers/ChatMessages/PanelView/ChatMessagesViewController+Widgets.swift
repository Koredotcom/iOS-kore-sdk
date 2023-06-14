//
//  ChatMessagesViewController+Widgets.swift
//  KoraSDK
//
//  Created by Kartheek on 30/06/20.
//  Copyright © 2019 Srinivas Vasadi. All rights reserved.
//

import Foundation
import UIKit
import KoreBotSDK
import MessageUI

//public enum WidgetId: String {
//    case upcomingTasksWidgetId = "upcomingTasks"
//    case overdueTasksWidgetId = "overdueTasks"
//    case files = "cloudFiles"
//    case upcomingMeetings = "upcomingMeetings"
//    case article = "Article"
//    case announcement = "Announcement"
//}

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
            break
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
        }
    }
    
    func utteranceAction(for element: KREAction, in widget: KREWidget?, panelItem: KREPanelItem?) {
        if let actionTag = element.utterance {
            var params: [String: Any] =  [String: Any]()
            if let trigger = widget?.trigger {
                params["utterance"] = trigger + " " + actionTag
            } else if let trigger = panelItem?.trigger {
                params["utterance"] = trigger + " " + actionTag
            } else {
                params["utterance"] = actionTag
            }
            params["utterance"] = actionTag
            params["options"] = ["refresh": true]
            NotificationCenter.default.post(name: KREMessageAction.navigateToComposeBar.notification, object: params)
        } else if let payload = element.payload {
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
    }
    
    func utteranceButtonAction(for element: KREButtonTemplate, in widget: KREWidget?, panelItem: KREPanelItem?) {
        
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
        
    }
    
    func addAnnouncementAction(widget: KREWidget?) {
        
    }
    
    func addKnowledge(completion block:((Bool) -> Void)?) {
        
    }
    
    func addAnnouncement() {
        
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
        
    }
    
    func openMeetingNotes(element: KREMeetingNote) {
        
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
