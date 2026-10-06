import SwiftUI

struct HTMLRichTemplate: View {
    let content: String
    let accentColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("HTML").templateSectionLabel()
            Text(content.strippingHTMLTags).templateBody().textSelection(.enabled)
        }
        .templateCard()
    }
}
