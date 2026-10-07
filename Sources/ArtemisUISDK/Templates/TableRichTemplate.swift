import Foundation
import SwiftUI
import ArtemisSocketSDK

struct TableRichTemplate: View {
    let table: TableTemplate
    let accentColor: Color

    var body: some View {
        ScrollView(.horizontal, showsIndicators: true) {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 0) {
                    ForEach(table.columns) { column in
                        Cell(column.header, isHeader: true, accentColor: accentColor)
                    }
                }
                ForEach(Array(table.rows.prefix(table.maxVisibleRows ?? 10).enumerated()), id: \.offset) { _, row in
                    HStack(spacing: 0) {
                        ForEach(table.columns) { column in
                            Cell(RichContentParser.displayString(row[column.key]?.value), isHeader: false, accentColor: accentColor)
                        }
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: TemplateStyle.smallRadius))
            .overlay(RoundedRectangle(cornerRadius: TemplateStyle.smallRadius).stroke(TemplateStyle.border, lineWidth: 1))
        }
        .templateCard(padding: 0)
        .frame(maxWidth: .infinity, alignment: .leading)
        .clipped()
    }

    private struct Cell: View {
        let value: String
        let isHeader: Bool
        let accentColor: Color

        init(_ value: String, isHeader: Bool, accentColor: Color) {
            self.value = value
            self.isHeader = isHeader
            self.accentColor = accentColor
        }

        var body: some View {
            Text(value.isEmpty ? " " : value)
                .font(isHeader ? .caption.weight(.bold) : .caption)
                .lineLimit(2)
                .foregroundStyle(isHeader ? TemplateStyle.text : TemplateStyle.mutedText)
                .frame(minWidth: 106, minHeight: 42, alignment: .leading)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(isHeader ? accentColor.opacity(0.1) : Color.white)
                .overlay(Rectangle().stroke(TemplateStyle.border, lineWidth: 0.5))
        }
    }
}
