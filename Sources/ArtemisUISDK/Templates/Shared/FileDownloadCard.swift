import SwiftUI

struct FileDownloadCard: View {
    let title: String
    let subtitle: String
    let url: String
    let accentColor: Color

    var body: some View {
        if let target = URL(string: url), target.isHTTP {
            Link(destination: target) { content }
        } else {
            content
        }
    }

    private var content: some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(TemplateStyle.text)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                if !subtitle.templateTrimmed.isEmpty {
                    Text(subtitle).templateBody().lineLimit(1)
                }
            }
            .layoutPriority(1)
            Spacer(minLength: 12)
            Text("Download")
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(accentColor)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .padding(.horizontal, 18)
                .frame(minHeight: 46)
                .frame(minWidth: 112)
                .background(accentColor.opacity(0.1))
                .clipShape(Capsule())
        }
        .templateCard(padding: 18)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
