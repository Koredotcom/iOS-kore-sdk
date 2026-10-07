import Foundation
import SwiftUI
import ArtemisSocketSDK

struct CarouselRichTemplate: View {
    let carousel: CarouselTemplate
    let accentColor: Color
    let submitAction: (String, String?, [String: String]?, String?) -> Void
    let renderId: String

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: 12) {
                ForEach(Array(carousel.cards.enumerated()), id: \.offset) { _, card in
                    VStack(alignment: .leading, spacing: 0) {
                        if let image = card.imageURL, let url = URL(string: image) {
                            AsyncImage(url: url) { loaded in loaded.resizable().scaledToFill() } placeholder: { TemplateStyle.placeholder }
                                .frame(width: 220, height: 130)
                                .clipped()
                        }
                        VStack(alignment: .leading, spacing: 10) {
                            Text(card.title).templateTitle().lineLimit(2)
                            if let subtitle = card.subtitle, !subtitle.templateTrimmed.isEmpty {
                                Text(subtitle).templateBody().lineLimit(3)
                            }
                            if let rawURL = card.defaultActionURL, let url = URL(string: rawURL), url.isHTTP {
                                Link("Open", destination: url).outlinedPill(accentColor: accentColor)
                            }
                            ForEach(Array(card.buttons.enumerated()), id: \.offset) { _, button in
                                Button(button.label) {
                                    submitAction(button.id, button.label, nil, renderId)
                                }
                                .buttonStyle(OutlinedPillButtonStyle(accentColor: accentColor))
                            }
                        }
                        .padding(14)
                    }
                    .frame(width: 220, alignment: .leading)
                    .templateCard()
                }
            }
            .padding(.vertical, 2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .clipped()
    }
}
