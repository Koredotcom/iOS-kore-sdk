import Foundation
import SwiftUI
import ArtemisSocketSDK

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
                if !isSuppressed(RichTemplateTypes.html), let html = richContent?.html?.templateTrimmed, !html.isEmpty { HTMLRichTemplate(content: html, accentColor: context.accentColor) }
                if !isSuppressed(RichTemplateTypes.video), let video = richContent?.video { VideoRichTemplate(media: video, accentColor: context.accentColor) }
                if !isSuppressed(RichTemplateTypes.audio), let audio = richContent?.audio { AudioRichTemplate(media: audio, accentColor: context.accentColor) }
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
