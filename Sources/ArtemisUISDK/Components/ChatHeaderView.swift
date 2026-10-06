import SwiftUI

struct ChatHeaderView: View {
    let title: String
    let theme: ChatTheme?
    let onClose: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Text(String(title.trimmingCharacters(in: .whitespaces).first ?? "A"))
                .font(.headline)
                .foregroundStyle(headerText)
                .frame(width: 40, height: 40)
                .background(headerText.opacity(0.2))
                .clipShape(Circle())
            Text(title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(headerText)
                .lineLimit(1)
            Spacer()
            Button(action: onClose) {
                Image(systemName: "xmark").font(.system(size: 15, weight: .bold))
            }
            .foregroundStyle(headerText)
            .padding(.trailing, 5)
        }
        .padding(.horizontal, 12)
        .frame(height: 72)
        .background(headerColor)
        .animation(.easeInOut, value: theme?.headerBackgroundColor)
    }

    private var headerColor: Color { Color(hexString: theme?.headerBackgroundColor) }
    private var headerText: Color { Color(hexString: theme?.headerTextColor) }
}
