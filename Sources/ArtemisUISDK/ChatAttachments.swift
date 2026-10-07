import Foundation
import UniformTypeIdentifiers
import ArtemisSocketSDK

public struct ChatAttachment: Identifiable, Equatable, Sendable {
    public let id: String
    public let filename: String
    public let mimeType: String
    public let sizeBytes: Int64
    public init(id: String, filename: String, mimeType: String = "application/octet-stream", sizeBytes: Int64 = 0) {
        self.id = id; self.filename = filename; self.mimeType = mimeType; self.sizeBytes = sizeBytes
    }
    var icon: String {
        if mimeType.hasPrefix("image/") { return "photo" }
        if mimeType.hasPrefix("video/") { return "video" }
        if mimeType.hasPrefix("audio/") { return "waveform" }
        return "doc"
    }
    var detail: String {
        sizeBytes > 0 ? ByteCountFormatter.string(fromByteCount: sizeBytes, countStyle: .file) : mimeType
    }

    static func from(_ message: Message) -> [ChatAttachment] {
        let metadata = message.metadata?.mapValues(\.value) ?? [:]
        let custom = metadata["custom"] as? [String: Any]
        let raw = custom?["customerAttachments"] as? [[String: Any]] ?? []
        let refs = raw.compactMap { value -> ChatAttachment? in
            guard let id = value["id"] as? String ?? value["attachmentId"] as? String, !id.isEmpty else { return nil }
            return ChatAttachment(id: id, filename: value["filename"] as? String ?? value["fileName"] as? String ?? value["name"] as? String ?? "Attachment",
                mimeType: value["mimeType"] as? String ?? value["fileType"] as? String ?? "application/octet-stream",
                sizeBytes: max(0, (value["sizeBytes"] as? NSNumber ?? value["size"] as? NSNumber)?.int64Value ?? 0))
        }
        var seen = Set<String>()
        if !refs.isEmpty { return refs.filter { seen.insert($0.id).inserted } }
        let ids = metadata["attachmentIds"] as? [String] ?? message.attachmentIds ?? []
        let names = metadata["attachmentFilenames"] as? [String] ?? []
        let types = metadata["attachmentMimeTypes"] as? [String] ?? []
        let sizes = metadata["attachmentSizeBytes"] as? [NSNumber] ?? metadata["attachmentSizes"] as? [NSNumber] ?? []
        return ids.enumerated().compactMap { index, id in
            guard !id.isEmpty, seen.insert(id).inserted else { return nil }
            return ChatAttachment(id: id, filename: names.indices.contains(index) ? names[index] : "Attachment",
                mimeType: types.indices.contains(index) ? types[index] : "application/octet-stream",
                sizeBytes: sizes.indices.contains(index) ? max(0, sizes[index].int64Value) : 0)
        }
    }
}

@MainActor extension AgentChatViewModel {
    public var canAttach: Bool { status == .connected && !isUploadingAttachment && !isSending }
    public var canSend: Bool {
        canAttach && (!composeText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || !pendingAttachments.isEmpty)
    }

    public func removeAttachment(_ id: String) {
        guard !isSending else { return }
        pendingAttachments.removeAll { $0.id == id }
    }

    /// URLs from the document picker remain security-scoped until their uploads complete.
    public func uploadAttachments(_ urls: [URL], removeTemporaryFiles: Bool = false) {
        guard canAttach, let sdk, let sessionId = sdk.getSessionId(), !urls.isEmpty else {
            if removeTemporaryFiles { urls.forEach { Self.removePickerFile($0) } }
            return
        }
        isUploadingAttachment = true
        attachmentSessionId = sessionId
        uploadTask = Task { [weak self] in
            guard let self else { return }
            defer {
                if removeTemporaryFiles { urls.forEach { Self.removePickerFile($0) } }
                self.isUploadingAttachment = false
                self.uploadingFilename = nil
                self.uploadTask = nil
            }
            for url in urls {
                if Task.isCancelled || self.sdk !== sdk || sdk.getSessionId() != sessionId { break }
                self.uploadingFilename = url.lastPathComponent
                let accessed = url.startAccessingSecurityScopedResource()
                defer { if accessed { url.stopAccessingSecurityScopedResource() } }
                do {
                    let info = try url.resourceValues(forKeys: [.fileSizeKey, .contentTypeKey, .isRegularFileKey])
                    guard info.isRegularFile == true else { throw UIConfigurationError("Select a file, not a folder") }
                    let mime = info.contentType?.preferredMIMEType ?? UTType(filenameExtension: url.pathExtension)?.preferredMIMEType ?? "application/octet-stream"
                    let id = try await sdk.uploadAttachment(fileURL: url, contentType: mime)
                    guard !Task.isCancelled, self.sdk === sdk, sdk.getSessionId() == sessionId else { break }
                    self.pendingAttachments.append(ChatAttachment(id: id, filename: url.lastPathComponent, mimeType: mime, sizeBytes: Int64(info.fileSize ?? 0)))
                } catch {
                    if !Task.isCancelled { self.errorMessage = "Upload failed for \(url.lastPathComponent): \(error.localizedDescription)" }
                }
            }
        }
    }

    public func attachments(for message: Message) -> [ChatAttachment] {
        sentAttachments[message.id] ?? ChatAttachment.from(message)
    }

    public func attachmentDownloadURL(_ attachment: ChatAttachment) async -> URL? {
        guard let sdk else { return nil }
        do { return try await sdk.resolveAttachmentDownloadURL(attachmentId: attachment.id) }
        catch { errorMessage = error.localizedDescription; return nil }
    }

    private static func removePickerFile(_ url: URL) {
        let folder = url.deletingLastPathComponent()
        guard folder.lastPathComponent.hasPrefix("ArtemisPhoto-") || folder.lastPathComponent.hasPrefix("ArtemisCamera-"),
              folder.deletingLastPathComponent().standardizedFileURL == FileManager.default.temporaryDirectory.standardizedFileURL else { return }
        try? FileManager.default.removeItem(at: folder)
    }

    func resetAttachments() {
        uploadTask?.cancel()
        pendingAttachments.removeAll()
        sentAttachments.removeAll()
        attachmentSessionId = nil
    }
}
