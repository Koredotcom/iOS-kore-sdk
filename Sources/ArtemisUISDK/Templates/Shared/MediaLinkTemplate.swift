import SwiftUI

struct MediaLinkTemplate: View {
    let title: String
    let systemImage: String
    let media: MediaContent
    let accentColor: Color

    var body: some View {
        LinkCard(title: title, subtitle: media.caption ?? media.alt ?? media.url, systemImage: systemImage, url: media.url, accentColor: accentColor)
    }
}
