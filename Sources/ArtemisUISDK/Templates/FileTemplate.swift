import Foundation
import SwiftUI
import ArtemisSocketSDK

struct FileTemplate: View {
    let file: FileContent
    let accentColor: Color

    var body: some View {
        FileDownloadCard(title: file.filename.isEmpty ? "Attachment" : file.filename, subtitle: fileSubtitle, url: file.url, accentColor: accentColor)
    }

    private var fileSubtitle: String {
        let size = file.sizeBytes.map(Self.formatBytes)
        return [file.mimeType, size].compactMap { $0 }.joined(separator: " · ")
    }

    private static func formatBytes(_ bytes: Int) -> String {
        ByteCountFormatter.string(fromByteCount: Int64(bytes), countStyle: .file)
    }
}
