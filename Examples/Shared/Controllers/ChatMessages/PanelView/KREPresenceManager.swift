//
//  KREPresenceManager.swift
//  KoreApp
//
//  Created by Srinivas Vasadi on 21/08/18.
//  Copyright © 2018 Srinivas Vasadi. All rights reserved.
//

import Foundation
//import Kora
//import SocketIO

public class KREPersistentConnection: NSObject {
    // MARK: - properties
    private var presenceQueue = DispatchQueue(label: "kora-presenceQueue")
    private var retryCount: Int = 0
    private weak var account: KAAccount?
    private var lastSubscribedResourceId: String?
    private var sAccessToken: String?
    
    var manager: SocketManager?
    var socket: SocketIOClient?

    // MARK: -
    public init(account: KAAccount?) {
        super.init()
                
        self.account = account
        initializeSocketManager()
        NotificationCenter.default.addObserver(self, selector: #selector(networkReachabilityChanged(_:)), name: NSNotification.Name.AFNetworkingReachabilityDidChange, object: nil)
    }
    
    // MARK: -
    func initializeSocketManager() {
        guard let url = URL(string: PRESENCE_SERVER) else {
            return
        }
    
        manager = SocketManager(socketURL: url, config: [.log(true), .compress, .secure(true), .forceWebsockets(true)])
        socket = manager?.defaultSocket
        
        addEventHandlers()
    }
    
    // MARK: - SocketIOClient implementations
    @objc func connect(_ connectionObj: [String: Any]?) {
        if let socket = socket, (socket.status == .connecting || socket.status == .connected) {
            return
        }
        
        retryCount = 0
        connectSocketIOClient()
    }
    
    @objc func sendStatus(_ status: String) {
        debugPrint("<\(#function) :: \(status)>")
        if let socket = socket {
            socket.emit("status", with: [status])
        }
    }
    
    @objc func subscribeTypingStatus(forResource resource: String?) {
        debugPrint("<\(#function) :: \(resource ?? "")>")
        if let socket = socket {
            let dictionary = ["resourceIds": [resource]]
            lastSubscribedResourceId = resource
            socket.emit("typingSubscribe", with: [dictionary])
        }
    }
    
    @objc func unsubscribeTypingStatus() {
        lastSubscribedResourceId = nil
    }
    
    @objc func publishTypingStatus(_ resource: String?) {
        if let socket = socket, let resourceId = resource {
            debugPrint("<%s :: %@>", #function, resourceId)
            let dictionary = ["resourceId": resourceId]
            socket.emit("typing", with: [dictionary])
        }
    }
    
    @objc func disconnect() {
        if let _ = socket {
            socket?.disconnect()
            socket = nil
        }
    }
    
    // MARK: - SocketIOClient connect
    @objc func connectSocketIOClient() {
        let minValue: Int = 1
        let maxValue: Int = 5
        
        guard let _ = account?.userInfo?.userId else {
            debugPrint("<\(#function) :: user Id is nil")
            return
        }
        
        presenceQueue.async(execute: {
            if self.socket == nil {
                self.connect()
                return
            }
            if self.retryCount < 10 {
                debugPrint("<%s :: retry count : %ld>", #function, Int(self.retryCount))
                let delay = self.retryCount * (minValue + (Int(arc4random()) % (maxValue - minValue)))
                debugPrint("<%s :: incremental delay value : %ld>", #function, delay)
                
                Thread.sleep(forTimeInterval: TimeInterval((delay / 10)))
                if let socket = self.socket, (socket.status == .connecting || socket.status == .connected) {
                    return
                } else {
                    self.socket = nil
                }
            } else {
                self.retryCount = 0
            }
            self.retryCount += 1
            self.connect()
        })
    }
    
    @objc func tryConnect() {
        if let socket = socket, socket.status == .connected, let userId = self.account?.userInfo?.userId {
            DispatchQueue.main.async(execute: {
                NotificationCenter.default.post(name: Notification.Name(rawValue: KoraNotification.PersistentConnectionStatusDidChange), object: userId)
            })
            return
        }
        presenceQueue.async(execute: {
            self.retryCount = 0
            self.connect()
        })
    }
    
    @objc func reconnect() {
        presenceQueue.async(execute: {
            self.retryCount = 0
            if let socket = self.socket, (socket.status == .connecting || socket.status == .connected) {
                self.disconnect()
            }
            self.connect()
        })
    }
    
    @objc func connect() {
        guard let userId = self.account?.userInfo?.userId else {
            return
        }
        
        if let socket = socket, (socket.status == .connecting || socket.status == .connected) {
            return
        }
        
        DispatchQueue.main.async(execute: {
            NotificationCenter.default.post(name: Notification.Name(rawValue: KoraNotification.PersistentConnectionStatusDidChange), object: userId)
        })
        let status = self.account?.doGetShortLivedActionToken(with: { [weak self] (response) in
            if let responseObject = response as? [String: Any], let sToken = responseObject["sToken"] as? String {
                self?.sAccessToken = sToken
                
                if let userId = self?.account?.userInfo?.userId, let accessToken = self?.sAccessToken {
                    let range = NSMakeRange(0, accessToken.count)
                    var token = accessToken.replacingOccurrences(of: "bearer", with: "", options: String.CompareOptions.caseInsensitive, range: Range(range, in: accessToken))
                    token = token.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    
                    let dictionary = ["userid": userId, "sToken" : token, "channels": NUMBER_OF_SOCKETIO_CHANNELS]
                    let config: SocketIOClientConfiguration = [.log(true), .compress, .secure(true), .connectParams(dictionary), .forceWebsockets(true)]
                    self?.manager?.config = config
                    
                    let socket = self?.manager?.defaultSocket
                    socket?.connect()
                }
            } else {
                debugPrint("<%s :: access token is nil", #function)
            }
        })
        
        if status != .noError {
            
        }
    }
    
    // MARK: - roster design sending presence
    @objc func sendEvent(_ eventName: String, with data: [Any]) {
        if let socket = socket {
            socket.emit(eventName, with: data)
        }
    }
    
    // MARK: - socket delegate methods
    @objc func socketIODidConnect(_ socket: SocketIOClient?) {
        if let userId = self.account?.userInfo?.userId {
            DispatchQueue.main.async(execute: {
                NotificationCenter.default.post(name: Notification.Name(rawValue: KoraNotification.PersistentConnectionStatusDidChange), object: userId)
            })
        }

        presenceQueue.async(execute: {
            self.retryCount = 0
            if let socket = socket, socket.status == .connected {
                debugPrint("<%s :: socket is connected>", #function)
                NotificationCenter.default.post(name: Notification.Name(rawValue: KoraNotification.PersistentConnectionConnected), object: nil)
            } else {
                debugPrint("<%s :: socket is disconnected>", #function)
            }
        })
    }
    
    func addEventHandlers() {
        socket?.on("notification", callback: { (data, ack) in
            guard let dictionary = data.first as? [String: Any],
                let customData = dictionary["customdata"] as? [String: Any] else {
                return
            }
            
            if let nStats = customData["nStats"] as? [String: Any] {
                self.account?.updateUserStats(nStats)
                self.account?.notificationCountHandler?()
            }
            self.account?.getNotifications()
            self.handleNotification(customData)
        })
        
        socket?.on("live", callback: { (data, ack) in
            guard let dictionary = data.first as? [String: Any] else {
                    return
            }
//                self.account?.getNotifications()
            self.handleLiveEvent(dictionary)
        })
        
        socket?.on("online", callback: { (data, ack) in
            guard let _ = data[0] as? [String] else {
                return
            }
        })
        
        socket?.on("status", callback: { (data, ack) in
            guard let _ = data[0] as? [String] else {
                return
            }
        })
        
        
        socket?.on("error", callback: { [weak self] (data, ack) in
            if let userId = self?.account?.userInfo?.userId {
                DispatchQueue.main.async(execute: {
                    NotificationCenter.default.post(name: Notification.Name(rawValue: KoraNotification.PersistentConnectionStatusDidChange), object: userId)
                })
            }
            self?.presenceQueue.async(execute: {
                if let _ = self?.socket, let _ = self?.account?.userInfo?.userId {
                    self?.retryCount += 1
                    self?.connectSocketIOClient()
                }
            })
        })
        
        socket?.onAny {
            debugPrint("<\(#function) :: on event: \($0.event)>")
            if let items = $0.items {
                debugPrint("<\(#function) :: items: \(items)>")
            }
        }
    }
    
    // MARK: - reachability changed
    @objc func networkReachabilityChanged(_ notification: Notification?) {
        let value = notification?.userInfo?[AFNetworkingReachabilityNotificationStatusItem]
        guard let status = value as? Int else {
            return
        }
        
        switch status {
        case AFNetworkReachabilityStatus.notReachable.rawValue:
            break
        case AFNetworkReachabilityStatus.reachableViaWiFi.rawValue, AFNetworkReachabilityStatus.reachableViaWWAN.rawValue:
            tryConnect()
        default:
            break
        }
    }
    
    func handleLiveEvent(_ dictionary:[String: Any]){
        guard let type = dictionary["entity"] as? String, let action = dictionary["action"] as? String else {
            return
        }
        switch type {
        case "profile":
            if action == "update" {
                _ = account?.doGetUserProfile(with: { (success) in
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "Profile_Live_Update"), object: nil)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ChangeBellIcon"), object: nil)
                })
            }
        case "panels":
            if action == "update" {
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: KoraNotification.Panel.event.notification, object: dictionary)
                }
            }
        default:
            break
        }
    }
    
    // MARK: -
    func handleNotification(_ dictionary: [String: Any]) {
        guard let type = dictionary["t"] as? String, let userId = dictionary["uid"] as? String else {
            return
        }
        
        guard let account = KoraApplication.sharedInstance.account,
            let currentUserId = account.userInfo?.userId, currentUserId == userId else {
                return
        }
        
        switch type {
        case "kaa":
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: KoraNotification.Widget.update.notification, object: dictionary)
            }
        case "kfl":
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: KoraNotification.EnforcementNotification), object: ["type": KoraNotification.EnforcementType.accountPermissionsChanged])
            }
        default:
            break
        }
    }
    
    // MARK: - deinit
    deinit {
        NotificationCenter.default.removeObserver(self)
        socket = nil
    }
}

class KREPresenceManager: NSObject {
    private var connections: [String: Any] = [:]
    private var subscribedUsers: Set<AnyHashable> = []
    private weak var account: KAAccount?
    @objc static var shared: KREPresenceManager = KREPresenceManager()
    
    // MARK: - init
    override init() {
        super.init()
        
        connections = [String: Any]()
        subscribedUsers = Set<AnyHashable>()
        
        NotificationCenter.default.addObserver(self, selector: #selector(KREPresenceManager.persistentConnectionConnected), name: Notification.Name(rawValue: KoraNotification.PersistentConnectionConnected), object: nil)
    }
    
    class func highestPriorityPresenceState(forPresence presence1: KREPresenceState, presence presence2: KREPresenceState) -> KREPresenceState {
        let priority = [KREPresenceState.online, KREPresenceState.busy, KREPresenceState.away, KREPresenceState.stealth, KREPresenceState.offline, KREPresenceState.none]
        
        for p in priority {
            if Int(p.rawValue) == Int(presence1.rawValue) {
                return presence1
            }
            
            if Int(p.rawValue) == Int(presence2.rawValue) {
                return presence2
            }
        }
        
        // default (this should never happen)
        return presence1
    }
    
    class func presenceState(forPresence presence: String?, statusMessage: String?, activationStatus: NSNumber?) -> KREPresenceState {
        if (presence?.lowercased() == "online") || (presence?.lowercased() == "available") {
            if (statusMessage?.lowercased() == "away") {
                return KREPresenceState.away
            }
            
            if (statusMessage?.lowercased() == "busy") {
                return KREPresenceState.busy
            }
            
            if (statusMessage?.lowercased() == "stealth") {
                return KREPresenceState.stealth
            }
            
            return KREPresenceState.online
        } else {
            if (activationStatus != 0) {
                return KREPresenceState.offline
            }
            
            return KREPresenceState.none
        }
    }

    // MARK: - persistent connection implementations
    @objc func connectPersistentConnection(for account: KAAccount?) {
        let lockQueue = DispatchQueue(label: "connections")
        lockQueue.sync {
            let account = KoraApplication.sharedInstance.account
            if let userId = account?.userInfo?.userId {
                if connections[userId] == nil, let _ = account?.authInfo?.accessToken {
                    disconnectAllAccounts()
                    let connection = KREPersistentConnection(account: account)
                    connections[userId] = connection
                    connection.tryConnect()
                } else {
                    let connection = connections[userId] as? KREPersistentConnection
                    connection?.tryConnect()
                }
            }
        }
    }
    
    @objc func disConnectPersistentConnection(for account: KAAccount?) {
        let lockQueue = DispatchQueue(label: "connections")
        lockQueue.sync {
            if let userId = account?.userInfo?.userId {
                if let connection = connections[userId] as? KREPersistentConnection {
                    connection.disconnect()
                    connections.removeValue(forKey: userId)
                }
            }
        }
    }

    @objc func sendStatus(_ status: String, in account: KAAccount?) {
        let lockQueue = DispatchQueue(label: "connections")
        lockQueue.sync {
            if let anId = account?.userInfo?.userId {
                if connections[anId] != nil {
                    let connection = connections[anId] as? KREPersistentConnection
                    connection?.sendStatus(status)
                }
            }
        }
    }
    
    @objc func subscribeTypingStatus(forResource resource: String?, in account: KAAccount?) {
        
    }
    
    @objc func unsubscribeTypingStatus(in account: KAAccount?) {
        
    }
    
    @objc func publishTypingStatus(forResource resource: String?, in account: KAAccount?) {
        
    }
    
    // MARK: - subscribe/unsubscribe roster design
    @objc func subscribeForSpaceListAndBuddyList(for account: KAAccount?) {
        
    }

    @objc func sendSocketEvent(with data: [Any], with name: String, for account: KAAccount?) {
        let lockQueue = DispatchQueue(label: "connections")
        lockQueue.sync {
            if let userId = account?.userInfo?.userId {
                if let connection = connections[userId] as? KREPersistentConnection, let socket = connection.socket {
                    if socket.status == .connected {
                        connection.sendEvent(name, with: data)
                    }
                }
            }
        }
    }
    
    @objc func subscribe(forNewSpace spaceList: Any?, for account: KAAccount?) {
        
    }
    
    @objc func subscribe(forBuddies buddyList: Any?, for account: KAAccount?) {
        
    }
    
    @objc func getCompanyContactsPresenceStatus() {
        
    }
    
    // MARK: - connect/disconnect all accounts
    @objc func connectAllAccounts() {
        
    }
    
    @objc func disconnectAllAccounts() {
        
    }
    
    // MARK: - socket connection established
    @objc func persistentConnectionConnected() {
        subscribedUsers.removeAll()
        let account: KAAccount? = KoraApplication.sharedInstance.account
        subscribeForSpaceListAndBuddyList(for: account)
    }
    
    // MARK: - dealloc
    deinit {
        connections.removeAll()
    }
}
