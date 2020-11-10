//
//  KAAccount.swift
//  KoraSDK
//
//  Created by Srinivas Vasadi on 06/11/18.
//  Copyright © 2018 Srinivas Vasadi. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation
import AFNetworking
import Mantle
import KoreBotSDK
import Intents

public class KAAccount: NSObject {
    // MARK: - properties
//    public var userInfo: KAUserInfo?
//    public var authInfo: KAAuthInfo?
//    public var userSettings: KASettings?
//    public var profileInfo: KAUserProfile?
    public var adminAccount: KAAdminAccount?
//    public var userStats: KAUserStats?
//    public var currentSkillChanged = KoraObservable(0)
    public var currentSkill: KASkillMessage? {
        didSet {
            //currentSkillChanged.value += 1
        }
    }
   // var koraHelp: KoraHelp?
   // var askPhrases: [AskPhrases]?
    var recentSkillsArr: [KASkillMessage]?
//    public var recentSkillsUpdated = KoraObservable(false)
//    public var recentAnnouncements: KARecentAnnouncements?
//    public var recentKnowledgeItems: KARecentKnowledgeItems?
//    public var recentSharedKnowledgeItems: KARecentSharedKnowledgeItems?
//    var applicationControl: ApplicationControl?
    var usageLimit: [UsageLimits]?
   // var persistentConnectionStatus: KAPersistentConnectionStatus = .none
    var wsKeyMapping: NSDictionary!
    var userDispatchQueue: DispatchQueue?
    let koraApplication = KoraApplication.sharedInstance
  //  let persistentStoreManager = KAPersistentStoreManager()
    var error: Error!
    private var completionQueue = DispatchQueue(label: "com.queue.kora")
    public let CONTACTS_FETCH_LIMIT: Int = 500
    public let NOTFICATION_FETCH_LIMIT = 50
    public var botClient: KABotClient?
    public var activeRequests: [String: Any] = [String: Any]()
    public var notificationCountHandler: (() -> Void)?
    public var timeZoneHandler: (() -> Void)?
    var pendingTasks = [URLSessionDataTask]()
    var user: KREUser?
   // var shortcutManager: SiriShortcutManager?
    var isContactSyncInProgress = false
    var jwtToken: String?
  //  public var settingsModal = SettingsModal()
    
//    public var tour: KAOnboardingTour?
//    public var features: [FeatureItem]?
//    public var ratings: [RatingItem]?

    var networkReachabilityStatus = AFNetworkReachabilityStatus.notReachable
    
    var requestSessionManager: KAHTTPSessionManager = {
        let sessionManager = KAHTTPSessionManager(baseURL: URL(string: SDKConfiguration.serverConfig.JWT_SERVER))
        return sessionManager
    }()
    
    var sessionManager: KAHTTPSessionManager = {
        let sessionManager = KAHTTPSessionManager(baseURL: URL(string: SDKConfiguration.serverConfig.JWT_SERVER))
        return sessionManager
    }()
    
    var operationQueue = OperationQueue()
    
    public var DEFAULT_TIMEOUT_INTERVAL: Double = 60.0
    public var KORE_SERVER = SDKConfiguration.serverConfig.JWT_SERVER
    public var dispatchQueue: DispatchQueue = DispatchQueue(label: "com.kora.requestQueue")
    
    // MARK: -
    public var identity: String {
//        guard let identity = userInfo?.currentIdentity?.identity else {
//            return ""
//        }
//        return identity
        return "Ka"
    }
    
    public var userId: String {
//        guard let koraUserId = userInfo?.userId else {
//            return ""
//        }
//        return koraUserId
        return "Ka"
    }
    
    public var orgId: String {
//        guard let koraOrgId = userInfo?.orgId else {
//            return ""
//        }
//        return koraOrgId
        return "Ka"
    }
    
    public var accessToken: String {
//        guard let authorizationToken = authInfo?.accessToken else {
//            return ""
//        }
//        return authorizationToken
        return AcccesssTokenn ?? ""
    }
    
    // private properties
    var chunkOperationQueue: OperationQueue = OperationQueue()
    var componentOperationQueue: OperationQueue = OperationQueue()
    var downloadOperationQueue: OperationQueue = OperationQueue()
    var uploadOperationQueue: OperationQueue = OperationQueue()
    
    // MARK: - init
    public override init() {
        super.init()

//        shortcutManager = SiriShortcutManager()
//
//        _ = persistentStoreManager.initialiseKoraElementsCoreDataStack()
//
        requestSessionManager.completionQueue = completionQueue
        sessionManager.completionQueue = completionQueue
//
//        operationQueue.maxConcurrentOperationCount = 1
//        DispatchQueue.global(qos: .default).async {
//            if let path = Bundle.main.path(forResource: "WSKeyMapping", ofType:"plist") {
//                self.wsKeyMapping = NSDictionary(contentsOfFile: path)
//            }
//        }
//
//        NotificationCenter.default.addObserver(self, selector: #selector(onCreateNewMeetingNotes(_:)), name: NSNotification.Name(rawValue: "CreateMeetingNotes"), object: nil)
}
    
//    @objc func onCreateNewMeetingNotes(_ notification:Notification){
//        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "onTakeNotesButtonClick"), object: notification.object)
//    }
//
//    // MARK: - account init processing
//    public func processAccount(_ completion: (() -> Void)?) {
//        // only process account, if it is signed in
//        if authInfo == nil {
//            return
//        }
//
//        DispatchQueue.main.async {
//            completion?()
//        }
//    }
//
//    public func signOut(completion block: (() -> Void)?) {
//        invalidateSession()
//        NotificationCenter.default.post(name: Notification.Name(rawValue: KoraNotification.DisconnectPersistentConnection), object: self)
//        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "AccountSignout"), object: self)
//        if let context = koraApplication.mainContext {
//            self.authInfo = nil
//            context.perform({
//                self.koraApplication.removeAuthInfo()
//                self.deinitializeWidgetManager()
//                self.persistentStoreManager.removeKoraElementsDB()
//
//                NotificationCenter.default.post(name: Notification.Name(rawValue: KoraNotification.AccountManagerUserSignedOut), object: self)
//                DispatchQueue.main.async {
//                    block?()
//                }
//            })
//        } else {
//            block?()
//        }
//    }
//
//    func updateAccount(completion block: ((Bool, Error?) -> Void)?) {
//        guard let authInfo = self.authInfo, let accessToken = authInfo.accessToken, let userId = userInfo?.userId else {
//            DispatchQueue.main.async {
//                block?(false, nil)
//            }
//            return
//        }
//
//        prepareInAppStoreItems()
//        registerForContactChanges()
//        updateMetaObjects(completion: nil)
//        let batchRequestUrl = String(format: "\(SDKConfiguration.serverConfig.KORE_SERVER)api/1.1/users/batch")
//        let authorization = "bearer \(accessToken)"
//        let index: Int = 0
//
//        // user profile
//        let profileEndpoint = String(format: "/api/ka/users/\(userId)/profile")
//        let profileDict: [String: Any] = ["method": "GET", "url": profileEndpoint, "headers": ["Authorization": authorization]]
//        let profileIndex = index
//
//        // user settings
//        let settingsEndpoint = "/api/1.1/users/\(userId)/settings"
//        let settingsDict: [String: Any] = ["method": "GET", "url": settingsEndpoint, "headers": ["Authorization": authorization]]
//        let settingsIndex = profileIndex + 1
//
//        let notificationsEndpoint = "/api/1.1/ka/users/\(userId)/notifications?limit=20&sort=descending"
//        let notificationsDict: [String: Any] = ["method": "GET", "url": notificationsEndpoint, "headers": ["Authorization": authorization]]
//        let notificationsIndex = settingsIndex + 1
//
//        let appControlsEndpoint = KARESTAPIManager.shared.appControlsUrl(with: userId, server: "\\")
//        let appControlsDict: [String: Any] = ["method": "GET", "url": appControlsEndpoint, "headers": ["Authorization": authorization]]
//        let appControlsIndex = notificationsIndex + 1
//
//        // batch POST request
//        let parameters = [profileDict, settingsDict, notificationsDict, appControlsDict]
//        _ = self.POST(urlString: batchRequestUrl, parameters: parameters, success: { [weak self] (dataTask, responseObject) in
//            guard let responseObject = responseObject as? Array<[String: Any]> else {
//                DispatchQueue.main.async {
//                    block?(false, nil)
//                }
//                return
//            }
//
//            let profile = responseObject[profileIndex]
//            let profileBody = profile["body"] as? [String: Any]
//            let profileErrors = profileBody?["errors"] as? Array<[String: Any]>
//            if let body = profileBody, profileErrors == nil {
//                self?.koraApplication.updateProfile(body)
//                self?.fetchUserProfileImage()
//            }
//
//            let settings = responseObject[settingsIndex]
//            let settingsBody = settings["body"] as? [String: Any]
//            let settingsErrors = settingsBody?["errors"] as? Array<[String: Any]>
//            if let body = settingsBody, settingsErrors == nil {
//                self?.koraApplication.updateSettings(body)
//            }
//
//            let notifications = responseObject[notificationsIndex]
//            if let notificationsBody = notifications["body"] as? [String: Any] {
//                if let nStats = notificationsBody["nStats"] as? [String: Any] {
//                    self?.updateUserStats(nStats)
//                }
//
//                let notificationsErrors = notificationsBody["errors"] as? Array<[String: Any]>
//                if notificationsErrors == nil {
//                    let body = notificationsBody
//                    self?.persistentStoreManager.insertOrUpdateAllNotifications(with: body, completion: nil)
//                }
//                DispatchQueue.main.async {
//                    self?.notificationCountHandler?()
//                }
//            }
//
//            let appControlsResponseObject = responseObject[appControlsIndex]
//            if let appControlsBody = appControlsResponseObject["body"] as? [String: Any],
//                let applicationControl = appControlsBody["applicationControl"] as? [String: Any],
//                let jsonString = Utilities.stringFromJSONObject(object: applicationControl) {
//                self?.userInfo?.applicationControls = jsonString
//                _ = try? self?.userInfo?.managedObjectContext?.save()
//                self?.setAppControls()
//            }
//
//            DispatchQueue.main.async {
//                block?(true, nil)
//            }
//        }) { (dataTask, responseObject, error) in
//            DispatchQueue.main.async {
//                block?(false, error)
//            }
//        }
//    }
//
//    func updateMetaObjects(completion block: ((Bool, Error?) -> Void)?) {
//        let batchRequestUrl = String(format: "\(SDKConfiguration.serverConfig.KORE_SERVER)api/1.1/users/batch")
//        let authorization = "bearer \(accessToken)"
//        let index: Int = 0
//
//        let askPhrasesEndpoint = KARESTAPIManager.shared.askPhrasesUrl(with: userId, server: "\\")
//        let askPhrasesDict: [String: Any] = ["method": "GET", "url": askPhrasesEndpoint, "headers": ["Authorization": authorization]]
//        let askPhrasesIndex = index
//
//        let helpPhrasesEndpoint = KARESTAPIManager.shared.helpPhrasesUrl(with: userId, server: "\\")
//        let helpPhrasesDict: [String: Any] = ["method": "GET", "url": helpPhrasesEndpoint, "headers": ["Authorization": authorization]]
//        let helpPhrasesIndex = askPhrasesIndex + 1
//
//        let recentSkillEndPoint = KARESTAPIManager.shared.getRecentSkills(with: userId, server: "\\")
//        let recentSkillsDict: [String: Any] = ["method": "GET", "url": recentSkillEndPoint, "headers": ["Authorization": authorization], "skills": "skillId"]
//        let recentSkillsIndex = helpPhrasesIndex + 1
//
//        let featuresEndPoint = KARESTAPIManager.shared.getFeatures(with: userId, server: "\\")
//        let featuresDict: [String: Any] = ["method": "GET", "url": featuresEndPoint, "headers": ["Authorization": authorization]]
//        let featuresIndex = recentSkillsIndex + 1
//
//        // batch POST request
//        let parameters = [askPhrasesDict, helpPhrasesDict, recentSkillsDict, featuresDict]
//        _ = self.POST(urlString: batchRequestUrl, parameters: parameters, success: { [weak self] (dataTask, responseObject) in
//            guard let responseObject = responseObject as? Array<[String: Any]> else {
//                DispatchQueue.main.async {
//                    block?(false, nil)
//                }
//                return
//            }
//
//            let jsonDecoder = JSONDecoder()
//            let askPhrasesResponseObject = responseObject[askPhrasesIndex]
//            if let askPhrasesBody = askPhrasesResponseObject["body"] as? [[String: Any]],
//                let data = try? JSONSerialization.data(withJSONObject: askPhrasesBody, options: .prettyPrinted) {
//                let allPhrases = try? jsonDecoder.decode([AskPhrases].self, from: data)
//                self?.askPhrases = allPhrases
//            }
//
//            let helpPhrasesResponseObject = responseObject[helpPhrasesIndex]
//            if let helpPhrasesBody = helpPhrasesResponseObject["body"] as? [String: Any],
//                let data = try? JSONSerialization.data(withJSONObject: helpPhrasesBody, options: .prettyPrinted) {
//                let koraHelp = try? jsonDecoder.decode(KoraHelp.self, from: data)
//                self?.koraHelp = koraHelp
//            }
//
//            let recentSkillsResponseObject = responseObject[recentSkillsIndex]
//            if let recentSkillsBody = recentSkillsResponseObject["body"] as? [String: Any] {
//                if let recentSkills = recentSkillsBody["skills"] as? Array<[String: Any]> {
//                    if let data = try? JSONSerialization.data(withJSONObject: recentSkills, options: .prettyPrinted) {
//                        let skillParsed = try? jsonDecoder.decode([KASkillMessage].self, from: data)
//                        self?.recentSkillsArr = skillParsed
//                        self?.recentSkillsUpdated.value = true
//                    }
//                }
//            }
//
//            let featuresResponseObject = responseObject[featuresIndex]
//            if let body = featuresResponseObject["body"] as? [String: Any] {
//                if let featuresBody = body["features"] as? Array<[String: Any]>,
//                    let data = try? JSONSerialization.data(withJSONObject: featuresBody, options: .prettyPrinted) {
//                    let features = try? jsonDecoder.decode([FeatureItem].self, from: data)
//                    self?.features = features
//                }
//
//                if let ratingsBody = body["ratings"] as? Array<[String: Any]>,
//                    let data = try? JSONSerialization.data(withJSONObject: ratingsBody, options: .prettyPrinted) {
//                    let ratings = try? jsonDecoder.decode([RatingItem].self, from: data)
//                    self?.ratings = ratings
//                }
//            }
//
//            DispatchQueue.main.async {
//                block?(true, nil)
//            }
//        }) { (dataTask, responseObject, error) in
//            DispatchQueue.main.async {
//                block?(false, error)
//            }
//        }
//    }
//
//    // MARK: -
//    public func fetchUserProfileImage() {
//        guard profileInfo?.profileIcon == "profile.png", let userId = userInfo?.userId else {
//            return
//        }
//
//        downloadProfileImage(for: userId, progress: nil, success: { [weak self] (filePath) in
//            if let filePath = filePath, FileManager.default.fileExists(atPath: filePath) == true {
//                let image = UIImage(contentsOfFile: filePath)
//                self?.updateProfileImage(image)
//            }
//        }) { (error) in
//
//        }
//    }
//
//    // MARK: - update notification stats
//    public func updateUserStats(_ nStats: [String: Any]) {
//        if let actionsCount = nStats["actions_count"] as? Int64 {
//            userStats?.nActionsCount = actionsCount
//        }
//        if let updatesUnseen = nStats["updates_unseen"] as? Int64 {
//            userStats?.nUpdatesUnseen = updatesUnseen
//        }
//        if let updatesLastSeen = nStats["updates_lseen"] as? Int64 {
//            userStats?.nUpdatesLastSeen = updatesLastSeen
//        }
//    }
//
//    public func updateSentFeedbackOn() {
//        koraApplication.updateSentFeedbackOn()
//    }
//
//    public func updateProfileImage(_ image: UIImage? = nil) {
//        let context = profileInfo?.managedObjectContext
//        context?.perform { [weak self] in
//            self?.profileInfo?.profileImage = image
//            self?.profileInfo?.profileIcon = (image == nil) ? "no-avatar" : "profile.png"
//            _ = try? context?.save()
//            self?.persistentStoreManager.saveChanges()
//
//            DispatchQueue.main.async {
//                NotificationCenter.default.post(name: KoraNotification.ProfileEvent.pictureChange.notification, object: nil)
//            }
//        }
//
//        // clear cache
//        URLCache.shared.removeAllCachedResponses()
//
//        let imageDownloader = AFImageDownloader.defaultInstance()
//        let urlCache = imageDownloader.sessionManager.session.configuration.urlCache
//        urlCache?.removeAllCachedResponses()
//
//        imageDownloader.imageCache?.removeAllImages()
//    }
//
//    // MARK: -
//    public func getPasteBoardName() -> String? {
//        if let userId = userInfo?.userId {
//            return "kora-\(userId)"
//        }
//        return nil
//    }
//
//    public var fullName: String {
//        return "\(userInfo?.firstName ?? "") \(userInfo?.lastName ?? "")".trimmingCharacters(in: CharacterSet.whitespaces)
//    }
//
//    // MARK: -
//    func removeUserDefaults() {
//        let userDefaults = UserDefaults.standard
//        userDefaults.removeObject(forKey: "KoraStartEvent")
//    }
//
//    // MARK: -
//    public func updateOnboarding(status: Bool, completion block: ((Bool) -> Void)? = nil) {
//        let status = doUpdateOnboarding(status: status, completion: { [weak self] (success) in
//            if success {
//                self?.profileInfo?.isOnboarded = NSNumber(value: true)
//                self?.persistentStoreManager.saveChanges()
//            }
//            block?(success)
//        })
//        switch status {
//        case .noNetwork:
//            block?(false)
//            break
//        default:
//            break
//        }
//    }
//
//    public func resetOnboarding() {
//        guard let _ = authInfo else {
//            return
//        }
//
//        updateOnboarding(status: false) { (success) in
//            if success {
//                DispatchQueue.main.async {
//                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: KoraNotification.EnforcementNotification), object: ["type": KoraNotification.EnforcementType.resetOnboarding])
//                }
//            }
//        }
//    }
//
//    public func getOnboardingTour(completion block: ((Bool, KAOnboardingTour?) -> Void)?) {
//        _ = doGetOnboardingTour(completion: { (success, tour) in
//            block?(success, tour)
//        })
//    }
//
//    // MARK: -
//    func checkLocationPermission() {
//        DispatchQueue.main.async {
//            KRELocationManager.shared.setupLocationManager()
//
//            DispatchQueue.global(qos: .default).async(execute: {
//                var status: CLAuthorizationStatus = CLLocationManager.authorizationStatus()
//
//                while (status == .notDetermined) {
//                    status = CLLocationManager.authorizationStatus()
//                }
//            })
//        }
//    }
//
//    func checkForSiriPermission(){
////        INPreferences.requestSiriAuthorization { (status) in
////            if status == .authorized {
////            }
////        }
//    }
//
//    // MARK: -
//    func setAppControls() {
//        guard let applicationControls = userInfo?.applicationControls,
//            let dictionary = Utilities.jsonObjectFromString(jsonString: applicationControls) as? [String: Any] else {
//            return
//        }
//
//        let jsonDecoder = JSONDecoder()
//        if let data = try? JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted) {
//            applicationControl = try? jsonDecoder.decode(ApplicationControl.self, from: data)
//        } else {
//            applicationControl = nil
//        }
//    }
//
//    // MARK: - deinit
//    deinit {
//        unRegisterForContactChanges()
//        userInfo = nil
//        authInfo = nil
//        userSettings = nil
//        profileInfo = nil
//        userDispatchQueue = nil
//    }
//}
//
//// MARK: - KAAccount+Kora.swift
//extension KAAccount {
//    // MARK: -
//    public func getProfile(completion block:((Bool) -> Void)?) {
//        let status = doGetProfile(with: { (status, responseObject) in
//            if status == true, let dictionary = responseObject as? [String: Any] {
//                KoraApplication.sharedInstance.updateProfile(dictionary)
//            }
//            block?(status)
//        })
//        switch status {
//        case .noNetwork:
//            block?(false)
//            break
//        default:
//            break
//        }
//    }
//
//    func validateTimeZone() {
//        getProfile(completion: { [weak self] (status) in
//            if status == true {
//                self?.fetchUserProfileImage()
//                self?.timeZoneHandler?()
//            }
//        })
//    }
//
//    func invalidateSession() {
//        sessionManager.invalidateSessionCancelingTasks(true, resetSession: true)
//        requestSessionManager.invalidateSessionCancelingTasks(true, resetSession: true)
//    }
//
//    // MARK:-
//    func initializeKoraBotClient() {
//        guard let _ = self.userInfo?.userId, let _ = self.authInfo else {
//            return
//        }
//
//        initializeWidgetManager()
//        botClient = KABotClient()
//
//        let networkReachabilityStatus = AFNetworkReachabilityManager.shared().networkReachabilityStatus
//        setReachabilityStatusChange(networkReachabilityStatus)
//
//        connectToKora()
//    }
//
//    func initializeWidgetManager() {
//        guard let userId = self.userInfo?.userId, let authInfo = self.authInfo, let userEmail = self.userInfo?.currentIdentity?.identity else {
//            return
//        }
//
//        let widgetManager = KREWidgetManager.shared
//        let user = KREUser()
//        user.userId = userId
//        user.accessToken = authInfo.accessToken
//        user.server = KORE_SERVER
//        user.tokenType = authInfo.tokenType
//        user.userEmail = userEmail
//        user.headers = ["X-KORA-Client": KoraAssistant.shared.applicationHeader]
//        widgetManager.initialize(with: user)
//        self.user = user
//
//        widgetManager.sessionExpiredAction = { (error) in
//            DispatchQueue.main.async {
//                NotificationCenter.default.post(name: NSNotification.Name(rawValue: KoraNotification.EnforcementNotification), object: ["type": KoraNotification.EnforcementType.userSessionDidBecomeInvalid])
//            }
//        }
//    }
//
//    func deinitializeWidgetManager() {
//        KREWidgetManager.shared.reset()
//        user = nil
//    }
//
//    var streamId: String? {
//        return botClient?.streamId
//    }
//
//    // MARK: -
//    public func connectToKora() {
//        guard let _ = userInfo, let _ = authInfo else {
//            print("Please sign in with kore account.")
//            return
//        }
//
//        botClient?.tryConnect()
//
//        getHashTags()
//        getCompanyContacts()
//    }
//
//    public func disconnectToKora() {
//
//    }
//
//    // MARK: -
//    public func setReachabilityStatusChange(_ status: AFNetworkReachabilityStatus) {
//        networkReachabilityStatus = status
//        switch status {
//        case AFNetworkReachabilityStatus.reachableViaWWAN, AFNetworkReachabilityStatus.reachableViaWiFi:
//            getNotifications()
////            validateTimeZone()
//        case AFNetworkReachabilityStatus.notReachable:
//            fallthrough
//        default:
//            break
//        }
//        botClient?.setReachabilityStatusChange(status)
//    }
//
//    // MARK: - get hash tags
//    func getHashTags(success: ((_ tokens: [String]) -> Void)?, failure: ((_ error: Error?) -> Void)?) {
//        let status = self.doGetHashtags(token: "", success: { [weak self] (dataTask, responseObject) in
//            if let array = responseObject as? [String] {
//                self?.botClient?.setHashTags(with: array)
//                success?(array)
//            } else {
//                failure?(nil)
//            }
//            }, failure: { (dataTask, responseObject, error) in
//                failure?(error)
//        })
//        if status == .noError {
//
//        }
//    }
//
    // MARK: - upload component
    public func uploadComponent(_ component: Component, progress: ((_ progress: Double) -> Void)?, success: ((_ component: Component) -> Void)?, failure: ((_ error: Error?) -> Void)?) {        
        let componentOperation: KAComponentOperation = KAComponentOperation(component: component)
        componentOperation.account = self
        componentOperation.setCompletionBlock(progress: { (value) in
            progress?(value)
        }, success: { (component) in
            success?(component)
        }, failure: { (error) in
            failure?(error)
        })
        self.componentOperationQueue.addOperation(componentOperation)
    }
    
    func sizeLimitCheck(bytes: NSNumber) -> Bool {
        guard let usage = usageLimit else {
            return false
        }
        
        let limit = usage.filter {$0.type == "attachment"}
        let kbSize = Int(truncating: bytes)/(1000 * 1000)
        if kbSize > (limit.first)?.size ?? 0 {
            return false
        } else {
            return true
        }
    }
    
    public func cancelUpload(for component: Component) {
        self.componentOperationQueue.cancelAllOperations()
    }
    
//    // MARK: - preview component
//    public func previewComponent(_ component: Component, with knowledgeId: String?, on viewController: UIViewController) {
//        switch(component.templateType) {
//        case KAAsset.audio.fileType:
//            break
//        case KAAsset.image.fileType:
//            let compoentsViewController = KAComponentsViewController(components: [component], with: 0)
//            compoentsViewController.resourceId = knowledgeId
//            let navigationController = UINavigationController(rootViewController: compoentsViewController)
//            navigationController.modalPresentationStyle = .fullScreen
//            viewController.present(navigationController, animated: true, completion: nil)
//        case KAAsset.video.fileType:
//            let videoPreviewViewController = KAVideoPreviewViewController(component: component, knowledgeId: knowledgeId!)
//            videoPreviewViewController.modalPresentationStyle = .fullScreen
//            viewController.present(videoPreviewViewController, animated: true, completion: nil)
//            break
//        case KAAsset.attachment.fileType:
//            let attachmentViewController = KAAttachmentViewController(component: component, knowledgeId: knowledgeId)
//            let navigationController = UINavigationController(rootViewController: attachmentViewController)
//            navigationController.modalPresentationStyle = .fullScreen
//            viewController.present(navigationController, animated: true, completion: nil)
//        default:
//            break
//        }
//    }
    
//    public func previewComponents(_ components: [Component], with knowledgeId: String, on viewController: UIViewController) {
//        let compoentsViewController = KAComponentsViewController(components: components, with: 0)
//        compoentsViewController.resourceId = knowledgeId
//        let navigationController = UINavigationController(rootViewController: compoentsViewController)
//        navigationController.modalPresentationStyle = .fullScreen
//        viewController.present(navigationController, animated: true, completion: nil)
//    }
    
//    // MARK: - download component
//    public func downloadComponent(_ component: Component, with knowledgeId: String, progress: ((_ progress: Double) -> Void)?, success: ((_ filePath: String?) -> Void)?, failure: ((_ error: Error?) -> Void)?) {
//        let downloadOperation: KAComponentDownloadOperation = KAComponentDownloadOperation(component: component, knowledgeId: knowledgeId)
//        downloadOperation.setCompletionBlock(progress: { (progress) in
//
//        }, success: { (filePath) in
//            if let block = success {
//                block(filePath)
//            }
//        }) { (error) in
//            if let block = failure {
//                block(error)
//            }
//        }
//        downloadOperationQueue.addOperation(downloadOperation)
//    }
//
//    public func downloadProfileImage(for userId: String, progress: ((_ progress: Double) -> Void)?, success: ((_ filePath: String?) -> Void)?, failure: ((_ error: Error?) -> Void)?) {
//        let downloadOperation = KAProfileImageDownloadOperation(userId: userId)
//        downloadOperation.setCompletionBlock(progress: { (progress) in
//
//        }, success: { (filePath) in
//            if let block = success {
//                block(filePath)
//            }
//        }) { (error) in
//            if let block = failure {
//                block(error)
//            }
//        }
//        downloadOperationQueue.addOperation(downloadOperation)
//    }

//    // MARK: - upload comment
//    public func uploadComment(_ comment: String?, knowledgeId: String?, block: ((_ success: Bool, _ followStatus: Bool?) -> Void)?) {
//        let commentOperation = KACommentUploadOperation(comment: comment, knowledgeId: knowledgeId)
//        commentOperation.setCompletionBlock(progress: { (progress) in
//
//        }, success: { [weak self] (responseObject, success) in
//            var followStatus: Bool?
//            if let myvoteAction: [String: Any] = responseObject?["myActions"] as? [String: Any], let follow: Bool = myvoteAction["follow"] as? Bool {
//                followStatus = follow
//            }
//
//            if let commentObejct = responseObject?["comment"] as? [String: Any] {
//                self?.persistentStoreManager.insertOrUpdateComments(with: [commentObejct], for: knowledgeId, completion: { (success) in
//                    block?(true, followStatus)
//                })
//            }
//        }) { (error) in
//            block?(false, nil)
//        }
//        uploadOperationQueue.addOperation(commentOperation)
//    }
    
    public func cancelDownload(for component: Component) {
        downloadOperationQueue.cancelAllOperations()
    }
    
    // MARK: - cancel all tasks
    func suspendAllTasks() {
        requestSessionManager.suspendAllTasks()
        sessionManager.suspendAllTasks()
    }
    
    func resumeAllTasks() {
        for dataTask in pendingTasks {
            dataTask.resume()
        }
        pendingTasks.removeAll()
    }
    
    func cancelAllTasks() {
        requestSessionManager.cancelAllTasks()
        sessionManager.cancelAllTasks()
    }
}

// MARK: - requests
extension KAAccount {
//    func prepareInAppStoreItems() {
//        guard let context = persistentStoreManager.mainContext else {
//            return
//        }
//
//        // init KARecentAnnouncements
//        if let recentAnnouncements = NSEntityDescription.insertNewObject(forEntityName: "KARecentAnnouncements", into: context) as? KARecentAnnouncements {
//            self.recentAnnouncements = recentAnnouncements
//        }
//
//        // init KARecentAnnouncements
//        if let recentKnowledgeItems = NSEntityDescription.insertNewObject(forEntityName: "KARecentKnowledgeItems", into: context) as? KARecentKnowledgeItems {
//            self.recentKnowledgeItems = recentKnowledgeItems
//        }
//
//        // init KARecentAnnouncements
//        if let recentSharedKnowledgeItems = NSEntityDescription.insertNewObject(forEntityName: "KARecentSharedKnowledgeItems", into: context) as? KARecentSharedKnowledgeItems {
//            self.recentSharedKnowledgeItems = recentSharedKnowledgeItems
//        }
//    }
//
//    // MARK: - get company contacts
//    func getCompanyContacts() {
//        let status = doGetCompanyContacts(with: 0) { (moreAvailable, success) in
//
//        }
//        if status == .noError {
//
//        }
//    }
//
//    private func getHashTags() {
//        getHashTags(success: { (tokens) in
//
//        }) { (error) in
//
//        }
//    }
//
//    // MARK: - insert or update notification
//    public func getNotifications() {
//        let _ = doGetNotifications(with: nil)
//    }
}

// MARK: - AsynchronousEventCoordinator
extension KAAccount {
//    public func tryOutKora() {
//        observeAsynchronousEvents()
//        NotificationCenter.default.post(name: NSNotification.Name(rawValue: KoraNotification.Event.tryout.description), object: nil)
//    }
//
//    public func observeAsynchronousEvents() {
//        botClient?.observeAsynchronousEvents()
//    }
//
//    public func handleNotification(_ dictionary: [String: Any]) {
//        guard let type = dictionary["t"] as? String else {
//            return
//        }
//
//        switch type {
//        case "kmr":
//            observeAsynchronousEvents()
//            let event = KoraNotification.Event.respondToMeeting.description
//            NotificationCenter.default.post(name: Notification.Name(rawValue: event), object: dictionary)
//        case "kmo":
//            observeAsynchronousEvents()
//            let event = KoraNotification.Event.followUpMeeting.description
//            NotificationCenter.default.post(name: Notification.Name(rawValue: event), object: dictionary)
//        case "kme":
//            observeAsynchronousEvents()
//            let event = KoraNotification.Event.scheduleMeeting.description
//            NotificationCenter.default.post(name: Notification.Name(rawValue: event), object: dictionary)
//        case "kse":
//            observeAsynchronousEvents()
//            let event = KoraNotification.Event.systemAlert.description
//            NotificationCenter.default.post(name: Notification.Name(rawValue: event), object: dictionary)
//        default:
//            break
//        }
//    }
//
//    public func sendFeedback(_ dictionary: [String: Any]) {
//        observeAsynchronousEvents()
//        let event = KoraNotification.Event.feedback.description
//        NotificationCenter.default.post(name: Notification.Name(rawValue: event), object: dictionary)
//    }
}

