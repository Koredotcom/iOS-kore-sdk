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

public protocol KABotClientDelegate: class {
    func botConnection(with connectionState: BotClientConnectionState)
    func showTypingStatusForBot()
    func hideTypingStatusForBot()
}

open class KABotClient: NSObject {
    // MARK:- shared instance
    fileprivate var isConnected: Bool = false {
        didSet {
            if isConnected {
                //whenever is connected is true it fetches the history if any
                //getRecentHistory()
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
    var componentOperationQueue: OperationQueue = OperationQueue()
    static let shared: KABotClient = {
        if (instance == nil) {
            instance = KABotClient()
        }
        return instance
    }()
    
    var thread: KREThread?
    let defaultTimeDifference = 15

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
    func fetchMessages(completion block: ((Bool) -> Void)? = nil) {
        let dataStoreManager = DataStoreManager.sharedManager
        dataStoreManager.getMessagesCount(completion: { [weak self] (count) in
            guard count == 0 else {
                self?.reconnectStatus(completion: block)
                return
            }
            
            self?.getMessages(offset: 0, completion:{ (success) in
                if success {
                    self?.reconnectStatus(completion: block)
                } else {
                    block?(false)
                }
            })
        })
    }
    
    func reconnectStatus(completion block: ((Bool) -> Void)?) {
        let dataStoreManager = DataStoreManager.sharedManager
        dataStoreManager.getLastMessage(completion: { [weak self] (message) in
            var status = false
            guard let weakSelf = self else {
                block?(status)
                return
            }
            
            status = weakSelf.canReconnect(using: message)
            block?(status)
        })
    }
    
    func canReconnect(using message: KREMessage?) -> Bool {
        var status = false
        guard let sentOn = message?.sentOn as Date? else {
            return status
        }
        
        let date = Date()
        let distanceBetweenDates = date.timeIntervalSince(sentOn)
        let secondsInMinute: Double = 60
        let minutesBetweenDates = Int((distanceBetweenDates / secondsInMinute))
        
        if minutesBetweenDates < defaultTimeDifference {
            status = true
        }
        
        return status
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
            if !SDKConfiguration.botConfig.isWebhookEnabled{
                self?.sendMessage("Welpro", options: nil)
                NotificationCenter.default.post(name: Notification.Name("StartTyping"), object: nil)
            }
            
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
            NotificationCenter.default.post(name: Notification.Name("StopTyping"), object: nil)
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
            NotificationCenter.default.post(name: Notification.Name("StopTyping"), object: nil)
        }
        
        botClient.onMessage = { [weak self] (object) in
            let message = self?.onReceiveMessage(object: object)
            self?.addMessages(message?.0, message?.1)
        }
        
        botClient.onMessageAck = { (ack) in
            
        }
    }
    func addMessages(_ message: Message?, _ ttsBody: String?) {
       // NotificationCenter.default.post(name: Notification.Name("StartTyping"), object: nil) //showTypingStatusForBot()
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
        else if (templateType == "listView") {
            return .newList
        }
        else if (templateType == "tableList") {
            return .tableList
        }
        else if (templateType == "daterange" || templateType == "dateTemplate") {
            return .calendarView
        }
        else if (templateType == "quick_replies_welcome"){
            return .quick_replies_welcome
        }
        else if (templateType == "Notification") {
            return .notification
        }
        else if (templateType == "multi_select") {
            return .multiSelect
        }
        else if (templateType == "listWidget") {
            return .list_widget
        }
        else if (templateType == "feedbackTemplate") {
            return .feedbackTemplate
        }
        else if (templateType == "form_template") {
            return .inlineForm
        }
        else if (templateType == "dropdown_template") {
            return .dropdown_template
        }else if (templateType == "custom_table")
        {
            return .custom_table
        }else if (templateType == "advancedListTemplate"){
            return .advancedListTemplate
        }else if (templateType == "cardTemplate"){
            return .cardTemplate
        }
        return .text
    }
    
    func onReceiveMessage(object: BotMessageModel?) -> (Message?, String?) {
        NotificationCenter.default.post(name: Notification.Name("StopTyping"), object: nil) //hideTypingStatusForBot()
        var ttsBody: String?
        var textMessage: Message! = nil
        let message: Message = Message()
        message.messageType = .reply
        if let type = object?.type, type == "incoming" {
            message.messageType = .default
        }
        if object?.createdOn != nil{
            message.sentDate = object?.createdOn
        }else{
            let timestamp = NSDate().timeIntervalSince1970
            let myTimeInterval = TimeInterval(timestamp)
            let time = NSDate(timeIntervalSince1970: TimeInterval(myTimeInterval))
            message.sentDate = time as Date
        }
       
        message.messageId = object?.messageId
        
        if let iconUrl = object?.iconUrl {
            message.iconUrl = iconUrl
        }else{
            message.iconUrl = botHistoryIcon
        }
        
        guard let messages = object?.messages, messages.count > 0 else {
            return (nil, ttsBody)
        }
        
        let messageObject = messages.first
        if (messageObject?.component == nil) {
            
        } else if let componentModel = messageObject?.component, let componentType = componentModel.type {
            switch componentType {
            case "text":
                if let payload = componentModel.payload as? [String: Any],
                    let text = payload["text"] as? String {
                    let textComponent = Component()
                    textComponent.payload = text
                    ttsBody = text
                    
                    if text.contains("use a web form")  {

                    }
                    message.addComponent(textComponent)
                    return (message, ttsBody)
                }
            case "template":
                if let payload = componentModel.payload as? [String: Any] {
                    let type = payload["type"] as? String ?? ""
                    let text = payload["text"] as? String
                    ttsBody = payload["speech_hint"] as? String
                    
                    switch type {
                    case "template":
                        if let dictionary = payload["payload"] as? [String: Any] {
                            let templateType = dictionary["template_type"] as? String ?? ""
                            var tabledesign = "responsive"
                            if let value = dictionary["table_design"] as? String {
                                tabledesign = value
                            }

                            let componentType = getComponentType(templateType, tabledesign)
                            if componentType != .quickReply {
                                
                            }
                            
                            ttsBody = dictionary["speech_hint"] != nil ? dictionary["speech_hint"] as? String : nil
                            if let tText = dictionary["text"] as? String, tText.count > 0 && (componentType == .carousel || componentType == .chart || componentType == .table || componentType == .minitable || componentType == .responsiveTable) {
                                textMessage = Message()
                                textMessage?.messageType = .reply
                                textMessage?.sentDate = message.sentDate
                                textMessage?.messageId = message.messageId
                                if let iconUrl = object?.iconUrl {
                                    textMessage?.iconUrl = iconUrl
                                }
                                let textComponent: Component = Component()
                                textComponent.payload = tText
                                textMessage?.addComponent(textComponent)
                            }
                            if templateType == "SYSTEM" || templateType == "live_agent"{
                               let textComponent = Component(.text)
                               let text = dictionary["text"] as? String ?? ""
                               textComponent.payload = text
                               ttsBody = text
                               message.addComponent(textComponent)
                           }else{
                            let optionsComponent: Component = Component(componentType)
                            optionsComponent.payload = Utilities.stringFromJSONObject(object: dictionary)
                            message.sentDate = object?.createdOn
                            message.addComponent(optionsComponent)
                           }
                        }
                    case "image":
                        if let dictionary = payload["payload"] as? [String: Any] {
                            let optionsComponent: Component = Component(.image)
                            optionsComponent.payload = Utilities.stringFromJSONObject(object: dictionary)
                            message.sentDate = object?.createdOn
                            message.addComponent(optionsComponent)
                        }
                    case "message":
                        if let dictionary = payload["payload"] as? [String: Any] {
                            let  componentType = dictionary["audioUrl"] != nil ? Component(.audio) : Component(.video)
                            let optionsComponent: Component = componentType
                            if let speechText = dictionary["text"] as? String{
                                ttsBody = speechText
                            }
                            optionsComponent.payload = Utilities.stringFromJSONObject(object: dictionary)
                            message.sentDate = object?.createdOn
                            message.addComponent(optionsComponent)
                        }
                    case "video":
                        if let _ = payload["payload"] as? [String: Any] {
                            let  componentType = Component(.video)
                            let optionsComponent: Component = componentType
                            optionsComponent.payload = Utilities.stringFromJSONObject(object: payload)
                            message.sentDate = object?.createdOn
                            message.addComponent(optionsComponent)
                        }
                    case "audio":
                        if let dictionary = payload["payload"] as? [String: Any] {
                            let  componentType = Component(.audio)
                            let optionsComponent: Component = componentType
                            optionsComponent.payload = Utilities.stringFromJSONObject(object: dictionary)
                            message.sentDate = object?.createdOn
                            message.addComponent(optionsComponent)
                        }
                    case "error":
                        if let dictionary = payload["payload"] as? [String: Any] {
                            let errorComponent: Component = Component(.error)
                            errorComponent.payload = Utilities.stringFromJSONObject(object: dictionary)
                            message.addComponent(errorComponent)
                            ttsBody = dictionary["speech_hint"] != nil ? dictionary["speech_hint"] as? String : nil
                        }
                    default:
                        if let text = text, text.count > 0 {
                            let textComponent: Component = Component()
                            textComponent.payload = text
                            message.addComponent(textComponent)
                        }
                    }
                }
                return (message, ttsBody)
            default:
                return (nil, ttsBody)
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
                
                dataStoreManager.insertOrUpdateThread(dictionary: resources, with: {( thread1) in
                    self?.thread = thread1
                    try? context.save()
                    dataStoreManager.coreDataManager.saveChanges()
                    
                    if SDKConfiguration.botConfig.isWebhookEnabled{
                        self?.fetachWebhookHistory()
                        block?(nil, self?.thread)
                        AcccesssTokenn = jwToken
                    }else{
                        self?.botClient.initialize(botInfoParameters: botInfo, customData: [:])
                        if (SDKConfiguration.serverConfig.BOT_SERVER.count > 0) {
                            self?.botClient.setKoreBotServerUrl(url: SDKConfiguration.serverConfig.BOT_SERVER)
                        }
                        self?.botClient.connectWithJwToken(jwToken, intermediary: { [weak self] (client) in
                            self?.fetchMessages(completion: { (reconnects) in
                                self?.botClient.connect(isReconnect: reconnects)
                                
                            })
                        }, success: { (client) in
                            self?.botClient = client!
                            AcccesssTokenn = client?.authInfoModel?.accessToken
                            block?(self?.botClient, self?.thread)
                        }, failure: { (error) in
                            failure?(error!)
                        })
                    }
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
        
        let parameters: NSDictionary = ["clientId": clientId as String,
                                        "clientSecret": clientSecret as String,
                                        "identity": identity as String,
                                        "aud": "https://idproxy.kore.com/authorize",
                                        "isAnonymous": isAnonymous as Bool]
        
        sessionManager?.responseSerializer = AFJSONResponseSerializer.init()
        sessionManager?.requestSerializer = requestSerializer
        sessionManager?.post(urlString, parameters: parameters, headers: nil, progress: nil, success: { (sessionDataTask, responseObject) in
            if let dictionary = responseObject as? [String: Any],
                let jwToken: String = dictionary["jwt"] as? String {
                jwtToken = jwToken
                success?(jwToken)
            } else {
                let error: NSError = NSError(domain: "bot", code: 100, userInfo: [:])
                failure?(error)
            }
        }) { (sessionDataTask, error) in
            failure?(error)
        }
        
    }
    
    func fetachWebhookHistory(){
        self.webhookHistoryApi(100, success: { [weak self] (responseObj) in
            if let responseObject = responseObj as? [String: Any], let messages = responseObject["messages"] as? Array<[String: Any]> {
                botHistoryIcon = responseObject["icon"] as? String
                self?.insertOrUpdateHistoryMessages(messages)
            }
            self?.historyRequestInProgress = false
        }, failure: { [weak self] (error) in
            self?.historyRequestInProgress = false
            print("Unable to webhook history fetch messges \(error.localizedDescription)")
        })
    }
    
    // MARK: -
    open func showTypingStatusForBot() {
        self.delegate?.showTypingStatusForBot()
    }
    
    open func hideTypingStatusForBot() {
        self.delegate?.hideTypingStatusForBot()
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
    public func getMessages(offset: Int, completion block:((Bool) -> Void)?) {
        guard historyRequestInProgress == false else {
            return
        }
        //getHistory - fetch all the history that the bot has previously
                botClient.getHistory(offset: offset, success: { [weak self] (responseObj) in
                    if let responseObject = responseObj as? [String: Any], let messages = responseObject["messages"] as? Array<[String: Any]> {
                        botHistoryIcon = responseObject["icon"] as? String
                        self?.insertOrUpdateHistoryMessages(messages)
                    }
                    self?.historyRequestInProgress = false
                    block?(true)
                    }, failure: { [weak self] (error) in
                        self?.historyRequestInProgress = false
                        print("Unable to fetch messges \(error?.localizedDescription ?? "")")
                        block?(false)
                })
    }
    
    //MARK: getRecentHistory - fetch all the history that the bot has previously based on last messageId
    public func getRecentHistory() {
        guard messagesRequestInProgress == false else {
            return
        }
        
        let dataStoreManager = DataStoreManager.sharedManager
        let context = dataStoreManager.coreDataManager.workerContext
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
            
            self?.botClient.getMessages(after: messageId, direction: 1, success: { (responseObj) in
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
        guard let models = try? MTLJSONAdapter.models(of: BotMessages.self, fromJSONArray: messages) as? [BotMessages], let botMessages = models, botMessages.count > 0 else {
            return
        }
//        let models = try? MTLJSONAdapter.models(of: BotMessages.self, fromJSONArray: messages) as? [BotMessages]
//        guard  let botMessages = models, botMessages.count > 0 else{
//            return
//        }
        
        
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
                    payloadObj["payload"] = jsonObject["payload"] as? [String : Any]
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
    
    // MARK: - Webhook Send message
    func webhookSendMessage(_ text: String!, _ type: String!,_ attachmentDic: [String: Any]!, success:((_ dictionary: [String: Any]) -> Void)?, failure:((_ error: Error) -> Void)?) {
        
        // Session Configuration
        let configuration = URLSessionConfiguration.default
        
        //Manager
        sessionManager = AFHTTPSessionManager.init(baseURL: URL.init(string: SDKConfiguration.serverConfig.JWT_SERVER) as URL?, sessionConfiguration: configuration)
        
        let urlString: String = "\(SDKConfiguration.serverConfig.BOT_SERVER)/chatbot/v2/webhook/\(SDKConfiguration.botConfig.botId)"
        let requestSerializer = AFJSONRequestSerializer()
        requestSerializer.httpMethodsEncodingParametersInURI = Set.init(["GET"]) as Set<String>
        requestSerializer.setValue("Keep-Alive", forHTTPHeaderField:"Connection")
        
        let authorizationStr = "bearer \(jwtToken!)"
        requestSerializer.setValue(authorizationStr, forHTTPHeaderField:"Authorization")
        requestSerializer.setValue("application/json", forHTTPHeaderField:"Content-Type")
        
        let session = ["new":false]
        let message : [String: Any] = ["type": type!,"val": text!, "attachments": attachmentDic!]
        
        let userInfo : [String: Any] = ["firstName": "","lastName": "", "email": ""]
        let from : [String: Any] = ["id": SDKConfiguration.botConfig.identity, "userInfo": userInfo]
        
        let groupInfo : [String: Any] = ["id": "","name": ""]
        let to : [String: Any] = ["id": "Kore.ai", "groupInfo": groupInfo]

    
        var parameters: NSDictionary?
        parameters = ["session": session,
        "message": message,
        "from": from,
        "to": to,
        "token": "{}"]
        
       
        sessionManager?.responseSerializer = AFJSONResponseSerializer.init()
        sessionManager?.requestSerializer = requestSerializer
        sessionManager?.post(urlString, parameters: parameters, headers: nil, progress: nil, success: { (sessionDataTask, responseObject) in
            if let dictionary = responseObject as? [String: Any]{
                success?(dictionary)
            } else {
                let error: NSError = NSError(domain: "bot", code: 100, userInfo: [:])
                failure?(error)
                NotificationCenter.default.post(name: Notification.Name("StopTyping"), object: nil)
            }
        }) { (sessionDataTask, error) in
            failure?(error)
            NotificationCenter.default.post(name: Notification.Name("StopTyping"), object: nil)
        }
        
    }
    
    // MARK:
    func pollApi(_ pollID: String!, success:((_ dictionary: [String: Any]) -> Void)?, failure:((_ error: Error) -> Void)?) {
        
        // Session Configuration
        let configuration = URLSessionConfiguration.default
        
        //Manager
        sessionManager = AFHTTPSessionManager.init(baseURL: URL.init(string: SDKConfiguration.serverConfig.JWT_SERVER) as URL?, sessionConfiguration: configuration)
       
        let urlString: String = "\(SDKConfiguration.serverConfig.BOT_SERVER)/chatbot/v2/webhook/\(SDKConfiguration.botConfig.botId)/poll/\(pollID!)"
        let requestSerializer = AFJSONRequestSerializer()
        requestSerializer.httpMethodsEncodingParametersInURI = Set.init(["GET"]) as Set<String>
        requestSerializer.setValue("Keep-Alive", forHTTPHeaderField:"Connection")
        
        let authorizationStr = "bearer \(jwtToken!)"
        requestSerializer.setValue(authorizationStr, forHTTPHeaderField:"Authorization")
        requestSerializer.setValue("application/json", forHTTPHeaderField:"Content-Type")
        
        let parameters: NSDictionary = [:]
        
        sessionManager?.responseSerializer = AFJSONResponseSerializer.init()
        sessionManager?.requestSerializer = requestSerializer
        sessionManager?.get(urlString, parameters: parameters, headers: nil, progress: nil, success: { (sessionDataTask, responseObject) in
            if let dictionary = responseObject as? [String: Any]{
                success?(dictionary)
            } else {
                let error: NSError = NSError(domain: "bot", code: 100, userInfo: [:])
                failure?(error)
                NotificationCenter.default.post(name: Notification.Name("StopTyping"), object: nil)
            }
        }) { (sessionDataTask, error) in
            failure?(error)
        }
        
    }
    
    // MARK:
    func webhookHistoryApi(_ limit: Int!, success:((_ dictionary: [String: Any]) -> Void)?, failure:((_ error: Error) -> Void)?) {
        
        // Session Configuration
        let configuration = URLSessionConfiguration.default
        
        //Manager
        sessionManager = AFHTTPSessionManager.init(baseURL: URL.init(string: SDKConfiguration.serverConfig.JWT_SERVER) as URL?, sessionConfiguration: configuration)
        
        let urlString: String = "\(SDKConfiguration.serverConfig.BOT_SERVER)/api/chathistory/\(SDKConfiguration.botConfig.botId)/ivr?botId=\(SDKConfiguration.botConfig.botId)&limit=\(limit!)"
        let requestSerializer = AFJSONRequestSerializer()
        requestSerializer.httpMethodsEncodingParametersInURI = Set.init(["GET"]) as Set<String>
        requestSerializer.setValue("Keep-Alive", forHTTPHeaderField:"Connection")
        
        let authorizationStr = "bearer \(jwtToken!)"
        requestSerializer.setValue(authorizationStr, forHTTPHeaderField:"Authorization")
        requestSerializer.setValue("application/json", forHTTPHeaderField:"Content-Type")
        
        let parameters: NSDictionary = [:]
        sessionManager?.responseSerializer = AFJSONResponseSerializer.init()
        sessionManager?.requestSerializer = requestSerializer
        sessionManager?.get(urlString, parameters: parameters, headers: nil, progress: nil, success: { (sessionDataTask, responseObject) in
            if let dictionary = responseObject as? [String: Any]{
                success?(dictionary)
            } else {
                let error: NSError = NSError(domain: "bot", code: 100, userInfo: [:])
                failure?(error)
                NotificationCenter.default.post(name: Notification.Name("StopTyping"), object: nil)
            }
        }) { (sessionDataTask, error) in
            failure?(error)
        }
        
    }
    
    // MARK:
    func webhookBotMetaApi( success:((_ dictionary: [String: Any]) -> Void)?, failure:((_ error: Error) -> Void)?) {
        
        // Session Configuration
        let configuration = URLSessionConfiguration.default
        
        //Manager
        sessionManager = AFHTTPSessionManager.init(baseURL: URL.init(string: SDKConfiguration.serverConfig.JWT_SERVER) as URL?, sessionConfiguration: configuration)
        
        // NOTE: You must set your URL to generate JWT.
        let urlString: String = "\(SDKConfiguration.serverConfig.BOT_SERVER)/api/botmeta/\(SDKConfiguration.botConfig.botId)"
        let requestSerializer = AFJSONRequestSerializer()
        requestSerializer.httpMethodsEncodingParametersInURI = Set.init(["GET"]) as Set<String>
        requestSerializer.setValue("Keep-Alive", forHTTPHeaderField:"Connection")
        
        let authorizationStr = "bearer \(jwtToken!)"
        requestSerializer.setValue(authorizationStr, forHTTPHeaderField:"Authorization")
        requestSerializer.setValue("application/json", forHTTPHeaderField:"Content-Type")
        
        let parameters: NSDictionary = [:]
        sessionManager?.responseSerializer = AFJSONResponseSerializer.init()
        sessionManager?.requestSerializer = requestSerializer
        sessionManager?.get(urlString, parameters: parameters, headers: nil, progress: nil, success: { (sessionDataTask, responseObject) in
            if let dictionary = responseObject as? [String: Any]{
                success?(dictionary)
            } else {
                let error: NSError = NSError(domain: "bot", code: 100, userInfo: [:])
                failure?(error)
                NotificationCenter.default.post(name: Notification.Name("StopTyping"), object: nil)
            }
        }) { (sessionDataTask, error) in
            failure?(error)
        }
        
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
