import Foundation
import SwiftUI
import ArtemisSocketSDK

struct FeedbackRichTemplate: View {
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
