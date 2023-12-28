//
//  KREWidgetManager.swift
//  KoreBotSDK
//
//  Created by Srinivas Vasadi on 11/03/19.
//  Copyright © 2019 Srinivas Vasadi. All rights reserved.
//

import UIKit
import Alamofire

public class KREWidgetManager: NSObject {
    // MARK: - properties
    public static var shared = KREWidgetManager()
    public var sessionExpiredAction:((Error?) -> Void)?
    
    let operationQueue = OperationQueue()
    let timeDifference: Int = 10
    let sessionManager: Session = {
        let configuration = URLSessionConfiguration.af.default
        configuration.timeoutIntervalForRequest = 30
        return Session(configuration: configuration)
    }()
    public var user: KREUser?
    public var panelItems: [KREPanelItem]?
    
    // MARK: - init
    public override init() {
        super.init()
    }
    
    public func initialize(with user: KREUser?) {
        self.user = user
    }
    
    // MARK: - requestSerializer
    func getRequestHeaders() -> HTTPHeaders {
        var headers: HTTPHeaders = [
            "bot-language": "en",
            "Keep-Alive": "Connection",
            "Content-Type": "application/json",
        ]

        if let keys = user?.headers?.keys as? [String], keys.count > 0 {
            for key in keys {
                if let value = user?.headers?[key] {
                    headers[key] = value
                }
            }
        }
        if let tokenType = user?.tokenType, let accessToken = user?.accessToken {
            headers["Authorization"] = "\(tokenType) \(accessToken)"
        }
        return headers
    }
    
    // MARK: -
    public func getPriorityWidgets(from panelItems: [KREPanelItem], block:((Bool) -> Void)?) {
        let widgets = panelItems.flatMap { $0.widgets }.flatMap { $0 }
        let prioritiyWidgets = widgets.filter({ $0.priority == true })
        
        let group = DispatchGroup()
        group.enter()
        
        for widget in prioritiyWidgets {
            group.enter()
            widget.dataSource?.willUpdateWidget(widget)
            fetchWidget(widget, forceReload: false) { (success) in
                widget.dataSource?.didUpdateWidget(widget)
                group.leave()
            }
        }
        
        group.leave()
        group.notify(queue: DispatchQueue.main) {
            block?(true)
        }
    }
    
    public func getWidgets(in panelItem: KREPanelItem?, forceReload reload: Bool = false, update updateBlock:((Bool, KREWidget) -> Void)?, completion completionBlock: ((Bool) -> Void)?) {
        guard let server = user?.server, let userId = user?.userId else {
            return
        }

        let group = DispatchGroup()
        group.enter()
        
        if let widgets = panelItem?.widgets {
            group.enter()
            for widget in widgets {
                group.enter()
                fetchWidget(widget, forceReload: reload) { (success) in
                    DispatchQueue.main.async {
                        updateBlock?(success, widget)
                    }
                    group.leave()
                }
            }
            group.leave()
        }
        
        group.leave()
        group.notify(queue: DispatchQueue.main) {
            completionBlock?(true)
        }
    }
    
    func fetchWidget(_ widget: KREWidget, forceReload reload: Bool, completion block: ((Bool) -> Void)?) {
        switch widget.widgetState {
        case .refreshing, .loading:
            block?(false)
            return
        case .loaded, .refreshed:
            let date = Date()
            let calendar = Calendar.current
            let components = calendar.dateComponents([.second], from: widget.lastSyncDate ?? date, to: date)
            let differenceInSeconds = components.second ?? 0
            if !reload && differenceInSeconds < timeDifference {
                block?(false)
                widget.widgetState = .refreshed
                return
            }
            
            widget.widgetState = .refreshing
        case .requestFailed, .noNetwork:
            widget.widgetState = .loading
        default:
            widget.widgetState = .loading
        }
        
        getWidget(widget, completion: { [weak self] (success, component, error) in
            guard !success, let error = error as? NSError else {
                widget.widgetState = (widget.widgetState == .refreshing) ? .refreshed : .loaded
                widget.lastSyncDate = Date()
                block?(success)
                return
            }
            
            // process error cases
            switch error.domain {
//            case NSURLErrorDomain:
//                switch error.code {
//                case NSURLErrorCannotConnectToHost, NSURLErrorNotConnectedToInternet:
//                    widget.widgetState = .noNetwork
//                default:
//                    widget.widgetState = .requestFailed
//                }
//            case AFURLResponseSerializationErrorDomain:
//                if let response = error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey] as? HTTPURLResponse {
//                    let statusCode = response.statusCode
//                    switch statusCode {
//                    case 410:
//                        self?.cancelAllRequests()
//                        self?.sessionExpiredAction?(error)
//                        break
//                    default:
//                        break
//                    }
//                }
//                widget.widgetState = .requestFailed
            default:
                widget.widgetState = .requestFailed
            }
            
            block?(success)
        })
    }
    
    // MARK: - requests
    public func getPanelItems(completion block: ((Bool, Any?, Error?) -> Void)?) {
        guard let server = user?.server else {
            block?(false, nil, nil)
            return
        }
        let panelRequestOperation = KREPanelRequestOperation(user: user)
        panelRequestOperation.setCompletionBlock(progress: { (progress) in
            
        }, success: { [weak self] (success, panelItems) in
            self?.panelItems = panelItems
            block?(success, panelItems, nil)
        }) { (error) in
            block?(false, nil, error)
        }
        operationQueue.addOperation(panelRequestOperation)
    }
        
    func getWidget(_ widget: KREWidget?, completion block: ((Bool, Any?, Error?) -> Void)?) {
        guard let server = user?.server else {
            block?(false, nil, nil)
            return
        }

        if widget?.templateType == "headLines" {
            let widgetRequestOperation = KRESummaryRequestOperation(widget: widget, user: user)
            widgetRequestOperation.setCompletionBlock(progress: { (progress) in
                
            }, success: { [weak self] (component, success) in
                block?(success, component, nil)
            }) { (error) in
                block?(false, nil, error)
            }
            operationQueue.addOperation(widgetRequestOperation)
        } else {
            let widgetRequestOperation = KREWidgetRequestOperation(widget: widget, user: user)
            widgetRequestOperation.setCompletionBlock(progress: { (progress) in
                
            }, success: { [weak self] (component, success) in
                block?(success, component, nil)
            }) { (error) in
                block?(false, nil, error)
            }
            operationQueue.addOperation(widgetRequestOperation)
        }
    }
    
    func cancelAllRequests() {
        operationQueue.cancelAllOperations()
    }
    
    // MARK: -
    public func getPanelItem(with panelId: String?) -> KREPanelItem? {
        let results = panelItems?.filter({$0.id == panelId })
        return results?.first
    }
    
    // MARK: -
    public func profileIdentity(for contact: KREContacts?) -> KREIdentity {
        if let identity = contact?.identity {
            identity.icon = contact?.icon
            identity.userId = contact?.id
            identity.color = contact?.color
            identity.initials = contact?.initials
            identity.server = user?.server
            return identity
        } else {
            let identity = KREIdentity()
            identity.icon = contact?.icon
            identity.userId = contact?.id
            identity.color = contact?.color
            identity.initials = contact?.initials
            identity.server = user?.server
            contact?.identity = identity
            return identity
        }
    }
        
  /*  Home panel - use below API to pin/unpin widgets
    PUT /ka/users/:userId/layout
    {"pinWidget": {"id": "widgetId", "panelId":"panelId", "name": "WidgetTitle", "skillId": "skillId"}}
    or
    {"unpinWidget": {"id": "widgetId", "panelId":"panelId", "name": "WidgetTitle", "skillId": "skillId"}}*/
    
   public func setPinUnPinApi(parameters: [String: Any], with block: ((_ status: Bool,_ componentElements: Any?) -> Void)?) {
        if let baseUrl = KREWidgetManager.shared.user?.server {
            guard let userId = KREWidgetManager.shared.user?.userId else {
                return
            }
            var urlString = baseUrl + String(format:"api/1.1/ka/users/%@/layout", userId)
            let headers = getRequestHeaders()
            
            let dataRequest = sessionManager.request(urlString, method: .put, parameters: parameters, headers: headers)
            dataRequest.validate().responseJSON { (response) in
                var success: Bool = false
                var componentElements: [Any] = [Any]()
                if let _ = response.error {
                    let error: NSError = NSError(domain: "", code: 0, userInfo: [:])
                    block?(false, error)
                    return
                }
                                
                if let dictionary = response.value as? [String: Any] {
                    success = true
                    let jsonDecoder = JSONDecoder()
                    block?(success, componentElements)
                    return
                } else {
                    block?(false, nil)
                }
            }
        }
    }
    
    public func pinOrUnpinWidget(_ dictionary: [String: Any]?) {
        guard let panels = KREWidgetManager.shared.panelItems else {
            return
        }
        
        if var panelItem = panels.filter({$0.id == "home" }).first {
            if let unpinWidget = dictionary?["unpinWidget"] as? [String: Any],
                let widgetId = unpinWidget["id"] as? String {
                if let index = panelItem.widgets?.index(where: { $0._id == widgetId }) {
                    panelItem.widgets?.remove(at: index)
                }
            }
        }
    }

    public func reset() {
        cancelAllRequests()
        panelItems?.removeAll()
        panelItems = nil
        user = nil
    }
    
    // MARK: - deinit
    deinit {

    }
}

// MARK: -
public class KREWidgetUtilities: NSObject {
    public class func profileIdentity(for contact: KREContacts?, server: String?) -> KREIdentity {
        let identity = KREIdentity()
        identity.icon = contact?.icon
        identity.userId = contact?.id
        identity.color = contact?.color
        identity.initials = contact?.initials
        identity.server = server
        contact?.identity = identity
        return identity
    }
}
