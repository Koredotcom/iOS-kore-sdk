import Foundation
import SwiftUI
import ArtemisSocketSDK

struct ChartRichTemplate: View {
    let chart: ChartTemplate
    let accentColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let title = chart.title, !title.templateTrimmed.isEmpty {
                Text(title).templateTitle()
            }
            let maxValue = max(chart.data.map(\.value).max() ?? 1, 1)
            ForEach(chart.data) { point in
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(point.label).templateBody()
                        Spacer()
                        Text(RichContentParser.displayString(point.value)).templateSectionLabel()
                    }
                    GeometryReader { proxy in
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(templateHexString: point.color) ?? accentColor)
                            .frame(width: max(4, proxy.size.width * CGFloat(point.value / maxValue)))
                    }
                    .frame(height: 10)
                    .background(TemplateStyle.progressTrack, in: RoundedRectangle(cornerRadius: 999))
                }
            }
        }
        .templateCard()
    }
}

private extension Color {
    init?(templateHexString: String?) {
        guard let hex = templateHexString?.trimmingCharacters(in: CharacterSet.alphanumerics.inverted),
              let value = UInt64(hex, radix: 16) else { return nil }
        let rgb = hex.count == 6 ? value : value & 0xFFFFFF
        self.init(red: Double((rgb >> 16) & 0xFF) / 255, green: Double((rgb >> 8) & 0xFF) / 255, blue: Double(rgb & 0xFF) / 255)
    }
}
