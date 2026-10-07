import Foundation

// MARK: - Main Configuration

public struct SDKConfiguration: Sendable {
    public let environment: String
    public let connection: ConnectionConfig
    public let channel: ChannelConfig?
    public let userContext: UserContextConfig?
    public let websocket: WebSocketConfig
    public let voice: VoiceConfig
    public let chat: ChatConfig
    public let storage: StorageConfig
    public let performance: PerformanceConfig
    public let accessibility: AccessibilityConfig
    public let theme: ThemeConfig
    public let debug: DebugConfig
    public let features: FeaturesConfig
    public let localization: LocalizationConfig
    public let security: SecurityConfig
    public let analytics: AnalyticsConfig?

    public init(
        environment: String,
        connection: ConnectionConfig,
        channel: ChannelConfig? = nil,
        userContext: UserContextConfig? = nil,
        websocket: WebSocketConfig = .default,
        voice: VoiceConfig = .default,
        chat: ChatConfig = .default,
        storage: StorageConfig = .default,
        performance: PerformanceConfig = .default,
        accessibility: AccessibilityConfig = .default,
        theme: ThemeConfig = .default,
        debug: DebugConfig = .default,
        features: FeaturesConfig = .default,
        localization: LocalizationConfig = .default,
        security: SecurityConfig = .default,
        analytics: AnalyticsConfig? = nil
    ) {
        self.environment = environment
        self.connection = connection
        self.channel = channel
        self.userContext = userContext
        self.websocket = websocket
        self.voice = voice
        self.chat = chat
        self.storage = storage
        self.performance = performance
        self.accessibility = accessibility
        self.theme = theme
        self.debug = debug
        self.features = features
        self.localization = localization
        self.security = security
        self.analytics = analytics
    }

    func copyWithUserContext(_ context: SDKUserContext) -> SDKConfiguration {
        SDKConfiguration(
            environment: environment,
            connection: connection,
            channel: channel,
            userContext: UserContextConfig(
                userId: context.userId,
                customAttributes: context.customAttributes
            ),
            websocket: websocket,
            voice: voice,
            chat: chat,
            storage: storage,
            performance: performance,
            accessibility: accessibility,
            theme: theme,
            debug: debug,
            features: features,
            localization: localization,
            security: security,
            analytics: analytics
        )
    }
}

// MARK: - Connection

public struct ConnectionConfig: Sendable {
    public let projectId: String
    public let endpoint: String
    public let apiKey: String?
    public let bootstrapToken: String?

    public init(projectId: String, endpoint: String, apiKey: String? = nil, bootstrapToken: String? = nil) {
        self.projectId = projectId
        self.endpoint = endpoint
        self.apiKey = apiKey
        self.bootstrapToken = bootstrapToken
    }
}

public struct ChannelConfig: Sendable {
    public let channelId: String?
    public let channelName: String?
    public let deploymentSlug: String?

    public init(channelId: String? = nil, channelName: String? = nil, deploymentSlug: String? = nil) {
        self.channelId = channelId
        self.channelName = channelName
        self.deploymentSlug = deploymentSlug
    }
}

public struct UserContextConfig: Sendable {
    public let userId: String?
    public let customAttributes: [String: AnySendable]?

    public init(userId: String? = nil, customAttributes: [String: AnySendable]? = nil) {
        self.userId = userId
        self.customAttributes = customAttributes
    }
}

// MARK: - WebSocket

public struct WebSocketConfig: Sendable {
    public let reconnection: ReconnectionConfig
    public let idleDisconnect: IdleDisconnectConfig

    public static let `default` = WebSocketConfig(
        reconnection: .default,
        idleDisconnect: .default
    )

    public init(reconnection: ReconnectionConfig, idleDisconnect: IdleDisconnectConfig) {
        self.reconnection = reconnection
        self.idleDisconnect = idleDisconnect
    }
}

public struct ReconnectionConfig: Sendable {
    public let enabled: Bool
    public let maxAttempts: Int
    public let baseDelayMs: Int
    public let maxDelayMs: Int
    public let exponentialBackoff: Bool

    public static let `default` = ReconnectionConfig()

    public init(
        enabled: Bool = true,
        maxAttempts: Int = 5,
        baseDelayMs: Int = 1000,
        maxDelayMs: Int = 30000,
        exponentialBackoff: Bool = true
    ) {
        self.enabled = enabled
        self.maxAttempts = maxAttempts
        self.baseDelayMs = baseDelayMs
        self.maxDelayMs = maxDelayMs
        self.exponentialBackoff = exponentialBackoff
    }
}

public struct IdleDisconnectConfig: Sendable {
    public let enabled: Bool
    public let timeoutMs: Int
    public let behavior: String

    public static let `default` = IdleDisconnectConfig()

    public init(enabled: Bool = false, timeoutMs: Int = 900_000, behavior: String = "disconnect") {
        self.enabled = enabled
        self.timeoutMs = timeoutMs
        self.behavior = behavior
    }
}

// MARK: - Chat

public struct ChatConfig: Sendable {
    public let maxMessagesLocal: Int
    public let historyPageSize: Int
    public let maxHistoryPages: Int
    public let enableTypingIndicator: Bool
    public let enableThoughts: Bool
    public let enableFileUpload: Bool
    public let maxFileSizeMb: Int
    public let allowedFileTypes: [String]

    public static let `default` = ChatConfig()

    public init(
        maxMessagesLocal: Int = 10_000,
        historyPageSize: Int = 200,
        maxHistoryPages: Int = 20,
        enableTypingIndicator: Bool = true,
        enableThoughts: Bool = false,
        enableFileUpload: Bool = true,
        maxFileSizeMb: Int = 10,
        allowedFileTypes: [String] = ["image/jpeg", "image/png", "application/pdf"]
    ) {
        self.maxMessagesLocal = maxMessagesLocal
        self.historyPageSize = historyPageSize
        self.maxHistoryPages = maxHistoryPages
        self.enableTypingIndicator = enableTypingIndicator
        self.enableThoughts = enableThoughts
        self.enableFileUpload = enableFileUpload
        self.maxFileSizeMb = maxFileSizeMb
        self.allowedFileTypes = allowedFileTypes
    }
}

// MARK: - Other Config Sections

public struct VoiceConfig: Sendable {
    public let enabled: Bool
    public let mode: String
    public let enableBargeIn: Bool
    public let enableVad: Bool
    public let sampleRate: Int
    public let channels: Int

    public static let `default` = VoiceConfig()

    public init(
        enabled: Bool = true,
        mode: String = "pipeline",
        enableBargeIn: Bool = true,
        enableVad: Bool = true,
        sampleRate: Int = 16_000,
        channels: Int = 1
    ) {
        self.enabled = enabled
        self.mode = mode
        self.enableBargeIn = enableBargeIn
        self.enableVad = enableVad
        self.sampleRate = sampleRate
        self.channels = channels
    }
}

public struct StorageConfig: Sendable {
    public let enableMessageCache: Bool
    public let enableOfflineQueue: Bool
    public let secureStorageKeyPrefix: String
    public let cacheTtlDays: Int

    public static let `default` = StorageConfig()

    public init(
        enableMessageCache: Bool = true,
        enableOfflineQueue: Bool = true,
        secureStorageKeyPrefix: String = "artemis_sdk",
        cacheTtlDays: Int = 30
    ) {
        self.enableMessageCache = enableMessageCache
        self.enableOfflineQueue = enableOfflineQueue
        self.secureStorageKeyPrefix = secureStorageKeyPrefix
        self.cacheTtlDays = cacheTtlDays
    }
}

public struct PerformanceConfig: Sendable {
    public let lowPowerMode: Bool
    public let reducedAnimations: Bool
    public let imageQuality: Double
    public let enablePagination: Bool
    public let prefetchAvatars: Bool

    public static let `default` = PerformanceConfig()

    public init(
        lowPowerMode: Bool = false,
        reducedAnimations: Bool = false,
        imageQuality: Double = 0.8,
        enablePagination: Bool = true,
        prefetchAvatars: Bool = true
    ) {
        self.lowPowerMode = lowPowerMode
        self.reducedAnimations = reducedAnimations
        self.imageQuality = imageQuality
        self.enablePagination = enablePagination
        self.prefetchAvatars = prefetchAvatars
    }
}

public struct AccessibilityConfig: Sendable {
    public let screenReaderEnabled: Bool
    public let minTouchTargetSize: Double
    public let highContrastMode: Bool
    public let hapticFeedback: Bool

    public static let `default` = AccessibilityConfig()

    public init(
        screenReaderEnabled: Bool = true,
        minTouchTargetSize: Double = 44,
        highContrastMode: Bool = false,
        hapticFeedback: Bool = true
    ) {
        self.screenReaderEnabled = screenReaderEnabled
        self.minTouchTargetSize = minTouchTargetSize
        self.highContrastMode = highContrastMode
        self.hapticFeedback = hapticFeedback
    }
}

public struct ThemeConfig: Sendable {
    public let primaryColor: String
    public let textColor: String
    public let backgroundColor: String
    public let surfaceColor: String
    public let borderRadius: Double
    public let fontFamily: String
    public let darkMode: Bool

    public static let `default` = ThemeConfig()

    public init(
        primaryColor: String = "#0066FF",
        textColor: String = "#1A1A1A",
        backgroundColor: String = "#FFFFFF",
        surfaceColor: String = "#F5F5F5",
        borderRadius: Double = 12,
        fontFamily: String = "System",
        darkMode: Bool = false
    ) {
        self.primaryColor = primaryColor
        self.textColor = textColor
        self.backgroundColor = backgroundColor
        self.surfaceColor = surfaceColor
        self.borderRadius = borderRadius
        self.fontFamily = fontFamily
        self.darkMode = darkMode
    }
}

public struct DebugConfig: Sendable {
    public let enabled: Bool
    public let logLevel: String
    public let logNetworkRequests: Bool
    public let logWebsocketMessages: Bool
    public let printLogs: Bool

    public static let `default` = DebugConfig()

    public init(
        enabled: Bool = false,
        logLevel: String = "info",
        logNetworkRequests: Bool = false,
        logWebsocketMessages: Bool = false,
        printLogs: Bool = false
    ) {
        self.enabled = enabled
        self.logLevel = logLevel
        self.logNetworkRequests = logNetworkRequests
        self.logWebsocketMessages = logWebsocketMessages
        self.printLogs = printLogs
    }
}

public struct FeaturesConfig: Sendable {
    public let enableRichContent: Bool
    public let enableMarkdown: Bool
    public let enableCarousel: Bool
    public let enableKpiCards: Bool
    public let enableForms: Bool
    public let enableQuickReplies: Bool
    public let enableVoice: Bool
    public let enableFileUpload: Bool
    public let enableFeedback: Bool
    public let enableActivityUpdates: Bool

    public static let `default` = FeaturesConfig()

    public init(
        enableRichContent: Bool = true,
        enableMarkdown: Bool = true,
        enableCarousel: Bool = true,
        enableKpiCards: Bool = true,
        enableForms: Bool = true,
        enableQuickReplies: Bool = true,
        enableVoice: Bool = true,
        enableFileUpload: Bool = true,
        enableFeedback: Bool = true,
        enableActivityUpdates: Bool = false
    ) {
        self.enableRichContent = enableRichContent
        self.enableMarkdown = enableMarkdown
        self.enableCarousel = enableCarousel
        self.enableKpiCards = enableKpiCards
        self.enableForms = enableForms
        self.enableQuickReplies = enableQuickReplies
        self.enableVoice = enableVoice
        self.enableFileUpload = enableFileUpload
        self.enableFeedback = enableFeedback
        self.enableActivityUpdates = enableActivityUpdates
    }
}

public struct LocalizationConfig: Sendable {
    public let defaultLocale: String
    public let supportedLocales: [String]
    public let fallbackLocale: String

    public static let `default` = LocalizationConfig()

    public init(
        defaultLocale: String = "en",
        supportedLocales: [String] = ["en", "es", "fr"],
        fallbackLocale: String = "en"
    ) {
        self.defaultLocale = defaultLocale
        self.supportedLocales = supportedLocales
        self.fallbackLocale = fallbackLocale
    }
}

public struct SecurityConfig: Sendable {
    public let enforceTls: Bool
    public let validateCertificates: Bool
    public let enableCertificatePinning: Bool
    public let certificatePins: [String]

    public static let `default` = SecurityConfig()

    public init(
        enforceTls: Bool = true,
        validateCertificates: Bool = true,
        enableCertificatePinning: Bool = false,
        certificatePins: [String] = []
    ) {
        self.enforceTls = enforceTls
        self.validateCertificates = validateCertificates
        self.enableCertificatePinning = enableCertificatePinning
        self.certificatePins = certificatePins
    }
}

public struct AnalyticsConfig: Sendable {
    public let enabled: Bool
    public let provider: String?
    public let trackEvents: [String]

    public init(enabled: Bool = false, provider: String? = nil, trackEvents: [String] = []) {
        self.enabled = enabled
        self.provider = provider
        self.trackEvents = trackEvents
    }
}

// MARK: - Parsing

enum SDKConfigurationParser {
    static func parse(from map: [String: Any]) -> SDKConfiguration {
        let connectionMap = map["connection"] as? [String: Any] ?? [:]
        let websocketMap = map["websocket"] as? [String: Any] ?? [:]
        let reconnectionMap = websocketMap["reconnection"] as? [String: Any] ?? [:]
        let idleMap = websocketMap["idle_disconnect"] as? [String: Any] ?? [:]
        let chatMap = map["chat"] as? [String: Any] ?? [:]
        let voiceMap = map["voice"] as? [String: Any] ?? [:]
        let storageMap = map["storage"] as? [String: Any] ?? [:]
        let performanceMap = map["performance"] as? [String: Any] ?? [:]
        let accessibilityMap = map["accessibility"] as? [String: Any] ?? [:]
        let themeMap = map["theme"] as? [String: Any] ?? [:]
        let debugMap = map["debug"] as? [String: Any] ?? [:]
        let featuresMap = map["features"] as? [String: Any] ?? [:]
        let localizationMap = map["localization"] as? [String: Any] ?? [:]
        let securityMap = map["security"] as? [String: Any] ?? [:]

        var channel: ChannelConfig?
        if let channelMap = map["channel"] as? [String: Any] {
            channel = ChannelConfig(
                channelId: channelMap["channel_id"] as? String,
                channelName: channelMap["channel_name"] as? String,
                deploymentSlug: channelMap["deployment_slug"] as? String
            )
        }

        var userContext: UserContextConfig?
        if let userMap = map["user_context"] as? [String: Any] {
            let attrs = userMap["custom_attributes"] as? [String: Any]
            userContext = UserContextConfig(
                userId: userMap["user_id"] as? String,
                customAttributes: JSONValue.anySendableDictionary(from: attrs)
            )
        }

        var analytics: AnalyticsConfig?
        if let analyticsMap = map["analytics"] as? [String: Any] {
            analytics = AnalyticsConfig(
                enabled: analyticsMap["enabled"] as? Bool ?? false,
                provider: analyticsMap["provider"] as? String,
                trackEvents: analyticsMap["track_events"] as? [String] ?? []
            )
        }

        return SDKConfiguration(
            environment: map["environment"] as? String ?? "dev",
            connection: ConnectionConfig(
                projectId: connectionMap["project_id"] as? String ?? "",
                endpoint: connectionMap["endpoint"] as? String ?? "",
                apiKey: connectionMap["api_key"] as? String,
                bootstrapToken: connectionMap["bootstrap_token"] as? String
            ),
            channel: channel,
            userContext: userContext,
            websocket: WebSocketConfig(
                reconnection: ReconnectionConfig(
                    enabled: reconnectionMap["enabled"] as? Bool ?? true,
                    maxAttempts: intValue(reconnectionMap["max_attempts"], default: 5),
                    baseDelayMs: intValue(reconnectionMap["base_delay_ms"], default: 1000),
                    maxDelayMs: intValue(reconnectionMap["max_delay_ms"], default: 30_000),
                    exponentialBackoff: reconnectionMap["exponential_backoff"] as? Bool ?? true
                ),
                idleDisconnect: IdleDisconnectConfig(
                    enabled: idleMap["enabled"] as? Bool ?? false,
                    timeoutMs: intValue(idleMap["timeout_ms"], default: 900_000),
                    behavior: idleMap["behavior"] as? String ?? "disconnect"
                )
            ),
            voice: VoiceConfig(
                enabled: voiceMap["enabled"] as? Bool ?? true,
                mode: voiceMap["mode"] as? String ?? "pipeline",
                enableBargeIn: voiceMap["enable_barge_in"] as? Bool ?? true,
                enableVad: voiceMap["enable_vad"] as? Bool ?? true,
                sampleRate: intValue(voiceMap["sample_rate"], default: 16_000),
                channels: intValue(voiceMap["channels"], default: 1)
            ),
            chat: ChatConfig(
                maxMessagesLocal: intValue(chatMap["max_messages_local"], default: 10_000),
                historyPageSize: intValue(chatMap["history_page_size"], default: 200),
                maxHistoryPages: intValue(chatMap["max_history_pages"], default: 20),
                enableTypingIndicator: chatMap["enable_typing_indicator"] as? Bool ?? true,
                enableThoughts: chatMap["enable_thoughts"] as? Bool ?? false,
                enableFileUpload: chatMap["enable_file_upload"] as? Bool ?? true,
                maxFileSizeMb: intValue(chatMap["max_file_size_mb"], default: 10),
                allowedFileTypes: chatMap["allowed_file_types"] as? [String]
                    ?? ["image/jpeg", "image/png", "application/pdf"]
            ),
            storage: StorageConfig(
                enableMessageCache: storageMap["enable_message_cache"] as? Bool ?? true,
                enableOfflineQueue: storageMap["enable_offline_queue"] as? Bool ?? true,
                secureStorageKeyPrefix: storageMap["secure_storage_key_prefix"] as? String ?? "artemis_sdk",
                cacheTtlDays: intValue(storageMap["cache_ttl_days"], default: 30)
            ),
            performance: PerformanceConfig(
                lowPowerMode: performanceMap["low_power_mode"] as? Bool ?? false,
                reducedAnimations: performanceMap["reduced_animations"] as? Bool ?? false,
                imageQuality: doubleValue(performanceMap["image_quality"], default: 0.8),
                enablePagination: performanceMap["enable_pagination"] as? Bool ?? true,
                prefetchAvatars: performanceMap["prefetch_avatars"] as? Bool ?? true
            ),
            accessibility: AccessibilityConfig(
                screenReaderEnabled: accessibilityMap["screen_reader_enabled"] as? Bool ?? true,
                minTouchTargetSize: doubleValue(accessibilityMap["min_touch_target_size"], default: 44),
                highContrastMode: accessibilityMap["high_contrast_mode"] as? Bool ?? false,
                hapticFeedback: accessibilityMap["haptic_feedback"] as? Bool ?? true
            ),
            theme: ThemeConfig(
                primaryColor: themeMap["primary_color"] as? String ?? "#0066FF",
                textColor: themeMap["text_color"] as? String ?? "#1A1A1A",
                backgroundColor: themeMap["background_color"] as? String ?? "#FFFFFF",
                surfaceColor: themeMap["surface_color"] as? String ?? "#F5F5F5",
                borderRadius: doubleValue(themeMap["border_radius"], default: 12),
                fontFamily: themeMap["font_family"] as? String ?? "System",
                darkMode: themeMap["dark_mode"] as? Bool ?? false
            ),
            debug: DebugConfig(
                enabled: debugMap["enabled"] as? Bool ?? false,
                logLevel: debugMap["log_level"] as? String ?? "info",
                logNetworkRequests: debugMap["log_network_requests"] as? Bool ?? false,
                logWebsocketMessages: debugMap["log_websocket_messages"] as? Bool ?? false,
                printLogs: debugMap["print_logs"] as? Bool ?? false
            ),
            features: FeaturesConfig(
                enableRichContent: featuresMap["enable_rich_content"] as? Bool ?? true,
                enableMarkdown: featuresMap["enable_markdown"] as? Bool ?? true,
                enableCarousel: featuresMap["enable_carousel"] as? Bool ?? true,
                enableKpiCards: featuresMap["enable_kpi_cards"] as? Bool ?? true,
                enableForms: featuresMap["enable_forms"] as? Bool ?? true,
                enableQuickReplies: featuresMap["enable_quick_replies"] as? Bool ?? true,
                enableVoice: featuresMap["enable_voice"] as? Bool ?? true,
                enableFileUpload: featuresMap["enable_file_upload"] as? Bool ?? true,
                enableFeedback: featuresMap["enable_feedback"] as? Bool ?? true,
                enableActivityUpdates: featuresMap["enable_activity_updates"] as? Bool ?? false
            ),
            localization: LocalizationConfig(
                defaultLocale: localizationMap["default_locale"] as? String ?? "en",
                supportedLocales: localizationMap["supported_locales"] as? [String] ?? ["en", "es", "fr"],
                fallbackLocale: localizationMap["fallback_locale"] as? String ?? "en"
            ),
            security: SecurityConfig(
                enforceTls: securityMap["enforce_tls"] as? Bool ?? true,
                validateCertificates: securityMap["validate_certificates"] as? Bool ?? true,
                enableCertificatePinning: securityMap["enable_certificate_pinning"] as? Bool ?? false,
                certificatePins: securityMap["certificate_pins"] as? [String] ?? []
            ),
            analytics: analytics
        )
    }

    private static func intValue(_ value: Any?, default defaultValue: Int) -> Int {
        if let int = value as? Int { return int }
        if let double = value as? Double { return Int(double) }
        if let string = value as? String, let int = Int(string) { return int }
        return defaultValue
    }

    private static func doubleValue(_ value: Any?, default defaultValue: Double) -> Double {
        if let double = value as? Double { return double }
        if let int = value as? Int { return Double(int) }
        if let string = value as? String, let double = Double(string) { return double }
        return defaultValue
    }
}
