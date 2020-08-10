//
//  KREPanelOperation.swift
//  Pods
//
//  Created by Sukhmeet Singh on 17/10/19.
//
import AFNetworking

class KREPanelRequestOperation: KREOperation {
    // MARK: -
    var user: KREUser?
    var error: Error?
    var requestStatus: Bool = false
    var progressBlock: ((_ progress: Progress) -> Void)?
    let widgetManager = KREWidgetManager.shared
    let sessionManager = KREWidgetManager.shared.sessionManager
    var panelItems: [KREPanelItem]?

    // MARK: - init
    init(user: KREUser?) {
        super.init()
        self.user = user
    }
    
    // MARK: - comment operation
    func setCompletionBlock(progress: ((_ progress: Progress) -> Void)?, success: ((_ success: Bool, _ panelItems: [KREPanelItem]) -> Void)?, failure: ((_ error: Error?) -> Void)?) {
        self.progressBlock = progress
        self.completionBlock = { [weak self] () in
            guard let weakSelf = self, weakSelf.isCancelled == false else {
                return
            }
            if weakSelf.requestStatus, let panels = weakSelf.panelItems {
                success?(weakSelf.requestStatus, panels)
            } else {
                failure?(weakSelf.error)
            }
        }
    }
    
    // MARK: - start event
    override func start() {
        super.start()
        
        sendRequest(with: { [weak self] (status) in
            self?.finish()
        })
    }
    
    func finish() {
        self.state = .finished
    }
    
    // MARK: - send request
    func sendRequest(with block: ((_ status: Bool) -> Void)?) {
        guard let userId = user?.userId, let server = user?.server, let email = user?.userEmail, let jwtAccessToken = user?.accessToken else {
            block?(false)
            return
        }
        KRELocationManager.shared.setupLocationManager()
        let urlString: String?
        urlString = panelsUrl(with: userId, server: server, email: email)
        let accessToken: String = String(format: "bearer %@", jwtAccessToken)
        sessionManager?.requestSerializer.setValue(accessToken, forHTTPHeaderField:"Authorization")
       
        let requestSerializer = widgetManager.requestSerializer()
        sessionManager?.requestSerializer = requestSerializer
        sessionManager?.responseSerializer = AFJSONResponseSerializer()
        
        let dataTask = sessionManager?.get(urlString!, parameters: nil, headers: nil, progress: { (progress) in
            
        }, success: { [weak self] (dataTask, responseObject) in
            var success: Bool = false
            var responseObj =  NSMutableDictionary()
            responseObj["panels"] = responseObject
            guard let dictionary = responseObj as? [String: Any],
                let panelsData = dictionary["panels"] as? Array<[String: Any]> else {
                    block?(false)
                    return
            }
            self?.widgetManager.insertOrUpdatePanelItems(with: dictionary)
            self?.requestStatus = true
            self?.panelItems = self?.widgetManager.panelItems
            success = true
            block?(success)
        }, failure: { [weak self] (dataTask, error) in
            self?.error = error
            block?(false)
        })
        dataTask?.resume()
    }
    
    func panelsUrl(with userId: String, server: String, email: String) -> String {
        let timezone = TimeZone.current.identifier
        KRELocationManager.shared.updateLastKnowLocation()
        let lastKnownRegion = KRELocationManager.shared.lastKnowRegion
        if let latitude = lastKnownRegion?.latitude, let longitude = lastKnownRegion?.longitude {
            return String(format: "\(server)widgetsdk/\(userId)/panels?resolveWidgets=true&from=\(email)")
        } else {
            return String(format: "\(server)widgetsdk/\(userId)/panels?resolveWidgets=true&from=\(email)")
        }
    }
}
