import SwiftUI

struct VideoRichTemplate: View {
    let media: MediaContent
    let accentColor: Color

    var body: some View {
        MediaLinkTemplate(title: "Video", systemImage: "play.rectangle.fill", media: media, accentColor: accentColor)
    }
}
