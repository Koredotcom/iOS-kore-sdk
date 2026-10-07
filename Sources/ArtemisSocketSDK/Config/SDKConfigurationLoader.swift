import Foundation
import Yams

/// Loads and validates SDK configuration from YAML or JSON files.
public enum SDKConfigurationLoader {
    private static let defaultConfigName = "sdk_configurations"

    /// Load configuration from a file URL (YAML or JSON).
    public static func load(
        from url: URL,
        environment: String? = nil,
        environmentOverrideURL: URL? = nil
    ) throws -> SDKConfiguration {
        let baseConfig = try loadFile(url)
        let env = environment
            ?? (baseConfig["artemis_sdk"] as? [String: Any])?["environment"] as? String
            ?? "dev"

        var envConfig: [String: Any]?
        if let overrideURL = environmentOverrideURL {
            envConfig = try? loadFile(overrideURL)
        } else {
            let envURL = url.deletingLastPathComponent()
                .appendingPathComponent("\(defaultConfigName).\(env)")
                .appendingPathExtension(url.pathExtension)
            envConfig = try? loadFile(envURL)
        }

        let merged = mergeConfigs(base: baseConfig, override: envConfig)
        guard let artemisSDK = merged["artemis_sdk"] as? [String: Any] else {
            throw SDKConfigurationError(message: "Configuration must have \"artemis_sdk\" root key")
        }

        let config = SDKConfigurationParser.parse(from: artemisSDK)
        try validate(config)
        return config
    }

    /// Load configuration from a bundle resource (e.g. `sdk_configurations.yaml`).
    public static func load(
        fromBundle bundle: Bundle = .main,
        resourceName: String = "sdk_configurations",
        resourceExtension: String = "yaml",
        environment: String? = nil,
        runtimeUserContext: SDKUserContext? = nil
    ) throws -> SDKConfiguration {
        guard let url = bundle.url(forResource: resourceName, withExtension: resourceExtension) else {
            throw SDKConfigurationError(
                message: "Configuration file \(resourceName).\(resourceExtension) not found in bundle"
            )
        }

        var config = try load(from: url, environment: environment)
        if let runtimeUserContext {
            config = config.copyWithUserContext(runtimeUserContext)
        }
        return config
    }

    /// Load configuration from raw YAML string.
    public static func load(
        yaml: String,
        environment: String? = nil,
        runtimeUserContext: SDKUserContext? = nil
    ) throws -> SDKConfiguration {
        guard let yamlObject = try Yams.load(yaml: yaml) else {
            throw SDKConfigurationError(message: "Failed to parse YAML configuration")
        }
        let baseConfig = yamlToDictionary(yamlObject)
        let env = environment
            ?? (baseConfig["artemis_sdk"] as? [String: Any])?["environment"] as? String
            ?? "dev"

        guard let artemisSDK = baseConfig["artemis_sdk"] as? [String: Any] else {
            throw SDKConfigurationError(message: "Configuration must have \"artemis_sdk\" root key")
        }

        var config = SDKConfigurationParser.parse(from: artemisSDK)
        _ = env // environment-specific overrides require a second file in bundle workflows
        try validate(config)
        if let runtimeUserContext {
            config = config.copyWithUserContext(runtimeUserContext)
        }
        return config
    }

    /// Create a programmatic configuration for testing or quick integration.
    public static func createDefault(
        projectId: String,
        endpoint: String,
        apiKey: String? = nil,
        channelId: String? = nil
    ) -> SDKConfiguration {
        SDKConfiguration(
            environment: "dev",
            connection: ConnectionConfig(projectId: projectId, endpoint: endpoint, apiKey: apiKey),
            channel: channelId.map { ChannelConfig(channelId: $0) },
            debug: DebugConfig(enabled: true, printLogs: true),
            security: SecurityConfig(enforceTls: false, validateCertificates: false)
        )
    }

    // MARK: - Private

    private static func loadFile(_ url: URL) throws -> [String: Any] {
        let content = try String(contentsOf: url, encoding: .utf8)
        let ext = url.pathExtension.lowercased()

        if ext == "yaml" || ext == "yml" {
            guard let yamlObject = try Yams.load(yaml: content) else {
                throw SDKConfigurationError(message: "Failed to parse YAML at \(url.lastPathComponent)")
            }
            return yamlToDictionary(yamlObject)
        }

        if ext == "json" {
            let data = content.data(using: .utf8) ?? Data()
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                throw SDKConfigurationError(message: "Failed to parse JSON at \(url.lastPathComponent)")
            }
            return json
        }

        throw SDKConfigurationError(message: "Unsupported config file format: \(url.pathExtension)")
    }

    private static func yamlToDictionary(_ value: Any) -> [String: Any] {
        if let dict = value as? [String: Any] {
            return dict.mapValues { yamlToAny($0) }
        }
        if let dict = value as? [AnyHashable: Any] {
            var result: [String: Any] = [:]
            for (key, val) in dict {
                result[String(describing: key)] = yamlToAny(val)
            }
            return result
        }
        return [:]
    }

    private static func yamlToAny(_ value: Any) -> Any {
        if let dict = value as? [String: Any] {
            return dict.mapValues { yamlToAny($0) }
        }
        if let dict = value as? [AnyHashable: Any] {
            var result: [String: Any] = [:]
            for (key, val) in dict {
                result[String(describing: key)] = yamlToAny(val)
            }
            return result
        }
        if let array = value as? [Any] {
            return array.map { yamlToAny($0) }
        }
        return value
    }

    private static func mergeConfigs(base: [String: Any], override: [String: Any]?) -> [String: Any] {
        guard let override else { return base }
        var result = base
        for (key, value) in override {
            if let overrideMap = value as? [String: Any],
               let baseMap = result[key] as? [String: Any] {
                result[key] = mergeConfigs(base: baseMap, override: overrideMap)
            } else {
                result[key] = value
            }
        }
        return result
    }

    private static func validate(_ config: SDKConfiguration) throws {
        var errors: [String] = []

        if config.connection.projectId.isEmpty {
            errors.append("connection.project_id is required and cannot be empty")
        }
        if config.connection.endpoint.isEmpty {
            errors.append("connection.endpoint is required and cannot be empty")
        }
        if !config.connection.endpoint.hasPrefix("http://") &&
            !config.connection.endpoint.hasPrefix("https://") {
            errors.append("connection.endpoint must start with http:// or https://")
        }
        if config.connection.apiKey == nil && config.connection.bootstrapToken == nil {
            errors.append("Either connection.api_key or connection.bootstrap_token is required")
        }
        if config.connection.apiKey != nil && config.connection.bootstrapToken != nil {
            errors.append("Cannot specify both connection.api_key and connection.bootstrap_token")
        }
        if config.environment == "prod" && config.connection.endpoint.hasPrefix("http://") {
            errors.append("Production environment must use HTTPS endpoint")
        }
        if config.voice.enabled &&
            config.voice.mode != "pipeline" &&
            config.voice.mode != "realtime" {
            errors.append("voice.mode must be either \"pipeline\" or \"realtime\"")
        }
        if config.voice.enabled && config.voice.sampleRate <= 0 {
            errors.append("voice.sample_rate must be greater than 0")
        }
        if config.chat.maxFileSizeMb <= 0 {
            errors.append("chat.max_file_size_mb must be greater than 0")
        }
        if config.websocket.reconnection.enabled {
            if config.websocket.reconnection.maxAttempts <= 0 {
                errors.append("websocket.reconnection.max_attempts must be greater than 0")
            }
            if config.websocket.reconnection.baseDelayMs <= 0 {
                errors.append("websocket.reconnection.base_delay_ms must be greater than 0")
            }
            if config.websocket.reconnection.maxDelayMs < config.websocket.reconnection.baseDelayMs {
                errors.append("websocket.reconnection.max_delay_ms must be >= base_delay_ms")
            }
        }

        if !errors.isEmpty {
            throw SDKConfigurationError(
                message: "Configuration validation failed:\n" + errors.map { "  - \($0)" }.joined(separator: "\n")
            )
        }
    }
}
