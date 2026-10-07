import Foundation
import SwiftUI
import ArtemisSocketSDK

struct QuickRepliesTemplate: View {
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
