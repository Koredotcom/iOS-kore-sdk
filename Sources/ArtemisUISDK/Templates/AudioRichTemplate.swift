import SwiftUI

struct AudioRichTemplate: View {
    let media: MediaContent
    let accentColor: Color

    var body: some View {
        MediaLinkTemplate(title: "Audio", systemImage: "waveform", media: media, accentColor: accentColor)
    }
}
