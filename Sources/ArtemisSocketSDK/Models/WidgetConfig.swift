import Foundation

/// Server-provided widget configuration from init/refresh response.
public struct WidgetConfig: Sendable {
    public let theme: WidgetTheme?
    public let themeId: String?
    public let themeName: String?
    public let welcomeMessage: String?
    public let placeholderText: String?
    public let launcherWelcomeMessage: String?
    public let connectingStatusText: String?
    public let raw: [String: AnySendable]

    init(raw: [String: Any]) {
        self.raw = raw.mapValues { AnySendable($0) }
        self.themeId = raw["themeId"] as? String
        self.themeName = raw["themeName"] as? String
        self.welcomeMessage = raw["welcomeMessage"] as? String
        self.placeholderText = raw["placeholderText"] as? String
        self.launcherWelcomeMessage = raw["launcherWelcomeMessage"] as? String
        self.connectingStatusText = raw["connectingStatusText"] as? String

        if let themeMap = raw["theme"] as? [String: Any] {
            self.theme = WidgetTheme(raw: themeMap)
        } else {
            self.theme = nil
        }
    }
}

/// Theme block of [WidgetConfig].
public struct WidgetTheme: Sendable {
    public let assistantName: String?
    public let primaryColor: String?
    public let primaryHoverColor: String?
    public let headerBackgroundColor: String?
    public let headerTextColor: String?
    public let backgroundColor: String?
    public let backgroundImage: String?
    public let surfaceColor: String?
    public let textColor: String?
    public let textMutedColor: String?
    public let borderColor: String?
    public let userBubbleColor: String?
    public let userBubbleTextColor: String?
    public let assistantBubbleColor: String?
    public let assistantBubbleTextColor: String?
    public let composeBarBackgroundColor: String?
    public let composeBarTextColor: String?
    public let composeBarPlaceholderColor: String?
    public let borderRadius: Int?
    public let messageBubbleRadius: String?
    public let density: String?
    public let baseFontSize: Int?
    public let launcherVariant: String?
    public let launcherLabel: String?
    public let launcherIcon: String?
    public let launcherShape: String?
    public let launcherSize: String?
    public let launcherRadius: Int?
    public let launcherBackgroundColor: String?
    public let launcherIconColor: String?
    public let launcherWelcomeEnabled: Bool?
    public let launcherWelcomeMessage: String?
    public let offset: Int?
    public let darkMode: Bool?
    public let raw: [String: AnySendable]

    init(raw: [String: Any]) {
        self.raw = raw.mapValues { AnySendable($0) }
        self.assistantName = raw["assistantName"] as? String
        self.primaryColor = raw["primaryColor"] as? String
        self.primaryHoverColor = raw["primaryHoverColor"] as? String
        self.headerBackgroundColor = raw["headerBackgroundColor"] as? String
        self.headerTextColor = raw["headerTextColor"] as? String
        self.backgroundColor = raw["backgroundColor"] as? String
        self.backgroundImage = raw["backgroundImage"] as? String
        self.surfaceColor = raw["surfaceColor"] as? String
        self.textColor = raw["textColor"] as? String
        self.textMutedColor = raw["textMutedColor"] as? String
        self.borderColor = raw["borderColor"] as? String
        self.userBubbleColor = raw["userBubbleColor"] as? String
        self.userBubbleTextColor = raw["userBubbleTextColor"] as? String
        self.assistantBubbleColor = raw["assistantBubbleColor"] as? String
        self.assistantBubbleTextColor = raw["assistantBubbleTextColor"] as? String
        self.composeBarBackgroundColor = raw["composeBarBackgroundColor"] as? String
        self.composeBarTextColor = raw["composeBarTextColor"] as? String
        self.composeBarPlaceholderColor = raw["composeBarPlaceholderColor"] as? String
        self.borderRadius = Self.asInt(raw["borderRadius"])
        self.messageBubbleRadius = raw["messageBubbleRadius"] as? String
        self.density = raw["density"] as? String
        self.baseFontSize = Self.asInt(raw["baseFontSize"])
        self.launcherVariant = raw["launcherVariant"] as? String
        self.launcherLabel = raw["launcherLabel"] as? String
        self.launcherIcon = raw["launcherIcon"] as? String
        self.launcherShape = raw["launcherShape"] as? String
        self.launcherSize = raw["launcherSize"] as? String
        self.launcherRadius = Self.asInt(raw["launcherRadius"])
        self.launcherBackgroundColor = raw["launcherBackgroundColor"] as? String
        self.launcherIconColor = raw["launcherIconColor"] as? String
        self.launcherWelcomeEnabled = raw["launcherWelcomeEnabled"] as? Bool
        self.launcherWelcomeMessage = raw["launcherWelcomeMessage"] as? String
        self.offset = Self.asInt(raw["offset"])
        self.darkMode = raw["darkMode"] as? Bool
    }

    private static func asInt(_ value: Any?) -> Int? {
        if let int = value as? Int { return int }
        if let double = value as? Double { return Int(double) }
        if let string = value as? String { return Int(string) }
        return nil
    }
}
