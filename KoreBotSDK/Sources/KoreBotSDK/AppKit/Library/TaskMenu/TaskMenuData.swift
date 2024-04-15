//
//  TaskMenuData.swift
//  KoreBotSDKDemo
//
//  Created by MatrixStream_01 on 29/05/20.
//  Copyright © 2020 Kore. All rights reserved.
//

import Foundation

// MARK: - Welcome
struct TaskMenu: Codable {
    let heading: String
    let tasks: [Task]
}

// MARK: - Task
struct Task: Codable {
    let title: String
    let icon: String
    let postback: Postback
}

// MARK: - Postback
struct Postback: Codable {
    let title, value: String
}
