import SwiftUI

struct PlaceholderIcon: View {
    let systemImage: String
    let accentColor: Color

    var body: some View {
        Image(systemName: systemImage)
            .font(.largeTitle)
            .foregroundStyle(accentColor)
            .frame(maxWidth: .infinity, minHeight: 160)
            .background(accentColor.opacity(0.08))
    }
}
