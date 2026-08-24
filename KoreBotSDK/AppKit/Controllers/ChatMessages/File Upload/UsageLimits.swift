//
//  UsageLimits.swift
//  KoraSDK
//
//  Created by Sukhmeet Singh on 05/05/20.
//  Copyright © 2020 Srinivas Vasadi. All rights reserved.
//

import UIKit

public enum KoraFremmiumConditions: Int {
    case limitShow = 0, noMore = 1, free = 2
    
    public var description: String {
        switch self {
        case .limitShow:
            return "limitShow"
        case .noMore:
            return "noMore"
        case .free:
            return "free"
        }
    }
}

public class UsageLimits: NSObject, Decodable {
    // MARK: - properties
    public var used: Int?
    public var size: Int?
    public var limit: Int?
    public var type: String?
    
    enum CodingKeys: String, CodingKey {
        case used = "used"
        case size = "size"
        case limit = "limit"
        case type = "type"
    }
    
    // MARK: - init
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        used = try? container.decode(Int.self, forKey: .used)
        size = try? container.decode(Int.self, forKey: .size)
        limit = try? container.decode(Int.self, forKey: .limit)
        type = try? container.decode(String.self, forKey: .type)
    }
    
    public func showFremiumForAnnouncmentAndKnowledge(usageLimits: [UsageLimits]) -> KoraFremmiumConditions {
        var totalUsage = 0
        var totalLimits = 0
        let usageArray = usageLimits.filter {$0.type == "announcements" || $0.type == "articles"}
    
        for usage in usageArray {
            totalUsage += (usage.used ?? 0)
            totalLimits += (usage.limit ?? 0)
        }
        if totalLimits < 0 {
            return .free
        }
        
        if totalUsage == 10 || totalUsage == 20 || totalUsage == 30 || totalUsage == 40 {
            return .limitShow
        }
        if totalUsage >= totalLimits {
            return .noMore
        } else {
            return .free
        }
    }
    
    public func showFremmiumForTeams(usageLimits: [UsageLimits]) -> KoraFremmiumConditions {
        let account = KoraApplication.sharedInstance.account
        var totalUsage = 0
        var totalLimit = 0

        guard let usage = account?.usageLimit else {
            return .free
        }
        let limit = (usage.filter {$0.type == "teams"}).first
        totalUsage = limit?.used ?? 0
        totalLimit = limit?.limit ?? 0
        if totalLimit < 0 {
            return .free
        }
        if totalUsage == 1 || totalUsage == 2  {
            return .limitShow
        }
        if (totalUsage) >= (totalLimit) {
            return .noMore
        } else {
            return .free
        }
    }
    
    public func countAnnouncementAndKnowledgeRemainnig(usageLimits: [UsageLimits]) -> Int {
        var totalUsage = 0
        let usageArrayAnnouncmenet = usageLimits.filter {$0.type == "announcements" }
        let usageArrayArticles = usageLimits.filter {$0.type == "articles"}
        let usageLimitTotal = (usageArrayAnnouncmenet.first?.limit ?? 0) + (usageArrayArticles.first?.limit ?? 0)
        let usageUsedTotal =  (usageArrayAnnouncmenet.first?.used ?? 0) + (usageArrayArticles.first?.used ?? 0)
        totalUsage =  usageLimitTotal - usageUsedTotal
        return totalUsage
    }
    
    public func isEnterprise(usageLimits: [UsageLimits]) -> Bool {
        let account = KoraApplication.sharedInstance.account
        var totalUsage = 0
        var totalLimit = 0
        
        guard let usage = account?.usageLimit else {
            return true
        }
        let limit = (usage.filter {$0.type == "teams"}).first
        totalUsage = limit?.used ?? 0
        totalLimit = limit?.limit ?? 0
        if totalLimit < 0 {
            return true
        } else {
            return false
        }
    }
}



public class KAAdminAccount: NSObject, Decodable {
    // MARK: - properties
    public var role: String?
    public var managedBy: String?
    public var licenseId: String?
    public var emailId: String?
    
    enum CodingKeys: String, CodingKey {
        case role = "role"
        case managedBy = "managedBy"
        case licenseId = "licenseId"
        case emailId = "emailId"
    }
    
    // MARK: - init
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        role = try? container.decode(String.self, forKey: .role)
        managedBy = try? container.decode(String.self, forKey: .managedBy)
        licenseId = try? container.decode(String.self, forKey: .licenseId)
        emailId = try? container.decode(String.self, forKey: .emailId)
    }
    
}
