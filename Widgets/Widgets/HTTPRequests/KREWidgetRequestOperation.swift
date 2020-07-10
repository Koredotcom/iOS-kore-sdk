//
//  KREWeatherRequestOperation.swift
//  KoreBotSDK
//
//  Created by Srinivas Vasadi on 12/03/19.
//  Copyright © 2019 Srinivas Vasadi. All rights reserved.
//

import UIKit
import AFNetworking

// MARK: - KREWidgetRequestOperation
class KREWidgetRequestOperation: KREOperation {
    // MARK: -
    var urlString: String?
    var error: Error?
    var progressBlock: ((_ progress: Progress) -> Void)?
    let widgetManager = KREWidgetManager.shared
    let sessionManager = KREWidgetManager.shared.sessionManager
    var widget: KREWidget?
    var user: KREUser?
    var success = true
    
    // MARK: - init
    init(widget: KREWidget?, user: KREUser?) {
        super.init()
        self.widget = widget
        self.user = user
    }
    
    // MARK: - comment operation
    func setCompletionBlock(progress: ((_ progress: Progress) -> Void)?, success: ((_ widget: KREWidget?, _ success: Bool) -> Void)?, failure: ((_ error: Error?) -> Void)?) {
        self.progressBlock = progress
        self.completionBlock = { [weak self] () in
            guard let weakSelf = self, weakSelf.isCancelled == false else {
                return
            }
            if let widget = weakSelf.widget, weakSelf.success {
                success?(widget, true)
            } else {
                failure?(weakSelf.error)
            }
        }
    }
    
    // MARK: - start event
    override func start() {
        super.start()
        let manager = KREWidgetManager.shared
        if let widgetFilters = widget?.filters, widgetFilters.count > 0 {
            let group = DispatchGroup()
            let queue = DispatchQueue(label: "com.kore.widgets")
            group.enter()
            for i in 0..<widgetFilters.count {
                guard let widgetFilter = widgetFilters[i] as? KREWidgetFilter else {
                    continue
                }
                
                if let widgetId = widget?.widgetId, widgetId == "upcomingMeetings" {

                }
                
                group.enter()
                manager.updateWidgetFilter(widgetFilter, isLoading: true)
                group.leave()

                group.enter()
                queue.async {
                    self.sendRequest(widgetFilter: widgetFilter, completion: { [weak self] (status) in
                        if let weakSelf = self {
                            weakSelf.success = weakSelf.success && status
                        }
                        
                        let delayInMilliSeconds = 2000
                        queue.asyncAfter(deadline: .now() + .milliseconds(delayInMilliSeconds)) {
                            manager.updateWidgetFilter(widgetFilter, isLoading: false)
                            group.leave()
                        }
                    })
                }
            }
            group.leave()
            
            group.notify(queue: DispatchQueue.main) {
                manager.updateSelectedWidgetFilter(for: self.widget)
                self.finish()
            }
        }  else {
            let json = """
            {
             "isSelected": true
            }
            """.data(using: .utf8)!
            if var widgetFilter = try? JSONDecoder().decode(KREWidgetFilter.self, from: json)  {
                widgetFilter.isSelected = true
                widget?.filters = [widgetFilter]
                self.sendRequest(widgetFilter: widgetFilter, completion: { [weak self] (status) in
                    if let weakSelf = self {
                        weakSelf.success = weakSelf.success && status
                    }
                    manager.updateWidgetFilter(widgetFilter, isLoading: false)
                    self?.finish()
                })
            }
        }
    }
    
    func finish() {
        self.state = .finished
    }
    
    // MARK: - send comment
    func sendRequest(widgetFilter: KREWidgetFilter?, completion block: ((_ status: Bool) -> Void)?) {
        var urlString = user?.server ?? ""
        var httpMethod = "GET"
        var parameters: [String: Any]?
        var body: [String: Any]?
        
        if let baseHook = widgetFilter?.baseHook {
            urlString = urlString + (baseHook.api ?? "")
            httpMethod = (baseHook.method ?? "")
            body = inputs(in: baseHook)
            parameters = baseHook.params
        } else {
            urlString = urlString + (widget?.baseHook?.api ?? "")
            httpMethod = widget?.baseHook?.method ?? ""
            body = inputs(in: widget?.baseHook)
            parameters = widget?.baseHook?.params
        }
        
        let userId = user?.userId ?? ""
        httpMethod = "Post"
        let dictionary: NSMutableDictionary = NSMutableDictionary()
        let widgetId = widget?._id ?? ""
        let email = user?.userEmail ?? ""
        let jwtAccessToken = user?.accessToken ?? ""
        dictionary.setObject(email as String, forKey: "from" as NSCopying)
        dictionary.setObject("{}", forKey: "inputs" as NSCopying)
        body = dictionary as! [String : Any]
        //print(body)
        //print(dictionary)
        urlString = widgetsUrl(with: userId, server: urlString, widgetId: widgetId)
        let accessToken: String = String(format: "bearer %@", jwtAccessToken)
        sessionManager?.requestSerializer.setValue(accessToken, forHTTPHeaderField:"Authorization")

        let requestSerializer = widgetManager.requestSerializer()
        sessionManager?.requestSerializer = requestSerializer
        sessionManager?.responseSerializer = AFJSONResponseSerializer()
        
        guard let urlRequest = try? requestSerializer.request(withMethod: httpMethod, urlString: urlString, parameters: body) as URLRequest else {
            block?(false)
            return
        }
        
        let dataTask = sessionManager?.dataTask(with: urlRequest, uploadProgress: { (progress) in
            
        }, downloadProgress: { (progress) in
            
        }, completionHandler: { [weak self] (response, responseObject, error) in
            self?.error = error
            var success: Bool = false
            widgetFilter?.baseHook?.error = error
            guard error == nil, let dictionary = responseObject as? [String: Any] else {
                block?(success)
                return
            }
            success = true
            let manager = KREWidgetManager.shared
            let array = dictionary["data"] as! NSArray
            let botWidgetDictionary = array.count>0 ? array[0] : dictionary
            //print(botWidgetDictionary)
            if let _ = botWidgetDictionary as? Dictionary<AnyHashable, Any>{
                manager.insertOrUpdateWidgetComponent(for: widgetFilter, in: self?.widget, with: botWidgetDictionary as! [String : Any])
            }else{
                manager.insertOrUpdateWidgetComponent(for: widgetFilter, in: self?.widget, with: dictionary)
            }
            block?(success)
        })
        dataTask?.resume()
    }
    
    // MARK: -
    func inputs(in hook: Hook?) -> [String: Any] {
        guard let fields = hook?.fields else {
            return [:]
        }
        var inputFields = [String: Any]()
        for field in fields {
            guard  let label = field.label else {
                continue
            }
            if let value = field.defaultValue {
                inputFields[label] = value
            }
            switch label {
            case "timeZone":
                inputFields[label] = TimeZone.current.identifier
            default:
                break
            }
        }
        return inputFields
    }
    func widgetsUrl(with userId: String, server: String, widgetId: String) -> String {
            return String(format: "\(server)widgetsdk/\(userId)/widgets/\(widgetId)?")
        }
}


