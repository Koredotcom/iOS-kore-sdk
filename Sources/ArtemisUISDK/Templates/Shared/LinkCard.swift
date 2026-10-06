import SwiftUI

struct LinkCard: View {
    let title: String
    let subtitle: String
    let systemImage: String
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
        HStack(spacing: 12) {
            Image(systemName: systemImage).foregroundStyle(accentColor).frame(width: 28, height: 28)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.subheadline.weight(.semibold))
                if !subtitle.templateTrimmed.isEmpty {
                    Text(subtitle).font(.caption).foregroundStyle(.secondary).lineLimit(2)
                }
            }
            Spacer()
            Image(systemName: "arrow.up.right.square").foregroundStyle(accentColor)
        }
        .padding(12)
        .background(Color.secondary.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
