//
//  KAFileUtilities.swift
//  KoraSDK
//
//  Created by Srinivas Vasadi on 24/04/18.
//  Copyright © 2018 Srinivas Vasadi. All rights reserved.
//

import UIKit
import Photos

public class KAFileUtilities: NSObject {
    // properties
    var koraContainerPath: String = ""
    let fileManager: FileManager = FileManager.default
    public static var instance: KAFileUtilities!

    // MARK:- datastore manager shared instance
    @objc public static let shared: KAFileUtilities = {
        if (instance == nil) {
            instance = KAFileUtilities()
        }
        return instance
    }()
    
    // MARK: - init
    override init() {
        super.init()
        setKoraContainerURL()
    }
    
    // MARK: - add kora cache directories
    func setKoraContainerURL() { //kk
        guard let containerUrl = KoraApplication.sharedInstance.getContainerURL() else {
            return
        }

        koraContainerPath = String(format: "\(containerUrl.path)/Library/Caches/Kora")
        if (FileManager.default.fileExists(atPath: "\(koraContainerPath)/\(KAAsset.attachment.folder)") == false) {
            _ = addDirectory(name: KAAsset.image.folder, atDirectoryPath: koraContainerPath)
            _ = addDirectory(name: KAAsset.video.folder, atDirectoryPath: koraContainerPath)
            _ = addDirectory(name: KAAsset.audio.folder, atDirectoryPath: koraContainerPath)
            _ = addDirectory(name: KAAsset.attachment.folder, atDirectoryPath: koraContainerPath)
        }
    }
    
    // MARK: -
    func addDirectory(name directoryName: String?, atDirectoryPath directoryPath: String?) -> Bool {
        let directoryPath = "\(directoryPath ?? "")/\(directoryName ?? "")"
        if (FileManager.default.fileExists(atPath: directoryPath) == false) {
            do {
                try self.fileManager.createDirectory(atPath: directoryPath, withIntermediateDirectories: true, attributes: nil)
                return true
            } catch {
                print("Problem creating directory [\(error.localizedDescription)]")
                return false
            }
        } else {
            return false
        }
    }
    
    // MARK: -
    func createThumbnailImage(for asset: PHAsset, with fileName: String, size: CGFloat) {
        let retinaScale = UIScreen.main.scale
        let retinaSquare = CGSize(width: size * retinaScale, height: size * retinaScale)
        let cropSizeLength = min(asset.pixelWidth, asset.pixelHeight)
        let square = CGRect(x: 0, y: 0, width: CGFloat(cropSizeLength), height: CGFloat(cropSizeLength))
        let cropRect = square.applying(CGAffineTransform(scaleX: 1.0/CGFloat(asset.pixelWidth), y: 1.0/CGFloat(asset.pixelHeight)))
        
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        var thumbnail = UIImage()
        
        options.isSynchronous = true
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .exact
        options.normalizedCropRect = cropRect
        
        manager.requestImage(for: asset, targetSize: retinaSquare, contentMode: .aspectFit, options: options, resultHandler: { [unowned self] (result, info) -> Void in
            thumbnail = result!
            let filePath = self.thumbnailPath(for: fileName, ofType: KAAsset.image.fileType)
            print(filePath)
            _ = self.save(thumbnail, toFilePath: filePath, fileType: KAAsset.image.fileType, compressionQuality: 1.0)
        })
    }
    
    func save(_ image: UIImage, toFilePath filePath: String, fileType: String, compressionQuality compression: CGFloat) -> Bool {
        if let imageData = image.jpegData(compressionQuality: compression) {
            if FileManager.default.fileExists(atPath: filePath) {
                do {
                    try FileManager.default.removeItem(atPath: filePath)
                } catch {
                    print("Error removing file:\((error.localizedDescription))")
                }
            }
            if FileManager.default.createFile(atPath: filePath, contents: imageData, attributes: nil) {
                return true
            }
        }
        return false
    }
    
    public func save(_ assetUrl: URL, to filePath: String, fileType: String) -> Bool {
        do {
            if fileManager.fileExists(atPath: filePath) {
                try fileManager.removeItem(atPath: filePath)
            }
            print(assetUrl.path, filePath)

            try fileManager.copyItem(atPath: assetUrl.path, toPath: filePath)
            print(filePath)
            return true
        } catch {
            print("Error removing file:\((error.localizedDescription))")
            return false
        }
    }
    
    // MARK: -
    public func getUUID(for fileType: String) -> String {
        var fileName: String = ""
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd'_'HHmmssSSS"
        switch fileType {
        case KAAsset.audio.fileType:
            fileName = "A_\(dateFormatter.string(from: Date()))"
        case KAAsset.image.fileType:
            fileName = "I_\(dateFormatter.string(from: Date()))"
        case KAAsset.video.fileType:
            fileName = "V_\(dateFormatter.string(from: Date()))"
        default:
            fileName = "AT_\(dateFormatter.string(from: Date()))"
        }
        return fileName
    }
    
    public func path(for fileName: String, of fileType: String, with fileExtension: String) -> String {
        print(fileName)
        let fileNameWithExtn = self.fileName(for: fileName, of: fileType, with: fileExtension)
        switch fileType {
        case KAAsset.audio.fileType:
            return "\(koraContainerPath)/\(KAAsset.audio.folder)/\(fileNameWithExtn)"
        case KAAsset.image.fileType:
            return "\(koraContainerPath)/\(KAAsset.image.folder)/\(fileNameWithExtn)"
        case KAAsset.video.fileType:
            return "\(koraContainerPath)/\(KAAsset.video.folder)/\(fileNameWithExtn)"
        default:
            return "\(koraContainerPath)/\(KAAsset.attachment.folder)/\(fileNameWithExtn)"
        }
    }
    
    public func thumbnailPath(for fileName: String, ofType fileType: String) -> String {
        let fileNameWithExtn = self.thumbnailFileName(for: "\(fileName)_thumbnail", withFileType: fileType)
        switch fileType {
        case KAAsset.audio.fileType:
            return "\(koraContainerPath)/\(KAAsset.audio.folder)/\(fileNameWithExtn)"
        case KAAsset.image.fileType:
            return "\(koraContainerPath)/\(KAAsset.image.folder)/\(fileNameWithExtn)"
        case KAAsset.video.fileType:
            return "\(koraContainerPath)/\(KAAsset.video.folder)/\(fileNameWithExtn)"
        default:
            return "\(koraContainerPath)/\(KAAsset.attachment.folder)/\(fileNameWithExtn)"
        }
    }
    
    public func thumbnailFileName(for itemName: String, withFileType fileType: String) -> String {
        switch fileType {
        case KAAsset.audio.fileType:
            return "\(itemName).\(KAAsset.audio.thumbnailExtension)"
        case KAAsset.image.fileType:
            return"\(itemName).\(KAAsset.image.thumbnailExtension)"
        case KAAsset.video.fileType:
            return "\(itemName).\(KAAsset.video.thumbnailExtension)"
        default:
            return"\(itemName).\(KAAsset.attachment.fileExtension)"
        }
    }
    
    public func fileName(for itemName: String, of fileType: String, with fileExtension: String) -> String {
        switch fileType {
        case KAAsset.audio.fileType:
            return "\(itemName).\(KAAsset.video.fileExtension)"
        case KAAsset.image.fileType:
            return"\(itemName).\(KAAsset.image.fileExtension)"
        case KAAsset.video.fileType:
            return "\(itemName).\(KAAsset.video.fileExtension)"
        default:
            return"\(itemName).\(fileExtension)"
        }
    }
    
    public func fileSize(with size: UInt64) -> String {
        return ByteCountFormatter.string(fromByteCount: Int64(size), countStyle: ByteCountFormatter.CountStyle.file)
    }
    
    public func sizeForItem(at filePath: String) -> UInt64 {
        let fileManager = FileManager.default
        guard fileManager.fileExists(atPath: filePath),
            let attributes = try? FileManager.default.attributesOfItem(atPath: filePath),
            let fileSize = attributes[FileAttributeKey.size] as? UInt64 else {
                return 0
        }
        
        return fileSize
    }
    
    // MARK: -
    public func doesFileExist(onDevice fileName: String, fileSize: UInt64, fileId: String, withFileType fileType: String) -> [String: Any] {
        var filePath: String!
        switch fileType {
        case KAAsset.audio.fileType:
            filePath = self.path(for: fileName, of: fileType, with: "")
        case KAAsset.image.fileType:
            filePath = self.path(for: fileName, of: fileType, with: "")
        case KAAsset.video.fileType:
            filePath = self.path(for: fileName, of: fileType, with: "")
        default:
            filePath = self.path(for: fileName, of: fileType, with: "")
        }
        
        var downloadStatus: KAAssetDownloadStatus = .notDownloaded
        if filePath.count > 0 {
            if FileManager.default.fileExists(atPath: filePath) {
                downloadStatus = self.assetDownloadStatus(with: fileName, of: fileSize, at: filePath, of: fileType)
                return ["filePath": filePath, "fileStatus": downloadStatus]
            }
        }
        if fileSize <= 0 {
            downloadStatus = .unknown
            return ["filePath": "", "fileStatus": downloadStatus]
        }
        return ["filePath": "", "fileStatus": downloadStatus]
    }
    
    func assetDownloadStatus(with fileName: String, of fileSize: UInt64, at filePath: String, of fileType: String) -> KAAssetDownloadStatus {
        do  {
            let attributes = try FileManager.default.attributesOfItem(atPath: filePath)
            let actualSize = attributes[FileAttributeKey.size] as! UInt64

            if fileSize == actualSize {
                return .completed
            } else if fileSize > actualSize {
                print("KREComponent Partially Downloaded(%d/%d)\n Waiting Till Downloaded", actualSize, fileSize)
                return .partial
            } else if actualSize == 0 {
                return .notDownloaded
            } else if fileSize == 0 && actualSize > 0 {
                if (fileType == KAAsset.image.fileType) {
                    if UIImage(contentsOfFile: filePath) != nil {
                        return .completed
                    }
                } else if (fileType == "video") || (fileType == "audio") {
                    let componentAsset = AVAsset(url: URL(fileURLWithPath: filePath))
                    if CMTimeGetSeconds(componentAsset.duration) > 0.0 {
                        return .completed
                    }
                } else if (fileType == "attachment") {
                    let file = FileHandle(forReadingAtPath: filePath)
                    if file != nil {
                        return .completed
                    }
                }
            }
            return .unknown
        } catch {
            return .unknown
        }
    }
}

// MARK: - UIImage Utilities
extension UIImage {
    func resizedImage(to destinationSize: CGSize) -> UIImage? {
        // the below values are regardless of orientation : for UIImages from Camera, width>height (landscape)
        let sourceSize = CGSize(width: self.size.width, height: self.size.height)
        if sourceSize.equalTo(destinationSize) {
            return self
        }
        var dstSize = destinationSize
        let scaleRatio: CGFloat = destinationSize.width / sourceSize.width
        let orient: UIImage.Orientation = imageOrientation
        var transform: CGAffineTransform = .identity
        switch orient {
        case .up:
            //EXIF = 1
            transform = .identity
            break
        case .upMirrored:
            //EXIF = 2
            transform = CGAffineTransform(translationX: sourceSize.width, y: 0.0)
            transform = transform.scaledBy(x: -1.0, y: 1.0)
            break
        case .down:
            //EXIF = 3
            transform = CGAffineTransform(translationX: sourceSize.width, y: sourceSize.height)
            transform = transform.rotated(by: .pi)
            break
        case .downMirrored:
            //EXIF = 4
            transform = CGAffineTransform(translationX: 0.0, y: sourceSize.height)
            transform = transform.scaledBy(x: 1.0, y: -1.0)
            break
        case .leftMirrored:
            //EXIF = 5
            dstSize = CGSize(width: dstSize.height, height: dstSize.width)
            transform = CGAffineTransform(translationX: sourceSize.height, y: sourceSize.width)
            transform = transform.scaledBy(x: -1.0, y: 1.0)
            transform = transform.rotated(by: CGFloat(3.0 * Double.pi/2))
            break
        case .left:
            //EXIF = 6
            dstSize = CGSize(width: dstSize.height, height: dstSize.width)
            transform = CGAffineTransform(translationX: 0.0, y: sourceSize.width)
            transform = transform.rotated(by: CGFloat(3.0 * Double.pi/2))
            break
        case .rightMirrored:
            //EXIF = 7
            dstSize = CGSize(width: dstSize.height, height: dstSize.width)
            transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
            transform = transform.rotated(by: CGFloat(Double.pi/2))
            break
        case .right:
            //EXIF = 8
            dstSize = CGSize(width: dstSize.height, height: dstSize.width)
            transform = CGAffineTransform(translationX: sourceSize.height, y: 0.0)
            transform = transform.rotated(by: CGFloat(Double.pi/2))
            break
        }
        /////////////////////////////////////////////////////////////////////////////
        // The actual resize: draw the image on a new context, applying a transform matrix
        UIGraphicsBeginImageContextWithOptions(dstSize, false, scale)
        let context = UIGraphicsGetCurrentContext()
        if context == nil {
            return nil
        }
        if orient == .right || orient == .left {
            context?.scaleBy(x: -scaleRatio, y: scaleRatio)
            context?.translateBy(x: -sourceSize.height, y: 0)
        } else {
            context?.scaleBy(x: scaleRatio, y: -scaleRatio)
            context?.translateBy(x: 0, y: -sourceSize.height)
        }
        context?.concatenate(transform)
        // we use sourceSize (and not dstSize) as the size to specify is in user space (and we use the CTM to apply a scaleRatio)
        context?.draw(cgImage!, in: CGRect(x: 0, y: 0, width: sourceSize.width, height: sourceSize.height))
        let resizedImage: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage
    }
    
    func resizedImageToFit(in boundingSize: CGSize, scaleIfSmaller scale: Bool) -> UIImage? {
        // get the image size (independant of imageOrientation)
        let sourceSize = CGSize(width: self.size.width, height: self.size.height)
        // not equivalent to self.size (which depends on the imageOrientation)!
        // adjust boundingSize to make it independant on imageOrientation too for farther computations
        let orient: UIImage.Orientation = imageOrientation
        var size: CGSize = boundingSize
        switch orient {
        case .left, .right, .leftMirrored, .rightMirrored:
            size = CGSize(width: boundingSize.height, height: boundingSize.width)
            break
        default:
            // NOP
            break
        }
        // Compute the target CGRect in order to keep aspect-ratio
        var dstSize: CGSize
        if !scale && (sourceSize.width < size.width) && (sourceSize.height < size.height) {
            //NSLog(@"Image is smaller, and we asked not to scale it in this case (scaleIfSmaller:NO)");
            dstSize = sourceSize
            // no resize (we could directly return 'self' here, but we draw the image anyway to take image orientation into account)
        } else {
            let wRatio: CGFloat = size.width / sourceSize.width
            let hRatio: CGFloat = size.height / sourceSize.height
            if wRatio < hRatio {
                // print("Width imposed, Height scaled ; ratio = %f",wRatio);
                dstSize = CGSize(width: size.width, height: CGFloat(sourceSize.height * wRatio))
            } else {
                // print("Height imposed, Width scaled ; ratio = %f",hRatio);
                dstSize = CGSize(width: CGFloat(sourceSize.width * hRatio), height: size.height)
            }
        }
        return resizedImage(to: dstSize)
    }
    
    // MARK: - UIImage Utilities
    func resize(_ image: UIImage?, withAntialiasing shouldAntialias: Bool, to targetSize: CGSize) -> UIImage? {
        let targetRect = CGRect(x: 0, y: 0, width: targetSize.width, height: targetSize.height)
        UIGraphicsBeginImageContextWithOptions(targetSize, false, 0)
        let context = UIGraphicsGetCurrentContext()
        context?.setShouldAntialias(shouldAntialias)
        context?.interpolationQuality = .high
        let flipVerticalTransform = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: targetSize.height)
        context?.concatenate(flipVerticalTransform)
        context?.draw(cgImage!, in: targetRect)
        let resizedImageRef = context!.makeImage()
        let resizedImage = UIImage(cgImage: resizedImageRef!)
        UIGraphicsEndImageContext()
        return resizedImage
    }
    
    // MARK: - crop image to rect
    public func crop(to rect: CGRect) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(rect.size, false, self.scale)
        
        self.draw(in: CGRect(x: -rect.origin.x, y: -rect.origin.y, width: self.size.width, height: self.size.height))
        
        let croppedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return croppedImage
    }
    
    // MARK: - rotate image by radians
    public func rotate(radians: CGFloat) -> UIImage {
        let rotatedSize = CGRect(origin: .zero, size: size).applying(CGAffineTransform(rotationAngle: CGFloat(radians))).integral.size
        UIGraphicsBeginImageContext(rotatedSize)
        if let context = UIGraphicsGetCurrentContext() {
            let origin = CGPoint(x: rotatedSize.width / 2.0, y: rotatedSize.height / 2.0)
            context.translateBy(x: origin.x, y: origin.y)
            context.rotate(by: radians)
            draw(in: CGRect(x: -origin.y, y: -origin.x, width: size.width, height: size.height))
            let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            return rotatedImage ?? self
        }
        
        return self
    }
}
