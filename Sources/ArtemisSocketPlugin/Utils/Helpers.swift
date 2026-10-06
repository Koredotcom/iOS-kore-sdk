import Foundation

enum ArtemisLogger {
    private static var enabled = false
    private static var logLevel = "info"
    private static var printToConsole = false

    static func configure(enabled: Bool, logLevel: String, printToConsole: Bool) {
        self.enabled = enabled
        self.logLevel = logLevel
        self.printToConsole = printToConsole
    }

    static func debug(_ message: String, metadata: [String: Any] = [:]) {
        log("DEBUG", message, metadata: metadata)
    }

    static func info(_ message: String, metadata: [String: Any] = [:]) {
        log("INFO", message, metadata: metadata)
    }

    static func warning(_ message: String, metadata: [String: Any] = [:]) {
        log("WARNING", message, metadata: metadata)
    }

    static func error(_ message: String, _ error: Error? = nil, metadata: [String: Any] = [:]) {
        var meta = metadata
        if let error { meta["error"] = error.localizedDescription }
        log("ERROR", message, metadata: meta)
    }

    private static func log(_ level: String, _ message: String, metadata: [String: Any]) {
        guard enabled || printToConsole else { return }
        guard shouldLog(level: level) else { return }

        let metaString = metadata.isEmpty ? "" : " \(metadata)"
        let line = "[ArtemisSDK][\(level)] \(message)\(metaString)"

        if printToConsole {
            print(line)
        }
    }

    private static func shouldLog(level: String) -> Bool {
        let levels = ["debug": 0, "info": 1, "warning": 2, "error": 3]
        let configured = levels[logLevel.lowercased()] ?? 1
        let current = levels[level.lowercased()] ?? 1
        return current >= configured
    }
}

enum EndpointNormalizer {
    static func normalizeHttpEndpoint(_ endpoint: String) -> String {
        var value = endpoint.trimmingCharacters(in: .whitespacesAndNewlines)
        while value.hasSuffix("/") {
            value.removeLast()
        }
        return value
    }

    static func normalizeWebSocketEndpoint(_ endpoint: String) -> String {
        var value = normalizeHttpEndpoint(endpoint)
        if value.hasPrefix("https://") {
            value = "wss://" + value.dropFirst("https://".count)
        } else if value.hasPrefix("http://") {
            value = "ws://" + value.dropFirst("http://".count)
        }
        return value
    }
}

enum WebSocketAuth {
    static func buildTicketProtocols(_ ticket: String) -> [String] {
        ["sdk-ticket", ticket]
    }

    static func buildTokenProtocols(_ token: String) -> [String] {
        ["sdk-auth", token]
    }

    static func protocolHeaderValue(_ protocols: [String]) -> String {
        protocols.joined(separator: ", ")
    }
}

struct SDKSessionScope: Sendable {
    let tenantId: String
    let projectId: String
    let channelId: String
    let deploymentId: String?
    let permissions: [String]
    let showActivityUpdates: Bool
}

enum JSONValue {
    static func anySendableDictionary(from dict: [String: Any]?) -> [String: AnySendable]? {
        guard let dict else { return nil }
        return dict.mapValues { AnySendable($0) }
    }

    static func dictionary(from sendable: [String: AnySendable]?) -> [String: Any]? {
        guard let sendable else { return nil }
        return sendable.mapValues { $0.value }
    }
}
