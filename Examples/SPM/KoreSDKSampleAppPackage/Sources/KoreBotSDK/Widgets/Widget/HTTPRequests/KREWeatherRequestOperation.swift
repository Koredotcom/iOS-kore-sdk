//
//  KREWeatherRequestOperation.swift
//  KoreBotSDK
//
//  Created by Srinivas Vasadi on 12/03/19.
//  Copyright © 2019 Srinivas Vasadi. All rights reserved.
//

import UIKit
import Alamofire


// MARK: - KREOperation
class KREOperation: Foundation.Operation {
    override var isAsynchronous: Bool {
        return true
    }
    override var isExecuting: Bool {
        return state == .executing
    }
    override var isFinished: Bool {
        return state == .finished
    }
    
    var state = State.ready {
        willSet {
            willChangeValue(forKey: state.keyPath)
            willChangeValue(forKey: newValue.keyPath)
        }
        didSet {
            didChangeValue(forKey: state.keyPath)
            didChangeValue(forKey: oldValue.keyPath)
        }
    }
    
    enum State: String {
        case ready = "Ready"
        case executing = "Executing"
        case finished = "Finished"
        fileprivate var keyPath: String { return "is" + self.rawValue }
    }
    
    override func start() {
        if self.isCancelled {
            state = .finished
        } else {
            state = .ready
            main()
        }
    }
    
    override func main() {
        if self.isCancelled {
            state = .finished
        } else {
            state = .executing
        }
    }
    
    func addQueryString(to urlString: String, with parameters: [String: Any]?) -> String {
        guard var urlComponents = URLComponents(string: urlString), let parameters = parameters, !parameters.isEmpty else {
            return urlString
        }
        
        let keys = parameters.keys.map { $0.lowercased() }
        urlComponents.queryItems = urlComponents.queryItems?
            .filter { !keys.contains($0.name.lowercased()) } ?? []
        
        urlComponents.queryItems?.append(contentsOf: parameters.compactMap {
            return URLQueryItem(name: $0.key, value: "\($0.value)")
        })
        
        return urlComponents.string ?? urlString
    }
}

// MARK: - KRESummaryRequestOperation
class KRESummaryRequestOperation: KREOperation {
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
        if let widgetFilters = widget?.elements, widgetFilters.count > 0 {
            let group = DispatchGroup()
            let queue = DispatchQueue(label: "com.kore.widgetsummary")
            group.enter()
            for i in 0..<widgetFilters.count {
                guard let widgetFilter = widgetFilters[i] as? KRESummaryElement else {
                    continue
                }
                group.enter()
                //     manager.updateWidgetFilter(widgetFilter, isLoading: true)
                group.leave()
                group.enter()
                queue.async {
                    self.sendRequest(summaryElement: widgetFilter, completion: { [weak self] (status) in
                        if let weakSelf = self {
                            weakSelf.success = weakSelf.success && status
                        }
                        let delayInMilliSeconds = 2000
                        queue.asyncAfter(deadline: .now() + .milliseconds(delayInMilliSeconds)) {
                            // manager.updateWidgetFilter(widgetFilter, isLoading: false)
                            group.leave()
                        }
                    })
                }
            }
            group.leave()
            
            group.notify(queue: DispatchQueue.main) {
                //  manager.updateSelectedWidgetFilter(for: self.widget)
                self.finish()
            }
        }  else {
//            let json = """
//            {
//             "isSelected": true
//            }
//            """.data(using: .utf8)!
//            if var widgetFilter = try? JSONDecoder().decode(KREWidgetFilter.self, from: json)  {
//                widgetFilter.isSelected = true
//                widget?.filters = [widgetFilter]
//                self.sendRequest(widgetFilter: widgetFilter, completion: { [weak self] (status) in
//                    if let weakSelf = self {
//                        weakSelf.success = weakSelf.success && status
//                    }
//                    manager.updateWidgetFilter(widgetFilter, isLoading: false)
//                    self?.finish()
//                })
//            }
        }
    }
    
    func finish() {
        self.state = .finished
    }
    
    // MARK: - send comment
    func sendRequest(summaryElement: KRESummaryElement?, completion block: ((_ status: Bool) -> Void)?) {
        var urlString = user?.server ?? ""
        var httpMethod = "GET"
        var parameters: [String: Any]?
        var body: [String: Any]?

        urlString = urlString + (summaryElement?.hook?.api ?? "")
        httpMethod = summaryElement?.hook?.method ?? ""
        body = inputs(in: summaryElement?.hook)
        parameters = summaryElement?.hook?.params
        urlString = addQueryString(to: urlString, with: parameters)

        let headers = widgetManager.getRequestHeaders()
        let method = HTTPMethod(rawValue: httpMethod.uppercased())
        
        let dataRequest = sessionManager.request(urlString, method: method, parameters: body, headers: headers)
        dataRequest.validate().responseJSON { [weak self] (response) in
            var success: Bool = false
            if let error = response.error {
                self?.error = error
                block?(false)
                return
            }
            guard let dictionary = response.value as? [String: Any] else {
                block?(success)
                return
            }
            success = true
            summaryElement?.title = dictionary["title"] as? String
            block?(success)
        }
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

}

