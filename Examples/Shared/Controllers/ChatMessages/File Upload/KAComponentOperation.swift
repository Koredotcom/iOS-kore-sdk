//
//  KAComponentOperation.swift
//  KoraSDK
//
//  Created by Srinivas Vasadi on 19/04/18.
//  Copyright © 2018 Srinivas Vasadi. All rights reserved.
//

import UIKit
import Foundation
import KoreBotSDK

class KAOperation: Foundation.Operation {
    override var isAsynchronous: Bool {
        return true
    }
    override var isExecuting: Bool {
        return state == .executing
    }
    override var isFinished: Bool {
        return state == .finished
    }
    
    var state = State.ready {
        willSet {
            willChangeValue(forKey: state.keyPath)
            willChangeValue(forKey: newValue.keyPath)
        }
        didSet {
            didChangeValue(forKey: state.keyPath)
            didChangeValue(forKey: oldValue.keyPath)
        }
    }
    
    enum State: String {
        case ready = "Ready"
        case executing = "Executing"
        case finished = "Finished"
        fileprivate var keyPath: String { return "is" + self.rawValue }
    }
    
    override func start() {
        if self.isCancelled {
            state = .finished
        } else {
            state = .ready
            main()
        }
    }
    
    override func main() {
        if self.isCancelled {
            state = .finished
        } else {
            state = .executing
        }
    }
}

class KAComponentOperation: KAOperation {
    // constants
    let SMALL_CHUNK_SIZE: Int = 512 * 1024
    let MEDIUM_CHUNK_SIZE: Int = 1000 * 1024 // 1000 KB
    let LARGE_CHUNK_SIZE: Int = 2 * 1024 * 1024 //2 MB
    
    let KORE_SERVER = SDKConfiguration.serverConfig.JWT_SERVER
    var component: Component!
    var error: Error?
    var completionGroup: DispatchGroup = DispatchGroup()
    weak var account = KoraApplication.sharedInstance.account
    var progressBlock: ((_ progress: Double) -> Void)?
    var numberOfTasks: Double = 0.0
    var fileTokenRequestProgress: Double = 0.0
    var mergeRequestProgress: Double = 0.0
    var mergeResponseProgress: Double = 0.0
    
    // MARK: - init
    init(component: Component?) {
        super.init()
        self.component = component
    }
    
    // MARK: - Operation
    func setCompletionBlock(progress: ((_ progress: Double) -> Void)?, success: ((_ component: Component) -> Void)?, failure: ((_ error: Error?) -> Void)?) {
        self.progressBlock = progress
        self.completionBlock = { [unowned self] () -> Void in
            if (self.isCancelled) {
                return
            }
            if let error = self.error {
                if let block = failure {
                    block(error)
                }
            } else {
                if let error = self.error {
                    if let block = failure {
                        block(error)
                    }
                } else {
                    if let block = success {
                        block(self.component)
                    }
                }
            }
        }
    }

    // MARK: - start event
    override func start() {
        super.start()
        completionGroup.enter()
        sendComponent({ [unowned self] (status) in
            self.uploadChunks()
            self.completionGroup.leave()
        })
        
        completionGroup.notify(queue: DispatchQueue.main, execute: { [unowned self] in
            //let chunks = self.component.fileMeta.chunks.filter({$0.uploaded == false})
            //if chunks.count > 0 {
                self.finish()
//            } else {
//                self.mergeRequest(with: { (status) in
//                    self.finish()
//                })
//            }
        })
    }
    
    func finish() {
        self.state = .finished
    }
    
    // MARK: - file token operation
    func fileTokenRequest(with block: ((_ status: Bool) -> Void)?) {
        guard let account = account else {
            block?(false)
            return
        }
        var header: [String: String]?
        let authorization = "bearer \(AcccesssTokenn ?? "")"
         header = ["Authorization": authorization]
        if !checkBotUpload() {
            header = nil
        }
        let sessionManager = account.sessionManager
        sessionManager.requestSerializer = account.requestSerializer()
        sessionManager.responseSerializer = AFJSONResponseSerializer.init()
        sessionManager.post(fileTokenUrl(with: account.userId), parameters:[:] , headers: header, progress: { [unowned self] (progress) in  //["userId": account.userId]
            self.fileTokenRequestProgress = progress.fractionCompleted
            self.updateProgress()
        }, success: { [unowned self] (dataTask, responseObject) in
            if let dictionary = responseObject as? [String: Any] {
                if let fileToken = dictionary["fileToken"] as? String {
                    self.component.fileMeta.fileToken = fileToken
                }
                if let expiresOn = dictionary["expiresOn"] as? Double {
                    self.component.fileMeta.expiresOn = Date(timeIntervalSince1970: expiresOn)
                }
            }
            block?(true)
        }) { [weak self] (dataTask, error) in
            self?.error = error
            block?(false)
        }
    }
    
    func chunkRequest(chunk: Chunk, block: ((_ status: Bool) -> Void)?) {
        guard let account = account, let fileToken = component.fileMeta.fileToken else {
            block?(false)
            return
        }
        let authorization = "bearer \(AcccesssTokenn ?? "")"
        _ = ["Authorization": authorization]

        let fileName = component.fileMeta.fileName
        let fileType = component.templateType
        let fileExtension = component.fileMeta.fileExtn!
        let filePath = "\(KAFileUtilities.shared.path(for: fileName!, of: fileType!, with: fileExtension))"
        let fileHandle: FileHandle! = FileHandle(forReadingAtPath: filePath)
        if fileHandle == nil {
            print("KAComponentOperation :: chunkUploadOperationWithChunkInfo :: File doesnt exist at path : \(filePath)")
            fileHandle.closeFile()
            block?(false)
            return
        }
        
        fileHandle.seek(toFileOffset: UInt64(chunk.offset))
        let chunkedData = fileHandle.readData(ofLength: chunk.size)
        //let parameters: [String: Any] = ["fileToken": fileToken, "chunkNo": chunk.number]
        let parameters: [String: Any] = ["fileExtension": fileExtension, "fileContext": "workflows","thumbnailUpload": false, "filename": fileName!]
       
        let requestSerializer = account.requestSerializer()
        if checkBotUpload() {
            requestSerializer.setValue(authorization, forHTTPHeaderField: "Authorization")
        }
        
        let requestUrl = fileUploadUrl()
    
        let request = requestSerializer.multipartFormRequest(withMethod: "POST", urlString: requestUrl, parameters: parameters, constructingBodyWith: { [unowned self] (formData) in
            formData.appendPart(withFileData: chunkedData, name: "file", fileName: self.component.fileMeta.fileName!, mimeType: "application/octet-stream")
        }, error: nil)
        let sessionManager = account.sessionManager
        sessionManager.requestSerializer = requestSerializer
        sessionManager.responseSerializer = AFJSONResponseSerializer.init()
       
        let uploadTask = sessionManager.uploadTask(withStreamedRequest: request as URLRequest, progress: { [unowned self] (progress) in
            chunk.uploadProgress = progress.fractionCompleted
            self.updateProgress()
        }) { [unowned self] (response, responseObject, error) in
            self.error = error
            let success = (error == nil) ? true : false
            chunk.uploaded = success
            //kk
            if success == true, let dictionary = responseObject as? [String: Any] {
                if let fileId = dictionary["fileId"] {
                    self.component.componentFileId = fileId as? String
                }
                if let hash = dictionary["hash"] {
                    self.component.componentHash = hash as? String
                }
            }
            self.mergeResponseProgress = 1.0
            self.updateProgress()//kk
            block?(success)
        }
        uploadTask.resume()
    }
    
    func sizeLimitCheck(bytes: Int64) -> Bool {
        return true
    }
    
    func checkBotUpload() -> Bool {
        if component.componentServer != nil {
            return true
        } else {
            return false
        }
    }
    
    func mergeRequest(with block: ((_ status: Bool) -> Void)?) {
        guard let account = account, let fileToken = component.fileMeta.fileToken, let fileExtension = component.fileMeta.fileExtn, let fileName = component.fileMeta.fileName else {
            block?(false)
            return
        }

        let requestSerializer: AFHTTPRequestSerializer = account.requestSerializer()
        if checkBotUpload() {
            let authorization = "bearer \(AcccesssTokenn ?? "")"
            requestSerializer.setValue(authorization, forHTTPHeaderField: "Authorization")
        }
        
        var parameters: [String: Any] = ["fileToken": fileToken, "totalChunks": component.fileMeta.numberOfChunks, "fileExtension": fileExtension, "fileContext": component.fileMeta.fileContext ?? "", "filename": fileName]
        let fileType = component.templateType ?? ""
        var request: URLRequest?
        switch fileType {
        case KAAsset.image.fileType, KAAsset.video.fileType:
            if component.fileMeta.fileContext == "profile" {
                parameters["thumbnailUpload"] = "false"
                request = requestSerializer.multipartFormRequest(withMethod: "PUT", urlString: mergeRequestUrl(with: account.userId, fileMeta: component.fileMeta), parameters: parameters, constructingBodyWith: nil, error: nil) as URLRequest
            } else if component.fileMeta.fileContext == "workflows" {
                parameters["thumbnailUpload"] = "false"
                request = requestSerializer.multipartFormRequest(withMethod: "PUT", urlString: mergeRequestUrl(with: account.userId, fileMeta: component.fileMeta), parameters: parameters, constructingBodyWith: nil, error: nil) as URLRequest
            }
            else {
                parameters["thumbnailUpload"] = "true"
              parameters["thumbnailExtension"] = "png"
                
                request = requestSerializer.multipartFormRequest(withMethod: "PUT", urlString: mergeRequestUrl(with: account.userId, fileMeta: component.fileMeta),parameters: parameters, constructingBodyWith: { [unowned self] (formData) -> Void in
                    let thumbnailPath = KAFileUtilities.shared.thumbnailPath(for: self.component.fileMeta.fileName!, ofType: fileType)
                    if FileManager.default.fileExists(atPath: thumbnailPath) == true {
                        do {
                            let data = try Data(contentsOf: URL(fileURLWithPath: thumbnailPath))
                            formData.appendPart(withFileData: data, name: "thumbnail", fileName: self.component.fileMeta.fileName!, mimeType: "image/png")
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                    }, error: nil) as URLRequest
            }
        default:
            parameters["thumbnailUpload"] = "false"
            request = try? requestSerializer.request(withMethod: "PUT", urlString: mergeRequestUrl(with: account.userId, fileMeta: component.fileMeta), parameters: parameters) as URLRequest
            break
        }
        guard let urlRequest = request else {
            block?(false)
            return
        }
        let sessionManager = account.sessionManager
        
        sessionManager.responseSerializer = AFJSONResponseSerializer.init()
        let uploadTask = sessionManager.uploadTask(withStreamedRequest: urlRequest, progress: { [weak self] (progress) in
            self?.mergeRequestProgress = progress.fractionCompleted
            self?.updateProgress()
        }) { [unowned self] (response, responseObject, error) in
            if (self.isCancelled) {
                return
            }
            self.error = error
            let success = ((error == nil) ? true : false)
            if success == true, let dictionary = responseObject as? [String: Any] {
                if let fileId = dictionary["fileId"] {
                    self.component.componentFileId = fileId as? String
                }
                if let thumbnailURL = dictionary["thumbnailURL"] {
                    self.component.thumbnailUrl = thumbnailURL as? String
                }
            }
            self.mergeResponseProgress = 1.0
            self.updateProgress()
            block?(success)
        }
        uploadTask.resume()
    }
    
    // MARK: - create and send chunks
    func sendComponent(_ block: ((_ status: Bool) -> Void)?) {
        var chunkSize: Int = 0
        let fileName = component.fileMeta.fileName
        let fileType = component.templateType
        let fileExtension = component.fileMeta.fileExtn!

        let filePath = "\(KAFileUtilities.shared.path(for: fileName!, of: fileType!, with: fileExtension))"
       
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: filePath) == false {
            print("KAComponentOperation :: addComponent :: File is not existed at path : \(filePath)")
            block?(false)
            return
        }
        
        var currentOffset: Int = 0
        let attributes = try? FileManager.default.attributesOfItem(atPath: filePath)
        component.fileMeta.fileSize = attributes![FileAttributeKey.size] as! UInt64
        if !sizeLimitCheck(bytes: Int64(component.fileMeta.fileSize)) {
            error = NSError(domain:"", code: 801, userInfo: [NSLocalizedDescriptionKey: "File Size Error"]) as Error
            block?(false)
            return
        }
        component.componentSize = String(attributes![FileAttributeKey.size] as! UInt64)
        var fileHandle: FileHandle! = FileHandle(forReadingAtPath: filePath)
        switch fileType {
        case KAAsset.image.fileType:
            component.fileMeta.fileExtn = KAAsset.image.fileExtension
            chunkSize = SMALL_CHUNK_SIZE
        case KAAsset.video.fileType:
            component.fileMeta.fileExtn = KAAsset.video.fileExtension
            chunkSize = MEDIUM_CHUNK_SIZE
        default:
            component.fileMeta.fileExtn = component.fileMeta.fileExtn
            chunkSize = MEDIUM_CHUNK_SIZE
            break
        }
        
        if fileHandle == nil {
            print("KAComponentOperation :: addComponent :: unable to locate file")
            var fileExists = false
            repeat {
                fileExists = FileManager.default.fileExists(atPath: filePath)
            } while !fileExists
            fileHandle = FileHandle(forReadingAtPath: filePath)
            print("KAComponentOperation :: file exists now - opening the fileHandle")
        }
        
        fileHandle?.seek(toFileOffset: UInt64(currentOffset))
        print("KAComponentOperation :: addComponent :: FILE SIZE : \(component.fileMeta.fileSize)")
        var chunkNumber: Int = 0
        repeat {
            fileHandle?.seek(toFileOffset: UInt64(currentOffset))
            let data = fileHandle?.readData(ofLength: chunkSize)
            print("CHUNK NUMBER : \(chunkNumber), CHUNK LENGTH : \(UInt(data?.count ?? 0))")
            let thisChunkSize = Int((data?.count ?? 0))
            print("KAComponentOperation :: addComponent :: \(thisChunkSize) bytes read as last chunk")
            if Int(thisChunkSize) > 0 {
                
            } else {
                break
            }
            
            let chunk = Chunk()
            chunk.number = chunkNumber
            chunk.offset = currentOffset
            chunk.size = data?.count ?? 0
            component.fileMeta.chunks.append(chunk)
            print("KAComponentOperation :: addComponent :: Chunk Length : \(thisChunkSize)")
            currentOffset += thisChunkSize
            chunkNumber += 1
        } while (true)
        component.fileMeta.numberOfChunks = chunkNumber
        
        numberOfTasks = Double(component.fileMeta.chunks.count) + 3.0
        block?(true)
    }

    func uploadChunks() {
        if component.fileMeta.chunks.count == 0 {
            print("KAComponentOperation :: addComponentToQueue :: No chunks")
            return
        }
        completionGroup.enter()
        fileTokenRequest { [unowned self] (tokenRecieved) in
            if (self.isCancelled) {
                self.completionGroup.leave()
                return
            }
            if tokenRecieved {
                for chunk in self.component.fileMeta.chunks {
                    self.completionGroup.enter()
                    self.chunkRequest(chunk: chunk, block: { [unowned self] (success) in
                        self.completionGroup.leave()
                        if (self.isCancelled) {
                            return
                        }
                    })
                }
            }
            self.completionGroup.leave()
        }
    }
    
    func updateProgress() {
        if let block = progressBlock {
            var progress = (fileTokenRequestProgress + mergeRequestProgress + mergeResponseProgress)
            for chunk in component.fileMeta.chunks {
                progress += chunk.uploadProgress
            }
            let value = progress/numberOfTasks
            block(value)
        }
    }

    // MARK: - chunk upload URL
    func chunkUploadUrl(with userId: String, fileMeta: FileMeta) -> String {
        var server = ""
        if let botServer = component.componentServer {
            server = botServer + "/"
            return "\(server)api/1.1/attachment/file/\(fileMeta.fileToken ?? "")/chunk"
        } else {
            server = KORE_SERVER
        }
        return "\(server)api/1.1/users/\(userId)/file/\(fileMeta.fileToken ?? "")/chunk"
    }
    
    func fileUploadUrl() -> String {
        var server = ""
        if let botServer = component.componentServer {
            server = botServer + "/"
            return "\(server)api/attachments/file/\(SDKConfiguration.botConfig.botId)/ivr" //"\(server)api/1.1/attachment/file"
        } else {
            server = KORE_SERVER
        }
        return  server
    }
    
    func fileTokenUrl(with userId: String) -> String {
        var server = ""
        https://koradev-bots.kora.ai/api/1.1/attachment/file/token
        if let botServer = component.componentServer {
            server = botServer + "/"
            return "\(server)api/attachments/\(SDKConfiguration.botConfig.botId)/ivr/token" //"\(server)api/1.1/attachment/file/token"
        } else {
            server = KORE_SERVER
        }
        return "\(server)api/1.1/users/\(userId)/file/token"
    }
    
    func mergeRequestUrl(with userId: String, fileMeta: FileMeta) -> String {
       var server = ""
              if let botServer = component.componentServer {
                  server = botServer + "/"
               return "\(server)api/1.1/attachment/file/\(fileMeta.fileToken ?? "")"
              } else {
                  server = KORE_SERVER
       }
        return "\(server)api/1.1/users/\(userId )/file/\(fileMeta.fileToken ?? "")"
    }
}
