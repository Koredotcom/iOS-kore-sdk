//
//  KABotClient.swift
//  KoraApp
//
//  Created by Srinivas Vasadi on 29/01/18.
//  Copyright © 2018 Srinivas Vasadi. All rights reserved.
//

import UIKit
import KoreBotSDK
import CoreData
import Mantle

public protocol KABotClientDelegate: NSObjectProtocol {
    func botConnection(with connectionState: BotClientConnectionState)
    func showTypingStatusForBot()
}

open class KABotClient: NSObject {
    // MARK:- shared instance
    fileprivate var isConnected: Bool = false {
        didSet {
            if isConnected {
                //whenever is connected is true it fetches the history if any
                getRecentHistory()
                fetchMessages()
            }
        }
    }
    fileprivate var isConnecting: Bool = false
    private static var client: KABotClient!
    fileprivate var retryCount = 0
    fileprivate(set) var maxRetryAttempts = 5
    fileprivate var botClientQueue = DispatchQueue(label: "com.kora.botclient")
    public var canSpeakUtterance: Bool = false
    open var onCarouselMsgReceived: (( _ knowledgeArr : Array<Any>) -> Void)!
    var messagesRequestInProgress: Bool = false
    var historyRequestInProgress: Bool = false
    private static var instance: KABotClient!
    static let shared: KABotClient = {
        if (instance == nil) {
            instance = KABotClient()
        }
        return instance
    }()
    
    var thread: KREThread?
    
    // properties
    public static var suggestions: NSMutableOrderedSet = NSMutableOrderedSet()
    private var botClient: BotClient = BotClient()
    
    public var identity: String!
    public var userId: String!
    public var streamId: String = ""
    var sessionManager: AFHTTPSessionManager?
    
    public var connectionState: BotClientConnectionState! {
        get {
            return botClient.connectionState
        }
    }
    open weak var delegate: KABotClientDelegate?
    
    // MARK: - init
    public override init() {
        super.init()
        configureBotClient()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - fetch messages
    func fetchMessages() {
        let dataStoreManager = DataStoreManager.sharedManager
        dataStoreManager.getMessagesCount(completion: { [weak self] (count) in
            if count == 0 {
                self?.getMessages(offset: 0)
            }
        })
    }
    
    // MARK: - connect/reconnect - tries to reconnect the bot when isConnected is false
    @objc func tryConnect() {
        let delayInMilliSeconds = 250
        botClientQueue.asyncAfter(deadline: .now() + .milliseconds(delayInMilliSeconds)) { [weak self] in
            if self?.isConnected == true {
                self?.retryCount = 0
            } else if let weakSelf = self {
                if weakSelf.isConnecting == false  {
                    weakSelf.isConnecting = true
                    weakSelf.isConnected = false
                    
                    if weakSelf.retryCount + 1 > weakSelf.maxRetryAttempts {
                        weakSelf.retryCount = 0
                    }
                    
                    weakSelf.retryCount += 1
                    weakSelf.connect(block: {(client, thread) in
                    }, failure:{(error) in
                        self?.isConnecting = false
                        self?.isConnected = false
                        
                        self?.tryConnect()
                    })
                }
            }
        }
    }
    
    
    // MARK: -
    public func sendMessage(_ message: String, options: [String: Any]?) {
        botClient.sendMessage(message, options: options)
    }
    
    // methods
    func configureBotClient() {
        // events
        botClient.connectionWillOpen =  { [weak self] () in
            if let weakSelf = self {
                DispatchQueue.main.async {
                    weakSelf.delegate?.botConnection(with: weakSelf.connectionState)
                }
            }
        }
        
        botClient.connectionDidOpen = { [weak self] () in
            self?.isConnected = true
            self?.isConnecting = false
            self?.sendMessage("Welpro", options: nil)
        }
        
        botClient.connectionReady = {
            
        }
        
        botClient.connectionDidClose = { [weak self] (code, reason) in
            self?.isConnected = false
            self?.isConnecting = false
            
            if let weakSelf = self {
                DispatchQueue.main.async {
                    weakSelf.delegate?.botConnection(with: weakSelf.connectionState)
                }
            }
            self?.tryConnect()
        }
        
        botClient.connectionDidFailWithError = { [weak self] (error) in
            self?.isConnected = false
            self?.isConnecting = false
            
            if let weakSelf = self {
                DispatchQueue.main.async {
                    weakSelf.delegate?.botConnection(with: weakSelf.connectionState)
                }
            }
            self?.tryConnect()
        }
        
        botClient.onMessage = { [weak self] (object) in
            let message = self?.onReceiveMessage(object: object)
            self?.addMessages(message?.0, message?.1)
        }
        
        botClient.onMessageAck = { (ack) in
            
        }
    }
    func addMessages(_ message: Message?, _ ttsBody: String?) {
        if let m = message, m.components.count > 0 {
            let delayInMilliSeconds = 500
            DispatchQueue.global().asyncAfter(deadline: .now() + .milliseconds(delayInMilliSeconds)) {
                let dataStoreManager = DataStoreManager.sharedManager
                dataStoreManager.createNewMessageIn(thread: self.thread, message: m, completion: { (success) in
                    
                })
                
                if let tts = ttsBody {
                    NotificationCenter.default.post(name: Notification.Name(startSpeakingNotification), object: tts)
                }
            }
        }
    }
    
    func deConfigureBotClient() {
        // events
        botClient.disconnect()
        botClient.connectionWillOpen = nil
        botClient.connectionDidOpen = nil
        botClient.connectionReady = nil
        botClient.connectionDidClose = nil
        botClient.connectionDidFailWithError = nil
        botClient.onMessage = nil
        botClient.onMessageAck = nil
    }
    
    // MARK: -
    func getTemplateType(_ templateType: String) -> ComponentType {
        switch templateType {
        case "quick_replies":
            return .quickReply
        case "button":
            return .options
        case "list":
            return .list
        case "carousel", "kora_welcome_carousel":
            return .carousel
        case "piechart", "linechart", "barchart":
            return .chart
        case "table":
            return .table
        default:
            return .text
        }
    }
    
    func getComponentType(_ templateType: String,_ tabledesign:String) -> ComponentType {
        if (templateType == "quick_replies") {
            return .quickReply
        } else if (templateType == "button") {
            return .options
        }else if (templateType == "list") {
            return .list
        }else if (templateType == "carousel") {
            return .carousel
        }else if (templateType == "piechart" || templateType == "linechart" || templateType == "barchart") {
            return .chart
        }else if (templateType == "table"  && tabledesign == "regular") {
            return .table
        }
        else if (templateType == "table"  && tabledesign == "responsive") {
            return .responsiveTable
        }
        else if (templateType == "mini_table") {
            return .minitable
        }
        else if (templateType == "menu") {
            return .menu
        }
        return .text
    }
    
    func onReceiveMessage(object: BotMessageModel?) -> (Message?, String?) {
        var ttsBody: String?
        var textMessage: Message! = nil
        let message: Message = Message()
        message.messageType = .reply
        if let type = object?.type, type == "incoming" {
            message.messageType = .default
        }
        message.sentDate = object?.createdOn
        message.messageId = object?.messageId
        
        if (object?.iconUrl != nil) {
            message.iconUrl = object?.iconUrl
        }
        
        //        if (webViewController != nil) {
        //            webViewController.dismiss(animated: true, completion: nil)
        //            webViewController = nil
        //        }
        //
        let messageObject = ((object?.messages.count)! > 0) ? (object?.messages[0]) : nil
        if (messageObject?.component == nil) {
            
        } else {
            let componentModel: ComponentModel = messageObject!.component!
            if (componentModel.type == "text") {
                let payload: NSDictionary = componentModel.payload! as! NSDictionary
                let text: NSString = payload["text"] as! NSString
                let textComponent: Component = Component()
                textComponent.payload = text as String
                ttsBody = text as String
                
                if(text.contains("use a web form")){
                    let range: NSRange = text.range(of: "use a web form - ")
                    let urlString: String? = text.substring(with: NSMakeRange(range.location+range.length, 44))
                    if (urlString != nil) {
                        let url: URL = URL(string: urlString!)!
                        //                        webViewController = SFSafariViewController(url: url)
                        //                        webViewController.modalPresentationStyle = .custom
                        //                        present(webViewController, animated: true, completion:nil)
                    }
                    ttsBody = "Ok, Please fill in the details and submit"
                }
                message.addComponent(textComponent)
                return (message, ttsBody)
            } else if (componentModel.type == "template") {
                let payload: NSDictionary = componentModel.payload! as! NSDictionary
                let text: String = payload["text"] != nil ? payload["text"] as! String : ""
                let type: String = payload["type"] != nil ? payload["type"] as! String : ""
                ttsBody = payload["speech_hint"] != nil ? payload["speech_hint"] as? String : nil
                
                if (type == "template") {
                    let dictionary: NSDictionary = payload["payload"] as! NSDictionary
                    let templateType: String = dictionary["template_type"] as! String
                    var tabledesign: String
                    
                    tabledesign  = (dictionary["table_design"] != nil ? dictionary["table_design"] as? String : "responsive")!
                    let componentType = self.getComponentType(templateType,tabledesign)
                    
                    if componentType != .quickReply {
                        
                    }
                    
                    let tText: String = dictionary["text"] != nil ? dictionary["text"] as! String : ""
                    ttsBody = dictionary["speech_hint"] != nil ? dictionary["speech_hint"] as? String : nil
                    
                    if tText.count > 0 && (componentType == .carousel || componentType == .chart || componentType == .table || componentType == .minitable || componentType == .responsiveTable) {
                        textMessage = Message()
                        textMessage?.messageType = .reply
                        textMessage?.sentDate = message.sentDate
                        textMessage?.messageId = message.messageId
                        if (object?.iconUrl != nil) {
                            textMessage?.iconUrl = object?.iconUrl
                        }
                        let textComponent: Component = Component()
                        textComponent.payload = tText
                        textMessage?.addComponent(textComponent)
                    }
                    
                    let optionsComponent: Component = Component(componentType)
                    optionsComponent.payload = Utilities.stringFromJSONObject(object: dictionary)
                    message.sentDate = object?.createdOn
                    message.addComponent(optionsComponent)
                } else if (type == "error") {
                    let dictionary: NSDictionary = payload["payload"] as! NSDictionary
                    let errorComponent: Component = Component(.error)
                    errorComponent.payload = Utilities.stringFromJSONObject(object: dictionary)
                    message.addComponent(errorComponent)
                } else if text.count > 0 {
                    let textComponent: Component = Component()
                    textComponent.payload = text
                    message.addComponent(textComponent)
                }
                return (message, ttsBody)
            }
        }
        return (nil, ttsBody)
    }
    
    // MARK: -
    func connect(block:((BotClient?, KREThread?) -> ())?, failure:((_ error: Error) -> Void)?) {
        let clientId: String = SDKConfiguration.botConfig.clientId
        let clientSecret: String = SDKConfiguration.botConfig.clientSecret
        let isAnonymous: Bool = SDKConfiguration.botConfig.isAnonymous
        let chatBotName: String = SDKConfiguration.botConfig.chatBotName
        let botId: String = SDKConfiguration.botConfig.botId
        
        var identity: String! = nil
        if (isAnonymous) {
            identity = self.getUUID()
        } else {
            identity = SDKConfiguration.botConfig.identity
        }
        
        let botInfo: [String: Any] = ["chatBot": chatBotName, "taskBotId": botId]
        
        self.getJwTokenWithClientId(clientId, clientSecret: clientSecret, identity: identity, isAnonymous: isAnonymous, success: { [weak self] (jwToken) in
            
            let dataStoreManager: DataStoreManager = DataStoreManager.sharedManager
            let context = dataStoreManager.coreDataManager.workerContext
            context.perform {
                let resources: Dictionary<String, AnyObject> = ["threadId": botId as AnyObject, "subject": chatBotName as AnyObject, "messages":[] as AnyObject]
                
                dataStoreManager.deleteThreadIfRequired(with: botId, completionBlock: { (success) in
                    dataStoreManager.insertOrUpdateThread(dictionary: resources, with: {(thread1) in
                        self?.thread = thread1
                        try? context.save()
                        dataStoreManager.coreDataManager.saveChanges()
                        
                        self?.botClient.initialize(botInfoParameters: botInfo)
                        if (SDKConfiguration.serverConfig.BOT_SERVER.count > 0) {
                            self?.botClient.setKoreBotServerUrl(url: SDKConfiguration.serverConfig.BOT_SERVER)
                        }
                        self?.botClient.connectWithJwToken(jwToken, success: { [weak self] (client) in
                            block?(client, self?.thread)
                            }, failure: { (error) in
                                failure?(error!)
                        })
                    })
                })
            }
            }, failure: { (error) in
                print(error)
                failure?(error)
        })
        
    }
    func getUUID() -> String {
        var id: String?
        let userDefaults = UserDefaults.standard
        if let UUID = userDefaults.string(forKey: "UUID") {
            id = UUID
        } else {
            let date: Date = Date()
            id = String(format: "email%ld%@", date.timeIntervalSince1970, "@domain.com")
            userDefaults.set(id, forKey: "UUID")
        }
        return id!
    }
    
    // MARK: get JWT token request
    func getJwTokenWithClientId(_ clientId: String!, clientSecret: String!, identity: String!, isAnonymous: Bool!, success:((_ jwToken: String?) -> Void)?, failure:((_ error: Error) -> Void)?) {
        
        // Session Configuration
        let configuration = URLSessionConfiguration.default
        
        //Manager
        sessionManager = AFHTTPSessionManager.init(baseURL: URL.init(string: SDKConfiguration.serverConfig.JWT_SERVER) as URL?, sessionConfiguration: configuration)
        
        // NOTE: You must set your URL to generate JWT.
        let urlString: String = SDKConfiguration.serverConfig.koreJwtUrl()
        let requestSerializer = AFJSONRequestSerializer()
        requestSerializer.httpMethodsEncodingParametersInURI = Set.init(["GET"]) as Set<String>
        requestSerializer.setValue("Keep-Alive", forHTTPHeaderField:"Connection")
        
        // Headers: {"alg": "RS256","typ": "JWT"}
        requestSerializer.setValue("RS256", forHTTPHeaderField:"alg")
        requestSerializer.setValue("JWT", forHTTPHeaderField:"typ")
        
        let parameters: NSDictionary = ["clientId": clientId,
                                        "clientSecret": clientSecret,
                                        "identity": identity,
                                        "aud": "https://idproxy.kore.com/authorize",
                                        "isAnonymous": isAnonymous]
        
        sessionManager?.responseSerializer = AFJSONResponseSerializer.init()
        sessionManager?.requestSerializer = requestSerializer
        sessionManager?.post(urlString, parameters: parameters, progress: nil, success: { (sessionDataTask, responseObject) in
            if (responseObject is NSDictionary) {
                let dictionary: NSDictionary = responseObject as! NSDictionary
                let jwToken: String = dictionary["jwt"] as! String
                success?(jwToken)
            } else {
                let error: NSError = NSError(domain: "bot", code: 100, userInfo: [:])
                failure?(error)
            }
        }) { (sessionDataTask, error) in
            failure?(error)
        }
        
    }
    
    
    // MARK: -
    open func showTypingStatusForBot() {
        delegate?.showTypingStatusForBot()
    }
    
    
    // MARK: -
    open func datastorePath() -> URL {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let url = urls[urls.count-1] as NSURL
        return url.appendingPathComponent("Bots.sqlite")!
    }
    
    // MARK: - set hash tags
    open func setHashTags(with array: [String]?) {
        if let values = array {
            KABotClient.suggestions.addObjects(from: values)
        }
    }
    
    // MARK: - get history
    public func getMessages(offset: Int) {
        guard historyRequestInProgress == false else {
            return
        }
        //getHistory - fetch all the history that the bot has previously
        botClient.getHistory(offset: offset, success: { [weak self] (responseObj) in
            if let responseObject = responseObj as? [String: Any], let messages = responseObject["messages"] as? Array<[String: Any]> {
                self?.insertOrUpdateHistoryMessages(messages)
            }
            self?.historyRequestInProgress = false
            }, failure: { [weak self] (error) in
                self?.historyRequestInProgress = false
                print("Unable to fetch messges \(error?.localizedDescription ?? "")")
        })
    }
    
    //MARK: getRecentHistory - fetch all the history that the bot has previously based on last messageId
    public func getRecentHistory() {
        
        guard messagesRequestInProgress == false,  let dataStoreManager = DataStoreManager.sharedManager as? DataStoreManager, let context = dataStoreManager.coreDataManager.workerContext as? NSManagedObjectContext else {
            return
        }
        
        messagesRequestInProgress = true
        let request: NSFetchRequest<KREMessage> = KREMessage.fetchRequest()
        let isSenderPredicate = NSPredicate(format: "isSender == \(false)")
        request.predicate = isSenderPredicate
        let sortDates = NSSortDescriptor(key: "sentOn", ascending: false)
        request.sortDescriptors = [sortDates]
        request.fetchLimit = 1
        
        context.perform { [weak self] in
            guard let array = try? context.fetch(request), array.count > 0, let messageId = array.first?.messageId else {
                self?.messagesRequestInProgress = false
                return
            }
            
            self?.botClient.getMessages(after: messageId, success: { (responseObj) in
                if let responseObject = responseObj as? [String: Any]{
                    if let messages = responseObject["messages"] as? Array<[String: Any]> {
                        self?.insertOrUpdateHistoryMessages(messages)
                    }
                }
                self?.messagesRequestInProgress = false
            }, failure: { (error) in
                self?.messagesRequestInProgress = false
                print("Unable to fetch history \(error?.localizedDescription ?? "")")
            })
        }
    }
    
    // MARK: - insert or update messages
    func insertOrUpdateHistoryMessages(_ messages: Array<[String: Any]>) {
        guard let botMessages = try? MTLJSONAdapter.models(of: BotMessages.self, fromJSONArray: messages) as? [BotMessages], botMessages.count > 0 else {
            return
        }
        
        var allMessages: [Message] = [Message]()
        for message in botMessages {
            if message.type == "outgoing" || message.type == "incoming" {
                guard let components = message.components, let data = components.first?.data else {
                    continue
                }
                
                guard let jsonString = data["text"] as? String else {
                    continue
                }
                
                let botMessage: BotMessageModel = BotMessageModel()
                botMessage.createdOn = message.createdOn
                botMessage.messageId = message.messageId
                botMessage.type = message.type
                
                let messageModel: MessageModel = MessageModel()
                let componentModel: ComponentModel = ComponentModel()
                if jsonString.contains("payload"), let jsonObject: [String: Any] = Utilities.jsonObjectFromString(jsonString: jsonString) as? [String : Any] {
                    componentModel.type = jsonObject["type"] as? String
                    
                    var payloadObj: [String: Any] = [String: Any]()
                    payloadObj["payload"] = jsonObject["payload"] as! [String : Any]
                    payloadObj["type"] = jsonObject["type"]
                    componentModel.payload = payloadObj
                } else {
                    var payloadObj: [String: Any] = [String: Any]()
                    payloadObj["text"] = jsonString
                    payloadObj["type"] = "text"
                    componentModel.type = "text"
                    componentModel.payload = payloadObj
                }
                
                messageModel.type = "text"
                messageModel.component = componentModel
                botMessage.messages = [messageModel]
                let messageTuple = onReceiveMessage(object: botMessage)
                if let object = messageTuple.0 {
                    allMessages.append(object)
                }
            }
        }
        
        // insert all messages
        if allMessages.count > 0 {
            let dataStoreManager = DataStoreManager.sharedManager
            dataStoreManager.insertMessages(allMessages, in:  thread, completion: nil)
            
        }
    }
    
    // MARK: -
    public func setReachabilityStatusChange(_ status: AFNetworkReachabilityStatus) {
        botClient.setReachabilityStatusChange(status)
    }
}

// MARK: - UserDefaults Sign-In status
extension UserDefaults {
    func setKoraStartEventStatus(_ status: Bool, for identity: String) {
        set(status, forKey: identity)
        synchronize()
    }
    
    func koraStartEventStatus(for identity: String) -> Bool {
        return bool(forKey: identity)
    }
}
