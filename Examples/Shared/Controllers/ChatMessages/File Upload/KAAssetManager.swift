//
//  KAAssetManager.swift
//  KoraSDK
//
//  Created by Srinivas Vasadi on 30/04/18.
//  Copyright © 2018 Srinivas Vasadi. All rights reserved.
//

import UIKit
import Photos
import CoreServices
import KoreBotSDK
import SwiftUTI

public enum KAAssetDownloadStatus {
    case notDownloaded, completed, partial, failed, unknown
}

public enum KAAsset {
    case audio, video, image, attachment
    
    var fileExtension: String {
        switch self {
        case .audio:
            return "m4a"
        case .video:
            return "mp4"
        case .image:
            return  "jpg"
        case .attachment:
            return ""
        }
    }
    var fileType: String {
        switch self {
        case .audio:
            return "audio"
        case .video:
            return "video"
        case .image:
            return  "image"
        case .attachment:
            return "attachment"
        }
    }
    var folder: String {
        switch self {
        case .audio:
            return "audios"
        case .video:
            return "videos"
        case .image:
            return  "images"
        case .attachment:
            return "attachments"
        }
    }
    var thumbnailExtension: String {
        switch self {
        case .video, .image:
            return "png"
        case .audio, .attachment:
            return ""
        }
    }
    var maxSize: CGSize {
        switch self {
        case .video, .image:
            return CGSize(width: 1280.0, height: 1280.0)
        case .audio, .attachment:
            return CGSize.zero
        }
    }
    var minSize: CGSize {
        switch self {
        case .audio, .attachment:
            return CGSize.zero
        case .video, .image:
            return CGSize(width: 320.0, height: 240.0)
        }
    }
    var compressionBitRate: Int {
        switch self {
        case .audio:
            return 48 * 1000
        case .video:
            return 256 * 1000
        default:
            return 0
        }
    }
    var maxDuration: Double {
        switch self {
        case .audio:
            return 300.0
        case .video:
            return 300.0
        default:
            return 0.0
        }
    }
}

class KAMediaAsset: NSObject {
    enum KAMediaAssetType {
        case image, audio, video, attachment
    }
    var assetUrl: URL!
    var asset: PHAsset!
    var assetURL: URL!
    var image: UIImage!
    var fileType: String!
    var fileExtn: String!
    var fileName: String!
    var filePath: String!
    var thumbnailPath: String!
    var identifier: String!
    var imageOrientation: String!
    var assetType: KAMediaAssetType!
    var thumbnail: UIImage!
    var duration: TimeInterval!
    var editedAssetPath: String!
    var editedAssetDuration: NSNumber!
    var fileSize: UInt64 = 0
    
    // MARK: - init
    init(asset: PHAsset) {
        super.init()
        self.asset = asset

        let fileUtilities = KAFileUtilities.shared
        switch asset.mediaType {
        case .audio:
            assetType = .audio
            duration = asset.duration
            fileExtn = KAAsset.audio.fileExtension
            fileType = KAAsset.audio.fileType
            break
        case .video:
            assetType = .video
            duration = asset.duration
            fileExtn = KAAsset.video.fileExtension
            fileType = KAAsset.video.fileType
            break
        case .image:
            assetType = .image
            fileExtn = KAAsset.image.fileExtension
            fileType = KAAsset.image.fileType
            break
        default:
            assetType = .none
            break
        }
        identifier = asset.localIdentifier
        fileName = fileUtilities.getUUID(for: self.fileType)
        filePath = fileUtilities.path(for: self.fileName, of: self.fileType, with: fileExtn)
        thumbnailPath = fileUtilities.thumbnailPath(for: self.fileName, ofType: self.fileType)
    }
    
    init(assetUrl: URL) {
        super.init()
        self.assetUrl = assetUrl
        
        let fileUtilities = KAFileUtilities.shared
        let assetName = assetUrl.deletingPathExtension().lastPathComponent
        fileName = assetName
        fileExtn = assetUrl.pathExtension

        let uti = UTI(withExtension: fileExtn)
        if uti.conforms(to: .image) || uti.conforms(to: .jpeg) ||  uti.conforms(to: .jpeg2000)  {
            assetType = .image
            fileExtn = KAAsset.image.fileExtension
            fileType = KAAsset.image.fileType
            fileName = fileUtilities.getUUID(for: self.fileType)
        } else if uti.conforms(to: .movie) || uti.conforms(to: .video) ||  uti.conforms(to: .quickTimeMovie) || uti.conforms(to: .mpeg4) {
            assetType = .video
            fileExtn = KAAsset.video.fileExtension
            fileType = KAAsset.video.fileType
            fileName = fileUtilities.getUUID(for: self.fileType)
        } else {
            assetType = .attachment
            fileType = KAAsset.attachment.fileType
        }
        
        filePath = fileUtilities.path(for: self.fileName, of: self.fileType, with: fileExtn)
        thumbnailPath = fileUtilities.thumbnailPath(for: self.fileName, ofType: self.fileType)
        identifier = ""
    }
    
    init(image: UIImage) {
        super.init()
        self.image = image
        
        assetType = .image
        fileExtn = KAAsset.image.fileExtension
        fileType = KAAsset.image.fileType
        
        let fileUtilities = KAFileUtilities.shared
        identifier = ""
        fileName = fileUtilities.getUUID(for: self.fileType)
        filePath = fileUtilities.path(for: self.fileName, of: self.fileType, with: fileExtn)
        thumbnailPath = fileUtilities.thumbnailPath(for: self.fileName, ofType: self.fileType)
    }
    
    // MARK: - Edited Media Methods
    func timeFormattedDuration(for duration: NSNumber) -> String {
        let totalSeconds = Int(truncating: duration)
        let seconds: Int = totalSeconds % 60
        let minutes: Int = (totalSeconds / 60) % 60
        let hours: Int = totalSeconds / 3600
        if hours > 0 {
            return "\(hours):%.2d:%.2d"
        }
        return String(format: "%.2d:%.2d", minutes, seconds)
    }
}

class KAAssetManager: NSObject {
    // properties
    var koraContainerPath: String = ""
    let fileManager: FileManager = FileManager.default
    static var instance: KAAssetManager!
    
    // MARK:- datastore manager shared instance
    @objc static let shared: KAAssetManager = {
        if (instance == nil) {
            instance = KAAssetManager()
        }
        return instance
    }()
    
    // MARK: -
    func requestMediaAsset(for asset: PHAsset, progress: ((_ progress: Double) -> Void)?, completion: ((_ staus: Bool, _ mediaAsset: KAMediaAsset?) -> Void)?) {
        switch asset.mediaType {
        case .video:
            self.exportVideo(with: asset, progress: progress, completion: completion)
        case .image:
            self.exportImage(with: asset, progress: progress, completion: completion)
        default:
            if (completion != nil) {
                completion!(false, nil)
            }
        }
    }
    
    // MARK: - export video/image
    func exportVideo(to filePath: String, with exportSession: AVAssetExportSession, completion: ((_ success: Bool) -> Void)?) {
        exportSession.outputURL = URL(fileURLWithPath: filePath)
        exportSession.outputFileType = AVFileType.mp4
        let start: CMTime = CMTimeMakeWithSeconds(0.0, preferredTimescale: exportSession.asset.duration.timescale)
        let range: CMTimeRange = CMTimeRangeMake(start: start, duration: exportSession.asset.duration)
        exportSession.timeRange = range
        exportSession.exportAsynchronously(completionHandler: { () -> Void in
            switch exportSession.status {
            case .failed:
                print("Export failed: \(exportSession.error?.localizedDescription ?? "")")
                if completion != nil {
                    completion!(false)
                }
            case .cancelled:
                print("Export canceled")
                if completion != nil {
                    completion!(false)
                }
            case .unknown:
                print("Export unknown")
                if completion != nil {
                    completion!(false)
                }
            default:
                print("NONE")
                if completion != nil {
                    completion!(true)
                }
            }
        })
    }
    
    func exportImage(_ asset: UIImage, size: CGSize? = nil, progress: ((_ progress: Double) -> Void)?, completion: ((_ success: Bool, _ mediaAsset: KAMediaAsset?) -> Void)?) {
        let mediaAsset = KAMediaAsset(image: asset)
        let fileUtilities = KAFileUtilities.shared
        let image = asset.resizedImageToFit(in: size ?? KAAsset.image.maxSize, scaleIfSmaller: false)
        if let image = image {
            if image.size.width > image.size.height {
                mediaAsset.imageOrientation = "landscape"
            } else {
                mediaAsset.imageOrientation = "portrait"
            }
            let imageStatus = fileUtilities.save(image, toFilePath: mediaAsset.filePath, fileType: mediaAsset.fileType, compressionQuality: 0.5)
            let thumbnail = asset.resizedImageToFit(in: KAAsset.image.minSize, scaleIfSmaller: false)
            let thumbnailStatus = fileUtilities.save(thumbnail!, toFilePath: mediaAsset.thumbnailPath, fileType: mediaAsset.fileType, compressionQuality: 0.5)
            
            DispatchQueue.main.async {
                if (imageStatus && thumbnailStatus) {
                    completion?(true, mediaAsset)
                } else {
                    completion?(false, nil)
                }
            }
        }
    }
    
    func exportImage(with asset: PHAsset, progress: ((_ progress: Double) -> Void)?, completion: ((_ success: Bool, _ mediaAsset: KAMediaAsset?) -> Void)?) {
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        options.deliveryMode = .highQualityFormat
        options.isSynchronous = false
        options.isNetworkAccessAllowed = true
        options.progressHandler = {  (progressValue, error, stop, info) in
            progress?(progressValue)
        }

        PHImageManager.default().requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: PHImageContentMode.default, options: options) { (result, info) in
            let mediaAsset = KAMediaAsset(asset: asset)
            let fileUtilities = KAFileUtilities.shared
            let image = result?.resizedImageToFit(in: KAAsset.image.maxSize, scaleIfSmaller: false)
            if let image = image {
                if image.size.width > image.size.height {
                    mediaAsset.imageOrientation = "landscape"
                } else {
                    mediaAsset.imageOrientation = "portrait"
                }
                let imageStatus = fileUtilities.save(image, toFilePath: mediaAsset.filePath, fileType: mediaAsset.fileType, compressionQuality: 0.5)
                let thumbnail = result?.resizedImageToFit(in: KAAsset.image.minSize, scaleIfSmaller: false)
                let thumbnailStatus = fileUtilities.save(thumbnail!, toFilePath: mediaAsset.thumbnailPath, fileType: mediaAsset.fileType, compressionQuality: 0.5)
                
                DispatchQueue.main.async {
                    if (imageStatus && thumbnailStatus && completion != nil) {
                        completion!(true, mediaAsset)
                    } else if (completion != nil) {
                        completion!(false, nil)
                    }
                }
            }
        }
    }
    
    func exportVideo(with asset: PHAsset, progress: ((_ progress: Double) -> Void)?, completion: ((_ success: Bool, _ mediaAsset: KAMediaAsset?) -> Void)?) {
        let options = PHVideoRequestOptions()
        options.version = .original
        options.deliveryMode = .automatic
        options.isNetworkAccessAllowed = true
        options.progressHandler = {  (progressValue, error, stop, info) in
            if (progress != nil) {
                progress?(progressValue)
            }
        }
        PHImageManager.default().requestExportSession(forVideo: asset, options: options, exportPreset: AVAssetExportPresetMediumQuality, resultHandler: { (exportSession, info) in
            let mediaAsset = KAMediaAsset(asset: asset)
            switch asset.sourceType {
            case .typeCloudShared:
                let cloudKey = info!["PHImageResultIsInCloudKey"] as! Bool
                if cloudKey {
                    let iCloudFileLink = exportSession!.asset.value(forKey: "URL") as? URL
                    if iCloudFileLink == nil {
                        return
                    }
                }
            default:
                self.exportVideo(to: mediaAsset.filePath, with: exportSession!, completion: { (success) in
                    let imageOptions = PHImageRequestOptions()
                    imageOptions.isSynchronous = true
                    imageOptions.deliveryMode = .highQualityFormat
                    imageOptions.isSynchronous = false
                    imageOptions.isNetworkAccessAllowed = true
                    imageOptions.progressHandler = {  (progressValue, error, stop, info) in
                        if (progress != nil) {
                            progress?(progressValue)
                        }
                    }
                    PHImageManager.default().requestImage(for: mediaAsset.asset, targetSize: KAAsset.video.maxSize, contentMode: .aspectFit, options: imageOptions, resultHandler: { [unowned self] (result, info) in
                        let fileUtilities = KAFileUtilities.shared
                        if let image = result {
                            let videoThumbnail = self.drawPlayButton(image)
                            if videoThumbnail.size.width > videoThumbnail.size.height {
                                mediaAsset.imageOrientation = "landscape"
                            } else {
                                mediaAsset.imageOrientation = "portrait"
                            }
                            let thumbnailStatus = fileUtilities.save(videoThumbnail, toFilePath: mediaAsset.thumbnailPath, fileType: mediaAsset.fileType, compressionQuality: 0.5)
                            DispatchQueue.main.async {
                                if completion != nil {
                                    completion!(thumbnailStatus, mediaAsset)
                                }
                            }
                        }
                    })
                })
                break
            }
        })
    }
    
    func exportVideo(_ url: URL, progress: ((_ progress: Double) -> Void)?, completion: ((_ success: Bool, _ mediaAsset: KAMediaAsset?) -> Void)?) {
        let mediaAsset = KAMediaAsset(assetUrl: url)
        let anAsset = AVURLAsset(url: url, options: nil)
        
        let exportSession = AVAssetExportSession(asset: anAsset, presetName: AVAssetExportPresetMediumQuality)
        self.exportVideo(to: mediaAsset.filePath, with: exportSession!, completion: { (success) in
            let imageOptions = PHImageRequestOptions()
            imageOptions.isSynchronous = true
            imageOptions.deliveryMode = .highQualityFormat
            imageOptions.isSynchronous = false
            imageOptions.isNetworkAccessAllowed = true
            imageOptions.progressHandler = {  (progressValue, error, stop, info) in
                if (progress != nil) {
                    progress?(progressValue)
                }
            }
            self.generateThumbnail(with: KAAsset.video.maxSize, from: URL(fileURLWithPath: mediaAsset.filePath), completion: { (result) in
                let fileUtilities = KAFileUtilities.shared
                if let image = result {
                    let videoThumbnail = self.drawPlayButton(image)
                    if videoThumbnail.size.width > videoThumbnail.size.height {
                        mediaAsset.imageOrientation = "landscape"
                    } else {
                        mediaAsset.imageOrientation = "portrait"
                    }
                    let thumbnailStatus = fileUtilities.save(videoThumbnail, toFilePath: mediaAsset.thumbnailPath, fileType: mediaAsset.fileType, compressionQuality: 0.5)
                    DispatchQueue.main.async {
                        if completion != nil {
                            completion!(thumbnailStatus, mediaAsset)
                        }
                    }
                }
            })
        })
    }
    
    func generateThumbnail(with size: CGSize, from fileURL: URL?, completion handler: ((_ thumbnail: UIImage?) -> Void)?) {
        guard let url = fileURL else {
            handler?(nil)
            return
        }
        let asset = AVURLAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        imageGenerator.maximumSize = CGSize.zero
        let imageTimeValue = NSValue(time: CMTimeMake(value: 2, timescale: 1))
        imageGenerator.generateCGImagesAsynchronously(forTimes: [imageTimeValue], completionHandler: { requestedTime, image, actualTime, result, error in
            if result == .failed {
                handler?(nil)
            } else {
                if let cgImage = image {
                    let image = UIImage(cgImage: cgImage)
                    handler?(image)
                } else {
                    handler?(nil)
                }
            }
        })
    }

    func exportAsset(with url: URL, completion: ((_ success: Bool, _ mediaAsset: KAMediaAsset?) -> Void)?) {
        DispatchQueue.global().async {
            let mediaAsset = KAMediaAsset(assetUrl: url)
            let fileUtilities = KAFileUtilities.shared
            let attachmentStatus = fileUtilities.save(url, to: mediaAsset.filePath, fileType: mediaAsset.fileType)
            switch mediaAsset.fileType {
            case KAAsset.image.fileType:
                guard let data = try? Data(contentsOf: url) else {
                    completion?(false, nil)
                    return
                }
                let image = UIImage(data: data)
                if let image = image {
                    if image.size.width > image.size.height {
                        mediaAsset.imageOrientation = "landscape"
                    } else {
                        mediaAsset.imageOrientation = "portrait"
                    }
                    let imageStatus = fileUtilities.save(image, toFilePath: mediaAsset.filePath, fileType: mediaAsset.fileType, compressionQuality: 0.5)
                    let thumbnail = image.resizedImageToFit(in: KAAsset.image.minSize, scaleIfSmaller: false)
                    let thumbnailStatus = fileUtilities.save(thumbnail!, toFilePath: mediaAsset.thumbnailPath, fileType: mediaAsset.fileType, compressionQuality: 0.5)
                    DispatchQueue.main.async {
                        if imageStatus && thumbnailStatus {
                            completion?(true, mediaAsset)
                        } else {
                            completion?(false, nil)
                        }
                    }
                }
            case KAAsset.video.fileType:
                self.generateThumbnail(with: KAAsset.video.maxSize, from: URL(fileURLWithPath: mediaAsset.filePath), completion: { (result) in
                    let fileUtilities = KAFileUtilities.shared
                    if let image = result {
                        let videoThumbnail = self.drawPlayButton(image)
                        if videoThumbnail.size.width > videoThumbnail.size.height {
                            mediaAsset.imageOrientation = "landscape"
                        } else {
                            mediaAsset.imageOrientation = "portrait"
                        }
                        let thumbnailStatus = fileUtilities.save(videoThumbnail, toFilePath: mediaAsset.thumbnailPath, fileType: mediaAsset.fileType, compressionQuality: 0.5)
                        DispatchQueue.main.async {
                            if completion != nil {
                                completion!(thumbnailStatus, mediaAsset)
                            }
                        }
                    }
                })
            default:
                DispatchQueue.main.async {
                    completion?(attachmentStatus, mediaAsset)
                }
            }
            
        }
    }
    
    func supportedAssetTypes() -> [String] {
        let types = [kUTTypeAudio, kUTTypeMP3, kUTTypeMPEG4Audio, kUTTypeWaveformAudio, kUTTypeAppleProtectedMPEG4Audio, kUTTypeVideo, kUTTypeMPEG2Video, kUTTypeMovie, kUTTypeAVIMovie, kUTTypeMPEG4, kUTTypeQuickTimeMovie, kUTTypeImage, kUTTypeRawImage, kUTTypePNG, kUTTypeJPEG, kUTTypeJPEG2000, kUTTypeBMP, kUTTypeGIF, kUTTypeQuickTimeImage, kUTTypeAppleICNS, kUTTypePICT, kUTTypeTIFF, kUTTypeText, kUTTypeRTF, kUTTypeUTF8PlainText, kUTTypePlainText, kUTTypePDF, kUTTypeXML, kUTTypeXML, kUTTypeHTML, kUTTypePresentation, kUTTypeSpreadsheet, kUTTypeDatabase, kUTTypeData,  kUTTypeSourceCode, kUTTypeZipArchive, kUTTypeWebArchive, kUTTypeFolder, kUTTypeDirectory] as [String]
        return types
    }
    
    // MARK: -
    func drawPlayButton(_ image: UIImage) -> UIImage {
        let playButton = UIImage(named: "play", in: Bundle(for: KAAssetManager.self), compatibleWith: nil)

        UIGraphicsBeginImageContext(image.size)
        image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        playButton?.draw(in: CGRect(x: (image.size.width) / 2 - (playButton?.size.width)! / 2, y: (image.size.height) / 2 - (playButton?.size.height)! / 2, width:( playButton?.size.width)!, height: (playButton?.size.height)!))
        let result: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return result
    }
    
    // MARK: -
    func doesComponentExist(onDevice component: Component) -> (filePath: String, downloadStatus: KAAssetDownloadStatus) {
        var downloadStatus: KAAssetDownloadStatus = .notDownloaded
        var fileType: String = KAAsset.image.fileType
        var fileExtension: String?
        var actualSize: UInt64 = 0
        let fileUtilities = KAFileUtilities.shared
        
        guard let componentSize = component.componentSize else {
            downloadStatus = .unknown
            return (filePath: "", downloadStatus: downloadStatus)
        }
        
        actualSize = UInt64(componentSize)!
        if actualSize == 0 {
            downloadStatus = .unknown
            return (filePath: "", downloadStatus: downloadStatus)
        }

        switch component.templateType {  //componentType
        case KAAsset.audio.fileType:
            fileExtension = KAAsset.audio.fileExtension
            fileType = KAAsset.audio.fileType
        case KAAsset.video.fileType:
            fileExtension = KAAsset.video.fileExtension
            fileType = KAAsset.video.fileType
        case KAAsset.image.fileType:
            fileExtension = KAAsset.image.fileExtension
            fileType = KAAsset.image.fileType
        case KAAsset.attachment.fileType:
            fileExtension = component.fileMeta.fileExtn
            fileType = KAAsset.attachment.fileType
        default:
            return (filePath: "", downloadStatus: downloadStatus)
        }
        
        if let fileName = component.fileMeta.fileName, let fileExtension = fileExtension {
            let filePath = fileUtilities.path(for: fileName, of: fileType, with: fileExtension)
            if FileManager.default.fileExists(atPath: filePath) {
                do {
                    let attributes = try FileManager.default.attributesOfItem(atPath: filePath)
                    let fileSize = attributes[FileAttributeKey.size] as! UInt64
                    downloadStatus = KAFileUtilities.shared.assetDownloadStatus(with: fileName, of: fileSize, at: filePath, of: fileType)
                    return (filePath: filePath, downloadStatus: downloadStatus)
                } catch {
                    
                }
            }
        }

        return (filePath: "", downloadStatus: downloadStatus)
    }

}
