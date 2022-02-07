//
//  KREDriveListManager.swift
//  Pods
//
//  Created by Sukhmeet Singh on 14/03/19.
//

import UIKit
import AFNetworking

public class KREDriveListManager: NSObject {
    let sessionManager = KREWidgetManager.shared.sessionManager
    var error: Error?

    public func getDrive(urlString: String, parameters: [String: Any], with block: ((_ status: Bool,_ componentElements: Any?) -> Void)?) {
        if let baseUrl = KREWidgetManager.shared.user?.server {
            
            var urlApi = baseUrl + urlString
            let requestSerializer = KREWidgetManager.shared.requestSerializer()
            
            let dataTask = sessionManager?.get(urlApi, parameters: parameters, headers: nil, progress: { (progress) in
                
            }, success: { (dataTask, responseObject) in
                var success: Bool = false
                var componentElements: [Any] = [Any]()
                
                guard let dictionary = responseObject as? [String: Any] else {
                    block?(success, componentElements)
                    return
                }
                
                success = true
                let jsonDecoder = JSONDecoder()
                
                if let elements = dictionary["elements"] as? Array<[String: Any]> {
                    for element in elements {
                        if let templateType = element["template_type"] as? String {
                            switch templateType {
                            case "files_search":
                                if let elementData = try? JSONSerialization.data(withJSONObject: element, options: .prettyPrinted) {
                                    let driveFileInfo = try? jsonDecoder.decode(KREDriveFileInfo.self, from: elementData)
                                    componentElements.append(driveFileInfo)
                                }
                            case "calendar_events":
                                if let elementData = try? JSONSerialization.data(withJSONObject: element, options: .prettyPrinted) {
                                    let driveFileInfo = try? jsonDecoder.decode(KRECalendarEvent.self, from: elementData)
                                    componentElements.append(driveFileInfo)
                                }
                            case "task_list":
                                if let elementData = try? JSONSerialization.data(withJSONObject: element, options: .prettyPrinted) {
                                    let driveFileInfo = try? jsonDecoder.decode(KRETaskListItem.self, from: elementData)
                                    componentElements.append(driveFileInfo)
                                }

                            default:
                                break
                            }
                        }
                    }
                }
                block?(success, componentElements)
            }, failure: { (dataTask, error) in
                block?(false, nil)
                
            })
            dataTask?.resume()
        }
    }
    
    func stautusUpdateApi(parameters: [String: Any], with block: ((_ status: Bool,_ componentElements: Any?) -> Void)?) {
        if let baseUrl = KREWidgetManager.shared.user?.server {
            guard let userId = KREWidgetManager.shared.user?.userId else {
                return
            }
            let urlApi = baseUrl + String(format:"api/1.1/ka/users/%@/calendar/updateEvent", userId)
            let dataTask = sessionManager?.post(urlApi, parameters: parameters, headers: nil, progress: { (progress) in
                
            }, success: { (dataTask, responseObject) in
                //self?.error = error
                var success: Bool = false
                var componentElements: [Any] = [Any]()
                
                guard let dictionary = responseObject as? [String: Any] else {
                    block?(success, componentElements)
                    
                    return
                }
                
                success = true
                let jsonDecoder = JSONDecoder()
                
                block?(success, componentElements)
            }, failure: { (dataTask, error) in
                block?(false, nil)
            })
            dataTask?.resume()
        }
    }
    
    func updateWidgetLayot(parameters: [String: Any], with block: ((_ status: Bool,_ componentElements: Any?) -> Void)?) {
        if let baseUrl = KREWidgetManager.shared.user?.server {
            guard let userId = KREWidgetManager.shared.user?.userId else {
                return
            }
            var urlApi = baseUrl + String(format:"api/1.1/ka/users/%@/widgets/layout", userId)
            let requestSerializer = KREWidgetManager.shared.requestSerializer()
            
            let dataTask = sessionManager?.put(urlApi, parameters: parameters, headers: nil, success: { (dataTask, responseObject) in
                //self?.error = error
                var success: Bool = false
                var componentElements: [Any] = [Any]()
                
                guard let dictionary = responseObject as? [String: Any] else {
                    block?(success, componentElements)
                    return
                }
                
                success = true
                let jsonDecoder = JSONDecoder()
                block?(success, componentElements)
            }, failure: { (dataTask, error) in
                block?(false, nil)
            })
            dataTask?.resume()
        }
    }

    public func panelWidgetLayot(parameters: [String: Any], panelId: String, with block: ((_ status: Bool,_ componentElements: Any?) -> Void)?) {
        if let baseUrl = KREWidgetManager.shared.user?.server {
            guard let userId = KREWidgetManager.shared.user?.userId else {
                return
            }
            var urlApi = baseUrl + String(format:"api/1.1/ka/users/%@/panels/%@/layout",userId, panelId)
            let dataTask = sessionManager?.post(urlApi, parameters: parameters, headers: nil, progress: nil, success: { (dataTask, responseObject) in
                var success: Bool = false
                var componentElements: [Any] = [Any]()
                
                guard let dictionary = responseObject as? [String: Any] else {
                    block?(success, componentElements)
                    
                    return
                }
                
                success = true
                block?(success, componentElements)
            }, failure: { (dataTask, error) in
                block?(false, nil)
            })
            dataTask?.resume()
        }
    }
    
    public func getMeetingDetails(eventId: String, with block: ((_ status: Bool,_ componentElements: Any?) -> Void)?) {
        if let baseUrl = KREWidgetManager.shared.user?.server {
            guard let userId = KREWidgetManager.shared.user?.userId else {
                return
            }
            
            let urlApi = baseUrl + String(format:"api/1.1/ka/users/%@/calendar/getSpecificEvent", userId)
            let parameters = ["eventId": eventId]
            let dataTask = sessionManager?.post(urlApi, parameters: parameters, headers: nil, progress: nil, success: { (dataTask, responseObject) in
                block?(true, responseObject)
            }, failure: { (dataTask, error) in
                block?(false, nil)
            })
            dataTask?.resume()
        }
    }
    
    open func paginationApiCall(hookParams: Hook?, with block: ((_ status: Bool,_ componentElements: [String: Any]) -> Void)?) {
        if let baseUrl = KREWidgetManager.shared.user?.server {
            guard let userId = KREWidgetManager.shared.user?.userId else {
                return
            }
            var urlApi = baseUrl + (hookParams?.api ?? "")
            let requestSerializer = KREWidgetManager.shared.requestSerializer()
            urlApi = addQueryString(to: urlApi, with: hookParams?.params)
            debugPrint("Api string \(urlApi)")
            let body = inputs(in: hookParams)
            guard let urlRequest = try? requestSerializer.request(withMethod: hookParams?.method ?? "", urlString: urlApi, parameters: body) as URLRequest else {
                block?(false, [:])
                return
            }
            
            let dataTask = sessionManager?.dataTask(with: urlRequest, uploadProgress: { (progress) in
                
            }, downloadProgress: { (progress) in
                
            }, completionHandler: { [weak self] (response, responseObject, error) in
                //self?.error = error
                var success: Bool = false
                var componentElements: [Any] = [Any]()
                
                guard error == nil, let dictionary = responseObject as? [String: Any] else {
                    block?(success, [:])
                    
                    return
                }
                
                success = true
                let jsonDecoder = JSONDecoder()
                
                block?(success, dictionary)
            })
            dataTask?.resume()
        }
    }
    
    // MARK: - add query parameters
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
    
    public func getTask(urlString: String, parameters: [String: Any], with block: ((_ status: Bool,_ componentElements: [Any]) -> Void)?) {
        if let baseUrl = KREWidgetManager.shared.user?.server {
            
            var urlApi = baseUrl + urlString
            let dataTask = sessionManager?.get(urlApi, parameters: parameters, headers: nil, progress: { (progress) in
                
            }, success: { (dataTask, responseObject) in
                //self?.error = error
                var success: Bool = false
                var componentElements: [Any] = [Any]()
                
                guard let dictionary = responseObject as? [String: Any] else {
                    block?(success, componentElements)
                    return
                }
                
                success = true
                let jsonDecoder = JSONDecoder()
                if let taskData = try? JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted) {
                    let taskElement = try? jsonDecoder.decode(WidgetComponent.self, from: taskData)
                    componentElements.append(taskElement)
                }
                block?(success, componentElements)
            }, failure: { [weak self] (dataTask, error) in
                //                self?.error = error
                block?(false, [])
            })
            dataTask?.resume()
        }
    }
    
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
