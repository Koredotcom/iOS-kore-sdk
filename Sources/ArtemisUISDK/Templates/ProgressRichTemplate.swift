import Foundation
import SwiftUI
import ArtemisSocketSDK

struct ProgressRichTemplate: View {
    let progress: ProgressTemplate
    let accentColor: Color

    var body: some View {
        if progress.variant == "circle" {
            VStack(spacing: 10) {
                ZStack {
                    Circle().stroke(TemplateStyle.border, lineWidth: 8)
                    Circle()
                        .trim(from: 0, to: percent)
                        .stroke(accentColor, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                    Text("\(Int(percent * 100))%").templateTitle()
                }
                .frame(width: 92, height: 92)
                Text(progress.label ?? "Progress").templateSectionLabel()
            }
            .frame(maxWidth: .infinity)
        } else {
            VStack(alignment: .leading, spacing: 8) {
                Text(progress.label ?? "Progress").templateSectionLabel()
                GeometryReader { proxy in
                    ZStack(alignment: .leading) {
                        Capsule().fill(TemplateStyle.progressTrack)
                        Capsule()
                            .fill(LinearGradient(colors: [accentColor, accentColor.opacity(0.62)], startPoint: .leading, endPoint: .trailing))
                            .frame(width: proxy.size.width * percent)
                    }
                }
                .frame(height: 10)
                Text("\(Int(percent * 100))%").templateSectionLabel()
            }
        }
    }

    private var percent: Double { max(progress.max, 1) == 0 ? 0 : min(max(progress.value / max(progress.max, 1), 0), 1) }
}
