import Foundation
import SwiftUI
#if canImport(ArtemisSocketPlugin)
import ArtemisSocketPlugin
#elseif canImport(artemis_socket_plugin)
import artemis_socket_plugin
#endif

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
