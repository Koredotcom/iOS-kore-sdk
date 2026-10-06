import SwiftUI

struct OutlinedPillButtonStyle: ButtonStyle {
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
