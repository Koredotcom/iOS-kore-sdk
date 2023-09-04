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
import Alamofire

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
            self.finish()
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
        var header: HTTPHeaders?
        //let authorization = "bearer \(AcccesssTokenn ?? "")"
        //header = ["Authorization": authorization]
        header = account.requestSerializerHeaders()
        if !checkBotUpload() {
            header = nil
        }
        
        let urlString: String = "\(fileTokenUrl(with: account.userId))"
        let parameters: [String: Any]  = [:]
        let sessionManager = account.sessionManager
        let dataRequest = sessionManager.request(urlString, method: .post, parameters: parameters, headers: header).uploadProgress(closure: { (progress) in
            self.fileTokenRequestProgress = progress.fractionCompleted
            self.updateProgress()
        })
        dataRequest.validate().responseJSON { (response) in
            if let _ = response.error {
                self.error = self.error
                block?(false)
                return
            }
            
            if let dictionary = response.value as? [String: Any]{
                if let fileToken = dictionary["fileToken"] as? String {
                    self.component.fileMeta.fileToken = fileToken
                }
                if let expiresOn = dictionary["expiresOn"] as? Double {
                    self.component.fileMeta.expiresOn = Date(timeIntervalSince1970: expiresOn)
                }
                block?(true)
            } else {
                self.error = self.error
                block?(false)
            }
        }
    }
    
    func chunkRequest(chunk: Chunk, block: ((_ status: Bool) -> Void)?){
        
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
        
        //Set Your URL
        let api_url = fileUploadUrl()
        guard let url = URL(string: api_url) else {
            return
        }
        
        var urlRequest = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 60.0)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
        
        //Set Your Parameter
        let parameterDict = NSMutableDictionary()
        parameterDict.setValue(fileExtension, forKey: "fileExtension")
        parameterDict.setValue("workflows", forKey: "fileContext")
        parameterDict.setValue(false, forKey: "thumbnailUpload")
        parameterDict.setValue(fileName!, forKey: "filename")
        
        urlRequest.addValue("Keep-Alive", forHTTPHeaderField:"Connection")
        urlRequest.addValue(KoraAssistant.shared.applicationHeader, forHTTPHeaderField: "X-KORA-Client")
        let tokenType = "bearer"
        if let accessToken = AcccesssTokenn {
            //urlRequest.addValue("\(tokenType) \(accessToken)", forHTTPHeaderField: "Authorization")
        }
        if checkBotUpload() {
            urlRequest.addValue(authorization, forHTTPHeaderField: "Authorization")
        }
        
        // Now Execute
        account?.sessionManager.upload(multipartFormData: { [unowned self] multiPart in
            
            for (key, value) in parameterDict {
                if let temp = value as? String {
                    multiPart.append(temp.data(using: .utf8)!, withName: key as! String)
                }
                if let temp = value as? Int {
                    multiPart.append("\(temp)".data(using: .utf8)!, withName: key as! String)
                }
                if let temp = value as? Bool {
                    multiPart.append("\(temp)".data(using: .utf8)!, withName: key as! String)
                }
                if let temp = value as? NSArray {
                    temp.forEach({ element in
                        let keyObj = key as! String + "[]"
                        if let string = element as? String {
                            multiPart.append(string.data(using: .utf8)!, withName: keyObj)
                        } else
                        if let num = element as? Int {
                            let value = "\(num)"
                            multiPart.append(value.data(using: .utf8)!, withName: keyObj)
                        }
                    })
                }
            }
            multiPart.append(chunkedData, withName: "file", fileName:  self.component.fileMeta.fileName!, mimeType: "application/octet-stream")
        }, with: urlRequest)
        .uploadProgress(queue: .main, closure: { [unowned self] progress in
            DispatchQueue.main.async {
                chunk.uploadProgress = progress.fractionCompleted
                self.updateProgress()
                print("Upload Progress: \(progress.fractionCompleted)")
            }
            
        })
        .responseJSON(completionHandler: { [unowned self] data in
            switch data.result {
            case .success(_):
                do {
                    let dictionary = try JSONSerialization.jsonObject(with: data.data!, options: .fragmentsAllowed) as! NSDictionary
                    self.error = self.error
                    let success = (error == nil) ? true : false
                    chunk.uploaded = success
                    if success == true, let dictionary = dictionary as? [String: Any] {
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
                catch {
                    // catch error.
                    print("catch error")
                    self.error = self.error
                }
                break
                
            case .failure(_):
                print("failure")
                self.error = self.error
                break
            }
        })
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
            if SDKConfiguration.botConfig.isWebhookEnabled{
                return "\(server)api/attachments/file/\(SDKConfiguration.botConfig.botId)/ivr"
            }else{
                return "\(server)api/1.1/attachment/file"
            }
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
            if SDKConfiguration.botConfig.isWebhookEnabled{
                return "\(server)api/attachments/\(SDKConfiguration.botConfig.botId)/ivr/token"
            }else{
                return "\(server)api/1.1/attachment/file/token"
            }
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
