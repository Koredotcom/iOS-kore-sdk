import Foundation
import SwiftUI
import ArtemisSocketSDK

struct ChannelFallbackTemplate: View {
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
