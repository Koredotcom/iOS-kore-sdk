import Foundation
import SwiftUI
import ArtemisSocketSDK

struct KPIRichTemplate: View {
    let kpi: KPITemplate
    let accentColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 8) {
                Text(kpi.label.uppercased()).templateSectionLabel()
                Text(kpi.displayValue)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(TemplateStyle.text)
                    .minimumScaleFactor(0.42)
                    .allowsTightening(true)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityLabel("\(kpi.label) \(kpi.displayValue)")
            }
            HStack(spacing: 8) {
                Image(systemName: trendIcon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(TemplateStyle.success)
                    .frame(width: 34, height: 34)
                    .background(TemplateStyle.success.opacity(0.14))
                    .clipShape(Circle())
                if let trend = kpi.trend, !trend.templateTrimmed.isEmpty {
                    Text(trend).templateBody()
                }
                Spacer()
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(TemplateStyle.kpiBackground)
        .overlay(RoundedRectangle(cornerRadius: TemplateStyle.cardRadius).stroke(accentColor.opacity(0.35), lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: TemplateStyle.cardRadius))
    }

    private var trendIcon: String {
        let trend = kpi.trend?.lowercased() ?? ""
        if trend.contains("down") { return "chart.line.downtrend.xyaxis" }
        return "chart.line.uptrend.xyaxis"
    }
}
