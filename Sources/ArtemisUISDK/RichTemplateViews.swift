import Foundation
import SwiftUI
#if canImport(ArtemisSocketPlugin)
import ArtemisSocketPlugin
#elseif canImport(artemis_socket_plugin)
import artemis_socket_plugin
#endif

struct RichContentTemplatesView: View {
    let message: Message
    let context: RichTemplateContext
    var suppressedTypes: Set<String> = []

    private var richContent: RichContent? { message.richContent }
    private var actions: ActionSet? { message.actions }

    var body: some View {
        if richContent != nil || actions != nil {
            VStack(alignment: .leading, spacing: TemplateStyle.sectionSpacing) {
                if !isSuppressed(RichTemplateTypes.image), let image = richContent?.image { MediaImageTemplate(image: image, accentColor: context.accentColor) }
                if !isSuppressed(RichTemplateTypes.html), let html = richContent?.html?.trimmed, !html.isEmpty { TextTemplate(title: "HTML", content: html, accentColor: context.accentColor) }
                if !isSuppressed(RichTemplateTypes.video), let video = richContent?.video { MediaLinkTemplate(title: "Video", systemImage: "play.rectangle.fill", media: video, accentColor: context.accentColor) }
                if !isSuppressed(RichTemplateTypes.audio), let audio = richContent?.audio { MediaLinkTemplate(title: "Audio", systemImage: "waveform", media: audio, accentColor: context.accentColor) }
                if !isSuppressed(RichTemplateTypes.file), let file = richContent?.file { FileTemplate(file: file, accentColor: context.accentColor) }
                if !isSuppressed(RichTemplateTypes.list), let list = richContent?.list { ListRichTemplate(list: list, accentColor: context.accentColor) }
                if !isSuppressed(RichTemplateTypes.kpi), let kpi = richContent?.kpi { KPIRichTemplate(kpi: kpi, accentColor: context.accentColor) }
                if !isSuppressed(RichTemplateTypes.table), let table = richContent?.table { TableRichTemplate(table: table, accentColor: context.accentColor) }
                if !isSuppressed(RichTemplateTypes.chart), let chart = richContent?.chart { ChartRichTemplate(chart: chart, accentColor: context.accentColor) }
                if !isSuppressed(RichTemplateTypes.form), let form = richContent?.form { FormRichTemplate(form: form, messageId: message.id, context: context) }
                if !isSuppressed(RichTemplateTypes.progress), let progress = richContent?.progress { ProgressRichTemplate(progress: progress, accentColor: context.accentColor) }
                if !isSuppressed(RichTemplateTypes.feedback), let feedback = richContent?.feedback { FeedbackRichTemplate(feedback: feedback, messageId: message.id, context: context) }
                if !isSuppressed(RichTemplateTypes.actions), let actions { ActionsRichTemplate(actions: actions, context: context) }
                if !isSuppressed(RichTemplateTypes.quickReplies), let replies = richContent?.quickReplies { QuickRepliesTemplate(replies: replies, messageId: message.id, context: context) }
                if !isSuppressed(RichTemplateTypes.channelFallback) {
                    ForEach(richContent?.channelFallbackItems ?? []) { item in ChannelFallbackTemplate(item: item) }
                }
                if !isSuppressed("carousel"), let carousel = richContent?.carousel { CarouselRichTemplate(carousel: carousel, accentColor: context.accentColor, submitAction: context.submitAction, renderId: message.id) }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func isSuppressed(_ type: String) -> Bool { suppressedTypes.contains(type) }
}

private struct CarouselRichTemplate: View {
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
                            if let subtitle = card.subtitle, !subtitle.trimmed.isEmpty {
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

private struct MediaImageTemplate: View {
    let image: MediaContent
    let accentColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let url = URL(string: image.url) {
                Link(destination: url) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let loaded): loaded.resizable().scaledToFill()
                        case .failure: PlaceholderIcon(systemImage: "photo", accentColor: accentColor)
                        default: ProgressView()
                        }
                    }
                    .frame(maxWidth: .infinity, minHeight: 170, maxHeight: 230)
                    .clipShape(RoundedRectangle(cornerRadius: TemplateStyle.imageRadius))
                }
            }
            if let caption = image.caption ?? image.alt, !caption.trimmed.isEmpty {
                Text(caption).templateSectionLabel()
            }
        }
    }
}

private struct MediaLinkTemplate: View {
    let title: String
    let systemImage: String
    let media: MediaContent
    let accentColor: Color

    var body: some View {
        LinkCard(title: title, subtitle: media.caption ?? media.alt ?? media.url, systemImage: systemImage, url: media.url, accentColor: accentColor)
    }
}

private struct FileTemplate: View {
    let file: FileContent
    let accentColor: Color

    var body: some View {
        FileDownloadCard(title: file.filename.isEmpty ? "Attachment" : file.filename, subtitle: fileSubtitle, url: file.url, accentColor: accentColor)
    }

    private var fileSubtitle: String {
        let size = file.sizeBytes.map(Self.formatBytes)
        return [file.mimeType, size].compactMap { $0 }.joined(separator: " · ")
    }

    private static func formatBytes(_ bytes: Int) -> String {
        ByteCountFormatter.string(fromByteCount: Int64(bytes), countStyle: .file)
    }
}

private struct ListRichTemplate: View {
    let list: ListTemplate
    let accentColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let title = list.title, !title.trimmed.isEmpty {
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
                        if let subtitle = item.subtitle, !subtitle.trimmed.isEmpty {
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

private struct KPIRichTemplate: View {
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
                if let trend = kpi.trend, !trend.trimmed.isEmpty {
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

private struct TableRichTemplate: View {
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

private struct ChartRichTemplate: View {
    let chart: ChartTemplate
    let accentColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let title = chart.title, !title.trimmed.isEmpty {
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
                            .fill(Color(hexString: point.color) ?? accentColor)
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

private struct FormRichTemplate: View {
    let form: FormTemplate
    let messageId: String
    let context: RichTemplateContext
    @State private var values: [String: String] = [:]
    @State private var submitted = false

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            if let title = form.title, !title.trimmed.isEmpty {
                Text(title).templateTitle()
            }
            ForEach(form.fields) { field in
                FieldView(field: field, value: binding(for: field), accentColor: context.accentColor, submitted: submitted)
            }
            Button(form.submitLabel ?? "Submit") {
                submitted = true
                context.submitAction("form-submit", encodeFormSubmitPayload(resolvedValues), resolvedValues, messageId)
            }
            .buttonStyle(FilledCapsuleButtonStyle(accentColor: context.accentColor))
            .disabled(!isValid || submitted)
        }
        .templateCard(padding: 18)
        .onAppear {
            for field in form.fields where values[field.id] == nil {
                values[field.id] = field.value ?? ""
            }
        }
    }

    private var resolvedValues: [String: String] {
        Dictionary(uniqueKeysWithValues: form.fields.map { ($0.id, values[$0.id] ?? $0.value ?? "") })
    }

    private var isValid: Bool {
        form.fields.allSatisfy { !$0.required || !(values[$0.id] ?? $0.value ?? "").trimmed.isEmpty }
    }

    private func binding(for field: FormTemplateField) -> Binding<String> {
        Binding(get: { values[field.id] ?? field.value ?? "" }, set: { values[field.id] = $0 })
    }

    private struct FieldView: View {
        let field: FormTemplateField
        @Binding var value: String
        let accentColor: Color
        let submitted: Bool

        var body: some View {
            VStack(alignment: .leading, spacing: 6) {
                if field.type == "select", !field.options.isEmpty {
                    Menu {
                        ForEach(field.options) { option in
                            Button(option.label) { value = option.id }
                        }
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                if !value.isEmpty {
                                    Text(field.label + (field.required ? " *" : "")).font(.caption2.weight(.semibold)).foregroundStyle(TemplateStyle.mutedText)
                                }
                                Text(selectedLabel)
                                    .foregroundStyle(value.isEmpty ? TemplateStyle.mutedText : TemplateStyle.text)
                            }
                            Spacer()
                            Image(systemName: "chevron.down").foregroundStyle(TemplateStyle.mutedText)
                        }
                        .templateInputBorder(accentColor: accentColor, focused: !value.isEmpty)
                    }
                    .disabled(submitted)
                } else {
                    TextField(field.placeholder ?? field.label, text: $value)
                        .formKeyboardType(field.inputType)
                        .disabled(submitted)
                        .templateTextField(accentColor: accentColor)
                }
            }
        }

        private var selectedLabel: String {
            field.options.first { $0.id == value }?.label ?? field.placeholder ?? field.label
        }

    }
}

private struct ProgressRichTemplate: View {
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

private struct FeedbackRichTemplate: View {
    let feedback: FeedbackTemplate
    let messageId: String
    let context: RichTemplateContext
    @State private var selected: Int?
    @State private var submitted = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(feedback.prompt).font(.system(size: 22, weight: .bold)).foregroundStyle(TemplateStyle.text)
            if feedback.type == "thumbs" {
                HStack(spacing: 10) {
                    feedbackOption(value: 1, label: "Thumbs up", icon: "hand.thumbsup")
                    feedbackOption(value: 0, label: "Thumbs down", icon: "hand.thumbsdown")
                }
            } else if feedback.type == "stars" {
                HStack(spacing: 8) {
                    ForEach(1...max(1, feedback.max), id: \.self) { rating in
                        Button {
                            selected = rating
                        } label: {
                            Image(systemName: (selected ?? 0) >= rating ? "star.fill" : "star")
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundStyle((selected ?? 0) >= rating ? context.accentColor : TemplateStyle.mutedText)
                                .frame(width: 44, height: 44)
                                .background(((selected ?? 0) >= rating ? context.accentColor.opacity(0.12) : Color.white), in: RoundedRectangle(cornerRadius: TemplateStyle.smallRadius))
                                .overlay(RoundedRectangle(cornerRadius: TemplateStyle.smallRadius).stroke((selected ?? 0) >= rating ? context.accentColor : TemplateStyle.border, lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                        .disabled(submitted)
                    }
                }
            } else {
                VStack(spacing: 10) {
                    ForEach(1...max(1, feedback.max), id: \.self) { rating in
                        Button {
                            selected = rating
                        } label: {
                            Text("\(rating)")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(TemplateStyle.text)
                                .frame(maxWidth: .infinity, minHeight: 48)
                                .background(selected == rating ? context.accentColor.opacity(0.18) : Color.white)
                                .overlay(RoundedRectangle(cornerRadius: TemplateStyle.smallRadius).stroke(selected == rating ? context.accentColor : TemplateStyle.border, lineWidth: selected == rating ? 1.5 : 1))
                                .clipShape(RoundedRectangle(cornerRadius: TemplateStyle.smallRadius))
                        }
                        .buttonStyle(.plain)
                        .disabled(submitted)
                    }
                }
            }
            if feedback.type != "thumbs" {
                Button("Submit") {
                    submitSelected()
                }
                .buttonStyle(FilledCapsuleButtonStyle(accentColor: context.accentColor))
                .disabled(selected == nil || submitted)
            }
        }
        .templateCard(padding: 20)
    }

    private func feedbackOption(value: Int, label: String, icon: String) -> some View {
        Button {
            selected = value
            submitSelected()
        } label: {
            Label(label, systemImage: icon)
                .frame(maxWidth: .infinity, minHeight: 44)
        }
        .buttonStyle(OutlinedPillButtonStyle(accentColor: context.accentColor, isSelected: selected == value))
        .disabled(submitted)
    }

    private func submitSelected() {
        guard let selected, !submitted else { return }
        submitted = true
        let ratingType = feedback.type == "thumbs" ? "thumbs" : "star"
        context.submitFeedback(messageId, ratingType, selected, messageId)
    }
}

private struct ActionsRichTemplate: View {
    let actions: ActionSet
    let context: RichTemplateContext
    @State private var values: [String: String] = [:]
    @State private var usedButtonIds: Set<String> = []

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(actions.elements) { element in
                switch element.type {
                case "select":
                    Menu {
                        ForEach(element.options) { option in
                            Button(option.label) { values[element.id] = option.id }
                        }
                    } label: {
                        HStack {
                            Text(values[element.id].flatMap { value in element.options.first { $0.id == value }?.label } ?? element.label)
                                .foregroundStyle((values[element.id] ?? "").isEmpty ? TemplateStyle.mutedText : TemplateStyle.text)
                            Spacer()
                            Image(systemName: "chevron.down").foregroundStyle(TemplateStyle.mutedText)
                        }
                        .templateInputBorder(accentColor: context.accentColor, focused: !(values[element.id] ?? "").isEmpty)
                    }
                    .onChange(of: values[element.id] ?? "") { newValue in
                        guard !newValue.isEmpty, actions.submitId == nil else { return }
                        context.submitAction(element.id, newValue, nil, actions.renderId)
                    }
                case "input":
                    TextField(element.placeholder ?? element.label, text: binding(for: element))
                        .templateTextField(accentColor: context.accentColor)
                default:
                    Button(element.label) {
                        usedButtonIds.insert(element.id)
                        context.submitAction(element.id, element.value ?? element.label, nil, actions.renderId)
                    }
                    .buttonStyle(OutlinedPillButtonStyle(accentColor: context.accentColor, isSelected: usedButtonIds.contains(element.id)))
                    .disabled(usedButtonIds.contains(element.id))
                }
            }
            if let submitId = actions.submitId, !submitId.trimmed.isEmpty {
                Button(actions.submitLabel ?? "Submit") {
                    context.submitAction(submitId, nil, values, actions.renderId)
                }
                .buttonStyle(FilledCapsuleButtonStyle(accentColor: context.accentColor))
            }
        }
    }

    private func binding(for element: ActionElement) -> Binding<String> {
        Binding(get: { values[element.id] ?? element.value ?? "" }, set: { values[element.id] = $0 })
    }
}

private struct QuickRepliesTemplate: View {
    let replies: [QuickReply]
    let messageId: String
    let context: RichTemplateContext
    @State private var used: Set<String> = []

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 118), spacing: 8, alignment: .leading)], alignment: .leading, spacing: 8) {
                ForEach(replies) { reply in
                    Button(reply.label) {
                        used.insert(reply.id)
                        context.submitAction(reply.id, reply.label, nil, messageId)
                    }
                    .buttonStyle(OutlinedPillButtonStyle(accentColor: context.accentColor, isSelected: used.contains(reply.id)))
                    .disabled(used.contains(reply.id))
                }
        }
    }
}

private struct ChannelFallbackTemplate: View {
    let item: ChannelFallbackItem

    var body: some View {
        DisclosureGroup(channelTitle) {
            Text(item.payload)
                .font(.system(.caption, design: .monospaced))
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 6)
        }
        .font(.caption)
        .templateCard(padding: 12)
    }

    private var channelTitle: String {
        switch item.type {
        case "adaptive_card": return "Adaptive Card payload"
        case "slack": return "Slack Block Kit payload"
        case "ag_ui": return "AG-UI payload"
        case "whatsapp": return "WhatsApp payload"
        default: return "Channel fallback payload"
        }
    }
}

private struct TextTemplate: View {
    let title: String
    let content: String
    let accentColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).templateSectionLabel()
            Text(content.strippingHTMLTags).templateBody().textSelection(.enabled)
        }
        .templateCard()
    }
}

private struct LinkCard: View {
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
                if !subtitle.trimmed.isEmpty {
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

private struct FileDownloadCard: View {
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
                if !subtitle.trimmed.isEmpty {
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

private struct PlaceholderIcon: View {
    let systemImage: String
    let accentColor: Color

    var body: some View {
        Image(systemName: systemImage)
            .font(.largeTitle)
            .foregroundStyle(accentColor)
            .frame(maxWidth: .infinity, minHeight: 160)
            .background(accentColor.opacity(0.08))
    }
}

private enum TemplateStyle {
    static let sectionSpacing: CGFloat = 14
    static let cardRadius: CGFloat = 18
    static let smallRadius: CGFloat = 12
    static let imageRadius: CGFloat = 14

    static let text = Color(red: 0.12, green: 0.13, blue: 0.16)
    static let mutedText = Color(red: 0.43, green: 0.50, blue: 0.61)
    static let border = Color(red: 0.88, green: 0.90, blue: 0.93)
    static let placeholder = Color(red: 0.90, green: 0.93, blue: 0.96)
    static let kpiBackground = Color(red: 0.94, green: 0.97, blue: 1.0)
    static let progressTrack = Color(red: 0.40, green: 0.47, blue: 0.57)
    static let success = Color(red: 0.10, green: 0.62, blue: 0.38)
}

private struct OutlinedPillButtonStyle: ButtonStyle {
    let accentColor: Color
    var isSelected = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 15, weight: .semibold))
            .lineLimit(1)
            .minimumScaleFactor(0.8)
            .foregroundStyle(accentColor)
            .padding(.horizontal, 16)
            .frame(minHeight: 42)
            .frame(maxWidth: .infinity)
            .background((isSelected ? accentColor.opacity(0.18) : Color.clear).opacity(configuration.isPressed ? 0.8 : 1))
            .overlay(Capsule().stroke(accentColor, lineWidth: 1.5))
            .clipShape(Capsule())
            .opacity(configuration.isPressed ? 0.75 : 1)
    }
}

private struct FilledCapsuleButtonStyle: ButtonStyle {
    let accentColor: Color
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .semibold))
            .foregroundStyle(Color.white)
            .padding(.horizontal, 20)
            .frame(minHeight: 50)
            .frame(maxWidth: .infinity)
            .background((isEnabled ? accentColor : accentColor.opacity(0.45)).opacity(configuration.isPressed ? 0.78 : 1))
            .clipShape(Capsule())
    }
}

private extension View {
    func templateCard(padding: CGFloat = 14) -> some View {
        self
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: TemplateStyle.cardRadius))
            .overlay(RoundedRectangle(cornerRadius: TemplateStyle.cardRadius).stroke(TemplateStyle.border, lineWidth: 1))
    }

    func templateTitle() -> some View {
        font(.system(size: 17, weight: .bold))
            .foregroundStyle(TemplateStyle.text)
    }

    func templateBody() -> some View {
        font(.system(size: 15, weight: .regular))
            .foregroundStyle(TemplateStyle.mutedText)
    }

    func templateSectionLabel() -> some View {
        font(.system(size: 14, weight: .bold))
            .foregroundStyle(TemplateStyle.mutedText)
    }

    func outlinedPill(accentColor: Color) -> some View {
        font(.system(size: 15, weight: .semibold))
            .foregroundStyle(accentColor)
            .padding(.horizontal, 16)
            .frame(minHeight: 42)
            .overlay(Capsule().stroke(accentColor, lineWidth: 1.5))
            .clipShape(Capsule())
    }

    func templateInputBorder(accentColor: Color, focused: Bool) -> some View {
        padding(.horizontal, 14)
            .frame(minHeight: 58)
            .background(Color.white)
            .overlay(RoundedRectangle(cornerRadius: TemplateStyle.smallRadius).stroke(focused ? accentColor.opacity(0.75) : TemplateStyle.border, lineWidth: focused ? 1.4 : 1))
            .clipShape(RoundedRectangle(cornerRadius: TemplateStyle.smallRadius))
    }

    func templateTextField(accentColor: Color) -> some View {
        font(.system(size: 16, weight: .regular))
            .foregroundStyle(TemplateStyle.text)
            .padding(.horizontal, 14)
            .frame(minHeight: 58)
            .background(Color.white)
            .overlay(RoundedRectangle(cornerRadius: TemplateStyle.smallRadius).stroke(TemplateStyle.border, lineWidth: 1))
            .clipShape(RoundedRectangle(cornerRadius: TemplateStyle.smallRadius))
    }

    @ViewBuilder func formKeyboardType(_ inputType: String?) -> some View {
#if os(iOS)
        switch inputType {
        case "number": keyboardType(.decimalPad)
        case "email": keyboardType(.emailAddress)
        case "phone": keyboardType(.phonePad)
        default: self
        }
#else
        self
#endif
    }
}

private extension URL {
    var isHTTP: Bool { ["http", "https"].contains(scheme?.lowercased()) }
}

private extension String {
    var trimmed: String { trimmingCharacters(in: .whitespacesAndNewlines) }

    var strippingHTMLTags: String {
        replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
            .replacingOccurrences(of: "&nbsp;", with: " ")
            .replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&lt;", with: "<")
            .replacingOccurrences(of: "&gt;", with: ">")
    }
}

private func encodeFormSubmitPayload(_ values: [String: String]) -> String {
    guard JSONSerialization.isValidJSONObject(values),
          let data = try? JSONSerialization.data(withJSONObject: values, options: [.sortedKeys]),
          let encoded = String(data: data, encoding: .utf8) else {
        return "{}"
    }
    return encoded
}

private extension Color {
    init?(hexString: String?) {
        guard let hex = hexString?.trimmingCharacters(in: CharacterSet.alphanumerics.inverted),
              let value = UInt64(hex, radix: 16) else { return nil }
        let rgb = hex.count == 6 ? value : value & 0xFFFFFF
        self.init(red: Double((rgb >> 16) & 0xFF) / 255, green: Double((rgb >> 8) & 0xFF) / 255, blue: Double(rgb & 0xFF) / 255)
    }
}
