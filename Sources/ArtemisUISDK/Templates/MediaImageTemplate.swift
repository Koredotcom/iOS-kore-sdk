import Foundation
import SwiftUI
import ArtemisSocketSDK

struct MediaImageTemplate: View {
    let image: MediaContent
    let accentColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let url = URL(string: image.url) {
                Link(destination: url) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let loaded): loaded.resizable().scaledToFill()
                        case .failure: PlaceholderIcon(systemImage: "photo", accentColor: accentColor)
                        default: ProgressView()
                        }
                    }
                    .frame(maxWidth: .infinity, minHeight: 170, maxHeight: 230)
                    .clipShape(RoundedRectangle(cornerRadius: TemplateStyle.imageRadius))
                }
            }
            if let caption = image.caption ?? image.alt, !caption.templateTrimmed.isEmpty {
                Text(caption).templateSectionLabel()
            }
        }
    }
}
