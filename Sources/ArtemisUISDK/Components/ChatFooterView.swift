import SwiftUI

struct ChatFooterView: View {
    @Binding var text: String
    let enabled: Bool
    let canSend: Bool
    let placeholder: String
    let font: String?
    let theme: ChatTheme?
    let onSend: () -> Void
    let onAttach: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            Button(action: onAttach) {
                Image(systemName: "paperclip").font(.system(size: 20))
            }
            .accessibilityLabel("Add attachment")
            .foregroundStyle(Color(hexString: theme?.mutedTextColor))
            .disabled(!enabled)
            .hidden()
            .frame(width: 0)
            TextField(placeholder, text: $text)
                .font(font.map { .custom($0, size: 16) })
                .textFieldStyle(.plain)
                .disabled(!enabled)
                .onSubmit(onSend)
            Button(action: onSend) {
                Image(systemName: "paperplane.circle.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(canSend ? Color(hexString: theme?.primaryColor) : Color.secondary.opacity(0.4))
            }
            .accessibilityLabel("Send message")
            .disabled(!canSend)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(Color(hexString: theme?.composeBarBackgroundColor))
        .overlay(Capsule().stroke(Color(hexString: theme?.borderColor), lineWidth: 1))
        .clipShape(Capsule())
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color(hexString: theme?.backgroundColor))
    }
}
