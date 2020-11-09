//
//  KAHTTPRequestManager.swift
//  KoraApp
//
//  Created by Srinivas Vasadi on 21/03/18.
//  Copyright © 2018 Srinivas Vasadi. All rights reserved.
//

import UIKit
import AFNetworking
import Mantle
import KoreBotSDK

open class KAHTTPRequestManager: NSObject {
    static var instance: KAHTTPRequestManager!
    
    // MARK: request manager shared instance
    public static let sharedManager : KAHTTPRequestManager = {
        if (instance == nil) {
            instance = KAHTTPRequestManager()
        }
        return instance
    }()
}

// MARK: - requests
extension KAAccount {
    // MARK: - check networkReachability
    public func networkReachability(shouldTriggerNotificaiton: Bool = true) -> Bool {
        return networkReachability(with: "", shouldTriggerNotificaiton: shouldTriggerNotificaiton)
    }
    
    func networkReachability(with message: String?, shouldTriggerNotificaiton: Bool) -> Bool {
        var isReachable = true
        let reachabilityStatus = AFNetworkReachabilityManager.shared().networkReachabilityStatus
        switch reachabilityStatus {
        case AFNetworkReachabilityStatus.notReachable:
            isReachable = false
        default:
            break
        }
        if isReachable == false && shouldTriggerNotificaiton {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Notification.Name("KANetworkNotReachableNotification"), object: nil, userInfo: ["message": message ?? ""])
            }
        }
        return isReachable
    }
/*
    // MARK: - hashtags
    func doGetHashtags(token: String?, success:((URLSessionDataTask?, Any?) -> Void)?, failure:((URLSessionDataTask?, Any?, Error?) -> Void)?) -> KAHTTPRequestStatus {
        let reachable = self.networkReachability()
        if !reachable {
            return .noNetwork
        }
        
        let urlString = SDKConfiguration.serverConfig.hashtagsUrl(userId: self.userId, token: token ?? "")
        if self.activeRequests[urlString] != nil {
            return .requestExists
        }
        
        let dataTask = self.GET(urlString: urlString, parameters: nil, success: { (dataTask, responseObject) in
            DispatchQueue.main.async {
                success?(dataTask, responseObject)
            }
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        }) { (dataTask, responseObject, error) in
            DispatchQueue.main.async {
                failure? (dataTask, responseObject, error)
            }
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        }
        dataTask?.taskDescription = urlString
        if let path = dataTask?.taskDescription {
            self.activeRequests[path] = dataTask
        }
        return .noError
    }
    
    func doGetHashtagsWithCount(token: String?, success:((URLSessionDataTask?, Any?) -> Void)?, failure:((URLSessionDataTask?, Any?, Error?) -> Void)?) -> KAHTTPRequestStatus {
        let reachable = self.networkReachability()
        if !reachable {
            return .noNetwork
        }
        
        let urlString = SDKConfiguration.serverConfig.hashtagsWithCountUrl(userId: self.userId, token: token ?? "")
        if self.activeRequests[urlString] != nil {
            return .requestExists
        }
        
        let dataTask = self.GET(urlString: urlString, parameters: nil, success: { (dataTask, responseObject) in
            DispatchQueue.main.async {
                success?(dataTask, responseObject)
            }
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        }) { (dataTask, responseObject, error) in
            DispatchQueue.main.async {
                failure? (dataTask, responseObject, error)
            }
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        }
        dataTask?.taskDescription = urlString
        if let path = dataTask?.taskDescription {
            self.activeRequests[path] = dataTask
        }
        return .noError
    }

    func doGetIncidents(for skillId: String, success:((URLSessionDataTask?, Any?) -> Void)?, failure:((URLSessionDataTask?, Any?, Error?) -> Void)?) -> KAHTTPRequestStatus {
        let reachable = self.networkReachability()
        if !reachable {
            return .noNetwork
        }
        
        let urlString = KARESTAPIManager.shared.skillWidgetUrl(userId: userId, skillId: skillId)
        if self.activeRequests[urlString] != nil {
            return .requestExists
        }
        
        let dataTask = self.GET(urlString: urlString, parameters: nil, success: { (dataTask, responseObject) in
            DispatchQueue.main.async {
                success?(dataTask, responseObject)
            }
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        }) { (dataTask, responseObject, error) in
            DispatchQueue.main.async {
                failure? (dataTask, responseObject, error)
            }
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        }
        dataTask?.taskDescription = urlString
        if let path = dataTask?.taskDescription {
            self.activeRequests[path] = dataTask
        }
        return .noError
    }

    
    func doUnfurl(with url: String, success:((URLSessionDataTask?, Any?) -> Void)?, failure:((URLSessionDataTask?, Any?, Error?) -> Void)?) -> KAHTTPRequestStatus {
        let reachable = self.networkReachability()
        if !reachable {
            return .noNetwork
        }
        
        let urlString = SDKConfiguration.serverConfig.unfurlUrl(userId: self.userId)
        if self.activeRequests[urlString] != nil {
            return .requestExists
        }
        let dataTask = self.POST(urlString: urlString, parameters: ["url": url], success: { (dataTask, responseObject) in
            DispatchQueue.main.async {
                success?(dataTask, responseObject)
            }
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        }) { (dataTask, responseObject, error) in
            DispatchQueue.main.async {
                failure? (dataTask, responseObject, error)
            }
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        }
        dataTask?.taskDescription = urlString
        if let path = dataTask?.taskDescription {
            self.activeRequests[path] = dataTask
        }
        return .noError
    }
    
    //MARK: Get Color codes
    func doGetColorsList(success:((URLSessionDataTask?, Any?) -> Void)?, failure:((URLSessionDataTask?, Any?, Error?) -> Void)?) -> KAHTTPRequestStatus {
        let reachable = self.networkReachability()
        if !reachable {
            return .noNetwork
        }
        
        let urlString = KARESTAPIManager.shared.getColorsUrl(userId: userId)
        if self.activeRequests[urlString] != nil {
            return .requestExists
        }
        let dataTask = self.GET(urlString: urlString, parameters: nil, success: { (dataTask, responseObject) in
            DispatchQueue.main.async {
                success?(dataTask, responseObject)
            }
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        }) { (dataTask, responseObject, error) in
            DispatchQueue.main.async {
                failure? (dataTask, responseObject, error)
            }
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        }
        dataTask?.taskDescription = urlString
        if let path = dataTask?.taskDescription {
            self.activeRequests[path] = dataTask
        }
        return .noError

    }
    //MARK: Check Team availability
    func dogetTeamsAvailability(with parameters: [String: Any], success:((URLSessionDataTask?, Any?) -> Void)?, failure:((URLSessionDataTask?, Any?, Error?) -> Void)?) -> KAHTTPRequestStatus {
        let reachable = self.networkReachability()
        if !reachable {
            return .noNetwork
        }
        
        var urlString = SDKConfiguration.serverConfig.getTeamsAvailability(userID: self.userId)
        urlString =  addQueryString(to: urlString, with: parameters)
        if self.activeRequests[urlString] != nil {
            return .requestExists
        }
        
        let dataTask = self.GET(urlString: urlString, parameters: nil, success: { (dataTask, responseObject) in
            DispatchQueue.main.async {
                success?(dataTask, responseObject)
            }
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        }, failure: { (dataTask, responseObject, error) in
            DispatchQueue.main.async {
                failure? (dataTask, responseObject, error)
            }
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        })
        dataTask?.taskDescription = urlString
        if let path = dataTask?.taskDescription {
            self.activeRequests[path] = dataTask
        }
        return .noError
    }
    
    // Profile change color
    public func doChangeProfileColor(with parameters: [String: Any], success:((URLSessionDataTask?, Any?) -> Void)?, failure:((URLSessionDataTask?, Any?, Error?) -> Void)?) -> KAHTTPRequestStatus {
        let reachable = self.networkReachability()
        if !reachable {
            return .noNetwork
        }

        let urlString = SDKConfiguration.serverConfig.createProfileColorUrl(userID: self.userId)
        if self.activeRequests[urlString] != nil {
            return .requestExists
        }
        
        let dataTask = self.PUT(urlString: urlString, parameters: parameters, success: { (dataTask, responseObject) in
            DispatchQueue.main.async {
                success?(dataTask, responseObject)
            }
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        }) { (dataTask, responseObject, error) in
            DispatchQueue.main.async {
                failure? (dataTask, responseObject, error)
            }
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        }
        dataTask?.taskDescription = urlString
        if let path = dataTask?.taskDescription {
            self.activeRequests[path] = dataTask
        }
        return .noError
    }
    
    
    // MARK: create team
    func doCreateTeam(with parameters: [String: Any], success:((URLSessionDataTask?, Any?) -> Void)?, failure:((URLSessionDataTask?, Any?, Error?) -> Void)?) -> KAHTTPRequestStatus {
        let reachable = self.networkReachability()
        if !reachable {
            return .noNetwork
        }
        
        let urlString = SDKConfiguration.serverConfig.createTeamUrl(userID: self.userId)
        if self.activeRequests[urlString] != nil {
            return .requestExists
        }
        
        let dataTask = self.POST(urlString: urlString, parameters: parameters, success: { (dataTask, responseObject) in
            DispatchQueue.main.async {
                success?(dataTask, responseObject)
            }
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        }) { (dataTask, responseObject, error) in
            DispatchQueue.main.async {
                failure? (dataTask, responseObject, error)
            }
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        }
        dataTask?.taskDescription = urlString
        if let path = dataTask?.taskDescription {
            self.activeRequests[path] = dataTask
        }
        return .noError
    }
    
    // MARK: edit team
    func doEditTeam(with teamId: String, params: [String: Any],success:((URLSessionDataTask?, Any?) -> Void)?, failure:((URLSessionDataTask?, Any?, Error?) -> Void)?) -> KAHTTPRequestStatus {
        let reachable = self.networkReachability()
        if !reachable {
            return .noNetwork
        }
        
        let urlString = SDKConfiguration.serverConfig.editTeamUrl(userID: self.userId, teamId)
        if self.activeRequests[urlString] != nil {
            return .requestExists
        }
        
        let dataTask = self.PUT(urlString: urlString, parameters: params, success: { (dataTask, responseObject) in
            DispatchQueue.main.async {
                success?(dataTask, responseObject)
            }
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        }) { (dataTask, responseObject, error) in
            DispatchQueue.main.async {
                failure? (dataTask, responseObject, error)
            }
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        }
        dataTask?.taskDescription = urlString
        if let path = dataTask?.taskDescription {
            self.activeRequests[path] = dataTask
        }
        return .noError
    }
    
    //MARK: GetContacts for Teams
    func doGetContactsForTeamCreation(with parameters: [String: Any],success:((URLSessionDataTask?, Any?) -> Void)?, failure:((URLSessionDataTask?, Any?, Error?) -> Void)?) -> KAHTTPRequestStatus {
        let reachable = self.networkReachability()
        if !reachable {
            return .noNetwork
        }
        
        var urlString = SDKConfiguration.serverConfig.getContactsForTeamCreationUrl(userID: self.userId)
        urlString = addQueryString(to: urlString, with: parameters)
        if self.activeRequests[urlString] != nil {
            return .requestExists
        }
        
        let dataTask = self.GET(urlString: urlString, parameters: nil, success: { (dataTask, responseObject) in
            DispatchQueue.main.async {
                success?(dataTask, responseObject)
            }
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        }) { (dataTask, responseObject, error) in
            DispatchQueue.main.async {
                failure? (dataTask, responseObject, error)
            }
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        }
        dataTask?.taskDescription = urlString
        if let path = dataTask?.taskDescription {
            self.activeRequests[path] = dataTask
        }
        return .noError
    }
    
    func doGetContacts(with parameters: [String: Any],success:((URLSessionDataTask?, Any?) -> Void)?, failure:((URLSessionDataTask?, Any?, Error?) -> Void)?) -> KAHTTPRequestStatus {
        let reachable = self.networkReachability()
        if !reachable {
            return .noNetwork
        }
        
        var urlString = SDKConfiguration.serverConfig.getContactsUrl(userID: self.userId)
        urlString = addQueryString(to: urlString, with: parameters)
        if self.activeRequests[urlString] != nil {
            return .requestExists
        }
        
        let dataTask = self.GET(urlString: urlString, parameters: nil, success: { (dataTask, responseObject) in
            DispatchQueue.main.async {
                success?(dataTask, responseObject)
            }
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        }) { (dataTask, responseObject, error) in
            DispatchQueue.main.async {
                failure? (dataTask, responseObject, error)
            }
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        }
        dataTask?.taskDescription = urlString
        if let path = dataTask?.taskDescription {
            self.activeRequests[path] = dataTask
        }
        return .noError
    }
    
    // MARK: - Resolve Contact - OLD API same as in Kore Messaging
    func doGetContacts(for contactIds: [String], success:((URLSessionDataTask?, Any?) -> Void)?, failure:((URLSessionDataTask?, Any?, Error?) -> Void)?) -> KAHTTPRequestStatus {
        let reachable = self.networkReachability()
        if !reachable {
            return .noNetwork
        }
        
        var urlString = SDKConfiguration.serverConfig.getResolvedContactUrl(userID: self.userId)
        urlString.append(contactIds.joined(separator: "&id="))
        if self.activeRequests[urlString] != nil {
            return .requestExists
        }
        
        let dataTask = self.GET(urlString: urlString, parameters: nil, success: { (dataTask, responseObject) in
            DispatchQueue.main.async {
                success?(dataTask, responseObject)
            }
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        }) { (dataTask, responseObject, error) in
            DispatchQueue.main.async {
                failure? (dataTask, responseObject, error)
            }
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        }
        dataTask?.taskDescription = urlString
        if let path = dataTask?.taskDescription {
            self.activeRequests[path] = dataTask
        }
        return .noError
    }
    
    // MARK: add contacts in team
    func doAddContacts(in teamId: String, parameters: [String: Array<[String: Any]>], success:((URLSessionDataTask?, Any?) -> Void)?, failure:((URLSessionDataTask?, Any?, Error?) -> Void)?) -> KAHTTPRequestStatus {
        let reachable = self.networkReachability()
        if !reachable {
            return .noNetwork
        }
        
        let urlString = SDKConfiguration.serverConfig.getTeamMembersUrl(userID: self.userId, teamId)
        if self.activeRequests[urlString] != nil {
            return .requestExists
        }
        
        let dataTask = self.POST(urlString: urlString, parameters: parameters, success: { (dataTask, responseObject) in
            DispatchQueue.main.async {
                success?(dataTask, responseObject)
            }
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        }) { (dataTask, responseObject, error) in
            DispatchQueue.main.async {
                failure? (dataTask, responseObject, error)
            }
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        }
        dataTask?.taskDescription = urlString
        if let path = dataTask?.taskDescription {
            self.activeRequests[path] = dataTask
        }
        return .noError
    }
    
    // MARK: get teams
    func doGetTeams(success:((Array<[String: Any]>?) -> Void)?, failure:((Error?) -> Void)?) -> KAHTTPRequestStatus {
        let reachable = self.networkReachability()
        if !reachable {
            return .noNetwork
        }
        
        let urlString = SDKConfiguration.serverConfig.getTeamsUrl(with: self.userId)
        if self.activeRequests[urlString] != nil {
            return .requestExists
        }
        
        let dataTask = self.GET(urlString: urlString, parameters: nil, success:{ (dataTask, responseObject) in
            if let responseObject = responseObject as? Array<[String: Any]> {
                DispatchQueue.main.async {
                    success?(responseObject)
                }
            }
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        }, failure:{ (dataTask, responseObject, error) in
            DispatchQueue.main.async {
                failure?(error)
            }
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        })
        dataTask?.taskDescription = urlString
        if let path = dataTask?.taskDescription {
            self.activeRequests[path] = dataTask
        }
        return .noError
    }
    
    //MARK: get team by team Id
    func doGetTeam(with teamId: String, success:((URLSessionDataTask?, Any?) -> Void)?, failure:((URLSessionDataTask?, Any?, Error?) -> Void)?) -> KAHTTPRequestStatus {
        let reachable = self.networkReachability()
        if !reachable {
            return .noNetwork
        }
        
        let urlString = SDKConfiguration.serverConfig.getTeamByTeamID(with: self.userId,teamId: teamId)
        if self.activeRequests[urlString] != nil {
            return .requestExists
        }
        
        let dataTask = self.GET(urlString: urlString, parameters: nil, success: { (dataTask, responseObject) in
            DispatchQueue.main.async {
                success?(dataTask, responseObject)
            }
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        }) { (dataTask, responseObject, error) in
            DispatchQueue.main.async {
                failure? (dataTask, responseObject, error)
            }
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        }
        dataTask?.taskDescription = urlString
        if let path = dataTask?.taskDescription {
            self.activeRequests[path] = dataTask
        }
        return .noError
    }
    
    // MARK: delete team
    func doDeleteTeam(with teamId: String, success:((URLSessionDataTask?, Any?) -> Void)?, failure:((URLSessionDataTask?, Any?, Error?) -> Void)?) -> KAHTTPRequestStatus {
        let reachable = self.networkReachability()
        if !reachable {
            return .noNetwork
        }
        
        let urlString = SDKConfiguration.serverConfig.getTeamByTeamID(with: self.userId,teamId: teamId)
        if self.activeRequests[urlString] != nil {
            return .requestExists
        }
        
        let dataTask = self.DELETE(urlString: urlString, parameters: nil, success: { (dataTask, responseObject) in
            DispatchQueue.main.async {
                success?(dataTask, responseObject)
            }
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        }) { (dataTask, responseObject, error) in
            DispatchQueue.main.async {
                failure? (dataTask, responseObject, error)
            }
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        }
        dataTask?.taskDescription = urlString
        if let path = dataTask?.taskDescription {
            self.activeRequests[path] = dataTask
        }
        return .noError
    }
    
    // MARK: leave team
    func doLeaveTeam(with teamId: String, qParams: [String: Any], success:((URLSessionDataTask?, Any?) -> Void)?, failure:((URLSessionDataTask?, Any?, Error?) -> Void)?) -> KAHTTPRequestStatus {
        let reachable = self.networkReachability()
        if !reachable {
            return .noNetwork
        }
        
        var urlString = SDKConfiguration.serverConfig.getTeamByTeamID(with: self.userId,teamId: teamId)
        urlString =  addQueryString(to: urlString, with: qParams)
        if self.activeRequests[urlString] != nil {
            return .requestExists
        }
        
        let dataTask = self.DELETE(urlString: urlString, parameters: nil, success: { (dataTask, responseObject) in
            DispatchQueue.main.async {
                success?(dataTask, responseObject)
            }
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        }) { (dataTask, responseObject, error) in
            DispatchQueue.main.async {
                failure? (dataTask, responseObject, error)
            }
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        }
        dataTask?.taskDescription = urlString
        if let path = dataTask?.taskDescription {
            self.activeRequests[path] = dataTask
        }
        return .noError
    }
    
    // MARK: - get team members
    func doGetTeamMembers(in teamId: String, qParams: [String: Any], success:((URLSessionDataTask?, Any?) -> Void)?, failure:((URLSessionDataTask?, Any?, Error?) -> Void)?) -> KAHTTPRequestStatus {
        let reachable = self.networkReachability()
        if !reachable {
            return .noNetwork
        }
        
        var urlString = SDKConfiguration.serverConfig.getTeamMembersUrl(userID: self.userId,teamId)
        urlString =  addQueryString(to: urlString, with: qParams)
        if self.activeRequests[urlString] != nil {
            return .requestExists
        }
        
        let dataTask = self.GET(urlString: urlString, parameters: nil, success: { (dataTask, responseObject) in
            DispatchQueue.main.async {
                success?(dataTask, responseObject)
            }
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        }) { (dataTask, responseObject, error) in
            DispatchQueue.main.async {
                failure? (dataTask, responseObject, error)
            }
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        }
        dataTask?.taskDescription = urlString
        if let path = dataTask?.taskDescription {
            self.activeRequests[path] = dataTask
        }
        return .noError
    }
    
    // MARK: Edit TeamMembers
    func doEditTeamMembers(in teamId: String, params: [String: Any], success:((URLSessionDataTask?, Any?) -> Void)?, failure:((URLSessionDataTask?, Any?, Error?) -> Void)?) -> KAHTTPRequestStatus {
        let reachable = self.networkReachability()
        if !reachable {
            return .noNetwork
        }
        
        let urlString = SDKConfiguration.serverConfig.getTeamMembersUrl(userID: self.userId, teamId)
        if self.activeRequests[urlString] != nil {
            return .requestExists
        }
        
        let dataTask = self.PUT(urlString: urlString, parameters: params,success: { (dataTask, responseObject) in
            DispatchQueue.main.async {
                success?(dataTask, responseObject)
            }
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        }) { (dataTask, responseObject, error) in
            DispatchQueue.main.async {
                failure? (dataTask, responseObject, error)
            }
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        }
        dataTask?.taskDescription = urlString
        if let path = dataTask?.taskDescription {
            self.activeRequests[path] = dataTask
        }
        return .noError
    }

    // MARK: - Get Team Knowledge
    func doGetKnowledgeForTeam(in teamId: String, success:((URLSessionDataTask?, Any?) -> Void)?, failure:((URLSessionDataTask?, Any?, Error?) -> Void)?) -> KAHTTPRequestStatus {
        let reachable = self.networkReachability()
        if !reachable {
            return .noNetwork
        }
        
        let requestURL = SDKConfiguration.serverConfig.getRecentKnowledgeinTeamUrl(userId: self.userId, teamId)
        if self.activeRequests[requestURL] != nil {
            return .requestExists
        }
        
        let dataTask = self.GET(urlString: requestURL, parameters:nil, success:{ (dataTask, responseObject) in
            if let responseObject = responseObject as? Array<[String: Any]> {
                DispatchQueue.main.async {
                    success?(dataTask, responseObject)
                }
            }
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        }, failure:{ (dataTask, responseObject, error) in
            DispatchQueue.main.async {
                failure? (dataTask, responseObject, error)
            }
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        })
        
        dataTask?.taskDescription = requestURL
        if let path = dataTask?.taskDescription {
            self.activeRequests[path] = dataTask
        }
        return .noError
    }
    
    func doGetAllCalenderRequests(in success:((URLSessionDataTask?, Any?) -> Void)?, failure:((URLSessionDataTask?, Any?, Error?) -> Void)?) -> KAHTTPRequestStatus {
        let reachable = self.networkReachability()
        if !reachable {
            return .noNetwork
        }
        
        let urlString = SDKConfiguration.serverConfig.getCalendarRequests(userID: self.userId)
        if self.activeRequests[urlString] != nil {
            return .requestExists
        }
        
        let dataTask = self.GET(urlString: urlString, parameters: nil,success: { (dataTask, responseObject) in
            DispatchQueue.main.async {
                success?(dataTask, responseObject)
            }
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        }) { (dataTask, responseObject, error) in
            DispatchQueue.main.async {
                failure? (dataTask, responseObject, error)
            }
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        }
        dataTask?.taskDescription = urlString
        if let path = dataTask?.taskDescription {
            self.activeRequests[path] = dataTask
        }
        return .noError
    }
    
 */
    // MARK: - upload components
    func requestSerializer() -> AFJSONRequestSerializer {
        let requestSerializer = AFJSONRequestSerializer()
        requestSerializer.httpMethodsEncodingParametersInURI = Set.init(["GET"]) as Set<String>
        requestSerializer.setValue("Keep-Alive", forHTTPHeaderField:"Connection")
        requestSerializer.setValue(KoraAssistant.shared.applicationHeader, forHTTPHeaderField: "X-KORA-Client")
        let tokenType = "bearer"
        if let accessToken = AcccesssTokenn { //authInfo?.tokenType authInfo?.accessToken
            requestSerializer.setValue("\(tokenType) \(accessToken)", forHTTPHeaderField: "Authorization")
        }
        return requestSerializer
    }
    
    // MARK: Add Query Params
    // MARK: add query parameters
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
 

/*
extension KAAccount {
    // get & update refresh token
    func getAndUpdateRefreshToken(for request: URLRequest, with block:((Bool, KAHTTPRequestStatus) -> Void)?) {
        let newAuthorization = String(format: "bearer %@", self.accessToken)
        if let oldAuthorization = request.value(forHTTPHeaderField: "Authorization"), oldAuthorization != newAuthorization {
            block?(true, .noError)
        } else {
            let operation = KAUpdateAccessTokenOperation(request: request)
            operation.setCompletionBlock(progress: { (progress) in
                
            }) { (status, requestStatus) in
                block?(status, requestStatus)
            }
            operationQueue.addOperation(operation)
        }
    }
    
    // get & update refresh token
    func doGetRefreshToken(with block:((Bool, [String: Any]?) -> Void)?) -> KAHTTPRequestStatus {
        let reachable = self.networkReachability()
        if !reachable {
            return .noNetwork
        }
        var parameters = ["scope": "friends", "client_id": "1", "client_secret": "1", "grant_type": "refresh_token"]
        if let refreshToken = self.authInfo?.refreshToken {
            parameters["refresh_token"] = refreshToken
        }
        
        let urlString = KARESTAPIManager.shared.oAuthTokenUrl()
        if self.activeRequests[urlString] != nil {
            return .requestExists
        }

        let requestSerializer = AFJSONRequestSerializer()
        requestSerializer.setValue(KoraAssistant.shared.applicationHeader, forHTTPHeaderField: "X-KORA-Client")
        guard var request = try? requestSerializer.request(withMethod: "POST", urlString: urlString, parameters: parameters) as URLRequest else {
            return .requestError
        }
        request.timeoutInterval = DEFAULT_TIMEOUT_INTERVAL
        let dataTask = self.HTTPRequestOperation(with: request, success: { (dataTask, responseObject) in
            if let responseObject = responseObject as? [String: Any], let authorization = responseObject["authorization"] as? [String: Any] {
                block?(true, authorization)
            } else {
                block?(false, nil)
            }
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        }, failure:{ (dataTask, responseObject, error) in
            DispatchQueue.main.async {
                block?(false, nil)
            }
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        })
        
        dataTask?.taskDescription = urlString
        if let path = dataTask?.taskDescription {
            self.activeRequests[path] = dataTask
        }
        dataTask?.resume()
        return .noError
    }

    // MARK: - validate request manager
    func validateRequest(_ response: URLResponse?, _ responseObject: Any?, with block:((Bool, Bool) -> Void)?) {
        var shouldRetry = false
        var tokenExpired = false
        let responseObject = responseObject as? [String: Any]
        let urlResponse = response as? HTTPURLResponse
        guard let statusCode = urlResponse?.statusCode else {
            block?(shouldRetry, tokenExpired)
            return
        }
        
        switch (statusCode) {
        case 200:
            break
        case 401:
            // access token expiry check
            if let errors = responseObject?["errors"] as? Array<[String: Any]>, let dictionary = errors.first {
                var errorCode = 0
                guard let code = dictionary["code"] else {
                    block?(shouldRetry, tokenExpired)
                    return
                }
                // Since the same error code 401 is being returned in thirdparty files request case also.
                // Having a check for thirdparty files request error code. Else Switch block is firing default case, which is logging out user ...
                if let code = code as? String {
                    let code: String = code.uppercased()
                    if (code == "CONNECTION_NOT_EXISTS") || (code == "CONNECTION_EXPIRED") || (code == "CONNECTION_NOT_CONFIGURED") {
                        
                    } else if (code == "TOKEN_EXPIRED") {
                        shouldRetry = true
                        tokenExpired = true
                    }
                    block?(shouldRetry, tokenExpired)
                    return
                } else if let code = dictionary["code"] as? [String: Any], let value = code["code"] as? Int {
                    errorCode = value
                } else if let code = dictionary["code"] as? NSNumber {
                    errorCode = code.intValue
                }
                
                guard let message = dictionary["msg"] as? String else {
                    block?(shouldRetry, tokenExpired)
                    return
                }
                switch (errorCode) {
                case 41:
                    if (message == "INVALID_ACCESS_TOKEN") {
                        shouldRetry = true
                        tokenExpired = false
                    }
                case 46:
                    if (message == "PASSWORD_POLICY_CHANGED") {
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: KoraNotification.EnforcementNotification), object: ["type": KoraNotification.EnforcementType.passwordPolicyChanged])
                        }
                    }
                case 47:
                    /*
                     PASSWORD EXPIRY
                     1. if error code if 46 OR 47
                     2. if request is for LOGIN -> Display ChangePassword Screen WithoutAutoLogin
                     else Display PASSWORD EXPIRED ALERT
                     3. Click LOGOUT -> Display LoginScreen
                     4. Click CHANGE_PASSWORD -> Display ChangePassword Screen
                     5. Fill Data -> Click UPDATE -> Hit Login Service -> Get New Access Token -> Update Password Service.
                     */
                    if (message == "PASSWORD_EXPIRED") {
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: KoraNotification.EnforcementNotification), object: ["type": KoraNotification.EnforcementType.passwordExpired])
                        }
                    }
                case 48:
                    if (message == "ADMIN_PASSWORD_RESET") {
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: KoraNotification.EnforcementNotification), object: ["type": KoraNotification.EnforcementType.adminPasswordReset])
                        }
                    }
                case 49:
                    if (message == "MANAGED_BY_ENTERPRISE") {
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: KoraNotification.EnforcementNotification), object: ["type": KoraNotification.EnforcementType.managedByEnterprise])
                        }
                    } else if (message == "LICENSE_CHANGED") {
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: KoraNotification.EnforcementNotification), object: ["type": KoraNotification.EnforcementType.licenseChanged])
                        }
                    }
                case 50:
                    if (message == "ADMIN_SSO_ENABLED") {
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: KoraNotification.EnforcementNotification), object: ["type": KoraNotification.EnforcementType.adminSSOEnabled])
                        }
                    }
                case 51:
                    if (message == "ADMIN_SSO_DISABLED") {
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: KoraNotification.EnforcementNotification), object: ["type": KoraNotification.EnforcementType.adminSSODisabled])
                        }
                    }
                case 52:
                    if (message == "ADMIN_ACCOUNT_SUSPEND") {
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: KoraNotification.EnforcementNotification), object: ["type": KoraNotification.EnforcementType.adminAccountSuspend])
                        }
                    }
                case 53:
                    if (message == "ADMIN_KILLED_SESSION") {
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: KoraNotification.EnforcementNotification), object: ["type": KoraNotification.EnforcementType.adminKilledSession])
                        }
                    }
                case 54:
                    if (message == "USAGE_POLICY_CHANGED") {
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: KoraNotification.EnforcementNotification), object: ["type": KoraNotification.EnforcementType.usagePolicyChanged])
                        }
                    }
                case 55:
                    if (message == "ADMIN_ACCOUNT_DELETED") {
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: KoraNotification.EnforcementNotification), object: ["type": KoraNotification.EnforcementType.adminAccountDeleted])
                        }
                    }
                case 57:
                    if message == "LOG_OFF" {
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: KoraNotification.EnforcementNotification), object: ["type": KoraNotification.EnforcementType.userSessionDidBecomeInvalid])
                        }
                    }
                case 61:
                    if message == "PERMISSIONS_CHANGED" {
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: KoraNotification.EnforcementNotification), object: ["type": KoraNotification.EnforcementType.accountPermissionsChanged])
                        }
                    }
                default:
                    break
                }
            }
        default:
            break
        }
        block?(shouldRetry, tokenExpired)
    }
    
    // MARK: -
    func HTTPRequestOperation(with request: URLRequest, success:((URLSessionDataTask?, Any?) -> Void)?, failure:((URLSessionDataTask?, Any?, Error?) -> Void)?) -> URLSessionDataTask? {
        guard let _ = authInfo?.accessToken else {
            return nil
        }
        
        var dataTask: URLSessionDataTask?
        let manager: KAHTTPSessionManager = self.requestSessionManager
        manager.responseSerializer = AFJSONResponseSerializer(readingOptions: .allowFragments)
        
        dataTask = manager.dataTask(with: request, uploadProgress: { (progress) in
            
        }, downloadProgress: { (progress) in
            
        }) { [weak self] (response, responseObject, error) in
            if error == nil {
                self?.validateRequest(response, responseObject, with:{ (shouldRetry, tokenExpired) in
                    success?(dataTask, responseObject)
                })
            } else if let weakSelf = self {
                self?.validateRequest(response, responseObject, with:{ (shouldRetry, tokenExpired) in
                    let tokenDidBecomeInvalid: (() -> Void) = {
                        failure?(dataTask, responseObject, error)
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: KoraNotification.EnforcementNotification), object: ["type": KoraNotification.EnforcementType.accessTokenDidBecomeInvalid])
                        }
                    }
                    
                    let retryOperation:((URLSessionDataTask?) -> Void) = { (dataTask) in
                        if var request = dataTask?.originalRequest {
                            let authorization = String(format: "bearer %@", weakSelf.accessToken)
                            request.setValue(authorization, forHTTPHeaderField: "Authorization")
                            let updatedDataTask = weakSelf.HTTPRequestOperation(with: request, success: success, failure: failure)
                            updatedDataTask?.taskDescription = dataTask?.taskDescription
                            updatedDataTask?.resume()
                        }
                    }
                    
                    if tokenExpired && shouldRetry {
                        weakSelf.getAndUpdateRefreshToken(for: request, with: { (status, requestStatus) in
                            switch (requestStatus) {
                            case .noError:
                                if status {
                                    retryOperation(dataTask)
                                    weakSelf.resumeAllTasks()
                                } else {
                                    tokenDidBecomeInvalid()
                                }
                                break
                            default:
                                failure?(dataTask, responseObject, error)
                                break
                            }
                        })
                    } else if shouldRetry, let weakSelf = self {
                        if let allHTTPHeaderFields = request.allHTTPHeaderFields, let oldAuthorization = allHTTPHeaderFields["Authorization"] {
                            let newAuthorization = String(format: "bearer %@", weakSelf.accessToken)
                            if oldAuthorization != newAuthorization {
                                retryOperation(dataTask)
                                return
                            }
                        }
                        tokenDidBecomeInvalid()
                    } else {
                        failure?(dataTask, responseObject, error)
                    }
                })
            }
        }
        return dataTask
    }
    
    // MARK: - HTTP methods
    @objc public func GET(urlString: String, parameters: [String: Any]?, success:((URLSessionDataTask?, Any?) -> Void)?, failure:((URLSessionDataTask?, Any?, Error?) -> Void)?) -> URLSessionDataTask? {
        guard var request = try? requestSerializer().request(withMethod: "GET", urlString: urlString, parameters: parameters) as URLRequest else {
            return nil
        }
        request.timeoutInterval = DEFAULT_TIMEOUT_INTERVAL
        let dataTask = self.HTTPRequestOperation(with: request, success:success, failure:failure)
        dataTask?.taskDescription = request.url?.absoluteString.appendingFormat("/%@", request.httpMethod!)
        if operationQueue.operations.count > 0, let task = dataTask {
            pendingTasks.append(task)
        } else {
            dataTask?.resume()
        }
        return dataTask
    }
    
    @objc public func HEAD(urlString: String, parameters: [String: Any]?, success:((URLSessionDataTask?, Any?) -> Void)?, failure:((URLSessionDataTask?, Any?, Error?) -> Void)?) -> URLSessionDataTask? {
        guard var request = try? requestSerializer().request(withMethod: "HEAD", urlString: urlString, parameters: parameters) as URLRequest else {
            return nil
        }
        request.timeoutInterval = DEFAULT_TIMEOUT_INTERVAL
        let dataTask = self.HTTPRequestOperation(with: request, success:{ (requestOperation, responseObject) in
            success?(requestOperation, responseObject)
        }, failure: failure)
        dataTask?.taskDescription = request.url?.absoluteString.appendingFormat("/%@", request.httpMethod!)
        if operationQueue.operations.count > 0, let task = dataTask {
            pendingTasks.append(task)
        } else {
            dataTask?.resume()
        }
        return dataTask
    }
    
    @objc public func POST(urlString: String, parameters: Any?, success:((URLSessionDataTask?, Any?) -> Void)?, failure:((URLSessionDataTask?, Any?, Error?) -> Void)?) -> URLSessionDataTask? {
        guard var request = try? requestSerializer().request(withMethod: "POST", urlString:urlString, parameters: parameters) as URLRequest else {
            return nil
        }
        request.timeoutInterval = DEFAULT_TIMEOUT_INTERVAL
        let dataTask = self.HTTPRequestOperation(with: request, success:success, failure:failure)
        dataTask?.taskDescription = request.url?.absoluteString.appendingFormat("/%@", request.httpMethod!)
        if operationQueue.operations.count > 0, let task = dataTask {
            pendingTasks.append(task)
        } else {
            dataTask?.resume()
        }
        return dataTask
    }
    
    @objc public func POST(urlString: String, parameters: [String: Any]?, constructingBodyWithBlock block:((AFMultipartFormData?) -> Void)?, success:((URLSessionDataTask?, Any?) -> Void)?, failure:((URLSessionDataTask?, Any?, Error?) -> Void)?) -> URLSessionDataTask? {
        var request = requestSerializer().multipartFormRequest(withMethod: "POST", urlString: urlString, parameters: parameters, constructingBodyWith: block, error: nil) as URLRequest
        request.timeoutInterval = DEFAULT_TIMEOUT_INTERVAL
        let dataTask = self.HTTPRequestOperation(with: request, success:success, failure:failure)
        dataTask?.taskDescription = request.url?.absoluteString.appendingFormat("/%@", request.httpMethod!)
        if operationQueue.operations.count > 0, let task = dataTask {
            pendingTasks.append(task)
        } else {
            dataTask?.resume()
        }
        return dataTask
    }
    
    @objc public func PUT(urlString: String, parameters: [String: Any]?, success:((URLSessionDataTask?, Any?) -> Void)?, failure:((URLSessionDataTask?, Any?, Error?) -> Void)?) -> URLSessionDataTask? {
        guard var request = try? requestSerializer().request(withMethod: "PUT", urlString: urlString, parameters: parameters) as URLRequest else {
            return nil
        }
        request.timeoutInterval = DEFAULT_TIMEOUT_INTERVAL
        let dataTask = self.HTTPRequestOperation(with: request, success:success, failure:failure)
        dataTask?.taskDescription = request.url?.absoluteString.appendingFormat("/%@", request.httpMethod!)
        if operationQueue.operations.count > 0, let task = dataTask {
            pendingTasks.append(task)
        } else {
            dataTask?.resume()
        }
        return dataTask
    }
    
    @objc public func PATCH(urlString: String, parameters: [String: Any]?, success:((URLSessionDataTask?, Any?) -> Void)?, failure:((URLSessionDataTask?, Any?, Error?) -> Void)?) -> URLSessionDataTask? {
        guard var request = try? requestSerializer().request(withMethod: "PATCH", urlString:urlString, parameters: parameters) as URLRequest else {
            return nil
        }
        request.timeoutInterval = DEFAULT_TIMEOUT_INTERVAL
        let dataTask = self.HTTPRequestOperation(with: request, success:success, failure:failure)
        dataTask?.taskDescription = request.url?.absoluteString.appendingFormat("/%@", request.httpMethod!)
        if operationQueue.operations.count > 0, let task = dataTask {
            pendingTasks.append(task)
        } else {
            dataTask?.resume()
        }
        return dataTask
    }
    
    @objc public func DELETE(urlString: String, parameters: [String: Any]?, success:((URLSessionDataTask?, Any?) -> Void)?, failure:((URLSessionDataTask?, Any?, Error?) -> Void)?) -> URLSessionDataTask? {
        guard var request = try? requestSerializer().request(withMethod: "DELETE", urlString: urlString, parameters: parameters) as URLRequest else {
            return nil
        }
        request.timeoutInterval = DEFAULT_TIMEOUT_INTERVAL
        
        let dataTask = self.HTTPRequestOperation(with: request, success:success, failure:failure)
        dataTask?.taskDescription = request.url?.absoluteString.appendingFormat("/%@", request.httpMethod!)
        if operationQueue.operations.count > 0, let task = dataTask {
            pendingTasks.append(task)
        } else {
            dataTask?.resume()
        }
        return dataTask
    }
    
    func showAlert(with title: String, and message: String) {

    }
    
    // MARK: - Kora requests
    func doGetRecentKnowledges(parameters: [String: Any]?, success:((_ responseObject: Array<[String: Any]>?) -> Void)?, failure:((_ error: Error?) -> Void)?) -> KAHTTPRequestStatus {
        let reachable = self.networkReachability()
        if !reachable {
            return .noNetwork
        }
        
        
        let requestURL = SDKConfiguration.serverConfig.getRecentKnowledgeUrl(userId: self.userId)

        let dataTask = self.GET(urlString: requestURL, parameters: parameters, success:{ (dataTask, responseObject) in
            if let responseObject = responseObject as? Array<[String: Any]> {
                DispatchQueue.main.async {
                    success?(responseObject)
                }
            }
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        }, failure:{ (dataTask, responseObject, error) in
            DispatchQueue.main.async {
                failure?(error)
            }
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        })
        
        dataTask?.taskDescription = requestURL
        if let path = dataTask?.taskDescription {
            self.activeRequests[path] = dataTask
        }
        return .noError
    }
    
    func doGetAnnouncements(parameters: [String: Any]?, success:((_ responseObject: Array<[String: Any]>?) -> Void)?, failure:((_ error: Error?) -> Void)?) -> KAHTTPRequestStatus {
        let reachable = self.networkReachability()
        if !reachable {
            return .noNetwork
        }
        
        let requestURL = SDKConfiguration.serverConfig.getAnnouncementsUrl(userId: self.userId)
        let dataTask = self.GET(urlString: requestURL, parameters: parameters, success:{ (dataTask, responseObject) in
            if let responseObject = responseObject as? Array<[String: Any]> {
                DispatchQueue.main.async {
                    success?(responseObject)
                }
            }
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        }, failure:{ (dataTask, responseObject, error) in
            DispatchQueue.main.async {
                failure?(error)
            }
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        })
        
        dataTask?.taskDescription = requestURL
        if let path = dataTask?.taskDescription {
            self.activeRequests[path] = dataTask
        }
        return .noError
    }

    func doGetAvailableSkills(parameters: [String: Any]?, success:((_ responseObject: [String: Any]?) -> Void)?, failure:((_ error: Error?) -> Void)?) -> KAHTTPRequestStatus {
        let reachable = self.networkReachability()
        if !reachable {
            return .noNetwork
        }
        let KORE_SERVER = SDKConfiguration.serverConfig.KORE_SERVER
        let requestURL = KARESTAPIManager.shared.getDisabledSkillsSearch(with: self.userId, server: KORE_SERVER)
        let dataTask = self.GET(urlString: requestURL, parameters: nil, success:{ (dataTask, responseObject) in
            if let responseObject = responseObject as? [String: Any] {
                DispatchQueue.main.async {
                    success?(responseObject)
                }
            }
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        }, failure:{ (dataTask, responseObject, error) in
            DispatchQueue.main.async {
                failure?(error)
            }
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        })
        
        dataTask?.taskDescription = requestURL
        if let path = dataTask?.taskDescription {
            self.activeRequests[path] = dataTask
        }
        return .noError
    }
    
    func doPostSearchSkills(with parameters: [String: Any]?, completion block:(([String: Any]?, Error?) -> Void)?) -> KAHTTPRequestStatus {
        let reachable = self.networkReachability()
        if !reachable {
            return .noNetwork
        }
        var requestURL = String(format:"%@api/1.1/ka/users/%@/skills", KORE_SERVER, self.userId)
        if let params = parameters {
            let skillId = params["skillId"] as! String
            let action = params["action"] as! String
            requestURL += String(format:"/%@/actions/%@/?authcheck=true", skillId, action)
        }

        if self.activeRequests[requestURL] != nil {
            return .requestExists
        }
        
        let dataTask = self.POST(urlString: requestURL, parameters:nil, success:{ (dataTask, responseObject) in
            if let responseObject = responseObject as? [String: Any] {
                DispatchQueue.main.async {
                    block?(responseObject, nil)
                }
            }
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        }, failure:{ (dataTask, responseObject, error) in
            DispatchQueue.main.async {
                block?(nil, error)
            }
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        })
        
        dataTask?.taskDescription = requestURL
        if let path = dataTask?.taskDescription {
            self.activeRequests[path] = dataTask
        }
        return .noError
    }
    
    func doGetEnabledSkillsSearch(parameters: [String: Any]?, success:((_ responseObject: [String: Any]?) -> Void)?, failure:((_ error: Error?) -> Void)?) -> KAHTTPRequestStatus {
        let reachable = self.networkReachability()
        if !reachable {
            return .noNetwork
        }
        let KORE_SERVER = SDKConfiguration.serverConfig.KORE_SERVER
        let requestURL = KARESTAPIManager.shared.getEnabledSkillsSearch(with: self.userId, server: KORE_SERVER)
        let dataTask = self.GET(urlString: requestURL, parameters: nil, success:{ (dataTask, responseObject) in
            if let responseObject = responseObject as? [String: Any] {
                DispatchQueue.main.async {
                    success?(responseObject)
                }
            }
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        }, failure:{ (dataTask, responseObject, error) in
            DispatchQueue.main.async {
                failure?(error)
            }
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        })
        
        dataTask?.taskDescription = requestURL
        if let path = dataTask?.taskDescription {
            self.activeRequests[path] = dataTask
        }
        return .noError
    }
    
    func doGetRecentSkills(parameters: [String: Any]?, success:((_ responseObject: [String: Any]?) -> Void)?, failure:((_ error: Error?) -> Void)?) -> KAHTTPRequestStatus {
        let reachable = self.networkReachability()
        if !reachable {
            return .noNetwork
        }
        
        let requestURL = SDKConfiguration.serverConfig.getRecentSkills(userId: self.userId)
        let dataTask = self.GET(urlString: requestURL, parameters: nil, success:{ (dataTask, responseObject) in
            if let responseObject = responseObject as? [String: Any] {
                DispatchQueue.main.async {
                    success?(responseObject)
                }
            }
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        }, failure:{ (dataTask, responseObject, error) in
            DispatchQueue.main.async {
                failure?(error)
            }
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        })
        
        dataTask?.taskDescription = requestURL
        if let path = dataTask?.taskDescription {
            self.activeRequests[path] = dataTask
        }
        return .noError
    }

    
    
    func doPostKnowledge(with parameters: [String: Any]?, completion block:(([String: Any]?, Error?) -> Void)?) -> KAHTTPRequestStatus {
        let reachable = self.networkReachability()
        if !reachable {
            return .noNetwork
        }
        
        let requestURL = String(format:"%@api/1.1/ka/users/%@/knowledge", KORE_SERVER, self.userId)
        if self.activeRequests[requestURL] != nil {
            return .requestExists
        }
        
        let dataTask = self.POST(urlString: requestURL, parameters:nil, success:{ (dataTask, responseObject) in
            if let responseObject = responseObject as? [String: Any] {
                DispatchQueue.main.async {
                    block?(responseObject, nil)
                }
            }
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        }, failure:{ (dataTask, responseObject, error) in
            DispatchQueue.main.async {
                block?(nil, error)
            }
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        })
        
        dataTask?.taskDescription = requestURL
        if let path = dataTask?.taskDescription {
            self.activeRequests[path] = dataTask
        }
        return .noError
    }
    
    func createTask(with parameters: [String: Any]?, completion block:(([String: Any]?, Error?) -> Void)?) -> KAHTTPRequestStatus {
        let reachable = self.networkReachability()
        if !reachable {
            return .noNetwork
        }
        
        let requestURL = String(format:"%@api/1.1/ka/users/%@/task/", KORE_SERVER, self.userId)
        if self.activeRequests[requestURL] != nil {
            return .requestExists
        }
        
        let dataTask = self.POST(urlString: requestURL, parameters: parameters, success:{ (dataTask, responseObject) in
            if let responseObject = responseObject as? [String: Any] {
                DispatchQueue.main.async {
                    block?(responseObject, nil)
                }
            }
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        }, failure:{ (dataTask, responseObject, error) in
            DispatchQueue.main.async {
                block?(nil, error)
            }
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        })
        
        dataTask?.taskDescription = requestURL
        if let path = dataTask?.taskDescription {
            self.activeRequests[path] = dataTask
        }
        return .noError
    }

    
    
    func doPostKnowledgeTaskWithParameters(parameters: [String: Any]?, completion block:(([String: Any]?, Error?) -> Void)?) -> KAHTTPRequestStatus {
        let reachable = self.networkReachability()
        if !reachable {
            return .noNetwork
        }
        
        let requestURL = String(format:"%@api/1.1/ka/users/%@/knowledge", KORE_SERVER, self.userId)
        if self.activeRequests[requestURL] != nil {
            return .requestExists
        }
        
        let dataTask = self.POST(urlString: requestURL, parameters:parameters, success:{ (dataTask, responseObject) in
            if let responseObject = responseObject as? [String: Any] {
                DispatchQueue.main.async {
                    block?(responseObject, nil)
                }
            }
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        }, failure:{ (dataTask, responseObject, error) in
            DispatchQueue.main.async {
                block?(nil, error)
            }
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        })
        
        dataTask?.taskDescription = requestURL
        if let path = dataTask?.taskDescription {
            self.activeRequests[path] = dataTask
        }
        return .noError
    }
    
    func doResolveKnowledgeTask(with taskId: String, completionBlock block:(([String: Any]?, Error?) -> Void)?) -> KAHTTPRequestStatus {
        let reachable = self.networkReachability()
        if !reachable {
            return .noNetwork
        }
        
        let requestURL = String(format:"%@api/1.1/ka/users/%@/knowledge/%@", KORE_SERVER, self.userId, taskId)
        if self.activeRequests[requestURL] != nil {
            return .requestExists
        }
        
        let dataTask = self.GET(urlString: requestURL, parameters:nil, success:{ (dataTask, responseObject) in
            if let responseObject = responseObject as? [String: Any] {
                DispatchQueue.main.async {
                    block?(responseObject, nil)
                }
            }
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        }, failure:{ (dataTask, responseObject, error) in
            DispatchQueue.main.async {
                block?(nil, error)
            }
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        })
        dataTask?.taskDescription = requestURL
        if let path = dataTask?.taskDescription {
            self.activeRequests[path] = dataTask
        }
        return .noError
    }
    
    
    func doResolveKnowledgeTask(with taskId: String, type: String, completionBlock block:(([String: Any]?, Error?) -> Void)?) -> KAHTTPRequestStatus {
        let reachable = self.networkReachability()
        if !reachable {
            return .noNetwork
        }
        
        let requestURL = String(format:"%@api/1.1/ka/users/%@/knowledge/%@?type=%@", KORE_SERVER, self.userId, taskId, type)
        if self.activeRequests[requestURL] != nil {
            return .requestExists
        }
        
        let dataTask = self.GET(urlString: requestURL, parameters:nil, success:{ (dataTask, responseObject) in
            if let responseObject = responseObject as? [String: Any] {
                DispatchQueue.main.async {
                    block?(responseObject, nil)
                }
            }
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        }, failure:{ (dataTask, responseObject, error) in
            DispatchQueue.main.async {
                block?(responseObject as! [String : Any], error)
            }
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        })
        dataTask?.taskDescription = requestURL
        if let path = dataTask?.taskDescription {
            if self.activeRequests[path] != nil {
                self.activeRequests.removeValue(forKey: path)
            }
        }
        return .noError
    }

    
    func doResolveKnowledges(with taskIds: [String]?, isAnnouncement: Bool = false, parameteres parameters: [String: Any]?, success:((Any?) -> Void)?, failure:((Error?) -> Void)?) -> KAHTTPRequestStatus {
        let reachable = self.networkReachability()
        if !reachable {
            return .noNetwork
        }
        
        var requestURL = String(format: "%@api/1.1/ka/users/%@/knowledge/resolve", KORE_SERVER, self.userId)
        if isAnnouncement {
            requestURL = requestURL + "?type=announcement"
        }
        if self.activeRequests[requestURL] != nil {
            return .requestExists
        }
        
        let dataTask = self.POST(urlString: requestURL, parameters: parameters, success:{ (dataTask, responseObject) in
            DispatchQueue.main.async {
                success?(responseObject)
            }
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        }, failure:{ (dataTask, responseObject, error) in
            DispatchQueue.main.async {
                failure?(error)
            }
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        })
        
        dataTask?.taskDescription = requestURL
        if let path = dataTask?.taskDescription {
            self.activeRequests[path] = dataTask
        }
        return .noError
    }
    
    func doPostInformation(with knowledgeId: String?, parameteres parameters: [String: Any]?, questionId: String?, completionBlock block:(([String: Any]?, Error?) -> Void)?) -> KAHTTPRequestStatus {
        let reachable = self.networkReachability()
        if !reachable {
            return .noNetwork
        }
        
        var requestURL = String(format:"%@api/1.1/ka/users/%@/knowledge", KORE_SERVER, self.userId)
        if let knowledgeId = knowledgeId {
            requestURL = requestURL.appendingFormat("/%@/edit", knowledgeId)
        }
        
        if let questionId = questionId {
            requestURL = requestURL.appendingFormat("?questionId=%@", questionId)
        }
        
        if self.activeRequests[requestURL] != nil {
            return .requestExists
        }
        
        let dataTask = self.POST(urlString: requestURL, parameters: parameters, success:{ (dataTask, responseObject) in
            DispatchQueue.main.async {
                if let responseObject = responseObject as? [String: Any] {
                    block?(responseObject, nil)
                } else {
                    block?(nil, nil)
                }
            }
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        }, failure:{ (dataTask, responseObject, error) in
            DispatchQueue.main.async {
                block?(nil, error)
            }
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        })
        
        dataTask?.taskDescription = requestURL
        if let path = dataTask?.taskDescription {
            self.activeRequests[path] = dataTask
        }
        return .noError
    }
    
    func doGetIsOnboarded(with parameters: [String: Any]?, completion block: (([String: Any]?, Error?) -> Void)?) -> KAHTTPRequestStatus {
        let reachable = self.networkReachability()
        if !reachable {
            return .noNetwork
        }
        
        
        let requestURL = String(format:"%@api/1.1/users/%@/isOnboarded", KORE_SERVER, self.userId)
        if self.activeRequests[requestURL] != nil {
            return .requestExists
        }
        
        let dataTask = self.GET(urlString: requestURL, parameters:parameters, success:{ (dataTask, responseObject) in
            if (responseObject is NSDictionary) {
                DispatchQueue.main.async {
                    block?(responseObject as? [String : Any], nil)
                }
            }
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        }, failure:{ (dataTask, responseObject, error) in
            DispatchQueue.main.async {
                block?(nil, error)
            }
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        })
        
        dataTask?.taskDescription = requestURL
        if let path = dataTask?.taskDescription {
            self.activeRequests[path] = dataTask
        }
        return .noError
    }
    
    func doPutIsOnboarded(with parameters: [String: Any]?, completion block:(([String: Any]?, Error?) -> Void)?) -> KAHTTPRequestStatus {
        let reachable = self.networkReachability()
        if !reachable {
            return .noNetwork
        }
        
        let requestURL = String(format:"%@api/1.1/users/%@/isOnboarded", KORE_SERVER, self.userId)
        if self.activeRequests[requestURL] != nil {
            return .requestExists
        }
        
        let dataTask = self.PUT(urlString: requestURL, parameters:parameters, success:{ (dataTask, responseObject) in
            DispatchQueue.main.async {
                if let responseObject = responseObject as? [String: Any] {
                    block?(responseObject, nil)
                } else {
                    block?(nil, nil)
                }
            }
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        }, failure:{ (dataTask, responseObject, error) in
            DispatchQueue.main.async {
                block?(nil, error)
            }
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        })
        
        dataTask?.taskDescription = requestURL
        if let path = dataTask?.taskDescription {
            self.activeRequests[path] = dataTask
        }
        return .noError
    }
    
    // MARK: - kora requests
    func doShareKnowledge(with knowledgeId: String, parameters: [String: Any]?, notify isnotify: Bool, success:((URLSessionDataTask?, Any?) -> Void)?, failure:((URLSessionDataTask?, Any?, Error?) -> Void)?) -> KAHTTPRequestStatus {
        let reachable = self.networkReachability()
        if !reachable {
            return .noNetwork
        }
        
        var requestURL = String(format:"%@api/1.1/ka/users/%@/knowledge/%@/share", KORE_SERVER, self.userId, knowledgeId)
        if isnotify {
            let queryParameters: [String: Any] = ["notify": "true"]
            requestURL = self.addQueryString(to: requestURL, with: queryParameters)
        } else {
            let queryParameters: [String: Any] = ["notify": "false"]
            requestURL = self.addQueryString(to: requestURL, with: queryParameters)
        }
        
        if self.activeRequests[requestURL] != nil {
            return .requestExists
        }
        
        let dataTask = self.POST(urlString: requestURL, parameters: parameters, success:{ (dataTask, responseObject) in
            DispatchQueue.main.async {
                success?(dataTask, responseObject)
            }
            
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        }, failure:{ (dataTask, responseObject, error) in
            DispatchQueue.main.async {
                failure? (dataTask, responseObject, error)
            }
            
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        })
        
        dataTask?.taskDescription = requestURL
        if let path = dataTask?.taskDescription {
            self.activeRequests[path] = dataTask
        }
        return .noError
    }
    
    func doUnShareKnowledge(with knowledgeId: String, parameters: [String: Any]?, completion block:(([String: Any]?, Error?) -> Void)?) -> KAHTTPRequestStatus {
        let reachable = self.networkReachability()
        if !reachable {
            return .noNetwork
        }
        
        let requestURL = String(format: "%@api/1.1/ka/users/%@/knowledge/%@/share", KORE_SERVER, self.userId, knowledgeId)
        if self.activeRequests[requestURL] != nil {
            return .requestExists
        }
        
        let dataTask = self.PUT(urlString: requestURL, parameters:parameters, success:{ (dataTask, responseObject) in
            if let responseObject = responseObject as? [String: Any] {
                DispatchQueue.main.async {
                    block?(responseObject, nil)
                }
            }
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        }, failure:{ (dataTask, responseObject, error) in
            DispatchQueue.main.async {
                block?(nil, error)
            }
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        })
        
        dataTask?.taskDescription = requestURL
        if let path = dataTask?.taskDescription {
            self.activeRequests[path] = dataTask
        }
        return .noError
    }
    
    func doCanShareViewKnowledge(with knowledgeId: String, parameters: [String: Any]?, completion block:(([String: Any]?, Error?) -> Void)?) -> KAHTTPRequestStatus {
        let reachable = self.networkReachability()
        if !reachable {
            return .noNetwork
        }
        
        let requestURL = String(format: "%@api/1.1/ka/users/%@/knowledge/%@/share", KORE_SERVER, self.userId, knowledgeId)
        if self.activeRequests[requestURL] != nil {
            return .requestExists
        }
        
        let dataTask = self.PUT(urlString: requestURL, parameters: parameters, success:{ (dataTask, responseObject) in
            if let responseObject = responseObject as? [String: Any] {
                DispatchQueue.main.async {
                    block?(responseObject, nil)
                }
            }
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        }, failure:{ (dataTask, responseObject, error) in
            DispatchQueue.main.async {
                block?(nil, error)
            }
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        })
        
        dataTask?.taskDescription = requestURL
        if let path = dataTask?.taskDescription {
            self.activeRequests[path] = dataTask
        }
        return .noError
    }
    
    func doUnShareCompletelyKnowledge(with knowledgeId: String, parameters: [String: Any]?, completion block:(([String: Any]?, Error?) -> Void)?) -> KAHTTPRequestStatus {
        let reachable = self.networkReachability()
        if !reachable {
            return .noNetwork
        }
        
        let requestURL = String(format:"%@api/1.1/ka/users/%@/knowledge/%@/share", KORE_SERVER, self.userId, knowledgeId)
        if self.activeRequests[requestURL] != nil {
            return .requestExists
        }
        
        let dataTask = self.DELETE(urlString: requestURL, parameters:parameters, success:{ (dataTask, responseObject) in
            
            DispatchQueue.main.async {
                block?(responseObject as? [String : Any], nil)
            }
            
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        }, failure:{ (dataTask, responseObject, error) in
            DispatchQueue.main.async {
                block?(nil, error)
            }
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        })
        
        dataTask?.taskDescription = requestURL
        if let path = dataTask?.taskDescription {
            self.activeRequests[path] = dataTask
        }
        return .noError
    }
    
    func doTeachKnowledge(with knowledgeId: String, parameters:[String: Any], success:((URLSessionDataTask?, Any?) -> Void)?, failure:((URLSessionDataTask?, Any?, Error?) -> Void)?) -> KAHTTPRequestStatus {
        let reachable = self.networkReachability()
        if !reachable {
            return .noNetwork
        }
        
        var requestURL = String(format: "%@api/1.1/ka/users/%@/knowledge/%@/train", KORE_SERVER, self.userId, knowledgeId)
        requestURL = self.addQueryString(to: requestURL, with: nil)
        
        if self.activeRequests[requestURL] != nil {
            return .requestExists
        }
        
        let dataTask = self.POST(urlString: requestURL, parameters: parameters, success:{ (dataTask, responseObject) in
            if let responseObject = responseObject as? [String: Any] {
                DispatchQueue.main.async {
                    success?(dataTask, responseObject)
                }
            }
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        }, failure:{ (dataTask, responseObject, error) in
            DispatchQueue.main.async {
                failure? (dataTask, responseObject, error)
            }
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        })
        
        dataTask?.taskDescription = requestURL
        if let path = dataTask?.taskDescription {
            self.activeRequests[path] = dataTask
        }
        return .noError
    }
    
    func doDeleteTeachKnowledge(with knowledgeId: String, parameters:[String: Any], success:((URLSessionDataTask?, Any?) -> Void)?, failure:((URLSessionDataTask?, Any?, Error?) -> Void)?) -> KAHTTPRequestStatus {
        let reachable = self.networkReachability()
        if !reachable {
            return .noNetwork
        }
        
        var requestURL = String(format: "%@api/1.1/ka/users/%@/knowledge/%@/train", KORE_SERVER, self.userId, knowledgeId)
        requestURL = self.addQueryString(to: requestURL, with: nil)
        
        if self.activeRequests[requestURL] != nil {
            return .requestExists
        }
        
        let dataTask = self.DELETE(urlString: requestURL, parameters: parameters, success: { (dataTask, responseObject) in
            DispatchQueue.main.async {
                success?(dataTask, responseObject)
            }
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        }, failure:{ (dataTask, responseObject, error) in
            DispatchQueue.main.async {
                failure? (dataTask, responseObject, error)
            }
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        })
        
        dataTask?.taskDescription = requestURL
        if let path = dataTask?.taskDescription {
            self.activeRequests[path] = dataTask
        }
        return .noError
    }

    
    func doGetSharedUser(with knowledgeId: String, success:((URLSessionDataTask?, Any?) -> Void)?, failure:((URLSessionDataTask?, Any?, Error?) -> Void)?) -> KAHTTPRequestStatus {
        let reachable = self.networkReachability()
        if !reachable {
            return .noNetwork
        }
        
        let requestURL = String(format: "%@api/1.1/ka/users/%@/knowledge/%@/share", KORE_SERVER, self.userId, knowledgeId)
        if self.activeRequests[requestURL] != nil {
            return .requestExists
        }
        
        let dataTask = self.GET(urlString: requestURL, parameters:nil, success:{ (dataTask, responseObject) in
            DispatchQueue.main.async {
                success?(dataTask, responseObject)
            }
            
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        }, failure:{ (dataTask, responseObject, error) in
            DispatchQueue.main.async {
                failure? (dataTask, responseObject, error)
            }
            
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        })
        
        dataTask?.taskDescription = requestURL
        if let path = dataTask?.taskDescription {
            self.activeRequests[path] = dataTask
        }
        return .noError
    }
    
    func doGetTeachedQuestions(with knowledgeId: String, success:((URLSessionDataTask?, Any?) -> Void)?, failure:((URLSessionDataTask?, Any?, Error?) -> Void)?) -> KAHTTPRequestStatus {
        let reachable = self.networkReachability()
        if !reachable {
            return .noNetwork
        }
        
        let requestURL = String(format:"%@api/1.1/ka/users/%@/knowledge/%@/train", KORE_SERVER, self.userId, knowledgeId)
        if self.activeRequests[requestURL] != nil {
            return .requestExists
        }
        
        let dataTask = self.GET(urlString: requestURL, parameters:nil, success:{ (dataTask, responseObject) in
            DispatchQueue.main.async {
                success?(dataTask, responseObject)
            }
            
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        }, failure:{ (dataTask, responseObject, error) in
            DispatchQueue.main.async {
                failure? (dataTask, responseObject, error)
            }
            
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        })
        
        dataTask?.taskDescription = requestURL
        if let path = dataTask?.taskDescription {
            self.activeRequests[path] = dataTask
        }
        return .noError
    }
    
    
    func doGetKnowledge(with knowledgeId: String, success:((URLSessionDataTask?, Any?) -> Void)?, failure:((URLSessionDataTask?, Any?, Error?) -> Void)?) -> KAHTTPRequestStatus {
        let reachable = self.networkReachability()
        if !reachable {
            return .noNetwork
        }
        
        
        let requestURL = String(format:"%@api/1.1/ka/users/%@/knowledge/%@", KORE_SERVER, self.userId, knowledgeId)
        
        if self.activeRequests[requestURL] != nil {
            return .requestExists
        }
        
        let dataTask = self.GET(urlString: requestURL, parameters:nil, success:{ (dataTask, responseObject) in
            DispatchQueue.main.async {
                success?(dataTask, responseObject)
            }
            
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        }, failure:{ (dataTask, responseObject, error) in
            DispatchQueue.main.async {
                failure? (dataTask, responseObject, error)
            }
            
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        })
        
        dataTask?.taskDescription = requestURL
        if let path = dataTask?.taskDescription {
            self.activeRequests[path] = dataTask
        }
        return .noError
    }
    
    func doGetContacts(token: String?, success:((URLSessionDataTask?, Any?) -> Void)?, failure:((URLSessionDataTask?, Any?, Error?) -> Void)?) -> KAHTTPRequestStatus {
        let reachable = self.networkReachability()
        if !reachable {
            return .noNetwork
        }
        
        let urlString = KARESTAPIManager.shared.contactsUrl(userId: self.userId, token: token ?? "")
        if self.activeRequests[urlString] != nil {
            return .requestExists
        }
        
        let dataTask = self.GET(urlString: urlString, parameters: nil, success: { (dataTask, responseObject) in
            DispatchQueue.main.async {
                success?(dataTask, responseObject)
            }
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        }) { (dataTask, responseObject, error) in
            DispatchQueue.main.async {
                failure? (dataTask, responseObject, error)
            }
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        }
        dataTask?.taskDescription = urlString
        if let path = dataTask?.taskDescription {
            self.activeRequests[path] = dataTask
        }
        return .noError
    }
    
    func doGetHashTags(with urlString: String, success:((URLSessionDataTask?, Any?) -> Void)?, failure:((URLSessionDataTask?, Any?, Error?) -> Void)?) -> KAHTTPRequestStatus {
        let reachable = self.networkReachability()
        if !reachable {
            return .noNetwork
        }
        
        
        let requestURL = String(format:"%@%@", KORE_SERVER, urlString)
        
        if self.activeRequests[requestURL] != nil {
            return .requestExists
        }
        
        let dataTask = self.GET(urlString: requestURL, parameters:nil, success:{ (dataTask, responseObject) in
            DispatchQueue.main.async {
                success?(dataTask, responseObject)
            }
            
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        }, failure:{ (dataTask, responseObject, error) in
            DispatchQueue.main.async {
                failure? (dataTask, responseObject, error)
            }
            
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        })
        
        dataTask?.taskDescription = requestURL
        if let path = dataTask?.taskDescription {
            self.activeRequests[path] = dataTask
        }
        return .noError
    }
    
    func doVoteInformation(with parameters: [String: Any]?, knowledge kid: String, completion block:(([String: Any]?, Error?) -> Void)?) -> KAHTTPRequestStatus {
        let reachable = self.networkReachability()
        if !reachable {
            return .noNetwork
        }
        
        let requestURL = String(format: "%@api/1.1/ka/users/%@/knowledge/%@/react", KORE_SERVER, self.userId, kid)
        if self.activeRequests[requestURL] != nil {
            return .requestExists
        }
        
        let dataTask = self.POST(urlString: requestURL, parameters:parameters, success:{ (dataTask, responseObject) in
            if let responseObject = responseObject as? [String: Any] {
                DispatchQueue.main.async {
                    block?(responseObject, nil)
                }
            }
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        }, failure:{ (dataTask, responseObject, error) in
            DispatchQueue.main.async {
                block?(nil, error)
            }
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        })
        
        dataTask?.taskDescription = requestURL
        if let path = dataTask?.taskDescription {
            self.activeRequests[path] = dataTask
        }
        return .noError
    }
    
    func doFollowInformation(with parameters: [String: Any]?, knowledgeId kid: String, completion block:(([String: Any]?, Error?) -> Void)?) -> KAHTTPRequestStatus {
        let reachable = self.networkReachability()
        if !reachable {
            return .noNetwork
        }
        
        let requestURL = String(format: "%@api/1.1/ka/users/%@/knowledge/%@/follow", KORE_SERVER, self.userId, kid)
        if self.activeRequests[requestURL] != nil {
            return .requestExists
        }
        
        let dataTask = self.POST(urlString: requestURL, parameters:parameters, success:{ (dataTask, responseObject) in
            if let responseObject = responseObject as? [String: Any] {
                DispatchQueue.main.async {
                    block?(responseObject, nil)
                }
            }
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        }, failure:{ (dataTask, responseObject, error) in
            DispatchQueue.main.async {
                block?(nil, error)
            }
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        })
        
        dataTask?.taskDescription = requestURL
        if let path = dataTask?.taskDescription {
            self.activeRequests[path] = dataTask
        }
        return .noError
    }
    
    func doPostArticleComment(with parameters: [String: Any]?, knowledgeId kid: String, completion block:(([String: Any]?, Error?) -> Void)?) -> KAHTTPRequestStatus {
        let reachable = self.networkReachability()
        if !reachable {
            return .noNetwork
        }
        
        let requestURL = String(format: "%@api/1.1/ka/users/%@/knowledge/%@/comment", KORE_SERVER, self.userId, kid)
        if self.activeRequests[requestURL] != nil {
            return .requestExists
        }
        
        let dataTask = self.POST(urlString: requestURL, parameters:parameters, success:{ (dataTask, responseObject) in
            if let responseObject = responseObject as? [String: Any] {
                DispatchQueue.main.async {
                    block?(responseObject, nil)
                }
            }
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        }, failure:{ (dataTask, responseObject, error) in
            DispatchQueue.main.async {
                block?(nil, error)
            }
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        })
        
        dataTask?.taskDescription = requestURL
        if let path = dataTask?.taskDescription {
            self.activeRequests[path] = dataTask
        }
        return .noError
    }
    
    func doGetComments(for knowledgeId: String, offset: Int, timeStamp: Int64, success:((URLSessionDataTask?, Any?) -> Void)?, failure:((URLSessionDataTask?, Any?, Error?) -> Void)?) -> KAHTTPRequestStatus {
        let reachable = self.networkReachability()
        if !reachable {
            return .noNetwork
        }
        
        var requestURL = String(format:"%@api/1.1/ka/users/%@/knowledge/%@/comment", KORE_SERVER, self.userId, knowledgeId)
        if self.activeRequests[requestURL] != nil {
            return .requestExists
        }
        
        let queryParameters: [String: Any] = ["limit": NSNumber(value: 5), "offSetTS": timeStamp, "offSet": offset]
        requestURL = self.addQueryString(to: requestURL, with: queryParameters)
        
        let dataTask = self.GET(urlString: requestURL, parameters:nil, success:{ (dataTask, responseObject) in
            DispatchQueue.main.async {
                success?(dataTask, responseObject)
            }
            
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        }, failure:{ (dataTask, responseObject, error) in
            DispatchQueue.main.async {
                failure? (dataTask, responseObject, error)
            }
            
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        })
        
        dataTask?.taskDescription = requestURL
        if let path = dataTask?.taskDescription {
            self.activeRequests[path] = dataTask
        }
        return .noError
    }
    
    func doGetKnowledge(with offset: Int, timeStamp: Int64, limit: Int, parameters: [String: Any]?,  success:((URLSessionDataTask?, Any?) -> Void)?, failure:((URLSessionDataTask?, Any?, Error?) -> Void)?) -> KAHTTPRequestStatus {
        let reachable = self.networkReachability()
        if !reachable {
            return .noNetwork
        }
        
        var requestURL = String(format:"%@api/1.1/ka/users/%@/knowledge/recent", KORE_SERVER, self.userId)
        if self.activeRequests[requestURL] != nil {
            return .requestExists
        }
        
        let queryParameters: [String: Any] = ["limit": String(format: "\(limit)"), "offSetTS": String(format: "\(timeStamp)"), "offSet": String(format: "\(offset)")]
        requestURL = self.addQueryString(to: requestURL, with: queryParameters)
        
        let dataTask = self.GET(urlString: requestURL, parameters: parameters, success:{ (dataTask, responseObject) in
            DispatchQueue.main.async {
                success?(dataTask, responseObject)
            }
            
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        }, failure:{ (dataTask, responseObject, error) in
            DispatchQueue.main.async {
                failure? (dataTask, responseObject, error)
            }
            
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        })
        
        dataTask?.taskDescription = requestURL
        if let path = dataTask?.taskDescription {
            self.activeRequests[path] = dataTask
        }
        return .noError
    }
    
    func doGetAnnouncementPaging(with offset: Int, timeStamp: Int64, limit: Int, success:((URLSessionDataTask?, Any?) -> Void)?, failure:((URLSessionDataTask?, Any?, Error?) -> Void)?) -> KAHTTPRequestStatus {
        let reachable = self.networkReachability()
        if !reachable {
            return .noNetwork
        }
        
        var requestURL = SDKConfiguration.serverConfig.getAnnouncementsUrl(userId: self.userId)
        if self.activeRequests[requestURL] != nil {
            return .requestExists
        }
        
        let queryParameters: [String: Any] = ["limit": String(format: "\(limit)"), "offSetTS": String(format: "\(timeStamp)"), "offSet": String(format: "\(offset)")]
        requestURL = self.addQueryString(to: requestURL, with: queryParameters)
        
        let dataTask = self.GET(urlString: requestURL, parameters:nil, success:{ (dataTask, responseObject) in
            DispatchQueue.main.async {
                success?(dataTask, responseObject)
            }
            
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        }, failure:{ (dataTask, responseObject, error) in
            DispatchQueue.main.async {
                failure? (dataTask, responseObject, error)
            }
            
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        })
        
        dataTask?.taskDescription = requestURL
        if let path = dataTask?.taskDescription {
            self.activeRequests[path] = dataTask
        }
        return .noError
    }

    
    func doGetPendingKnowledgeInTeam(with teamId: String,  success:((URLSessionDataTask?, Any?) -> Void)?, failure:((URLSessionDataTask?, Any?, Error?) -> Void)?) -> KAHTTPRequestStatus {
        let reachable = self.networkReachability()
        if !reachable {
            return .noNetwork
        }
        let requestURL = SDKConfiguration.serverConfig.getPendingKnowledgeinTeamUrl(userId: self.userId, teamId)
        if self.activeRequests[requestURL] != nil {
            return .requestExists
        }
        
        let dataTask = self.GET(urlString: requestURL, parameters:nil, success:{ (dataTask, responseObject) in
            if let responseObject = responseObject as? Array<[String: Any]> {
                DispatchQueue.main.async {
                    success?(dataTask, responseObject)
                }
            }
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        }, failure:{ (dataTask, responseObject, error) in
            DispatchQueue.main.async {
                failure? (dataTask, responseObject, error)
            }
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        })
        
        dataTask?.taskDescription = requestURL
        if let path = dataTask?.taskDescription {
            self.activeRequests[path] = dataTask
        }
        return .noError
    }
    func doGetResolvePendingKnowledgeInTeam(with teamId: String, knowledgeId: String, success:((URLSessionDataTask?, Any?) -> Void)?, failure:((URLSessionDataTask?, Any?, Error?) -> Void)?) -> KAHTTPRequestStatus {
        let reachable = self.networkReachability()
        if !reachable {
            return .noNetwork
        }
        let requestURL = SDKConfiguration.serverConfig.getResolvePendingKnowledgeinTeamUrl(userId: self.userId, teamId, knowledgeId)
        if self.activeRequests[requestURL] != nil {
            return .requestExists
        }
        
        let dataTask = self.GET(urlString: requestURL, parameters:nil, success:{ (dataTask, responseObject) in
            DispatchQueue.main.async {
                success?(dataTask, responseObject)
            }
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        }, failure:{ (dataTask, responseObject, error) in
            DispatchQueue.main.async {
                failure? (dataTask, responseObject, error)
            }
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        })
        
        dataTask?.taskDescription = requestURL
        if let path = dataTask?.taskDescription {
            self.activeRequests[path] = dataTask
        }
        return .noError
    }
    func doApproveOrRejectPendingKnowledgeInTeam(with teamId: String, params:[String: Any], success:((URLSessionDataTask?, Any?) -> Void)?, failure:((URLSessionDataTask?, Any?, Error?) -> Void)?) -> KAHTTPRequestStatus {
        let reachable = self.networkReachability()
        if !reachable {
            return .noNetwork
        }
        let requestURL = SDKConfiguration.serverConfig.getPendingKnowledgeinTeamUrl(userId: self.userId, teamId)
        if self.activeRequests[requestURL] != nil {
            return .requestExists
        }
        
        let dataTask = self.POST(urlString: requestURL, parameters:params, success:{ (dataTask, responseObject) in
            DispatchQueue.main.async {
                success?(dataTask, responseObject)
            }
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        }, failure:{ (dataTask, responseObject, error) in
            DispatchQueue.main.async {
                failure? (dataTask, responseObject, error)
            }
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        })
        
        dataTask?.taskDescription = requestURL
        if let path = dataTask?.taskDescription {
            self.activeRequests[path] = dataTask
        }
        return .noError
    }
    
    
    func doDeleteComment(with kId: String, comment cId: String, success:((URLSessionDataTask?, Any?) -> Void)?, failure:((URLSessionDataTask?, Any?, Error?) -> Void)?) -> KAHTTPRequestStatus {
        let reachable = self.networkReachability()
        if !reachable {
            return .noNetwork
        }
        
        let requestURL = String(format:"%@api/1.1/ka/users/%@/knowledge/%@/comment/%@", KORE_SERVER, self.userId, kId, cId)
        if self.activeRequests[requestURL] != nil {
            return .requestExists
        }
        
        let dataTask = self.DELETE(urlString: requestURL, parameters:nil, success:{ (dataTask, responseObject) in
            DispatchQueue.main.async {
                success?(dataTask, responseObject)
            }
            
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        }, failure:{ (dataTask, responseObject, error) in
            DispatchQueue.main.async {
                failure? (dataTask, responseObject, error)
            }
            
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        })
        
        dataTask?.taskDescription = requestURL
        if let path = dataTask?.taskDescription {
            self.activeRequests[path] = dataTask
        }
        return .noError
    }
    
    func doDeleteKnowledge(with knowledgeId: String, success:((URLSessionDataTask?, Any?) -> Void)?, failure:((URLSessionDataTask?, Any?, Error?) -> Void)?) -> KAHTTPRequestStatus {
        let reachable = self.networkReachability()
        if !reachable {
            return .noNetwork
        }
        
        let requestURL = String(format:"%@api/1.1/ka/users/%@/knowledge/%@", KORE_SERVER, self.userId, knowledgeId)
        if self.activeRequests[requestURL] != nil {
            return .requestExists
        }
        
        let dataTask = self.DELETE(urlString: requestURL, parameters:nil, success:{ (dataTask, responseObject) in
            DispatchQueue.main.async {
                success?(dataTask, responseObject)
            }
            
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        }, failure:{ (dataTask, responseObject, error) in
            DispatchQueue.main.async {
                failure? (dataTask, responseObject, error)
            }
            
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        })
        
        dataTask?.taskDescription = requestURL
        if let path = dataTask?.taskDescription {
            self.activeRequests[path] = dataTask
        }
        return .noError
    }
    
    
    // MARK: - get company contacts
    func doGetCompanyContacts(with offset: Int, completion block:((Bool, Bool) -> Void)?) -> KAHTTPRequestStatus {
        let reachable = self.networkReachability()
        if !reachable {
            return .noNetwork
        }
        
        let requestURL = KARESTAPIManager.shared.companyContactsUrl(with: self.userId, limit: CONTACTS_FETCH_LIMIT, offset: offset)
        
        if self.activeRequests[requestURL.appendingFormat("/%@", "GET")] != nil {
            return .requestExists
        }
        
        let dataTask = self.GET(urlString: requestURL, parameters:nil, success:{ [weak self] (dataTask, responseObject) in
            if let responseObject = responseObject as? [String: Any], let contacts = responseObject["contacts"] as? Array<[String: Any]> {
                self?.insertCompanyContacts(with: contacts, completion: { (status) in
                    block?(true, status)
                })
            } else {
                block?(false, false)
            }
            
            if let path = dataTask?.taskDescription {
                self?.activeRequests.removeValue(forKey: path)
            }
            }, failure:{ (dataTask, responseObject, error) in
                block?(false, false)
                if let path = dataTask?.taskDescription {
                    self.activeRequests.removeValue(forKey: path)
                }
        })
        if let path = dataTask?.taskDescription {
            self.activeRequests[path] = dataTask
        }
        return .noError
    }
    
    func doGetCompanyContactsActivity(with block:((Bool) -> Void)?) -> KAHTTPRequestStatus {
        let reachable = self.networkReachability()
        if !reachable {
            return .noNetwork
        }
        
        let requestURL = String(format:"%@api/1.1/ka/users/%@/activity", KORE_SERVER, self.userId)
        if self.activeRequests[requestURL.appendingFormat("/%@","GET")] != nil {
            return .requestExists
        }
        
        let dataTask = self.GET(urlString: requestURL, parameters:nil, success:{ (dataTask, responseObject) in
            block?(true)
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        }, failure:{ (dataTask, responseObject, error) in
            block?(false)
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        })
        if let path = dataTask?.taskDescription {
            self.activeRequests[path] = dataTask
        }
        return .noError
    }
    
    // MARK: - get/edit profile
    public func doUpdateOnboarding(status: Bool, completion block:((Bool) -> Void)?) -> KAHTTPRequestStatus {
        let reachable = self.networkReachability()
        if !reachable {
            return .noNetwork
        }
        
        let urlString = String(format:"%@api/ka/users/%@/profile/onboarding", KORE_SERVER, self.userId)
        if self.activeRequests[urlString.appendingFormat("/%@", "PUT")] != nil {
            return .requestExists
        }
        
        let parameters = ["onboarding": ["ios": NSNumber(value: status)]]
        let dataTask = self.PUT(urlString: urlString, parameters: parameters, success: { (dataTask, responseObject) in
            DispatchQueue.main.async {
                block?(true)
            }
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        }) { (dataTask, responseObject, error) in
            DispatchQueue.main.async {
                block?(false)
            }
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        }
        dataTask?.taskDescription = urlString
        if let path = dataTask?.taskDescription {
            self.activeRequests[path] = dataTask
        }
        return .noError
    }
    
    public func doGetOnboardingTour(completion block:((Bool, KAOnboardingTour?) -> Void)?) -> KAHTTPRequestStatus {
        let reachable = self.networkReachability()
        if !reachable {
            return .noNetwork
        }
        
        let urlString = String(format:"%@api/1.1/ka/users/%@/onboarding/tour?channel=ios", KORE_SERVER, userId)
        if self.activeRequests[urlString.appendingFormat("/%@", "GET")] != nil {
            return .requestExists
        }
        
        let dataTask = GET(urlString: urlString, parameters: nil, success: { (dataTask, responseObject) in
            if let responseObject = responseObject as? [String: Any],
                let data = try? JSONSerialization.data(withJSONObject: responseObject, options: .prettyPrinted) {
                let jsonDecoder = JSONDecoder()
                let tour = try? jsonDecoder.decode(KAOnboardingTour.self, from: data)
                
                DispatchQueue.main.async {
                    block?(true, tour)
                }
            } else {
                DispatchQueue.main.async {
                    block?(false, nil)
                }
            }
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        }) { (dataTask, responseObject, error) in
            DispatchQueue.main.async {
                block?(false, nil)
            }
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        }
        dataTask?.taskDescription = urlString
        if let path = dataTask?.taskDescription {
            self.activeRequests[path] = dataTask
        }
        return .noError
    }
    
    public func doGetProfile(with block:((Bool, Any?) -> Void)?) -> KAHTTPRequestStatus {
        let reachable = self.networkReachability()
        if !reachable {
            return .noNetwork
        }
        
        let urlString = String(format:"%@api/1.1/ka/users/%@/profile", KORE_SERVER, self.userId)
        if self.activeRequests[urlString.appendingFormat("/%@", "GET")] != nil {
            return .requestExists
        }
        
        let dataTask = self.GET(urlString: urlString, parameters: nil, success: { (dataTask, responseObject) in
            DispatchQueue.main.async {
                block?(true, responseObject)
            }
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        }) { (dataTask, responseObject, error) in
            DispatchQueue.main.async {
                block?(false, nil)
            }
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        }
        dataTask?.taskDescription = urlString
        if let path = dataTask?.taskDescription {
            self.activeRequests[path] = dataTask
        }
        return .noError
    }
    
    public func doEditProfile(with parameters: [String: Any], completion block:((Bool) -> Void)?) -> KAHTTPRequestStatus {
        let reachable = self.networkReachability()
        if !reachable {
            return .noNetwork
        }
        
        let urlString = String(format:"%@api/1.1/ka/users/%@/profile", KORE_SERVER, self.userId)
        if self.activeRequests[urlString.appendingFormat("/%@", "PUT")] != nil {
            return .requestExists
        }
        
        let dataTask = self.PUT(urlString: urlString, parameters: parameters, success: { (dataTask, responseObject) in
            DispatchQueue.main.async {
                block?(true)
            }
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        }) { (dataTask, responseObject, error) in
            DispatchQueue.main.async {
                block?(false)
            }
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        }
        dataTask?.taskDescription = urlString
        if let path = dataTask?.taskDescription {
            self.activeRequests[path] = dataTask
        }
        return .noError
    }
    
    public func doRemoveProfileImage(completion block:((Bool) -> Void)?) -> KAHTTPRequestStatus {
        let reachable = self.networkReachability()
        if !reachable {
            return .noNetwork
        }
         
        let parameters: [String: Any] = ["accountInfo": ["profImage": "no-avatar"]];
        let urlString = String(format:"%@api/1.1/ka/users/%@/profile", KORE_SERVER, userId)
        if let _ = activeRequests[urlString.appendingFormat("/%@", "PUT")] {
            return .requestExists
        }
        
        let dataTask = PUT(urlString: urlString, parameters: parameters, success:{ (dataTask, responseObject) in
            block?(true)
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        }, failure:{ (dataTask, responseObject, error) in
            block?(false)
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        })
        if let path = dataTask?.taskDescription {
            activeRequests[path] = dataTask
        }
        return .noError
    }
}

// MARK: - Meeting Type Requests
extension KAAccount {
    // MARK: - get all meeting types request
    func doGetAllMeetingTypes(with block:(((Bool, [KAWebMeeting]?, [KAPhoneMeeting]?, [KAMeetingRoomData]? ,String?, String?, String?) -> Void)?)) -> KAHTTPRequestStatus {
        let reachable = self.networkReachability()
        if !reachable {
            return .noNetwork
        }
        
        let requestURL = KARESTAPIManager.shared.meetingTypesUrl(with: self.userId)
        if self.activeRequests[requestURL.appendingFormat("/%@","GET")] != nil {
            return .requestExists
        }
        
        let dataTask = self.GET(urlString: requestURL, parameters: nil, success:{ (dataTask, responseObject) in
            guard let dictionary = responseObject as? [String: Any] else {
                DispatchQueue.main.async {
                    block?(false, nil, nil, nil, nil, nil, nil)
                }
                
                if let path = dataTask?.taskDescription {
                    self.activeRequests.removeValue(forKey: path)
                }
                return
            }
            let web = dictionary["web"] as? Array<[String: Any]>
            let phone = dictionary["phone"] as? Array<[String: Any]>
            let rooms = dictionary["rooms"] as? Array<[String: Any]>
            let defaultWeb = dictionary["defaultWeb"] as? String
            let defaultPhone = dictionary["defaultPhone"] as? String
            let preset = dictionary["preset"] as? String
            let webMeetings = try? MTLJSONAdapter.models(of: KAWebMeeting.self, fromJSONArray: web) as! [KAWebMeeting]
         let jsonDecoder = JSONDecoder()
         guard let data = try? JSONSerialization.data(withJSONObject: phone, options: .prettyPrinted),
             let phoneMeetings = try? jsonDecoder.decode([KAPhoneMeeting].self, from: data) else  {
                return
            }
            guard let dataroom = try? JSONSerialization.data(withJSONObject: rooms ?? [], options: .prettyPrinted),
                let roomsDecodable = try? jsonDecoder.decode([KAMeetingRoomData].self, from: dataroom) else  {
                   return
               }

            DispatchQueue.main.async {
                block?(false, webMeetings, phoneMeetings, roomsDecodable, defaultWeb, defaultPhone, preset)
            }
            
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        }, failure:{ (dataTask, responseObject, error) in
            DispatchQueue.main.async {
                block?(false, nil, nil, nil, nil, nil, nil)
            }
            
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        })
        if let path = dataTask?.taskDescription {
            self.activeRequests[path] = dataTask
        }
        return .noError
    }
    
    // MARK: - web meeting type requests
    func doAddWebMeetingType(_ webMeeting: KAWebMeeting, completion block:((Bool, Any?) -> Void)?) -> KAHTTPRequestStatus {
        let reachable = self.networkReachability()
        if !reachable {
            return .noNetwork
        }
        
        let requestURL = KARESTAPIManager.shared.webTypeMeetingUrl(with: self.userId)
        if self.activeRequests[requestURL.appendingFormat("/%@", "POST")] != nil {
            return .requestExists
        }
        
        guard var parameters = try? MTLJSONAdapter.jsonDictionary(fromModel: webMeeting) as? [String: Any] else {
            block?(false, nil)
            return .requestExists
        }
        if let meetingId = parameters?["meetingId"] as? String, meetingId.count <= 0 {
            parameters?.removeValue(forKey: "meetingId")
        }
        
        let dataTask = self.POST(urlString: requestURL, parameters: parameters, success:{ (dataTask, responseObject) in
            block?(true, responseObject)
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        }, failure:{ (dataTask, responseObject, error) in
            block?(false, nil)
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        })
        if let path = dataTask?.taskDescription {
            self.activeRequests[path] = dataTask
        }
        return .noError
    }
    
    func doEditWebMeetingType(_ webMeeting: KAWebMeeting, completion block:((Bool) -> Void)?) -> KAHTTPRequestStatus {
        let reachable = self.networkReachability()
        if !reachable {
            return .noNetwork
        }
        
        guard let parameters = try? MTLJSONAdapter.jsonDictionary(fromModel: webMeeting) as? [String: Any], let webMeetingId = webMeeting.meetingId else {
            block?(false)
            return .requestExists
        }
        
        let requestURL = KARESTAPIManager.shared.webTypeMeetingUrl(with: self.userId, web: webMeetingId)
        if self.activeRequests[requestURL.appendingFormat("/%@", "PUT")] != nil {
            return .requestExists
        }
        
        let dataTask = self.PUT(urlString: requestURL, parameters: parameters, success:{ (dataTask, responseObject) in
            block?(true)
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        }, failure:{ (dataTask, responseObject, error) in
            block?(false)
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        })
        if let path = dataTask?.taskDescription {
            self.activeRequests[path] = dataTask
        }
        return .noError
    }
    
    func doDeleteWebMeetingType(_ webMeeting: KAWebMeeting, completion block:((Bool) -> Void)?) -> KAHTTPRequestStatus {
        let reachable = self.networkReachability()
        if !reachable {
            return .noNetwork
        }
        
        guard let webMeetingId = webMeeting.meetingId, webMeetingId.count > 0 else {
            block?(false)
            return .requestExists
        }
        
        let requestURL = KARESTAPIManager.shared.webTypeMeetingUrl(with: self.userId, web: webMeetingId)
        if self.activeRequests[requestURL.appendingFormat("/%@", "DELETE")] != nil {
            return .requestExists
        }
        
        let dataTask = self.DELETE(urlString: requestURL, parameters: nil, success:{ (dataTask, responseObject) in
            block?(true)
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        }, failure:{ (dataTask, responseObject, error) in
            block?(false)
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        })
        if let path = dataTask?.taskDescription {
            self.activeRequests[path] = dataTask
        }
        return .noError
    }
    
    func doMakeWebMeetingType(_ webMeeting: KAWebMeeting, completion block:((Bool) -> Void)?) -> KAHTTPRequestStatus {
        let reachable = self.networkReachability()
        if !reachable {
            return .noNetwork
        }
        
        let requestURL = KARESTAPIManager.shared.defaultWebMeetingTypeUrl(with: self.userId)
        if self.activeRequests[requestURL.appendingFormat("/%@", "PUT")] != nil {
            return .requestExists
        }
        
        guard let meetingId = webMeeting.meetingId, meetingId.count > 0 else {
            block?(false)
            return .requestExists
        }
        
        let parameters = ["id": meetingId]
        let dataTask = self.PUT(urlString: requestURL, parameters: parameters, success:{ (dataTask, responseObject) in
            block?(true)
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        }, failure:{ (dataTask, responseObject, error) in
            block?(false)
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        })
        if let path = dataTask?.taskDescription {
            self.activeRequests[path] = dataTask
        }
        return .noError
    }
    
    // MARK: - phone meeting type requests
    func doAddPhoneMeetingType(_ phoneMeeting: KAPhoneMeeting, completion block:((Bool, Any?) -> Void)?) -> KAHTTPRequestStatus {
        let reachable = self.networkReachability()
        if !reachable {
            return .noNetwork
        }
        
        let requestURL = KARESTAPIManager.shared.phoneTypeMeetingUrl(with: self.userId)
        if self.activeRequests[requestURL.appendingFormat("/%@", "POST")] != nil {
            return .requestExists
        }
        
        
        guard let parametersData = try? JSONEncoder().encode(phoneMeeting) else {
            block?(false, nil)
            return .requestExists
        }
        
        guard var parameters = try? JSONSerialization.jsonObject(with: parametersData, options: []) as? [String: Any] else {
            block?(false, nil)
            return .requestExists
        }

        if let meetingId = parameters?["meetingId"] as? String, meetingId.count <= 0 {
            parameters?.removeValue(forKey: "meetingId")
        }
        let dataTask = self.POST(urlString: requestURL, parameters: parameters, success:{ (dataTask, responseObject) in
            block?(true, responseObject)
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        }, failure:{ (dataTask, responseObject, error) in
            block?(false, nil)
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        })
        if let path = dataTask?.taskDescription {
            self.activeRequests[path] = dataTask
        }
        return .noError
    }
    
    // MARK: - phone meeting type requests
    func doAddMeetingRoom(_ meetingRoom: KAMeetingRoomData, completion block:((Bool, Any?) -> Void)?) -> KAHTTPRequestStatus {
        let reachable = self.networkReachability()
        if !reachable {
            return .noNetwork
        }
        
        let requestURL = KARESTAPIManager.shared.roomTypeMeetingUrl(with: self.userId)
        if self.activeRequests[requestURL.appendingFormat("/%@", "POST")] != nil {
            return .requestExists
        }
        
        
        guard let parametersData = try? JSONEncoder().encode(meetingRoom) else {
            block?(false, nil)
            return .requestExists
        }
        
        guard var parameters = try? JSONSerialization.jsonObject(with: parametersData, options: []) as? [String: Any] else {
            block?(false, nil)
            return .requestExists
        }

        if let meetingId = parameters?["meetingId"] as? String, meetingId.count <= 0 {
            parameters?.removeValue(forKey: "meetingId")
        }
        let dataTask = self.POST(urlString: requestURL, parameters: parameters, success:{ (dataTask, responseObject) in
            block?(true, responseObject)
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        }, failure:{ (dataTask, responseObject, error) in
            block?(false, responseObject)
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        })
        if let path = dataTask?.taskDescription {
            self.activeRequests[path] = dataTask
        }
        return .noError
    }

    func doEditRoomMeetingType(_ roomMeeting: KAMeetingRoomData, completion block:((Bool, Any?) -> Void)?) -> KAHTTPRequestStatus {
        let reachable = self.networkReachability()
        if !reachable {
            return .noNetwork
        }
        
        guard let parametersData = try? JSONEncoder().encode(roomMeeting), let meetingId = roomMeeting.id else {
            block?(false, nil)
            return .requestExists
        }
        
        guard let parameters = try? JSONSerialization.jsonObject(with: parametersData, options: []) as? [String: Any] else {
            block?(false, nil)
            return .requestExists
        }

        let requestURL = KARESTAPIManager.shared.roomTypeMeetingUrl(with: self.userId, room: meetingId)
        if self.activeRequests[requestURL.appendingFormat("/%@", "PUT")] != nil {
            return .requestExists
        }
        
        let dataTask = self.PUT(urlString: requestURL, parameters: parameters, success:{ (dataTask, responseObject) in
            block?(true, responseObject)
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        }, failure:{ (dataTask, responseObject, error) in
            block?(false, responseObject)
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        })
        if let path = dataTask?.taskDescription {
            self.activeRequests[path] = dataTask
        }
        return .noError
    }
    
    func doDeleteRoomMeetingType(_ roomMeeting: KAMeetingRoomData, completion block:((Bool) -> Void)?) -> KAHTTPRequestStatus {
        let reachable = self.networkReachability()
        if !reachable {
            return .noNetwork
        }
        
        guard let roomMeetingId = roomMeeting.id, roomMeetingId.count > 0 else {
            block?(false)
            return .requestExists
        }
        
        let requestURL = KARESTAPIManager.shared.roomTypeMeetingUrl(with: self.userId, room: roomMeetingId)
        if self.activeRequests[requestURL.appendingFormat("/%@", "DELETE")] != nil {
            return .requestExists
        }
        
        let dataTask = self.DELETE(urlString: requestURL, parameters: nil, success:{ (dataTask, responseObject) in
            block?(true)
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        }, failure:{ (dataTask, responseObject, error) in
            block?(false)
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        })
        if let path = dataTask?.taskDescription {
            self.activeRequests[path] = dataTask
        }
        return .noError
    }

    
    func doEditPhoneMeetingType(_ phoneMeeting: KAPhoneMeeting, completion block:((Bool) -> Void)?) -> KAHTTPRequestStatus {
        let reachable = self.networkReachability()
        if !reachable {
            return .noNetwork
        }
        

        guard let parametersData = try? JSONEncoder().encode(phoneMeeting), let meetingId = phoneMeeting.meetingId else {
            block?(false)
            return .requestExists
        }
        
        guard let parameters = try? JSONSerialization.jsonObject(with: parametersData, options: []) as? [String: Any] else {
            block?(false)
            return .requestExists
        }


        let requestURL = KARESTAPIManager.shared.phoneTypeMeetingUrl(with: self.userId, phone: meetingId)
        if self.activeRequests[requestURL.appendingFormat("/%@", "PUT")] != nil {
            return .requestExists
        }
        
        let dataTask = self.PUT(urlString: requestURL, parameters: parameters, success:{ (dataTask, responseObject) in
            block?(true)
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        }, failure:{ (dataTask, responseObject, error) in
            block?(false)
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        })
        if let path = dataTask?.taskDescription {
            self.activeRequests[path] = dataTask
        }
        return .noError
    }
    
    func doDeletePhoneMeetingType(_ phoneMeeting: KAPhoneMeeting, completion block:((Bool) -> Void)?) -> KAHTTPRequestStatus {
        let reachable = self.networkReachability()
        if !reachable {
            return .noNetwork
        }
        
        guard let phoneMeetingId = phoneMeeting.meetingId, phoneMeetingId.count > 0 else {
            block?(false)
            return .requestExists
        }
        
        let requestURL = KARESTAPIManager.shared.phoneTypeMeetingUrl(with: self.userId, phone: phoneMeetingId)
        if self.activeRequests[requestURL.appendingFormat("/%@", "DELETE")] != nil {
            return .requestExists
        }
        
        let dataTask = self.DELETE(urlString: requestURL, parameters: nil, success:{ (dataTask, responseObject) in
            block?(true)
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        }, failure:{ (dataTask, responseObject, error) in
            block?(false)
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        })
        if let path = dataTask?.taskDescription {
            self.activeRequests[path] = dataTask
        }
        return .noError
    }
    
    func doMakePhoneMeetingType(_ phoneMeeting: KAPhoneMeeting, completion block:((Bool) -> Void)?) -> KAHTTPRequestStatus {
        let reachable = self.networkReachability()
        if !reachable {
            return .noNetwork
        }
        
        let requestURL = KARESTAPIManager.shared.defaultPhoneTypeMeetingTypeUrl(with: self.userId)
        if self.activeRequests[requestURL.appendingFormat("/%@", "PUT")] != nil {
            return .requestExists
        }
        
        guard let meetingId = phoneMeeting.meetingId, meetingId.count > 0 else {
            block?(false)
            return .requestExists
        }
        
        let parameters = ["id": meetingId]
        let dataTask = self.PUT(urlString: requestURL, parameters: parameters, success:{ (dataTask, responseObject) in
            block?(true)
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        }, failure:{ (dataTask, responseObject, error) in
            block?(false)
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        })
        if let path = dataTask?.taskDescription {
            self.activeRequests[path] = dataTask
        }
        return .noError
    }
}

// MARK: - Notifications Requests
extension KAAccount {
    // MARK: - get all notifications  request
    func doGetNotifications(with block:(((Bool) -> Void)?)) -> KAHTTPRequestStatus {
        let reachable = self.networkReachability()
        if !reachable {
            return .noNetwork
        }
        
        let requestURL = KARESTAPIManager.shared.notificationsUrl(with: self.userId)
        if self.activeRequests[requestURL.appendingFormat("/%@","GET")] != nil {
            return .requestExists
        }
        
        let dataTask = self.GET(urlString: requestURL, parameters: nil, success:{ [weak self] (dataTask, responseObject) in
            guard let dictionary = responseObject as? [String: Any] else {
                DispatchQueue.main.async {
                    block?(false)
                }
                
                if let path = dataTask?.taskDescription {
                    self?.activeRequests.removeValue(forKey: path)
                }
                return
            }
            if let nStats = dictionary["nStats"] as? [String: Any]{
                self?.updateUserStats(nStats)
            }
            self?.persistentStoreManager.insertOrUpdateAllNotifications(with: dictionary, completion: {
                if let path = dataTask?.taskDescription {
                    self?.activeRequests.removeValue(forKey: path)
                }
                
                DispatchQueue.main.async {
                    block?(true)
                }
            })
            }, failure:{ [weak self] (dataTask, responseObject, error) in
                DispatchQueue.main.async {
                    block?(false)
                }
                
                if let path = dataTask?.taskDescription {
                    self?.activeRequests.removeValue(forKey: path)
                }
        })
        if let path = dataTask?.taskDescription {
            self.activeRequests[path] = dataTask
        }
        return .noError
    }
    
    func doMarkAsReadNotifications(_ params: [String: Any],success:((URLSessionDataTask?, Any?) -> Void)?, failure:((URLSessionDataTask?, Any?, Error?) -> Void)?) -> KAHTTPRequestStatus {
        let reachable = self.networkReachability()
        if !reachable {
            return .noNetwork
        }
        
        let requestURL = KARESTAPIManager.shared.notificationsUpdateUrl(with: self.userId)
        if self.activeRequests[requestURL] != nil {
            return .requestExists
        }
        
        let dataTask = self.PUT(urlString: requestURL, parameters: nil, success:{(dataTask, responseObject) in
            DispatchQueue.main.async {
                success?(dataTask, responseObject)
            }
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        }, failure:{ [weak self] (dataTask, responseObject, error) in
            DispatchQueue.main.async {
                failure? (dataTask, responseObject, error)
            }
            if let path = dataTask?.taskDescription {
                self?.activeRequests.removeValue(forKey: path)
            }
        })
        if let path = dataTask?.taskDescription {
            self.activeRequests[path] = dataTask
        }
        return .noError
    }
    
    func doGetNotificationUpdates(with offset: Int, completion block:((Bool, Bool) -> Void)?) -> KAHTTPRequestStatus {
        let reachable = self.networkReachability()
        if !reachable {
            return .noNetwork
        }
        
        let requestURL = KARESTAPIManager.shared.notificationsUpdateUrl(with: self.userId, limit: NOTFICATION_FETCH_LIMIT, offset: offset)
        
        if self.activeRequests[requestURL.appendingFormat("/%@", "GET")] != nil {
            return .requestExists
        }
        
        let dataTask = self.GET(urlString: requestURL, parameters: nil, success:{ [weak self] (dataTask, responseObject) in
            var needLoadMore = true
            guard let dictionary = responseObject as? [String: Any], let updates = dictionary["updates"] as? Array<[String: Any]> else {
                DispatchQueue.main.async {
                    block?(false, needLoadMore)
                }
                
                if let path = dataTask?.taskDescription {
                    self?.activeRequests.removeValue(forKey: path)
                }
                return
            }
            
            if let limit = self?.NOTFICATION_FETCH_LIMIT, updates.count < limit {
                needLoadMore = false
            }
            self?.persistentStoreManager.insertOrUpdateAllNotifications(with: dictionary, completion: {
                if let path = dataTask?.taskDescription {
                    self?.activeRequests.removeValue(forKey: path)
                }
                
                DispatchQueue.main.async {
                    block?(true, needLoadMore)
                }
            })
            }, failure:{ (dataTask, responseObject, error) in
                block?(false, true)
                if let path = dataTask?.taskDescription {
                    self.activeRequests.removeValue(forKey: path)
                }
        })
        if let path = dataTask?.taskDescription {
            self.activeRequests[path] = dataTask
        }
        return .noError
    }
    
    func doGetNotificationActions(with offset: Int, completion block:((Bool, Bool) -> Void)?) -> KAHTTPRequestStatus {
        let reachable = self.networkReachability()
        if !reachable {
            return .noNetwork
        }
        
        let requestURL = KARESTAPIManager.shared.notificationsActionsUrl(with: self.userId, limit: NOTFICATION_FETCH_LIMIT, offset: offset)
        
        if self.activeRequests[requestURL.appendingFormat("/%@", "GET")] != nil {
            return .requestExists
        }
        
        let dataTask = self.GET(urlString: requestURL, parameters: nil, success:{ [weak self] (dataTask, responseObject) in
            var needLoadMore = true
            guard let dictionary = responseObject as? [String: Any], let actions = dictionary["actions"] as? Array<[String: Any]> else {
                DispatchQueue.main.async {
                    block?(false, needLoadMore)
                }
                
                if let path = dataTask?.taskDescription {
                    self?.activeRequests.removeValue(forKey: path)
                }
                return
            }
            
            if let limit = self?.NOTFICATION_FETCH_LIMIT, actions.count < limit {
                needLoadMore = false
            }
            self?.persistentStoreManager.insertOrUpdateAllNotifications(with: dictionary, completion: {
                if let path = dataTask?.taskDescription {
                    self?.activeRequests.removeValue(forKey: path)
                }
                
                DispatchQueue.main.async {
                    block?(true, needLoadMore)
                }
            })
            }, failure:{ (dataTask, responseObject, error) in
                block?(false, true)
                if let path = dataTask?.taskDescription {
                    self.activeRequests.removeValue(forKey: path)
                }
        })
        if let path = dataTask?.taskDescription {
            self.activeRequests[path] = dataTask
        }
        return .noError
    }
}

// MARK: - get tasks
extension KAAccount {
    func doGetTasks(_ urlString: String, success:((URLSessionDataTask?, Any?) -> Void)?, failure:((URLSessionDataTask?, Any?, Error?) -> Void)?) -> KAHTTPRequestStatus {
        let reachable = self.networkReachability()
        if !reachable {
            return .noNetwork
        }
        
        if self.activeRequests[urlString] != nil {
            return .requestExists
        }
        
        let dataTask = self.GET(urlString: urlString, parameters: nil, success: { (dataTask, responseObject) in
            DispatchQueue.main.async {
                success?(dataTask, responseObject)
            }
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        }) { (dataTask, responseObject, error) in
            DispatchQueue.main.async {
                failure? (dataTask, responseObject, error)
            }
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        }
        dataTask?.taskDescription = urlString
        if let path = dataTask?.taskDescription {
            self.activeRequests[path] = dataTask
        }
        return .noError
    }
}

// MARK: - Help phrases
extension KAAccount {
    
    func doGetAskPhrases(with block:((Bool, Any?) -> Void)?) -> KAHTTPRequestStatus {
        let reachable = self.networkReachability()
        if !reachable {
            return .noNetwork
        }
        
        let requestURL = KARESTAPIManager.shared.askPhrasesUrl(with: self.userId, server: KORE_SERVER)
        if self.activeRequests[requestURL.appendingFormat("/%@", "GET")] != nil {
            return .requestExists
        }
        
        let dataTask = self.GET(urlString: requestURL, parameters: nil, success: { [weak self] (dataTask, responseObject) in
            if let responseObject = responseObject as? [[String: Any]],
                let data = try? JSONSerialization.data(withJSONObject: responseObject, options: .prettyPrinted) {
                let jsonDecoder = JSONDecoder()
                let allPhrases = try? jsonDecoder.decode([AskPhrases].self, from: data)
                self?.askPhrases = allPhrases

                DispatchQueue.main.async {
                    block?(true, responseObject)
                }
            } else {
                DispatchQueue.main.async {
                    block?(false, responseObject)
                }
            }
            
            if let path = dataTask?.taskDescription {
                self?.activeRequests.removeValue(forKey: path)
            }
        }) { [weak self] (dataTask, responseObject, error) in
            DispatchQueue.main.async {
                block?(false, error)
            }
            if let path = dataTask?.taskDescription {
                self?.activeRequests.removeValue(forKey: path)
            }
        }
        dataTask?.taskDescription = requestURL
        if let path = dataTask?.taskDescription {
            self.activeRequests[path] = dataTask
        }
        return .noError
    }
    
    func doGetHelpPhrases(with block:((Bool, Any?) -> Void)?) -> KAHTTPRequestStatus {
        let reachable = self.networkReachability()
        if !reachable {
            return .noNetwork
        }
        
        let requestURL = KARESTAPIManager.shared.helpPhrasesUrl(with: self.userId, server: KORE_SERVER)
        if self.activeRequests[requestURL.appendingFormat("/%@", "GET")] != nil {
            return .requestExists
        }
        
        let dataTask = self.GET(urlString: requestURL, parameters: nil, success: { [weak self] (dataTask, responseObject) in
            if let responseObject = responseObject as? [String: Any],
                let data = try? JSONSerialization.data(withJSONObject: responseObject, options: .prettyPrinted) {
                let jsonDecoder = JSONDecoder()
                let koraHelp = try? jsonDecoder.decode(KoraHelp.self, from: data)
                self?.koraHelp = koraHelp
                
                DispatchQueue.main.async {
                    block?(true, responseObject)
                }
            } else {
                DispatchQueue.main.async {
                    block?(false, responseObject)
                }
            }
            
            if let path = dataTask?.taskDescription {
                self?.activeRequests.removeValue(forKey: path)
            }
        }) { [weak self] (dataTask, responseObject, error) in
            DispatchQueue.main.async {
                block?(false, error)
            }
            if let path = dataTask?.taskDescription {
                self?.activeRequests.removeValue(forKey: path)
            }
        }
        dataTask?.taskDescription = requestURL
        if let path = dataTask?.taskDescription {
            self.activeRequests[path] = dataTask
        }
        return .noError
    }
}

// MARK: - export contacts
extension KAAccount {
    func doExportContacts(with parameters: Any?, completion block:((Bool, Int64?, Error?) -> Void)?) -> KAHTTPRequestStatus {
        let reachable = self.networkReachability()
        if !reachable {
            return .noNetwork
        }
        
        let deviceId = UIDevice.current.identifierForVendor?.uuidString ?? ""
        let requestURL = String(format:"%@api/1.1/ka/users/%@/devicecontacts?deviceId=%@", KORE_SERVER, userId, deviceId)
        if activeRequests[requestURL] != nil {
            return .requestExists
        }
        
        let dataTask = self.POST(urlString: requestURL, parameters: parameters, success:{ (dataTask, responseObject) in
            var status = false
            var lastModified: Int64?
            if let responseObject = responseObject as? [String: Any], let lastUpdatedTimeStamp = responseObject["lastUpdatedTimeStamp"] as? Int64 {
                lastModified = lastUpdatedTimeStamp
                status = true
            }
            DispatchQueue.main.async {
                block?(status, lastModified, nil)
            }
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        }, failure:{ (dataTask, responseObject, error) in
            DispatchQueue.main.async {
                block?(false, nil, error)
            }
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        })
        
        dataTask?.taskDescription = requestURL
        if let path = dataTask?.taskDescription {
            self.activeRequests[path] = dataTask
        }
        return .noError
    }
}

extension KAAccount {
    func checkNetwork()-> KAHTTPRequestStatus{
        let reachable = self.networkReachability()
        if !reachable {
            return .noNetwork
        }
        return .noError
    }

    func checkRequestStatus()-> KAHTTPRequestStatus{
        let requestURL = KARESTAPIManager.shared.helpPhrasesUrl(with: self.userId, server: KORE_SERVER)
        if self.activeRequests[requestURL.appendingFormat("/%@", "GET")] != nil {
            return .requestExists
        }
        return .noError
    }
    
    func doGetMeetingNotesDraft(userId: String, meetingId: String, eventId: String, success:((URLSessionDataTask?, Any?) -> Void)? , failure:((URLSessionDataTask?, Any?, Error?) -> Void)? ) -> KAHTTPRequestStatus {
        if checkNetwork() == .noNetwork{
            return .noNetwork
        }
        if checkRequestStatus() == .requestExists{
            return .requestExists
        }

        let requestURL = KARESTAPIManager.shared.meetingNotesDraftUrl(userId: userId, meetingId: meetingId, eventId: eventId, server: KORE_SERVER)
        let dataTask = self.GET(urlString: requestURL, parameters: nil, success: { (dataTask, responseObject) in
            DispatchQueue.main.async {
                success?(dataTask, responseObject)
            }

            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        },
        failure: { (dataTask, responseObject, error) in
            DispatchQueue.main.async {
                failure? (dataTask, responseObject, error)
            }

            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        })

        dataTask?.taskDescription = requestURL
        if let path = dataTask?.taskDescription {
            self.activeRequests[path] = dataTask
        }
        return .noError
    }

    public func resolveCallFollowup(userId: String, meetingId: String, eventId: String, success:((URLSessionDataTask?, Any?) -> Void)? , failure:((URLSessionDataTask?, Any?, Error?) -> Void)? ) -> KAHTTPRequestStatus {
        if checkNetwork() == .noNetwork{
            return .noNetwork
        }
        if checkRequestStatus() == .requestExists{
            return .requestExists
        }

        let requestURL = KARESTAPIManager.shared.followupMeetingResolve(userId: userId, meetingId: meetingId, server: KORE_SERVER)
        let dataTask = self.GET(urlString: requestURL, parameters: nil, success: { (dataTask, responseObject) in
            DispatchQueue.main.async {
                success?(dataTask, responseObject)
            }

            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        },
        failure: { (dataTask, responseObject, error) in
            DispatchQueue.main.async {
                failure? (dataTask, responseObject, error)
            }

            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        })

        dataTask?.taskDescription = requestURL
        if let path = dataTask?.taskDescription {
            self.activeRequests[path] = dataTask
        }
        return .noError
    }

    func reminderCall(userId: String, meetingId: String, eventId: String, success:((URLSessionDataTask?, Any?) -> Void)? , failure:((URLSessionDataTask?, Any?, Error?) -> Void)? ) -> KAHTTPRequestStatus {
        if checkNetwork() == .noNetwork{
            return .noNetwork
        }
        if checkRequestStatus() == .requestExists{
            return .requestExists
        }

        let requestURL = KARESTAPIManager.shared.followupMeetingReminder(userId: userId, meetingId: meetingId, server: KORE_SERVER)
        let dataTask = self.POST(urlString: requestURL, parameters: nil, success: { (dataTask, responseObject) in
            DispatchQueue.main.async {
                success?(dataTask, responseObject)
            }

            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        },
        failure: { (dataTask, responseObject, error) in
            DispatchQueue.main.async {
                failure? (dataTask, responseObject, error)
            }

            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        })

        dataTask?.taskDescription = requestURL
        if let path = dataTask?.taskDescription {
            self.activeRequests[path] = dataTask
        }
        return .noError
    }

    
    func cancelMeetingFollowup(userId: String, meetingId: String, eventId: String, success:((URLSessionDataTask?, Any?) -> Void)? , failure:((URLSessionDataTask?, Any?, Error?) -> Void)? ) -> KAHTTPRequestStatus {
        if checkNetwork() == .noNetwork{
            return .noNetwork
        }
        if checkRequestStatus() == .requestExists{
            return .requestExists
        }

        let requestURL = KARESTAPIManager.shared.followupMeetingDelete(userId: userId, meetingId: meetingId, server: KORE_SERVER)
        let dataTask = self.DELETE(urlString: requestURL, parameters: nil, success: { (dataTask, responseObject) in
            DispatchQueue.main.async {
                success?(dataTask, responseObject)
            }

            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        },
        failure: { (dataTask, responseObject, error) in
            DispatchQueue.main.async {
                failure? (dataTask, responseObject, error)
            }

            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        })

        dataTask?.taskDescription = requestURL
        if let path = dataTask?.taskDescription {
            self.activeRequests[path] = dataTask
        }
        return .noError
    }

    func scheduleCallFollowup(userId: String, meetingId: String, eventId: String, success:((URLSessionDataTask?, Any?) -> Void)? , failure:((URLSessionDataTask?, Any?, Error?) -> Void)? ) -> KAHTTPRequestStatus {
        if checkNetwork() == .noNetwork{
            return .noNetwork
        }
        if checkRequestStatus() == .requestExists{
            return .requestExists
        }

        let requestURL = KARESTAPIManager.shared.followupMeetingResolve(userId: userId, meetingId: meetingId, server: KORE_SERVER)
        let dataTask = self.GET(urlString: requestURL, parameters: nil, success: { (dataTask, responseObject) in
            DispatchQueue.main.async {
                success?(dataTask, responseObject)
            }

            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        },
        failure: { (dataTask, responseObject, error) in
            DispatchQueue.main.async {
                failure? (dataTask, responseObject, error)
            }

            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        })

        dataTask?.taskDescription = requestURL
        if let path = dataTask?.taskDescription {
            self.activeRequests[path] = dataTask
        }
        return .noError
    }

    func createMeetingFollowup(userId: String, meetingId: String, data: [String: Any], success:((URLSessionDataTask?, Any?) -> Void)? , failure:((URLSessionDataTask?, Any?, Error?) -> Void)? ) -> KAHTTPRequestStatus {
        if checkNetwork() == .noNetwork{
            return .noNetwork
        }
        if checkRequestStatus() == .requestExists{
            return .requestExists
        }

        let requestURL = KARESTAPIManager.shared.followupCreateMeeting(userId: userId, meetingId: meetingId, server: KORE_SERVER)
        let dataTask = self.POST(urlString: requestURL, parameters: data, success: { (dataTask, responseObject) in
            DispatchQueue.main.async {
                success?(dataTask, responseObject)
            }

            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        },
        failure: { (dataTask, responseObject, error) in
            DispatchQueue.main.async {
                failure? (dataTask, responseObject, error)
            }

            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        })

        dataTask?.taskDescription = requestURL
        if let path = dataTask?.taskDescription {
            self.activeRequests[path] = dataTask
        }
        return .noError
    }

    func doGetMeetingNotesParticipants(_ userid:String, _ meetingid:String, success:((URLSessionDataTask?, Any?) -> Void)? , failure:((URLSessionDataTask?, Any?, Error?) -> Void)? ) -> KAHTTPRequestStatus {
        
        if checkNetwork() == .noNetwork{
            return .noNetwork
        }
        if checkRequestStatus() == .requestExists{
            return .requestExists
        }
        
        let requestURL = KARESTAPIManager.shared.meetingNotesParticipantsUrl(with: userid, meetingid: meetingid, server: KORE_SERVER)
        let dataTask = self.GET(urlString: requestURL, parameters: nil, success: { (dataTask, responseObject) in
            
            DispatchQueue.main.async {
                success?(dataTask, responseObject)
            }
            
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        },
                                failure: { (dataTask, responseObject, error) in
                                    DispatchQueue.main.async {
                                        failure? (dataTask, responseObject, error)
                                    }
                                    
                                    if let path = dataTask?.taskDescription {
                                        self.activeRequests.removeValue(forKey: path)
                                    }
        })
        
        dataTask?.taskDescription = requestURL
        if let path = dataTask?.taskDescription {
            self.activeRequests[path] = dataTask
        }
        return .noError
    }
    //  /ka/users/:userId/meetings/:mId/notes/participants

    
    func doGetMeetingNotesAttendee(_ userid:String, _ meetingid:String, success:((URLSessionDataTask?, Any?) -> Void)? , failure:((URLSessionDataTask?, Any?, Error?) -> Void)? ) -> KAHTTPRequestStatus {
        
        if checkNetwork() == .noNetwork{
            return .noNetwork
        }
        if checkRequestStatus() == .requestExists{
            return .requestExists
        }
        
        let requestURL = KARESTAPIManager.shared.meetingNotesAttendeeUrl(with: userid, meetingid: meetingid, server: KORE_SERVER)
        let dataTask = self.GET(urlString: requestURL, parameters: nil, success: { (dataTask, responseObject) in
            
            DispatchQueue.main.async {
                success?(dataTask, responseObject)
            }
            
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        },
                                failure: { (dataTask, responseObject, error) in
                                    DispatchQueue.main.async {
                                        failure? (dataTask, responseObject, error)
                                    }
                                    
                                    if let path = dataTask?.taskDescription {
                                        self.activeRequests.removeValue(forKey: path)
                                    }
        })
        
        dataTask?.taskDescription = requestURL
        if let path = dataTask?.taskDescription {
            self.activeRequests[path] = dataTask
        }
        return .noError
    }
    
    func doPostMeetingNotes(with meetingId: String?, parameteres parameters: [String: Any]?, completionBlock block:(([String: Any]?, Error?) -> Void)?) -> KAHTTPRequestStatus {
        if checkNetwork() == .noNetwork{
            return .noNetwork
        }
        
        var requestURL = String(format:"%@api/1.1/ka/users/%@/meetings", KORE_SERVER, self.userId)
        if let meetingId = meetingId {
            requestURL = requestURL.appendingFormat("/%@/notes", meetingId)
        }

        if self.activeRequests[requestURL] != nil {
            return .requestExists
        }

        let dataTask = self.POST(urlString: requestURL, parameters: parameters, success:{ (dataTask, responseObject) in
            DispatchQueue.main.async {
                if let responseObject = responseObject as? [String: Any] {
                    block?(responseObject, nil)
                } else {
                    block?(nil, nil)
                }
            }
            if let path = dataTask?.taskDescription {
                if self.activeRequests[path] != nil { 
                    self.activeRequests.removeValue(forKey: path)
                }
            }
        }, failure:{ (dataTask, responseObject, error) in
            DispatchQueue.main.async {
                block?(nil, error)
            }
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        })
        
        dataTask?.taskDescription = requestURL
        if let path = dataTask?.taskDescription {
            self.activeRequests[path] = dataTask
        }
        return .noError
    }
}

// MARK: - Kora analytics
extension KAAccount {
    func doPostKoraActivity(parameters: [String: Any]?, completion block:((Bool, Error?) -> Void)?) -> KAHTTPRequestStatus {
        if checkNetwork() == .noNetwork {
            return .noNetwork
        }
        
        let urlString = String(format:"%@api/1.1/ka/users/%@/activity", KORE_SERVER, userId)
        if activeRequests[urlString] != nil {
            return .requestExists
        }
        
        let dataTask = POST(urlString: urlString, parameters: parameters, success:{ [weak self] (dataTask, responseObject) in
            DispatchQueue.main.async {
                if let _ = responseObject as? [String: Any] {
                    block?(true, nil)
                } else {
                    block?(false, nil)
                }
            }
            if let path = dataTask?.taskDescription {
                self?.activeRequests.removeValue(forKey: path)
            }
        }, failure:{ [weak self] (dataTask, responseObject, error) in
            DispatchQueue.main.async {
                block?(false, error)
            }
            if let path = dataTask?.taskDescription {
                self?.activeRequests.removeValue(forKey: path)
            }
        })
        
        dataTask?.taskDescription = urlString
        if let path = dataTask?.taskDescription {
            self.activeRequests[path] = dataTask
        }
        return .noError
    }
}


// MARK: - Tasks
extension KAAccount {
    func doPostTask(taskId: String?, parameteres parameters: [String: Any]?, completionBlock block:(([String: Any]?, Error?) -> Void)?) -> KAHTTPRequestStatus {
        if checkNetwork() == .noNetwork{
            return .noNetwork
        }
        
        var httpMethod = "POST"
        var urlString = String(format:"%@api/1.1/ka/users/%@/task", KORE_SERVER, self.userId)
        if let taskId = taskId {
            urlString = urlString.appendingFormat("/%@", taskId)
            httpMethod = "PUT"
        }

        if activeRequests[urlString] != nil {
            return .requestExists
        }

        guard var request = try? requestSerializer().request(withMethod: httpMethod, urlString: urlString, parameters: parameters) as URLRequest else {
            return .requestError
        }
        request.timeoutInterval = DEFAULT_TIMEOUT_INTERVAL
        let dataTask = HTTPRequestOperation(with: request, success: { [weak self] (dataTask, responseObject) in
            DispatchQueue.main.async {
                if let responseObject = responseObject as? [String: Any] {
                    block?(responseObject, nil)
                } else {
                    block?(nil, nil)
                }
            }
            if let path = dataTask?.taskDescription {
                if self?.activeRequests[path] != nil {
                    self?.activeRequests.removeValue(forKey: path)
                }
            }
        }, failure: { [weak self] (dataTask, responseObject, error) in
            DispatchQueue.main.async {
                block?(nil, error)
            }
            if let path = dataTask?.taskDescription {
                self?.activeRequests.removeValue(forKey: path)
            }
        })
        dataTask?.taskDescription = urlString
        dataTask?.resume()
        if let path = dataTask?.taskDescription {
            activeRequests[path] = dataTask
        }
        return .noError
    }
    
    func doResolveTask(taskId: String, completion block:(([String: Any]?, Error?) -> Void)?) -> KAHTTPRequestStatus {
        let reachable = self.networkReachability()
        if !reachable {
            return .noNetwork
        }
        
        let requestUrl = String(format:"%@api/1.1/ka/users/%@/task/%@", KORE_SERVER, userId, taskId)
        if activeRequests[requestUrl] != nil {
            return .requestExists
        }
        
        let dataTask = self.GET(urlString: requestUrl, parameters: nil, success:{ (dataTask, responseObject) in
            if let responseObject = responseObject as? [String: Any] {
                DispatchQueue.main.async {
                    block?(responseObject, nil)
                }
            }
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        }, failure:{ (dataTask, responseObject, error) in
            DispatchQueue.main.async {
                block?(nil, error)
            }
            if let path = dataTask?.taskDescription {
                self.activeRequests.removeValue(forKey: path)
            }
        })
        dataTask?.taskDescription = requestUrl
        if let path = dataTask?.taskDescription {
            if self.activeRequests[path] != nil {
                self.activeRequests.removeValue(forKey: path)
            }
        }
        return .noError
    }
}
*/
