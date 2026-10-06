import Foundation

extension URL {
    var isHTTP: Bool { ["http", "https"].contains(scheme?.lowercased()) }
}

extension String {
    var templateTrimmed: String { trimmingCharacters(in: .whitespacesAndNewlines) }

    var strippingHTMLTags: String {
        replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
            .replacingOccurrences(of: "&nbsp;", with: " ")
            .replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&lt;", with: "<")
            .replacingOccurrences(of: "&gt;", with: ">")
    }
}
