//
//  TaskList.swift
//  KoraSDK
//
//  Created by Sowmya Ponangi on 09/12/18.
//  Copyright © 2018 Srinivas Vasadi. All rights reserved.
//

import UIKit

public class KRETaskListItem: NSObject, Decodable {
    public var assignee: KREContacts?
    public var owner: KREContacts?
    public var createdOn: Int64?
    public var dueDate: Int64?
    public var lastModified: Int64?
    public var taskId: String?
    public var title: String?
    public var status: String?
    public var actions: [KREAction]?
    public var isSelected: Bool = false
    public var templateType: String?

    public enum TaskListKeys: String, CodingKey {
        case taskId = "id"
        case data = "data"
        case title = "title"
        case actions = "actions"
        case templateType = "template_type"
    }
    
    public enum DataKeys: String, CodingKey {
        case createdOn = "cOn"
        case assignee = "assignee"
        case dueDate = "dueDate"
        case owner = "owner"
        case status = "status"
        case title = "title"
        case lastModified = "lMod"
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: TaskListKeys.self)
        taskId = try? container.decode(String.self, forKey: .taskId)
        title = try? container.decode(String.self, forKey: .title)
        actions = try? container.decode([KREAction].self, forKey: .actions)
        templateType = try? container.decode(String.self, forKey: .templateType)

        if let dataContainer = try? container.nestedContainer(keyedBy: DataKeys.self, forKey: .data) {
            assignee = try? dataContainer.decode(KREContacts.self, forKey: .assignee)
            dueDate = try? dataContainer.decode(Int64.self, forKey: .dueDate)
            owner = try? dataContainer.decode(KREContacts.self, forKey: .owner)
            status = try? dataContainer.decode(String.self, forKey: .status)
            createdOn = try? dataContainer.decode(Int64.self, forKey: .createdOn)
            lastModified = try? dataContainer.decode(Int64.self, forKey: .lastModified)
        }
    }
}
