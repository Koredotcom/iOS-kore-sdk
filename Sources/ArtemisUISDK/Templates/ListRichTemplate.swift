import Foundation
import SwiftUI
import ArtemisSocketSDK

struct ListRichTemplate: View {
    let list: ListTemplate
    let accentColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let title = list.title, !title.templateTrimmed.isEmpty {
                Text(title).templateSectionLabel()
            }
            ForEach(list.items) { item in
                HStack(spacing: 12) {
                    if let imageURL = item.imageURL, let url = URL(string: imageURL) {
                        AsyncImage(url: url) { image in image.resizable().scaledToFill() } placeholder: { Color.secondary.opacity(0.12) }
                            .frame(width: 52, height: 52)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.title).templateTitle()
                        if let subtitle = item.subtitle, !subtitle.templateTrimmed.isEmpty {
                            Text(subtitle).templateBody().lineLimit(2)
                        }
                    }
                    Spacer(minLength: 8)
                    if let rawURL = item.defaultActionURL, let url = URL(string: rawURL), url.isHTTP {
                        Link(destination: url) { Image(systemName: "arrow.up.right.square").foregroundStyle(accentColor) }
                    }
                }
                .padding(14)
                .templateCard()
            }
        }
    }
}
