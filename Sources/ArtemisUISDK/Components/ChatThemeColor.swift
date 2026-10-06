import SwiftUI

extension Color {
    init(hexString: String?) {
        guard let hex = hexString?.trimmingCharacters(in: CharacterSet.alphanumerics.inverted),
              let value = UInt64(hex, radix: 16) else {
            self = .accentColor
            return
        }
        let rgb = hex.count == 6 ? value : value & 0xFFFFFF
        self.init(
            red: Double((rgb >> 16) & 0xFF) / 255,
            green: Double((rgb >> 8) & 0xFF) / 255,
            blue: Double(rgb & 0xFF) / 255
        )
    }
}
