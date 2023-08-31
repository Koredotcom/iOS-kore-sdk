//
//  Component.swift
//  KoreBotSDKDemo
//
//  Created by developer@kore.com on 09/05/16.
//  Copyright © 2016 Kore Inc. All rights reserved.
//

import Foundation
import UIKit

public enum ComponentType : Int {
    case text = 1, image = 2, options = 3, quickReply = 4, list = 5, carousel = 6, error = 7, chart = 8, table = 9, minitable = 10, responsiveTable = 11, menu = 12, newList = 13, tableList = 14, calendarView = 15, quick_replies_welcome = 16, notification = 17, multiSelect = 18, list_widget = 19, feedbackTemplate = 20, inlineForm = 21, dropdown_template = 22, video = 23, audio = 24, custom_table = 25, advancedListTemplate = 26, cardTemplate = 27, linkDownload = 28
}

public class Component: NSObject, Encodable, Decodable, NSCopying {
    public var templateType: String?
    public var componentType: ComponentType = .text
    public var componentServer: String?
    public var message: Message!
    public var payload: String?
    public var text: String?
    public var componentId: String?
    public var thumbnailUrl: String?
    public var body: String?
    public var desc: String?
    public var title: String?
    public var fileMeta: FileMeta = FileMeta()
    public var componentSize: String?
    public var componentFileId: String?
    public var isNewComponent: Bool = false
    public var componentHash: String?

    enum ComponentKeys: String, CodingKey {
        case body = "componentBody"
        case componentFileId = "componentFileId"
        case componentId = "componentId"
        case fileMeta = "componentData"
        case componentSize = "componentSize"
        case title = "componentTitle"
        case templateType = "templateType"
        case componentHash = "hash"
    }

    // MARK: - init
    override init() {
        super.init()
    }
    
    convenience init(_ type: ComponentType) {
        self.init()
        componentType = type
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ComponentKeys.self)
        body = try? container.decode(String.self, forKey: .body)
        componentFileId = try? container.decode(String.self, forKey: .componentFileId)
        componentId = try? container.decode(String.self, forKey: .componentId)
        if let meta = try? container.decode(FileMeta.self, forKey: .fileMeta) {
            fileMeta = meta
        }
        componentSize = try? container.decode(String.self, forKey: .componentSize)
        title = try? container.decode(String.self, forKey: .title)
        templateType = try? container.decode(String.self, forKey: .templateType)
        componentHash = try? container.decode(String.self, forKey: .componentHash)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: ComponentKeys.self)
        try container.encode(body, forKey: .body)
        try container.encode(componentFileId, forKey: .componentFileId)
        try container.encode(componentId, forKey: .componentId)
        try container.encode(fileMeta, forKey: .fileMeta)
        try container.encode(title, forKey: .title)
        try container.encode(componentSize, forKey: .componentSize)
        try container.encode(templateType, forKey: .templateType)
        try container.encode(componentHash, forKey: .componentHash)
    }
    
    public func copy(with zone: NSZone? = nil) -> Any {
        let copy = Component()
        copy.body = body
        copy.componentFileId = componentFileId
        copy.componentId = componentId
        copy.title = title
        copy.fileMeta = fileMeta
        copy.componentSize = componentSize
        copy.templateType = templateType
        copy.componentHash = componentHash
        return copy
    }
}

public class FileMeta: NSObject, Encodable, Decodable, NSCopying {
    public var fileName: String?
    public var fileExtn: String?
    public var fileToken: String?
    public var fileContext: String? = "knowledge"
    public var expiresOn: Date?
    public var fileSize: UInt64 = 0
    public var numberOfChunks: Int = 0
    public var chunks: [Chunk] = [Chunk]()
    public var orientation: String?

    enum FileMetaKeys: String, CodingKey {
        case fileName = "filename"
    }
    
    // MARK: - init
    override init() {
        super.init()
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: FileMetaKeys.self)
        fileName = try? container.decode(String.self, forKey: .fileName)
        if let fileName = fileName {
            fileExtn = URL(fileURLWithPath: fileName).pathExtension
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: FileMetaKeys.self)
        try container.encode(fileName, forKey: .fileName)
    }
    
    public func copy(with zone: NSZone? = nil) -> Any {
        let copy = FileMeta()
        copy.fileName = fileName
        copy.fileExtn = fileExtn
        return copy
    }
    
    public var extn: String? {
        if let fileName = fileName {
            return URL(fileURLWithPath: fileName).pathExtension
        }
        return nil
    }

    public var name: String? {
        if let fileName = fileName {
            return URL(fileURLWithPath: fileName).deletingPathExtension().lastPathComponent
        }
        return nil
    }
}

public class Chunk: NSObject {
    public var offset: Int!
    public var number: Int!
    public var size: Int!
    public var uploaded: Bool = false
    public var uploadProgress: Double = 0.0

    override init() {
        super.init()
    }
    
    convenience init(_ type: String) {
        self.init()
    }
}
