import SwiftUI

enum TemplateStyle {
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

extension View {
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
